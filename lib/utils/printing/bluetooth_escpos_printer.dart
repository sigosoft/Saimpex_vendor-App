import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothEscPosPrinter {
  static const MethodChannel _channel = MethodChannel(
    'saimpex.vendor/escpos_printer',
  );

  Future<void> printBytes({
    String? printerAddress,
    required List<int> bytes80mm,
    required List<int> bytes58mm,
  }) async {
    if (!Platform.isAndroid) {
      throw Exception('Bluetooth ESC/POS printing is currently Android-only');
    }
    if (bytes80mm.isEmpty || bytes58mm.isEmpty) {
      throw Exception('Nothing to print');
    }
    await _ensureBluetoothPermissions();

    await _channel.invokeMethod('printEscPos', <String, dynamic>{
      'address': printerAddress?.trim(),
      'bytes80mm': bytes80mm,
      'bytes58mm': bytes58mm,
    });
  }

  /// Paired Bluetooth devices, for the printer picker. Android only.
  Future<List<PairedPrinter>> listPairedPrinters() async {
    if (!Platform.isAndroid) return const [];
    await _ensureBluetoothPermissions();
    final raw = await _channel.invokeListMethod<Map>('listPairedPrinters');
    return (raw ?? const [])
        .map(
          (m) => PairedPrinter(
            name: m['name']?.toString() ?? '',
            address: m['address']?.toString() ?? '',
          ),
        )
        .where((p) => p.address.isNotEmpty)
        .toList();
  }

  /// Short ticket to check the chosen printer (same bytes for 58/80 mm).
  Future<void> printTestPage({
    String? printerAddress,
    required String title,
    required String printerLabel,
  }) {
    final bytes = buildTestPageBytes(title: title, printerLabel: printerLabel);
    return printBytes(
      printerAddress: printerAddress,
      bytes80mm: bytes,
      bytes58mm: bytes,
    );
  }

  /// ESC/POS bytes for [printTestPage]. Non-ASCII is replaced, since the
  /// printer runs in its default code page.
  static List<int> buildTestPageBytes({
    required String title,
    required String printerLabel,
  }) {
    List<int> text(String s) =>
        s.codeUnits.map((c) => c < 128 ? c : 0x3F).toList();
    return [
      0x1B, 0x40, // init
      0x1B, 0x61, 0x01, // center
      0x1D, 0x21, 0x11, // double size
      ...text('SAIMPEX'), 0x0A,
      0x1D, 0x21, 0x00, // normal size
      ...text(title), 0x0A,
      ...text(printerLabel), 0x0A,
      ...text('--------------------------------'), 0x0A,
      0x1B, 0x64, 0x05, // feed 5 lines
      0x1D, 0x56, 0x42, 0x00, // partial cut (ignored by printers without a cutter)
    ];
  }

  Future<void> _ensureBluetoothPermissions() async {
    final connect = await Permission.bluetoothConnect.request();
    if (!connect.isGranted) {
      throw Exception('Bluetooth connect permission denied');
    }

    final scan = await Permission.bluetoothScan.request();
    if (!scan.isGranted && !scan.isLimited) {
      // Some devices may not require scan for paired-device connect.
      // Keep this non-fatal only when connect is granted.
      return;
    }
  }
}

class PairedPrinter {
  const PairedPrinter({required this.name, required this.address});

  final String name;
  final String address;
}
