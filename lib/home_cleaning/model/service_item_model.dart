/// Home cleaning catalogue models, parsed from the vendorapp service vertical
/// endpoints (ServiceVerticalController: serviceTypes, serviceItems,
/// addServiceItem, updateServiceItem).
library;

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}

String? _toText(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text == 'null') return null;
  return text;
}

List<String> _toStringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((e) => e is Map ? (e['name'] ?? e['label']) : e)
      .map(_toText)
      .whereType<String>()
      .toList();
}

/// Formats a price without useless decimals: 100.0 -> "100", 12.5 -> "12.5".
String formatServicePrice(double? value) {
  if (value == null) return '0';
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

/// Picks the name for the current language, falling back to English.
String _localized(String lang, String? en, String? fr, String? ar) {
  if (lang == 'fr' && fr != null) return fr;
  if (lang == 'ar' && ar != null) return ar;
  return en ?? fr ?? ar ?? '';
}

/// Property types and product supply values sent to the backend. The backend
/// stores them as free strings; product supply uses the same `customer` /
/// `vendor` values the customer booking API validates.
class CleaningServiceValues {
  static const propertyApartment = 'Apartment';
  static const propertyVilla = 'Villa';
  static const supplyCustomer = 'customer';
  static const supplyVendor = 'vendor';
}

class CleaningServiceType {
  const CleaningServiceType({
    required this.id,
    this.nameEn,
    this.nameFr,
    this.nameAr,
  });

  final int id;
  final String? nameEn;
  final String? nameFr;
  final String? nameAr;

  String localizedName(String lang) => _localized(lang, nameEn, nameFr, nameAr);

  static CleaningServiceType? fromJson(dynamic json) {
    if (json is! Map) return null;
    final id = _toInt(json['id']);
    if (id == null) return null;
    return CleaningServiceType(
      id: id,
      nameEn: _toText(json['name_en']) ?? _toText(json['name']),
      nameFr: _toText(json['name_fr']),
      nameAr: _toText(json['name_ar']),
    );
  }
}

class CleaningServiceSpace {
  CleaningServiceSpace({required this.name, required this.price, this.unit});

  String name;
  double price;

  /// Stored as the English unit value ('Room', 'Unit', 'Hour', 'Sq. Ft').
  String? unit;

  static CleaningServiceSpace? fromJson(dynamic json) {
    if (json is! Map) return null;
    final name = _toText(json['name']) ?? _toText(json['type']);
    if (name == null) return null;
    return CleaningServiceSpace(
      name: name,
      price: _toDouble(json['price']) ?? 0,
      unit: _toText(json['unit']),
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'unit': unit, 'price': price};
}

class CleaningServiceAddon {
  CleaningServiceAddon({required this.name, required this.price});

  String name;
  double price;

  static CleaningServiceAddon? fromJson(dynamic json) {
    if (json is! Map) return null;
    final name = _toText(json['name']);
    if (name == null) return null;
    return CleaningServiceAddon(
      name: name,
      price: _toDouble(json['price']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'price': price};
}

class CleaningServiceItem {
  const CleaningServiceItem({
    required this.id,
    this.serviceTypeId,
    this.nameEn,
    this.nameFr,
    this.nameAr,
    this.description,
    this.price = 0,
    this.status = 1,
    this.imageUrl,
    this.propertyTypes = const [],
    this.productSupply = const [],
    this.supplyFee,
    this.spaces = const [],
    this.addons = const [],
    this.issues = const [],
  });

  final int id;
  final int? serviceTypeId;
  final String? nameEn;
  final String? nameFr;
  final String? nameAr;
  final String? description;
  final double price;

  /// 1 active, 2 inactive.
  final int status;
  final String? imageUrl;
  final List<String> propertyTypes;
  final List<String> productSupply;
  final double? supplyFee;
  final List<CleaningServiceSpace> spaces;
  final List<CleaningServiceAddon> addons;
  final List<String> issues;

  String localizedName(String lang) => _localized(lang, nameEn, nameFr, nameAr);

  static CleaningServiceItem? fromJson(dynamic json) {
    if (json is! Map) return null;
    final id = _toInt(json['id']);
    if (id == null) return null;
    final spaces = json['spaces'] is List
        ? (json['spaces'] as List)
              .map(CleaningServiceSpace.fromJson)
              .whereType<CleaningServiceSpace>()
              .toList()
        : <CleaningServiceSpace>[];
    final addons = json['addons'] is List
        ? (json['addons'] as List)
              .map(CleaningServiceAddon.fromJson)
              .whereType<CleaningServiceAddon>()
              .toList()
        : <CleaningServiceAddon>[];
    return CleaningServiceItem(
      id: id,
      serviceTypeId: _toInt(json['service_type_id']),
      nameEn: _toText(json['name_en']) ?? _toText(json['name']),
      nameFr: _toText(json['name_fr']),
      nameAr: _toText(json['name_ar']),
      description:
          _toText(json['description_en']) ?? _toText(json['description']),
      price: _toDouble(json['price']) ?? 0,
      status: _toInt(json['status']) ?? 1,
      imageUrl: _toText(json['image_url']),
      propertyTypes: _toStringList(json['property_types']),
      productSupply: _toStringList(json['product_supply']),
      supplyFee: _toDouble(json['supply_fee']),
      spaces: spaces,
      addons: addons,
      issues: _toStringList(json['issues']),
    );
  }
}
