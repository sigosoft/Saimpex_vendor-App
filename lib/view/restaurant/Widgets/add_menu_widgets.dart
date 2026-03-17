import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMenuFieldLabel extends StatelessWidget {
  final String label;

  const AddMenuFieldLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.rubik(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF64748B),
      ),
    );
  }
}

class AddMenuTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const AddMenuTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth * 0.9,
      height: screenHeight * 0.065,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.rubik(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F1F1F),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.rubik(
            fontSize: 13,
            color: const Color(0xFF94A3B8),
          ),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
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

class AddMenuTextAreaField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const AddMenuTextAreaField({
    super.key,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth * 0.9,
      height: screenHeight * 0.11,
      child: TextFormField(
        controller: controller,
        maxLines: null,
        expands: true,
        style: GoogleFonts.rubik(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF1F1F1F),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.rubik(
            fontSize: 12,
            color: const Color(0xFF94A3B8),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
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

class AddMenuDropdownField extends StatelessWidget {
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? value;
  final String? hint;
  final double height;
  final bool fullWidth;

  const AddMenuDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.height = 52,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = fullWidth ? MediaQuery.of(context).size.width * 0.9 : null;
    return SizedBox(
      width: width,
      height: height,
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        isExpanded: true,
        hint: hint != null
            ? Text(
                hint!,
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                ),
              )
            : null,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF94A3B8),
          size: 20,
        ),
        style: GoogleFonts.rubik(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F1F1F),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(16, 13, 8, 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFF5216), width: 1),
          ),
        ),
        items: items
            .map((e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
      ),
    );
  }
}

