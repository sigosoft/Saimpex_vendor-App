import 'package:flutter/material.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/fonts.dart';

/// The rows a bulk import rejected (`data.errors` of
/// `importRestaurantCatalogItems`, e.g. "Row 4: price must be a number").
/// Nothing was imported; the vendor fixes the file and uploads it again.
Future<void> showImportErrorsDialog(BuildContext context, List<String> errors) {
  return showDialog<void>(
    context: context,
    builder: (c) {
      final s = S.of(c);
      return AlertDialog(
        title: Text(s.importFailedTitle, style: appFont('Rubik', fontSize: 17, fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.importFailedBody, style: appFont('Rubik', fontSize: 13, color: const Color(0xFF6B7280))),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: errors.length,
                separatorBuilder: (_, _) => const Divider(height: 12),
                itemBuilder: (_, i) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.error_outline, size: 16, color: Color(0xFFE11D48)),
                  ),
                  const SizedBox(width: 8),
                  // Server text (English); row numbers match the file.
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(errors[i], style: appFont('Rubik', fontSize: 13)),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(s.done))],
      );
    },
  );
}
