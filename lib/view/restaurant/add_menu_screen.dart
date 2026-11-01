import 'package:saimpex_vendor/resources/fonts.dart';
import 'dart:io';
import 'package:flutter/material.dart' hide MenuController;
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/controller/menucontroller.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/add_menu_widgets.dart';

class AddMenuScreen extends StatefulWidget {
  const AddMenuScreen({super.key});

  @override
  State<AddMenuScreen> createState() => _AddMenuScreenState();
}

class _AddMenuScreenState extends State<AddMenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.isRegistered<MenuController>()
          ? Get.find<MenuController>()
          : Get.put(MenuController());
      if (controller.restaurantCategories.isEmpty &&
          !controller.isRestaurantCategoriesLoading) {
        controller.getAllCategories();
      }
      if (controller.restaurantTags.isEmpty &&
          !controller.isRestaurantTagsLoading) {
        controller.getAllTags();
      }
      if (controller.menuAttributes.isEmpty &&
          !controller.isMenuAttributesLoading) {
        controller.getAllAttributes();
      }
    });
  }

  void _openCategoryMultiSelect(
    BuildContext context,
    MenuController controller,
  ) {
    if (controller.restaurantCategories.isEmpty &&
        !controller.isRestaurantCategoriesLoading) {
      controller.getAllCategories();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return GetBuilder<MenuController>(
          builder: (ctrl) {
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
                            S.of(context).categoryLabel,
                            style: appFont('Rubik', 
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F1F1F),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ctrl.selectedCategoryIds.clear();
                            ctrl.update();
                          },
                          child: Text(
                            S.of(context).resetButton,
                            style: appFont('Rubik', 
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFFF5216),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (ctrl.isRestaurantCategoriesLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36.0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Color(0xFFFF5216),
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Loading categories...",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (ctrl.restaurantCategories.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28.0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.category_outlined,
                                size: 36,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "No categories available",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => ctrl.getAllCategories(),
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Retry",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5216),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight:
                              MediaQuery.of(sheetContext).size.height * 0.5,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: ctrl.restaurantCategories.length,
                          itemBuilder: (_, index) {
                            final c = ctrl.restaurantCategories[index];
                            final id = (c.id != null && c.id != 0)
                                ? c.id.toString()
                                : (c.id?.toString() ?? '');
                            final name = c.displayName;
                            final checked = id.isNotEmpty &&
                                ctrl.selectedCategoryIds.contains(id);
                            return CheckboxListTile(
                              value: checked,
                              onChanged: id.isEmpty
                                  ? null
                                  : (_) {
                                      ctrl.toggleCategoryById(id);
                                    },
                              title: Text(
                                name.isNotEmpty ? name : 'Category ${index + 1}',
                                style: appFont('Rubik', 
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F1F1F),
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
                        onPressed: () {
                          ctrl.update();
                          Navigator.of(sheetContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5216),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          S.of(context).submitButton,
                          style: appFont('Rubik', 
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

  void _openTagMultiSelect(BuildContext context, MenuController controller) {
    if (controller.restaurantTags.isEmpty &&
        !controller.isRestaurantTagsLoading) {
      controller.getAllTags();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return GetBuilder<MenuController>(
          builder: (ctrl) {
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
                            S.of(context).tagsLabel,
                            style: appFont('Rubik', 
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F1F1F),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ctrl.selectedTagIds.clear();
                            ctrl.update();
                          },
                          child: Text(
                            S.of(context).resetButton,
                            style: appFont('Rubik', 
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFFF5216),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (ctrl.isRestaurantTagsLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36.0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Color(0xFFFF5216),
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Loading tags...",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (ctrl.restaurantTags.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28.0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.tag,
                                size: 36,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "No tags available",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => ctrl.getAllTags(),
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Retry",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5216),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight:
                              MediaQuery.of(sheetContext).size.height * 0.5,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: ctrl.restaurantTags.length,
                          itemBuilder: (_, index) {
                            final t = ctrl.restaurantTags[index];
                            final id = (t.id != null && t.id != 0)
                                ? t.id.toString()
                                : (t.id?.toString() ?? '');
                            final name = t.displayName;
                            final checked = id.isNotEmpty &&
                                ctrl.selectedTagIds.contains(id);
                            return CheckboxListTile(
                              value: checked,
                              onChanged: id.isEmpty
                                  ? null
                                  : (_) {
                                      ctrl.toggleTagById(id);
                                    },
                              title: Text(
                                name.isNotEmpty ? name : 'Tag ${index + 1}',
                                style: appFont('Rubik', 
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1F1F1F),
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
                        onPressed: () {
                          ctrl.update();
                          Navigator.of(sheetContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5216),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          S.of(context).submitButton,
                          style: appFont('Rubik', 
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
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
          S.of(context).addMenuTitle,
          style: appFont('Rubik', 
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        centerTitle: false,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: GetBuilder<MenuController>(
          init: MenuController(),
          builder: (controller) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddMenuFieldLabel(S.of(context).itemNameEnglishLabel),
              SizedBox(height: screenHeight * 0.007),
              AddMenuTextField(
                controller: controller.nameEnCtrl,
                hint: S.of(context).enterItemNameHint,
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AddMenuFieldLabel(S.of(context).categoryLabel),
                        SizedBox(height: screenHeight * 0.007),
                        AddMenuMultiSelectField(
                          displayText:
                              controller.selectedCategoryDisplayText,
                          hint: controller.isRestaurantCategoriesLoading
                              ? 'Loading categories...'
                              : S.of(context).selectCategoryHint,
                          onTap: () => _openCategoryMultiSelect(
                            context,
                            controller,
                          ),
                          height: screenHeight * 0.055,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (Get.find<ProfileController>().vendorType != '2')
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AddMenuFieldLabel(S.of(context).isVegLabel),
                          SizedBox(height: screenHeight * 0.007),
                          AddMenuDropdownField(
                            value: controller.selectedIsVeg == null
                                ? null
                                : (controller.selectedIsVeg == 'Yes'
                                      ? S.of(context).yesLabel
                                      : S.of(context).noLabel),
                            hint: 'Select',
                            items: [
                              S.of(context).yesLabel,
                              S.of(context).noLabel,
                            ],
                            onChanged: (v) {
                              controller.selectedIsVeg =
                                  (v == S.of(context).yesLabel) ? 'Yes' : 'No';
                              controller.update();
                            },
                            height: screenHeight * 0.055,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              AddMenuFieldLabel(S.of(context).descriptionEnglishLabel),
              SizedBox(height: screenHeight * 0.007),
              AddMenuTextAreaField(
                controller: controller.descEnCtrl,
                hint: S.of(context).enterDescriptionHint,
              ),
              SizedBox(height: screenHeight * 0.02),
              AddMenuFieldLabel(S.of(context).tagsLabel),
              SizedBox(height: screenHeight * 0.007),
              AddMenuMultiSelectField(
                displayText: controller.selectedTagDisplayText,
                hint: controller.isRestaurantTagsLoading
                    ? 'Loading tags...'
                    : S.of(context).selectTagHint,
                onTap: () => _openTagMultiSelect(context, controller),
                height: screenHeight * 0.055,
                fullWidth: true,
              ),
              SizedBox(height: screenHeight * 0.02),
              AddMenuFieldLabel(S.of(context).attributeLabel),
              SizedBox(height: screenHeight * 0.007),
              controller.isMenuAttributesLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFF5216),
                          ),
                        ),
                      ),
                    )
                  : AddMenuDropdownField(
                      value: controller.selectedAttributeDisplayName,
                      hint: S.of(context).selectAttributeHint,
                      items: controller.attributeDisplayNames,
                      onChanged: (v) {
                        controller.setSelectedAttributeByName(v);
                        controller.update();
                      },
                      height: screenHeight * 0.055,
                      fullWidth: true,
                    ),
              SizedBox(height: screenHeight * 0.02),
              if (Get.find<ProfileController>().vendorType != '2') ...[
                AddMenuFieldLabel(S.of(context).preparationTimeMinutesLabel),
                SizedBox(height: screenHeight * 0.007),
                AddMenuTextField(
                  controller: controller.prepTimeCtrl,
                  hint: S.of(context).enterMinutesHint,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
              AddMenuFieldLabel(S.of(context).serialNoLabel),
              SizedBox(height: screenHeight * 0.007),
              AddMenuTextField(
                controller: controller.serialNumberCtrl,
                hint: S.of(context).enterSerialNumberHint,
              ),
              SizedBox(height: screenHeight * 0.02),
              AddMenuFieldLabel(S.of(context).maxAllowedQuantityLabel),
              SizedBox(height: screenHeight * 0.007),
              AddMenuTextField(
                controller: controller.quantityAllowedCtrl,
                hint: S.of(context).enterMaxQuantityHint,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AddMenuFieldLabel(S.of(context).priceLabel),
                        SizedBox(height: screenHeight * 0.007),
                        AddMenuTextField(
                          controller: controller.priceCtrl,
                          hint: S.of(context).enterPriceHint,
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
                        AddMenuFieldLabel(S.of(context).discountPriceLabel),
                        SizedBox(height: screenHeight * 0.007),
                        AddMenuTextField(
                          controller: controller.discountPriceCtrl,
                          hint: S.of(context).enterDiscountPriceHint,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              AddMenuFieldLabel(S.of(context).itemImageLabel),
              SizedBox(height: screenHeight * 0.007),
              GestureDetector(
                onTap: () => controller.showImageAlertDialog(context),
                child: Container(
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.15,
                  padding: EdgeInsets.all(screenHeight * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5E5E5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.upload_outlined,
                        color: Color(0xFF94A3B8),
                        size: 22,
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        S.of(context).uploadImageHint,
                        style: appFont('Rubik', 
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              if (controller.uploadedImages.isNotEmpty)
                SizedBox(
                  height: screenHeight * 0.08,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.uploadedImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(controller.uploadedImages[index].path),
                              width: screenHeight * 0.08,
                              height: screenHeight * 0.08,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: screenHeight * 0.08,
                                height: screenHeight * 0.08,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.image,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: GestureDetector(
                              onTap: () => controller.removeImageAt(index),
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF5216),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

              SizedBox(height: screenHeight * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.05,
                    child: OutlinedButton(
                      onPressed: controller.resetForm,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFE5E5E5),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        S.of(context).resetButton,
                        style: appFont('Rubik', 
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F1F1F),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  SizedBox(
                    width: screenWidth * 0.48,
                    height: screenHeight * 0.05,
                    child: ElevatedButton(
                      onPressed: () {
                        final error = controller.addMenuValidation();
                        if (error != null) {
                          showToast(context, error);
                          return;
                        }
                        controller.addMenu(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5216),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        S.of(context).submitButton,
                        style: appFont('Rubik', 
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
