import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/view/login/widgets/bold_text-rubik.dart';

import '../../../generated/l10n.dart';

class EditablePhoneField extends StatefulWidget {
  const EditablePhoneField({
    super.key,
    required this.media,
    required this.controller,
    this.countryCode = '+222',
    this.onEditChanged,
    required this.isEditable,
  });

  final MediaQueryData media;
  final TextEditingController controller;
  final String countryCode;
  final ValueChanged<bool>? onEditChanged;
  final bool isEditable;
  @override
  State<EditablePhoneField> createState() => _EditablePhoneFieldState();
}

class _EditablePhoneFieldState extends State<EditablePhoneField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoldTextRubik(
          text: S.of(context).phoneNumber,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        SizedBox(height: widget.media.size.height * 0.01),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: BoldTextRubik(
                  text: widget.countryCode,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: widget.isEditable ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  readOnly: !widget.isEditable,
                  style: appFont('Rubik', 
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: widget.isEditable ? Colors.black : Colors.grey,
                  ),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: widget.isEditable,
                child: Opacity(
                  opacity: widget.isEditable ? 0.5 : 1.0,
                  child: TextButton.icon(
                    onPressed: () {
                      widget.onEditChanged?.call(!widget.isEditable);
                    },
                    icon: Image.asset(
                      'lib/assets/images/penciledit.png',
                      width: 16,
                      height: 16,
                      color: colorPrimary,
                    ),
                    label: BoldTextRubik(
                      text: S.of(context).edit,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: colorPrimary,
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
