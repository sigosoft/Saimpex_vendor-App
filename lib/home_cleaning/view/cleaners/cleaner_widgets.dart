import 'package:flutter/material.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/home_cleaning/model/cleaner.dart';
import 'package:saimpex_vendor/resources/fonts.dart';

// Shared pieces of the cleaner screens (task V16), Figma "V2 Additions
// (1 Nov)": Home Cleaning – My Cleaners (10868:11391), Add Cleaner
// (10868:11643), Assign Cleaner (10868:11841), Booking with Cleaner
// (10868:12059).

const Color cleanerPageBg = Color(0xFFFFF8F0);
const Color cleanerOrange = Color(0xFFFF5216);
const Color cleanerInk = Color(0xFF111827);
const Color cleanerMuted = Color(0xFF6B7280);
const Color cleanerBorder = Color(0xFFF0ECE4);

TextStyle cleanerText(double size, FontWeight w, Color c) => appFont('Inter', fontSize: size, fontWeight: w, color: c);

String _two(int v) => v.toString().padLeft(2, '0');

/// "4.8 ★ · 12 reviews" or "New".
String cleanerStats(BuildContext context, Cleaner c) {
  if (c.rating == null) return S.of(context).cleanerNew;
  return '${c.rating!.toStringAsFixed(1)} ★ · ${S.of(context).cleanerReviewsCount(c.reviewsCount.toString())}';
}

class CleanerAvatar extends StatelessWidget {
  const CleanerAvatar({super.key, required this.cleaner, this.size = 44});

  final Cleaner cleaner;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = cleaner.photoUrl;
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: const Color(0xFFEAF2FF),
        alignment: Alignment.center,
        child: url != null
            ? Image.network(url, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _letter())
            : _letter(),
      ),
    );
  }

  Widget _letter() => Text(cleaner.initial, style: cleanerText(size * 0.4, FontWeight.w700, const Color(0xFF2563EB)));
}

/// Available / Busy · 10:00–12:00 / Deactivated pill.
class CleanerStatusPill extends StatelessWidget {
  const CleanerStatusPill({super.key, required this.cleaner});

  final Cleaner cleaner;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final (String label, Color fg, Color bg) = !cleaner.active || cleaner.availability == 'inactive'
        ? (s.cleanerDeactivated, cleanerMuted, const Color(0xFFF3F4F6))
        : cleaner.isBusy
            ? (
                cleaner.busyFrom == null
                    ? s.cleanerBusy
                    : '${s.cleanerBusy} · ${_two(cleaner.busyFrom!.hour)}:${_two(cleaner.busyFrom!.minute)}',
                const Color(0xFFEA7A1A),
                const Color(0xFFFFF1E6),
              )
            : (s.cleanerAvailable, const Color(0xFF16A34A), const Color(0xFFE8F7EE));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: cleanerText(12, FontWeight.w600, fg)),
    );
  }
}

/// The page header used by the cleaner screens (back button + title).
class CleanerHeader extends StatelessWidget {
  const CleanerHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          elevation: 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => Navigator.of(context).maybePop(),
            child: const SizedBox(width: 36, height: 36, child: Icon(Icons.chevron_left, color: cleanerOrange)),
          ),
        ),
        Expanded(child: Text(title, textAlign: TextAlign.center, style: cleanerText(18, FontWeight.w700, cleanerInk))),
        const SizedBox(width: 36),
      ]),
    );
  }
}
