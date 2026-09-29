import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/pharmacy/reject_order_sheet.dart';

part 'create_quotation_screen.dart';

enum PharmacyOrderNotesType { none, text, voice }

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

  @override
  State<PharmacyOrderDetailsScreen> createState() =>
      _PharmacyOrderDetailsScreenState();
}

class _PharmacyOrderDetailsScreenState
    extends State<PharmacyOrderDetailsScreen> {
  static const Color _orange = Color(0xFFFF5C22);

  static const String _prescriptionAsset =
      'lib/pharmacy/Assets/images/Prescription Upload.png';

  double _rotationTurns = 0;

  static const _deliveryTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Prescription Received',
      subtitle: 'Feb 07, 2024 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Under Review',
      icon: Icons.assignment_outlined,
    ),
    _TimelineStep(
      title: 'Review Completed',
      icon: Icons.check_rounded,
    ),
    _TimelineStep(
      title: 'Quotation Sent',
      icon: Icons.request_quote_outlined,
    ),
    _TimelineStep(
      title: 'Paid',
      icon: Icons.check_rounded,
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
    _TimelineStep(
      title: 'Order Delivered',
      icon: Icons.home_outlined,
    ),
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
    _TimelineStep(
      title: 'Review Completed',
      icon: Icons.check_rounded,
    ),
    _TimelineStep(
      title: 'Quotation Sent',
      icon: Icons.request_quote_outlined,
    ),
    _TimelineStep(
      title: 'Paid',
      icon: Icons.check_rounded,
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
    _TimelineStep(
      title: 'Order Delivered',
      icon: Icons.home_outlined,
    ),
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
    _TimelineStep(
      title: 'Quotation Sent',
      icon: Icons.request_quote_outlined,
    ),
    _TimelineStep(
      title: 'Paid',
      icon: Icons.check_rounded,
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
    _TimelineStep(
      title: 'Order Delivered',
      icon: Icons.home_outlined,
    ),
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
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Ready for Dispatch',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.inventory_2_outlined,
      completed: true,
    ),
    _TimelineStep(
      title: 'Delivery Partner Assigned',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.electric_scooter,
      completed: true,
    ),
    _TimelineStep(
      title: 'Order Delivered',
      subtitle: 'Feb 07, 2026 10:45 AM',
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
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Ready for Dispatch',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.inventory_2_outlined,
      completed: true,
    ),
    _TimelineStep(
      title: 'Delivery Partner Assigned',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.electric_scooter,
      completed: true,
    ),
    _TimelineStep(
      title: 'Order Delivered',
      icon: Icons.home_outlined,
    ),
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
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
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
    _TimelineStep(
      title: 'Order Delivered',
      icon: Icons.home_outlined,
    ),
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
    _TimelineStep(
      title: 'Order Delivered',
      icon: Icons.home_outlined,
    ),
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
    _TimelineStep(
      title: 'Order Delivered',
      icon: Icons.home_outlined,
    ),
  ];

  static const _selfPickupTimeline = <_TimelineStep>[
    _TimelineStep(
      title: 'Prescription Received',
      subtitle: 'Feb 07, 2026 10:45 AM',
      icon: Icons.check_rounded,
      completed: true,
    ),
    _TimelineStep(
      title: 'Under Review',
      icon: Icons.assignment_outlined,
    ),
    _TimelineStep(
      title: 'Review Completed',
      icon: Icons.check_rounded,
    ),
    _TimelineStep(
      title: 'Quotation Sent',
      icon: Icons.request_quote_outlined,
    ),
    _TimelineStep(
      title: 'Paid',
      icon: Icons.check_rounded,
    ),
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
    _TimelineStep(
      title: 'Order Delivered',
      icon: Icons.home_outlined,
    ),
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

  void _openCreateQuotation() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PharmacyCreateQuotationScreen(
          customerName: widget.customerName,
          phone: widget.phone,
          requestId: widget.requestId,
          requestMeta: widget.requestMeta,
        ),
      ),
    );
  }

  void _openFullPrescription() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullPrescriptionViewer(
          assetPath: _prescriptionAsset,
          rotationTurns: _rotationTurns,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.customerName.isNotEmpty
        ? widget.customerName.substring(0, 1).toUpperCase()
        : 'A';

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
                              style: GoogleFonts.inter(
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
                                onTap: () => Navigator.of(context).maybePop(),
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
                              name: widget.customerName,
                              phone: widget.phone,
                              requestId: widget.requestId,
                              requestMeta: widget.requestMeta,
                              preparing: widget.isPreparing,
                              ready: widget.isReady,
                              delivered: widget.isDelivered,
                            )
                          else
                            _CustomerCard(
                              initial: initial,
                              name: widget.customerName,
                              phone: widget.phone,
                              requestId: widget.requestId,
                              requestMeta: widget.requestMeta,
                              reviewing: widget.isUnderReview,
                              reviewCompleted: widget.isReviewCompleted,
                              awaitingPayment: widget.isAwaitingPayment,
                            ),
                          const SizedBox(height: 14),
                          if (widget.isReady || widget.isDelivered) ...[
                            const _DeliveryPartnerSection(),
                            const SizedBox(height: 18),
                          ],
                          _UploadedPrescriptionCard(
                            assetPath: _prescriptionAsset,
                            rotationTurns: _rotationTurns,
                            onZoom: _openFullPrescription,
                            onRotate: () => setState(
                              () => _rotationTurns += 0.25,
                            ),
                            onViewFull: _openFullPrescription,
                          ),
                          const SizedBox(height: 18),
                          if (widget.notesType != PharmacyOrderNotesType.none) ...[
                            Text(
                              'SPECIAL NOTES',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFA0A9B8),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (widget.notesType == PharmacyOrderNotesType.voice)
                              _SpecialNotesVoiceCard(
                                duration: widget.voiceNoteDuration,
                              )
                            else
                              _SpecialNotesTextCard(note: widget.specialNotes),
                            const SizedBox(height: 18),
                          ],
                          if (widget.isAwaitingPayment) ...[
                            const _AwaitingPaymentItems(),
                            const SizedBox(height: 16),
                            const _AwaitingPaymentSummary(),
                            const SizedBox(height: 12),
                            const _AwaitingCustomerPaymentCard(),
                            const SizedBox(height: 18),
                          ] else if (widget.isToPrepare ||
                              widget.isPreparing ||
                              widget.isReady ||
                              widget.isDelivered) ...[
                            const _AwaitingOrderItems(),
                            const SizedBox(height: 16),
                            const _QuotationSummaryCard(),
                            const SizedBox(height: 18),
                          ],
                          Text(
                            'ORDER TIMELINE',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFA0A9B8),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _TimelineCard(steps: _timeline),
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
            else if (!widget.isAwaitingPayment &&
                !widget.isReady &&
                !widget.isDelivered)
              _BottomActions(
              onReject: () => showPharmacyRejectOrderSheet(context),
              onReview: widget.isReviewCompleted
                  ? _openCreateQuotation
                  : _openFullPrescription,
              primaryLabel: widget.isReviewCompleted
                  ? 'Create Quotation'
                  : widget.isUnderReview
                      ? 'Mark as Reviewed'
                      : 'Review Prescription',
            ),
          ],
        ),
      ),
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
  });

  final String initial;
  final String name;
  final String phone;
  final String requestId;
  final String requestMeta;
  final bool reviewing;
  final bool reviewCompleted;
  final bool awaitingPayment;

  static const Color _accent = Color(0xFFFF5722);
  static const Color _avatarLetter = Color(0xFFE64A19);
  static const Color _chatOrange = Color(0xFFFF5722);
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
                style: GoogleFonts.inter(
                  color: _accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.7,
                  height: 1.1,
                ),
              ),
              const Spacer(),
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
                  style: GoogleFonts.inter(
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
                    style: GoogleFonts.inter(
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
                        style: GoogleFonts.inter(
                          color: const Color(0xFF212121),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        phone,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF757575),
                          fontWeight: FontWeight.w400,
                          fontSize: 13.5,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
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
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: CustomPaint(
                      painter: _ChatDotsIconPainter(color: Colors.white),
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
                  style: GoogleFonts.inter(
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
                        style: GoogleFonts.inter(
                          color: _accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: '  •  $requestMeta',
                        style: GoogleFonts.inter(
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

/// Speech bubble with three dots, matching the customer chat button.
class _ChatDotsIconPainter extends CustomPainter {
  const _ChatDotsIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final bubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.06, h * 0.08, w * 0.88, h * 0.62),
      Radius.circular(h * 0.18),
    );
    canvas.drawRRect(bubble, paint);

    final tail = Path()
      ..moveTo(w * 0.22, h * 0.68)
      ..lineTo(w * 0.18, h * 0.92)
      ..lineTo(w * 0.42, h * 0.68);
    canvas.drawPath(tail, paint);

    final dot = Paint()..color = color;
    final cy = h * 0.39;
    final r = w * 0.055;
    canvas.drawCircle(Offset(w * 0.32, cy), r, dot);
    canvas.drawCircle(Offset(w * 0.50, cy), r, dot);
    canvas.drawCircle(Offset(w * 0.68, cy), r, dot);
  }

  @override
  bool shouldRepaint(covariant _ChatDotsIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _UploadedPrescriptionCard extends StatelessWidget {
  const _UploadedPrescriptionCard({
    required this.assetPath,
    required this.rotationTurns,
    required this.onZoom,
    required this.onRotate,
    required this.onViewFull,
  });

  final String assetPath;
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
            style: GoogleFonts.inter(
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
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(
                            Icons.description_outlined,
                            size: 48,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
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
                  const Icon(Icons.open_in_new_rounded, size: 17, color: _orange),
                  const SizedBox(width: 8),
                  Text(
                    'View Full Prescription',
                    style: GoogleFonts.inter(
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
                style: GoogleFonts.inter(
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
            child: Icon(
              Icons.description_outlined,
              color: _orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              note,
              style: GoogleFonts.inter(
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
    0.35, 0.55, 0.42, 0.78, 0.50, 0.92, 0.60, 0.70, 0.45, 0.85,
    0.38, 0.62, 0.90, 0.48, 0.72, 0.40, 0.68, 0.55, 0.82, 0.46,
    0.74, 0.58, 0.36, 0.80, 0.52, 0.66, 0.44, 0.76, 0.50, 0.60,
    0.42, 0.70, 0.48, 0.64, 0.38, 0.72,
  ];

  late final AnimationController _controller;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addStatusListener((status) {
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
            style: GoogleFonts.inter(
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
  });

  final String initial;
  final String name;
  final String phone;
  final String requestId;
  final String requestMeta;
  final bool preparing;
  final bool ready;
  final bool delivered;

  static const Color _accent = Color(0xFFFF5722);
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
                style: GoogleFonts.inter(
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
                  style: GoogleFonts.inter(
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
                    style: GoogleFonts.inter(
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
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: GoogleFonts.inter(
                          color: _meta,
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: CustomPaint(
                      painter: _ChatDotsIconPainter(color: Colors.white),
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
                        style: GoogleFonts.inter(
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
                              style: GoogleFonts.inter(
                                color: _accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                height: 1.2,
                              ),
                            ),
                            TextSpan(
                              text: '  •  $requestMeta',
                              style: GoogleFonts.inter(
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
                        style: GoogleFonts.inter(
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
                              style: GoogleFonts.inter(
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
                style: GoogleFonts.inter(
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
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Near Marhaba Supermarket,Nouakchott',
                        style: GoogleFonts.inter(
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
                  style: GoogleFonts.inter(
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
          style: GoogleFonts.inter(
            color: const Color(0xFFB0B7C3),
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.4,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        const _AvailabilityStatus(availability: _Availability.limited),
        const SizedBox(height: 8),
        Text(
          'Paracetamol 650 mg',
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 15.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const _AvailableCountPill(available: 6, prescribed: 10),
        const SizedBox(height: 12),
        const _OrderItemTotals(detail: '10 tablets × 50 MRU', total: '500 MRU'),
        const SizedBox(height: 18),
        const _AvailabilityStatus(availability: _Availability.outOfStock),
        const SizedBox(height: 8),
        Text(
          'Paracetamol 500 mg',
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 15.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Suggested Alternative',
          style: GoogleFonts.inter(
            color: const Color(0xFF9CA3AF),
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F7FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4E4FF)),
          ),
          child: const Column(
            children: [
              _OrderAltRow(name: 'Paracetamol 500 mg', inStock: false),
              SizedBox(height: 10),
              _OrderAltRow(name: 'Paracetamol 650 mg', inStock: true),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _OrderItemTotals(detail: '10 tablets × 50 MRU', total: '500 MRU'),
      ],
    );
  }
}

class _OrderAltRow extends StatelessWidget {
  const _OrderAltRow({required this.name, required this.inStock});

  final String name;
  final bool inStock;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: inStock ? const Color(0xFF22C55E) : const Color(0xFFFF3250),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.inter(
              color: const Color(0xFF2C2C2C),
              fontWeight: FontWeight.w500,
              fontSize: 14.5,
            ),
          ),
        ),
      ],
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
              style: GoogleFonts.inter(
                color: const Color(0xFFB0B0B0),
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              style: GoogleFonts.inter(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
                fontSize: 13,
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
              style: GoogleFonts.inter(
                color: const Color(0xFFB0B0B0),
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              total,
              style: GoogleFonts.inter(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AwaitingPaymentSummary extends StatelessWidget {
  const _AwaitingPaymentSummary();

  static const Color _orange = Color(0xFFFF5722);

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
                style: GoogleFonts.inter(
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
          const _AwaitingSummaryLine(label: 'Item total', value: '1500 MRU'),
          const SizedBox(height: 12),
          const _AwaitingSummaryLine(label: 'Tax', value: '10'),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: Color(0xFF5C5C5C)),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                '1510 MRU',
                style: GoogleFonts.inter(
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
          style: GoogleFonts.inter(
            color: const Color(0xFFD0D0D0),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _AwaitingOrderItems extends StatelessWidget {
  const _AwaitingOrderItems();

  static const _items = <(String, String)>[
    ('Doliprane 500mg', '50 MRU'),
    ('Augmentin 1g', '50 MRU'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORDER ITEMS (2)',
          style: GoogleFonts.inter(
            color: const Color(0xFFB0B7C3),
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.4,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < _items.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _items[i].$1,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF2C2C2C),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _items[i].$2,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFF5722),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Qty: 1 Strip',
                    style: GoogleFonts.inter(
                      color: const Color.fromARGB(255, 96, 96, 96),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _QuotationSummaryCard extends StatelessWidget {
  const _QuotationSummaryCard();

  static const Color _orange = Color(0xFFFF5722);

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
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.2,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Item total',
                style: GoogleFonts.inter(
                  color: const Color(0xFFD0D0D0),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                '100 MRU',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: Color(0xFF5C5C5C)),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const Spacer(),
              Text(
                '100 MRU',
                style: GoogleFonts.inter(
                  color: _orange,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AwaitingCustomerPaymentCard extends StatelessWidget {
  const _AwaitingCustomerPaymentCard();

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
                  style: GoogleFonts.inter(
                    color: const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '23/04/2026 10:45 AM',
                  style: GoogleFonts.inter(
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
      crossAxisAlignment:
          hasSubtitle ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        if (step.completed)
          Container(
            width: iconSize,
            height: iconSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: orange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.icon,
              size: 16,
              color: Colors.white,
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
                  ? Icon(
                      step.icon,
                      size: 14,
                      color: inactiveIcon,
                    )
                  : SizedBox(
                      width: step.customIcon == _TimelineCustomIcon.openBox
                          ? 17
                          : 15,
                      height: step.customIcon == _TimelineCustomIcon.openBox
                          ? 17
                          : 15,
                      child: CustomPaint(
                        painter: switch (step.customIcon!) {
                          _TimelineCustomIcon.capsule =>
                            _CapsuleIconPainter(color: inactiveIcon),
                          _TimelineCustomIcon.scooter =>
                            _ScooterIconPainter(color: inactiveIcon),
                          _TimelineCustomIcon.openBox =>
                            _OpenBoxIconPainter(color: inactiveIcon),
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
                  style: GoogleFonts.inter(
                    color: step.completed
                        ? const Color(0xFF1A1A1A)
                        : inactiveText,
                    fontWeight:
                        step.completed ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 14.5,
                    height: 1.25,
                  ),
                ),
                if (hasSubtitle) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.subtitle!,
                    style: GoogleFonts.inter(
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
    canvas.drawLine(
      Offset(0, -h / 2 + 0.5),
      Offset(0, h / 2 - 0.5),
      stroke,
    );

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
    canvas.drawLine(Offset(0.6 * sx, 5.2 * sy), Offset(2.4 * sx, 5.2 * sy), stroke);
    canvas.drawLine(Offset(0.4 * sx, 6.8 * sy), Offset(2.2 * sx, 6.8 * sy), stroke);
    canvas.drawLine(Offset(0.8 * sx, 8.4 * sy), Offset(2.4 * sx, 8.4 * sy), stroke);

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
                  style: GoogleFonts.inter(
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
                    style: GoogleFonts.inter(
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
  const _DeliveryPartnerSection();

  static const Color _orange = Color(0xFFFF5722);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DELIVERY PARTNER',
          style: GoogleFonts.inter(
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
                      'Mohamed Abdallahi',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1A2332),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                          style: GoogleFonts.inter(
                            color: const Color(0xFF1A2332),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(124 reviews)',
                          style: GoogleFonts.inter(
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

  static const Color _orange = Color(0xFFFF5722);

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
            style: GoogleFonts.inter(
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
    required this.assetPath,
    required this.rotationTurns,
  });

  final String assetPath;
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
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
