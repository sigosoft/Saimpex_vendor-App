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
      prescriptionImage:
          json['prescription_image'] ?? json['image'] ?? json['file'],
      isSelfPickup: json['is_self_pickup'] ?? json['isSelfPickup'],
      deliveryType: json['delivery_type'] ?? json['deliveryType'],
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

  String get displayFileName {
    if (prescriptionImage != null &&
        prescriptionImage is String &&
        prescriptionImage.toString().isNotEmpty) {
      final name = prescriptionImage.toString().split('/').last;
      if (name.isNotEmpty) return name;
    }
    if (images is List && (images as List).isNotEmpty) {
      final first = (images as List).first?.toString();
      if (first != null && first.isNotEmpty) {
        final name = first.split('/').last;
        if (name.isNotEmpty) return name;
      }
    }
    final numId = prescriptionId ?? id;
    return numId != null ? 'Prescription_#$numId.jpg' : 'Prescription.jpg';
  }

  String? get displayImageUrl {
    if (prescriptionImage != null &&
        prescriptionImage is String &&
        prescriptionImage.toString().isNotEmpty) {
      final img = prescriptionImage.toString();
      return img.startsWith('http') ? img : '${ApiConfigs.IMAGE_URL}$img';
    }
    if (images is List && (images as List).isNotEmpty) {
      final first = (images as List).first?.toString();
      if (first != null && first.isNotEmpty) {
        return first.startsWith('http')
            ? first
            : '${ApiConfigs.IMAGE_URL}$first';
      }
    }
    return null;
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
