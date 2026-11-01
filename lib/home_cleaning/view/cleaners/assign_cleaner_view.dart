import 'dart:async';

import 'package:flutter/material.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaner.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaning_booking.dart';
import 'package:saimpex_vendor/home_cleaning/view/cleaners/cleaner_widgets.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';

/// Assign Cleaner (task V16), Figma 10868:11841: the booking, a search, and
/// the cleaners with their availability **for this booking's time**
/// (`serviceCleaners?order_id=`). Busy and deactivated cleaners can't be
/// picked (the API refuses them). Pops true once the cleaner is assigned.
class AssignCleanerView extends StatefulWidget {
  const AssignCleanerView({super.key, required this.booking});

  final CleaningBooking booking;

  static Future<bool?> open(BuildContext context, CleaningBooking booking) =>
      Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => AssignCleanerView(booking: booking)));

  @override
  State<AssignCleanerView> createState() => _AssignCleanerViewState();
}

class _AssignCleanerViewState extends State<AssignCleanerView> {
  final _search = TextEditingController();
  Timer? _debounce;
  List<Cleaner> _cleaners = [];
  bool _loading = true;
  bool _saving = false;
  int? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.booking.cleaner?.id;
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final page = await CleanersApi.list(keyword: _search.text, orderId: widget.booking.id);
      if (mounted) setState(() => _cleaners = page.cleaners.where((c) => c.active).toList());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _assign() async {
    final id = _selected;
    if (id == null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    final res = await CleanersApi.assign(orderId: widget.booking.id, cleanerId: id);
    if (!mounted) return;
    setState(() => _saving = false);
    if ((res.message ?? '').isNotEmpty) messenger.showSnackBar(SnackBar(content: Text(res.message!)));
    if (res.ok) {
      Navigator.of(context).pop(true);
    } else {
      _load(); // availability may have changed
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final b = widget.booking;
    final rtl = LocalizationService.currentLanguageCode == 'ar';
    final selected = _cleaners.where((c) => c.id == _selected).firstOrNull;
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: cleanerPageBg,
        body: SafeArea(
          child: Column(children: [
            CleanerHeader(title: s.assignCleaner),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              padding: const EdgeInsets.all(14),
              width: double.infinity,
              decoration: BoxDecoration(color: const Color(0xFFFFF1E6), borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  [s.bookingHash(b.orderCode ?? '${b.id}'), if ((b.slotWindow ?? '').isNotEmpty) b.slotWindow!].join(' • '),
                  style: cleanerText(14, FontWeight.w700, cleanerInk),
                ),
                if ((b.address ?? '').isNotEmpty || (b.serviceName ?? '').isNotEmpty)
                  Text([b.serviceName ?? '', b.address ?? ''].where((p) => p.isNotEmpty).join(' • '),
                      style: cleanerText(12, FontWeight.w400, cleanerMuted)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _search,
                onChanged: (_) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 350), _load);
                },
                decoration: InputDecoration(
                  hintText: s.searchCleaner,
                  prefixIcon: const Icon(Icons.search, color: cleanerMuted),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: cleanerOrange))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_cleaners.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(s.noCleanersYet, textAlign: TextAlign.center, style: cleanerText(14, FontWeight.w400, cleanerMuted)),
                          ),
                        for (final c in _cleaners) ...[
                          _tile(c),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: selected == null || _saving ? null : _assign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cleanerOrange,
                    disabledBackgroundColor: cleanerOrange.withValues(alpha: 0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(selected == null ? s.assignCleaner : s.assignCleanerNamed(selected.name),
                          style: cleanerText(16, FontWeight.w700, Colors.white)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _tile(Cleaner c) {
    // The cleaner already on this booking counts as available for it.
    final canPick = c.isAvailable || c.id == widget.booking.cleaner?.id;
    final isSelected = _selected == c.id;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: canPick ? () => setState(() => _selected = c.id) : null,
      child: Opacity(
        opacity: canPick ? 1 : 0.6,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? cleanerOrange : cleanerBorder, width: isSelected ? 1.5 : 1),
          ),
          child: Row(children: [
            CleanerAvatar(cleaner: c),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.name, style: cleanerText(15, FontWeight.w600, cleanerInk)),
                Text(cleanerStats(context, c), style: cleanerText(12, FontWeight.w400, cleanerMuted)),
                const SizedBox(height: 4),
                CleanerStatusPill(cleaner: c),
              ]),
            ),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? cleanerOrange : const Color(0xFFD1D5DB)),
          ]),
        ),
      ),
    );
  }
}
