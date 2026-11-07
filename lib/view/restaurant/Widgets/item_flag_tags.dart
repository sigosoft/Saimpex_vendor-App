import 'package:flutter/material.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/fonts.dart';

/// True for 1 / "1" / true / "true" (API flags).
bool apiFlag(dynamic v) {
  final s = v?.toString().trim().toLowerCase();
  return s == '1' || s == 'true';
}

/// Figma item tags: Popular, Veg, New arrival. From the restaurant item
/// APIs (backend #175 / #179): `is_popular`, `is_veg`, `is_new_arrival`.
/// Shows nothing when no flag is set.
class ItemFlagTags extends StatelessWidget {
  const ItemFlagTags({
    super.key,
    this.popular = false,
    this.veg = false,
    this.newArrival = false,
  });

  /// Reads the three flags from a raw API row.
  factory ItemFlagTags.fromRaw(Map<String, dynamic>? raw, {Key? key}) =>
      ItemFlagTags(
        key: key,
        popular: apiFlag(raw?['is_popular']),
        veg: apiFlag(raw?['is_veg']),
        newArrival: apiFlag(raw?['is_new_arrival']),
      );

  final bool popular;
  final bool veg;
  final bool newArrival;

  bool get isEmpty => !popular && !veg && !newArrival;

  Widget _tag(String text, Color fg, Color bg, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
            Text(
              text,
              style: appFont('Rubik',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (isEmpty) return const SizedBox.shrink();
    final s = S.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (popular)
          _tag(s.itemPopularTag, const Color(0xFFFF5216),
              const Color(0xFFFFEDE5), Icons.local_fire_department),
        if (veg)
          _tag(s.veg, const Color(0xFF16A34A), const Color(0xFFDCFCE7),
              Icons.eco),
        if (newArrival)
          _tag(s.itemNewArrivalTag, const Color(0xFF2563EB),
              const Color(0xFFDBEAFE), Icons.fiber_new),
      ],
    );
  }
}
