import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/water/core/water_api.dart';

/// Quick ("easy") edit of a restaurant catalog item (scope §6 "easy and
/// advanced editing", task V9): name, price (or each variant's price),
/// availability and photo on one sheet. "Advanced edit" opens the full Edit
/// Product screen (variants, option groups, extras, images).
///
/// `updateRestaurantCatalogItem` replaces the whole item: option groups and
/// tags left out are removed. So the sheet loads the item
/// (`restaurantCatalogItemDetail`) and sends every field back unchanged
/// except the ones edited here; extras are not sent, which keeps them as they
/// are. No Figma screen; built in the Edit Product style.

/// Calls for the sheet. Injectable so it can be tested.
class QuickEditApi {
  const QuickEditApi();

  Future<Map<String, dynamic>> load(String itemId) async {
    await WaterApi.prepare();
    final res = await DioClient().get(ApiEndPoints.restaurantCatalogItemDetailAlt, query: {'item_id': itemId});
    final body = res.data;
    if (!WaterApi.isOk(body) || body['data'] is! Map) {
      throw WaterApi.message(body) ?? S.current.somethingWentWrong;
    }
    return Map<String, dynamic>.from(body['data']);
  }

  /// Returns the server message.
  Future<String?> save(Map<String, String> fields, {String? imagePath}) async {
    await WaterApi.prepare();
    final form = dio.FormData.fromMap(fields);
    if (imagePath != null) {
      form.files.add(MapEntry('images[]', await dio.MultipartFile.fromFile(imagePath, filename: imagePath.split(RegExp(r'[/\\]')).last)));
    }
    final res = await DioClient().post(ApiEndPoints.updateRestaurantCatalogItem, body: form);
    final body = res.data;
    if (!WaterApi.isOk(body)) throw WaterApi.message(body) ?? S.current.failedToUpdateItem;
    return WaterApi.message(body);
  }
}

/// The update body: the loaded [detail] with the quick edits applied.
/// [variantPrices] is keyed by variant id. [replaceImage] removes the first
/// gallery image (the one shown), as the full edit screen does.
Map<String, String> buildQuickEditBody(
  Map<String, dynamic> detail, {
  required String name,
  String? price,
  String? discountPrice,
  Map<int, String> variantPrices = const {},
  required bool available,
  bool replaceImage = false,
}) {
  String text(dynamic v) => v == null || '$v' == 'null' ? '' : '$v';
  List<Map<String, dynamic>> maps(dynamic v) =>
      v is List ? v.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList() : const [];
  final hasVariants = detail['has_variants'] == true || '${detail['has_variants']}' == '1';
  final images = maps(detail['images']);

  return {
    'item_id': text(detail['id']),
    'name_en': name.trim(),
    for (final k in const ['name_ar', 'name_fr', 'description_en', 'description_ar', 'description_fr', 'serial_no', 'variant_group_name', 'preparation_time'])
      if (text(detail[k]).isNotEmpty) k: text(detail[k]),
    'category_ids': jsonEncode(detail['category_ids'] is List ? detail['category_ids'] : const []),
    'in_kg': detail['in_kg'] == true || '${detail['in_kg']}' == '1' ? '1' : '0',
    'has_variants': hasVariants ? '1' : '0',
    if (!hasVariants) 'price': (price ?? text(detail['price'])).trim(),
    if (!hasVariants && (discountPrice ?? text(detail['discount_price'])).trim().isNotEmpty)
      'discount_price': (discountPrice ?? text(detail['discount_price'])).trim(),
    'available_status': available ? '1' : '2',
    'tags': jsonEncode([
      for (final t in (detail['tags'] is List ? detail['tags'] as List : const []))
        if (t is Map) t['id'] else t,
    ]),
    'variants': jsonEncode([
      if (hasVariants)
        for (final v in maps(detail['variants']))
          {
            'id': v['id'],
            'name': v['name'],
            'price': variantPrices[int.tryParse('${v['id']}')]?.trim() ?? v['price'],
            if (text(v['sku']).isNotEmpty) 'sku': v['sku'],
            'selection_requirement': v['selection_requirement'] ?? 'optional',
          },
    ]),
    'option_groups': jsonEncode([
      for (final g in maps(detail['option_groups']))
        {
          'id': g['id'],
          'name': g['name'],
          'selection_requirement': g['selection_requirement'] ?? 'optional',
          'min_selections': g['min_selections'],
          'max_selections': g['max_selections'],
          'options': [
            for (final o in maps(g['options']))
              {
                'id': o['id'],
                'name': o['name'],
                'additional_price': o['additional_price'] ?? 0,
                'available_status': o['available_status'] ?? 1,
              },
          ],
        },
    ]),
    'remove_image_ids': jsonEncode([
      if (replaceImage && images.isNotEmpty) images.first['id'],
    ]),
  };
}

/// Opens the sheet; [onAdvanced] opens the full edit screen. Returns true
/// when the item was saved.
Future<bool?> showQuickEditItemSheet(
  BuildContext context, {
  required String itemId,
  required VoidCallback onAdvanced,
  QuickEditApi api = const QuickEditApi(),
  Future<String?> Function()? pickImage,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => QuickEditItemSheet(itemId: itemId, onAdvanced: onAdvanced, api: api, pickImage: pickImage),
  );
}

class QuickEditItemSheet extends StatefulWidget {
  const QuickEditItemSheet({
    super.key,
    required this.itemId,
    required this.onAdvanced,
    this.api = const QuickEditApi(),
    this.pickImage,
  });

  final String itemId;
  final VoidCallback onAdvanced;
  final QuickEditApi api;

  /// Returns a picked photo's path; the gallery by default.
  final Future<String?> Function()? pickImage;

  @override
  State<QuickEditItemSheet> createState() => _QuickEditItemSheetState();
}

class _QuickEditItemSheetState extends State<QuickEditItemSheet> {
  static const _orange = Color(0xFFFF5216);

  Map<String, dynamic>? _detail;
  String? _error;
  bool _saving = false;
  bool _available = true;
  String? _imagePath;
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _offer = TextEditingController();
  final Map<int, TextEditingController> _variantPrices = {};

  bool get _hasVariants => _detail?['has_variants'] == true || '${_detail?['has_variants']}' == '1';

  List<Map<String, dynamic>> get _variants => _detail?['variants'] is List
      ? (_detail!['variants'] as List).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList()
      : const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _offer.dispose();
    for (final c in _variantPrices.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _text(dynamic v) => v == null || '$v' == 'null' ? '' : '$v';

  Future<void> _load() async {
    try {
      final d = await widget.api.load(widget.itemId);
      if (!mounted) return;
      setState(() {
        _detail = d;
        _name.text = _text(d['name_en']);
        _price.text = _text(d['price']);
        _offer.text = _text(d['discount_price']);
        _available = '${d['available_status'] ?? 1}' == '1';
        for (final v in _variants) {
          final id = int.tryParse('${v['id']}');
          if (id != null) _variantPrices[id] = TextEditingController(text: _text(v['price']));
        }
      });
    } catch (e) {
      if (mounted) setState(() => _error = WaterApi.errorText(e));
    }
  }

  String? _validate() {
    final s = S.of(context);
    if (_name.text.trim().isEmpty) return s.quickEditNameRequired;
    bool badPrice(String v) => double.tryParse(v.trim()) == null || double.parse(v.trim()) < 0;
    if (_hasVariants) {
      if (_variantPrices.values.any((c) => badPrice(c.text))) return s.quickEditPriceInvalid;
    } else {
      if (badPrice(_price.text)) return s.quickEditPriceInvalid;
      if (_offer.text.trim().isNotEmpty) {
        if (badPrice(_offer.text)) return s.quickEditPriceInvalid;
        if (double.parse(_offer.text.trim()) > double.parse(_price.text.trim())) return s.quickEditOfferAbovePrice;
      }
    }
    return null;
  }

  Future<void> _save() async {
    final problem = _validate();
    final messenger = ScaffoldMessenger.of(context);
    if (problem != null) {
      messenger.showSnackBar(SnackBar(content: Text(problem)));
      return;
    }
    setState(() => _saving = true);
    try {
      final body = buildQuickEditBody(
        _detail!,
        name: _name.text,
        price: _price.text,
        discountPrice: _offer.text,
        variantPrices: {for (final e in _variantPrices.entries) e.key: e.value.text},
        available: _available,
        replaceImage: _imagePath != null,
      );
      final msg = await widget.api.save(body, imagePath: _imagePath);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(msg ?? S.current.itemUpdatedSuccessfully)));
      Navigator.of(context).pop(true);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(WaterApi.errorText(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pick() async {
    final path = await (widget.pickImage ??
        () async => (await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85))?.path)();
    if (path != null && mounted) setState(() => _imagePath = path);
  }

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 14),
        child: Text(text, style: appFont('Rubik', fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF374151))),
      );

  Widget _photo() {
    final url = _text(_detail?['image_url']);
    final images = _detail?['images'];
    final first = images is List && images.isNotEmpty && images.first is Map ? _text(images.first['image_url']) : '';
    final shown = first.isNotEmpty ? first : url;
    Widget img;
    if (_imagePath != null) {
      img = const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 36);
    } else if (shown.isNotEmpty) {
      img = Image.network(shown, fit: BoxFit.cover, width: 88, height: 88,
          errorBuilder: (c, e, s) => const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF)));
    } else {
      img = const Icon(Icons.add_a_photo_outlined, color: Color(0xFF9CA3AF));
    }
    return Row(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(width: 88, height: 88, color: const Color(0xFFF3F4F6), alignment: Alignment.center, child: img),
      ),
      const SizedBox(width: 14),
      OutlinedButton.icon(
        key: const Key('quickEditPhoto'),
        onPressed: _saving ? null : _pick,
        style: OutlinedButton.styleFrom(
          foregroundColor: _orange,
          side: const BorderSide(color: _orange),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        icon: const Icon(Icons.photo_camera_outlined, size: 18),
        label: Text(_imagePath == null ? S.of(context).quickEditChangePhoto : S.of(context).quickEditNewPhotoChosen),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(children: [
                Expanded(child: Text(s.quickEditTitle, style: appFont('Rubik', fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ]),
            ),
            const Divider(height: 1),
            Flexible(
              child: _detail == null
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: _error == null
                            ? const CircularProgressIndicator(color: _orange)
                            : Text(_error!, textAlign: TextAlign.center),
                      ),
                    )
                  : ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(20, 8, 20, 8), children: [
                      const SizedBox(height: 8),
                      _photo(),
                      _label(s.quickEditName),
                      TextField(key: const Key('quickEditName'), controller: _name, decoration: _decoration(s.quickEditName)),
                      if (_hasVariants) ...[
                        _label(s.quickEditVariantPrices),
                        for (final v in _variants)
                          if (_variantPrices[int.tryParse('${v['id']}')] != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(children: [
                                Expanded(child: Text(_text(v['name']), style: appFont('Rubik', fontSize: 14))),
                                SizedBox(
                                  width: 130,
                                  child: TextField(
                                    key: Key('quickEditVariant-${v['id']}'),
                                    controller: _variantPrices[int.tryParse('${v['id']}')],
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: _decoration('0').copyWith(suffixText: 'MRU'),
                                  ),
                                ),
                              ]),
                            ),
                      ] else
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label(s.quickEditPrice),
                              TextField(
                                key: const Key('quickEditPrice'),
                                controller: _price,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _decoration('0').copyWith(suffixText: 'MRU'),
                              ),
                            ]),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label(s.quickEditOfferPrice),
                              TextField(
                                key: const Key('quickEditOffer'),
                                controller: _offer,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _decoration(s.quickEditOptional).copyWith(suffixText: 'MRU'),
                              ),
                            ]),
                          ),
                        ]),
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        key: const Key('quickEditAvailable'),
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: _orange,
                        title: Text(s.quickEditAvailable, style: appFont('Rubik', fontSize: 14, fontWeight: FontWeight.w500)),
                        subtitle: Text(_available ? s.quickEditAvailableOn : s.quickEditAvailableOff,
                            style: appFont('Rubik', fontSize: 12, color: const Color(0xFF6B7280))),
                        value: _available,
                        onChanged: _saving ? null : (v) => setState(() => _available = v),
                      ),
                      TextButton.icon(
                        onPressed: _saving
                            ? null
                            : () {
                                Navigator.pop(context);
                                widget.onAdvanced();
                              },
                        icon: const Icon(Icons.tune, size: 18, color: _orange),
                        label: Text(s.quickEditAdvanced, style: appFont('Rubik', fontSize: 14, color: _orange, fontWeight: FontWeight.w500)),
                      ),
                    ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  key: const Key('quickEditSave'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    disabledBackgroundColor: const Color(0xFFFFCDBA),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _detail == null || _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(s.quickEditSave, style: appFont('Rubik', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
