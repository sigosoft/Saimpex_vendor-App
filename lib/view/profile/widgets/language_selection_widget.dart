import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/view/login/widgets/bold_text-rubik.dart';

class LanguageSelectionWidget extends StatelessWidget {
  const LanguageSelectionWidget({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    this.backgroundColor = lightOrange,
    this.selectedColor = colorPrimary,
  });

  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;
  final Color backgroundColor;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: _LanguageOption(
                text: 'English',
                isSelected: selectedLanguage == 'English',
                onTap: () => onLanguageChanged('English'),
                selectedColor: selectedColor,
              ),
            ),
            Expanded(
              child: _LanguageOption(
                text: 'French',
                isSelected: selectedLanguage == 'French',
                onTap: () => onLanguageChanged('French'),
                selectedColor: selectedColor,
              ),
            ),
            Expanded(
              child: _LanguageOption(
                text: 'Arabic',
                isSelected: selectedLanguage == 'Arabic',
                onTap: () => onLanguageChanged('Arabic'),
                selectedColor: selectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.text,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: BoldTextRubik(
            text: LocalizationService.nativeName(text),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
