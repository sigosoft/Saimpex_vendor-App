import 'dart:convert';

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

  EscPosReceiptBuildResult buildReceipt(
    Data data, {
    int feedLines = 6,
    bool withCut = true,
  }) {
    final previewLines = <String>[];

    List<int> buildForWidth(bool is58mm) {
      final bytes = <int>[];
      final lineWidth = is58mm ? _lineWidth58mm : _lineWidth80mm;

      void addBytes(List<int> value) => bytes.addAll(value);

      void addText(String text) {
        addBytes(latin1.encode('$text\n'));
        if (!is58mm) previewLines.add(text); // only add preview once
      }

    void center() => addBytes(const [0x1B, 0x61, 0x01]); // ESC a 1
    void left() => addBytes(const [0x1B, 0x61, 0x00]); // ESC a 0
    void bold(bool on) => addBytes([0x1B, 0x45, on ? 0x01 : 0x00]); // ESC E n

    addBytes(const [0x1B, 0x40]); // ESC @ init printer

    center();
    bold(true);
    addText(is58mm ? 'RECEIPT' : 'ORDER RECEIPT');
    bold(false);
    addText('-' * lineWidth);
    left();

    addText(_twoCol('Order', data.orderCode?.trim().isNotEmpty == true
        ? data.orderCode!.trim()
        : '#${data.id ?? '-'}', lineWidth));
    addText(_twoCol('Date', _safeDate(data.placedAt), lineWidth));
    addText(_twoCol('Customer', _clean(data.userName), lineWidth));
    addText(_twoCol('Phone', '${_clean(data.countryCode)} ${_clean(data.userMobile)}'.trim(), lineWidth));
    addText(_twoCol('Payment', _clean(data.paymentType), lineWidth));
    addText(_divider(lineWidth));

    addText(_itemHeader(lineWidth, is58mm));
    addText(_divider(lineWidth));

    final items = _extractItems(data);
    if (items.isEmpty) {
      addText(_fit('No items', lineWidth));
    } else {
      for (final item in items) {
        addText(_itemRow(item, lineWidth, is58mm));
      }
    }

    addText(_divider(lineWidth));
    addText(_amountRow('Subtotal', '${_num(data.subtotal)} MRU', lineWidth));
    addText(_amountRow('Tax', '${_num(data.tax)} MRU', lineWidth));
    addText(_amountRow('Delivery', '${_num(data.deliveryFee)} MRU', lineWidth));
    bold(true);
    addText(_amountRow('TOTAL', '${_num(data.total)} MRU', lineWidth));
    bold(false);
    addText(_divider(lineWidth));
    addText('Thank you!');

      // Fix #1: always feed paper past cutter blade.
      final safeFeed = feedLines < 4 ? 4 : feedLines;
      addBytes([0x1B, 0x64, safeFeed]); // ESC d n : print and feed n lines

      // Fix #2: send explicit full cut command (only for 80mm as pocket printers usually lack cutters).
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

  String _safeDate(DateTime? value) {
    if (value == null) return '-';
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final min = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$min';
  }

  String _clean(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? '-' : v;
  }

  String _num(String? value) {
    final n = double.tryParse((value ?? '').trim());
    return (n ?? 0).toStringAsFixed(2);
  }

  String _divider(int width) => '-' * width;

  String _twoCol(String left, String right, int width) {
    final leftWidth = (width * 0.35).floor();
    final l = _fit(left, leftWidth);
    final r = _fitRight(right, width - leftWidth);
    return '$l$r';
  }

  String _amountRow(String label, String amount, int width) {
    final leftWidth = (width * 0.5).floor();
    final l = _fit(label, leftWidth);
    final r = _fitRight(amount, width - leftWidth);
    return '$l$r';
  }

  String _itemHeader(int width, bool is58mm) {
    if (is58mm) {
      final name = _fit('ITEM', 12);
      final qty = _fitRight('QTY', 4);
      final unit = _fitRight('UNIT', 7);
      final total = _fitRight('TOTAL', 9);
      return '$name$qty$unit$total';
    } else {
      final name = _fit('ITEM', 24);
      final qty = _fitRight('QTY', 6);
      final unit = _fitRight('UNIT', 8);
      final total = _fitRight('TOTAL', 10);
      return '$name$qty$unit$total';
    }
  }

  String _itemRow(_ReceiptItem item, int width, bool is58mm) {
    if (is58mm) {
      final name = _fit(item.name, 12);
      final qty = _fitRight(item.qty.toString(), 4);
      final unit = _fitRight(item.unit, 7);
      final total = _fitRight(item.total, 9);
      return '$name$qty$unit$total';
    } else {
      final name = _fit(item.name, 24);
      final qty = _fitRight(item.qty.toString(), 6);
      final unit = _fitRight(item.unit, 8);
      final total = _fitRight(item.total, 10);
      return '$name$qty$unit$total';
    }
  }

  String _fit(String value, int width) {
    final sanitized = value.replaceAll('\n', ' ').trim();
    if (sanitized.length >= width) return '${sanitized.substring(0, width - 1)}…';
    return sanitized.padRight(width);
  }

  String _fitRight(String value, int width) {
    final sanitized = value.replaceAll('\n', ' ').trim();
    if (sanitized.length >= width) return sanitized.substring(sanitized.length - width);
    return sanitized.padLeft(width);
  }

  List<_ReceiptItem> _extractItems(Data data) {
    final items = <_ReceiptItem>[];

    for (final row in data.orderItems ?? <OrderItem>[]) {
      final qty = row.quantity ?? 0;
      final unit = _num(row.unitPrice);
      final total = _num(row.price);
      final name = row.orderItem?.nameEn ??
          row.orderItem?.nameFr ??
          row.orderItem?.nameAr ??
          'Item';
      items.add(
        _ReceiptItem(
          name: name,
          qty: qty,
          unit: unit,
          total: total,
        ),
      );
    }

    for (final row in data.basketOrders ?? <BasketOrder>[]) {
      final qty = row.basket?.quantity ?? 1;
      final unit = _num(row.basket?.price);
      final total = (double.tryParse(unit) ?? 0) * qty;
      final name = row.basket?.basketNameEn ??
          row.basket?.basketNameFr ??
          row.basket?.basketNameAr ??
          'Basket';
      items.add(
        _ReceiptItem(
          name: name,
          qty: qty,
          unit: unit,
          total: total.toStringAsFixed(2),
        ),
      );
    }

    return items;
  }
}

class _ReceiptItem {
  final String name;
  final int qty;
  final String unit;
  final String total;

  const _ReceiptItem({
    required this.name,
    required this.qty,
    required this.unit,
    required this.total,
  });
}

