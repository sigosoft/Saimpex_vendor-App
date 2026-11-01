import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:saimpex_vendor/utils/payment_type.dart';
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
import 'package:saimpex_vendor/pharmacy/view/pharmacy_chat_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/reject_order_sheet.dart';
import 'package:saimpex_vendor/utils/utils.dart';

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
    customerName: customerName.isNotEmpty ? customerName : 'Customer',
    customerId: validCustomerId,
    conversationId: initialConvId,
    avatar: initialAvatar,
  );
}

class PharmacyOrderDetailsScreen extends StatefulWidget {
  const PharmacyOrderDetailsScreen({
    super.key,
    this.customerName = 'Ahmed',
    this.phone = '+222 45 12 34 56',
    this.requestId = '#22789007',
    this.requestMeta = 'Today • 10:45 AM',
    this.notesType = PharmacyOrderNotesType.none,
    this.specialNotes =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras vestibulum mattis',
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
  });

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

  @override
  void initState() {
    super.initState();
    _detailsController = Get.put(PharmacyOrderDetailsController());
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

  List<_TimelineStep> get _timeline {
    if (widget.isDelivered) return _deliveredTimeline;
    if (widget.isReady) return _readyTimeline;
    if (widget.isPreparing) return _preparingTimeline;
    if (widget.isToPrepare) return _toPrepareTimeline;
    if (widget.isAwaitingPayment) return _awaitingPaymentTimeline;
    if (widget.isReviewCompleted) return _reviewCompletedTimeline;
    if (widget.isUnderReview) return _underReviewTimeline;
    if (widget.isSelfPickup) return _selfPickupTimeline;
    return _deliveryTimeline;
  }

  List<_TimelineStep> _buildTimeline(String? createdTime) {
    final baseSteps = _timeline;
    if (createdTime == null || createdTime.isEmpty) return baseSteps;
    return baseSteps.asMap().entries.map((entry) {
      if (entry.key == 0) {
        return _TimelineStep(
          title: entry.value.title,
          subtitle: createdTime,
          icon: entry.value.icon,
          customIcon: entry.value.customIcon,
          completed: entry.value.completed,
        );
      }
      return entry.value;
    }).toList();
  }

  void _openCreateQuotation() {
    final presc = _detailsController.prescriptionObj;
    final customerName = presc?.customerName?.trim().isNotEmpty == true
        ? presc!.customerName!
        : (widget.customerName != 'Ahmed' ? widget.customerName : 'Customer');
    final phone = presc?.displayPhone.trim().isNotEmpty == true
        ? presc!.displayPhone
        : (widget.phone != '+222 45 12 34 56' ? widget.phone : '');
    final requestId = presc?.prescriptionId != null
        ? '#${presc!.prescriptionId}'
        : (widget.requestId != '#22789007' ? widget.requestId : '');
    final requestMeta = presc?.createdAt?.trim().isNotEmpty == true
        ? presc!.createdAt!
        : (widget.requestMeta != 'Today • 10:45 AM' ? widget.requestMeta : '');
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
    if (widget.isOtc) {
      return GetBuilder<PharmacyOrderDetailsController>(
        builder: (detailsCtrl) {
          return _OtcOrderDetailsPage(
            orderId: widget.effectiveOrderId,
            orderRawId: widget.effectiveOrderId,
            isLoading: detailsCtrl.isLoadingOrderDetail,
            orderDetailData: detailsCtrl.orderDetailData,
            name: widget.customerName,
            phone: widget.phone,
            requestId: widget.requestId,
            requestMeta: widget.requestMeta,
            selfPickup: widget.isSelfPickup,
            cashOnDelivery: widget.cashOnDelivery,
            accepted: widget.isOtcAccepted,
            preparing: widget.isOtcPreparing,
            ready: widget.isOtcReady,
            partnerAssigned: widget.isOtcPartnerAssigned,
            delivered: widget.isOtcDelivered,
            cancelled: widget.isOtcCancelled,
          );
        },
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
            : (widget.customerName != 'Ahmed'
                  ? widget.customerName
                  : (rawCustName ?? 'Customer'));

        final initial = effectiveCustomerName.isNotEmpty
            ? effectiveCustomerName.substring(0, 1).toUpperCase()
            : 'C';

        final rawPhone = prescObj?.displayPhone.trim();
        final effectivePhone = (rawPhone != null && rawPhone.isNotEmpty)
            ? rawPhone
            : (widget.phone != '+222 45 12 34 56'
                  ? widget.phone
                  : (rawPhone ?? ''));

        final effectiveRequestId = prescObj?.prescriptionId != null
            ? '#${prescObj!.prescriptionId}'
            : (widget.requestId != '#22789007'
                  ? widget.requestId
                  : (prescObj?.displayOrderCode ?? widget.requestId));

        final rawCreatedAt = prescObj?.createdAt?.trim();
        final effectiveRequestMeta =
            (rawCreatedAt != null && rawCreatedAt.isNotEmpty)
            ? rawCreatedAt
            : (widget.requestMeta != 'Today • 10:45 AM'
                  ? widget.requestMeta
                  : (rawCreatedAt ?? ''));

        final rawNote = prescObj?.note?.trim();
        final effectiveNote = (rawNote != null && rawNote.isNotEmpty)
            ? rawNote
            : (widget.specialNotes !=
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras vestibulum mattis'
                  ? widget.specialNotes
                  : (rawNote ?? ''));

        final hasNote =
            effectiveNote.isNotEmpty ||
            widget.notesType == PharmacyOrderNotesType.voice;

        final statusStr = prescObj?.status?.trim().toLowerCase();
        final isEffectiveReviewing =
            widget.isUnderReview ||
            statusStr == 'uploaded' ||
            statusStr == 'under_review' ||
            statusStr == 'under review' ||
            statusStr == 'reviewing';
        final isEffectiveReviewCompleted =
            widget.isReviewCompleted ||
            statusStr == 'review_completed' ||
            statusStr == 'reviewed';
        final isEffectiveAwaitingPayment =
            widget.isAwaitingPayment ||
            statusStr == 'awaiting_payment' ||
            statusStr == 'quoted';

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
                                  'Order Details',
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
                                if (widget.isToPrepare ||
                                    widget.isPreparing ||
                                    widget.isReady ||
                                    widget.isDelivered)
                                  _ToPrepareInfoCard(
                                    initial: initial,
                                    name: effectiveCustomerName,
                                    phone: effectivePhone,
                                    requestId: effectiveRequestId,
                                    requestMeta: effectiveRequestMeta,
                                    preparing: widget.isPreparing,
                                    ready: widget.isReady,
                                    delivered: widget.isDelivered,
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
                                    reviewing: isEffectiveReviewing,
                                    reviewCompleted: isEffectiveReviewCompleted,
                                    awaitingPayment: isEffectiveAwaitingPayment,
                                    onChatTap: () => _openCustomerChat(
                                      context,
                                      customerName: effectiveCustomerName,
                                      customerId: prescObj?.userId,
                                    ),
                                  ),
                                const SizedBox(height: 14),
                                if (widget.isReady || widget.isDelivered) ...[
                                  const _DeliveryPartnerSection(
                                    showPhone: true,
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
                                    'SPECIAL NOTES',
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
                                if (isEffectiveAwaitingPayment ||
                                    widget.isToPrepare ||
                                    widget.isPreparing ||
                                    widget.isReady ||
                                    widget.isDelivered) ...[
                                  const _AwaitingPaymentItems(),
                                  const SizedBox(height: 16),
                                  _AwaitingPaymentSummary(
                                    totalAmount: prescObj?.quoteAmount != null
                                        ? '${prescObj!.quoteAmount} MRU'
                                        : null,
                                  ),
                                  if (isEffectiveAwaitingPayment) ...[
                                    const SizedBox(height: 12),
                                    _AwaitingCustomerPaymentCard(
                                      time: effectiveRequestMeta.isNotEmpty
                                          ? effectiveRequestMeta
                                          : null,
                                    ),
                                  ],
                                  const SizedBox(height: 18),
                                ],
                                Text(
                                  'ORDER TIMELINE',
                                  style: appFont('Inter', 
                                    color: const Color(0xFFA0A9B8),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _TimelineCard(
                                  steps: _buildTimeline(effectiveRequestMeta),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (widget.isToPrepare || widget.isPreparing)
                  _StartPreparingBar(
                    label: widget.isPreparing
                        ? 'Ready for Dispatch'
                        : 'Start Preparing',
                  )
                else if (!isEffectiveAwaitingPayment &&
                    !widget.isReady &&
                    !widget.isDelivered)
                  _BottomActions(
                    onReject: () => showPharmacyRejectOrderSheet(context),
                    onReview: isEffectiveReviewCompleted
                        ? _openCreateQuotation
                        : _openFullPrescription,
                    primaryLabel: isEffectiveReviewCompleted
                        ? 'Create Quotation'
                        : isEffectiveReviewing
                        ? 'Mark as Reviewed'
                        : 'Review Prescription',
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
                'CUSTOMER',
                style: appFont('Inter', 
                  color: _accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.7,
                  height: 1.1,
                ),
              ),
              const Spacer(),
              if (!awaitingPayment)
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
                        ? 'AWAITING PAYMENT'
                        : reviewCompleted
                        ? 'REVIEW COMPLETED'
                        : reviewing
                        ? 'REVIEWING'
                        : 'NEW',
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
                  'REQUEST ID',
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
                        text: requestId,
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
            'UPLOADED PRESCRIPTION',
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
                              errorBuilder: (_, error, __) => const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      size: 44,
                                      color: Color(0xFF9E9E9E),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Failed to load prescription',
                                      style: TextStyle(
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
                                : const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.description_outlined,
                                          size: 44,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'No Prescription Image',
                                          style: TextStyle(
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
                          label: 'Zoom',
                          onTap: onZoom,
                          color: const Color(0xFFE67E22),
                        ),
                        const SizedBox(width: 8),
                        _ImageActionChip(
                          icon: Icons.rotate_right_rounded,
                          label: 'Rotate',
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
                    'View Full Prescription',
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
  });

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
                'CUSTOMER',
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
                  color: ready || delivered
                      ? _ready
                      : preparing
                      ? _accent
                      : _blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  delivered
                      ? 'DELIVERED'
                      : ready
                      ? 'READY'
                      : preparing
                      ? 'PREPARING'
                      : 'TO PREPARE',
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
                        'REQUEST ID',
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
                              text: requestId,
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
                        'DELIVERY TYPE',
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
                          Image.asset(
                            'lib/pharmacy/Assets/images/delivery_icon.png',
                            width: 16,
                            height: 16,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Delivery',
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
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: _accent, size: 18),
              const SizedBox(width: 6),
              Text(
                'DELIVERY ADDRESS',
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
                        'Sahara View Home',
                        style: appFont('Inter', 
                          color: const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Near Marhaba Supermarket,Nouakchott',
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
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4EA),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/pharmacy/Assets/images/online_payment.png',
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Text(
                  'Online Payment',
                  style: appFont('Inter', 
                    color: _accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.1,
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

class _AwaitingPaymentItems extends StatelessWidget {
  const _AwaitingPaymentItems();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORDER ITEMS (2)',
          style: appFont('Inter', 
            color: const Color(0xFFB0B7C3),
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.4,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        const _AwaitingItemCard(
          availability: _Availability.inStock,
          name: '1. Paracetamol 500 mg',
          unit: '10 tablets × 50 MRU',
          total: '500 MRU',
        ),
        const SizedBox(height: 12),
        const _AwaitingItemCard(
          availability: _Availability.limited,
          name: '1. Paracetamol 650 mg',
          available: 6,
          prescribed: 10,
          unit: '6 tablets × 50 MRU',
          total: '500 MRU',
        ),
        const SizedBox(height: 12),
        const _AwaitingItemCard(
          availability: _Availability.outOfStock,
          name: '1. Paracetamol 500 mg',
          showAlternative: true,
          unit: '10 tablets × 50 MRU',
          total: '500 MRU',
        ),
      ],
    );
  }
}

class _AwaitingItemCard extends StatelessWidget {
  const _AwaitingItemCard({
    required this.availability,
    required this.name,
    required this.unit,
    required this.total,
    this.available,
    this.prescribed,
    this.showAlternative = false,
  });

  final _Availability availability;
  final String name;
  final String unit;
  final String total;
  final int? available;
  final int? prescribed;
  final bool showAlternative;

  @override
  Widget build(BuildContext context) {
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
          _AvailabilityStatus(availability: availability),
          const SizedBox(height: 12),
          Text(
            name,
            style: appFont('Inter', 
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
              fontSize: 16.5,
              height: 1.25,
            ),
          ),
          if (available != null && prescribed != null) ...[
            const SizedBox(height: 10),
            _AvailableCountPill(available: available!, prescribed: prescribed!),
          ],
          if (showAlternative) ...[
            const SizedBox(height: 14),
            const _SuggestedAlternativeBox(
              original: _QuotationMedicine(
                'Paracetamol 500 mg',
                50,
                inStock: false,
              ),
              medicines: [_QuotationMedicine('Paracetamol 650 mg', 50)],
            ),
          ],
          const SizedBox(height: 16),
          _OrderItemTotals(detail: unit, total: total),
        ],
      ),
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
              'Unit',
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
              'Total',
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
  const _AwaitingPaymentSummary({this.totalAmount, this.itemTotal, this.tax});

  final String? totalAmount;
  final String? itemTotal;
  final String? tax;

  static const Color _orange = Color(0xFFFF5216);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
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
                'QUOTATION SUMMARY',
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
          _AwaitingSummaryLine(
            label: 'Item total',
            value: itemTotal ?? totalAmount ?? '1500 MRU',
          ),
          const SizedBox(height: 12),
          _AwaitingSummaryLine(label: 'Tax', value: tax ?? '0'),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: Color(0xFF5C5C5C)),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Total Amount',
                style: appFont('Inter', 
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                totalAmount ?? '1510 MRU',
                style: appFont('Inter', 
                  color: _orange,
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
                  'Awaiting Customer Payment',
                  style: appFont('Inter', 
                    color: const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time ?? '23/04/2026 10:45 AM',
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
                  step.title,
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
    this.primaryLabel = 'Review Prescription',
  });

  final VoidCallback onReject;
  final VoidCallback onReview;
  final String primaryLabel;

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
                  'Reject',
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
                    primaryLabel,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DELIVERY PARTNER',
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
                        image: const DecorationImage(
                          image: AssetImage(
                            'lib/water/Assets/Images/delivery_boy1.png',
                          ),
                          fit: BoxFit.cover,
                          alignment: Alignment(0, -0.2),
                        ),
                      ),
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
                      name?.isNotEmpty == true ? name! : '',
                      style: appFont('Inter', 
                        color: const Color(0xFF1A2332),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (showPhone)
                      Text(
                        phone?.isNotEmpty == true ? phone! : '',
                        style: appFont('Inter', 
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                          fontSize: 13.5,
                          height: 1.2,
                        ),
                      )
                    else
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFF5B400),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '4.8',
                            style: appFont('Inter', 
                              color: const Color(0xFF1A2332),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(124 reviews)',
                            style: appFont('Inter', 
                              color: const Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              height: 1,
                            ),
                          ),
                        ],
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
  const _StartPreparingBar({this.label = 'Start Preparing'});

  final String label;

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
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: _orange,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            label,
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
        title: const Text('Prescription'),
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
