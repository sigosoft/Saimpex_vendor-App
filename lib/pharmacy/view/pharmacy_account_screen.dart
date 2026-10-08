import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_business_settings_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_coupons_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_earnings_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_leave_management_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_profile_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_received_payouts_screen.dart';
import 'package:saimpex_vendor/pharmacy/view/pharmacy_working_hours_screen.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/view/login/login.dart';

class PharmacyAccountScreen extends StatefulWidget {
  const PharmacyAccountScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  static const orange = Color(0xFFFF5216);
  static const ink = Color(0xFF1C1D1B);
  static const iconBg = Color(0xFFEFEEEA);

  @override
  State<PharmacyAccountScreen> createState() => _PharmacyAccountScreenState();
}

class _PharmacyAccountScreenState extends State<PharmacyAccountScreen> {
  int _language = 0;
  bool _notifications = true;

  void _openMenu() {
    final top = MediaQuery.paddingOf(context).top + 56;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: const Color(0xFF1A1A1A).withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (dialogContext, _, _) {
        return Padding(
          padding: EdgeInsets.only(top: top, right: 12),
          child: Align(
            alignment: Alignment.topRight,
            child: Material(
              color: Colors.white,
              elevation: 6,
              shadowColor: const Color(0xFF1A1A1A).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => Navigator.of(dialogContext).pop(),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _DeleteLidIcon(),
                      const SizedBox(width: 8),
                      Text(
                        'Delete Account',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1C1D1B),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFC8C8C8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    await savename('loginStatus', 'false');
    await savename('token', '');
    Get.offAll(() => const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1E4),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 8, bottom: 28),
              child: _AccountHeader(onBack: widget.onBack, onMenu: _openMenu),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  const _ProfileCard(),
                  const SizedBox(height:10),
                  Text(
                    'Language',
                    style: GoogleFonts.inter(
                      color: PharmacyAccountScreen.orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _LanguageBar(
                    selected: _language,
                    onSelect: (index) => setState(() => _language = index),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Business',
                    style: GoogleFonts.inter(
                      color: PharmacyAccountScreen.orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MenuCard(
                    divided: true,
                    children: [
                      _MenuTile(
                        icon: Icons.notifications_none_rounded,
                        label: 'Notification',
                        trailing: Switch(
                          value: _notifications,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onChanged: (value) {
                            HapticFeedback.selectionClick();
                            setState(() => _notifications = value);
                          },
                          thumbColor: const WidgetStatePropertyAll(Colors.white),
                          trackColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return PharmacyAccountScreen.orange;
                            }
                            return const Color(0xFFE5E7EB);
                          }),
                          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                        ),
                      ),
                      _MenuTile(
                        icon: Icons.domain_outlined,
                        label: 'Pharmacy Profile',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuTile(
                        icon: Icons.access_time_rounded,
                        label: 'Working hours',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyWorkingHoursScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuTile(
                        image: 'lib/pharmacy/Assets/images/business_settings.png',
                        imageSize: 19,
                        label: 'Business settings',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyBusinessSettingsScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuTile(
                        image: 'lib/pharmacy/Assets/images/leave_management.png',
                        imageSize: 19,
                        label: 'Leave Management',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyLeaveManagementScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuTile(
                        image: 'lib/pharmacy/Assets/images/currency.png',
                        imageSize: 20,
                        label: 'Earnings',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyEarningsScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuTile(
                        image: 'lib/pharmacy/Assets/images/received_payouts.png',
                        imageSize: 22,
                        label: 'Received Payouts',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyReceivedPayoutsScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuTile(
                        icon: Icons.sell_outlined,
                        label: 'Coupons',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PharmacyCouponsScreen(),
                            ),
                          );
                        },
                      ),
                      const _MenuTile(icon: Icons.delivery_dining_outlined, label: 'Delivery Boys'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionLabel('Support & Legal'),
                  const SizedBox(height: 10),
                  const _MenuCard(
                    children: [
                      _MenuTile(icon: Icons.headset_mic_outlined, label: 'Help & Support'),
                      _MenuTile(icon: Icons.description_outlined, label: 'Terms & Conditions'),
                      _MenuTile(
                        image: 'lib/pharmacy/Assets/images/privacy_policy.png',
                        imageSize: 20,
                        label: 'Privacy Policy',
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  InkWell(
                    onTap: _logout,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, color: PharmacyAccountScreen.orange, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'Logout',
                            style: GoogleFonts.inter(
                              color: PharmacyAccountScreen.orange,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'V2.8.1',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF858585),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Check for update',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF5C5C5C),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFF5C5C5C),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({this.onBack, this.onMenu});

  final VoidCallback? onBack;
  final VoidCallback? onMenu;

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
              'Account',
              style: GoogleFonts.inter(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
                height: 1.2,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onBack,
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
                    color: PharmacyAccountScreen.orange,
                    size: 26,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: onMenu,
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(Icons.more_vert, color: Color(0xFF1A1A1A), size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
              const SizedBox(width: 2),
              Text(
                '4.8',
                style: GoogleFonts.inter(
                  color: PharmacyAccountScreen.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Open',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF16A34A),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const _LogoBadge(),
          const SizedBox(height: 12),
          Text(
            'Pharmacy SAIMPEX',
            style: GoogleFonts.inter(
              color: PharmacyAccountScreen.ink,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 16),
              const SizedBox(width: 4),
              Text(
                'Verified',
                style: GoogleFonts.inter(
                  color: const Color(0xFF16A34A),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'ID: PH-99283',
            style: GoogleFonts.inter(
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/pharmacy/Assets/images/profile_iconimage.png',
      width: 112,
      height: 112,
      fit: BoxFit.contain,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
        style: GoogleFonts.inter(
          color: const Color(0xFF8B919E),
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.2,
        ),
    );
  }
}

class _LanguageBar extends StatelessWidget {
  const _LanguageBar({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  static const _labels = ['English', 'French', 'Arabic'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDFD7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segment = constraints.maxWidth / _labels.length;
          return SizedBox(
            height: 40,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  left: selected * segment,
                  top: 0,
                  bottom: 0,
                  width: segment,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: PharmacyAccountScreen.orange,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(_labels.length, (index) {
                    final isSelected = selected == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (index == selected) return;
                          HapticFeedback.selectionClick();
                          onSelect(index);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            style: GoogleFonts.inter(
                              color: isSelected ? Colors.white : const Color(0xFF3F3F4D),
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              fontSize: 14,
                              height: 1.1,
                            ),
                            child: Text(_labels[index]),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children, this.divided = false});

  final List<Widget> children;
  final bool divided;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (divided && i != children.length - 1) {
        rows.add(const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFF1F1F1),
          indent: 16,
          endIndent: 16,
        ));
      }
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5216).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: rows),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    this.icon,
    this.image,
    this.imageSize = 20,
    required this.label,
    this.trailing,
    this.labelColor = const Color(0xFF1C1D1B),
    this.showChevron = true,
    this.onTap,
  });

  final IconData? icon;
  final String? image;
  final double imageSize;
  final String label;
  final Widget? trailing;
  final Color labelColor;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: PharmacyAccountScreen.iconBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            child: image != null
                ? SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: Image.asset(image!, fit: BoxFit.contain),
                  )
                : Icon(icon, color: PharmacyAccountScreen.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: labelColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ),
          trailing ??
              (showChevron
                  ? const Icon(Icons.chevron_right_rounded, color: Color(0xFFC8C8C8), size: 22)
                  : const SizedBox(width: 22)),
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

class _DeleteLidIcon extends StatefulWidget {
  const _DeleteLidIcon();

  @override
  State<_DeleteLidIcon> createState() => _DeleteLidIconState();
}

class _DeleteLidIconState extends State<_DeleteLidIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _lidOpen(double t) {
    if (t < 0.35) return Curves.easeOutCubic.transform(t / 0.35);
    if (t < 0.55) return 1;
    if (t < 0.90) return 1 - Curves.easeInCubic.transform((t - 0.55) / 0.35);
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _DeleteLidPainter(lidOpen: _lidOpen(_controller.value)),
          );
        },
      ),
    );
  }
}

class _DeleteLidPainter extends CustomPainter {
  const _DeleteLidPainter({required this.lidOpen});

  final double lidOpen;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PharmacyAccountScreen.orange
      ..style = PaintingStyle.fill;

    final body = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        size.width * 0.22,
        size.height * 0.38,
        size.width * 0.56,
        size.height * 0.54,
      ),
      bottomLeft: const Radius.circular(2.5),
      bottomRight: const Radius.circular(2.5),
    );
    canvas.drawRRect(body, paint);

    final slot = Paint()..color = Colors.white;
    final slotTop = body.top + body.height * 0.18;
    final slotHeight = body.height * 0.55;
    final slotWidth = size.width * 0.07;
    for (final left in [body.left + body.width * 0.28, body.left + body.width * 0.58]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, slotTop, slotWidth, slotHeight),
          const Radius.circular(1.5),
        ),
        slot,
      );
    }

    final lid = Rect.fromLTWH(
      size.width * 0.12,
      size.height * 0.28,
      size.width * 0.76,
      size.height * 0.10,
    );
    final hinge = Offset(lid.left, lid.bottom);
    canvas.save();
    canvas.translate(hinge.dx, hinge.dy);
    canvas.rotate(-0.9 * lidOpen);
    canvas.translate(-hinge.dx, -hinge.dy);
    canvas.drawRRect(RRect.fromRectAndRadius(lid, const Radius.circular(1.2)), paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.38,
          size.height * 0.16,
          size.width * 0.24,
          size.height * 0.12,
        ),
        const Radius.circular(1.5),
      ),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DeleteLidPainter oldDelegate) {
    return oldDelegate.lidOpen != lidOpen;
  }
}
