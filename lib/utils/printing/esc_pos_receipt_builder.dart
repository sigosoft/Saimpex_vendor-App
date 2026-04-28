import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:saimpex_vendor/model/OrderDetailsModel.dart';

class EscPosReceiptBuildResult {
  final List<int> bytes80mm;
  final List<int> bytes58mm;
  final String preview;

  const EscPosReceiptBuildResult({
    required this.bytes80mm,
    required this.bytes58mm,
    required this.preview,
  });
}

class EscPosReceiptBuilder {
  static const int _lineWidth80mm = 48;
  static const int _lineWidth58mm = 32;

  // Printer paper widths in dots (203 dpi)
  static const int _paperDots80mm = 576;
  static const int _paperDots58mm = 384;

  // Logo print width in pixels
  static const int _logoWidth80mm = 220;
  static const int _logoWidth58mm = 140;

  Future<EscPosReceiptBuildResult> buildReceipt(
    Data data, {
    String? vendorName,
    int feedLines = 6,
    bool withCut = true,
  }) async {
    // Pre-load logo bytes for both paper sizes
    final logoBytes80 = await _buildLogoBytes(_logoWidth80mm, _paperDots80mm);
    final logoBytes58 = await _buildLogoBytes(_logoWidth58mm, _paperDots58mm);

    final previewLines = <String>[];

    List<int> buildForWidth(bool is58mm) {
      final bytes = <int>[];
      final lineWidth = is58mm ? _lineWidth58mm : _lineWidth80mm;
      final logoBytes = is58mm ? logoBytes58 : logoBytes80;

      void addBytes(List<int> value) => bytes.addAll(value);

      void addText(String text) {
        addBytes(latin1.encode('$text\n'));
        if (!is58mm) previewLines.add(text);
      }

      void center() => addBytes(const [0x1B, 0x61, 0x01]);
      void left() => addBytes(const [0x1B, 0x61, 0x00]);
      void bold(bool on) => addBytes([0x1B, 0x45, on ? 0x01 : 0x00]);
      void doubleSize(bool on) =>
          addBytes([0x1D, 0x21, on ? 0x11 : 0x00]); // GS ! : double W+H
      void reverseVideo(bool on) =>
          addBytes([0x1D, 0x42, on ? 0x01 : 0x00]); // GS B

      // ── Init printer ──────────────────────────────────────────────────
      addBytes(const [0x1B, 0x40]);

      // ── LOGO ──────────────────────────────────────────────────────────
      center();
      if (logoBytes.isNotEmpty) {
        addBytes(logoBytes);
        addText(''); // newline after logo
      }
      addText(''); // blank line

      // ── VENDOR / RESTAURANT NAME ───────────────────────────────────────
      final vName = (vendorName?.trim().isNotEmpty == true)
          ? vendorName!.trim()
          : '';
      if (vName.isNotEmpty) {
        center();
        bold(true);
        if (!is58mm) doubleSize(true);
        addText(vName);
        if (!is58mm) doubleSize(false);
        bold(false);
        addText(''); // blank line
      }

      // ── ORDER CODE ────────────────────────────────────────────────────
      center();
      final orderCode = (data.orderCode?.trim().isNotEmpty == true)
          ? data.orderCode!.trim()
          : '#${data.id ?? '-'}';
      addText(orderCode);
      addText(''); // blank line

      // ── ORDER TYPE BADGE (inverted / black box) ────────────────────────
      center();
      bold(true);
      reverseVideo(true);
      final typeLabel = _orderTypeLabel(data.type);
      // Pad to create the "badge" width effect
      final badgeWidth = is58mm ? 16 : 20;
      final badge = typeLabel
          .padLeft((badgeWidth + typeLabel.length) ~/ 2)
          .padRight(badgeWidth);
      addText(badge);
      reverseVideo(false);
      bold(false);
      addText(''); // blank line

      // ── DATE & TIME ───────────────────────────────────────────────────
      center();
      addText(_formattedDate(data.placedAt));
      addText(''); // blank line

      // ── DIVIDER ───────────────────────────────────────────────────────
      left();
      addText(_solidLine(lineWidth));

      // ── CUSTOMER NAME ─────────────────────────────────────────────────
      addText('Name: ${_clean(data.userName)}');
      addText(''); // blank line
      addText(_solidLine(lineWidth));

      // ── ITEMS HEADER ──────────────────────────────────────────────────
      addText(_itemHeader(lineWidth, is58mm));
      addText(''); // blank line
      addText(_solidLine(lineWidth));

      // ── ITEM ROWS ─────────────────────────────────────────────────────
      final items = _extractItems(data);
      if (items.isEmpty) {
        addText('');
        addText('No items');
        addText('');
      } else {
        for (final item in items) {
          addText('');
          addText(_itemRow(item, lineWidth, is58mm));
          addText('');
        }
      }

      // ── DIVIDER ───────────────────────────────────────────────────────
      addText(_solidLine(lineWidth));
      addText(''); // blank line

      // ── SUBTOTAL / DELIVERY FEE / TAX ─────────────────────────────────
      left();
      addText(_amountRow('Subtotal', _num(data.subtotal), lineWidth));
      addText(_amountRow('Delivery Fee', _num(data.deliveryFee), lineWidth));
      addText(_amountRow('Tax', _num(data.tax), lineWidth));

      // ── DASHED DIVIDER ────────────────────────────────────────────────
      addText(_dashedLine(lineWidth));

      // ── TOTAL (bold) ──────────────────────────────────────────────────
      bold(true);
      addText(_amountRow('Total', _num(data.total), lineWidth));
      bold(false);

      // ── DASHED DIVIDER ────────────────────────────────────────────────
      addText(_dashedLine(lineWidth));

      // ── PAYMENT ───────────────────────────────────────────────────────
      addText('Payment : ${_clean(data.paymentType)}');

      // ── DASHED DIVIDER ────────────────────────────────────────────────
      addText(_dashedLine(lineWidth));

      // ── DELIVERY NOTES ────────────────────────────────────────────────
      final note = data.customerNote?.toString().trim() ?? '';
      if (note.isNotEmpty) {
        addText('Delivery Notes: $note');
      } else {
        addText('Delivery Notes: -');
      }

      // ── FINAL SOLID DIVIDER ───────────────────────────────────────────
      addText(_solidLine(lineWidth));

      // ── THANK YOU ─────────────────────────────────────────────────────
      center();
      addText('');
      addText('Thank you for choosing Saimpex!');
      addText('We appreciate your order');
      addText('');

      // ── FEED & CUT ────────────────────────────────────────────────────
      final safeFeed = feedLines < 4 ? 4 : feedLines;
      addBytes([0x1B, 0x64, safeFeed]);
      if (withCut && !is58mm) {
        addBytes(const [0x1D, 0x56, 0x00]); // GS V 0 : full cut
      }

      return bytes;
    }

    final bytes80 = buildForWidth(false);
    final bytes58 = buildForWidth(true);

    return EscPosReceiptBuildResult(
      bytes80mm: bytes80,
      bytes58mm: bytes58,
      preview: previewLines.join('\n'),
    );
  }

  // ── Logo → ESC/POS raster (GS v 0) ───────────────────────────────────────
  Future<List<int>> _buildLogoBytes(int targetWidth, int paperDots) async {
    try {
      final assetData = await rootBundle.load('lib/assets/images/logo.png');
      final pngBytes = assetData.buffer.asUint8List();

      img.Image? image = img.decodeImage(pngBytes);
      if (image == null) return [];

      // Resize maintaining aspect ratio
      final targetHeight = (image.height * targetWidth / image.width).round();
      image = img.copyResize(
        image,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.average,
      );

      final w = image.width;
      final h = image.height;

      // Total bytes per row for the full paper width
      final totalBytesPerRow = (paperDots + 7) ~/ 8;
      // Left offset to center the logo
      final leftDotOffset = (paperDots - w) ~/ 2;
      final leftByteOffset = leftDotOffset ~/ 8;

      final rasterData = <int>[];
      for (int y = 0; y < h; y++) {
        final row = List<int>.filled(totalBytesPerRow, 0);
        for (int x = 0; x < w; x++) {
          final pixel = image.getPixel(x, y);
          // Compute luminance: dark pixel → print dot
          final lum = (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114);
          if (lum < 200) {
            // threshold to convert white background to blank
            final bytePos = leftByteOffset + (x ~/ 8);
            final bitPos = 7 - (x % 8);
            if (bytePos < totalBytesPerRow) {
              row[bytePos] |= (1 << bitPos);
            }
          }
        }
        rasterData.addAll(row);
      }

      // GS v 0 raster image command
      final xL = totalBytesPerRow & 0xFF;
      final xH = (totalBytesPerRow >> 8) & 0xFF;
      final yL = h & 0xFF;
      final yH = (h >> 8) & 0xFF;
      return [0x1D, 0x76, 0x30, 0x00, xL, xH, yL, yH, ...rasterData];
    } catch (_) {
      return []; // Skip logo gracefully if loading fails
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _orderTypeLabel(String? type) {
    if (type == null || type.trim().isEmpty) return 'Order';
    final t = type.toLowerCase();
    if (t.contains('delivery')) return 'Delivery';
    if (t.contains('pickup') || t.contains('take')) return 'Pickup';
    if (t.contains('basket')) return 'Basket Order';
    if (t.contains('dine') || t.contains('table')) return 'Dine In';
    // Capitalize first letter
    return type.trim()[0].toUpperCase() + type.trim().substring(1);
  }

  String _formattedDate(DateTime? value) {
    if (value == null) return '-';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = value.day.toString().padLeft(2, '0');
    final month = months[value.month - 1];
    final year = value.year;
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final min = value.minute.toString().padLeft(2, '0');
    final ampm = value.hour >= 12 ? 'PM' : 'AM';
    return '$day $month $year  |  $hour:$min $ampm';
  }

  String _clean(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? '-' : v;
  }

  String _num(String? value) {
    final n = double.tryParse((value ?? '').trim());
    return (n ?? 0).toStringAsFixed(2);
  }

  String _solidLine(int width) => '-' * width;

  String _dashedLine(int width) {
    // "- - - - -" pattern
    final sb = StringBuffer();
    int count = 0;
    while (count < width) {
      sb.write(count + 1 < width ? '- ' : '-');
      count += 2;
    }
    return sb.toString().substring(0, width);
  }

  String _amountRow(String label, String amount, int width) {
    // label left, amount right
    final amtWidth = 10;
    final labelWidth = width - amtWidth;
    final l = _fit(label, labelWidth);
    final r = _fitRight(amount, amtWidth);
    return '$l$r';
  }

  // 3-column: Items | Qty | Amount
  String _itemHeader(int width, bool is58mm) {
    if (is58mm) {
      // 32 chars: Items(18) Qty(6) Amount(8)
      final name = _fit('Items', 18);
      final qty = _fit('Qty', 6);
      final amt = _fitRight('Amount', 8);
      return '$name$qty$amt';
    } else {
      // 48 chars: Items(28) Qty(8) Amount(12)
      final name = _fit('Items', 28);
      final qty = _fit('Qty', 8);
      final amt = _fitRight('Amount', 12);
      return '$name$qty$amt';
    }
  }

  String _itemRow(_ReceiptItem item, int width, bool is58mm) {
    final qtyStr = 'x ${item.qty}';
    if (is58mm) {
      final name = _fit(item.name, 18);
      final qty = _fit(qtyStr, 6);
      final amt = _fitRight(item.total, 8);
      return '$name$qty$amt';
    } else {
      final name = _fit(item.name, 28);
      final qty = _fit(qtyStr, 8);
      final amt = _fitRight(item.total, 12);
      return '$name$qty$amt';
    }
  }

  String _fit(String value, int width) {
    final sanitized = value.replaceAll('\n', ' ').trim();
    if (sanitized.length >= width) return sanitized.substring(0, width);
    return sanitized.padRight(width);
  }

  String _fitRight(String value, int width) {
    final sanitized = value.replaceAll('\n', ' ').trim();
    if (sanitized.length >= width)
      return sanitized.substring(sanitized.length - width);
    return sanitized.padLeft(width);
  }

  List<_ReceiptItem> _extractItems(Data data) {
    final items = <_ReceiptItem>[];

    for (final row in data.orderItems ?? <OrderItem>[]) {
      final qty = row.quantity ?? 1;
      final total = _num(row.price);
      final name =
          row.orderItem?.nameEn ??
          row.orderItem?.nameFr ??
          row.orderItem?.nameAr ??
          'Item';
      items.add(_ReceiptItem(name: name, qty: qty, total: total));
    }

    for (final row in data.basketOrders ?? <BasketOrder>[]) {
      final qty = row.basket?.quantity ?? 1;
      final unitPrice = double.tryParse(row.basket?.price ?? '0') ?? 0;
      final total = (unitPrice * qty).toStringAsFixed(2);
      final name =
          row.basket?.basketNameEn ??
          row.basket?.basketNameFr ??
          row.basket?.basketNameAr ??
          'Basket';
      items.add(_ReceiptItem(name: name, qty: qty, total: total));
    }

    return items;
  }
}

class _ReceiptItem {
  final String name;
  final int qty;
  final String total;

  const _ReceiptItem({
    required this.name,
    required this.qty,
    required this.total,
  });
}
