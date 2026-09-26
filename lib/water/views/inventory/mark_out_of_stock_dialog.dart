import 'package:flutter/material.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';

Future<bool> showMarkOutOfStockDialog(BuildContext context) {
  return showInventoryStatusDialog(
    context,
    message: 'Are you sure you want to mark this item as out of stock?',
    confirmColor: AppColors.inventoryOutOfStock,
  );
}

Future<bool> showMarkAvailableDialog(BuildContext context) {
  return showInventoryStatusDialog(
    context,
    message: 'Are you sure you want to mark this item as available?',
    confirmColor: AppColors.inventoryAvailable,
  );
}

Future<bool> showInventoryStatusDialog(
  BuildContext context, {
  required String message,
  required Color confirmColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => InventoryStatusDialog(
      message: message,
      confirmColor: confirmColor,
    ),
  );
  return result ?? false;
}

class InventoryStatusDialog extends StatelessWidget {
  const InventoryStatusDialog({
    super.key,
    required this.message,
    required this.confirmColor,
  });

  final String message;
  final Color confirmColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(false),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                    size: 22,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 15.5,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.inventoryOutOfStock,
                        side: const BorderSide(
                          color: AppColors.inventoryOutOfStock,
                          width: 1.3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Kept for existing call sites / clarity.
class MarkOutOfStockDialog extends InventoryStatusDialog {
  const MarkOutOfStockDialog({super.key})
      : super(
          message: 'Are you sure you want to mark this item as out of stock?',
          confirmColor: AppColors.inventoryOutOfStock,
        );
}
