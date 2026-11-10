import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/utils/bidi_text.dart' show isolated;
import 'package:saimpex_vendor/utils/payment_type.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' hide FormData;
import 'package:intl/intl.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/printing/print_order_ticket.dart';
import 'package:saimpex_vendor/pharmacy/controller/pharmacy_chat_controller.dart';
import 'package:saimpex_vendor/pharmacy/controller/pharmacy_home_controller.dart';
import 'package:saimpex_vendor/pharmacy/controller/pharmacy_order_details_controller.dart';
import 'package:saimpex_vendor/pharmacy/model/pharmacy_order.dart';
import 'package:saimpex_vendor/pharmacy/model/pharmacy_order_detail_model.dart';
import 'package:saimpex_vendor/pharmacy/model/pharmacy_prescription_detail_model.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_chat_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/reject_order_sheet.dart';
import 'package:saimpex_vendor/view/home/substitution/order_substitutions.dart' show groceryUnitLabel;
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';

part 'create_quotation_screen.dart';
part '../controller/create_quotation_controller.dart';
part 'otc_order_details_screen.dart';

void _openCustomerChat(
  BuildContext context, {
  required String customerName,
  required int? customerId,
  String? avatar,
}) {
  final int validCustomerId = (customerId != null && customerId > 0)
      ? customerId
      : 1;

  int initialConvId = 0;
  String initialAvatar = avatar ?? '';
  if (Get.isRegistered<PharmacyChatController>()) {
    final chatCtrl = Get.find<PharmacyChatController>();
    for (final c in chatCtrl.conversations) {
      if (c.customerId == validCustomerId ||
          c.customer?.id == validCustomerId) {
        if (c.id != null && c.id! > 0) {
          initialConvId = c.id!;
        }
        final img = c.customer?.image?.trim();
        if (img != null && img.isNotEmpty && initialAvatar.isEmpty) {
          initialAvatar = img;
        }
        break;
      }
    }
  }

  PharmacyChatScreen.open(
    context,
    customerName: customerName.isNotEmpty ? customerName : S.of(context).quoteCustomer,
    customerId: validCustomerId,
    conversationId: initialConvId,
    avatar: initialAvatar,
  );
}

class PharmacyOrderDetailsScreen extends StatefulWidget {
  const PharmacyOrderDetailsScreen({
    super.key,
    this.customerName = '',
    this.phone = '',
    this.requestId = '',
    this.requestMeta = '',
    this.notesType = PharmacyOrderNotesType.none,
    this.specialNotes = '',
    this.voiceNoteDuration = const Duration(seconds: 15),
    this.isSelfPickup = false,
    this.isUnderReview = false,
    this.isReviewCompleted = false,
    this.isAwaitingPayment = false,
    this.isToPrepare = false,
    this.isPreparing = false,
    this.isReady = false,
    this.isDelivered = false,
    this.isOtc = false,
    this.cashOnDelivery = false,
    this.isOtcAccepted = false,
    this.isOtcPreparing = false,
    this.isOtcReady = false,
    this.isOtcPartnerAssigned = false,
    this.isOtcDelivered = false,
    this.isOtcCancelled = false,
    this.orderId,
    this.orderRawId,
    this.prescriptionId,
    this.prescriptionImageUrl,
    this.resolveFromServer = false,
  });

  /// Opens one pharmacy order's details from just an id (a notification or
  /// popup "View order"). With [orderId] the order is loaded first: a
  /// prescription order shows the prescription layout, any other the OTC
  /// layout; with only [prescriptionId] the prescription (and the order it
  /// became, if paid) is loaded. The stage and buttons follow the server
  /// status. Returns after the screen is closed.
  static Future<void> openById(
    BuildContext context, {
    int? orderId,
    int? prescriptionId,
  }) async {
    if (orderId == null && prescriptionId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PharmacyOrderDetailsScreen(
          orderId: orderId,
          prescriptionId: prescriptionId,
          resolveFromServer: true,
        ),
      ),
    );
  }

  /// Stage and layout come from the loaded order / prescription instead of
  /// the flags above (see [openById]).
  final bool resolveFromServer;

  final String customerName;
  final String phone;
  final String requestId;
  final String requestMeta;
  final PharmacyOrderNotesType notesType;
  final String specialNotes;
  final Duration voiceNoteDuration;
  final bool isSelfPickup;
  final bool isUnderReview;
  final bool isReviewCompleted;
  final bool isAwaitingPayment;
  final bool isToPrepare;
  final bool isPreparing;
  final bool isReady;
  final bool isDelivered;
  final bool isOtc;
  final bool cashOnDelivery;
  final bool isOtcAccepted;
  final bool isOtcPreparing;
  final bool isOtcReady;
  final bool isOtcPartnerAssigned;
  final bool isOtcDelivered;
  final bool isOtcCancelled;
  final int? orderId;
  final int? orderRawId;
  final int? prescriptionId;
  final String? prescriptionImageUrl;

  int? get effectiveOrderId => orderId ?? orderRawId ?? prescriptionId;
  int? get effectivePrescriptionId => prescriptionId ?? orderId ?? orderRawId;

  @override
  State<PharmacyOrderDetailsScreen> createState() =>
      _PharmacyOrderDetailsScreenState();
}

class _PharmacyOrderDetailsScreenState
    extends State<PharmacyOrderDetailsScreen> {
  static const Color _orange = Color(0xFFFF5C22);

  static const String _prescriptionAsset =
      'lib/pharmacy/Assets/images/Prescription Upload.png';

  late final PharmacyOrderDetailsController _detailsController;

  /// Loading the order and its prescription (paid stages / [openById]).
  bool _resolving = false;

  /// Opened by id and the order has no prescription: OTC layout.
  bool _resolvedOtc = false;

  bool get _paidStageFromCaller =>
      widget.isToPrepare ||
      widget.isPreparing ||
      widget.isReady ||
      widget.isDelivered;

  @override
  void initState() {
    super.initState();
    _detailsController = Get.put(PharmacyOrderDetailsController());
    if (!widget.isOtc && (_paidStageFromCaller || widget.resolveFromServer)) {
      _loadOrderAndPrescription();
      return;
    }
    if (widget.isOtc) {
      final id =
          widget.effectiveOrderId ??
          int.tryParse(
            widget.requestId.replaceAll(RegExp(r'[^0-9]'), '').trim(),
          );
      if (id != null) {
        _detailsController.fetchPharmacyOrderDetail(id);
      }
    } else {
      final prescId =
          widget.effectivePrescriptionId ??
          int.tryParse(
            widget.requestId.replaceAll(RegExp(r'[^0-9]'), '').trim(),
          );
      if (prescId != null) {
        _detailsController.fetchPharmacyPrescriptionDetails(prescId);
      }
    }
  }

  @override
  void dispose() {
    Get.delete<PharmacyOrderDetailsController>();
    super.dispose();
  }

  /// A paid prescription order: the order (`pharmacyOrderDetail`: items,
  /// totals, status logs, prescription id) and the prescription
  /// (`pharmacyPrescriptionDetails`: image, quote, `data.order` with address,
  /// payment and rider). The cards passed the order id as the prescription
  /// id, so a paid order loaded prescription #<order id>: no image, no
  /// items, total 0 (retest 6 Nov, VA-19).
  Future<void> _loadOrderAndPrescription() async {
    _resolving = true; // called from initState, before the first build
    final c = _detailsController;
    int? orderId = widget.orderId ?? widget.orderRawId;
    int? prescId = widget.prescriptionId;
    // Older callers passed one id in all three fields; it is the order id.
    if (orderId != null && prescId == orderId) prescId = null;
    if (orderId == null && prescId == null) {
      orderId = int.tryParse(
        widget.requestId.replaceAll(RegExp(r'[^0-9]'), '').trim(),
      );
    }
    if (orderId != null) {
      await c.fetchPharmacyOrderDetail(orderId);
      prescId ??= c.otcOrder?.prescriptionId;
    }
    if (prescId != null) {
      await c.fetchPharmacyPrescriptionDetails(prescId);
      final linked = c.linkedOrder?.orderId;
      if (c.otcOrder == null && linked != null) {
        await c.fetchPharmacyOrderDetail(linked);
      }
    }
    if (!mounted) return;
    setState(() {
      _resolving = false;
      _resolvedOtc = widget.resolveFromServer &&
          c.otcOrder != null &&
          prescId == null;
    });
  }

  /// Server status of the paid order (1 paid / new, 2 accepted, 3
  /// preparing, 4 ready, 5 picked up, 9 delivered, 10 cancelled); null
  /// before payment or while loading.
  int? get _orderStatus =>
      _detailsController.otcOrder?.status ??
      _detailsController.linkedOrder?.status;

  int? get _paidOrderId =>
      _detailsController.otcOrder?.id ??
      _detailsController.linkedOrder?.orderId ??
      (_paidStageFromCaller ? (widget.orderId ?? widget.orderRawId) : null);

  bool get _awaitingAccept => _orderStatus == 1;
  bool get _isToPrepare => _orderStatus == null
      ? widget.isToPrepare
      : (_orderStatus == 1 || _orderStatus == 2);
  bool get _isPreparing =>
      _orderStatus == null ? widget.isPreparing : _orderStatus == 3;
  bool get _isReady => _orderStatus == null
      ? widget.isReady
      : (_orderStatus == 4 || _orderStatus == 5);
  bool get _isDelivered =>
      _orderStatus == null ? widget.isDelivered : _orderStatus == 9;
  bool get _isCancelled => _orderStatus == 10;
  bool get _isPaidStage =>
      _isToPrepare || _isPreparing || _isReady || _isDelivered || _isCancelled;

  bool get _isSelfPickup =>
      _detailsController.otcOrder?.isSelfPickupBool ?? widget.isSelfPickup;

  bool get _hasRider =>
      (_detailsController.linkedOrder?.riderName ?? '').isNotEmpty ||
      (_detailsController.otcOrder?.deliveryBoyId ?? 0) > 0;

  PharmacyHomeController get _home => Get.isRegistered<PharmacyHomeController>()
      ? Get.find<PharmacyHomeController>()
      : Get.put(PharmacyHomeController());

  /// Runs one of the Home card actions (same controller calls), then goes
  /// back so the list reloads. The detail buttons did nothing (handover §4).
  Future<void> _runAction(Future<bool> Function() call) async {
    if (_detailsController.isActionRunning) return;
    _detailsController.setActionRunning(true);
    bool ok = false;
    try {
      ok = await call();
    } finally {
      _detailsController.setActionRunning(false);
    }
    if (ok && mounted) Navigator.of(context).maybePop();
  }

  /// Accept (paid, new), Start Preparing (accepted) or Ready for Dispatch
  /// (preparing) on a paid prescription order.
  void _onPaidOrderAction() {
    final id = _paidOrderId;
    if (id == null) return;
    if (_awaitingAccept) {
      _runAction(() => _home.acceptPharmacyOrder(id, context: context));
    } else if (_isPreparing) {
      _runAction(() => _home.markAsReadyPharmacyOrder(id, context: context));
    } else {
      _runAction(() => _home.preparePharmacyOrder(id, context: context));
    }
  }

  /// Reject a prescription before payment: the reason sheet, then the same
  /// call as the Home card's Reject.
  Future<void> _rejectPrescription() async {
    final id = _detailsController.prescriptionObj?.prescriptionId ??
        widget.effectivePrescriptionId;
    if (id == null) return;
    final reason = await showPharmacyRejectOrderSheet(context);
    if (reason == null || !mounted) return;
    await _runAction(
      () => _home.rejectPharmacyPrescription(id, note: reason, context: context),
    );
  }

  /// OTC detail buttons: the Home card calls for the order's status.
  void _onOtcPrimary(int orderId, int? status) {
    final accepted = status != null ? status == 2 : widget.isOtcAccepted;
    final preparing = status != null ? status == 3 : widget.isOtcPreparing;
    if (preparing) {
      _runAction(() => _home.markAsReadyPharmacyOrder(orderId, context: context));
    } else if (accepted) {
      _runAction(() => _home.preparePharmacyOrder(orderId, context: context));
    } else {
      _runAction(() => _home.acceptPharmacyOrder(orderId, context: context));
    }
  }

  Future<void> _onOtcReject(int orderId) async {
    final reason = await showPharmacyRejectOrderSheet(context);
    if (reason == null || !mounted) return;
    await _runAction(
      () => _home.cancelPharmacyOrder(orderId, reason: reason, context: context),
    );
  }

  static const _deliveryTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Prescription Received',
      subtitle: 'Feb 07, 2024 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(title: 'Under Review', icon: Icons.assignment_outlined),
    _TimelineStep(title: 'Review Completed', icon: Icons.check_rounded),
    _TimelineStep(title: 'Quotation Sent', icon: Icons.request_quote_outlined),
    _TimelineStep(title: 'Paid', icon: Icons.check_rounded),
    _TimelineStep(
      title: 'Preparing Medicines',
      icon: Icons.medication_outlined,
      customIcon: _TimelineCustomIcon.capsule,
    ),
    _TimelineStep(
      title: 'Ready for Dispatch',
      icon: Icons.inventory_2_outlined,
      customIcon: _TimelineCustomIcon.openBox,
    ),
    _TimelineStep(
      title: 'Delivery Partner Assigned',
      icon: Icons.delivery_dining,
      customIcon: _TimelineCustomIcon.scooter,
    ),
    _TimelineStep(title: 'Order Delivered', icon: Icons.home_outlined),
  ];

  static const _underReviewTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Prescription Received',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Under Review',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.description_outlined,
      completed: true,
    ),
    _TimelineStep(title: 'Review Completed', icon: Icons.check_rounded),
    _TimelineStep(title: 'Quotation Sent', icon: Icons.request_quote_outlined),
    _TimelineStep(title: 'Paid', icon: Icons.check_rounded),
    _TimelineStep(
      title: 'Preparing Medicines',
      icon: Icons.medication_outlined,
      customIcon: _TimelineCustomIcon.capsule,
    ),
    _TimelineStep(
      title: 'Ready for Dispatch',
      icon: Icons.inventory_2_outlined,
      customIcon: _TimelineCustomIcon.openBox,
    ),
    _TimelineStep(
      title: 'Delivery Partner Assigned',
      icon: Icons.delivery_dining,
      customIcon: _TimelineCustomIcon.scooter,
    ),
    _TimelineStep(title: 'Order Delivered', icon: Icons.home_outlined),
  ];

  static const _reviewCompletedTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Prescription Received',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Under Review',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.description_outlined,
      completed: true,
    ),
    _TimelineStep(
      title: 'Review Completed',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(title: 'Quotation Sent', icon: Icons.request_quote_outlined),
    _TimelineStep(title: 'Paid', icon: Icons.check_rounded),
    _TimelineStep(
      title: 'Preparing Medicines',
      icon: Icons.medication_outlined,
      customIcon: _TimelineCustomIcon.capsule,
    ),
    _TimelineStep(
      title: 'Ready for Dispatch',
      icon: Icons.inventory_2_outlined,
      customIcon: _TimelineCustomIcon.openBox,
    ),
    _TimelineStep(
      title: 'Delivery Partner Assigned',
      icon: Icons.delivery_dining,
      customIcon: _TimelineCustomIcon.scooter,
    ),
    _TimelineStep(title: 'Order Delivered', icon: Icons.home_outlined),
  ];

  static const _deliveredTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Prescription Received',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Under Review',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.assignment_outlined,
      completed: true,
    ),
    _TimelineStep(
      title: 'Review Completed',
      subtitle: 'Feb 07, 2026 10:47 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Quotation Sent',
      subtitle: 'Feb 07, 2026 10:48 AM',
      icon: Icons.description_outlined,
      completed: true,
    ),
    _TimelineStep(
      title: 'Paid',
      subtitle: 'Feb 07, 2026 10:50 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Preparing Medicines',
      subtitle: 'Feb 07, 2026 10:50 AM',
      icon: Icons.medication_outlined,
      customIcon: _TimelineCustomIcon.capsule,
      completed: true,
    ),
    _TimelineStep(
      title: 'Ready for Dispatch',
      subtitle: 'Feb 07, 2026 10:50 AM',
      icon: Icons.inventory_2_outlined,
      customIcon: _TimelineCustomIcon.openBox,
      completed: true,
    ),
    _TimelineStep(
      title: 'Delivery Partner Assigned',
      subtitle: 'Feb 07, 2026 10:50 AM',
      icon: Icons.delivery_dining,
      customIcon: _TimelineCustomIcon.scooter,
      completed: true,
    ),
    _TimelineStep(
      title: 'Order Delivered',
      subtitle: 'Feb 07, 2026 10:50 AM',
      icon: Icons.home_outlined,
      completed: true,
    ),
  ];

  static const _readyTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Prescription Received',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Under Review',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.assignment_outlined,
      completed: true,
    ),
    _TimelineStep(
      title: 'Review Completed',
      subtitle: 'Feb 07, 2026 10:47 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Quotation Sent',
      subtitle: 'Feb 07, 2026 10:48 AM',
      icon: Icons.description_outlined,
      completed: true,
    ),
    _TimelineStep(
      title: 'Paid',
      subtitle: 'Feb 07, 2026 10:50 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Preparing Medicines',
      subtitle: 'Feb 07, 2026 10:50 AM',
      icon: Icons.medication_outlined,
      customIcon: _TimelineCustomIcon.capsule,
      completed: true,
    ),
    _TimelineStep(
      title: 'Ready for Dispatch',
      subtitle: 'Feb 07, 2026 10:50 AM',
      icon: Icons.inventory_2_outlined,
      customIcon: _TimelineCustomIcon.openBox,
      completed: true,
    ),
    _TimelineStep(
      title: 'Delivery Partner Assigned',
      subtitle: 'Feb 07, 2026 10:50 AM',
      icon: Icons.delivery_dining,
      customIcon: _TimelineCustomIcon.scooter,
      completed: true,
    ),
    _TimelineStep(title: 'Order Delivered', icon: Icons.home_outlined),
  ];

  static const _preparingTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Prescription Received',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Under Review',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.assignment_outlined,
      completed: true,
    ),
    _TimelineStep(
      title: 'Review Completed',
      subtitle: 'Feb 07, 2026 10:47 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Quotation Sent',
      subtitle: 'Feb 07, 2026 10:48 AM',
      icon: Icons.description_outlined,
      completed: true,
    ),
    _TimelineStep(
      title: 'Paid',
      subtitle: 'Feb 07, 2026 10:50 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Preparing Medicines',
      subtitle: 'Feb 07, 2026 10:50 AM',
      icon: Icons.medication_outlined,
      customIcon: _TimelineCustomIcon.capsule,
      completed: true,
    ),
    _TimelineStep(
      title: 'Ready for Dispatch',
      icon: Icons.inventory_2_outlined,
      customIcon: _TimelineCustomIcon.openBox,
    ),
    _TimelineStep(
      title: 'Delivery Partner Assigned',
      icon: Icons.delivery_dining,
      customIcon: _TimelineCustomIcon.scooter,
    ),
    _TimelineStep(title: 'Order Delivered', icon: Icons.home_outlined),
  ];

  static const _toPrepareTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Prescription Received',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Under Review',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.description_outlined,
      completed: true,
    ),
    _TimelineStep(
      title: 'Review Completed',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Quotation Sent',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.description_outlined,
      completed: true,
    ),
    _TimelineStep(
      title: 'Paid',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Preparing Medicines',
      icon: Icons.medication_outlined,
      customIcon: _TimelineCustomIcon.capsule,
    ),
    _TimelineStep(
      title: 'Ready for Dispatch',
      icon: Icons.inventory_2_outlined,
      customIcon: _TimelineCustomIcon.openBox,
    ),
    _TimelineStep(
      title: 'Delivery Partner Assigned',
      icon: Icons.delivery_dining,
      customIcon: _TimelineCustomIcon.scooter,
    ),
    _TimelineStep(title: 'Order Delivered', icon: Icons.home_outlined),
  ];

  static const _awaitingPaymentTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Prescription Received',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Under Review',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.description_outlined,
      completed: true,
    ),
    _TimelineStep(
      title: 'Review Completed',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Quotation Sent',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.description_outlined,
      completed: true,
    ),
    _TimelineStep(title: 'Paid', icon: Icons.check_rounded),
    _TimelineStep(
      title: 'Preparing Medicines',
      icon: Icons.medication_outlined,
      customIcon: _TimelineCustomIcon.capsule,
    ),
    _TimelineStep(
      title: 'Ready for Dispatch',
      icon: Icons.inventory_2_outlined,
      customIcon: _TimelineCustomIcon.openBox,
    ),
    _TimelineStep(
      title: 'Delivery Partner Assigned',
      icon: Icons.delivery_dining,
      customIcon: _TimelineCustomIcon.scooter,
    ),
    _TimelineStep(title: 'Order Delivered', icon: Icons.home_outlined),
  ];

  static const _selfPickupTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Prescription Received',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(title: 'Under Review', icon: Icons.assignment_outlined),
    _TimelineStep(title: 'Review Completed', icon: Icons.check_rounded),
    _TimelineStep(title: 'Quotation Sent', icon: Icons.request_quote_outlined),
    _TimelineStep(title: 'Paid', icon: Icons.check_rounded),
    _TimelineStep(
      title: 'Preparing Medicines',
      icon: Icons.medication_outlined,
      customIcon: _TimelineCustomIcon.capsule,
    ),
    _TimelineStep(
      title: 'Ready for Pickup',
      icon: Icons.inventory_2_outlined,
      customIcon: _TimelineCustomIcon.openBox,
    ),
    _TimelineStep(title: 'Order Delivered', icon: Icons.home_outlined),
  ];

  /// The step list for the current stage. The server status
  /// ([underReview] / [reviewed] / [quoted]) moves the timeline on as well,
  /// so a screen opened from a stale list still shows the real stage.
  List<_TimelineStep> _timelineFor({
    required bool underReview,
    required bool reviewed,
    required bool quoted,
  }) {
    if (_isDelivered) return _deliveredTimeline;
    if (_isReady) return _readyTimeline;
    if (_isPreparing) return _preparingTimeline;
    if (_isToPrepare || _isCancelled) return _toPrepareTimeline;
    if (quoted) return _awaitingPaymentTimeline;
    if (reviewed) return _reviewCompletedTimeline;
    if (underReview) return _underReviewTimeline;
    if (_isSelfPickup) return _selfPickupTimeline;
    return _deliveryTimeline;
  }

  /// Times for the paid steps: "Paid" from the prescription's `accepted_at`
  /// (else the order's `placed_at`), the others from the order status logs.
  Map<String, String> _paidStepTimes() {
    final c = _detailsController;
    final times = <String, String>{};
    String? fmt(String? raw) =>
        (raw ?? '').trim().isEmpty ? null : formatServerDateTime(raw);
    String? logTime(int status) {
      for (final log in c.otcOrderDetailData?.statusLogs ?? const []) {
        if (log.status == status) return fmt(log.createdAt);
      }
      return null;
    }

    final paid = fmt(c.prescriptionObj?.acceptedAt) ?? fmt(c.otcOrder?.placedAt);
    if (paid != null) times['Paid'] = paid;
    final preparing = logTime(3);
    if (preparing != null) times['Preparing Medicines'] = preparing;
    final ready = logTime(4);
    if (ready != null) times['Ready for Dispatch'] = ready;
    final delivered = logTime(9) ?? fmt(c.otcOrder?.deliveredAt);
    if (delivered != null) times['Order Delivered'] = delivered;
    return times;
  }

  /// Only real times: the first step gets [createdTime] and "Quotation
  /// Sent" gets the server's `quoted_at`; the step lists carry fixed sample
  /// dates ("Feb 07, 2026 10:45 AM") that are never shown.
  ///
  /// Figma (pharmacy check, 6 Nov): a self-pickup order reads "Ready for
  /// Pickup" and has no "Delivery Partner Assigned" step at every stage.
  List<_TimelineStep> _buildTimeline(
    String? createdTime, {
    String? quotedTime,
    bool underReview = false,
    bool reviewed = false,
    bool quoted = false,
  }) {
    final hasCreated = createdTime != null && createdTime.isNotEmpty;
    final hasQuoted = quotedTime != null && quotedTime.isNotEmpty;
    final selfPickup = _isSelfPickup;
    final paidTimes = _isPaidStage ? _paidStepTimes() : const <String, String>{};
    final steps = _timelineFor(
      underReview: underReview,
      reviewed: reviewed,
      quoted: quoted,
    ).where(
      (s) => !(selfPickup && s.title == 'Delivery Partner Assigned'),
    );
    return steps.toList().asMap().entries.map((entry) {
      final step = entry.value;
      // "Delivery Partner Assigned" is ticked only when the order has a
      // rider (it was ticked on every Ready order, with no rider).
      final completed = step.title == 'Delivery Partner Assigned'
          ? (_hasRider || _isDelivered)
          : step.completed;
      String? subtitle;
      if (entry.key == 0 && hasCreated) {
        subtitle = createdTime;
      } else if (step.title == 'Quotation Sent' && completed && hasQuoted) {
        subtitle = quotedTime;
      } else if (completed) {
        subtitle = paidTimes[step.title];
      }
      return _TimelineStep(
        title: selfPickup && step.title == 'Ready for Dispatch'
            ? 'Ready for Pickup'
            : step.title,
        subtitle: subtitle,
        icon: step.icon,
        customIcon: step.customIcon,
        completed: completed,
      );
    }).toList();
  }

  void _openCreateQuotation() {
    final presc = _detailsController.prescriptionObj;
    final customerName = presc?.customerName?.trim().isNotEmpty == true
        ? presc!.customerName!
        : (widget.customerName.isNotEmpty ? widget.customerName : S.of(context).quoteCustomer);
    final phone = presc?.displayPhone.trim().isNotEmpty == true
        ? presc!.displayPhone
        : (widget.phone.isNotEmpty ? widget.phone : '');
    final requestId = presc?.prescriptionId != null
        ? '#${presc!.prescriptionId}'
        : (widget.requestId.isNotEmpty ? widget.requestId : '');
    final requestMeta = presc?.createdAt?.trim().isNotEmpty == true
        ? formatServerDateTime(presc!.createdAt)
        : (widget.requestMeta.isNotEmpty ? widget.requestMeta : '');
    final primaryImageUrl =
        _detailsController.prescriptionDetailData?.primaryImageUrl ??
        widget.prescriptionImageUrl;
    final int? effectivePrescriptionId =
        presc?.prescriptionId ??
        widget.prescriptionId ??
        widget.orderRawId ??
        int.tryParse(widget.orderId?.toString() ?? '');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PharmacyCreateQuotationScreen(
          customerName: customerName,
          phone: phone,
          requestId: requestId,
          requestMeta: requestMeta,
          imageUrl: primaryImageUrl,
          imageBytes: _detailsController.prescriptionImageBytes,
          prescriptionId: effectivePrescriptionId,
        ),
      ),
    );
  }

  /// "Mark as Reviewed": same API calls as the Home card. An `uploaded`
  /// prescription is moved to under review first, as the server expects.
  Future<void> _markReviewed() async {
    final id = _detailsController.prescriptionObj?.prescriptionId ??
        widget.effectivePrescriptionId;
    if (id == null) return;
    final home = Get.isRegistered<PharmacyHomeController>()
        ? Get.find<PharmacyHomeController>()
        : Get.put(PharmacyHomeController());
    final status =
        _detailsController.prescriptionObj?.status?.trim().toLowerCase();
    if (status == 'uploaded' &&
        !await home.reviewPharmacyPrescription(id, context: context)) {
      return;
    }
    final ok = await home.markPharmacyPrescriptionReviewed(id, context: context);
    if (ok && mounted) {
      await _detailsController.fetchPharmacyPrescriptionDetails(id);
    }
  }

  void _openFullPrescription() {
    final primaryImageUrl =
        _detailsController.prescriptionDetailData?.primaryImageUrl ??
        widget.prescriptionImageUrl;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullPrescriptionViewer(
          imageUrl: primaryImageUrl,
          imageBytes: _detailsController.prescriptionImageBytes,
          rotationTurns: _detailsController.rotationTurns,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOtc || _resolvedOtc) {
      return GetBuilder<PharmacyOrderDetailsController>(
        builder: (detailsCtrl) {
          final order = detailsCtrl.otcOrder;
          // The loaded order's status decides the stage and buttons; the
          // card's flags are used until it has loaded.
          final s = order?.status;
          final orderId = order?.id ?? widget.effectiveOrderId;
          return _OtcOrderDetailsPage(
            orderId: orderId,
            orderRawId: orderId,
            isLoading: detailsCtrl.isLoadingOrderDetail,
            orderDetailData: detailsCtrl.orderDetailData,
            name: widget.customerName.isNotEmpty
                ? widget.customerName
                : (order?.customerName ?? '').trim(),
            phone: widget.phone.isNotEmpty
                ? widget.phone
                : order?.displayCustomerMobile ?? '',
            requestId: widget.requestId.isNotEmpty
                ? widget.requestId
                : order?.displayOrderCode ?? '',
            requestMeta: widget.requestMeta.isNotEmpty
                ? widget.requestMeta
                : formatServerDateTime(order?.placedAt ?? order?.createdAt),
            selfPickup: order?.isSelfPickupBool ?? widget.isSelfPickup,
            cashOnDelivery: order != null
                ? order.isCashOnDeliveryBool
                : widget.cashOnDelivery,
            accepted: s != null ? s == 2 : widget.isOtcAccepted,
            preparing: s != null ? s == 3 : widget.isOtcPreparing,
            ready: s != null ? (s == 4 || s == 5) : widget.isOtcReady,
            partnerAssigned: s != null
                ? ((order?.deliveryBoyId ?? 0) > 0 || s == 5)
                : widget.isOtcPartnerAssigned,
            delivered: s != null ? s == 9 : widget.isOtcDelivered,
            cancelled: s != null ? s == 10 : widget.isOtcCancelled,
            actionRunning: detailsCtrl.isActionRunning,
            onPrimary: orderId == null
                ? null
                : () => _onOtcPrimary(orderId, s),
            onReject: orderId == null ? null : () => _onOtcReject(orderId),
          );
        },
      );
    }
    if (_resolving) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: _orange,
          elevation: 0,
          title: Text(S.of(context).orderDetails),
        ),
        body: const Center(child: CircularProgressIndicator(color: _orange)),
      );
    }
    return GetBuilder<PharmacyOrderDetailsController>(
      builder: (controller) {
        final prescObj = controller.prescriptionObj;
        final prescData = controller.prescriptionDetailData;
        final primaryImageUrl =
            prescData?.primaryImageUrl ?? widget.prescriptionImageUrl;

        final rawCustName = prescObj?.customerName?.trim();
        final effectiveCustomerName =
            (rawCustName != null && rawCustName.isNotEmpty)
            ? rawCustName
            : (widget.customerName.isNotEmpty
                  ? widget.customerName
                  : (rawCustName ?? S.of(context).quoteCustomer));

        final initial = effectiveCustomerName.isNotEmpty
            ? effectiveCustomerName.substring(0, 1).toUpperCase()
            : 'C';

        final rawPhone = prescObj?.displayPhone.trim();
        final effectivePhone = (rawPhone != null && rawPhone.isNotEmpty)
            ? rawPhone
            : (widget.phone.isNotEmpty
                  ? widget.phone
                  : (rawPhone ?? ''));

        final paidOrder = controller.otcOrder;
        final linkedOrder = controller.linkedOrder;
        final paidStage = _isPaidStage;
        // A paid order is known by its order code (as on the list card).
        final paidOrderCode = (linkedOrder?.orderCode ?? '').isNotEmpty
            ? linkedOrder!.orderCode!
            : (paidOrder?.displayOrderCode ?? '');
        final effectiveRequestId = paidStage && paidOrderCode.isNotEmpty
            ? paidOrderCode
            : prescObj?.prescriptionId != null
            ? '#${prescObj!.prescriptionId}'
            : (widget.requestId.isNotEmpty
                  ? widget.requestId
                  : (prescObj?.displayOrderCode ?? widget.requestId));
        // Address, payment and rider of the paid order (`data.order`, else
        // the order detail). Hidden when the server has none.
        final deliveryAddress = (linkedOrder?.deliveryAddress ?? '').isNotEmpty
            ? linkedOrder!.deliveryAddress
            : paidOrder?.location;
        final paymentType = linkedOrder?.paymentType ?? paidOrder?.paymentType;

        final rawCreatedAt = prescObj?.createdAt?.trim();
        final effectiveRequestMeta =
            (rawCreatedAt != null && rawCreatedAt.isNotEmpty)
            ? formatServerDateTime(rawCreatedAt)
            : (widget.requestMeta.isNotEmpty
                  ? widget.requestMeta
                  : (rawCreatedAt ?? ''));

        final rawNote = prescObj?.note?.trim();
        final effectiveNote = (rawNote != null && rawNote.isNotEmpty)
            ? rawNote
            : (widget.specialNotes.isNotEmpty
                  ? widget.specialNotes
                  : (rawNote ?? ''));

        final hasNote =
            effectiveNote.isNotEmpty ||
            widget.notesType == PharmacyOrderNotesType.voice;

        final statusStr = prescObj?.status?.trim().toLowerCase();
        final isEffectiveReviewing = !paidStage &&
            (widget.isUnderReview ||
                statusStr == 'uploaded' ||
                statusStr == 'under_review' ||
                statusStr == 'under review' ||
                statusStr == 'reviewing');
        final isEffectiveReviewCompleted = !paidStage &&
            (widget.isReviewCompleted ||
                statusStr == 'review_completed' ||
                statusStr == 'reviewed');
        final isEffectiveAwaitingPayment = !paidStage &&
            (widget.isAwaitingPayment ||
                statusStr == 'awaiting_payment' ||
                statusStr == 'quoted');
        // Paid, but no longer open for review / quote actions.
        final isClosedPrescription = !paidStage &&
            (statusStr == 'accepted' ||
                statusStr == 'ordered' ||
                statusStr == 'rejected');

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFF0E8),
                          Color(0xFFFFF8F4),
                          Color(0xFFFFFFFF),
                        ],
                        stops: [0, 0.16, 1],
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery.paddingOf(context).top + 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            height: 44,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  S.of(context).orderDetails,
                                  style: appFont('Inter', 
                                    color: const Color(0xFF1A1A1A),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    letterSpacing: -0.2,
                                    height: 1.2,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: InkWell(
                                    onTap: () =>
                                        Navigator.of(context).maybePop(),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFFFE0D0),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.04,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.chevron_left_rounded,
                                        color: _orange,
                                        size: 26,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (controller.isLoadingPrescriptionDetail &&
                            controller.prescriptionDetailData == null)
                          const Expanded(
                            child: Center(
                              child: CircularProgressIndicator(color: _orange),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              children: [
                                if (paidStage)
                                  _ToPrepareInfoCard(
                                    initial: initial,
                                    name: effectiveCustomerName,
                                    phone: effectivePhone,
                                    requestId: effectiveRequestId,
                                    requestMeta: effectiveRequestMeta,
                                    preparing: _isPreparing,
                                    ready: _isReady,
                                    delivered: _isDelivered,
                                    cancelled: _isCancelled,
                                    selfPickup: _isSelfPickup,
                                    address: _isSelfPickup
                                        ? null
                                        : deliveryAddress,
                                    paymentType: paymentType,
                                    onChatTap: () => _openCustomerChat(
                                      context,
                                      customerName: effectiveCustomerName,
                                      customerId: prescObj?.userId,
                                    ),
                                  )
                                else
                                  _CustomerCard(
                                    initial: initial,
                                    name: effectiveCustomerName,
                                    phone: effectivePhone,
                                    requestId: effectiveRequestId,
                                    requestMeta: effectiveRequestMeta,
                                    // Badge: NEW until the pharmacy starts the review (server 'uploaded');
                                    // the review actions below still show (test 10 Nov, #21).
                                    reviewing: isEffectiveReviewing && statusStr != 'uploaded',
                                    reviewCompleted: isEffectiveReviewCompleted,
                                    awaitingPayment: isEffectiveAwaitingPayment,
                                    onChatTap: () => _openCustomerChat(
                                      context,
                                      customerName: effectiveCustomerName,
                                      customerId: prescObj?.userId,
                                    ),
                                  ),
                                const SizedBox(height: 14),
                                // Only the order's real rider (`data.order.rider`);
                                // nothing while none is assigned.
                                if (paidStage &&
                                    (linkedOrder?.riderName ?? '').isNotEmpty) ...[
                                  _DeliveryPartnerSection(
                                    showPhone: true,
                                    name: linkedOrder!.riderName,
                                    phone: linkedOrder.riderPhone,
                                    image: linkedOrder.riderImageUrl,
                                  ),
                                  const SizedBox(height: 18),
                                ],
                                _UploadedPrescriptionCard(
                                  imageUrl: primaryImageUrl,
                                  imageBytes: controller.prescriptionImageBytes,
                                  isLoading:
                                      controller.isLoadingPrescriptionImage ||
                                      controller.isLoadingPrescriptionDetail,
                                  rotationTurns: controller.rotationTurns,
                                  onZoom: _openFullPrescription,
                                  onRotate: controller.rotatePrescription,
                                  onViewFull: _openFullPrescription,
                                ),
                                const SizedBox(height: 18),
                                if (hasNote) ...[
                                  Text(
                                    S.of(context).pharmacyDetailSpecialNotes,
                                    style: appFont('Inter', 
                                      color: const Color(0xFFA0A9B8),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (widget.notesType ==
                                      PharmacyOrderNotesType.voice)
                                    _SpecialNotesVoiceCard(
                                      duration: widget.voiceNoteDuration,
                                    )
                                  else
                                    _SpecialNotesTextCard(note: effectiveNote),
                                  const SizedBox(height: 18),
                                ],
                                if (isEffectiveAwaitingPayment || paidStage) ...[
                                  // The quote lines; for a paid order without
                                  // them, the order's own items.
                                  if (paidStage &&
                                      controller.prescriptionQuoteItems.isEmpty &&
                                      controller.otcItems.isNotEmpty)
                                    _PaidOrderItems(items: controller.otcItems)
                                  else
                                    _AwaitingPaymentItems(
                                      items: controller.prescriptionQuoteItems,
                                    ),
                                  const SizedBox(height: 16),
                                  _AwaitingPaymentSummary(
                                    // A paid order: what was charged.
                                    totalAmount: paidStage
                                        ? (linkedOrder?.total ??
                                              paidOrder?.total ??
                                              prescObj?.quoteAmount)
                                        : prescObj?.quoteAmount,
                                    items: controller.prescriptionQuoteItems,
                                    itemTotal: paidStage &&
                                            controller.prescriptionQuoteItems.isEmpty
                                        ? paidOrder?.subtotal
                                        : null,
                                    deliveryFee:
                                        paidStage ? paidOrder?.deliveryFee : null,
                                    tax: paidStage ? paidOrder?.tax : null,
                                  ),
                                  if (isEffectiveAwaitingPayment) ...[
                                    const SizedBox(height: 12),
                                    _AwaitingCustomerPaymentCard(
                                      // When the quote went out (quoted_at);
                                      // nothing when the server has no time.
                                      time: (prescObj?.quotedAt ?? '')
                                              .trim()
                                              .isNotEmpty
                                          ? formatServerDateTime(
                                              prescObj!.quotedAt,
                                            )
                                          : null,
                                    ),
                                  ],
                                  const SizedBox(height: 18),
                                ],
                                Text(
                                  S.of(context).pharmacyDetailOrderTimeline,
                                  style: appFont('Inter', 
                                    color: const Color(0xFFA0A9B8),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _TimelineCard(
                                  steps: _buildTimeline(
                                    effectiveRequestMeta,
                                    quotedTime: (prescObj?.quotedAt ?? '')
                                            .trim()
                                            .isNotEmpty
                                        ? formatServerDateTime(
                                            prescObj!.quotedAt,
                                          )
                                        : null,
                                    underReview: widget.isUnderReview ||
                                        statusStr == 'under_review',
                                    reviewed: isEffectiveReviewCompleted,
                                    quoted: isEffectiveAwaitingPayment,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_isToPrepare || _isPreparing)
                  _StartPreparingBar(
                    label: _awaitingAccept
                        ? S.of(context).acceptOrder
                        : _isPreparing
                        ? S.of(context).pharmacyDetailReadyForDispatch
                        : S.of(context).pharmacyDetailStartPreparing,
                    busy: controller.isActionRunning,
                    onPressed: _paidOrderId == null ? null : _onPaidOrderAction,
                  )
                else if (!isEffectiveAwaitingPayment &&
                    !paidStage &&
                    !isClosedPrescription)
                  _BottomActions(
                    onReject: _rejectPrescription,
                    onReview: isEffectiveReviewCompleted
                        ? _openCreateQuotation
                        : isEffectiveReviewing
                        ? _markReviewed
                        : _openFullPrescription,
                    primaryLabel: isEffectiveReviewCompleted
                        ? S.of(context).quoteCreateTitle
                        : isEffectiveReviewing
                        ? S.of(context).pharmacyDetailMarkReviewed
                        : S.of(context).pharmacyDetailReviewPrescription,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.initial,
    required this.name,
    required this.phone,
    required this.requestId,
    required this.requestMeta,
    this.reviewing = false,
    this.reviewCompleted = false,
    this.awaitingPayment = false,
    this.onChatTap,
  });

  final String initial;
  final String name;
  final String phone;
  final String requestId;
  final String requestMeta;
  final bool reviewing;
  final bool reviewCompleted;
  final bool awaitingPayment;
  final VoidCallback? onChatTap;

  static const Color _accent = Color(0xFFFF5216);
  static const Color _avatarLetter = Color(0xFFE64A19);
  static const Color _chatOrange = Color(0xFFFF5216);
  static const Color _newBadge = Color(0xFFF9A825);
  static const Color _reviewingBadge = Color(0xFF7B61FF);
  static const Color _completedBadge = Color(0xFF22C55E);
  static const Color _awaitingBadge = Color(0xFFF5C400);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5C22).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_search_rounded, color: _accent, size: 20),
              const SizedBox(width: 6),
              Text(
                S.of(context).pharmacyDetailCustomerHeader,
                style: appFont('Inter', 
                  color: _accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.7,
                  height: 1.1,
                ),
              ),
              const Spacer(),
              // Figma: the Awaiting Payment detail keeps its status badge.
              Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: reviewCompleted || awaitingPayment
                        ? 8
                        : reviewing
                        ? 14
                        : 12,
                    vertical: reviewing ? 6 : 5,
                  ),
                  decoration: BoxDecoration(
                    color: awaitingPayment
                        ? _awaitingBadge
                        : reviewCompleted
                        ? _completedBadge
                        : reviewing
                        ? _reviewingBadge
                        : _newBadge,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    awaitingPayment
                        ? S.of(context).pharmacyDetailBadgeAwaitingPayment
                        : reviewCompleted
                        ? S.of(context).pharmacyDetailBadgeReviewCompleted
                        : reviewing
                        ? S.of(context).pharmacyDetailBadgeReviewing
                        : S.of(context).pharmacyDetailBadgeNew,
                    style: appFont('Inter', 
                      color: Colors.white,
                      fontSize: reviewCompleted || awaitingPayment
                          ? 9
                          : reviewing
                          ? 11
                          : 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: reviewCompleted || awaitingPayment
                          ? 0.2
                          : reviewing
                          ? 0.6
                          : 0.5,
                      height: 1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7F8),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initial,
                    style: appFont('Inter', 
                      color: _avatarLetter,
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
                        name,
                        style: appFont('Inter', 
                          color: const Color(0xFF212121),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        phone,
                        style: appFont('Inter', 
                          color: const Color(0xFF757575),
                          fontWeight: FontWeight.w400,
                          fontSize: 13.5,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onChatTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _chatOrange,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _chatOrange.withValues(alpha: 0.32),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'lib/home_cleaning/Assets/images/chat.png',
                      width: 22,
                      height: 22,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8F9),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).pharmacyDetailRequestId,
                  style: appFont('Inter', 
                    color: const Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    letterSpacing: 0.6,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: isolated(requestId),
                        style: appFont('Inter', 
                          color: _accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: '  •  $requestMeta',
                        style: appFont('Inter', 
                          color: const Color(0xFF616161),
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                    ],
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



class _UploadedPrescriptionCard extends StatelessWidget {
  const _UploadedPrescriptionCard({
    this.assetPath,
    this.imageUrl,
    this.imageBytes,
    this.isLoading = false,
    required this.rotationTurns,
    required this.onZoom,
    required this.onRotate,
    required this.onViewFull,
  });

  final String? assetPath;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final bool isLoading;
  final double rotationTurns;
  final VoidCallback onZoom;
  final VoidCallback onRotate;
  final VoidCallback onViewFull;

  static const Color _orange = Color(0xFFFF5C22);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).pharmacyDetailUploadedPrescription,
            style: appFont('Inter', 
              color: const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.6,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 1.12,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: const Color(0xFFF3F3F3),
                    child: AnimatedRotation(
                      turns: rotationTurns,
                      duration: const Duration(milliseconds: 280),
                      child: (imageBytes != null && imageBytes!.isNotEmpty)
                          ? Image.memory(imageBytes!, fit: BoxFit.cover)
                          : (imageUrl != null && imageUrl!.trim().isNotEmpty)
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: _orange,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, error, __) => Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.broken_image_outlined,
                                      size: 44,
                                      color: Color(0xFF9E9E9E),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      S.of(context).pharmacyDetailImageLoadFailed,
                                      style: const TextStyle(
                                        color: Color(0xFF9E9E9E),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : (isLoading
                                ? const Center(
                                    child: SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: _orange,
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.description_outlined,
                                          size: 44,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          S.of(context).pharmacyDetailNoPrescriptionImage,
                                          style: const TextStyle(
                                            color: Color(0xFF9E9E9E),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ImageActionChip(
                          icon: Icons.zoom_in_rounded,
                          label: S.of(context).pharmacyDetailZoom,
                          onTap: onZoom,
                          color: const Color(0xFFE67E22),
                        ),
                        const SizedBox(width: 8),
                        _ImageActionChip(
                          icon: Icons.rotate_right_rounded,
                          label: S.of(context).pharmacyDetailRotate,
                          onTap: onRotate,
                          color: const Color(0xFF544C4C),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: onViewFull,
              style: OutlinedButton.styleFrom(
                foregroundColor: _orange,
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFFFCDB8), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.open_in_new_rounded,
                    size: 17,
                    color: _orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    S.of(context).pharmacyDetailViewFullPrescription,
                    style: appFont('Inter', 
                      color: _orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageActionChip extends StatelessWidget {
  const _ImageActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: appFont('Inter', 
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialNotesTextCard extends StatelessWidget {
  const _SpecialNotesTextCard({required this.note});

  final String note;

  static const Color _orange = Color(0xFFFF5C22);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.description_outlined, color: _orange, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              note,
              style: appFont('Inter', 
                color: const Color(0xFF6B5E52),
                fontWeight: FontWeight.w500,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialNotesVoiceCard extends StatefulWidget {
  const _SpecialNotesVoiceCard({required this.duration});

  final Duration duration;

  @override
  State<_SpecialNotesVoiceCard> createState() => _SpecialNotesVoiceCardState();
}

class _SpecialNotesVoiceCardState extends State<_SpecialNotesVoiceCard>
    with SingleTickerProviderStateMixin {
  static const Color _orange = Color(0xFFFF5C22);
  static const Color _waveIdle = Color(0xFFC9D0DB);

  static const _heights = <double>[
    0.35,
    0.55,
    0.42,
    0.78,
    0.50,
    0.92,
    0.60,
    0.70,
    0.45,
    0.85,
    0.38,
    0.62,
    0.90,
    0.48,
    0.72,
    0.40,
    0.68,
    0.55,
    0.82,
    0.46,
    0.74,
    0.58,
    0.36,
    0.80,
    0.52,
    0.66,
    0.44,
    0.76,
    0.50,
    0.60,
    0.42,
    0.70,
    0.48,
    0.64,
    0.38,
    0.72,
  ];

  late final AnimationController _controller;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _playing = false);
          _controller.value = 0;
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _playing = !_playing;
      if (_playing) {
        _controller.forward();
      } else {
        _controller.stop();
      }
    });
  }

  String get _durationLabel {
    final total = widget.duration.inSeconds;
    final mins = total ~/ 60;
    final secs = total % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Material(
            color: _orange,
            shape: const CircleBorder(),
            elevation: 0,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _toggle,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: _playing ? 22 : 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final progress = _controller.value;
                return SizedBox(
                  height: 28,
                  child: CustomPaint(
                    painter: _VoiceWaveformPainter(
                      heights: _heights,
                      progress: progress.clamp(0.0, 1.0),
                      activeColor: _orange,
                      idleColor: _waveIdle,
                    ),
                    size: Size.infinite,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _durationLabel,
            style: appFont('Inter', 
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceWaveformPainter extends CustomPainter {
  const _VoiceWaveformPainter({
    required this.heights,
    required this.progress,
    required this.activeColor,
    required this.idleColor,
  });

  final List<double> heights;
  final double progress;
  final Color activeColor;
  final Color idleColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (heights.isEmpty) return;

    const barWidth = 2.4;
    final gap =
        (size.width - (heights.length * barWidth)) / (heights.length - 1);
    final activeCount = (heights.length * progress).floor();

    for (var i = 0; i < heights.length; i++) {
      final h = heights[i].clamp(0.18, 1.0) * size.height;
      final x = i * (barWidth + gap);
      final top = (size.height - h) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barWidth, h),
        const Radius.circular(1.2),
      );
      final paint = Paint()
        ..color = progress == 0
            ? (i < 8 ? activeColor : idleColor)
            : (i < activeCount ? activeColor : idleColor);
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceWaveformPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.idleColor != idleColor;
}

class _ToPrepareInfoCard extends StatelessWidget {
  const _ToPrepareInfoCard({
    required this.initial,
    required this.name,
    required this.phone,
    required this.requestId,
    required this.requestMeta,
    this.preparing = false,
    this.ready = false,
    this.delivered = false,
    this.onChatTap,
    this.address,
    this.selfPickup = false,
    this.cancelled = false,
    this.paymentType,
  });

  /// Delivery address when known; the block is hidden otherwise.
  final String? address;

  /// The order's `payment_type`; the payment pill is hidden when unknown.
  final dynamic paymentType;
  final bool cancelled;
  final bool selfPickup;
  final String initial;
  final String name;
  final String phone;
  final String requestId;
  final String requestMeta;
  final bool preparing;
  final bool ready;
  final bool delivered;
  final VoidCallback? onChatTap;

  static const Color _accent = Color(0xFFFF5216);
  static const Color _blue = Color(0xFF3B82F6);
  static const Color _ready = Color(0xFF22C55E);
  static const Color _panel = Color(0xFFF6F7F8);
  static const Color _label = Color(0xFFB0B0B0);
  static const Color _meta = Color(0xFF8E8E8E);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5C22).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_search_rounded, color: _accent, size: 18),
              const SizedBox(width: 6),
              Text(
                S.of(context).pharmacyDetailCustomerHeader,
                style: appFont('Inter', 
                  color: _accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.6,
                  height: 1.1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cancelled
                      ? const Color(0xFFE11D48)
                      : ready || delivered
                      ? _ready
                      : preparing
                      ? _accent
                      : _blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cancelled
                      ? S.of(context).cancelled.toUpperCase()
                      : delivered
                      ? S.of(context).pharmacyDetailBadgeDelivered
                      : ready
                      ? S.of(context).pharmacyDetailBadgeReady
                      : preparing
                      ? S.of(context).pharmacyDetailBadgePreparing
                      : S.of(context).pharmacyDetailBadgeToPrepare,
                  style: appFont('Inter', 
                    color: Colors.white,
                    fontSize: delivered ? 9 : 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF0F0),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initial,
                    style: appFont('Inter', 
                      color: const Color(0xFFE24B3B),
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
                        name,
                        style: appFont('Inter', 
                          color: const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: appFont('Inter', 
                          color: _meta,
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onChatTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      'lib/home_cleaning/Assets/images/chat.png',
                      width: 22,
                      height: 22,
                      color: Colors.white,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).pharmacyDetailRequestId,
                        style: appFont('Inter', 
                          color: _label,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          letterSpacing: 0.4,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: isolated(requestId),
                              style: appFont('Inter', 
                                color: _accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                height: 1.2,
                              ),
                            ),
                            TextSpan(
                              text: '  •  $requestMeta',
                              style: appFont('Inter', 
                                color: _meta,
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).pharmacyDetailDeliveryType,
                        style: appFont('Inter', 
                          color: _label,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          letterSpacing: 0.3,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (selfPickup)
                            const Icon(
                              Icons.shopping_bag_outlined,
                              size: 16,
                              color: _accent,
                            )
                          else
                            Image.asset(
                              'lib/pharmacy/Assets/images/delivery_icon.png',
                              width: 16,
                              height: 16,
                              fit: BoxFit.contain,
                            ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              // Figma: "Delivery" or "Self Pickup", from the
                              // order's is_self_pickup (was always Delivery).
                              selfPickup
                                  ? S.of(context).selfPickup
                                  : S.of(context).delivery,
                              style: appFont('Inter', 
                                color: _accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                height: 1.1,
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
          // The order's real payment method (`data.order.payment_type`): a
          // fixed "Online payment" pill was shown for every order, also
          // wallet ones (VA-22). Hidden when the server sends none.
          if (paymentTypeCode(paymentType) != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4EA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    isCashPayment(paymentType)
                        ? 'lib/pharmacy/Assets/images/cashondelivery.png'
                        : 'lib/pharmacy/Assets/images/online_payment.png',
                    width: 16,
                    height: 16,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    paymentTypeLabel(paymentType),
                    style: appFont('Inter',
                      color: _accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Only a real address (`data.order.delivery_address`): this showed
          // a fixed sample ("Sahara View Home").
          if ((address ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: _accent, size: 18),
              const SizedBox(width: 6),
              Text(
                S.of(context).deliveryAddress,
                style: appFont('Inter', 
                  color: _accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.6,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF4EA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.home_outlined,
                    color: _accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address!.trim(),
                        style: appFont('Inter',
                          color: const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.2,
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

/// The quote as the server stored it (§6.15): each requested medicine with
/// its availability, and under an unavailable one the alternative offered
/// with the customer's answer.
class _AwaitingPaymentItems extends StatelessWidget {
  const _AwaitingPaymentItems({required this.items});

  final List<PharmacyPrescriptionQuoteItem> items;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final lang = LocalizationService.currentLanguageCode;
    final mains = items.where((i) => !i.isAlternative).toList();
    final alts = items.where((i) => i.isAlternative).toList();
    final used = <PharmacyPrescriptionQuoteItem>{};
    List<PharmacyPrescriptionQuoteItem> altsFor(PharmacyPrescriptionQuoteItem m) {
      final names = {m.nameEn, m.name}.whereType<String>().map((e) => e.toLowerCase()).toSet();
      final found = alts.where((a) => names.contains(a.alternativeFor!.toLowerCase())).toList();
      used.addAll(found);
      return found;
    }

    final cards = <Widget>[];
    var n = 0;
    for (final m in mains) {
      n++;
      cards.add(_AwaitingItemCard(index: n, item: m, alternatives: altsFor(m), lang: lang));
    }
    for (final a in alts.where((a) => !used.contains(a))) {
      n++;
      cards.add(_AwaitingItemCard(index: n, item: a, alternatives: const [], lang: lang));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.quoteOrderItems('${mains.length}'),
          style: appFont('Inter', 
            color: const Color(0xFFB0B7C3),
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.4,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        if (cards.isEmpty)
          Text(s.quoteNoItems, style: appFont('Inter', color: const Color(0xFF6B7280), fontSize: 13))
        else
          for (final c in cards) ...[c, const SizedBox(height: 12)],
      ],
    );
  }
}

/// A paid order's own lines (`pharmacyOrderDetail.items`), shown when the
/// prescription has no quote lines.
class _PaidOrderItems extends StatelessWidget {
  const _PaidOrderItems({required this.items});

  final List<PharmacyOrderItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).quoteOrderItems('${items.length}'),
          style: appFont('Inter',
            color: const Color(0xFFB0B7C3),
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.4,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _OtcItemCard(
            name: items[i].displayName,
            price: '${_qAmount(_qNum(items[i].totalPrice ?? items[i].unitPrice))} MRU',
            image: items[i].displayImageUrl ?? '',
            quantity: items[i].quantity ?? 1,
          ),
        ],
      ],
    );
  }
}

num _qNum(String? v) => num.tryParse(v ?? '') ?? 0;

String _qAmount(num v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

/// What the customer pays for this line: available/partial lines, and
/// alternatives they accepted.
num quoteLineCharged(PharmacyPrescriptionQuoteItem i) {
  if (i.availability == 'unavailable') return 0;
  if (i.isAlternative && i.customerDecision != 'accepted') return 0;
  final total = num.tryParse(i.totalPrice ?? '');
  return total ?? _qNum(i.quantity) * _qNum(i.price);
}

class _AwaitingItemCard extends StatelessWidget {
  const _AwaitingItemCard({
    required this.index,
    required this.item,
    required this.alternatives,
    required this.lang,
  });

  final int index;
  final PharmacyPrescriptionQuoteItem item;
  final List<PharmacyPrescriptionQuoteItem> alternatives;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final availability = switch (item.availability) {
      'partial' => _Availability.limited,
      'unavailable' => _Availability.outOfStock,
      _ => _Availability.inStock,
    };
    final qty = int.tryParse(item.quantity ?? '') ?? 0;
    final alt = alternatives.isNotEmpty ? alternatives.first : null;
    final shown = alt ?? item;
    final charged = alt != null ? quoteLineCharged(alt) : quoteLineCharged(item);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _AvailabilityStatus(availability: availability),
            if (item.isAlternative) ...[
              const SizedBox(width: 8),
              _DecisionChip(decision: item.customerDecision),
            ],
          ]),
          const SizedBox(height: 12),
          Text(
            '$index. ${item.localName(lang)}',
            style: appFont('Inter', 
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
              fontSize: 16.5,
              height: 1.25,
            ),
          ),
          if (item.availability == 'partial' && item.requestedQuantity != null) ...[
            const SizedBox(height: 10),
            _AvailableCountPill(available: qty, prescribed: item.requestedQuantity!),
          ],
          if (alt != null) ...[
            const SizedBox(height: 14),
            _SuggestedAlternativeBox(
              original: _QuotationMedicine(item.localName(lang), 0, stock: 0),
              medicines: [_QuotationMedicine(alt.localName(lang), _qNum(alt.price))],
            ),
            const SizedBox(height: 8),
            _DecisionChip(decision: alt.customerDecision),
          ],
          const SizedBox(height: 16),
          _OrderItemTotals(
            detail: s.quoteQtyTimesPrice(shown.quantity ?? '0', _qAmount(_qNum(shown.price))),
            total: '${_qAmount(charged)} MRU',
          ),
        ],
      ),
    );
  }
}

/// The customer's answer to an alternative.
class _DecisionChip extends StatelessWidget {
  const _DecisionChip({required this.decision});

  final String? decision;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final (String label, Color color) = switch (decision) {
      'accepted' => (s.quoteDecisionAccepted, const Color(0xFF16A34A)),
      'rejected' => (s.quoteDecisionRejected, const Color(0xFFE11D48)),
      _ => (s.quoteDecisionWaiting, const Color(0xFFB45309)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label, style: appFont('Inter', fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _OrderItemTotals extends StatelessWidget {
  const _OrderItemTotals({required this.detail, required this.total});

  final String detail;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).quoteUnit,
              style: appFont('Inter', 
                color: const Color.fromARGB(255, 80, 80, 80),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              style: appFont('Inter', 
                color: const Color(0xFF3F2A24),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              S.of(context).quoteTotal,
              style: appFont('Inter', 
                color: const Color.fromARGB(255, 85, 85, 85),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: total.replaceAll(' MRU', ''),
                    style: appFont('Inter', 
                      color: const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      height: 1,
                    ),
                  ),
                  TextSpan(
                    text: ' MRU',
                    style: appFont('Inter', 
                      color: const Color(0xFFFF5216),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AwaitingPaymentSummary extends StatelessWidget {
  const _AwaitingPaymentSummary({
    this.totalAmount,
    required this.items,
    this.itemTotal,
    this.deliveryFee,
    this.tax,
  });

  /// The server's quote amount (`quote_amount`), or a paid order's `total`.
  final String? totalAmount;
  final List<PharmacyPrescriptionQuoteItem> items;

  /// A paid order's `subtotal`, used when there are no quote lines.
  final String? itemTotal;

  /// A paid order's delivery fee and tax; each row only when above 0.
  final String? deliveryFee;
  final String? tax;

  static const Color _orange = Color(0xFFFF5216);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final itemTotal = num.tryParse(this.itemTotal ?? '') ??
        items.fold<num>(0, (sum, i) => sum + quoteLineCharged(i));
    final fee = num.tryParse(deliveryFee ?? '') ?? 0;
    final taxValue = num.tryParse(tax ?? '') ?? 0;
    final pending = items.where((i) => i.isAlternative && i.customerDecision == null).length;
    final total = num.tryParse(totalAmount ?? '') ?? itemTotal;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'lib/pharmacy/Assets/images/quotation_summary.png',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Text(
                s.quoteSummary,
                style: appFont('Inter', 
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.3,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _AwaitingSummaryLine(label: s.quoteItemTotal, value: '${_qAmount(itemTotal)} MRU'),
          if (fee > 0) ...[
            const SizedBox(height: 10),
            _AwaitingSummaryLine(label: s.deliveryFeeLabel, value: '${_qAmount(fee)} MRU'),
          ],
          if (taxValue > 0) ...[
            const SizedBox(height: 10),
            _AwaitingSummaryLine(label: s.tax, value: '${_qAmount(taxValue)} MRU'),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: Color(0xFF5C5C5C)),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                s.quoteTotalAmount,
                style: appFont('Inter', 
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                '${_qAmount(total)} MRU',
                style: appFont('Inter', 
                  color: _orange,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (pending > 0) ...[
            const SizedBox(height: 10),
            Text(
              s.quotePendingAlternatives('$pending'),
              style: appFont('Inter', color: const Color(0xFFFFC9A8), fontSize: 12, height: 1.3),
            ),
          ],
        ],
      ),
    );
  }
}

class _AwaitingSummaryLine extends StatelessWidget {
  const _AwaitingSummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: appFont('Inter', 
            color: const Color(0xFFD0D0D0),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: appFont('Inter', 
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _AwaitingCustomerPaymentCard extends StatelessWidget {
  const _AwaitingCustomerPaymentCard({this.time});

  final String? time;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEFEFEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF6D4),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'lib/pharmacy/Assets/images/awaiting_payment.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).pharmacyDetailAwaitingCustomerPayment,
                  style: appFont('Inter', 
                    color: const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time ?? '',
                  style: appFont('Inter', 
                    color: const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.2,
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

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.steps});

  final List<_TimelineStep> steps;

  static const Color _orange = Color(0xFFFF5C22);
  static const Color _line = Color(0xFFE5E7EB);
  static const Color _inactiveBg = Color(0xFFE8EEF4);
  static const Color _inactiveIcon = Color(0xFF8C9DAE);
  static const Color _inactiveText = Color(0xFF9BA4B5);
  static const double _iconSize = 32;

  int get _completedRun {
    var count = 0;
    for (final step in steps) {
      if (!step.completed) break;
      count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 20, 26),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F5F2),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          // Continuous vertical line through icon centers.
          Positioned(
            left: (_iconSize / 2) - 0.75,
            top: _iconSize / 2,
            bottom: _iconSize / 2,
            child: Container(width: 1.5, color: _line),
          ),
          if (_completedRun > 1)
            Positioned(
              left: (_iconSize / 2) - 0.75,
              top: _iconSize / 2,
              child: Container(
                width: 1.5,
                height: (_completedRun - 1) * 56.5,
                color: _orange,
              ),
            ),
          Column(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                if (i > 0) const SizedBox(height: 18),
                _TimelineRow(
                  step: steps[i],
                  orange: _orange,
                  inactiveBg: _inactiveBg,
                  inactiveIcon: _inactiveIcon,
                  inactiveText: _inactiveText,
                  iconSize: _iconSize,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.step,
    required this.orange,
    required this.inactiveBg,
    required this.inactiveIcon,
    required this.inactiveText,
    required this.iconSize,
  });

  final _TimelineStep step;
  final Color orange;
  final Color inactiveBg;
  final Color inactiveIcon;
  final Color inactiveText;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = step.subtitle != null;

    return Row(
      crossAxisAlignment: hasSubtitle
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (step.completed)
          Container(
            width: iconSize,
            height: iconSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: orange, shape: BoxShape.circle),
            child: _TimelineGlyph(
              step: step,
              color: Colors.white,
              materialSize: 16,
            ),
          )
        else
          Container(
            width: iconSize,
            height: iconSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8EAEF), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9BA4B5).withValues(alpha: 0.10),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Container(
              width: iconSize - 6,
              height: iconSize - 6,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: inactiveBg,
                shape: BoxShape.circle,
              ),
              child: step.customIcon == null
                  ? Icon(step.icon, size: 14, color: inactiveIcon)
                  : SizedBox(
                      width: step.customIcon == _TimelineCustomIcon.openBox
                          ? 17
                          : 15,
                      height: step.customIcon == _TimelineCustomIcon.openBox
                          ? 17
                          : 15,
                      child: CustomPaint(
                        painter: switch (step.customIcon!) {
                          _TimelineCustomIcon.capsule => _CapsuleIconPainter(
                            color: inactiveIcon,
                          ),
                          _TimelineCustomIcon.scooter => _ScooterIconPainter(
                            color: inactiveIcon,
                          ),
                          _TimelineCustomIcon.openBox => _OpenBoxIconPainter(
                            color: inactiveIcon,
                          ),
                        },
                      ),
                    ),
            ),
          ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: hasSubtitle ? 2 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _timelineTitle(context, step.title),
                  style: appFont('Inter', 
                    color: step.completed
                        ? const Color(0xFF1A1A1A)
                        : inactiveText,
                    fontWeight: step.completed
                        ? FontWeight.w700
                        : FontWeight.w400,
                    fontSize: 14.5,
                    height: 1.25,
                  ),
                ),
                if (hasSubtitle) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.subtitle!,
                    style: appFont('Inter', 
                      color: const Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineGlyph extends StatelessWidget {
  const _TimelineGlyph({
    required this.step,
    required this.color,
    this.materialSize = 14,
  });

  final _TimelineStep step;
  final Color color;
  final double materialSize;

  @override
  Widget build(BuildContext context) {
    final custom = step.customIcon;
    if (custom == null) {
      return Icon(step.icon, size: materialSize, color: color);
    }
    final box = custom == _TimelineCustomIcon.openBox ? 18.0 : 16.0;
    return SizedBox(
      width: box,
      height: box,
      child: CustomPaint(
        painter: switch (custom) {
          _TimelineCustomIcon.capsule => _CapsuleIconPainter(color: color),
          _TimelineCustomIcon.scooter => _ScooterIconPainter(color: color),
          _TimelineCustomIcon.openBox => _OpenBoxIconPainter(color: color),
        },
      ),
    );
  }
}

enum _TimelineCustomIcon { capsule, scooter, openBox }

/// The timeline lists are `const`, so their titles are English keys;
/// translate them when drawn (test day V17). Also used by the OTC timeline
/// (same library). Unknown titles are shown as given.
String _timelineTitle(BuildContext context, String title) {
  final s = S.of(context);
  return switch (title) {
    'Prescription Received' => s.pharmacyDetailStepPrescriptionReceived,
    'Under Review' => s.pharmacyDetailStepUnderReview,
    'Review Completed' => s.pharmacyDetailStepReviewCompleted,
    'Quotation Sent' => s.pharmacyDetailStepQuotationSent,
    'Paid' => s.pharmacyDetailStepPaid,
    'Preparing Medicines' => s.pharmacyDetailStepPreparingMedicines,
    'Preparing' => s.preparing,
    'Ready for Dispatch' => s.pharmacyDetailReadyForDispatch,
    'Ready for Pickup' => s.pharmacyDetailStepReadyForPickup,
    'Delivery Partner Assigned' => s.pharmacyDetailStepPartnerAssigned,
    'Order Delivered' => s.pharmacyDetailStepOrderDelivered,
    'Order Received' => s.pharmacyDetailStepOrderReceived,
    'Order Accepted' => s.pharmacyDetailStepOrderAccepted,
    'Picked Up by Rider' => s.pharmacyDetailStepPickedUpByRider,
    'Picked Up by Customer' => s.pharmacyDetailStepPickedUpByCustomer,
    _ => title,
  };
}

class _TimelineStep {
  const _TimelineStep({
    required this.title,
    required this.icon,
    this.subtitle,
    this.completed = false,
    this.customIcon,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final bool completed;
  final _TimelineCustomIcon? customIcon;
}

/// Half-filled capsule tilted ~45°, matching the design asset.
class _CapsuleIconPainter extends CustomPainter {
  const _CapsuleIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    // Tilt bottom-left → top-right (~45°).
    canvas.rotate(-0.78);

    final w = size.width * 0.92;
    final h = size.height * 0.42;
    final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(h / 2));

    // Outline full capsule.
    canvas.drawRRect(rrect, stroke);

    // Solid left (bottom-left after rotation) half.
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(-w / 2, -h / 2, 0, h / 2));
    canvas.drawRRect(rrect, fill);
    canvas.restore();

    // Divider seam in the middle.
    canvas.drawLine(Offset(0, -h / 2 + 0.5), Offset(0, h / 2 - 0.5), stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CapsuleIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Delivery scooter with box + speed lines, matching the design asset.
class _ScooterIconPainter extends CustomPainter {
  const _ScooterIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final sx = w / 16;
    final sy = h / 16;

    // Speed lines behind the box.
    canvas.drawLine(
      Offset(0.6 * sx, 5.2 * sy),
      Offset(2.4 * sx, 5.2 * sy),
      stroke,
    );
    canvas.drawLine(
      Offset(0.4 * sx, 6.8 * sy),
      Offset(2.2 * sx, 6.8 * sy),
      stroke,
    );
    canvas.drawLine(
      Offset(0.8 * sx, 8.4 * sy),
      Offset(2.4 * sx, 8.4 * sy),
      stroke,
    );

    // Delivery box on rear.
    final box = RRect.fromRectAndRadius(
      Rect.fromLTWH(2.4 * sx, 3.4 * sy, 3.6 * sx, 4.4 * sy),
      Radius.circular(0.55 * sx),
    );
    canvas.drawRRect(box, stroke);

    // Rear wheel.
    canvas.drawCircle(Offset(4.4 * sx, 12.2 * sy), 2.05 * sx, stroke);
    canvas.drawCircle(Offset(4.4 * sx, 12.2 * sy), 0.55 * sx, fill);

    // Front wheel.
    canvas.drawCircle(Offset(12.4 * sx, 12.2 * sy), 2.05 * sx, stroke);
    canvas.drawCircle(Offset(12.4 * sx, 12.2 * sy), 0.55 * sx, fill);

    // Deck / body between wheels.
    final body = Path()
      ..moveTo(6.2 * sx, 10.8 * sy)
      ..lineTo(10.6 * sx, 10.8 * sy)
      ..quadraticBezierTo(11.2 * sx, 10.8 * sy, 11.4 * sx, 10.0 * sy)
      ..lineTo(11.6 * sx, 8.2 * sy);
    canvas.drawPath(body, stroke);

    // Stem / handle column.
    canvas.drawLine(
      Offset(11.6 * sx, 8.2 * sy),
      Offset(12.0 * sx, 4.6 * sy),
      stroke,
    );

    // Handlebar.
    canvas.drawLine(
      Offset(10.8 * sx, 4.4 * sy),
      Offset(13.4 * sx, 4.0 * sy),
      stroke,
    );

    // Seat / rear connection from box to deck.
    canvas.drawLine(
      Offset(5.8 * sx, 7.8 * sy),
      Offset(7.0 * sx, 10.6 * sy),
      stroke,
    );

    // Small front fender / mudguard hint.
    canvas.drawArc(
      Rect.fromCircle(center: Offset(12.4 * sx, 12.2 * sy), radius: 2.35 * sx),
      -2.4,
      1.0,
      false,
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _ScooterIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Open carton seen from the front-right, matching Ready for Dispatch.
class _OpenBoxIconPainter extends CustomPainter {
  const _OpenBoxIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.065
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.shortestSide / 24;
    Offset p(double x, double y) => Offset(x * s, y * s);

    // Left top flap.
    canvas.drawPath(
      Path()
        ..moveTo(p(5.2, 8.6).dx, p(5.2, 8.6).dy)
        ..lineTo(p(3.2, 4.8).dx, p(3.2, 4.8).dy)
        ..lineTo(p(10.2, 2.0).dx, p(10.2, 2.0).dy)
        ..lineTo(p(12.0, 5.6).dx, p(12.0, 5.6).dy),
      stroke,
    );

    // Right top flap.
    canvas.drawPath(
      Path()
        ..moveTo(p(12.6, 5.6).dx, p(12.6, 5.6).dy)
        ..lineTo(p(14.4, 2.0).dx, p(14.4, 2.0).dy)
        ..lineTo(p(21.2, 4.8).dx, p(21.2, 4.8).dy)
        ..lineTo(p(19.2, 8.6).dx, p(19.2, 8.6).dy),
      stroke,
    );

    // Box body: front face + right side.
    canvas.drawPath(
      Path()
        ..moveTo(p(5.2, 8.6).dx, p(5.2, 8.6).dy)
        ..lineTo(p(5.2, 16.6).dx, p(5.2, 16.6).dy)
        ..lineTo(p(12.2, 19.6).dx, p(12.2, 19.6).dy)
        ..lineTo(p(19.2, 16.6).dx, p(19.2, 16.6).dy)
        ..lineTo(p(19.2, 8.6).dx, p(19.2, 8.6).dy)
        ..lineTo(p(12.2, 5.6).dx, p(12.2, 5.6).dy)
        ..close(),
      stroke,
    );

    // Opening rim and front center seam.
    canvas.drawLine(p(5.2, 8.6), p(12.2, 11.4), stroke);
    canvas.drawLine(p(19.2, 8.6), p(12.2, 11.4), stroke);
    canvas.drawLine(p(12.2, 5.6), p(12.2, 11.4), stroke);
    canvas.drawLine(p(12.2, 11.4), p(12.2, 19.6), stroke);
  }

  @override
  bool shouldRepaint(covariant _OpenBoxIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onReject,
    required this.onReview,
    this.primaryLabel,
  });

  final VoidCallback onReject;
  final VoidCallback onReview;
  final String? primaryLabel;

  static const Color _orange = Color(0xFFFF5C22);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: onReject,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A1A1A),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  S.of(context).reject,
                  style: appFont('Inter', 
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _orange.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: onReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    primaryLabel ??
                        S.of(context).pharmacyDetailReviewPrescription,
                    maxLines: 1,
                    softWrap: false,
                    style: appFont('Inter', 
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryPartnerSection extends StatelessWidget {
  const _DeliveryPartnerSection({
    this.showPhone = false,
    this.name,
    this.phone,
    this.image,
  });

  final bool showPhone;
  final String? name;
  final String? phone;
  final String? image;

  static const Color _orange = Color(0xFFFF5216);

  @override
  Widget build(BuildContext context) {
    // Only a real rider: the card showed a stock photo, no name and, on OTC
    // orders, a fixed "4.8 (124 reviews)". Order details carry only the
    // rider id, so it stays hidden until the API sends name / phone.
    final riderName = (name ?? '').trim();
    if (riderName.isEmpty) return const SizedBox.shrink();
    final riderImage = (image ?? '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).pharmacyDetailDeliveryPartner,
          style: appFont('Inter', 
            color: const Color(0xFF9AA6B2),
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.8,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 52,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        color: const Color(0xFFFFF4EA),
                        image: riderImage.isEmpty
                            ? null
                            : DecorationImage(
                                image: NetworkImage(riderImage),
                                fit: BoxFit.cover,
                              ),
                      ),
                      alignment: Alignment.center,
                      child: riderImage.isEmpty
                          ? Text(
                              riderName.substring(0, 1).toUpperCase(),
                              style: appFont('Inter', color: const Color(0xFFFF5216), fontWeight: FontWeight.w700, fontSize: 18),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riderName,
                      style: appFont('Inter', 
                        color: const Color(0xFF1A2332),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (showPhone && (phone ?? '').trim().isNotEmpty)
                      Text(
                        phone!.trim(),
                        style: appFont('Inter', 
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                          fontSize: 13.5,
                          height: 1.2,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _orange,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _orange.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StartPreparingBar extends StatelessWidget {
  const _StartPreparingBar({this.label, this.onPressed, this.busy = false});

  final String? label;

  /// The order action; null disables the button.
  final VoidCallback? onPressed;
  final bool busy;

  static const Color _orange = Color(0xFFFF5216);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: busy ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _orange,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _orange.withValues(alpha: 0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : Text(
                  label ?? S.of(context).pharmacyDetailStartPreparing,
                  style: appFont('Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

class _FullPrescriptionViewer extends StatelessWidget {
  const _FullPrescriptionViewer({
    this.assetPath,
    this.imageUrl,
    this.imageBytes,
    required this.rotationTurns,
  });

  final String? assetPath;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final double rotationTurns;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(S.of(context).pharmacyDetailPrescription),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: AnimatedRotation(
            turns: rotationTurns,
            duration: Duration.zero,
            child: (imageBytes != null && imageBytes!.isNotEmpty)
                ? Image.memory(imageBytes!, fit: BoxFit.contain)
                : (imageUrl != null && imageUrl!.trim().isNotEmpty)
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      );
                    },
                    errorBuilder: (_, error, __) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 64,
                    ),
                  )
                : const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 64,
                  ),
          ),
        ),
      ),
    );
  }
}
