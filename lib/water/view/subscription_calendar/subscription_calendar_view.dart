import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/water/core/water_state_view.dart';

/// Delivery calendar for water subscriptions.
///
/// The backend has no endpoint that returns scheduled deliveries per day
/// (slots, customers, per-day counts), so the planner is not shown and the
/// screen says it is not available yet. See issues_water.md
/// ("[vendor-app] Water: no delivery calendar endpoint").
class SubscriptionCalendarView extends StatelessWidget {
  const SubscriptionCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF9F6),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF1EB),
                Color(0xFFFFF9F6),
                Color(0xFFFFF9F6),
              ],
              stops: [0, 0.22, 1],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              _Header(onBack: () => Navigator.of(context).maybePop()),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    WaterStateView.empty(
                      title: S.of(context).waterCalendarNotAvailable,
                      message: S.of(context).waterCalendarNotAvailableHint,
                      icon: Icons.calendar_month_outlined,
                    ),
                  ],
                ),
              ),
            ],
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
              S.of(context).waterSubscriptionCalendar,
              style: GoogleFonts.inter(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
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
                    border: Border.all(color: const Color(0xFFFFE0D0)),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Color(0xFFFF5216),
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
