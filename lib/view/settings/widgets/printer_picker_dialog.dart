import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/generated/l10n.dart';

import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/printing/bluetooth_escpos_printer.dart';

/// Saved printer; empty = automatic (USB first, then the first paired
/// Bluetooth printer). Read by `OrderPrintService`.
const String kPrinterAddressPref = 'printerAddress';

/// Settings → Printer: choose a paired Bluetooth printer and print a test page (V7).
/// Built without a Figma screen.
Future<void> showPrinterPicker(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => const _PrinterPickerDialog(),
  );
}

class _PrinterPickerDialog extends StatefulWidget {
  const _PrinterPickerDialog();

  @override
  State<_PrinterPickerDialog> createState() => _PrinterPickerDialogState();
}

class _PrinterPickerDialogState extends State<_PrinterPickerDialog> {
  final _printer = BluetoothEscPosPrinter();
  List<PairedPrinter> _devices = const [];
  String _selected = '';
  bool _loading = true;
  bool _printing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final saved = (await getSavedObject(kPrinterAddressPref))?.toString();
    var devices = const <PairedPrinter>[];
    String? error;
    try {
      devices = await _printer.listPairedPrinters();
    } catch (e) {
      debugPrint('listPairedPrinters: $e');
      if (mounted) error = S.of(context).bluetoothUnavailable;
    }
    if (!mounted) return;
    setState(() {
      _devices = devices;
      _selected = (saved == null || saved == 'null') ? '' : saved.trim();
      _error = error;
      _loading = false;
    });
  }

  Future<void> _select(String address) async {
    setState(() => _selected = address);
    await savename(kPrinterAddressPref, address);
  }

  Future<void> _testPrint() async {
    setState(() => _printing = true);
    final label = _selected.isEmpty
        ? S.of(context).automaticPrinter
        : _devices
                  .where((d) => d.address == _selected)
                  .map((d) => d.name)
                  .firstOrNull ??
              _selected;
    try {
      await _printer.printTestPage(
        printerAddress: _selected.isEmpty ? null : _selected,
        title: S.of(context).printerTest,
        printerLabel: label,
      );
      if (mounted) showToast(context, S.of(context).testPageSent);
    } catch (e) {
      debugPrint('Test print failed: $e');
      if (mounted) showToast(context, S.of(context).printFailed);
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final android = Platform.isAndroid;
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        S.of(context).printer,
        style: GoogleFonts.rubik(fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 420,
        child: !android
            ? Text(S.of(context).printingAndroidOnly)
            : _loading
            ? const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: RadioGroup<String>(
                  groupValue: _selected,
                  onChanged: (v) => _select(v ?? ''),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RadioListTile<String>(
                        value: '',
                        activeColor: colorPrimary,
                        title: Text(S.of(context).automaticPrinter),
                        subtitle: Text(S.of(context).automaticPrinterHint),
                      ),
                      for (final d in _devices)
                        RadioListTile<String>(
                          value: d.address,
                          activeColor: colorPrimary,
                          title: Text(d.name.isEmpty ? d.address : d.name),
                          subtitle: Text(
                            d.address,
                            textDirection: TextDirection.ltr,
                          ),
                        ),
                      if (_error != null || _devices.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Text(
                            _error ?? S.of(context).noPairedPrinters,
                            style: GoogleFonts.rubik(
                              fontSize: 13,
                              color: mutedTextColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
      actions: [
        if (android)
          TextButton(
            onPressed: _loading || _printing ? null : _testPrint,
            child: _printing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(S.of(context).printTestPage),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.of(context).done),
        ),
      ],
    );
  }
}
