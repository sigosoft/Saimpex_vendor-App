import 'package:flutter/material.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/fonts.dart';

/// Full URL of a payout's payment proof, or null when Admin attached none.
///
/// `earnings/payoutDetail` sends `payment_proof_url` (full URL) and
/// `payment_proof` (storage path); older rows may only have the path.
String? paymentProofUrl(Map<String, dynamic>? payout) {
  if (payout == null) return null;
  String? clean(dynamic v) {
    final s = v?.toString().trim() ?? '';
    return (s.isEmpty || s == 'null') ? null : s;
  }

  final full = clean(payout['payment_proof_url']);
  if (full != null) return full;
  final path = clean(payout['payment_proof']) ??
      clean(payout['proof']) ??
      clean(payout['proof_image']);
  if (path == null) return null;
  if (path.startsWith('http')) return path;
  return '${ApiConfigs.IMAGE_URL}${path.replaceFirst(RegExp(r'^/'), '')}';
}

/// Shows the payment proof image, zoomable.
void showPaymentProofDialog(BuildContext context, String url) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(dialogContext).waterPaymentProof,
                    style: appFont(
                      'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: InteractiveViewer(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                    errorBuilder: (_, _, _) => Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(S.of(dialogContext).waterFailedToLoadImage),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
