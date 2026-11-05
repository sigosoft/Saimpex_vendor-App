import 'package:flutter/material.dart';

/// Shown when an item has no image (or it fails to load). A burger photo
/// was used for this, so grocery items without a photo showed a burger.
Widget noImageBox({double? width, double? height, BoxFit? fit}) => Container(
      width: width,
      height: height,
      color: const Color(0xFFF2F2F2),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFFB0B0B0)),
    );
