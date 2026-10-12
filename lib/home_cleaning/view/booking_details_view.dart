import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:saimpex_vendor/home_cleaning/view/reject_booking_sheet.dart';

class BookingDetailsView extends StatefulWidget {
  const BookingDetailsView({
    super.key,
    required this.customerName,
    required this.serviceName,
    required this.orderId,
  });

  final String customerName;
  final String serviceName;
  final String orderId;

  static const _orange = Color(0xFFFF5722);
  static const _ink = Color(0xFF1A1A1A);
  static const _muted = Color(0xFF9E9E9E);

  @override
  State<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends State<BookingDetailsView> {
  final _serviceKey = GlobalKey();
  double _fadeEnd = 360;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureFade());
  }

  void _measureFade() {
    final box = _serviceKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !mounted) return;
    final mid = box.localToGlobal(Offset.zero).dy + box.size.height / 2;
    if ((mid - _fadeEnd).abs() > 1) {
      setState(() => _fadeEnd = mid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _fadeEnd,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFE8DC),
                      Color(0xFFFFF3EC),
                      Color(0xFFFFFFFF),
                    ],
                    stops: [0, 0.5, 1],
                  ),
                ),
              ),
            ),
            Column(
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
                        'Booking Details',
                        style: GoogleFonts.inter(
                          color: BookingDetailsView._ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
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
                              border: Border.all(color: const Color(0xFFFFE0D0)),
                            ),
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              color: BookingDetailsView._orange,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  children: [
                    _CustomerCard(
                      name: widget.customerName,
                      orderId: widget.orderId,
                    ),
                    const SizedBox(height: 12),
                    _ServiceCard(
                      key: _serviceKey,
                      serviceName: widget.serviceName,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SPACES',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9AA3B2),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _SpacesCard(),
                    const SizedBox(height: 16),
                    Text(
                      'MAKE IT EXTRA CLEAN',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9AA3B2),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _WhiteCard(
                      child: _SpaceTile(
                        title: 'Fridge Cleaning',
                        detail: '100 MRU x 1',
                        total: '100 MRU',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _ProductsCard(),
                    const SizedBox(height: 16),
                    Text(
                      'SPECIAL NOTES',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9AA3B2),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.sticky_note_2_outlined,
                            color: Color(0xFFFF5722),
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras vestibulum mattis',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF7A4E32),
                                fontWeight: FontWeight.w500,
                                fontSize: 13.5,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _LocationCard(),
                    const SizedBox(height: 16),
                    Text(
                      'PAYMENT SUMMARY',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9AA3B2),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _PaymentCard(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                showRejectBookingSheet(context);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: BookingDetailsView._ink,
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFFE0E0E0)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Reject',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF424242),
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
                            child: ElevatedButton(
                              onPressed: () => HapticFeedback.lightImpact(),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: BookingDetailsView._orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Accept Booking',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.name, required this.orderId});

  final String name;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'lib/home_cleaning/Assets/images/account.png',
                width: 16,
                height: 16,
                color: BookingDetailsView._orange,
                colorBlendMode: BlendMode.srcIn,
              ),
              const SizedBox(width: 6),
              Text(
                'CUSTOMER',
                style: GoogleFonts.inter(
                  color: BookingDetailsView._orange,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'NEW',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F8),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFFDECEC),
                  child: Text(
                    name.isEmpty ? 'A' : name[0],
                    style: GoogleFonts.inter(
                      color: BookingDetailsView._orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          color: BookingDetailsView._ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+222 45 12 34 56',
                        style: GoogleFonts.inter(
                          color: BookingDetailsView._muted,
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: BookingDetailsView._orange,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'lib/home_cleaning/Assets/images/chat.png',
                    width: 20,
                    height: 20,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REQUEST ID',
                  style: GoogleFonts.inter(
                    color: BookingDetailsView._muted,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: orderId,
                        style: GoogleFonts.inter(
                          color: BookingDetailsView._orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: ' • Today • 10:45 AM',
                        style: GoogleFonts.inter(
                          color: BookingDetailsView._muted,
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
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

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({super.key, required this.serviceName});

  final String serviceName;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'lib/home_cleaning/Assets/images/regularcleaning.png',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: GoogleFonts.inter(
                    color: BookingDetailsView._ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF42A5F5)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '15 Aug 2026, 2:00 PM - 4:00 PM',
                        softWrap: false,
                        maxLines: 1,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF616161),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpacesCard extends StatelessWidget {
  const _SpacesCard();

  @override
  Widget build(BuildContext context) {
    return const _WhiteCard(
      child: Column(
        children: [
          _SpaceTile(title: 'Bedrooms', detail: '100 MRU x 4', total: '400 MRU'),
          SizedBox(height: 10),
          _SpaceTile(title: 'Kitchens', detail: '150 MRU x 1', total: '150 MRU'),
        ],
      ),
    );
  }
}

class _SpaceTile extends StatelessWidget {
  const _SpaceTile({
    required this.title,
    required this.detail,
    required this.total,
  });

  final String title;
  final String detail;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8A8A8A),
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            total,
            style: GoogleFonts.inter(
              color: const Color(0xFFFF5722),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsCard extends StatelessWidget {
  const _ProductsCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'CLEANING PRODUCTS',
              style: GoogleFonts.inter(
                color: const Color(0xFF9AA3B2),
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.6,
              ),
            ),
            const Spacer(),
            Text(
              '+120 MRU',
              style: GoogleFonts.inter(
                color: const Color(0xFFFF5722),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6F2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Provider will provide products',
                style: GoogleFonts.inter(
                  color: const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Cleaning products will be provided by the service provider',
                style: GoogleFonts.inter(
                  color: const Color(0xFF5C534E),
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E0EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                children: [
                  const Positioned.fill(child: _BookingMap()),
                  const Align(
                    alignment: Alignment(0.12, -0.28),
                    child: Icon(Icons.location_on, color: Color(0xFFFF5722), size: 50),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4EEF8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined, color: Color(0xFF7E57C2), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Sahara View Home',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF1D1B20),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sahara View Home',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF1D1B20),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '123 Desert Rose Blvd, Suite 4B',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF494551),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
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


class _BookingMap extends StatelessWidget {
  const _BookingMap();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(18.0885, -15.9782),
          zoom: 15.2,
        ),
        zoomControlsEnabled: false,
        scrollGesturesEnabled: false,
        zoomGesturesEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
        liteModeEnabled: true,
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PAYMENT DETAILS',
            style: GoogleFonts.inter(
              color: const Color(0xFFFF5722),
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          const _PayRow('Total', '730 MRU'),
          const SizedBox(height: 12),
          const _PayRow('Payment type', 'Online Payment', valueColor: Color(0xFFFF5722)),
          const SizedBox(height: 12),
          const _PayRow('Payment on', 'Aug 25, 2026 10:45 AM, Today'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, thickness: 1, color: Color(0xFF3A3A3A)),
          ),
          const _PayRow('Total paid', '730 MRU', emphasize: true),
        ],
      ),
    );
  }
}

class _PayRow extends StatelessWidget {
  const _PayRow(
    this.label,
    this.value, {
    this.valueColor = Colors.white,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.inter(
      color: emphasize ? Colors.white : const Color(0xFFE4E4E4),
      fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
      fontSize: emphasize ? 15 : 13.5,
    );
    final valueStyle = GoogleFonts.inter(
      color: valueColor,
      fontWeight: emphasize || valueColor != Colors.white ? FontWeight.w700 : FontWeight.w600,
      fontSize: emphasize ? 16 : 13.5,
    );
    return Row(
      children: [
        Text(label, style: labelStyle),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value, textAlign: TextAlign.right, style: valueStyle),
        ),
      ],
    );
  }
}
