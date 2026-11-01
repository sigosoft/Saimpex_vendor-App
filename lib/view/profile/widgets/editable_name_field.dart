import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/view/login/widgets/bold_text-rubik.dart';

import '../../../generated/l10n.dart';

class EditableNameField extends StatefulWidget {
  const EditableNameField({
    super.key,
    required this.media,
    required this.controller,
    this.onEditChanged,
  });

  final MediaQueryData media;
  final TextEditingController controller;
  final ValueChanged<bool>? onEditChanged;

  @override
  State<EditableNameField> createState() => _EditableNameFieldState();
}

class _EditableNameFieldState extends State<EditableNameField> {
  bool isEditable = false;
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
          text: S.of(context).name,
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
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  readOnly: !isEditable,
                  style: appFont('Rubik', 
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isEditable ? Colors.black : Colors.grey,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: isEditable,
                child: Opacity(
                  opacity: isEditable ? 0.5 : 1.0,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        isEditable = !isEditable;
                      });
                      widget.onEditChanged?.call(isEditable);
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
