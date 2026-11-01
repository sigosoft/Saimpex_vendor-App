import 'package:flutter/material.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/widgets/custom_button.dart';

import '../../../generated/l10n.dart';

class UpdateProfileButton extends StatelessWidget {
  const UpdateProfileButton({
    super.key,
    required this.media,
    required this.onPressed,
  });

  final MediaQueryData media;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: S.of(context).update,
        onPressed: onPressed,
        backgroundColor: colorPrimary,
        textColor: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        padding: EdgeInsets.symmetric(
          vertical: media.size.height * 0.02,
        ),
        borderRadius: 12,
      ),
    );
  }
}

