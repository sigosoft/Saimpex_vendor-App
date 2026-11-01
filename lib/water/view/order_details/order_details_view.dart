import 'package:saimpex_vendor/utils/payment_type.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/water/core/constants/app_assets.dart';
import 'package:saimpex_vendor/water/model/home_order.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/controller/chat_controller.dart';
import 'package:saimpex_vendor/view/chat/ChatDetails.dart';
import 'package:saimpex_vendor/water/view/chat/chat_view.dart';
import 'package:saimpex_vendor/water/view/home/reject_order_sheet.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/printing/print_order_ticket.dart';

class OrderDetailsView extends StatefulWidget {
  const OrderDetailsView({super.key, required this.order, this.orderId});

  final HomeOrder order;
  final dynamic orderId;

  static const Color _orange = Color(0xFFFF5E21);
  static const Color _title = Color(0xFF1E212C);
  static const Color _muted = Color(0xFF8E8E8E);
  static const Color _cardShadow = Color(0x0F000000);

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _orderDetail;

  /// Order id used for the API calls, kept for printing.
  dynamic _apiOrderId;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty && token != "null") {
        DioClient().updateToken(token);
      }

      dynamic id = widget.orderId ??
          widget.order.rawId ??
          widget.order.orderData?.id ??
          widget.order.orderData?.rawJson?['id'];

      if (id == null) {
        final match = RegExp(r'\d+').firstMatch(widget.order.orderId);
        if (match != null) {
          id = int.tryParse(match.group(0)!);
        }
      }

      if (id != null) {
        id = int.tryParse(id.toString()) ?? id;
      }
      _apiOrderId = id;

      final queryParams = <String, dynamic>{'order_id': id};

      debugPrint("==================== GET WATER ORDER DETAIL ====================");
      debugPrint("Endpoint: ${ApiEndPoints.getWaterOrderDetail}");
      debugPrint("Query: $queryParams");
      print("==================== GET WATER ORDER DETAIL ====================");
      print("Endpoint: ${ApiEndPoints.getWaterOrderDetail}");
      print("Query: $queryParams");

      final response = await DioClient().get(
        ApiEndPoints.getWaterOrderDetail,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");

      Map<String, dynamic>? raw;
      if (response.data is Map<String, dynamic>) {
        raw = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        raw = Map<String, dynamic>.from(response.data as Map);
      } else if (response.data is String) {
        try {
          final decoded = jsonDecode(response.data as String);
          if (decoded is Map) raw = Map<String, dynamic>.from(decoded);
        } catch (_) {}
      }

      if (raw != null &&
          (raw['status'] == true ||
              raw['status'].toString() == 'true' ||
              raw['status'] == 1 ||
              raw['status'] == '1')) {
        final data = raw['data'];
        if (data is Map<String, dynamic>) {
          _orderDetail = data;
        } else if (data is Map) {
          _orderDetail = Map<String, dynamic>.from(data);
        } else if (data is List && data.isNotEmpty && data.first is Map) {
          _orderDetail = Map<String, dynamic>.from(data.first as Map);
        } else {
          _orderDetail = raw;
        }
      } else {
        _errorMessage = raw?['message']?.toString() ?? S.current.orderDetailsNotFound;
      }
    } catch (e) {
      debugPrint("==================== GET WATER ORDER DETAIL ERROR ====================");
      debugPrint("Error: $e");
      print("==================== GET WATER ORDER DETAIL ERROR ====================");
      print("Error: $e");
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openUserChat({
    required BuildContext context,
    required String name,
    int? userId,
    String? avatarUrl,
  }) async {
    final chatCtrl = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());

    int convId = 0;
    int? finalCustomerId = userId;

    if (chatCtrl.conversations.isEmpty) {
      try {
        await chatCtrl.getAllConversations(context, quiet: true);
      } catch (_) {}
    }

    if (finalCustomerId != null && finalCustomerId > 0) {
      for (final c in chatCtrl.conversations) {
        if (c.customerId == finalCustomerId || c.customer?.id == finalCustomerId) {
          if (c.id != null && c.id! > 0) {
            convId = c.id!;
            break;
          }
        }
      }
    }

    if (convId == 0 && name.trim().isNotEmpty && name.trim().toLowerCase() != 'customer' && name.trim() != S.current.waterCustomer) {
      for (final c in chatCtrl.conversations) {
        final cName = c.customer?.name?.trim();
        if (cName != null && cName.toLowerCase() == name.trim().toLowerCase()) {
          if (c.id != null && c.id! > 0) {
            convId = c.id!;
            finalCustomerId ??= c.customerId ?? c.customer?.id;
            break;
          }
        }
      }
    }

    if (convId == 0 && finalCustomerId == null && name.trim().isNotEmpty && name.trim().toLowerCase() != 'customer' && name.trim() != S.current.waterCustomer) {
      try {
        await chatCtrl.searchCustomers(name.trim());
        if (chatCtrl.customerResults.isNotEmpty) {
          final match = chatCtrl.customerResults.firstWhere(
            (c) => c.name?.trim().toLowerCase() == name.trim().toLowerCase(),
            orElse: () => chatCtrl.customerResults.first,
          );
          finalCustomerId = match.id;
          for (final c in chatCtrl.conversations) {
            if (c.customerId == finalCustomerId || c.customer?.id == finalCustomerId) {
              if (c.id != null && c.id! > 0) {
                convId = c.id!;
                break;
              }
            }
          }
        }
      } catch (_) {}
    }

    if (!mounted || !context.mounted) return;

    ChatView.open(
      context,
      customerName: name.isNotEmpty ? name : S.of(context).waterCustomer,
      conversationId: convId > 0 ? convId : null,
      customerId: finalCustomerId,
      avatarUrl: avatarUrl,
    );
  }

  static Map<String, dynamic>? _safeMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  /// Gas refills: empty cylinders to collect, from the order or the detail root.
  int get _emptyCylinders => int.tryParse(
        '${_orderMap['empty_cylinders_to_collect'] ?? _orderDetail?['empty_cylinders_to_collect'] ?? ''}',
      ) ?? 0;

  Map<String, dynamic> get _orderMap {
    if (_orderDetail == null) return {};
    if (_orderDetail!['order'] is Map) {
      return Map<String, dynamic>.from(_orderDetail!['order'] as Map);
    }
    return _orderDetail!;
  }

  List<Map<String, dynamic>> get _itemsList {
    if (_orderDetail == null) return [];
    final candidates = [
      _orderDetail!['items'],
      _orderDetail!['orderItems'],
      _orderDetail!['order_items'],
      _orderMap['items'],
      _orderMap['orderItems'],
      _orderMap['order_items'],
    ];
    for (final c in candidates) {
      if (c is List && c.isNotEmpty) {
        return c
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return [];
  }

  List<Map<String, dynamic>> get _statusLogsList {
    if (_orderDetail == null) return [];
    final candidates = [
      _orderDetail!['status_logs'],
      _orderDetail!['statusLogs'],
      _orderMap['status_logs'],
      _orderMap['statusLogs'],
    ];
    for (final c in candidates) {
      if (c is List && c.isNotEmpty) {
        return c
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return [];
  }

  static String _formatDateString(dynamic rawDate) {
    if (rawDate == null) return '';
    final str = rawDate.toString().trim();
    if (str.isEmpty || str == 'null') return '';
    try {
      final dt = DateTime.parse(str);
      return DateFormat('MMM dd, yyyy hh:mm a').format(dt);
    } catch (_) {
      return str;
    }
  }

  static HomeOrderStatus _parseStatus(dynamic rawStatus, HomeOrderStatus fallback) {
    if (rawStatus == null) return fallback;
    final s = int.tryParse(rawStatus.toString());
    if (s != null) {
      switch (s) {
        case 1:
          return HomeOrderStatus.newOrder;
        case 2:
          return HomeOrderStatus.accepted;
        case 3:
          return HomeOrderStatus.preparing;
        case 4:
          return HomeOrderStatus.ready;
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
          return HomeOrderStatus.delivered;
        case 10:
          return HomeOrderStatus.cancelled;
      }
    }
    final str = rawStatus.toString().toLowerCase();
    if (str.contains('new') || str.contains('pending')) return HomeOrderStatus.newOrder;
    if (str.contains('accept')) return HomeOrderStatus.accepted;
    if (str.contains('prepar')) return HomeOrderStatus.preparing;
    if (str.contains('ready')) return HomeOrderStatus.ready;
    if (str.contains('deliver') || str.contains('complete') || str.contains('ongoing')) {
      return HomeOrderStatus.delivered;
    }
    if (str.contains('cancel') || str.contains('reject')) return HomeOrderStatus.cancelled;
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F4),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF0E8),
                Color(0xFFFFF8F4),
                Color(0xFFF7F7F7),
              ],
              stops: [0, 0.2, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _Header(
                  onBack: () => Navigator.of(context).maybePop(),
                  onPrint: _orderDetail == null || _apiOrderId == null
                      ? null
                      : () => printOrderTicket(
                          context,
                          orderId: _apiOrderId,
                          orderType: 'water',
                        ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _buildBody(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: OrderDetailsView._orange),
      );
    }

    if (_errorMessage != null && _orderDetail == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: _fetchOrderDetail,
                style: OutlinedButton.styleFrom(
                  foregroundColor: OrderDetailsView._orange,
                  side: const BorderSide(color: OrderDetailsView._orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(S.of(context).tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    final orderMap = _orderMap;
    final items = _itemsList;
    final statusLogs = _statusLogsList;

    final userMap = _safeMap(orderMap['user']) ?? _safeMap(_orderDetail?['user']);
    final customerMap = _safeMap(orderMap['customer']) ?? _safeMap(_orderDetail?['customer']);
    final partnerMap = _safeMap(orderMap['delivery_boy']) ??
        _safeMap(orderMap['driver']) ??
        _safeMap(_orderDetail?['delivery_boy']) ??
        _safeMap(_orderDetail?['driver']);

    // Customer
    final customerName = orderMap['user_name']?.toString().trim().isNotEmpty == true
        ? orderMap['user_name'].toString().trim()
        : (userMap?['name']?.toString().trim().isNotEmpty == true
            ? userMap!['name'].toString().trim()
            : (customerMap?['name']?.toString().trim().isNotEmpty == true
                ? customerMap!['name'].toString().trim()
                : widget.order.customerName));

    final customerPhone = orderMap['user_mobile']?.toString().trim() ??
        orderMap['mobile']?.toString().trim() ??
        orderMap['user_phone']?.toString().trim() ??
        orderMap['phone']?.toString().trim() ??
        userMap?['mobile']?.toString().trim() ??
        userMap?['phone']?.toString().trim() ??
        customerMap?['mobile']?.toString().trim() ??
        customerMap?['phone']?.toString().trim() ??
        '';

    // Order code & time
    final orderCode = orderMap['order_code']?.toString().trim().isNotEmpty == true
        ? orderMap['order_code'].toString().trim()
        : (orderMap['order_id']?.toString().trim().isNotEmpty == true
            ? orderMap['order_id'].toString().trim()
            : widget.order.orderId);

    final rawPlaced = orderMap['placed_at_formatted'] ??
        orderMap['placed_at'] ??
        orderMap['created_at'];
    final placedTime = _formatDateString(rawPlaced);

    // Delivery type
    final isPickup = orderMap['is_self_pickup'] == 1 ||
        orderMap['is_self_pickup'] == true ||
        orderMap['is_self_pickup'] == '1' ||
        orderMap['delivery_type'] == 2 ||
        orderMap['delivery_type'] == '2' ||
        orderMap['delivery_type']?.toString().toLowerCase().contains('pickup') == true ||
        (!widget.order.isDelivery && orderMap['delivery_type'] == null);
    final isDelivery = !isPickup;

    // Status
    final currentStatus = _parseStatus(orderMap['status'], widget.order.status);

    // Delivery partner
    final partnerName = orderMap['delivery_boy_name']?.toString().trim().isNotEmpty == true
        ? orderMap['delivery_boy_name'].toString().trim()
        : (orderMap['delivery_partner_name']?.toString().trim().isNotEmpty == true
            ? orderMap['delivery_partner_name'].toString().trim()
            : (partnerMap?['name']?.toString().trim().isNotEmpty == true
                ? partnerMap!['name'].toString().trim()
                : widget.order.deliveryPartnerName));

    final partnerRating = orderMap['delivery_boy_rating']?.toString() ??
        partnerMap?['rating']?.toString();
    final partnerReviews = orderMap['delivery_boy_reviews']?.toString() ??
        partnerMap?['reviews_count']?.toString() ??
        partnerMap?['reviews']?.toString();

    // Address
    final fullAddress = orderMap['user_address']?.toString().trim() ??
        orderMap['address']?.toString().trim() ??
        orderMap['location']?.toString().trim() ??
        orderMap['delivery_address']?.toString().trim() ??
        userMap?['address']?.toString().trim() ??
        customerMap?['address']?.toString().trim();

    final addressTitle = orderMap['address_title']?.toString().trim() ??
        orderMap['building_name']?.toString().trim() ??
        orderMap['address_name']?.toString().trim() ??
        ((fullAddress != null && fullAddress.isNotEmpty) ? S.of(context).waterDeliveryAddressTitle : null);

    // Payment
    final paymentType = orderMap['payment_type']?.toString().trim() ??
        orderMap['payment_method']?.toString().trim();
    final isCod = isCashPayment(paymentType);
    final isOnlinePayment = paymentType != null && paymentType.isNotEmpty
        ? !isCod
        : widget.order.isOnlinePayment;

    final rawPayedOn = orderMap['payed_on'] ??
        orderMap['paid_at'] ??
        orderMap['payment_date'];
    final payedOn = _formatDateString(rawPayedOn);

    final subtotal = orderMap['subtotal']?.toString() ??
        orderMap['item_total']?.toString();
    final deliveryFee = orderMap['delivery_fee']?.toString();
    final tax = orderMap['tax']?.toString();
    final discount = orderMap['discount']?.toString();
    final total = orderMap['total']?.toString();

    final dynamic rawCustomerId = orderMap['user_id'] ??
        orderMap['customer_id'] ??
        userMap?['id'] ??
        customerMap?['id'] ??
        _orderDetail?['user_id'] ??
        _orderDetail?['customer_id'] ??
        widget.order.orderData?.rawJson?['user_id'] ??
        widget.order.orderData?.rawJson?['customer_id'] ??
        _safeMap(widget.order.orderData?.rawJson?['user'])?['id'] ??
        _safeMap(widget.order.orderData?.rawJson?['customer'])?['id'];
    final int? customerId = int.tryParse(rawCustomerId?.toString() ?? '');

    final dynamic rawPartnerId = orderMap['delivery_boy_id'] ??
        partnerMap?['id'] ??
        orderMap['driver_id'] ??
        orderMap['delivery_partner_id'] ??
        _orderDetail?['delivery_boy_id'] ??
        _orderDetail?['driver_id'] ??
        widget.order.orderData?.rawJson?['delivery_boy_id'] ??
        _safeMap(widget.order.orderData?.rawJson?['delivery_boy'])?['id'];
    final int? partnerId = int.tryParse(rawPartnerId?.toString() ?? '');

    final dynamic rawCustomerImage = orderMap['user_image'] ??
        orderMap['customer_image'] ??
        orderMap['user_avatar'] ??
        orderMap['avatar'] ??
        orderMap['image'] ??
        userMap?['image'] ??
        userMap?['avatar'] ??
        customerMap?['image'] ??
        customerMap?['avatar'] ??
        _orderDetail?['user_image'] ??
        _orderDetail?['customer_image'] ??
        _safeMap(widget.order.orderData?.rawJson?['user'])?['image'] ??
        _safeMap(widget.order.orderData?.rawJson?['customer'])?['image'];
    final String? customerAvatar = rawCustomerImage?.toString();

    final dynamic rawPartnerImage = orderMap['delivery_boy_image'] ??
        partnerMap?['image'] ??
        orderMap['driver_image'] ??
        _orderDetail?['delivery_boy_image'] ??
        _orderDetail?['driver_image'];
    final String? partnerAvatar = rawPartnerImage?.toString();

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: OrderDetailsView._orange,
            onRefresh: _fetchOrderDetail,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                _CustomerCard(
                  customerName: customerName,
                  customerPhone: customerPhone,
                  orderId: orderCode,
                  placedTime: placedTime.isNotEmpty ? placedTime : widget.order.timeAgo,
                  orderType: isDelivery ? S.of(context).delivery : S.of(context).selfPickup,
                  isDelivery: isDelivery,
                  status: currentStatus,
                  addressTitle: addressTitle,
                  fullAddress: fullAddress,
                  onChat: () => _openUserChat(
                    context: context,
                    name: customerName,
                    userId: customerId,
                    avatarUrl: customerAvatar,
                  ),
                ),
                if (partnerName != null && partnerName.isNotEmpty && partnerName != 'null') ...[
                  const SizedBox(height: 16),
                  Text(
                    S.of(context).waterDeliveryPartnerHeader,
                    style: const TextStyle(
                      color: OrderDetailsView._muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _DeliveryPartnerCard(
                    name: partnerName,
                    rating: partnerRating,
                    reviews: partnerReviews,
                    onChat: () => _openUserChat(
                      context: context,
                      name: partnerName,
                      userId: partnerId,
                      avatarUrl: partnerAvatar,
                    ),
                  ),
                ],
                if (items.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    S.of(context).waterOrderItemsCount('${items.length}'),
                    style: const TextStyle(
                      color: OrderDetailsView._muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final item in items) ...[
                    _OrderItemCard(item: item),
                    const SizedBox(height: 8),
                  ],
                ],
                // Gas refills: empty cylinders the driver collects (#84).
                if (_emptyCylinders > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.recycling_outlined, size: 18, color: OrderDetailsView._orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          S.of(context).gasEmptyCylindersToCollect('$_emptyCylinders'),
                          style: const TextStyle(
                            color: OrderDetailsView._title,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  S.of(context).paymentSummary,
                  style: const TextStyle(
                    color: OrderDetailsView._muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 10),
                _PaymentSummary(
                  isOnline: isOnlinePayment,
                  subtotal: subtotal,
                  deliveryFee: deliveryFee,
                  tax: tax,
                  discount: discount,
                  total: total,
                  paymentType: paymentType,
                  payedOn: payedOn,
                  isDelivery: isDelivery,
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context).orderTimeline,
                  style: const TextStyle(
                    color: OrderDetailsView._title,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                _OrderTimeline(
                  isDelivery: isDelivery,
                  status: currentStatus,
                  hasDeliveryPartner:
                      partnerName != null && partnerName.isNotEmpty && partnerName != 'null',
                  statusLogs: statusLogs,
                  placedAt: placedTime.isNotEmpty ? placedTime : widget.order.timeAgo,
                ),
              ],
            ),
          ),
        ),
        _BottomActions(
          status: currentStatus,
          isDelivery: isDelivery,
          onReject: () => showRejectOrderSheet(context),
          onAccept: () {},
          onPrepare: () {},
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, this.onPrint});

  final VoidCallback onBack;

  /// Prints the order ticket (V7); hidden until the order has loaded.
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              S.of(context).orderDetails,
              style: const TextStyle(
                color: OrderDetailsView._title,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: OrderDetailsView._orange,
                    size: 28,
                  ),
                ),
              ),
            ),
            if (onPrint != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Tooltip(
                  message: S.of(context).printOrder,
                  child: InkWell(
                    onTap: onPrint,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.print_outlined,
                        color: OrderDetailsView._orange,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.customerName,
    required this.customerPhone,
    required this.orderId,
    required this.placedTime,
    required this.orderType,
    required this.isDelivery,
    required this.status,
    this.addressTitle,
    this.fullAddress,
    this.onChat,
  });

  final String customerName;
  final String customerPhone;
  final String orderId;
  final String placedTime;
  final String orderType;
  final bool isDelivery;
  final HomeOrderStatus status;
  final String? addressTitle;
  final String? fullAddress;
  final VoidCallback? onChat;

  static const Color _labelOrange = Color(0xFFE67E4D);
  static const Color _newBadge = Color(0xFFF39C12);
  static const Color _acceptedBadge = Color(0xFF2EAD5B);
  static const Color _pillShadow = Color(0x14000000);

  (String, Color) get _statusBadge {
    return switch (status) {
      HomeOrderStatus.newOrder => (S.current.waterNewBadge, _newBadge),
      HomeOrderStatus.accepted => (S.current.accepted.toUpperCase(), _acceptedBadge),
      HomeOrderStatus.preparing => (S.current.preparing.toUpperCase(), const Color(0xFFFF8A00)),
      HomeOrderStatus.ready => (S.current.ready.toUpperCase(), const Color(0xFF2EAD5B)),
      HomeOrderStatus.delivered => (S.current.delivered.toUpperCase(), const Color(0xFF2EAD5B)),
      HomeOrderStatus.cancelled => (S.current.cancelled.toUpperCase(), const Color(0xFF9E9E9E)),
    };
  }

  @override
  Widget build(BuildContext context) {
    final typeColor =
        isDelivery ? OrderDetailsView._orange : const Color(0xFF2F80ED);
    final (badgeLabel, badgeColor) = _statusBadge;
    final initial = customerName.trim().isNotEmpty
        ? customerName.trim()[0].toUpperCase()
        : 'C';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_search_outlined,
                color: Color.fromARGB(255, 247, 80, 2),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                S.of(context).waterCustomerHeader,
                style: const TextStyle(
                  color: Color.fromARGB(255, 247, 80, 2),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SoftPill(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFFFE4E8),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Color(0xFFC62828),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: const TextStyle(
                          color: OrderDetailsView._title,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                        ),
                      ),
                      if (customerPhone.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          customerPhone,
                          // Phone numbers always read left-to-right.
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                InkWell(
                  onTap: onChat ?? () => ChatView.open(context, customerName: customerName),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: OrderDetailsView._orange,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              OrderDetailsView._orange.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'lib/home_cleaning/Assets/images/chat.png',
                      width: 20,
                      height: 20,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _SoftPill(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).waterRequestId,
                        style: const TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: orderId,
                              style: const TextStyle(
                                color: OrderDetailsView._orange,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            if (placedTime.isNotEmpty)
                              TextSpan(
                                text: ' - $placedTime',
                                style: const TextStyle(
                                  color: Color(0xFF5A5A5A),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11.5,
                                ),
                              ),
                          ],
                        ),
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _SoftPill(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        S.of(context).waterDeliveryTypeHeader,
                        style: const TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isDelivery)
                            Text(
                              '(',
                              style: TextStyle(
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          if (!isDelivery) const SizedBox(width: 2),
                          ColorFiltered(
                            colorFilter: const ColorFilter.matrix(<double>[
                              1, 0, 0, 0, 0,
                              0, 1, 0, 0, 0,
                              0, 0, 1, 0, 0,
                              1, 1, 1, 0, 0,
                            ]),
                            child: Image.asset(
                              isDelivery
                                  ? AppAssets.deliveryIcon
                                  : AppAssets.selfPickupIcon,
                              width: 14,
                              height: 14,
                              errorBuilder: (_, _, _) => Icon(
                                isDelivery
                                    ? Icons.delivery_dining
                                    : Icons.shopping_bag_outlined,
                                size: 14,
                                color: typeColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            orderType,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                          if (!isDelivery) const SizedBox(width: 2),
                          if (!isDelivery)
                            Text(
                              ')',
                              style: TextStyle(
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isDelivery && (fullAddress != null && fullAddress!.trim().isNotEmpty)) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: _labelOrange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  S.of(context).deliveryAddress,
                  style: const TextStyle(
                    color: _labelOrange,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SoftPill(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFFFF0E6),
                    child: Icon(
                      Icons.home_outlined,
                      color: OrderDetailsView._orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (addressTitle != null && addressTitle!.trim().isNotEmpty) ...[
                          Text(
                            addressTitle!.trim(),
                            style: const TextStyle(
                              color: OrderDetailsView._title,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 3),
                        ],
                        Text(
                          fullAddress!.trim(),
                          style: const TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontWeight: FontWeight.w400,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SoftPill extends StatelessWidget {
  const _SoftPill({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: _CustomerCard._pillShadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  const _OrderItemCard({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final dynamic rawOrderItem = item['order_item'];
    final orderItemMap = rawOrderItem is Map ? rawOrderItem : null;
    final name = orderItemMap?['name_en']?.toString() ??
        orderItemMap?['name']?.toString() ??
        item['name']?.toString() ??
        item['product_name']?.toString() ??
        item['item_name']?.toString() ??
        item['title']?.toString() ??
        '';

    final unitPrice = item['unit_price']?.toString() ??
        item['price']?.toString() ??
        item['rate']?.toString() ??
        '';

    final qty = item['quantity']?.toString() ??
        item['qty']?.toString() ??
        '1';

    final rawImage = item['image']?.toString() ??
        item['product_image']?.toString() ??
        item['image_url']?.toString() ??
        '';

    String imageUrl = '';
    if (rawImage.isNotEmpty && rawImage != 'null') {
      if (rawImage.startsWith('http://') || rawImage.startsWith('https://')) {
        imageUrl = rawImage;
      } else {
        final base = ApiConfigs.IMAGE_URL.trim();
        imageUrl = base.endsWith('/') ? '$base$rawImage' : '$base/$rawImage';
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: OrderDetailsView._cardShadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 64,
              height: 64,
              color: const Color(0xFFE8E8E8),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Image.asset(
                        AppAssets.waterCan19L,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.water_drop,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    )
                  : Image.asset(
                      AppAssets.waterCan19L,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.water_drop,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : S.of(context).waterItem,
                  style: const TextStyle(
                    color: OrderDetailsView._title,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                ),
                if (unitPrice.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '$unitPrice MRU',
                    style: const TextStyle(
                      color: OrderDetailsView._orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              S.of(context).qtyLabel(qty),
              style: const TextStyle(
                color: Color(0xFF555555),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({
    required this.isOnline,
    this.subtotal,
    this.deliveryFee,
    this.tax,
    this.discount,
    this.total,
    this.paymentType,
    this.payedOn,
    this.isDelivery = true,
  });

  final bool isOnline;
  final String? subtotal;
  final String? deliveryFee;
  final String? tax;
  final String? discount;
  final String? total;
  final String? paymentType;
  final String? payedOn;
  final bool isDelivery;

  @override
  Widget build(BuildContext context) {
    final payTypeLabel = paymentTypeLabel(paymentType, cashFallback: !isOnline);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (subtotal != null && subtotal!.isNotEmpty) ...[
            _PayRow(label: S.of(context).itemTotal, value: '$subtotal MRU'),
            const SizedBox(height: 10),
          ],
          if (isDelivery && deliveryFee != null && deliveryFee!.isNotEmpty) ...[
            _PayRow(label: S.of(context).deliveryFee, value: '$deliveryFee MRU'),
            const SizedBox(height: 10),
          ],
          if (tax != null && tax!.isNotEmpty && tax != '0' && tax != '0.00') ...[
            _PayRow(label: S.of(context).tax, value: '$tax MRU'),
            const SizedBox(height: 10),
          ],
          if (discount != null && discount!.isNotEmpty && discount != '0' && discount != '0.00') ...[
            _PayRow(
              label: S.of(context).discount,
              value: '-$discount MRU',
              valueColor: const Color(0xFF2EAD5B),
            ),
            const SizedBox(height: 10),
          ],
          _PayRow(
            label: S.of(context).paymentType,
            value: payTypeLabel,
            valueColor: OrderDetailsView._orange,
          ),
          if (payedOn != null && payedOn!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _PayRow(
              label: S.of(context).paymentOn,
              value: payedOn!.trim(),
              valueColor: const Color(0xFFB0B0B0),
              valueSize: 12,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF444444), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                S.of(context).waterTotalPaid,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                '${total ?? subtotal ?? "0"} MRU',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayRow extends StatelessWidget {
  const _PayRow({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
    this.valueSize = 13.5,
  });

  final String label;
  final String value;
  final Color valueColor;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w500,
              fontSize: valueSize,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeliveryPartnerCard extends StatelessWidget {
  const _DeliveryPartnerCard({
    required this.name,
    this.rating,
    this.reviews,
    this.onChat,
  });

  final String name;
  final String? rating;
  final String? reviews;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFFFE0D0),
                child: Text(
                  initials.isEmpty ? 'D' : initials,
                  style: const TextStyle(
                    color: OrderDetailsView._orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2EAD5B),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: OrderDetailsView._title,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (rating != null && rating!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Color(0xFFFFC107),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating!.trim(),
                        style: const TextStyle(
                          color: OrderDetailsView._title,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (reviews != null && reviews!.trim().isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          S.of(context).waterReviewsCount(reviews!.trim()),
                          style: const TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontWeight: FontWeight.w400,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: onChat ?? () => ChatView.open(context, customerName: name),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: OrderDetailsView._orange,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: OrderDetailsView._orange.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Image.asset(
                'lib/home_cleaning/Assets/images/chat.png',
                width: 20,
                height: 20,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({
    required this.isDelivery,
    required this.status,
    this.hasDeliveryPartner = false,
    this.statusLogs = const [],
    this.placedAt,
  });

  final bool isDelivery;
  final HomeOrderStatus status;
  final bool hasDeliveryPartner;
  final List<Map<String, dynamic>> statusLogs;
  final String? placedAt;

  static const Color _containerBg = Color(0xFFF8F7F4);

  static List<(IconData, String, List<int>)> get deliveryBase => [
    (Icons.check_rounded, S.current.waterOrderReceived, [1]),
    (Icons.check_rounded, S.current.orderAccepted, [2]),
    (Icons.local_drink_outlined, S.current.preparing, [3]),
    (Icons.check_rounded, S.current.waterReadyForDispatch, [4]),
    (Icons.delivery_dining_outlined, S.current.waterDeliveryPartnerAssigned, [5]),
    (Icons.check_rounded, S.current.waterPickedUpByRider, [6, 7]),
    (Icons.home_outlined, S.current.waterOrderDelivered, [8, 9]),
  ];

  static List<(IconData, String, List<int>)> get selfPickupBase => [
    (Icons.check_rounded, S.current.waterOrderReceived, [1]),
    (Icons.check_rounded, S.current.orderAccepted, [2]),
    (Icons.local_drink_outlined, S.current.preparing, [3]),
    (Icons.check_rounded, S.current.waterReadyForPickup, [4]),
    (Icons.check_rounded, S.current.waterPickedUpByCustomer, [5, 6, 7, 8, 9]),
  ];

  int get _completedCount {
    return switch (status) {
      HomeOrderStatus.newOrder => 1,
      HomeOrderStatus.accepted => 2,
      HomeOrderStatus.preparing => 3,
      HomeOrderStatus.ready => isDelivery
          ? (hasDeliveryPartner ? 5 : 4)
          : 4,
      HomeOrderStatus.delivered => isDelivery ? 7 : 5,
      HomeOrderStatus.cancelled => 1,
    };
  }

  String _getTimestampForStep(int stepIndex, List<int> statusIds) {
    for (final log in statusLogs) {
      final logStatus = int.tryParse(log['status']?.toString() ?? '');
      if (logStatus != null && statusIds.contains(logStatus)) {
        final timeStr = log['created_at_formatted'] ??
            log['created_at'] ??
            log['time'] ??
            log['date'];
        if (timeStr != null && timeStr.toString().isNotEmpty) {
          return _OrderDetailsViewState._formatDateString(timeStr);
        }
      }
    }
    if (stepIndex == 0 && placedAt != null && placedAt!.isNotEmpty) {
      return _OrderDetailsViewState._formatDateString(placedAt);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final base = isDelivery ? deliveryBase : selfPickupBase;
    final completed = _completedCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        color: _containerBg,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          for (var i = 0; i < base.length; i++)
            _TimelineStep(
              icon: base[i].$1,
              title: base[i].$2,
              subtitle: i < completed ? _getTimestampForStep(i, base[i].$3) : '',
              active: i < completed,
              showLine: i < base.length - 1,
              lineActive: i < completed - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.showLine,
    required this.lineActive,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;
  final bool showLine;
  final bool lineActive;

  static const Color _inactiveCircle = Color(0xFFE8EEF5);
  static const Color _inactiveIcon = Color(0xFFAAB7C6);
  static const Color _inactiveText = Color(0xFF97A6B9);
  static const Color _lineInactive = Color(0xFFE8EEF5);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: active ? OrderDetailsView._orange : _inactiveCircle,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: OrderDetailsView._orange
                                  .withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: active ? Colors.white : _inactiveIcon,
                  ),
                ),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: lineActive
                          ? OrderDetailsView._orange
                          : _lineInactive,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showLine ? 22 : 0, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: active ? OrderDetailsView._title : _inactiveText,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.status,
    required this.isDelivery,
    required this.onReject,
    required this.onAccept,
    required this.onPrepare,
  });

  final HomeOrderStatus status;
  final bool isDelivery;
  final VoidCallback onReject;
  final VoidCallback onAccept;
  final VoidCallback onPrepare;

  String? get _primaryLabel {
    return switch (status) {
      HomeOrderStatus.accepted => S.current.prepareOrder,
      HomeOrderStatus.preparing => S.current.markAsReady,
      HomeOrderStatus.ready when !isDelivery => S.current.waterMarkAsPickedUp,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final primaryLabel = _primaryLabel;
    final showRejectAccept = status == HomeOrderStatus.newOrder ||
        status == HomeOrderStatus.delivered;

    if (primaryLabel == null && !showRejectAccept) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: SafeArea(
        top: false,
        child: primaryLabel != null
            ? SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color:
                            OrderDetailsView._orange.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: onPrepare,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OrderDetailsView._orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      primaryLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1A1A1A),
                          side: const BorderSide(color: Color(0xFFD0D0D0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          S.of(context).reject,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: OrderDetailsView._orange
                                  .withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OrderDetailsView._orange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            S.of(context).acceptOrder,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
