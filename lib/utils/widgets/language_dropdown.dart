import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

import '../../resources/colors.dart';

class LanguageDropdown extends StatefulWidget {
  final List<String> languages;
  final String? initial;
  final ValueChanged<String?>? onChanged;

  const LanguageDropdown({
    super.key,
    this.languages = const ['English', 'French', 'Arabic'],
    this.initial,
    this.onChanged,
  });

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial ?? (widget.languages.isNotEmpty ? widget.languages[0] : null);
  }
  final FlutterLocalization localization = FlutterLocalization.instance;
  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection:
      localization.currentLocale!.languageCode.toString() == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: lightOrange,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            // optional subtle shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // optional language icon / flag
            // const Padding(
            //   padding: EdgeInsets.only(right: 8.0),
            //   child: Icon(Icons.language, color: Colors.black54),
            // ),

            // Expanded area for dropdown button
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selected,
                  icon: const Icon( // black arrow on the right
                    Icons.keyboard_arrow_down,
                    color: Colors.black,
                  ),
                  dropdownColor: Colors.white,
                  elevation: 4,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  onChanged: (value) {
                    setState(() => _selected = value);
                    if (widget.onChanged != null) widget.onChanged!(value);
                  },
                  items: widget.languages.map((lang) {
                    return DropdownMenuItem<String>(
                      value: lang,
                      child: Text(lang, overflow: TextOverflow.ellipsis, style: appFont('Rubik', 
                        textStyle: Theme.of(context).textTheme.labelMedium,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                      )),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
