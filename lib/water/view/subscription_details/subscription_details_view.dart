import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/water/core/constants/app_assets.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';
import 'package:saimpex_vendor/water/model/home_order.dart';
import 'package:saimpex_vendor/water/view/chat/chat_view.dart';
import 'package:saimpex_vendor/water/view/home/pause_subscription_sheet.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/water/controller/home_controller.dart';
import 'package:saimpex_vendor/water/core/water_api.dart';
import 'package:saimpex_vendor/water/core/water_state_view.dart';

/// Values from `GET vendorapp/waterSubscriptionDetails?subscription_id=`
/// (`data.subscription`). Only fields the backend returns are shown.
class _Details {
  const _Details(this.json);

  final Map<String, dynamic> json;

  String _str(String key) {
    final v = json[key]?.toString().trim() ?? '';
    return v == 'null' ? '' : v;
  }

  String get phone => _str('phone').isNotEmpty ? _str('phone') : _str('customer_mobile');
  String get requestedOn => WaterApi.formatDateTime(json['created_at']);
  String get address => _str('address_line1');
  String get product => _str('service').isNotEmpty ? _str('service') : _str('product_name');

  int get _bottles => int.tryParse(_str('bottles_per_delivery')) ?? int.tryParse(_str('qty')) ?? 1;
  int get _quantity {
    final q = int.tryParse(_str('quantity')) ?? 1;
    return q < 1 ? 1 : q;
  }

  /// Bottles per delivery × subscribed quantity (amount = price × quantity, §6.14).
  int get qty => _bottles * _quantity;

  int get frequencyDays => int.tryParse(_str('frequency_days')) ?? 0;

  String get frequency {
    return switch (frequencyDays) {
      1 => S.current.waterDaily,
      7 => S.current.waterWeekly,
      14 => S.current.waterBiWeekly,
      30 => S.current.waterMonthly,
      final d when d > 0 => S.current.waterEveryNDays(d.toString()),
      _ => _str('frequency').isNotEmpty ? _str('frequency') : '—',
    };
  }

  String get slot => _str('slot').isNotEmpty ? _str('slot') : (_str('delivery_slot').isNotEmpty ? _str('delivery_slot') : '—');

  String get startDate => WaterApi.formatDate(
        _str('starts_at').isNotEmpty ? json['starts_at'] : json['created_at'],
      );
  String get endDate => WaterApi.formatDate(json['ends_at']);

  DateTime? get nextDeliveryAt => WaterApi.parseDate(json['next_delivery_at']);

  String get nextDelivery {
    final next = nextDeliveryAt;
    if (next == null) return '—';
    return _isTomorrow(next) ? S.current.waterTomorrow : WaterApi.formatDate(json['next_delivery_at']);
  }

  /// The backend sends `upcoming` (3 rows) built from `next_delivery_at` +
  /// `frequency_days`; the same dates are rebuilt here so the weekday is
  /// localised.
  List<(String date, String label, String time)> get upcoming {
    final raw = json['upcoming'];
    final next = nextDeliveryAt;
    if (raw is! List || raw.isEmpty || next == null || frequencyDays <= 0) {
      return const [];
    }
    return [
      for (var i = 0; i < raw.length; i++)
        () {
          final at = next.add(Duration(days: frequencyDays * i));
          return (
            at.day.toString().padLeft(2, '0'),
            _isTomorrow(at) ? S.current.waterTomorrow : WaterApi.weekday(at),
            WaterApi.formatTime(at),
          );
        }(),
    ];
  }

  String? get pausedOn {
    final v = WaterApi.formatDateTime(json['paused_at']);
    return v == '—' ? null : v;
  }

  String get paymentType => _str('payment_type');
  bool get isPaid => _str('payment_status') == '2';

  String get paymentMethod => switch (paymentType) {
        '2' => S.current.onlinePayment,
        '3' => S.current.waterWallet,
        '1' => S.current.cashOnDelivery,
        _ => '—',
      };

  /// `amount` (price × quantity); older rows have 0, then plan price × quantity.
  String get amount {
    final a = double.tryParse(_str('amount'));
    if (a != null && a > 0) return WaterApi.money(a);
    final price = double.tryParse(_str('plan_price')) ?? double.tryParse(_str('value'));
    if (price == null) return '—';
    return WaterApi.money(price * _quantity);
  }

  String? get paidOn {
    final v = WaterApi.formatDateTime(json['paid_at']);
    return v == '—' ? null : v;
  }

  static bool _isTomorrow(DateTime dt) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return dt.year == tomorrow.year && dt.month == tomorrow.month && dt.day == tomorrow.day;
  }
}

class SubscriptionDetailsView extends StatefulWidget {
  const SubscriptionDetailsView({super.key, required this.order});

  /// Row from the home list; the screen reloads the full record by its id.
  final SubscriptionOrder order;

  @override
  State<SubscriptionDetailsView> createState() => _SubscriptionDetailsViewState();
}

class _SubscriptionDetailsViewState extends State<SubscriptionDetailsView> {
  _Details? _details;
  bool _loading = true;
  String? _error;

  SubscriptionOrder get order => _details != null
      ? SubscriptionOrder.fromJson(_details!.json)
      : widget.order;
  bool get _isPaused => order.status == SubscriptionOrderStatus.paused;
  bool get _isActive => order.status == SubscriptionOrderStatus.active;
  bool get _isNew => order.status == SubscriptionOrderStatus.newOrder;

  /// New + Active share the full schedule layout from the design.
  bool get _showDeliverySchedule => _isActive || _isNew;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await WaterApi.prepare();
      final id = widget.order.subscriptionId;
      final response = await DioClient().get(
        ApiEndPoints.waterSubscriptionDetails,
        query: {'subscription_id': id},
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (!WaterApi.isOk(body) || data is! Map || data['subscription'] is! Map) {
        throw WaterApi.message(body) ?? S.current.waterSomethingWentWrong;
      }
      if (!mounted) return;
      setState(() {
        _details = _Details(Map<String, dynamic>.from(data['subscription'] as Map));
      });
    } catch (e) {
      if (mounted) setState(() => _error = WaterApi.errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  WaterHomeController get _homeController => Get.isRegistered<WaterHomeController>()
      ? Get.find<WaterHomeController>()
      : Get.put(WaterHomeController());

  Future<void> _pause() async {
    final reason = await showPauseSubscriptionSheet(context);
    if (reason == null || !mounted) return;
    await _homeController.pauseWaterSubscription(
      order.subscriptionId,
      reason: reason,
      context: context,
    );
    if (mounted) _load();
  }

  Future<void> _resume() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(dialogContext).waterResumeSubscription),
        content: Text(S.of(dialogContext).waterResumeSubscriptionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(S.of(dialogContext).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              S.of(dialogContext).waterResume,
              style: const TextStyle(color: AppColors.primaryOrange),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _homeController.resumeWaterSubscription(
      order.subscriptionId,
      context: context,
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final details = _details;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundMid,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundTop,
                AppColors.backgroundMid,
                AppColors.backgroundBottom,
              ],
              stops: [0, 0.2, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _Header(onBack: () => Navigator.of(context).maybePop()),
                const SizedBox(height: 12),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primaryOrange,
                    onRefresh: _load,
                    child: details == null
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              if (_loading)
                                const WaterStateView.loading()
                              else
                                WaterStateView.error(
                                  message: _error ?? S.of(context).waterSomethingWentWrong,
                                  onRetry: _load,
                                ),
                            ],
                          )
                        : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      _CustomerCard(order: order, details: details),
                      if (_isPaused) ...[
                        const SizedBox(height: 12),
                        _PausedStatusCard(order: order, pausedOn: details.pausedOn),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        S.of(context).waterPlanSummary,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ProductCard(name: details.product, qty: details.qty),
                      const SizedBox(height: 12),
                      _PlanGrid(
                        frequency: details.frequency,
                        timeSlot: details.slot,
                        startDate: details.startDate,
                        endDate: details.endDate,
                      ),
                      if (_showDeliverySchedule) ...[
                        const SizedBox(height: 10),
                        _NextDeliveryBar(value: details.nextDelivery),
                        if (details.upcoming.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          _SectionTitle(
                            title: S.of(context).waterUpcomingDeliveries,
                          ),
                          const SizedBox(height: 10),
                          _UpcomingDeliveriesCard(items: details.upcoming),
                        ],
                      ],
                      // Delivery history: the details endpoint returns no
                      // delivered orders for a subscription yet, so the block
                      // is hidden (issue draft in issues_water.md).
                      const SizedBox(height: 18),
                      Text(
                        S.of(context).paymentSummary,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _PaymentSummary(details: details),
                    ],
                  ),
                  ),
                ),
                if (details != null)
                  _BottomActions(
                    status: order.status,
                    pausedByVendor: order.pausedByVendor,
                    customerName: order.customerName,
                    customerId: order.resolvedCustomerId,
                    orderId: order.subscriptionId,
                    avatarUrl: order.customerAvatar,
                    onPause: _pause,
                    onResume: _resume,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

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
              S.of(context).waterSubscriptionDetails,
              style: const TextStyle(
                color: AppColors.textDark,
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
                    border: Border.all(
                      color: AppColors.primaryOrange.withValues(alpha: 0.35),
                    ),
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
                    color: AppColors.primaryOrange,
                    size: 28,
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
  const _CustomerCard({required this.order, required this.details});

  final SubscriptionOrder order;
  final _Details details;

  static List<BoxShadow> get _softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final typeColor = order.isDelivery
        ? AppColors.primaryOrange
        : AppColors.selfPickupBlue;

    final (badgeLabel, badgeColor) = switch (order.status) {
      SubscriptionOrderStatus.newOrder ||
      SubscriptionOrderStatus.active => (S.current.active, AppColors.activeGreen),
      SubscriptionOrderStatus.paused => (S.current.waterPaused.toUpperCase(), AppColors.primaryOrange),
      SubscriptionOrderStatus.cancelled => (S.current.cancelled.toUpperCase(), AppColors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
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
                color: AppColors.primaryOrange,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                S.of(context).waterCustomerHeader,
                style: const TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
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
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: _softShadow,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.avatarPink,
                  child: Text(
                    order.customerName.isEmpty ? '?' : order.customerName[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.avatarText,
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
                        order.customerName,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        details.phone.isEmpty ? '—' : details.phone,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOrange.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.phone, color: Colors.white, size: 20),
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
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).waterRequestId,
                        style: const TextStyle(
                          color: AppColors.textHint,
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
                              text: order.orderId,
                              style: const TextStyle(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(
                              text: ' • ${details.requestedOn}',
                              style: const TextStyle(
                                color: AppColors.textMeta,
                                fontWeight: FontWeight.w400,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          S.of(context).waterDeliveryTypeHeader,
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ColorFiltered(
                            colorFilter: const ColorFilter.matrix(<double>[
                              1,
                              0,
                              0,
                              0,
                              0,
                              0,
                              1,
                              0,
                              0,
                              0,
                              0,
                              0,
                              1,
                              0,
                              0,
                              1,
                              1,
                              1,
                              0,
                              0,
                            ]),
                            child: Image.asset(
                              order.isDelivery
                                  ? AppAssets.deliveryIcon
                                  : AppAssets.selfPickupIcon,
                              width: 14,
                              height: 14,
                              errorBuilder: (_, _, _) => Icon(
                                order.isDelivery
                                    ? Icons.delivery_dining
                                    : Icons.shopping_bag_outlined,
                                size: 14,
                                color: typeColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              order.isDelivery
                                  ? S.of(context).delivery
                                  : S.of(context).selfPickup,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
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
          if (order.isDelivery) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primaryOrange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  S.of(context).deliveryAddress,
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: _softShadow,
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.orangeSoftBg,
                    child: Icon(
                      Icons.home_outlined,
                      color: AppColors.primaryOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      details.address.isEmpty
                          ? S.of(context).addressNotAvailable
                          : details.address,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
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

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.name, required this.qty});

  final String name;
  final int qty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
              color: AppColors.softGrayAlt,
              child: Image.asset(
                AppAssets.waterCan19L,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.water_drop, color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? '—' : name,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    S.of(context).qtyLabel('$qty'),
                    style: const TextStyle(
                      color: AppColors.textLabel,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanGrid extends StatelessWidget {
  const _PlanGrid({
    required this.frequency,
    required this.timeSlot,
    required this.startDate,
    required this.endDate,
  });

  final String frequency;
  final String timeSlot;
  final String startDate;
  final String endDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _PlanTile(
                icon: Icons.sync_rounded,
                label: S.of(context).waterFrequency,
                value: frequency,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PlanTile(
                icon: Icons.access_time_rounded,
                label: S.of(context).waterTimeSlot,
                value: timeSlot,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _PlanTile(
                icon: Icons.calendar_month_outlined,
                label: S.of(context).waterStart,
                value: startDate,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PlanTile(
                icon: Icons.calendar_month_outlined,
                label: S.of(context).waterEnd,
                value: endDate,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.planPurpleBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.planPurple),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.planPurpleSoft,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.planPurple,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextDeliveryBar extends StatelessWidget {
  const _NextDeliveryBar({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.planPurpleBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_shipping_outlined,
            color: AppColors.planPurple,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).waterNextDelivery,
                  style: const TextStyle(
                    color: AppColors.planPurpleSoft,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.planPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.planPurple,
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _PausedStatusCard extends StatelessWidget {
  const _PausedStatusCard({required this.order, this.pausedOn});

  final SubscriptionOrder order;

  /// `paused_at`, formatted; null when the backend has none.
  final String? pausedOn;
  @override
  Widget build(BuildContext context) {
    final pausedBy = order.pausedByVendor
        ? S.of(context).waterYou
        : S.of(context).waterCustomer;
    final pausedOn = this.pausedOn ?? order.pausedOn ?? '—';
    final reason = order.pauseReason;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.pausedCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.pausedCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.pausedAmber,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.pause_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                S.of(context).waterCurrentlyPaused,
                style: const TextStyle(
                  color: AppColors.pausedAmber,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PausedMetaRow(label: S.of(context).waterPausedByLabel, value: pausedBy),
          const SizedBox(height: 6),
          _PausedMetaRow(label: S.of(context).waterPausedOnLabel, value: pausedOn),
          if (order.pausedByVendor &&
              reason != null &&
              reason.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            _PausedMetaRow(label: S.of(context).waterReasonLabel, value: reason),
          ],
        ],
      ),
    );
  }
}

class _PausedMetaRow extends StatelessWidget {
  const _PausedMetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.labelGray,
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;
  static const Color titleColor = AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _UpcomingDeliveriesCard extends StatelessWidget {
  const _UpcomingDeliveriesCard({required this.items});

  /// (day of month, weekday label, time)
  final List<(String, String, String)> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.cardBorder),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.planPurpleBg,
                    child: Text(
                      items[i].$1,
                      style: const TextStyle(
                        color: AppColors.planPurple,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[i].$2,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.planPurple,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    items[i].$3,
                    style: const TextStyle(
                      color: AppColors.planPurple,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
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

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.details});

  final _Details details;

  @override
  Widget build(BuildContext context) {
    final paidOn = details.paidOn;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.paymentCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _PayRow(label: S.of(context).waterSubscriptionAmount, value: details.amount),
          const SizedBox(height: 10),
          _PayRow(label: S.of(context).paymentMethod, value: details.paymentMethod),
          if (details.isPaid && paidOn != null) ...[
            const SizedBox(height: 10),
            _PayRow(
              label: S.of(context).paymentOn,
              value: paidOn,
              valueColor: AppColors.textHint,
              valueSize: 12,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: AppColors.paymentDivider, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                details.isPaid
                    ? S.of(context).waterTotalPaid
                    : S.of(context).waterAmountDue,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                details.amount,
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

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.status,
    required this.pausedByVendor,
    required this.customerName,
    required this.onPause,
    required this.onResume,
    this.customerId,
    this.orderId,
    this.avatarUrl,
  });

  final SubscriptionOrderStatus status;
  final bool pausedByVendor;
  final String customerName;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final int? customerId;
  final dynamic orderId;
  final String? avatarUrl;

  Widget _chatButton({required BuildContext context, bool fullWidth = false}) {
    return SizedBox(
      height: 50,
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: () => ChatView.open(
          context,
          customerName: customerName,
          customerId: customerId,
          orderId: orderId,
          avatarUrl: avatarUrl,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryOrange,
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.primaryOrange, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/home_cleaning/Assets/images/chat.png',
                width: 18,
                height: 18,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
              SizedBox(width: 6),
              Text(
                S.of(context).waterChatWithCustomer,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    double iconSize = 18,
  }) {
    return SizedBox(
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCustomerPaused =
        status == SubscriptionOrderStatus.paused && !pausedByVendor;
    final isVendorPaused =
        status == SubscriptionOrderStatus.paused && pausedByVendor;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: SafeArea(
        top: false,
        child: isCustomerPaused
            ? _chatButton(context: context, fullWidth: true)
            : Row(
                children: [
                  Expanded(child: _chatButton(context: context)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: isVendorPaused
                        ? _primaryButton(
                            label: S.of(context).waterResume,
                            icon: Icons.play_arrow_rounded,
                            iconSize: 20,
                            onPressed: onResume,
                          )
                        : _primaryButton(
                            label: S.of(context).waterPause,
                            icon: Icons.pause,
                            onPressed: onPause,
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
