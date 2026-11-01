import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class CustomSearchBox extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Color boxColor;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool showSearchIcon;
  final double? width;
  final double height;

  const CustomSearchBox({
    super.key,
    required this.hintText,
    required this.boxColor,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.showSearchIcon = true,
    this.width,
    this.height = 41,
  });

  @override
  Widget build(BuildContext context) {
    final FlutterLocalization localization = FlutterLocalization.instance;
    return SizedBox(
      width: width ?? 293,
      height: height,
      child: Directionality(
        textDirection: localization.currentLocale?.languageCode == "ar"
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: TextFormField(
          controller: controller,
          cursorColor: Colors.black,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          style: appFont('Rubik', 
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: appFont('Rubik', 
              color: const Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: boxColor,
            isDense: true,
            prefixIcon: showSearchIcon
                ? Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Icon(
                      Icons.search,
                      color: const Color(0xFF94A3B8),
                      size: 20,
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(minHeight: 20),
            contentPadding: const EdgeInsets.only(
              top: 14,
              bottom: 14,
              right: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFFF5216), width: 1),
            ),
          ),
        ),
      ),
    );
  }
}
