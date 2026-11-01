import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaner.dart';
import 'package:saimpex_vendor/home_cleaning/view/cleaners/cleaner_widgets.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';

/// Add / edit a cleaner (task V16), Figma 10868:11643: photo, full name,
/// phone (+222), Active. API `addServiceCleaner` / `updateServiceCleaner`.
class CleanerFormView extends StatefulWidget {
  const CleanerFormView({super.key, this.initial});

  final Cleaner? initial;

  @override
  State<CleanerFormView> createState() => _CleanerFormViewState();
}

class _CleanerFormViewState extends State<CleanerFormView> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _phone = TextEditingController(text: _localPhone(widget.initial?.phone));
  late bool _active = widget.initial?.active ?? true;
  File? _photo;
  bool _saving = false;

  /// The form shows +222 as a prefix; strip it from a stored number.
  static String _localPhone(String? phone) {
    final p = (phone ?? '').replaceAll(' ', '');
    return p.startsWith('+222') ? p.substring(4) : p;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _ready => _name.text.trim().isNotEmpty && _phone.text.replaceAll(' ', '').length >= 8;

  Future<void> _pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    if (x != null) setState(() => _photo = File(x.path));
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final initial = widget.initial;
      final msg = await CleanersApi.save(
        id: initial?.id,
        name: _name.text.trim(),
        phone: '+222${_phone.text.replaceAll(' ', '')}',
        active: initial == null ? _active : (initial.active != _active ? _active : null),
        photo: _photo,
      );
      if (msg != null) messenger.showSnackBar(SnackBar(content: Text(msg)));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _deco(String hint, {String? prefix}) => InputDecoration(
        hintText: hint,
        prefixText: prefix,
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: cleanerBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: cleanerOrange)),
      );

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rtl = LocalizationService.currentLanguageCode == 'ar';
    final photoUrl = widget.initial?.photoUrl;
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: cleanerPageBg,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              CleanerHeader(title: widget.initial == null ? s.addCleaner : s.editCleaner),
              Center(
                child: GestureDetector(
                  onTap: _pick,
                  child: Column(children: [
                    ClipOval(
                      child: Container(
                        width: 88,
                        height: 88,
                        color: const Color(0xFFEFF1F4),
                        child: _photo != null
                            ? Image.file(_photo!, fit: BoxFit.cover)
                            : photoUrl != null
                                ? Image.network(photoUrl, fit: BoxFit.cover)
                                : const Icon(Icons.photo_camera_outlined, size: 32, color: cleanerMuted),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(s.addPhoto, style: cleanerText(13, FontWeight.w600, cleanerOrange)),
                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(s.fullName, style: cleanerText(13, FontWeight.w600, cleanerInk)),
                  const SizedBox(height: 6),
                  TextField(controller: _name, onChanged: (_) => setState(() {}), decoration: _deco(s.cleanerNameHint)),
                  const SizedBox(height: 14),
                  Text(s.phoneNumber, style: cleanerText(13, FontWeight.w600, cleanerInk)),
                  const SizedBox(height: 6),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setState(() {}),
                      decoration: _deco('22 11 11 11', prefix: '+222  '),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cleanerBorder),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(s.cleanerActive, style: cleanerText(14, FontWeight.w600, cleanerInk)),
                          Text(s.cleanerActiveHelp, style: cleanerText(12, FontWeight.w400, cleanerMuted)),
                        ]),
                      ),
                      Switch(
                        value: _active,
                        activeThumbColor: Colors.white,
                        activeTrackColor: cleanerOrange,
                        onChanged: (v) => setState(() => _active = v),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: !_ready || _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cleanerOrange,
                        disabledBackgroundColor: cleanerOrange.withValues(alpha: 0.4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(s.saveCleaner, style: cleanerText(16, FontWeight.w700, Colors.white)),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
