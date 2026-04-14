import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/controller/item_controller.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/edit_items_screen_widgets.dart';

class EditItemsScreen extends StatefulWidget {
  final String itemId;

  const EditItemsScreen({super.key, required this.itemId});

  @override
  State<EditItemsScreen> createState() => _EditItemsScreenState();
}

class _EditItemsScreenState extends State<EditItemsScreen> {
  bool _didLoadDetails = false;

  void _openTagsMultiSelect(BuildContext context, ItemController controller) {
    if (controller.restaurantTags.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setModalState) {
            void rebuildSheet() => setModalState(() {});
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 12 + MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            S.of(context).tags,
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.selectedRestaurantTagIds.clear();
                            controller.selectedRestaurantTagId = null;
                            controller.update();
                            rebuildSheet();
                          },
                          child: Text(
                            S.of(context).resetButton,
                            style: GoogleFonts.rubik(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFFF5216),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.restaurantTags.length,
                        itemBuilder: (_, index) {
                          final t = controller.restaurantTags[index];
                          final id = t.id ?? 0;
                          final name = (t.nameEn ?? '').trim();
                          final checked =
                              id > 0 &&
                              controller.selectedRestaurantTagIds.contains(id);
                          return CheckboxListTile(
                            value: checked,
                            onChanged: id <= 0
                                ? null
                                : (_) {
                                    controller.toggleTagById(id);
                                    rebuildSheet();
                                  },
                            title: Text(
                              name.isNotEmpty ? name : '-',
                              style: GoogleFonts.rubik(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            activeColor: const Color(0xFFFF5216),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5216),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          S.of(context).submitButton,
                          style: GoogleFonts.rubik(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
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
          S.of(context).editItem,
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: false,
      ),
      child: GetBuilder<ItemController>(
        init: ItemController(editRestaurantMenuItemId: widget.itemId),
        builder: (controller) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_didLoadDetails &&
                  controller.editRestaurantMenuItemId != null &&
                  controller.editRestaurantMenuItemId!.isNotEmpty)
                () {
                  _didLoadDetails = true;
                  Future.microtask(
                    () =>
                        controller.getRestaurantMenuItemDetails(widget.itemId),
                  );
                  return const SizedBox.shrink();
                }(),
              EditItemsFieldLabel(S.of(context).itemType),
              const SizedBox(height: 8),
              EditItemsDropdownField(
                value:
                    controller.selectedType != null &&
                        controller.typeDisplayNames.contains(
                          controller.selectedType,
                        )
                    ? controller.selectedType
                    : null,
                hint: controller.isMenuListLoading
                    ? S.of(context).loading
                    : S.of(context).selectTypeHint,
                items: controller.typeDisplayNames,
                onChanged: controller.isMenuListLoading
                    ? (_) {}
                    : controller.setSelectedType,
                fullWidth: true,
              ),
              const SizedBox(height: 20),

              if (Get.find<ProfileController>().vendorType != '2') ...[
                EditItemsFieldLabel(S.of(context).preparationTimeMinutes),
                const SizedBox(height: 8),
                EditItemsTextField(
                  controller: controller.prepTimeCtrl,
                  hint: S.of(context).enterMinutes,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
              ],

              EditItemsFieldLabel(S.of(context).tags),
              const SizedBox(height: 8),
              EditItemsMultiSelectField(
                displayText: controller.selectedTagDisplayText,
                hint: controller.isRestaurantTagsLoading
                    ? S.of(context).loading
                    : S.of(context).selectTagHint,
                onTap: controller.isRestaurantTagsLoading
                    ? () {}
                    : () => _openTagsMultiSelect(context, controller),
                fullWidth: true,
              ),
              const SizedBox(height: 20),

              EditItemsFieldLabel(S.of(context).attribute),
              const SizedBox(height: 8),
              EditItemsDropdownField(
                value:
                    controller.selectedAttribute != null &&
                        controller.attributeDisplayNames.contains(
                          controller.selectedAttribute,
                        )
                    ? controller.selectedAttribute
                    : null,
                hint: controller.isRestaurantAttributesLoading
                    ? S.of(context).loading
                    : S.of(context).selectAttributeHint,
                items: controller.attributeDisplayNames,
                onChanged: controller.isRestaurantAttributesLoading
                    ? (_) {}
                    : controller.setSelectedAttribute,
                fullWidth: true,
              ),
              const SizedBox(height: 20),

              EditItemsFieldLabel(S.of(context).serialNumber),
              const SizedBox(height: 8),
              EditItemsTextField(
                controller: controller.serialNumberCtrl,
                hint: S.of(context).enterSerialNumber,
              ),
              const SizedBox(height: 20),

              EditItemsFieldLabel(S.of(context).maximumAllowedQuantity),
              const SizedBox(height: 8),
              EditItemsTextField(
                controller: controller.maxQuantityCtrl,
                hint: S.of(context).enterMaximumAllowedQuantity,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EditItemsFieldLabel(S.of(context).price),
                        const SizedBox(height: 8),
                        EditItemsTextField(
                          controller: controller.priceCtrl,
                          hint: S.of(context).enterPrice,
                          fullWidth: true,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EditItemsFieldLabel(S.of(context).discountPrice),
                        const SizedBox(height: 8),
                        EditItemsTextField(
                          controller: controller.discountPriceCtrl,
                          hint: S.of(context).enterDiscountPrice,
                          fullWidth: true,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.12,
        color: Colors.white.withOpacity(0.01),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Get.find<ItemController>().reset(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    S.of(context).reset,
                    style: GoogleFonts.rubik(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final c = Get.find<ItemController>();
                    c.updateItemAfterEdit(
                      context,
                      menuId: c.selectedMenuId?.toString() ?? '',
                      menuItemId: widget.itemId,
                      restaurantAttributeId:
                          c.selectedRestaurantAttributeId?.toString() ?? '',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5216),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    S.of(context).submit,
                    style: GoogleFonts.rubik(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
