import 'package:saimpex_vendor/utils/payment_type.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';

class PharmacyOrderDetailModel {
  bool? status;
  PharmacyOrderDetailData? data;
  String? message;

  PharmacyOrderDetailModel({this.status, this.data, this.message});

  PharmacyOrderDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] == true || json['status']?.toString() == 'true';
    message = json['message']?.toString();
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      data = PharmacyOrderDetailData.fromJson(
        json['data'] as Map<String, dynamic>,
      );
    } else if (json['data'] != null && json['data'] is Map) {
      data = PharmacyOrderDetailData.fromJson(
        Map<String, dynamic>.from(json['data'] as Map),
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> res = {};
    res['status'] = status;
    res['message'] = message;
    if (data != null) {
      res['data'] = data!.toJson();
    }
    return res;
  }
}

class PharmacyOrderDetailData {
  PharmacyOrderDetailOrder? order;
  List<PharmacyOrderItem> items = [];
  List<PharmacyOrderStatusLog> statusLogs = [];

  PharmacyOrderDetailData({
    this.order,
    this.items = const [],
    this.statusLogs = const [],
  });

  PharmacyOrderDetailData.fromJson(Map<String, dynamic> json) {
    if (json['order'] != null && json['order'] is Map) {
      order = PharmacyOrderDetailOrder.fromJson(
        Map<String, dynamic>.from(json['order'] as Map),
      );
    }
    if (json['items'] != null && json['items'] is List) {
      items = (json['items'] as List)
          .map(
            (e) => PharmacyOrderItem.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    }
    if (json['status_logs'] != null && json['status_logs'] is List) {
      statusLogs = (json['status_logs'] as List)
          .map(
            (e) => PharmacyOrderStatusLog.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> res = {};
    if (order != null) {
      res['order'] = order!.toJson();
    }
    res['items'] = items.map((v) => v.toJson()).toList();
    res['status_logs'] = statusLogs.map((v) => v.toJson()).toList();
    return res;
  }
}

class PharmacyOrderDetailOrder {
  int? id;
  String? orderCode;
  int? customerType;
  int? userId;
  int? vendorId;
  int? deliveryBoyId;
  int? orderType;
  String? type;
  int? source;
  String? subtotal;
  String? discount;
  String? couponCode;
  String? deliveryFee;
  String? tax;
  String? total;
  dynamic paymentStatus;
  dynamic isCreditSale;
  dynamic paymentType;
  dynamic paymentId;
  String? notes;
  String? orderNote;
  String? location;
  String? latitude;
  String? longitude;
  int? status;
  String? placedAt;
  String? scheduledFor;
  String? deliveredAt;
  String? cancelledAt;
  String? cancelledReason;
  String? distanceKm;
  int? deliveryType;
  dynamic isSelfPickup;
  String? createdAt;
  String? updatedAt;
  String? customerName;
  String? customerMobile;
  String? customerEmail;
  String? customerAddress;

  PharmacyOrderDetailOrder({
    this.id,
    this.orderCode,
    this.customerType,
    this.userId,
    this.vendorId,
    this.deliveryBoyId,
    this.orderType,
    this.type,
    this.source,
    this.subtotal,
    this.discount,
    this.couponCode,
    this.deliveryFee,
    this.tax,
    this.total,
    this.paymentStatus,
    this.isCreditSale,
    this.paymentType,
    this.paymentId,
    this.notes,
    this.orderNote,
    this.location,
    this.latitude,
    this.longitude,
    this.status,
    this.placedAt,
    this.scheduledFor,
    this.deliveredAt,
    this.cancelledAt,
    this.cancelledReason,
    this.distanceKm,
    this.deliveryType,
    this.isSelfPickup,
    this.createdAt,
    this.updatedAt,
    this.customerName,
    this.customerMobile,
    this.customerEmail,
    this.customerAddress,
  });

  PharmacyOrderDetailOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int
        ? json['id']
        : int.tryParse(json['id']?.toString() ?? '');
    orderCode = json['order_code']?.toString();
    customerType = json['customer_type'] is int
        ? json['customer_type']
        : int.tryParse(json['customer_type']?.toString() ?? '');
    userId = json['user_id'] is int
        ? json['user_id']
        : int.tryParse(json['user_id']?.toString() ?? '');
    vendorId = json['vendor_id'] is int
        ? json['vendor_id']
        : int.tryParse(json['vendor_id']?.toString() ?? '');
    deliveryBoyId = json['delivery_boy_id'] is int
        ? json['delivery_boy_id']
        : int.tryParse(json['delivery_boy_id']?.toString() ?? '');
    orderType = json['order_type'] is int
        ? json['order_type']
        : int.tryParse(json['order_type']?.toString() ?? '');
    type = json['type']?.toString();
    source = json['source'] is int
        ? json['source']
        : int.tryParse(json['source']?.toString() ?? '');
    subtotal = json['subtotal']?.toString();
    discount = json['discount']?.toString();
    couponCode = json['coupon_code']?.toString();
    deliveryFee = json['delivery_fee']?.toString();
    tax = json['tax']?.toString();
    total = json['total']?.toString();
    paymentStatus = json['payment_status'];
    isCreditSale = json['is_credit_sale'];
    paymentType = json['payment_type'];
    paymentId = json['payment_id'];
    notes = json['notes']?.toString();
    orderNote = json['order_note']?.toString();
    location = json['location']?.toString();
    latitude = json['latitude']?.toString();
    longitude = json['longitude']?.toString();
    status = json['status'] is int
        ? json['status']
        : int.tryParse(json['status']?.toString() ?? '');
    placedAt = json['placed_at']?.toString();
    scheduledFor = json['scheduled_for']?.toString();
    deliveredAt = json['delivered_at']?.toString();
    cancelledAt = json['cancelled_at']?.toString();
    cancelledReason = json['cancelled_reason']?.toString();
    distanceKm = json['distance_km']?.toString();
    deliveryType = json['delivery_type'] is int
        ? json['delivery_type']
        : int.tryParse(json['delivery_type']?.toString() ?? '');
    isSelfPickup = json['is_self_pickup'];
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    customerName = json['customer_name']?.toString();
    customerMobile = json['customer_mobile']?.toString();
    customerEmail = json['customer_email']?.toString();
    customerAddress = json['customer_address']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> res = {};
    res['id'] = id;
    res['order_code'] = orderCode;
    res['customer_type'] = customerType;
    res['user_id'] = userId;
    res['vendor_id'] = vendorId;
    res['delivery_boy_id'] = deliveryBoyId;
    res['order_type'] = orderType;
    res['type'] = type;
    res['source'] = source;
    res['subtotal'] = subtotal;
    res['discount'] = discount;
    res['coupon_code'] = couponCode;
    res['delivery_fee'] = deliveryFee;
    res['tax'] = tax;
    res['total'] = total;
    res['payment_status'] = paymentStatus;
    res['is_credit_sale'] = isCreditSale;
    res['payment_type'] = paymentType;
    res['payment_id'] = paymentId;
    res['notes'] = notes;
    res['order_note'] = orderNote;
    res['location'] = location;
    res['latitude'] = latitude;
    res['longitude'] = longitude;
    res['status'] = status;
    res['placed_at'] = placedAt;
    res['scheduled_for'] = scheduledFor;
    res['delivered_at'] = deliveredAt;
    res['cancelled_at'] = cancelledAt;
    res['cancelled_reason'] = cancelledReason;
    res['distance_km'] = distanceKm;
    res['delivery_type'] = deliveryType;
    res['is_self_pickup'] = isSelfPickup;
    res['created_at'] = createdAt;
    res['updated_at'] = updatedAt;
    res['customer_name'] = customerName;
    res['customer_mobile'] = customerMobile;
    res['customer_email'] = customerEmail;
    res['customer_address'] = customerAddress;
    return res;
  }

  bool get isSelfPickupBool {
    return isSelfPickup == 1 ||
        isSelfPickup == true ||
        isSelfPickup?.toString() == '1' ||
        isSelfPickup?.toString().toLowerCase() == 'true';
  }

  bool get isCashOnDeliveryBool => isCashPayment(paymentType);

  String get displayOrderCode {
    if (orderCode != null && orderCode!.trim().isNotEmpty) {
      return orderCode!.startsWith('#') ? orderCode! : '#$orderCode';
    }
    return id != null ? '#$id' : '';
  }

  String get displayCustomerName =>
      (customerName != null && customerName!.trim().isNotEmpty)
          ? customerName!
          : 'Customer';

  String get displayCustomerMobile =>
      (customerMobile != null && customerMobile!.trim().isNotEmpty)
          ? customerMobile!
          : '';

  String get displayLocation =>
      (location != null && location!.trim().isNotEmpty)
          ? location!
          : (customerAddress ?? '');
}

class PharmacyOrderItem {
  int? id;
  int? orderId;
  int? orderType;
  int? productId;
  int? quantity;
  int? returnedQuantity;
  String? returnReason;
  dynamic saleUnit;
  String? saleUnitName;
  String? unitPrice;
  String? totalPrice;
  String? discountAmount;
  String? discountType;
  String? taxAmount;
  String? createdAt;
  String? updatedAt;
  int? menuId;
  String? nameEn;
  String? nameAr;
  String? nameFr;
  String? image;
  String? attributeValue;
  List<String>? images;

  PharmacyOrderItem({
    this.id,
    this.orderId,
    this.orderType,
    this.productId,
    this.quantity,
    this.returnedQuantity,
    this.returnReason,
    this.saleUnit,
    this.saleUnitName,
    this.unitPrice,
    this.totalPrice,
    this.discountAmount,
    this.discountType,
    this.taxAmount,
    this.createdAt,
    this.updatedAt,
    this.menuId,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.image,
    this.attributeValue,
    this.images,
  });

  PharmacyOrderItem.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int
        ? json['id']
        : int.tryParse(json['id']?.toString() ?? '');
    orderId = json['order_id'] is int
        ? json['order_id']
        : int.tryParse(json['order_id']?.toString() ?? '');
    orderType = json['order_type'] is int
        ? json['order_type']
        : int.tryParse(json['order_type']?.toString() ?? '');
    productId = json['product_id'] is int
        ? json['product_id']
        : int.tryParse(json['product_id']?.toString() ?? '');
    quantity = json['quantity'] is int
        ? json['quantity']
        : int.tryParse(json['quantity']?.toString() ?? '');
    returnedQuantity = json['returned_quantity'] is int
        ? json['returned_quantity']
        : int.tryParse(json['returned_quantity']?.toString() ?? '');
    returnReason = json['return_reason']?.toString();
    saleUnit = json['sale_unit'];
    saleUnitName = json['sale_unit_name']?.toString();
    unitPrice = json['unit_price']?.toString();
    totalPrice = json['total_price']?.toString();
    discountAmount = json['discount_amount']?.toString();
    discountType = json['discount_type']?.toString();
    taxAmount = json['tax_amount']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    menuId = json['menu_id'] is int
        ? json['menu_id']
        : int.tryParse(json['menu_id']?.toString() ?? '');
    nameEn = json['name_en']?.toString();
    nameAr = json['name_ar']?.toString();
    nameFr = json['name_fr']?.toString();
    image = json['image']?.toString();
    attributeValue = json['attribute_value']?.toString();
    if (json['images'] is List) {
      images = (json['images'] as List).map((e) => e.toString()).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> res = {};
    res['id'] = id;
    res['order_id'] = orderId;
    res['order_type'] = orderType;
    res['product_id'] = productId;
    res['quantity'] = quantity;
    res['returned_quantity'] = returnedQuantity;
    res['return_reason'] = returnReason;
    res['sale_unit'] = saleUnit;
    res['sale_unit_name'] = saleUnitName;
    res['unit_price'] = unitPrice;
    res['total_price'] = totalPrice;
    res['discount_amount'] = discountAmount;
    res['discount_type'] = discountType;
    res['tax_amount'] = taxAmount;
    res['created_at'] = createdAt;
    res['updated_at'] = updatedAt;
    res['menu_id'] = menuId;
    res['name_en'] = nameEn;
    res['name_ar'] = nameAr;
    res['name_fr'] = nameFr;
    res['image'] = image;
    res['attribute_value'] = attributeValue;
    res['images'] = images;
    return res;
  }

  String get displayName {
    if (nameEn != null && nameEn!.trim().isNotEmpty) return nameEn!;
    if (nameAr != null && nameAr!.trim().isNotEmpty) return nameAr!;
    if (nameFr != null && nameFr!.trim().isNotEmpty) return nameFr!;
    return 'Item';
  }

  String? get displayImageUrl {
    final img = (image != null && image!.trim().isNotEmpty)
        ? image!
        : (images?.isNotEmpty == true ? images!.first : null);
    if (img == null || img.trim().isEmpty) return null;
    if (img.startsWith('http://') || img.startsWith('https://')) return img;
    return '${ApiConfigs.IMAGE_URL}$img';
  }
}

class PharmacyOrderStatusLog {
  int? id;
  int? orderId;
  int? status;
  int? updatedBy;
  String? remark;
  String? createdAt;
  String? updatedAt;

  PharmacyOrderStatusLog({
    this.id,
    this.orderId,
    this.status,
    this.updatedBy,
    this.remark,
    this.createdAt,
    this.updatedAt,
  });

  PharmacyOrderStatusLog.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int
        ? json['id']
        : int.tryParse(json['id']?.toString() ?? '');
    orderId = json['order_id'] is int
        ? json['order_id']
        : int.tryParse(json['order_id']?.toString() ?? '');
    status = json['status'] is int
        ? json['status']
        : int.tryParse(json['status']?.toString() ?? '');
    updatedBy = json['updated_by'] is int
        ? json['updated_by']
        : int.tryParse(json['updated_by']?.toString() ?? '');
    remark = json['remark']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> res = {};
    res['id'] = id;
    res['order_id'] = orderId;
    res['status'] = status;
    res['updated_by'] = updatedBy;
    res['remark'] = remark;
    res['created_at'] = createdAt;
    res['updated_at'] = updatedAt;
    return res;
  }
}
