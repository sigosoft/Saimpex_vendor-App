import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Filter options for stock history lists.
enum StockHistoryFilterKind { all, added, removed }

/// Pill-shaped filter chips: All / Added / Removed (matches vendor orange accent).
class StockHistoryFilterBar extends StatelessWidget {
  const StockHistoryFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final StockHistoryFilterKind selected;
  final ValueChanged<StockHistoryFilterKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Chip(
            label: 'All',
            isSelected: selected == StockHistoryFilterKind.all,
            onTap: () => onChanged(StockHistoryFilterKind.all),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Chip(
            label: 'Added',
            isSelected: selected == StockHistoryFilterKind.added,
            onTap: () => onChanged(StockHistoryFilterKind.added),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Chip(
            label: 'Removed',
            isSelected: selected == StockHistoryFilterKind.removed,
            onTap: () => onChanged(StockHistoryFilterKind.removed),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const _orange = Color(0xFFFF5216);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? _orange : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.rubik(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF4B5563),
            ),
          ),
        ),
      ),
    );
  }
}
