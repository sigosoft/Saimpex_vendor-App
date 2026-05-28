/// Parses backend delivery / self-pickup values from order list and detail APIs.
class OrderFulfillment {
  const OrderFulfillment._();

  /// Customer app sends [is_self_pickup] = 1 for self pickup; also supports
  /// [delivery_type] and string variants from older APIs.
  static bool isSelfPickupFrom({
    dynamic deliveryType,
    dynamic isSelfPickup,
  }) {
    if (_isTruthyOne(isSelfPickup)) return true;
    return _isSelfPickupFromDeliveryType(deliveryType);
  }

  static bool isDeliveryFrom({
    dynamic deliveryType,
    dynamic isSelfPickup,
  }) {
    if (isSelfPickupFrom(
      deliveryType: deliveryType,
      isSelfPickup: isSelfPickup,
    )) {
      return false;
    }
    return _isDeliveryFromDeliveryType(deliveryType);
  }

  /// @deprecated Prefer [isSelfPickupFrom].
  static bool isSelfPickup(dynamic deliveryType) =>
      _isSelfPickupFromDeliveryType(deliveryType);

  /// @deprecated Prefer [isDeliveryFrom].
  static bool isDelivery(dynamic deliveryType) =>
      _isDeliveryFromDeliveryType(deliveryType);

  static bool _isTruthyOne(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is num) return value.toInt() == 1;
    final normalized = value.toString().trim().toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }

  static bool _isSelfPickupFromDeliveryType(dynamic deliveryType) {
    if (deliveryType == null) return false;
    if (deliveryType is int) {
      return deliveryType == 2;
    }
    if (deliveryType is num) {
      return deliveryType.toInt() == 2;
    }
    final normalized = deliveryType.toString().trim().toLowerCase();
    if (normalized.isEmpty) return false;
    if (normalized == '2') return true;
    return (normalized.contains('self') && normalized.contains('pickup')) ||
        normalized == 'self_pickup' ||
        normalized == 'selfpickup' ||
        normalized == 'pickup' ||
        normalized == 'takeaway' ||
        normalized == 'take_away';
  }

  static bool _isDeliveryFromDeliveryType(dynamic deliveryType) {
    if (deliveryType == null) return true;
    if (_isSelfPickupFromDeliveryType(deliveryType)) return false;
    if (deliveryType is int) {
      return deliveryType == 1;
    }
    if (deliveryType is num) {
      return deliveryType.toInt() == 1;
    }
    final normalized = deliveryType.toString().trim().toLowerCase();
    if (normalized.isEmpty) return true;
    if (normalized == '1') return true;
    return normalized.contains('delivery');
  }
}
