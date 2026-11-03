/// Counts may come as numbers or strings ("8", 8.0). A plain cast threw on
/// those, so the whole dashboard failed to parse and showed 0 everywhere.
int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  final s = v.toString().trim();
  return int.tryParse(s) ?? double.tryParse(s)?.toInt();
}

class DashboardModel {
  bool? status;
  DashboardData? data;

  DashboardModel({this.status, this.data});

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      status: json['status'] == true || json['status'] == 'true',
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
    );
  }
}

class DashboardData {
  SubscriptionDetails? subscriptionDetails;
  int? totalOrders;
  int? todayOrders;
  int? totalProducts;
  String? revenueTotal;
  String? revenueYearTotal;
  List<double>? revenueReport;
  List<PopularItem>? popularItems;

  DashboardData({
    this.subscriptionDetails,
    this.totalOrders,
    this.todayOrders,
    this.totalProducts,
    this.revenueTotal,
    this.revenueYearTotal,
    this.revenueReport,
    this.popularItems,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    List<double> report = [];
    if (json['revenue_report'] != null) {
      for (var v in (json['revenue_report'] as List)) {
        report.add(double.tryParse(v.toString()) ?? 0.0);
      }
    }
    return DashboardData(
      subscriptionDetails: json['subscription_details'] != null
          ? SubscriptionDetails.fromJson(json['subscription_details'])
          : null,
      totalOrders: _toInt(json['total_orders']),
      todayOrders: _toInt(json['today_orders']),
      totalProducts: _toInt(json['total_products']),
      revenueTotal: json['revenue_total']?.toString(),
      revenueYearTotal: json['revenue_year_total']?.toString(),
      revenueReport: report,
      popularItems: json['popular_items'] != null
          ? (json['popular_items'] as List)
                .map((e) => PopularItem.fromJson(e))
                .toList()
          : [],
    );
  }
}

class SubscriptionDetails {
  int? subscriptionId;
  String? subscriptionEndDate;
  String? nameEn;
  String? nameFr;
  String? nameAr;

  SubscriptionDetails({
    this.subscriptionId,
    this.subscriptionEndDate,
    this.nameEn,
    this.nameFr,
    this.nameAr,
  });

  factory SubscriptionDetails.fromJson(Map<String, dynamic> json) {
    return SubscriptionDetails(
      subscriptionId: _toInt(json['subscription_id']),
      subscriptionEndDate: json['subscription_end_date']?.toString(),
      nameEn: json['name_en'],
      nameFr: json['name_fr'],
      nameAr: json['name_ar'],
    );
  }
}

class PopularItem {
  int? id;
  String? nameEn;
  String? nameAr;
  String? nameFr;
  String? image;
  String? attributeNameEn;
  String? attributeNameAr;
  String? attributeNameFr;
  int? orderCount;

  PopularItem({
    this.id,
    this.nameEn,
    this.nameAr,
    this.nameFr,
    this.image,
    this.attributeNameEn,
    this.attributeNameAr,
    this.attributeNameFr,
    this.orderCount,
  });

  factory PopularItem.fromJson(Map<String, dynamic> json) {
    return PopularItem(
      id: _toInt(json['id']),
      nameEn: json['name_en'],
      nameAr: json['name_ar'],
      nameFr: json['name_fr'],
      image: json['image'],
      attributeNameEn: json['attribute_name_en'],
      attributeNameAr: json['attribute_name_ar'],
      attributeNameFr: json['attribute_name_fr'],
      orderCount: _toInt(json['order_count']),
    );
  }
}
