import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/controller/item_controller.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/view/restaurant/edit_items_screen.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/restaurant_menu_item_stock_logs_model.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/stock_history_filter_chips.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/stock_history_transaction_card.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/vendor_orange_full_width_button.dart';

/// Stock change log for a menu item (layout matches vendor stock history design).
class ViewStockHistoryScreen extends StatefulWidget {
  const ViewStockHistoryScreen({
    super.key,
    required this.itemName,
    required this.editItemId,
    this.imageUrl,
    this.actorLabel = 'Restaurant1',
  });

  final String itemName;
  final String editItemId;
  final String? imageUrl;
  final String actorLabel;

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
  final DateTime dateTime;
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
      final parsedDate = DateTime.tryParse(log.createdAt ?? '') ?? DateTime.now();
      return _StockHistoryEntry(
        stockId: (log.id ?? '').toString(),
        dateTime: parsedDate,
        byUser: (log.addedByName ?? '').trim().isNotEmpty
            ? log.addedByName!.trim()
            : widget.actorLabel,
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
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
          ),
          title: Text(
            'Stock History',
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          centerTitle: false,
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: VendorOrangeFullWidthButton(
              label: 'Update Stock',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditItemsScreen(itemId: widget.editItemId),
                  ),
                );
              },
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
            builder: (controller) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    widget.itemName,
                    style: GoogleFonts.rubik(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.22,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              _imagePlaceholder(context),
                        )
                      : _imagePlaceholder(context),
                ),
                const SizedBox(height: 18),
                StockHistoryFilterBar(
                  selected: _filter,
                  onChanged: (v) => setState(() => _filter = v),
                ),
                const SizedBox(height: 18),
                if (controller.isStockLogsLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else ...() {
                  final entries = _buildEntries(controller.menuItemStockLogs);
                  final visibleEntries = _applyFilter(entries);
                  if (visibleEntries.isEmpty) {
                    return [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'No stock history found',
                            style: GoogleFonts.rubik(
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.22,
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.fastfood, size: 56, color: Color(0xFF94A3B8)),
    );
  }
}
