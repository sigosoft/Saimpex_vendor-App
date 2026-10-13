import 'package:saimpex_vendor/configs/ApiConfigs.dart';

class PharmacyPrescriptionDetailModel {
  final bool? status;
  final PharmacyPrescriptionDetailData? data;
  final String? message;

  PharmacyPrescriptionDetailModel({
    this.status,
    this.data,
    this.message,
  });

  factory PharmacyPrescriptionDetailModel.fromJson(Map<String, dynamic> json) {
    return PharmacyPrescriptionDetailModel(
      status: json['status'] == true || json['status'].toString() == 'true',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? PharmacyPrescriptionDetailData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : json['data'] != null && json['data'] is Map
              ? PharmacyPrescriptionDetailData.fromJson(
                  Map<String, dynamic>.from(json['data'] as Map),
                )
              : null,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
      'message': message,
    };
  }
}

class PharmacyPrescriptionDetailData {
  final PharmacyPrescriptionDetailPrescription? prescription;
  final List<PharmacyPrescriptionImage> images;
  final List<PharmacyPrescriptionQuoteItem> quoteItems;

  PharmacyPrescriptionDetailData({
    this.prescription,
    this.images = const [],
    this.quoteItems = const [],
  });

  factory PharmacyPrescriptionDetailData.fromJson(Map<String, dynamic> json) {
    List<PharmacyPrescriptionImage> parsedImages = [];
    if (json['images'] is List) {
      for (final e in (json['images'] as List)) {
        if (e is Map) {
          parsedImages.add(
            PharmacyPrescriptionImage.fromJson(
              Map<String, dynamic>.from(e),
            ),
          );
        } else if (e is String && e.trim().isNotEmpty) {
          parsedImages.add(PharmacyPrescriptionImage(imagePath: e.trim()));
        }
      }
    }

    if (parsedImages.isEmpty && json['image_path'] != null) {
      parsedImages.add(
        PharmacyPrescriptionImage(
          imagePath: json['image_path'].toString(),
        ),
      );
    }

    List<PharmacyPrescriptionQuoteItem> parsedQuoteItems = [];
    if (json['quote_items'] is List) {
      parsedQuoteItems = (json['quote_items'] as List)
          .whereType<Map>()
          .map(
            (e) => PharmacyPrescriptionQuoteItem.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    }

    return PharmacyPrescriptionDetailData(
      prescription: json['prescription'] != null && json['prescription'] is Map
          ? PharmacyPrescriptionDetailPrescription.fromJson(
              Map<String, dynamic>.from(json['prescription'] as Map),
            )
          : null,
      images: parsedImages,
      quoteItems: parsedQuoteItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescription': prescription?.toJson(),
      'images': images.map((e) => e.toJson()).toList(),
      'quote_items': quoteItems.map((e) => e.toJson()).toList(),
    };
  }

  String? get primaryImageUrl {
    if (images.isNotEmpty) {
      final first = images.first.fullImageUrl;
      if (first != null && first.isNotEmpty) return first;
    }
    return null;
  }
}

class PharmacyPrescriptionDetailPrescription {
  final int? prescriptionId;
  final int? userId;
  final int? pharmacyId;
  final String? flowType;
  final String? status;
  final String? note;
  final int? callBeforeAlternative;
  final String? contactNumber;
  final String? quoteAmount;
  final String? quoteExpiresAt;
  final String? quotedAt;
  final String? paymentRequestedAt;
  final String? acceptedAt;
  final int? orderId;
  final String? createdAt;
  final String? customerName;
  final String? customerMobile;
  final String? customerEmail;

  PharmacyPrescriptionDetailPrescription({
    this.prescriptionId,
    this.userId,
    this.pharmacyId,
    this.flowType,
    this.status,
    this.note,
    this.callBeforeAlternative,
    this.contactNumber,
    this.quoteAmount,
    this.quoteExpiresAt,
    this.quotedAt,
    this.paymentRequestedAt,
    this.acceptedAt,
    this.orderId,
    this.createdAt,
    this.customerName,
    this.customerMobile,
    this.customerEmail,
  });

  factory PharmacyPrescriptionDetailPrescription.fromJson(
    Map<String, dynamic> json,
  ) {
    return PharmacyPrescriptionDetailPrescription(
      prescriptionId: json['prescription_id'] is int
          ? json['prescription_id'] as int
          : int.tryParse(json['prescription_id']?.toString() ?? ''),
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ?? ''),
      pharmacyId: json['pharmacy_id'] is int
          ? json['pharmacy_id'] as int
          : int.tryParse(json['pharmacy_id']?.toString() ?? ''),
      flowType: json['flow_type']?.toString(),
      status: json['status']?.toString(),
      note: json['note']?.toString(),
      callBeforeAlternative: json['call_before_alternative'] is int
          ? json['call_before_alternative'] as int
          : int.tryParse(json['call_before_alternative']?.toString() ?? ''),
      contactNumber: json['contact_number']?.toString(),
      quoteAmount: json['quote_amount']?.toString(),
      quoteExpiresAt: json['quote_expires_at']?.toString(),
      quotedAt: json['quoted_at']?.toString(),
      paymentRequestedAt: json['payment_requested_at']?.toString(),
      acceptedAt: json['accepted_at']?.toString(),
      orderId: json['order_id'] is int
          ? json['order_id'] as int
          : int.tryParse(json['order_id']?.toString() ?? ''),
      createdAt: json['created_at']?.toString(),
      customerName: json['customer_name']?.toString(),
      customerMobile: json['customer_mobile']?.toString(),
      customerEmail: json['customer_email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescription_id': prescriptionId,
      'user_id': userId,
      'pharmacy_id': pharmacyId,
      'flow_type': flowType,
      'status': status,
      'note': note,
      'call_before_alternative': callBeforeAlternative,
      'contact_number': contactNumber,
      'quote_amount': quoteAmount,
      'quote_expires_at': quoteExpiresAt,
      'quoted_at': quotedAt,
      'payment_requested_at': paymentRequestedAt,
      'accepted_at': acceptedAt,
      'order_id': orderId,
      'created_at': createdAt,
      'customer_name': customerName,
      'customer_mobile': customerMobile,
      'customer_email': customerEmail,
    };
  }

  String get displayCustomerName =>
      customerName?.isNotEmpty == true ? customerName! : 'Customer';

  String get displayPhone => customerMobile?.isNotEmpty == true
      ? customerMobile!
      : (contactNumber?.isNotEmpty == true ? contactNumber! : '');

  String get displayOrderCode =>
      prescriptionId != null ? '#$prescriptionId' : '';
}

class PharmacyPrescriptionImage {
  final int? id;
  final String? imagePath;
  final int? sortOrder;

  PharmacyPrescriptionImage({
    this.id,
    this.imagePath,
    this.sortOrder,
  });

  factory PharmacyPrescriptionImage.fromJson(Map<String, dynamic> json) {
    return PharmacyPrescriptionImage(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      imagePath: json['image_path']?.toString(),
      sortOrder: json['sort_order'] is int
          ? json['sort_order'] as int
          : int.tryParse(json['sort_order']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_path': imagePath,
      'sort_order': sortOrder,
    };
  }

  String? get fullImageUrl {
    if (imagePath == null || imagePath!.trim().isEmpty) return null;
    final path = imagePath!.trim();
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final base = ApiConfigs.IMAGE_URL.trim();
    final cleanBase = base.endsWith('/') ? base : '$base/';
    var cleanPath = path.startsWith('/') ? path.substring(1) : path;
    if (cleanBase.endsWith('storage/') && cleanPath.startsWith('storage/')) {
      cleanPath = cleanPath.substring(8);
    }
    return '$cleanBase$cleanPath';
  }
}

class PharmacyPrescriptionQuoteItem {
  final int? id;
  final String? name;
  final String? quantity;
  final String? price;
  final String? instruction;

  PharmacyPrescriptionQuoteItem({
    this.id,
    this.name,
    this.quantity,
    this.price,
    this.instruction,
  });

  factory PharmacyPrescriptionQuoteItem.fromJson(Map<String, dynamic> json) {
    return PharmacyPrescriptionQuoteItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? json['item_name']?.toString(),
      quantity: json['quantity']?.toString(),
      price: json['price']?.toString() ?? json['unit_price']?.toString(),
      instruction: json['instruction']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'instruction': instruction,
    };
  }
}
