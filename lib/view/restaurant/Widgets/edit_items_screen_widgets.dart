import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditItemsFieldLabel extends StatelessWidget {
  final String label;

  const EditItemsFieldLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.rubik(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF1F2937),
      ),
    );
  }
}

class EditItemsTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool fullWidth;

  const EditItemsTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 48,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.rubik(fontSize: 14, color: const Color(0xFF1F2937)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.rubik(
            fontSize: 14,
            color: const Color(0xFF94A3B8).withOpacity(0.6),
          ),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
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
      height: 48,
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        isExpanded: true,
        hint: hint != null
            ? Text(
                hint!,
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  color: const Color(0xFF94A3B8).withOpacity(0.6),
                ),
              )
            : null,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF94A3B8),
          size: 24,
        ),
        style: GoogleFonts.rubik(fontSize: 14, color: const Color(0xFF1F2937)),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFF5216), width: 1),
          ),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
      height: 48,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFF5216), width: 1),
            ),
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF94A3B8),
              size: 24,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              textToShow ?? (hint ?? ''),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.rubik(
                fontSize: 14,
                fontWeight:
                    textToShow == null ? FontWeight.w400 : FontWeight.w500,
                color: textToShow == null
                    ? const Color(0xFF94A3B8).withOpacity(0.6)
                    : const Color(0xFF1F2937),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

