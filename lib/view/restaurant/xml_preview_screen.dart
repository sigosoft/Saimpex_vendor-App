import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';

/// In-app preview of a downloaded XML (or text) file, with option to open externally.
class XmlPreviewScreen extends StatefulWidget {
  final String filePath;

  const XmlPreviewScreen({super.key, required this.filePath});

  @override
  State<XmlPreviewScreen> createState() => _XmlPreviewScreenState();
}

class _XmlPreviewScreenState extends State<XmlPreviewScreen> {
  String? _content;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final file = File(widget.filePath);
      if (!await file.exists()) {
        setState(() {
          _error = 'File not found';
          _loading = false;
        });
        return;
      }
      final text = await file.readAsString();
      setState(() {
        _content = text;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        ),
        title: Text(
          'Template preview',
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Open with another app',
            onPressed: () => OpenFilex.open(widget.filePath),
            icon: const Icon(Icons.open_in_new, color: Color(0xFFFF5216)),
          ),
        ],
      ),
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF5216)),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _content ?? '',
                style: GoogleFonts.robotoMono(
                  fontSize: 12,
                  height: 1.4,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
    );
  }
}
