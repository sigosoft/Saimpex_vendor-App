import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/fonts.dart';

/// Hide / unhide a product (API doc §6.21, SPX-ADM-02 item 62, task V10).
/// One bar under each product card on the grocery / local store, pharmacy
/// and water lists. Built without a Figma screen, in the cards' style.

/// Hidden state from a list row (`is_hidden`, `hidden_until`, `hidden_forever`).
class ProductVisibilityState {
  const ProductVisibilityState({this.isHidden = false, this.hiddenUntil, this.hiddenForever = false});

  final bool isHidden;
  final DateTime? hiddenUntil;
  final bool hiddenForever;

  static bool _truthy(dynamic v) => v == true || v?.toString() == '1' || v?.toString() == 'true';

  factory ProductVisibilityState.fromJson(Map<String, dynamic>? json) => ProductVisibilityState(
        isHidden: _truthy(json?['is_hidden']),
        hiddenUntil: DateTime.tryParse(json?['hidden_until']?.toString() ?? '')?.toLocal(),
        hiddenForever: _truthy(json?['hidden_forever']),
      );
}

/// `vertical` for [ProductVisibilityBar]: grocery vendors (type 2) use
/// `grocery`, local stores (11) `local_store`.
String groceryVerticalFor(String? vendorType) => vendorType == '11' ? 'local_store' : 'grocery';

/// Sends the choice and returns the new state (null when it failed).
Future<ProductVisibilityState?> updateProductVisibility({
  required String vertical,
  required int menuId,
  required String hideFor,
}) async {
  try {
    final res = await DioClient().post(
      ApiEndPoints.updateProductVisibility,
      body: {'vertical': vertical, 'menu_id': menuId, 'hide_for': hideFor},
    );
    final data = res.data is Map ? res.data['data'] : null;
    if (res.data is Map && res.data['status'] == true && data is Map) {
      return ProductVisibilityState.fromJson(Map<String, dynamic>.from(data));
    }
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
  }
  return null;
}

class ProductVisibilityBar extends StatefulWidget {
  const ProductVisibilityBar({
    super.key,
    required this.vertical,
    required this.menuId,
    required this.initial,
  });

  final String vertical;
  final int menuId;
  final ProductVisibilityState initial;

  @override
  State<ProductVisibilityBar> createState() => _ProductVisibilityBarState();
}

class _ProductVisibilityBarState extends State<ProductVisibilityBar> {
  static const Color _orange = Color(0xFFFF5216);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _hiddenBg = Color(0xFFF3F4F6);

  late ProductVisibilityState _state = widget.initial;
  bool _busy = false;

  @override
  void didUpdateWidget(covariant ProductVisibilityBar old) {
    super.didUpdateWidget(old);
    if (old.menuId != widget.menuId || old.initial.isHidden != widget.initial.isHidden) {
      _state = widget.initial;
    }
  }

  String _label(S s) {
    if (!_state.isHidden) return s.productVisible;
    final until = _state.hiddenUntil;
    if (_state.hiddenForever || until == null) return s.productHiddenForever;
    final now = DateTime.now();
    final sameDay = until.year == now.year && until.month == now.month && until.day == now.day;
    String two(int v) => v.toString().padLeft(2, '0');
    final time = '${two(until.hour)}:${two(until.minute)}';
    return s.productHiddenUntil(sameDay ? time : '${two(until.day)}/${two(until.month)} $time');
  }

  Future<void> _apply(String hideFor) async {
    setState(() => _busy = true);
    final next = await updateProductVisibility(vertical: widget.vertical, menuId: widget.menuId, hideFor: hideFor);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (next != null) _state = next;
    });
  }

  Future<void> _chooseHide() async {
    final s = S.of(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(s.hideProductTitle, style: appFont('Inter', fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(s.hideProductHelp, style: appFont('Inter', fontSize: 12, color: _muted)),
            ),
            for (final (value, label) in [
              ('1h', s.hideFor1Hour),
              ('4h', s.hideFor4Hours),
              ('today', s.hideUntilEndOfToday),
              ('forever', s.hideUntilShown),
            ])
              ListTile(
                title: Text(label, style: appFont('Inter', fontSize: 14)),
                onTap: () => Navigator.of(ctx).pop(value),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice != null) await _apply(choice);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final hidden = _state.isHidden;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hidden ? _hiddenBg : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16, color: hidden ? _muted : _orange),
          const SizedBox(width: 6),
          Expanded(child: Text(_label(s), style: appFont('Inter', fontSize: 12, fontWeight: FontWeight.w500, color: _muted))),
          if (_busy)
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: _orange))
          else
            TextButton(
              onPressed: hidden ? () => _apply('show') : _chooseHide,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(0, 32)),
              child: Text(
                hidden ? s.showProductNow : s.hideProduct,
                style: appFont('Inter', fontSize: 13, fontWeight: FontWeight.w600, color: _orange),
              ),
            ),
        ],
      ),
    );
  }
}
