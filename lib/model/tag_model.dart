class TagsModel {
  String? status;
  List<TagData>? data;
  String? message;

  TagsModel({
    this.status,
    this.data,
    this.message,
  });

  factory TagsModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<dynamic>? list;
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map) {
      for (final key in ['data', 'tags', 'menu_tags']) {
        if (rawData[key] is List) {
          list = rawData[key];
          break;
        } else if (rawData[key] is Map && rawData[key]['data'] is List) {
          list = rawData[key]['data'];
          break;
        }
      }
    }
    return TagsModel(
      status: json['status']?.toString(),
      data: list
              ?.whereType<Map>()
              .map((e) => TagData.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class TagData {
  int? id;
  String? nameEn;
  String? nameAr;
  String? nameFr;

  TagData({
    this.id,
    this.nameEn,
    this.nameAr,
    this.nameFr,
  });

  String get displayName {
    if (nameEn != null && nameEn!.trim().isNotEmpty) return nameEn!.trim();
    if (nameFr != null && nameFr!.trim().isNotEmpty) return nameFr!.trim();
    if (nameAr != null && nameAr!.trim().isNotEmpty) return nameAr!.trim();
    return '';
  }

  factory TagData.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['tag_id'] ?? json['menu_tag_id'];
    final id =
        rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0;
    final name = (json['name_en'] ??
            json['name'] ??
            json['tag_name'] ??
            json['title'] ??
            '')
        .toString();
    return TagData(
      id: id,
      nameEn: name,
      nameAr: (json['name_ar'] ?? json['name'] ?? name).toString(),
      nameFr: (json['name_fr'] ?? json['name'] ?? name).toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
      'name_fr': nameFr,
    };
  }
}