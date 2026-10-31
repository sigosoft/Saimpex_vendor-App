import 'package:flutter/material.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';

/// Loading / empty / error block used inside the Water list screens.
class WaterStateView extends StatelessWidget {
  const WaterStateView.loading({super.key})
      : loading = true,
        title = null,
        message = null,
        icon = null,
        onRetry = null;

  const WaterStateView.empty({
    super.key,
    required String this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
  })  : loading = false,
        onRetry = null;

  const WaterStateView.error({
    super.key,
    required String this.message,
    required VoidCallback this.onRetry,
  })  : loading = false,
        title = null,
        icon = Icons.cloud_off_rounded;

  final bool loading;
  final String? title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textMuted),
          if (title != null) ...[
            const SizedBox(height: 12),
            Text(
              title!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w400,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryOrange,
                side: const BorderSide(color: AppColors.primaryOrange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(S.of(context).tryAgain),
            ),
          ],
        ],
      ),
    );
  }
}
