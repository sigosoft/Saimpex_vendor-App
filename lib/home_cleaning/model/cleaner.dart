import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/home_cleaning/controller/cleaning_api.dart';

/// A home cleaning vendor's cleaner, API doc §6.39 (task V16):
/// `{id, name, phone, photo_url, status (1 active, 2 deactivated), rating,
/// reviews_count, availability: available|busy|inactive, busy_with}`.
class Cleaner {
  const Cleaner({
    required this.id,
    required this.name,
    this.phone,
    this.photoUrl,
    this.active = true,
    this.rating,
    this.reviewsCount = 0,
    this.availability = 'available',
    this.busyFrom,
    this.busyOrderCode,
  });

  final int id;
  final String name;
  final String? phone;
  final String? photoUrl;
  final bool active;
  final double? rating;
  final int reviewsCount;

  /// available | busy | inactive (for a booking's time when listed with
  /// `order_id`).
  final String availability;
  final DateTime? busyFrom;
  final String? busyOrderCode;

  bool get isAvailable => availability == 'available';
  bool get isBusy => availability == 'busy';

  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  static Cleaner? fromJson(dynamic json) {
    if (json is! Map) return null;
    final id = int.tryParse('${json['id'] ?? json['cleaner_id'] ?? ''}');
    if (id == null) return null;
    final busy = json['busy_with'];
    final status = int.tryParse('${json['status'] ?? 1}') ?? 1;
    return Cleaner(
      id: id,
      name: (json['name'] ?? '').toString(),
      phone: json['phone']?.toString(),
      photoUrl: (json['photo_url'] ?? '').toString().isEmpty ? null : json['photo_url'].toString(),
      active: json['active'] == null ? status == 1 : (json['active'] == true || json['active'].toString() == '1'),
      rating: double.tryParse('${json['rating'] ?? ''}'),
      reviewsCount: int.tryParse('${json['reviews_count'] ?? 0}') ?? 0,
      availability: (json['availability'] ?? (status == 1 ? 'available' : 'inactive')).toString(),
      busyFrom: busy is Map ? DateTime.tryParse('${busy['scheduled_for'] ?? ''}')?.toLocal() : null,
      busyOrderCode: busy is Map ? busy['order_code']?.toString() : null,
    );
  }
}

class CleanersPage {
  const CleanersPage(this.cleaners, this.counts);

  final List<Cleaner> cleaners;

  /// total, available, busy, inactive
  final Map<String, int> counts;
}

/// Cleaner calls (ServiceVerticalController, home cleaning only).
class CleanersApi {
  const CleanersApi._();

  /// `GET serviceCleaners` — with [orderId], availability is for that
  /// booking's time (Assign Cleaner sheet).
  static Future<CleanersPage> list({String? keyword, int? orderId}) async {
    final res = await CleaningApi.get(ApiEndPoints.serviceCleaners, query: {
      if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
      if (orderId != null) 'order_id': orderId,
    });
    if (!res.ok) throw CleanersApiException(res.message);
    final list = res.map['cleaners'];
    final counts = res.map['counts'];
    return CleanersPage(
      list is List ? list.map(Cleaner.fromJson).whereType<Cleaner>().toList() : const [],
      counts is Map ? counts.map((k, v) => MapEntry('$k', int.tryParse('$v') ?? 0)) : const {},
    );
  }

  /// `POST addServiceCleaner` / `updateServiceCleaner` (multipart when a
  /// photo is sent). Returns the server message.
  static Future<String?> save({int? id, String? name, String? phone, bool? active, File? photo}) async {
    final fields = <String, dynamic>{
      if (id != null) 'cleaner_id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (active != null) 'status': active ? 1 : 2,
    };
    if (photo != null) {
      fields['photo'] = await dio.MultipartFile.fromFile(photo.path, filename: photo.path.split(Platform.pathSeparator).last);
    }
    final res = await CleaningApi.postBody(
      id == null ? ApiEndPoints.addServiceCleaner : ApiEndPoints.updateServiceCleaner,
      photo != null ? dio.FormData.fromMap(fields) : fields,
    );
    if (!res.ok) throw CleanersApiException(res.message);
    return res.message;
  }

  /// `POST assignServiceCleaner` — 422 for a deactivated or busy cleaner.
  static Future<CleaningApiResult> assign({required int orderId, required int cleanerId}) =>
      CleaningApi.post(ApiEndPoints.assignServiceCleaner, {'order_id': orderId, 'cleaner_id': cleanerId});
}

class CleanersApiException implements Exception {
  const CleanersApiException(this.message);
  final String? message;

  @override
  String toString() => message ?? '';
}
