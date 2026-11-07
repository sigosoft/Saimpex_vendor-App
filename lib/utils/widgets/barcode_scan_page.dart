import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/fonts.dart';

/// Full-screen camera that returns the first barcode it reads (or null).
/// Used by pharmacy Add Product and the pharmacy and water inventory search.
class BarcodeScanPage extends StatefulWidget {
  const BarcodeScanPage({super.key});

  @override
  State<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage> {
  var _handled = false;

  void _onDetect(BarcodeCapture capture) {
    if (_handled || !mounted) return;
    String? code;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.isNotEmpty) {
        code = value;
        break;
      }
    }
    if (code == null) return;
    _handled = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          S.of(context).scanBarcode,
          style: appFont('Inter', fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    S.of(context).pharmacyInvCameraPermissionBarcode,
                    textAlign: TextAlign.center,
                    style: appFont('Inter', color: Colors.white, fontSize: 15),
                  ),
                ),
              );
            },
          ),
          Center(
            child: Container(
              width: 260,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFFF5216), // brand orange
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: Text(
              S.of(context).pharmacyInvPositionBarcode,
              textAlign: TextAlign.center,
              style: appFont('Inter', color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
