import 'package:flutter/material.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaner.dart';
import 'package:saimpex_vendor/home_cleaning/view/cleaners/cleaner_form_view.dart';
import 'package:saimpex_vendor/home_cleaning/view/cleaners/cleaner_widgets.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';

/// My Cleaners (task V16), Figma 10868:11391: All / Available / Busy /
/// Inactive filters with counts, each cleaner with rating and status,
/// Edit and Deactivate / Activate, and Add Cleaner. API `serviceCleaners`,
/// `updateServiceCleaner` (status 2 deactivates; 422 while busy).
class MyCleanersView extends StatefulWidget {
  const MyCleanersView({super.key, this.loader});

  /// Data source; the API by default (tests pass a fixed page).
  final Future<CleanersPage> Function()? loader;

  @override
  State<MyCleanersView> createState() => _MyCleanersViewState();
}

class _MyCleanersViewState extends State<MyCleanersView> {
  CleanersPage? _page;
  bool _loading = true;
  String? _error;
  String _filter = 'all';
  final Set<int> _busy = {};

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
    try {
      final page = await (widget.loader ?? () => CleanersApi.list())();
      if (mounted) setState(() => _page = page);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Cleaner> get _visible {
    final all = _page?.cleaners ?? const <Cleaner>[];
    return switch (_filter) {
      'available' => all.where((c) => c.active && c.isAvailable).toList(),
      'busy' => all.where((c) => c.active && c.isBusy).toList(),
      'inactive' => all.where((c) => !c.active).toList(),
      _ => all,
    };
  }

  int _count(String key) {
    final counts = _page?.counts ?? const {};
    final all = _page?.cleaners ?? const <Cleaner>[];
    return counts[key == 'all' ? 'total' : key] ??
        switch (key) {
          'available' => all.where((c) => c.active && c.isAvailable).length,
          'busy' => all.where((c) => c.active && c.isBusy).length,
          'inactive' => all.where((c) => !c.active).length,
          _ => all.length,
        };
  }

  Future<void> _open([Cleaner? cleaner]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CleanerFormView(initial: cleaner)),
    );
    if (saved == true) _load();
  }

  Future<void> _toggleActive(Cleaner c) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy.add(c.id));
    try {
      final msg = await CleanersApi.save(id: c.id, active: !c.active);
      if (msg != null) messenger.showSnackBar(SnackBar(content: Text(msg)));
      await _load();
    } catch (e) {
      // e.g. 422 "has an open booking" while busy.
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy.remove(c.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rtl = LocalizationService.currentLanguageCode == 'ar';
    final filters = [
      ('all', s.cleanerFilterAll),
      ('available', s.cleanerAvailable),
      ('busy', s.cleanerBusy),
      ('inactive', s.cleanerInactive),
    ];
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: cleanerPageBg,
        body: SafeArea(
          child: Column(children: [
            CleanerHeader(title: s.myCleaners),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final (key, label) in filters)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ChoiceChip(
                        label: Text('$label ${_count(key)}',
                            style: cleanerText(13, FontWeight.w600, _filter == key ? cleanerOrange : cleanerMuted)),
                        selected: _filter == key,
                        showCheckmark: false,
                        selectedColor: Colors.transparent,
                        backgroundColor: const Color(0xFFF3F4F6),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onSelected: (_) => setState(() => _filter = key),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _loading && _page == null
                  ? const Center(child: CircularProgressIndicator(color: cleanerOrange))
                  : RefreshIndicator(
                      color: cleanerOrange,
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (_error != null && _page == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(_error!, textAlign: TextAlign.center, style: cleanerText(14, FontWeight.w400, cleanerMuted)),
                            )
                          else if (_visible.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(s.noCleanersYet, textAlign: TextAlign.center, style: cleanerText(14, FontWeight.w400, cleanerMuted)),
                            ),
                          for (final c in _visible) ...[
                            _card(s, c),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _open(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cleanerOrange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('+ ${s.addCleaner}', style: cleanerText(16, FontWeight.w700, Colors.white)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _card(S s, Cleaner c) {
    final busy = _busy.contains(c.id);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cleanerBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CleanerAvatar(cleaner: c),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.name, style: cleanerText(15, FontWeight.w600, cleanerInk)),
              Text(cleanerStats(context, c), style: cleanerText(12, FontWeight.w400, cleanerMuted)),
              if ((c.phone ?? '').isNotEmpty)
                Text(c.phone!, textDirection: TextDirection.ltr, style: cleanerText(12, FontWeight.w400, cleanerMuted)),
            ]),
          ),
          CleanerStatusPill(cleaner: c),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          OutlinedButton(
            onPressed: () => _open(c),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: cleanerOrange),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(s.edit, style: cleanerText(13, FontWeight.w600, cleanerOrange)),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: busy ? null : () => _toggleActive(c),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: busy
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: cleanerOrange))
                : Text(c.active ? s.cleanerDeactivate : s.cleanerActivate, style: cleanerText(13, FontWeight.w600, cleanerMuted)),
          ),
        ]),
      ]),
    );
  }
}
