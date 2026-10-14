import 'package:intl/intl.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/pharmacy/model/pharmacy_order.dart';

class PharmacyPrescriptionsModel {
  final bool? status;
  final PharmacyPrescriptionsData? data;
  final String? message;

  PharmacyPrescriptionsModel({this.status, this.data, this.message});

  factory PharmacyPrescriptionsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PharmacyPrescriptionsModel();
    return PharmacyPrescriptionsModel(
      status: json['status'] == true || json['status']?.toString() == 'true',
      data: json['data'] != null
          ? PharmacyPrescriptionsData.fromJson(
              Map<String, dynamic>.from(json['data']),
            )
          : null,
      message: json['message']?.toString(),
    );
  }
}

class PharmacyPrescriptionsData {
  final int? currentPage;
  final List<PrescriptionItem>? data;
  final int? lastPage;
  final dynamic total;

  PharmacyPrescriptionsData({
    this.currentPage,
    this.data,
    this.lastPage,
    this.total,
  });

  factory PharmacyPrescriptionsData.fromJson(Map<String, dynamic> json) {
    List<PrescriptionItem> list = [];
    final prescriptions = json['prescriptions'];
    if (prescriptions is Map && prescriptions['data'] is List) {
      list = (prescriptions['data'] as List)
          .map(
            (e) =>
                PrescriptionItem.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } else if (json['data'] is List) {
      list = (json['data'] as List)
          .map(
            (e) =>
                PrescriptionItem.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } else if (prescriptions is List) {
      list = (prescriptions as List)
          .map(
            (e) =>
                PrescriptionItem.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    }

    final pageObj = prescriptions is Map ? prescriptions : json;

    return PharmacyPrescriptionsData(
      currentPage: pageObj['current_page'] is int
          ? pageObj['current_page']
          : int.tryParse(pageObj['current_page']?.toString() ?? ''),
      lastPage: pageObj['last_page'] is int
          ? pageObj['last_page']
          : int.tryParse(pageObj['last_page']?.toString() ?? ''),
      total: pageObj['total'],
      data: list,
    );
  }
}

class PrescriptionItem {
  final int? prescriptionId;
  final int? id;
  final int? userId;
  final int? pharmacyId;
  final String? flowType;
  final String? status;
  final String? note;
  final dynamic callBeforeAlternative;
  final String? contactNumber;
  final String? createdAt;
  final String? createdAtFormatted;
  final String? placedAt;
  final String? placedAtFormatted;
  final String? orderCode;
  final String? userName;
  final Map<String, dynamic>? user;
  final dynamic images;
  final dynamic prescriptionImage;
  final dynamic isSelfPickup;
  final dynamic deliveryType;
  final dynamic quoteAmount;
  final String? quoteExpiresAt;
  final String? quotedAt;
  final String? paymentRequestedAt;
  final Map<String, dynamic>? rawJson;

  PrescriptionItem({
    this.prescriptionId,
    this.id,
    this.userId,
    this.pharmacyId,
    this.flowType,
    this.status,
    this.note,
    this.callBeforeAlternative,
    this.contactNumber,
    this.createdAt,
    this.createdAtFormatted,
    this.placedAt,
    this.placedAtFormatted,
    this.orderCode,
    this.userName,
    this.user,
    this.images,
    this.prescriptionImage,
    this.isSelfPickup,
    this.deliveryType,
    this.quoteAmount,
    this.quoteExpiresAt,
    this.quotedAt,
    this.paymentRequestedAt,
    this.rawJson,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      prescriptionId: json['prescription_id'] is int
          ? json['prescription_id']
          : int.tryParse(json['prescription_id']?.toString() ?? ''),
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
      pharmacyId: json['pharmacy_id'] is int
          ? json['pharmacy_id']
          : int.tryParse(json['pharmacy_id']?.toString() ?? ''),
      flowType: json['flow_type']?.toString(),
      status: json['status']?.toString(),
      note: json['note']?.toString(),
      callBeforeAlternative: json['call_before_alternative'],
      contactNumber: json['contact_number']?.toString() ??
          json['phone']?.toString() ??
          json['mobile']?.toString(),
      createdAt: json['created_at']?.toString(),
      createdAtFormatted: json['created_at_formatted']?.toString(),
      placedAt: json['placed_at']?.toString(),
      placedAtFormatted: json['placed_at_formatted']?.toString(),
      orderCode: json['order_code']?.toString() ??
          json['order_number']?.toString() ??
          json['prescription_code']?.toString(),
      userName: json['user_name']?.toString() ??
          json['customer_name']?.toString() ??
          json['name']?.toString(),
      user: json['user'] is Map ? Map<String, dynamic>.from(json['user']) : null,
      images: json['images'] ?? json['prescription_images'] ?? json['files'],
      prescriptionImage: json['prescription_image'] ??
          json['image_path'] ??
          json['image'] ??
          json['file_path'] ??
          json['file'],
      isSelfPickup: json['is_self_pickup'] ?? json['isSelfPickup'],
      deliveryType: json['delivery_type'] ?? json['deliveryType'],
      quoteAmount: json['quote_amount'] ??
          json['quotation_amount'] ??
          json['total'] ??
          json['amount'],
      quoteExpiresAt: json['quote_expires_at']?.toString() ??
          json['expires_at']?.toString(),
      quotedAt: json['quoted_at']?.toString(),
      paymentRequestedAt: json['payment_requested_at']?.toString(),
      rawJson: json,
    );
  }

  String get displayCustomerName {
    if (userName != null && userName!.trim().isNotEmpty) {
      return userName!.trim();
    }
    if (user != null &&
        user!['name'] != null &&
        user!['name'].toString().trim().isNotEmpty) {
      return user!['name'].toString().trim();
    }
    if (userId != null) {
      return 'Customer #$userId';
    }
    return 'Customer';
  }

  String get displayOrderCode {
    if (orderCode != null && orderCode!.trim().isNotEmpty) {
      final code = orderCode!.trim();
      return code.startsWith('#') ? code : '#$code';
    }
    final numId = prescriptionId ?? id;
    if (numId != null) {
      return '#$numId';
    }
    return '#';
  }

  String get displayTimeAgo {
    if (createdAtFormatted != null && createdAtFormatted!.isNotEmpty) {
      return createdAtFormatted!;
    }
    if (placedAtFormatted != null && placedAtFormatted!.isNotEmpty) {
      return placedAtFormatted!;
    }
    final timeStr = createdAt ?? placedAt;
    if (timeStr != null && timeStr.isNotEmpty) {
      return _formatRelativeTime(timeStr);
    }
    return '';
  }

  bool get isSelfPickupBool {
    return isSelfPickup == 1 ||
        isSelfPickup == true ||
        isSelfPickup?.toString() == '1' ||
        isSelfPickup?.toString().toLowerCase() == 'true' ||
        deliveryType?.toString().toLowerCase() == 'pickup';
  }

  PharmacyOrderNotesType get notesType {
    if (note != null && note!.trim().isNotEmpty) {
      return PharmacyOrderNotesType.text;
    }
    return PharmacyOrderNotesType.none;
  }

  static String? _resolveUrl(String? raw) {
    if (raw == null) return null;
    var str = raw.trim();
    if (str.isEmpty) return null;
    str = str.replaceAll(r'\', '/');
    if (str.startsWith('http://') || str.startsWith('https://')) {
      return str;
    }
    if (str.startsWith('//')) {
      return 'https:$str';
    }
    final base = ApiConfigs.IMAGE_URL.trim();
    final uri = Uri.tryParse(base);
    final origin = (uri != null && uri.hasScheme)
        ? '${uri.scheme}://${uri.host}'
        : 'https://dev.saimpexenterprise.com';
    if (str.startsWith('/storage/')) {
      return '$origin$str';
    }
    if (str.startsWith('storage/')) {
      return '$origin/$str';
    }
    if (str.startsWith('/')) {
      final cleanBase =
          base.endsWith('/') ? base.substring(0, base.length - 1) : base;
      return '$cleanBase$str';
    }
    final cleanBase = base.endsWith('/') ? base : '$base/';
    return '$cleanBase$str';
  }

  String get displayFileName {
    if (rawJson != null) {
      final directName = rawJson!['file_name'] ??
          rawJson!['filename'] ??
          rawJson!['original_file_name'] ??
          rawJson!['original_name'] ??
          rawJson!['client_name'];
      if (directName != null && directName.toString().trim().isNotEmpty) {
        return directName.toString().trim();
      }
      final p = rawJson!['prescription'] ?? rawJson!['prescriptions'];
      if (p is Map) {
        final f = p['file_name'] ??
            p['filename'] ??
            p['original_file_name'] ??
            p['original_name'] ??
            p['client_name'];
        if (f != null && f.toString().trim().isNotEmpty) {
          return f.toString().trim();
        }
      }
    }

    if (images is List && (images as List).isNotEmpty) {
      for (final item in (images as List)) {
        if (item is Map) {
          final f = item['file_name'] ??
              item['filename'] ??
              item['original_file_name'] ??
              item['original_name'] ??
              item['name'];
          if (f != null && f.toString().trim().isNotEmpty) {
            return f.toString().trim();
          }
        }
      }
    }

    final imgUrl = displayImageUrl;
    if (imgUrl != null && imgUrl.isNotEmpty) {
      final name = imgUrl.split('?').first.split('/').last;
      if (name.isNotEmpty) return name;
    }
    if (prescriptionImage != null &&
        prescriptionImage is String &&
        prescriptionImage.toString().isNotEmpty) {
      final name = prescriptionImage.toString().split('?').first.split('/').last;
      if (name.isNotEmpty) return name;
    }
    if (images is List && (images as List).isNotEmpty) {
      for (final item in (images as List)) {
        if (item is String && item.isNotEmpty) {
          final name = item.split('?').first.split('/').last;
          if (name.isNotEmpty) return name;
        }
      }
    }
    return 'Prescription';
  }

  String? get displayImageUrl {
    String? raw;
    if (prescriptionImage != null) {
      if (prescriptionImage is String &&
          prescriptionImage.toString().trim().isNotEmpty) {
        raw = prescriptionImage.toString().trim();
      } else if (prescriptionImage is Map) {
        final m = prescriptionImage as Map;
        final v = m['image_path'] ??
            m['url'] ??
            m['file_url'] ??
            m['image'] ??
            m['file_path'] ??
            m['file'] ??
            m['path'];
        if (v != null && v.toString().trim().isNotEmpty) {
          raw = v.toString().trim();
        }
      }
    }
    if (raw == null && images is List && (images as List).isNotEmpty) {
      for (final item in (images as List)) {
        if (item is String && item.trim().isNotEmpty) {
          raw = item.trim();
          break;
        } else if (item is Map) {
          final v = item['image_path'] ??
              item['url'] ??
              item['file_url'] ??
              item['image'] ??
              item['file_path'] ??
              item['file'] ??
              item['path'];
          if (v != null && v.toString().trim().isNotEmpty) {
            raw = v.toString().trim();
            break;
          }
        }
      }
    }
    if (raw == null && rawJson != null) {
      final direct = rawJson!['image_path'] ??
          rawJson!['file_path'] ??
          rawJson!['image'] ??
          rawJson!['prescription_image'] ??
          rawJson!['file'] ??
          rawJson!['file_url'] ??
          rawJson!['image_url'] ??
          rawJson!['url'];
      if (direct != null &&
          direct is String &&
          direct.trim().isNotEmpty) {
        raw = direct.trim();
      } else if (rawJson!['prescription'] is Map) {
        final p = rawJson!['prescription'] as Map;
        final v = p['image_path'] ??
            p['file_path'] ??
            p['image'] ??
            p['prescription_image'] ??
            p['file'] ??
            p['file_url'] ??
            p['url'];
        if (v != null && v.toString().trim().isNotEmpty) {
          raw = v.toString().trim();
        }
      }
    }
    return _resolveUrl(raw);
  }

  String get displayPhone {
    if (contactNumber != null && contactNumber!.isNotEmpty) {
      return contactNumber!;
    }
    if (user != null && user!['mobile'] != null) {
      return user!['mobile'].toString();
    }
    if (user != null && user!['phone'] != null) {
      return user!['phone'].toString();
    }
    return '';
  }

  String get displayQuotationAmount {
    if (quoteAmount != null) {
      final s = quoteAmount.toString().trim();
      if (s.isNotEmpty) {
        if (s.contains('MRU')) return s;
        final numVal = num.tryParse(s);
        if (numVal != null) {
          return '${numVal.toStringAsFixed(2)} MRU';
        }
        return '$s MRU';
      }
    }
    return '';
  }

  String get displayQuotedDate {
    final dtStr = quotedAt ?? paymentRequestedAt ?? createdAt;
    if (dtStr != null && dtStr.trim().isNotEmpty) {
      try {
        DateTime dt = DateTime.tryParse(dtStr) ?? DateTime.now();
        if (dtStr.contains('-') && !dtStr.contains('T')) {
          try {
            dt = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dtStr);
          } catch (_) {}
        }
        dt = dt.toLocal();
        return DateFormat('dd MMM yyyy  ·  hh:mm a').format(dt);
      } catch (_) {
        return dtStr;
      }
    }
    return '';
  }

  String get displayExpiresText {
    if (quoteExpiresAt != null && quoteExpiresAt!.trim().isNotEmpty) {
      try {
        final expStr = quoteExpiresAt!.trim();
        DateTime dt = DateTime.tryParse(expStr) ?? DateTime.now();
        if (expStr.contains('-') && !expStr.contains('T')) {
          try {
            dt = DateFormat("yyyy-MM-dd HH:mm:ss").parse(expStr);
          } catch (_) {}
        }
        dt = dt.toLocal();
        final now = DateTime.now();
        final diff = dt.difference(now);
        if (diff.isNegative) {
          return 'Expired';
        }
        if (diff.inDays > 0) {
          return 'Expires in ${diff.inDays}d';
        }
        if (diff.inHours > 0) {
          return 'Expires in ${diff.inHours}h ${diff.inMinutes % 60}m';
        }
        if (diff.inMinutes > 0) {
          return 'Expires in ${diff.inMinutes} min';
        }
        return 'Expires in < 1 min';
      } catch (_) {
        return 'Expires: $quoteExpiresAt';
      }
    }
    return '';
  }

  static String _formatRelativeTime(String timeStr) {
    try {
      DateTime dt = DateTime.tryParse(timeStr) ?? DateTime.now();
      if (timeStr.contains('-') && !timeStr.contains('T')) {
        try {
          dt = DateFormat("yyyy-MM-dd HH:mm:ss").parse(timeStr);
        } catch (_) {}
      }
      dt = dt.toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('dd MMM, yyyy').format(dt);
    } catch (_) {
      return timeStr;
    }
  }
}
