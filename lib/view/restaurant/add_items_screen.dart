import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/controller/item_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/add_items_screen_widgets.dart';

class AddItemsScreen extends StatefulWidget {
  const AddItemsScreen({super.key});

  @override
  State<AddItemsScreen> createState() => _AddItemsScreenState();
}

class _AddItemsScreenState extends State<AddItemsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
          S.of(context).addItemsTitle,
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: false,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: GetBuilder<ItemController>(
          init: ItemController(),
          builder: (controller) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddItemsFieldLabel(S.of(context).itemTypeLabel),
              const SizedBox(height: 8),
              AddItemsDropdownField(
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
              AddItemsFieldLabel(S.of(context).preparationTimeMinutesLabel),
              const SizedBox(height: 8),
              AddItemsTextField(
                controller: controller.prepTimeCtrl,
                hint: S.of(context).enterMinutesHint,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              AddItemsFieldLabel(S.of(context).tagsLabel),
              const SizedBox(height: 8),
              AddItemsDropdownField(
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
              AddItemsFieldLabel(S.of(context).attributeLabel),
              const SizedBox(height: 8),
              AddItemsDropdownField(
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
              AddItemsFieldLabel(S.of(context).serialNoLabel),
              const SizedBox(height: 8),
              AddItemsTextField(
                controller: controller.serialNumberCtrl,
                hint: S.of(context).enterSerialNumberHint,
              ),
              const SizedBox(height: 20),
              AddItemsFieldLabel(S.of(context).maxAllowedQuantityLabel),
              const SizedBox(height: 8),
              AddItemsTextField(
                controller: controller.maxQuantityCtrl,
                hint: S.of(context).enterMaxQuantityHint,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AddItemsFieldLabel(S.of(context).priceLabel),
                        const SizedBox(height: 8),
                        AddItemsTextField(
                          controller: controller.priceCtrl,
                          hint: S.of(context).enterPriceHint,
                          keyboardType: TextInputType.number,
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AddItemsFieldLabel(S.of(context).discountPriceLabel),
                        const SizedBox(height: 8),
                        AddItemsTextField(
                          controller: controller.discountPriceCtrl,
                          hint: S.of(context).enterDiscountPriceHint,
                          keyboardType: TextInputType.number,
                          fullWidth: true,
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
      bottomNavigationBar: AddItemsBottomBar(
        onReset: () => Get.find<ItemController>().reset(),
        onSubmit: () {
          final c = Get.find<ItemController>();
          c.addItem(
            context,
            menuId: c.selectedMenuId?.toString() ?? '',
            menuItemId: c.serialNumberCtrl.text.trim(),
            restaurantAttributeId:
                c.selectedRestaurantAttributeId?.toString() ?? '',
          );
        },
      ),
    );
  }
}
