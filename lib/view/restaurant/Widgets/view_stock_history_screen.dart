import 'package:saimpex_vendor/resources/fonts.dart';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/controller/item_controller.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/restaurant_menu_item_stock_logs_model.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/stock_history_filter_chips.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/stock_history_transaction_card.dart';

/// Stock change log for a menu item (layout matches vendor stock history design).
class ViewStockHistoryScreen extends StatefulWidget {
  const ViewStockHistoryScreen({
    super.key,
    required this.itemName,
    required this.editItemId,
    this.imageUrl,
  });

  final String itemName;
  final String editItemId;
  final String? imageUrl;

  @override
  State<ViewStockHistoryScreen> createState() => _ViewStockHistoryScreenState();
}

class _StockHistoryEntry {
  _StockHistoryEntry({
    required this.stockId,
    required this.dateTime,
    required this.byUser,
    required this.isAdded,
    required this.quantityDelta,
    required this.remaining,
  });

  final String stockId;
  final DateTime? dateTime;
  final String byUser;
  final bool isAdded;
  final int quantityDelta;
  final int remaining;
}

class _ViewStockHistoryScreenState extends State<ViewStockHistoryScreen> {
  StockHistoryFilterKind _filter = StockHistoryFilterKind.all;

  String _resolveImageUrl() {
    final raw = widget.imageUrl?.trim() ?? '';
    if (raw.isEmpty) return '';
    if (raw.startsWith('http')) return raw;
    return '${ApiConfigs.IMAGE_URL}$raw';
  }

  List<_StockHistoryEntry> _buildEntries(List<StockLogItem> logs) {
    return logs.map((log) {
      final movementType = log.movementType ?? 0;
      final isAdded = movementType == 1;
      final quantity = (log.quantity ?? 0).abs();
      final parsedDate = log.createdAt != null
          ? DateTime.tryParse(log.createdAt!)?.toLocal()
          : null;
      return _StockHistoryEntry(
        stockId: (log.id ?? '').toString(),
        dateTime: parsedDate,
        byUser: (log.addedByName ?? '').trim(),
        isAdded: isAdded,
        quantityDelta: isAdded ? quantity : -quantity,
        remaining: log.currentStock ?? 0,
      );
    }).toList();
  }

  List<_StockHistoryEntry> _applyFilter(List<_StockHistoryEntry> entries) {
    switch (_filter) {
      case StockHistoryFilterKind.all:
        return entries;
      case StockHistoryFilterKind.added:
        return entries.where((e) => e.isAdded).toList();
      case StockHistoryFilterKind.removed:
        return entries.where((e) => !e.isAdded).toList();
    }
  }

  Future<void> _showUpdateStockDialog(BuildContext context) async {
    final qtyController = TextEditingController();
    String stockAction = 'Add';

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 280),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Update Stock',
                            style: appFont('Rubik', 
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(dialogContext).pop(),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFD1D5DB),
                              ),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Type',
                      style: appFont('Rubik', 
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: stockAction,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF6B7280),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Add',
                              child: Text('Add'),
                            ),
                            DropdownMenuItem(
                              value: 'Remove',
                              child: Text('Remove'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              stockAction = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Item Quantity',
                      style: appFont('Rubik', 
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: '',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF5216),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFFF5216),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: appFont('Rubik', 
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFF5216),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              onPressed: () async {
                                final qty = int.tryParse(
                                  qtyController.text.trim(),
                                );
                                if (qty == null || qty <= 0) {
                                  showToast(
                                    context,
                                    'Please enter valid quantity',
                                  );
                                  return;
                                }
                                final itemController =
                                    Get.isRegistered<ItemController>()
                                        ? Get.find<ItemController>()
                                        : Get.put(
                                            ItemController(),
                                            permanent: false,
                                          );
                                final movementType =
                                    stockAction == 'Add' ? '1' : '2';
                                await itemController.updateMenuItemStock(
                                  context,
                                  widget.editItemId,
                                  qty,
                                  movementType,
                                );
                                await itemController.getMenuItemStockLogs(
                                  widget.editItemId,
                                  1,
                                  10,
                                );
                                if (Get.isRegistered<ProfileController>()) {
                                  final profileController =
                                      Get.find<ProfileController>();
                                  await profileController.fetchRestaurantMenus(
                                    keyword: '',
                                  );
                                  await profileController.fetchGroceryMenuItems();
                                }

                                if (dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5216),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Update',
                                style: appFont('Rubik', 
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = FlutterLocalization.instance;
    final lang = localization.currentLocale?.languageCode ?? 'en';
    final imageUrl = _resolveImageUrl();

    return Directionality(
      textDirection: lang == 'ar' ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: CommonBackground(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF1F2937),
              size: 18,
            ),
          ),
          title: Text(
            'Stock History',
            style: appFont('Rubik', 
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          centerTitle: false,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _showUpdateStockDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5216),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Update Stock',
                    style: appFont('Rubik', 
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GetBuilder<ItemController>(
            init: ItemController(),
            didChangeDependencies: (state) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                state.controller?.getMenuItemStockLogs(
                  widget.editItemId,
                  1,
                  10,
                );
              });
            },
            builder: (controller) {
              String displayName = widget.itemName.trim();
              if (displayName.isEmpty || displayName.toLowerCase() == 'item') {
                final product = controller.menuItemStockLogModel?.data?.product;
                if (product != null) {
                  if (lang == 'ar' && (product.nameAr?.trim().isNotEmpty ?? false)) {
                    displayName = product.nameAr!.trim();
                  } else if (lang == 'fr' && (product.nameFr?.trim().isNotEmpty ?? false)) {
                    displayName = product.nameFr!.trim();
                  } else if (product.nameEn?.trim().isNotEmpty ?? false) {
                    displayName = product.nameEn!.trim();
                  }
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (displayName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      displayName,
                      style: appFont('Rubik', 
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: double.infinity,
                            height: 190,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Image.asset(
                              'lib/assets/images/Burger.jpg',
                              width: double.infinity,
                              height: 190,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'lib/assets/images/Burger.jpg',
                            width: double.infinity,
                            height: 190,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(height: 16),
                  StockHistoryFilterBar(
                    selected: _filter,
                    onChanged: (v) => setState(() => _filter = v),
                  ),
                  const SizedBox(height: 16),
                  if (controller.isStockLogsLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF5216),
                        ),
                      ),
                    )
                  else ...() {
                    final entries = _buildEntries(controller.menuItemStockLogs);
                    final visibleEntries = _applyFilter(entries);
                    if (visibleEntries.isEmpty) {
                      return [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              'No stock history found',
                              style: appFont('Rubik', 
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ];
                    }
                    return visibleEntries
                        .map(
                          (e) => StockHistoryTransactionCard(
                            stockId: e.stockId,
                            dateTime: e.dateTime,
                            byUser: e.byUser,
                            isStockAdded: e.isAdded,
                            quantityDelta: e.quantityDelta,
                            remaining: e.remaining,
                          ),
                        )
                        .toList();
                  }(),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
