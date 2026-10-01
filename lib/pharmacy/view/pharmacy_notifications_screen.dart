import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/pharmacy/model/pharmacy_order.dart';
import 'package:saimpex_vendor/pharmacy/view/order_details_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/reject_order_sheet.dart';

class PharmacyNotificationsScreen extends StatelessWidget {
  const PharmacyNotificationsScreen({super.key});

  static const _orange = Color(0xFFFF5317);
  static const _link = Color(0xFFFF5722);
  static const _name = Color(0xFF2D3444);
  static const _meta = Color(0xFF6B7280);
  static const _badge = Color(0xFFF59E0B);
  static const _payBg = Color(0xFFF4F4F0);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFE8E0),
                Color(0xFFFFF4EF),
                Colors.white,
                Colors.white,
              ],
              stops: [0, 0.16, 0.34, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _Header(onBack: () => Navigator.of(context).maybePop()),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      _OrderNotificationCard(
                        onReject: () => showPharmacyRejectOrderSheet(context),
                        onPrimary: () => _openDetails(context),
                        primaryLabel: 'Review Prescription',
                        middle: _PrescriptionBox(
                          onView: () => _openDetails(context),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _OrderNotificationCard(
                        onReject: () => showPharmacyRejectOrderSheet(context),
                        onPrimary: () => _openDetails(context),
                        primaryLabel: 'Accept Order',
                        middle: const _OtcPills(),
                      ),
                      const SizedBox(height: 14),
                      const _PaymentVerifiedCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PharmacyOrderDetailsScreen(
          customerName: 'Ahmed',
          requestMeta: 'Today • 10:45 AM',
          notesType: PharmacyOrderNotesType.none,
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
              'Notifications',
              style: GoogleFonts.inter(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w700,
                fontSize: 17,
                height: 1.1,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Color(0xFFFF5722),
                    size: 26,
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

class _OrderNotificationCard extends StatelessWidget {
  const _OrderNotificationCard({
    required this.middle,
    required this.primaryLabel,
    required this.onReject,
    required this.onPrimary,
  });

  final Widget middle;
  final String primaryLabel;
  final VoidCallback onReject;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return _AccentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CustomerHeader(),
          const SizedBox(height: 14),
          middle,
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 46,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: onReject,
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Text(
                          'Reject',
                          maxLines: 1,
                          softWrap: false,
                          style: GoogleFonts.inter(
                            color: PharmacyNotificationsScreen._name,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 46,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: PharmacyNotificationsScreen._orange,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: PharmacyNotificationsScreen._orange
                              .withValues(alpha: 0.32),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onPrimary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        primaryLabel,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: false,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerHeader extends StatelessWidget {
  const _CustomerHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFFEE2E2),
            shape: BoxShape.circle,
          ),
          child: Text(
            'A',
            style: GoogleFonts.inter(
              color: const Color(0xFFDC2626),
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ahmed',
                      style: GoogleFonts.inter(
                        color: PharmacyNotificationsScreen._name,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.15,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: PharmacyNotificationsScreen._badge,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'NEW',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.4,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: _DeliveryMeta(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeliveryMeta extends StatelessWidget {
  const _DeliveryMeta();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'lib/pharmacy/Assets/images/delivery_icon.png',
          width: 16,
          height: 16,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 4),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Delivery',
                style: GoogleFonts.inter(
                  color: PharmacyNotificationsScreen._link,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  height: 1,
                ),
              ),
              TextSpan(
                text: '  • #22789007 • 2 min ago',
                style: GoogleFonts.inter(
                  color: PharmacyNotificationsScreen._meta,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.5,
                  height: 1,
                ),
              ),
            ],
          ),
          maxLines: 1,
          softWrap: false,
        ),
      ],
    );
  }
}

class _PrescriptionBox extends StatelessWidget {
  const _PrescriptionBox({required this.onView});

  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(
            'lib/pharmacy/Assets/images/prescription_home.png',
            width: 52,
            height: 56,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prescription_Jun25.jpg',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: PharmacyNotificationsScreen._name,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onView,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Full Prescription',
                        style: GoogleFonts.inter(
                          color: PharmacyNotificationsScreen._link,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.open_in_new_rounded,
                        size: 14,
                        color: PharmacyNotificationsScreen._link,
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

class _OtcPills extends StatelessWidget {
  const _OtcPills();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Flexible(
          child: _InfoPill(
            icon: Icon(
              Icons.inventory_2_outlined,
              size: 16,
              color: PharmacyNotificationsScreen._link,
            ),
            label: '2 Items • 80 MRU',
          ),
        ),
        SizedBox(width: 8),
        Flexible(
          child: _InfoPill(
            icon: Image(
              image: AssetImage(
                'lib/pharmacy/Assets/images/online_payment.png',
              ),
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
            label: 'Online Payment',
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentVerifiedCard extends StatelessWidget {
  const _PaymentVerifiedCard();

  @override
  Widget build(BuildContext context) {
    return _AccentCard(
      background: const Color.fromARGB(255, 255, 255, 243),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF9AF7A8),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'lib/pharmacy/Assets/images/verified.png',
              width: 22,
              height: 22,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Payment Verified',
                        style: GoogleFonts.inter(
                          color: PharmacyNotificationsScreen._name,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.2,
                        ),
                      ),
                    ),
                    Text(
                      '1h ago',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Admin has verified payment for ',
                      ),
                      TextSpan(
                        text: '#ORD-8821',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const TextSpan(
                        text: '.\nYou can now ship the items.',
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

class _AccentCard extends StatelessWidget {
  const _AccentCard({
    required this.child,
    this.background = Colors.white,
  });

  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
