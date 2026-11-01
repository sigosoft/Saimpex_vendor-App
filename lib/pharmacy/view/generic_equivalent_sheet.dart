import 'dart:async';

import 'package:flutter/material.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';

/// Product name in the app language (`name_en` / `name_fr` / `name_ar`).
String genericProductName(Map<String, dynamic> p) {
  final lang = LocalizationService.currentLanguageCode;
  final local = (p['name_$lang'] ?? '').toString();
  return local.isNotEmpty ? local : (p['name_en'] ?? '').toString();
}

/// Picks the generic equivalent of a pharmacy product (API doc §6.55,
/// backend #130). Searches every pharmacy with `pharmacyGenericSearch`
/// (2+ characters). Pops the chosen product map, or `{}` for "Remove link".
/// Built without a Figma screen, in the product form's style.
class GenericEquivalentSheet extends StatefulWidget {
  const GenericEquivalentSheet({super.key, this.excludeMenuId, this.hasLink = false});

  final int? excludeMenuId;
  final bool hasLink;

  static Future<Map<String, dynamic>?> show(BuildContext context, {int? excludeMenuId, bool hasLink = false}) =>
      showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => GenericEquivalentSheet(excludeMenuId: excludeMenuId, hasLink: hasLink),
      );

  @override
  State<GenericEquivalentSheet> createState() => _GenericEquivalentSheetState();
}

class _GenericEquivalentSheetState extends State<GenericEquivalentSheet> {
  static const Color _ink = Color(0xFF111827);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _orange = Color(0xFFFF5216);

  final _query = TextEditingController();
  Timer? _debounce;
  bool _loading = false;
  List<Map<String, dynamic>> _results = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(text.trim()));
  }

  Future<void> _search(String keyword) async {
    if (keyword.length < 2) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await DioClient().get(
        ApiEndPoints.pharmacyGenericSearch,
        query: {
          'keyword': keyword,
          if (widget.excludeMenuId != null) 'exclude_menu_id': widget.excludeMenuId,
        },
      );
      final data = res.data is Map ? res.data['data'] : null;
      final list = data is Map ? data['products'] : null;
      if (!mounted || _query.text.trim() != keyword) return;
      setState(() {
        _results = list is List ? list.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList() : [];
      });
    } catch (e) {
      debugPrint('pharmacyGenericSearch: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rtl = LocalizationService.currentLanguageCode == 'ar';
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(s.pharmacyGenericEquivalent, style: appFont('Inter', fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
                  const SizedBox(height: 4),
                  Text(s.pharmacyGenericEquivalentHelp, style: appFont('Inter', fontSize: 12, color: _muted)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _query,
                    autofocus: true,
                    onChanged: _onChanged,
                    style: appFont('Inter', fontSize: 14, color: _ink),
                    decoration: InputDecoration(
                      hintText: s.pharmacyGenericSearchHint,
                      hintStyle: appFont('Inter', fontSize: 14, color: _muted),
                      prefixIcon: const Icon(Icons.search, color: _muted),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  if (widget.hasLink)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(<String, dynamic>{}),
                        icon: const Icon(Icons.link_off, size: 18, color: _orange),
                        label: Text(s.pharmacyGenericRemoveLink, style: appFont('Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _orange)),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator(color: _orange))
                        : _results.isEmpty
                            ? Center(
                                child: Text(
                                  _query.text.trim().length < 2 ? s.pharmacyGenericTypeTwo : s.pharmacyGenericNoMatch,
                                  textAlign: TextAlign.center,
                                  style: appFont('Inter', fontSize: 13, color: _muted),
                                ),
                              )
                            : ListView.separated(
                                itemCount: _results.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (_, i) {
                                  final p = _results[i];
                                  final generic = (p['generic_name'] ?? '').toString();
                                  final pharmacy = (p['pharmacy_name'] ?? '').toString();
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(genericProductName(p), style: appFont('Inter', fontSize: 14, fontWeight: FontWeight.w600, color: _ink)),
                                    subtitle: Text(
                                      [if (generic.isNotEmpty) generic, if (pharmacy.isNotEmpty) pharmacy].join(' • '),
                                      style: appFont('Inter', fontSize: 12, color: _muted),
                                    ),
                                    onTap: () => Navigator.of(context).pop(p),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
