import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom painter for dashed rounded border.
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double radius;

  DashedBorderPainter({
    this.color = const Color(0xFFCBD5E1),
    this.strokeWidth = 1.2,
    this.dash = 6.0,
    this.gap = 4.0,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(
          metric.extractPath(
            distance,
            next > metric.length ? metric.length : next,
          ),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dash != dash ||
      oldDelegate.gap != gap ||
      oldDelegate.radius != radius;
}

/// Form field label used on Edit Items screen.
class EditItemsFieldLabel extends StatelessWidget {
  final String label;
  final Color? color;

  const EditItemsFieldLabel(this.label, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.rubik(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color ?? const Color(0xFF475569),
      ),
    );
  }
}

/// Card container for sections on Edit Items screen.
class EditItemsCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const EditItemsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Styled text field used on Edit Items screen.
class EditItemsTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool fullWidth;
  final int maxLines;
  final String? suffixText;

  const EditItemsTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.fullWidth = true,
    this.maxLines = 1,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: maxLines > 1 ? 84 : 44,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.rubik(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.rubik(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
          suffixIcon: suffixText != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      suffixText!,
                      style: GoogleFonts.rubik(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: maxLines > 1 ? 12 : 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFF5216), width: 1),
          ),
        ),
      ),
    );
  }
}

/// Styled dropdown used on Edit Items screen.
class EditItemsDropdownField extends StatelessWidget {
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? value;
  final String? hint;
  final bool fullWidth;

  const EditItemsDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 44,
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        isExpanded: true,
        hint: hint != null
            ? Text(
                hint!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
                ),
              )
            : null,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF64748B),
          size: 20,
        ),
        style: GoogleFonts.rubik(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFF5216), width: 1),
          ),
        ),
        items: items
            .toSet()
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class EditItemsMultiSelectField extends StatelessWidget {
  final String? displayText;
  final String? hint;
  final bool fullWidth;
  final VoidCallback onTap;

  const EditItemsMultiSelectField({
    super.key,
    required this.onTap,
    this.displayText,
    this.hint,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final textToShow = (displayText != null && displayText!.trim().isNotEmpty)
        ? displayText!.trim()
        : null;
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 44,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFF5216), width: 1),
            ),
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF64748B),
              size: 20,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              textToShow ?? (hint ?? ''),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.rubik(
                fontSize: 13,
                fontWeight:
                    textToShow == null ? FontWeight.w400 : FontWeight.w500,
                color: textToShow == null
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF1F2937),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom bar with Reset and Submit buttons for Edit Items screen.
class EditItemsBottomBar extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onSubmit;

  const EditItemsBottomBar({
    super.key,
    required this.onReset,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: GoogleFonts.rubik(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5216),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: GoogleFonts.rubik(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
