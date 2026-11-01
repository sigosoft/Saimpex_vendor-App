import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/utils/utils.dart';

/// Request a new category for Admin approval (task V8, scope §3): the
/// vendor's requests with their status, and a sheet to send a new one.
/// Pharmacy: `pharmacyCategoryRequests` / `requestPharmacyCategory`; water:
/// `waterCategoryRequests` / `requestWaterCategory`. Built without a Figma
/// screen, in the style of the support screens.
enum CategoryRequestKind { pharmacy, water }

class CategoryRequestsScreen extends StatefulWidget {
  const CategoryRequestsScreen({super.key, required this.kind});

  final CategoryRequestKind kind;

  static void open(CategoryRequestKind kind) => Get.to(() => CategoryRequestsScreen(kind: kind));

  @override
  State<CategoryRequestsScreen> createState() => _CategoryRequestsScreenState();
}

class _CategoryRequestsScreenState extends State<CategoryRequestsScreen> {
  static const Color _pageBg = Color(0xffFDF9F0);
  static const Color _cardBorder = Color(0xffF0ECE4);
  static const Color _text = Color(0xff111827);
  static const Color _muted = Color(0xff6B7280);
  static const Color _orange = Color(0xFFFF5216);

  List<Map<String, dynamic>> _requests = [];
  bool _loading = true;

  String get _listPath => widget.kind == CategoryRequestKind.pharmacy
      ? ApiEndPoints.pharmacyCategoryRequests
      : ApiEndPoints.waterCategoryRequests;

  String get _sendPath => widget.kind == CategoryRequestKind.pharmacy
      ? ApiEndPoints.requestPharmacyCategory
      : ApiEndPoints.requestWaterCategory;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      DioClient().updateToken((await getSavedObject('token'))?.toString() ?? '');
      final res = await DioClient().get(_listPath);
      final data = res.data is Map ? res.data['data'] : null;
      final list = data is Map ? data['requests'] : null;
      _requests = list is List ? list.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList() : [];
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _newRequest() async {
    final sent = await showRequestSheet(
      context,
      title: S.of(context).requestNewCategory,
      nameLabel: S.of(context).categoryName,
      send: (name, reason) async {
        final res = await DioClient().post(_sendPath, body: {'name_en': name, 'reason': reason});
        return res.data is Map && res.data['status'] == true;
      },
    );
    if (sent == true) {
      Fluttertoast.showToast(msg: S.current.requestSentForReview);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rtl = LocalizationService.currentLanguageCode == 'ar';
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _pageBg,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: _orange,
          onPressed: _newRequest,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(s.requestNewCategory, style: appFont('Inter', fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      elevation: 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => Get.back(),
                        child: const SizedBox(width: 36, height: 36, child: Icon(Icons.chevron_left, color: _orange)),
                      ),
                    ),
                    Expanded(
                      child: Text(s.categoryRequests, textAlign: TextAlign.center, style: appFont('Inter', fontSize: 18, fontWeight: FontWeight.w600, color: _text)),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: _orange))
                    : RefreshIndicator(
                        color: _orange,
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                          children: [
                            Text(s.categoryRequestsHelp, style: appFont('Inter', fontSize: 12, color: _muted)),
                            const SizedBox(height: 12),
                            if (_requests.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 60),
                                child: Text(s.noCategoryRequests, textAlign: TextAlign.center, style: appFont('Inter', fontSize: 14, color: _muted)),
                              ),
                            for (final r in _requests) ...[
                              _card(s, r),
                              const SizedBox(height: 10),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(S s, Map<String, dynamic> r) {
    final status = int.tryParse(r['status']?.toString() ?? '') ?? 1;
    final (String label, Color fg, Color bg) = switch (status) {
      2 => (s.requestApproved, const Color(0xff16A34A), const Color(0xffE8F7EE)),
      3 => (s.requestRejected, const Color(0xffE11D48), const Color(0xffFFE4E6)),
      _ => (s.requestPending, const Color(0xffEA7A1A), const Color(0xffFFF1E6)),
    };
    final reason = (r['reason'] ?? '').toString().trim();
    // Admin's note; the backend's default texts are not shown.
    final note = (r['details'] ?? '').toString().trim();
    final showNote = status != 1 && note.isNotEmpty && note != 'Rejected' && note != 'Added to the category list.';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text((r['name_en'] ?? '').toString(), style: appFont('Inter', fontSize: 15, fontWeight: FontWeight.w600, color: _text))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
                child: Text(label, style: appFont('Inter', fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
              ),
            ],
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(reason, style: appFont('Inter', fontSize: 12, color: _muted)),
          ],
          if (showNote) ...[
            const SizedBox(height: 6),
            Text(s.adminNote(note), style: appFont('Inter', fontSize: 12, color: _text)),
          ],
        ],
      ),
    );
  }
}

/// Name + reason sheet shared by category and service-type requests.
/// [send] returns true when the server accepted the request. Pops true then.
Future<bool?> showRequestSheet(
  BuildContext context, {
  required String title,
  required String nameLabel,
  required Future<bool> Function(String name, String reason) send,
}) {
  final nameCtrl = TextEditingController();
  final reasonCtrl = TextEditingController();
  var sending = false;
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) {
        final s = S.of(ctx);
        final ready = nameCtrl.text.trim().isNotEmpty && reasonCtrl.text.trim().isNotEmpty;
        InputDecoration deco(String hint) => InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            );
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: appFont('Inter', fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                maxLength: 120,
                onChanged: (_) => setSheet(() {}),
                decoration: deco(nameLabel).copyWith(counterText: ''),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonCtrl,
                maxLength: 1000,
                minLines: 2,
                maxLines: 4,
                onChanged: (_) => setSheet(() {}),
                decoration: deco(s.requestReasonHint).copyWith(counterText: ''),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: !ready || sending
                      ? null
                      : () async {
                          setSheet(() => sending = true);
                          var ok = false;
                          try {
                            ok = await send(nameCtrl.text.trim(), reasonCtrl.text.trim());
                          } catch (e) {
                            Fluttertoast.showToast(msg: e.toString());
                          }
                          if (!ctx.mounted) return;
                          if (ok) {
                            Navigator.of(ctx).pop(true);
                          } else {
                            setSheet(() => sending = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5216),
                    disabledBackgroundColor: const Color(0xFFFF5216).withValues(alpha: 0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: sending
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(s.sendForApproval, style: appFont('Inter', fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
