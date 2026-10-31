import 'package:saimpex_vendor/home_cleaning/controller/cleaning_api.dart';

/// Home cleaning order statuses (vendor_type 9) as used by
/// ServiceVerticalController / VendorScreenData on the backend:
/// 1 new -> 2 accepted -> 8 on the way -> 3 in progress -> 9 completed,
/// 10 cancelled (rejected by vendor while new, or cancelled later).
class CleaningStatus {
  const CleaningStatus._();

  static const int newBooking = 1;
  static const int accepted = 2;
  static const int onTheWay = 8;
  static const int inProgress = 3;
  static const int completed = 9;
  static const int cancelled = 10;

  /// Next status when the server does not send `next_status`.
  static int? fallbackNext(int status) => switch (status) {
        newBooking => accepted,
        accepted => onTheWay,
        onTheWay => inProgress,
        inProgress => completed,
        _ => null,
      };
}

/// The five filter chips on the bookings list.
enum CleaningBookingTab {
  newBookings([CleaningStatus.newBooking]),
  accepted([CleaningStatus.accepted, CleaningStatus.onTheWay]),
  inProgress([CleaningStatus.inProgress]),
  completed([CleaningStatus.completed]),
  cancelled([CleaningStatus.cancelled]);

  const CleaningBookingTab(this.statuses);

  /// Server `status` values shown under this chip.
  final List<int> statuses;
}

class CleaningBookingLine {
  const CleaningBookingLine({
    required this.kind,
    required this.name,
    required this.quantity,
    required this.price,
    this.unit,
  });

  /// space | addon | issue | property | supply | distance | garment
  final String kind;
  final String name;
  final int quantity;

  /// Unit price; the line total is price x quantity.
  final double price;
  final String? unit;

  double get lineTotal => price * quantity;
  bool get isSpace => kind == 'space';
  bool get isAddon => kind == 'addon';
  bool get isSupply => kind == 'supply';

  factory CleaningBookingLine.fromJson(Map<String, dynamic> json) {
    return CleaningBookingLine(
      kind: (json['kind'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      quantity: _int(json['quantity']) ?? 1,
      price: _double(json['price']) ?? 0,
      unit: _str(json['unit']),
    );
  }
}

class CleaningBooking {
  const CleaningBooking({
    required this.id,
    required this.status,
    this.orderCode,
    this.customerName,
    this.customerPhone,
    this.serviceEn,
    this.serviceFr,
    this.serviceAr,
    this.lines = const [],
    this.summary,
    this.scheduledFor,
    this.slotEnd,
    this.slotWindow,
    this.createdAt,
    this.address,
    this.latitude,
    this.longitude,
    this.notes,
    this.subtotal,
    this.tax,
    this.total,
    this.totalPaid,
    this.paymentType,
    this.paymentStatus,
    this.paidOn,
    this.nextStatus,
    this.canReject = false,
    this.rejectReason,
    this.rejectNote,
  });

  final int id;
  final int status;
  final String? orderCode;
  final String? customerName;
  final String? customerPhone;
  final String? serviceEn;
  final String? serviceFr;
  final String? serviceAr;
  final List<CleaningBookingLine> lines;
  final String? summary;
  final DateTime? scheduledFor;
  final DateTime? slotEnd;

  /// Server-formatted window (English), used only when dates fail to parse.
  final String? slotWindow;
  final DateTime? createdAt;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final double? subtotal;
  final double? tax;
  final double? total;
  final double? totalPaid;

  /// 1 cash, 2 online (orders.payment_type).
  final String? paymentType;

  /// 2 = paid.
  final int? paymentStatus;
  final DateTime? paidOn;
  final int? nextStatus;
  final bool canReject;
  final String? rejectReason;
  final String? rejectNote;

  bool get isNew => status == CleaningStatus.newBooking;
  bool get isAccepted =>
      status == CleaningStatus.accepted || status == CleaningStatus.onTheWay;
  bool get isOnTheWay => status == CleaningStatus.onTheWay;
  bool get isInProgress => status == CleaningStatus.inProgress;
  bool get isCompleted => status == CleaningStatus.completed;
  bool get isCancelled => status == CleaningStatus.cancelled;
  bool get isPaid => paymentStatus == 2;

  int? get resolvedNextStatus => nextStatus ?? CleaningStatus.fallbackNext(status);

  String get displayCode {
    final code = orderCode?.trim();
    if (code == null || code.isEmpty) return '#$id';
    return code.startsWith('#') ? code : '#$code';
  }

  String get displayName {
    final n = customerName?.trim();
    return (n == null || n.isEmpty) ? '' : n;
  }

  String get initial {
    final n = displayName;
    return n.isEmpty ? '?' : String.fromCharCode(n.runes.first).toUpperCase();
  }

  String? get serviceName {
    final lang = CleaningApi.languageCode;
    final localized = switch (lang) {
      'fr' => serviceFr,
      'ar' => serviceAr,
      _ => serviceEn,
    };
    final v = (localized?.trim().isNotEmpty ?? false) ? localized : serviceEn;
    return (v?.trim().isNotEmpty ?? false) ? v!.trim() : null;
  }

  /// Chips on the list card: everything the customer picked except the
  /// product-supply fee line.
  List<CleaningBookingLine> get chipLines =>
      lines.where((l) => !l.isSupply && l.name.trim().isNotEmpty).toList();

  List<CleaningBookingLine> get spaceLines => lines.where((l) => l.isSpace).toList();
  List<CleaningBookingLine> get addonLines => lines.where((l) => l.isAddon).toList();
  CleaningBookingLine? get supplyLine {
    for (final l in lines) {
      if (l.isSupply) return l;
    }
    return null;
  }

  factory CleaningBooking.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'];
    return CleaningBooking(
      id: _int(json['order_id']) ?? _int(json['id']) ?? 0,
      status: _int(json['status']) ?? 0,
      orderCode: _str(json['order_code']) ?? _str(json['request_id']),
      customerName: _str(json['customer_name']) ?? _str(json['customer']),
      customerPhone: _str(json['customer_phone']) ??
          _str(json['customer_mobile']) ??
          _str(json['phone']),
      serviceEn: _str(json['service_name_en']) ?? _str(json['service']),
      serviceFr: _str(json['service_name_fr']),
      serviceAr: _str(json['service_name_ar']),
      lines: rawLines is List
          ? rawLines
              .whereType<Map>()
              .map((e) => CleaningBookingLine.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      summary: _str(json['summary']),
      scheduledFor: _date(json['scheduled_for']),
      slotEnd: _date(json['slot_end']),
      slotWindow: _str(json['slot_window']) ?? _str(json['slot']),
      createdAt: _date(json['created_at']) ?? _date(json['placed_at']),
      address: _str(json['address']) ?? _str(json['location']),
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      notes: _str(json['notes']),
      subtotal: _double(json['subtotal']),
      tax: _double(json['tax']),
      total: _double(json['total']) ?? _double(json['amount']),
      totalPaid: _double(json['total_paid']) ?? _double(json['paid']),
      paymentType: _str(json['payment_type']),
      paymentStatus: _int(json['payment_status']),
      paidOn: _date(json['paid_on']) ?? _date(json['payment_on']),
      nextStatus: _int(json['next_status']),
      canReject: json['can_reject'] == true || json['can_reject'].toString() == '1',
      rejectReason: _str(json['reject_reason']),
      rejectNote: _str(json['reject_note']),
    );
  }
}

/// Numbers from GET serviceDashboard used on the home header.
class CleaningDashboard {
  const CleaningDashboard({
    required this.statusCounts,
    this.totalBookings,
    this.completed,
    this.todayBookings,
    this.upcoming,
    this.inProgress,
    this.revenue,
    this.isOpen,
    this.acceptingBookings,
    this.todayHours,
  });

  /// Raw `status_mix` (status -> count).
  final Map<int, int> statusCounts;
  final int? totalBookings;
  final int? completed;
  final int? todayBookings;
  final int? upcoming;
  final int? inProgress;
  final double? revenue;
  final bool? isOpen;
  final bool? acceptingBookings;
  final String? todayHours;

  int countFor(CleaningBookingTab tab) =>
      tab.statuses.fold(0, (sum, s) => sum + (statusCounts[s] ?? 0));

  factory CleaningDashboard.fromJson(Map<String, dynamic> json) {
    final counts = <int, int>{};
    final mix = json['status_mix'];
    if (mix is Map) {
      mix.forEach((k, v) {
        final s = int.tryParse(k.toString());
        final c = _int(v);
        if (s != null && c != null) counts[s] = c;
      });
    }
    final screen = json['screen'] is Map
        ? Map<String, dynamic>.from(json['screen'] as Map)
        : <String, dynamic>{};
    final kpis = screen['kpis'] is Map
        ? Map<String, dynamic>.from(screen['kpis'] as Map)
        : <String, dynamic>{};
    final welcome = screen['welcome'] is Map
        ? Map<String, dynamic>.from(screen['welcome'] as Map)
        : <String, dynamic>{};
    final glance = screen['at_a_glance'] is Map
        ? Map<String, dynamic>.from(screen['at_a_glance'] as Map)
        : <String, dynamic>{};

    return CleaningDashboard(
      statusCounts: counts,
      totalBookings: _int(json['orders']),
      completed: _int(json['completed']),
      todayBookings: _int(kpis['today_bookings']) ?? _int(kpis['today']),
      upcoming: _int(kpis['upcoming']),
      inProgress: _int(kpis['in_progress']),
      revenue: _double(kpis['revenue']) ?? _double(glance['revenue']),
      isOpen: _bool(welcome['is_open']),
      acceptingBookings: _bool(welcome['accepting_orders']),
      todayHours: _str(welcome['today_hours']),
    );
  }
}

/// `membership` block from GET home (subscriptions joined on vendors).
class CleaningMembership {
  const CleaningMembership({this.nameEn, this.nameFr, this.nameAr, this.expiresInDays});

  final String? nameEn;
  final String? nameFr;
  final String? nameAr;
  final int? expiresInDays;

  String? get name {
    final localized = switch (CleaningApi.languageCode) {
      'fr' => nameFr,
      'ar' => nameAr,
      _ => nameEn,
    };
    final v = (localized?.trim().isNotEmpty ?? false) ? localized : nameEn;
    return (v?.trim().isNotEmpty ?? false) ? v!.trim() : null;
  }

  static CleaningMembership? fromJson(dynamic json) {
    if (json is! Map) return null;
    final m = CleaningMembership(
      nameEn: _str(json['name_en']),
      nameFr: _str(json['name_fr']),
      nameAr: _str(json['name_ar']),
      expiresInDays: _int(json['expires_in_days']),
    );
    return m.name == null ? null : m;
  }
}

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return (s.isEmpty || s == 'null') ? null : s;
}

int? _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  final s = _str(v);
  if (s == null) return null;
  return int.tryParse(s) ?? double.tryParse(s)?.toInt();
}

double? _double(dynamic v) {
  if (v is num) return v.toDouble();
  final s = _str(v);
  return s == null ? null : double.tryParse(s);
}

bool? _bool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v == 1;
  final s = _str(v)?.toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return null;
}

DateTime? _date(dynamic v) {
  final s = _str(v);
  return s == null ? null : DateTime.tryParse(s);
}
