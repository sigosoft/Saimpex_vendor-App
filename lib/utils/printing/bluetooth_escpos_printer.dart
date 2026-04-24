import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothEscPosPrinter {
  static const MethodChannel _channel = MethodChannel(
    'saimpex.vendor/escpos_printer',
  );

  Future<void> printBytes({
    String? printerAddress,
    required List<int> bytes,
  }) async {
    if (!Platform.isAndroid) {
      throw Exception('Bluetooth ESC/POS printing is currently Android-only');
    }
    if (bytes.isEmpty) {
      throw Exception('Nothing to print');
    }
    await _ensureBluetoothPermissions();

    await _channel.invokeMethod('printEscPos', <String, dynamic>{
      'address': printerAddress?.trim(),
      'bytes': bytes,
    });
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

