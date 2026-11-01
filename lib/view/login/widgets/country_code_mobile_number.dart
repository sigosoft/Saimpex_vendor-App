import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/view/login/widgets/bold_text-rubik.dart';

import '../../../generated/l10n.dart';

class CountryCodeMobileNumber extends StatelessWidget {
  final Country selectedCountry;
  final TextEditingController phoneController;
  final ValueChanged<Country> onCountryChanged;

  const CountryCodeMobileNumber({
    super.key,
    required this.selectedCountry,
    required this.phoneController,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showCountryPicker(
              context: context,
              favorite: ['MR', 'US', 'FR'],
              exclude: <String>['IL'],
              countryListTheme: CountryListThemeData(
                flagSize: 25,
                backgroundColor: Colors.white,
                textStyle: appFont('Rubik', 
                  textStyle: Theme.of(context).textTheme.displayLarge,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                ),
                inputDecoration: InputDecoration(
                  labelText: S.of(context).search,
                  hintText: S.of(context).startTypingToSearch,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorPrimary,
                      width: size.width * 0.005,
                    ),
                  ),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              onSelect: onCountryChanged,
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.02,
              vertical: size.height * 0.005,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white,
                width: size.width * 0.005,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCountry.flagEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: size.width * 0.02),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white,
                width: size.width * 0.005,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
            child: Row(
              children: [
                BoldTextRubik(
                  text: '+${selectedCountry.phoneCode}',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: size.height * 0.04,
                  color: Colors.grey[300],
                ),
                SizedBox(width: size.width * 0.02),
                Expanded(
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: selectedCountry.phoneCode == "222" ? 8 : null,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: S.of(context).enterYourWhatsappNumber,
                      hintStyle: appFont('Rubik', 
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        color: grey500Opacity,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: size.height * 0.005,
                      ),
                    ),
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
