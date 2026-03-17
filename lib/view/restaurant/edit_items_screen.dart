import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/controller/item_controller.dart';
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
          'Edit Item',
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
              EditItemsFieldLabel('Item Type'),
              const SizedBox(height: 8),
              EditItemsDropdownField(
                value: controller.selectedType != null &&
                        controller.typeDisplayNames.contains(controller.selectedType)
                    ? controller.selectedType
                    : null,
                hint: controller.isMenuListLoading
                    ? 'Loading...'
                    : S.of(context).selectTypeHint,
                items: controller.typeDisplayNames,
                onChanged: controller.isMenuListLoading
                    ? (_) {}
                    : controller.setSelectedType,
                fullWidth: true,
              ),
              const SizedBox(height: 20),

              EditItemsFieldLabel('Preparation Time (minutes)'),
              const SizedBox(height: 8),
              EditItemsTextField(
                controller: controller.prepTimeCtrl,
                hint: 'Enter minutes',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              EditItemsFieldLabel('Tags'),
              const SizedBox(height: 8),
              EditItemsDropdownField(
                value: controller.selectedTag != null &&
                        controller.tagDisplayNames.contains(controller.selectedTag)
                    ? controller.selectedTag
                    : null,
                hint: controller.isRestaurantTagsLoading
                    ? 'Loading...'
                    : S.of(context).selectTagHint,
                items: controller.tagDisplayNames,
                onChanged: controller.isRestaurantTagsLoading
                    ? (_) {}
                    : controller.setSelectedTag,
                fullWidth: true,
              ),
              const SizedBox(height: 20),

              EditItemsFieldLabel('Attribute'),
              const SizedBox(height: 8),
              EditItemsDropdownField(
                value: controller.selectedAttribute != null &&
                        controller.attributeDisplayNames
                            .contains(controller.selectedAttribute)
                    ? controller.selectedAttribute
                    : null,
                hint: controller.isRestaurantAttributesLoading
                    ? 'Loading...'
                    : S.of(context).selectAttributeHint,
                items: controller.attributeDisplayNames,
                onChanged: controller.isRestaurantAttributesLoading
                    ? (_) {}
                    : controller.setSelectedAttribute,
                fullWidth: true,
              ),
              const SizedBox(height: 20),

              EditItemsFieldLabel('Serial Number'),
              const SizedBox(height: 8),
              EditItemsTextField(
                controller: controller.serialNumberCtrl,
                hint: 'Enter serial number',
              ),
              const SizedBox(height: 20),

              EditItemsFieldLabel('Maximum Allowed Quantity'),
              const SizedBox(height: 8),
              EditItemsTextField(
                controller: controller.maxQuantityCtrl,
                hint: 'Enter maximum allowed quantity',
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EditItemsFieldLabel('Price'),
                        const SizedBox(height: 8),
                        EditItemsTextField(
                          controller: controller.priceCtrl,
                          hint: 'Enter Price',
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
                        EditItemsFieldLabel('Discount Price'),
                        const SizedBox(height: 8),
                        EditItemsTextField(
                          controller: controller.discountPriceCtrl,
                          hint: 'Enter Discount Price',
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
                    'Reset',
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
                  onPressed: () => Get.find<ItemController>().updateItem(
                    context,
                    restaurantMenuItemId: widget.itemId,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5216),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Submit',
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
