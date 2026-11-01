import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/controller/services_api.dart';
import 'package:saimpex_vendor/home_cleaning/model/service_item_model.dart';
import 'package:saimpex_vendor/home_cleaning/model/service_kind.dart';
import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/view/settings/category_requests_screen.dart';

// Add / edit a laundry or car wash service (task V14 part B). Figma "Vendor
// Apps": laundry Add Service (9714:86553), item pricing (9714:86733) and Add
// Item sheet (9714:86867); car wash Add Service (9714:82201) with vehicle
// types, add-ons and home / workplace distance pricing. API: addServiceItem /
// updateServiceItem (rows as JSON, row images as `<rows>[i][image]`).

const Color _orange = Color(0xFFFF5216);
const Color _ink = Color(0xFF1A1A1A);
const Color _muted = Color(0xFF8A94A6);
const Color _field = Color(0xFFF3F4F6);
const Color _pageBg = Color(0xFFFFF8F4);

TextStyle _t(double size, FontWeight w, Color c) => appFont('Inter', fontSize: size, fontWeight: w, color: c);

double? _d(dynamic v) => v == null ? null : double.tryParse(v.toString());
String _n(num? v) => v == null ? '' : (v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString());

/// One editable row: a garment, a vehicle type, an add-on or a distance band.
class _Row {
  _Row({this.name = '', this.unit, this.detail, this.price, this.min, this.max, this.imagePath, this.imageUrl});

  String name;
  String? unit; // garments: piece | kg | metre
  String? detail; // add-ons: short description
  double? price;
  double? min; // distance bands (km)
  double? max;
  String? imagePath; // stored path from the server, sent back on save
  String? imageUrl; // for display
  File? imageFile; // newly picked
}

class ServiceFormView extends StatefulWidget {
  const ServiceFormView({super.key, this.initial, this.loadTypes});

  final CleaningServiceItem? initial;

  /// Service types source; the API by default (tests pass a fixed list).
  final Future<List<CleaningServiceType>> Function()? loadTypes;

  @override
  State<ServiceFormView> createState() => _ServiceFormViewState();
}

class _ServiceFormViewState extends State<ServiceFormView> {
  final _description = TextEditingController();
  final _price = TextEditingController();

  List<CleaningServiceType> _types = [];
  CleaningServiceType? _type;
  File? _image;
  String? _imageUrl;
  bool _saving = false;
  bool _loadingTypes = true;

  // Laundry
  String _processing = 'Standard (24h)';
  String _unit = 'kg';
  final List<_Row> _garments = [];

  // Car wash
  final List<_Row> _vehicles = [];
  final List<_Row> _addons = [];
  final List<_Row> _distances = [];

  bool get _laundry => ServiceKinds.isLaundry;
  String get _lang => LocalizationService.currentLanguageCode;

  @override
  void initState() {
    super.initState();
    _fill(widget.initial);
    _loadTypes();
  }

  @override
  void dispose() {
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  List<_Row> _rows(dynamic list, _Row Function(Map<String, dynamic>) make) => list is List
      ? list.whereType<Map>().map((m) => make(Map<String, dynamic>.from(m))).toList()
      : <_Row>[];

  void _fill(CleaningServiceItem? item) {
    _description.text = item?.description ?? '';
    _imageUrl = item?.imageUrl;
    final r = item?.raw ?? const {};
    _processing = r['processing']?.toString() == 'Express' ? 'Express' : 'Standard (24h)';
    _unit = r['unit']?.toString() == 'item' ? 'item' : 'kg';
    _price.text = item == null ? '' : _n(item.price);
    _garments
      ..clear()
      ..addAll(_rows(r['garments'], (g) => _Row(
            name: g['name']?.toString() ?? '',
            unit: g['unit']?.toString() ?? 'piece',
            price: _d(g['price']),
            imagePath: g['image']?.toString(),
            imageUrl: g['image_url']?.toString(),
          )));
    _vehicles
      ..clear()
      ..addAll(_rows(r['spaces'], (v) => _Row(
            name: v['name']?.toString() ?? '',
            price: _d(v['price']),
            imagePath: v['image']?.toString(),
            imageUrl: v['image_url']?.toString(),
          )));
    _addons
      ..clear()
      ..addAll(_rows(r['addons'], (a) => _Row(
            name: a['name']?.toString() ?? '',
            detail: a['detail']?.toString(),
            price: _d(a['price']),
            imagePath: a['image']?.toString(),
            imageUrl: a['image_url']?.toString(),
          )));
    _distances
      ..clear()
      ..addAll(_rows(r['distances'], (b) => _Row(min: _d(b['min_km']), max: _d(b['max_km']), price: _d(b['price']))));
  }

  Future<void> _loadTypes() async {
    try {
      final types = await (widget.loadTypes ?? CleaningServicesApi.fetchTypes)();
      if (!mounted) return;
      setState(() {
        _types = types;
        final id = widget.initial?.serviceTypeId;
        _type = types.where((t) => t.id == id).firstOrNull ?? (_type != null ? types.where((t) => t.id == _type!.id).firstOrNull : null);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      if (mounted) setState(() => _loadingTypes = false);
    }
  }

  Future<File?> _pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1600);
    return x == null ? null : File(x.path);
  }

  void _reset() => setState(() {
        _fill(widget.initial);
        _image = null;
        if (widget.initial == null) _type = null;
      });

  Future<void> _requestType() async {
    final sent = await showRequestSheet(
      context,
      title: S.of(context).requestNewServiceType,
      nameLabel: S.of(context).serviceTypeName,
      send: (name, reason) async {
        final res = await DioClient().post(ApiEndPoints.requestServiceType, body: {'name_en': name, 'reason': reason});
        return res.data is Map && res.data['status'] == true;
      },
    );
    if (sent == true) Fluttertoast.showToast(msg: S.current.requestSentForReview);
  }

  String? _validate(S s) {
    if (_type == null) return s.serviceChooseType;
    if (_laundry) {
      if (_unit == 'kg' && (double.tryParse(_price.text) ?? -1) < 0) return s.serviceEnterPrice;
      if (_unit == 'item' && !_garments.any((g) => g.name.trim().isNotEmpty)) return s.serviceAddOneItem;
    } else if (!_vehicles.any((v) => v.name.trim().isNotEmpty)) {
      return s.serviceAddOneVehicleType;
    }
    return null;
  }

  Future<void> _save() async {
    final s = S.of(context);
    final problem = _validate(s);
    if (problem != null) {
      Fluttertoast.showToast(msg: problem);
      return;
    }
    setState(() => _saving = true);
    try {
      DioClient().updateToken((await getSavedObject('token'))?.toString() ?? '');
      final t = _type!;
      final fields = <String, dynamic>{
        if (widget.initial != null) 'service_item_id': widget.initial!.id,
        'service_type_id': t.id,
        'name_en': t.nameEn ?? t.localizedName(_lang),
        if (t.nameFr != null) 'name_fr': t.nameFr,
        if (t.nameAr != null) 'name_ar': t.nameAr,
        'description_en': _description.text.trim(),
        'status': widget.initial?.status ?? 1,
      };
      final files = <MapEntry<String, dio.MultipartFile>>[];
      Future<void> addFiles(String key, List<_Row> rows) async {
        for (var i = 0; i < rows.length; i++) {
          final f = rows[i].imageFile;
          if (f != null) {
            files.add(MapEntry('$key[$i][image]', await dio.MultipartFile.fromFile(f.path, filename: f.path.split(Platform.pathSeparator).last)));
          }
        }
      }

      if (_laundry) {
        fields['processing'] = _processing;
        fields['unit'] = _unit;
        if (_unit == 'kg') {
          fields['price'] = double.tryParse(_price.text) ?? 0;
          fields['garments'] = jsonEncode([]);
        } else {
          final rows = _garments.where((g) => g.name.trim().isNotEmpty).toList();
          fields['price'] = rows.first.price ?? 0;
          fields['garments'] = jsonEncode([
            for (final g in rows)
              {'name': g.name.trim(), 'unit': g.unit ?? 'piece', 'price': g.price ?? 0, if (g.imagePath != null) 'image': g.imagePath},
          ]);
          await addFiles('garments', rows);
        }
      } else {
        final vehicles = _vehicles.where((v) => v.name.trim().isNotEmpty).toList();
        final addons = _addons.where((a) => a.name.trim().isNotEmpty).toList();
        fields['price'] = vehicles.first.price ?? 0;
        fields['vehicles'] = jsonEncode([
          for (final v in vehicles) {'name': v.name.trim(), 'price': v.price ?? 0, if (v.imagePath != null) 'image': v.imagePath},
        ]);
        fields['addons'] = jsonEncode([
          for (final a in addons)
            {'name': a.name.trim(), 'detail': a.detail ?? '', 'price': a.price ?? 0, if (a.imagePath != null) 'image': a.imagePath},
        ]);
        fields['distances'] = jsonEncode([
          for (final b in _distances) {'min_km': b.min ?? 0, 'max_km': b.max ?? 0, 'price': b.price ?? 0},
        ]);
        await addFiles('vehicles', vehicles);
        await addFiles('addons', addons);
      }
      final form = dio.FormData.fromMap(fields);
      if (_image != null) {
        form.files.add(MapEntry('image', await dio.MultipartFile.fromFile(_image!.path, filename: _image!.path.split(Platform.pathSeparator).last)));
      }
      form.files.addAll(files);
      final res = await DioClient().post(
        widget.initial == null ? ApiEndPoints.addServiceItem : ApiEndPoints.updateServiceItem,
        body: form,
      );
      final ok = CleaningServicesApi.isOk(res.data is Map ? Map<String, dynamic>.from(res.data) : null);
      final msg = CleaningServicesApi.serverMessage(res.data);
      if (msg != null) Fluttertoast.showToast(msg: msg);
      if (ok && mounted) Navigator.of(context).pop(true);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Row editors ───────────────────────────────────────────────────────

  Future<void> _editRow(List<_Row> list, {int? index, required _RowKind kind}) async {
    final row = await showModalBottomSheet<_Row>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _RowSheet(kind: kind, initial: index == null ? null : list[index], pick: _pick),
    );
    if (row == null) return;
    setState(() => index == null ? list.add(row) : list[index] = row);
  }

  // ── UI ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final rtl = _lang == 'ar';
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(
          backgroundColor: _pageBg,
          elevation: 0,
          centerTitle: true,
          foregroundColor: _ink,
          title: Text(widget.initial == null ? s.addService : s.editService, style: _t(17, FontWeight.w700, _ink)),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(s.serviceImage, style: _t(13, FontWeight.w600, _muted)),
            const SizedBox(height: 8),
            _imageBox(file: _image, url: _imageUrl, height: 160, onTap: () async {
              final f = await _pick();
              if (f != null) setState(() => _image = f);
            }),
            const SizedBox(height: 16),
            _section(s.basicInformation, [
              Row(children: [
                Expanded(child: Text(_laundry ? s.laundryService : s.serviceTypeLabel, style: _t(13, FontWeight.w600, _ink))),
                TextButton(onPressed: _requestType, child: Text('+ ${s.requestNewServiceType}', style: _t(12, FontWeight.w600, _orange))),
              ]),
              _dropdown<CleaningServiceType>(
                value: _type,
                hint: _loadingTypes ? '…' : s.serviceChooseType,
                items: {for (final t in _types) t: t.localizedName(_lang)},
                onChanged: (v) => setState(() => _type = v),
              ),
              if (_laundry) ...[
                _label(s.processingTime),
                _dropdown<String>(
                  value: _processing,
                  items: {'Standard (24h)': s.processingStandard24h, 'Express': s.processingExpress},
                  onChanged: (v) => setState(() => _processing = v ?? _processing),
                ),
                _label(s.pricingUnit),
                _dropdown<String>(
                  value: _unit,
                  items: {'kg': s.pricingPerKg, 'item': s.pricingPerItem},
                  onChanged: (v) => setState(() => _unit = v ?? _unit),
                ),
                if (_unit == 'kg') ...[
                  _label(s.price),
                  _textField(_price, hint: '150', suffix: s.mruPerKg, number: true),
                ],
              ],
              _label(s.shortDescription),
              _textField(_description, hint: s.enterDescription, lines: 3),
            ]),
            if (_laundry && _unit == 'item')
              _section(s.itemPricing, [
                Text(s.itemPricingHelp, style: _t(12, FontWeight.w400, _muted)),
                const SizedBox(height: 8),
                for (var i = 0; i < _garments.length; i++)
                  _rowTile(_garments[i], '${_n(_garments[i].price)} ${s.mruPerUnit(_unitLabel(s, _garments[i].unit))}',
                      onEdit: () => _editRow(_garments, index: i, kind: _RowKind.garment),
                      onDelete: () => setState(() => _garments.removeAt(i))),
                _addButton(s.addItem, () => _editRow(_garments, kind: _RowKind.garment)),
              ]),
            if (!_laundry) ...[
              _section(s.addVehicleType, [
                for (var i = 0; i < _vehicles.length; i++)
                  _rowTile(_vehicles[i], '${_n(_vehicles[i].price)} MRU',
                      onEdit: () => _editRow(_vehicles, index: i, kind: _RowKind.vehicle),
                      onDelete: () => setState(() => _vehicles.removeAt(i))),
                _addButton(s.addVehicleType, () => _editRow(_vehicles, kind: _RowKind.vehicle)),
              ]),
              _section(s.addOnServices, [
                for (var i = 0; i < _addons.length; i++)
                  _rowTile(_addons[i], '+${_n(_addons[i].price)} MRU',
                      subtitle: _addons[i].detail,
                      onEdit: () => _editRow(_addons, index: i, kind: _RowKind.addon),
                      onDelete: () => setState(() => _addons.removeAt(i))),
                _addButton(s.addAddOn, () => _editRow(_addons, kind: _RowKind.addon)),
              ]),
              _section(s.homeWorkplacePricing, [
                Text(s.homeWorkplacePricingHelp, style: _t(12, FontWeight.w400, _muted)),
                const SizedBox(height: 8),
                for (var i = 0; i < _distances.length; i++)
                  _rowTile(_Row(name: '${_n(_distances[i].min)} – ${_n(_distances[i].max)} km'), '${_n(_distances[i].price)} MRU',
                      noImage: true,
                      onEdit: () => _editRow(_distances, index: i, kind: _RowKind.distance),
                      onDelete: () => setState(() => _distances.removeAt(i))),
                _addButton(s.addDistanceRange, () => _editRow(_distances, kind: _RowKind.distance)),
              ]),
            ],
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : _reset,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(s.reset, style: _t(15, FontWeight.w600, _ink)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: _orange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(widget.initial == null ? s.addService : s.saveChanges, style: _t(15, FontWeight.w700, Colors.white)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  String _unitLabel(S s, String? unit) => switch (unit) {
        'kg' => s.unitKg,
        'metre' => s.unitMetre,
        _ => s.unitPiece,
      };

  Widget _section(String title, List<Widget> children) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title.toUpperCase(), style: _t(13, FontWeight.w700, _ink).copyWith(letterSpacing: 0.4)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(text, style: _t(13, FontWeight.w600, _ink)),
      );

  Widget _dropdown<T>({required T? value, String? hint, required Map<T, String> items, required ValueChanged<T?> onChanged}) =>
      DropdownButtonFormField<T>(
        initialValue: items.containsKey(value) ? value : null,
        isExpanded: true,
        hint: hint == null ? null : Text(hint, style: _t(14, FontWeight.w400, _muted)),
        items: [for (final e in items.entries) DropdownMenuItem(value: e.key, child: Text(e.value, style: _t(14, FontWeight.w600, _ink)))],
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: _field,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      );

  Widget _textField(TextEditingController c, {String? hint, String? suffix, bool number = false, int lines = 1}) => TextField(
        controller: c,
        minLines: lines,
        maxLines: lines,
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
        decoration: InputDecoration(
          hintText: hint,
          suffixText: suffix,
          filled: true,
          fillColor: _field,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      );

  Widget _rowTile(_Row row, String trailing,
          {String? subtitle, bool noImage = false, required VoidCallback onEdit, required VoidCallback onDelete}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          if (!noImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(width: 48, height: 48, child: _thumb(row.imageFile, row.imageUrl)),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(row.name, style: _t(14, FontWeight.w600, _ink)),
              if ((subtitle ?? '').isNotEmpty) Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: _t(11, FontWeight.w400, _muted)),
            ]),
          ),
          Text(trailing, style: _t(13, FontWeight.w700, _ink)),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 18, color: _orange)),
          IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFE53935))),
        ]),
      );

  Widget _addButton(String label, VoidCallback onTap) => OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add, size: 18, color: _orange),
        label: Text(label, style: _t(13, FontWeight.w600, _orange)),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(44),
          side: const BorderSide(color: _orange),
          backgroundColor: const Color(0xFFFFF4EC),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}

Widget _thumb(File? file, String? url) {
  if (file != null) return Image.file(file, fit: BoxFit.cover);
  if (url != null && url.isNotEmpty) {
    return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: _field));
  }
  return const ColoredBox(color: _field, child: Icon(Icons.image_outlined, color: _muted));
}

Widget _imageBox({File? file, String? url, required double height, required VoidCallback onTap}) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFC9AE)),
        ),
        clipBehavior: Clip.antiAlias,
        child: file != null || (url != null && url.isNotEmpty)
            ? _thumb(file, url)
            : Builder(
                builder: (context) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.add_a_photo_outlined, color: _orange, size: 28),
                  const SizedBox(height: 6),
                  Text(S.of(context).tapToUploadImage, style: _t(13, FontWeight.w600, _ink)),
                ]),
              ),
      ),
    );

enum _RowKind { garment, vehicle, addon, distance }

class _RowSheet extends StatefulWidget {
  const _RowSheet({required this.kind, this.initial, required this.pick});

  final _RowKind kind;
  final _Row? initial;
  final Future<File?> Function() pick;

  @override
  State<_RowSheet> createState() => _RowSheetState();
}

class _RowSheetState extends State<_RowSheet> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _detail = TextEditingController(text: widget.initial?.detail ?? '');
  late final _price = TextEditingController(text: _n(widget.initial?.price));
  late final _min = TextEditingController(text: _n(widget.initial?.min));
  late final _max = TextEditingController(text: _n(widget.initial?.max));
  late String _unit = widget.initial?.unit ?? 'piece';
  late File? _file = widget.initial?.imageFile;

  @override
  void dispose() {
    for (final c in [_name, _detail, _price, _min, _max]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _distance => widget.kind == _RowKind.distance;

  bool get _ready {
    final price = double.tryParse(_price.text);
    if (price == null || price < 0) return false;
    if (_distance) {
      final min = double.tryParse(_min.text);
      final max = double.tryParse(_max.text);
      return min != null && max != null && max > min;
    }
    return _name.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final title = switch (widget.kind) {
      _RowKind.garment => s.addItem,
      _RowKind.vehicle => s.addVehicleType,
      _RowKind.addon => s.addAddOn,
      _RowKind.distance => s.addDistanceRange,
    };
    InputDecoration deco(String hint, {String? suffix}) => InputDecoration(
          hintText: hint,
          suffixText: suffix,
          filled: true,
          fillColor: _field,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        );
    Widget gap() => const SizedBox(height: 10);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(child: Text(title, style: _t(17, FontWeight.w700, _ink))),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
            ]),
            if (!_distance) ...[
              _imageBox(file: _file, url: widget.initial?.imageUrl, height: 120, onTap: () async {
                final f = await widget.pick();
                if (f != null) setState(() => _file = f);
              }),
              gap(),
              TextField(
                controller: _name,
                onChanged: (_) => setState(() {}),
                decoration: deco(switch (widget.kind) {
                  _RowKind.garment => s.itemNameHint,
                  _RowKind.vehicle => s.vehicleTypeHint,
                  _ => s.addOnNameHint,
                }),
              ),
            ],
            if (widget.kind == _RowKind.garment) ...[
              gap(),
              DropdownButtonFormField<String>(
                initialValue: _unit,
                items: [
                  DropdownMenuItem(value: 'piece', child: Text(s.unitPiece)),
                  DropdownMenuItem(value: 'kg', child: Text(s.unitKg)),
                  DropdownMenuItem(value: 'metre', child: Text(s.unitMetre)),
                ],
                onChanged: (v) => setState(() => _unit = v ?? _unit),
                decoration: deco(s.pricingUnit),
              ),
            ],
            if (widget.kind == _RowKind.addon) ...[
              gap(),
              TextField(controller: _detail, maxLines: 2, decoration: deco(s.addOnDescriptionHint)),
            ],
            if (_distance) ...[
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _min,
                    onChanged: (_) => setState(() {}),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: deco(s.minKm, suffix: 'km'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _max,
                    onChanged: (_) => setState(() {}),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: deco(s.maxKm, suffix: 'km'),
                  ),
                ),
              ]),
            ],
            gap(),
            TextField(
              controller: _price,
              onChanged: (_) => setState(() {}),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: deco(s.price, suffix: 'MRU'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: !_ready
                  ? null
                  : () => Navigator.of(context).pop(_Row(
                        name: _name.text.trim(),
                        unit: widget.kind == _RowKind.garment ? _unit : null,
                        detail: widget.kind == _RowKind.addon ? _detail.text.trim() : null,
                        price: double.tryParse(_price.text),
                        min: _distance ? double.tryParse(_min.text) : null,
                        max: _distance ? double.tryParse(_max.text) : null,
                        imagePath: widget.initial?.imagePath,
                        imageUrl: widget.initial?.imageUrl,
                      )..imageFile = _file),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: _orange,
                disabledBackgroundColor: _orange.withValues(alpha: 0.4),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(widget.initial == null ? s.add : s.saveChanges, style: _t(15, FontWeight.w700, Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
