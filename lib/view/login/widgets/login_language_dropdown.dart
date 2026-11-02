import 'package:flutter/material.dart';

class LoginLanguageDropdown extends StatelessWidget {
  const LoginLanguageDropdown({
    super.key,
    required this.topPadding,
    required this.currentLanguageCode,
    required this.onLanguageChanged,
  });

  final double topPadding;
  final String currentLanguageCode;
  final ValueChanged<String> onLanguageChanged;

  static const Map<String, String> _languageLabels = {
    'en': 'English',
    'fr': 'Français',
    'ar': 'العربية',
  };

  @override
  Widget build(BuildContext context) {
    final selectedCode = _languageLabels.containsKey(currentLanguageCode)
        ? currentLanguageCode
        : 'en';

    return Positioned(
      top: topPadding + 10,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD8CC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedCode,
            dropdownColor: Colors.white,
            elevation: 4,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            items: _languageLabels.entries
                .map(
                  (entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onLanguageChanged(value);
              }
            },
            icon: const Icon(
              Icons.expand_more,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
