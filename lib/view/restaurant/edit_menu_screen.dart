import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/controller/menucontroller.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/edit_menu_screen_widgets.dart';

import '../../generated/l10n.dart';

class EditMenuScreen extends StatefulWidget {
  final String itemId;

  const EditMenuScreen({super.key, required this.itemId});

  @override
  State<EditMenuScreen> createState() => _EditMenuScreenState();
}

class _EditMenuScreenState extends State<EditMenuScreen> {
  late final MenuController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<MenuController>()
        ? Get.find<MenuController>()
        : Get.put(MenuController(), permanent: false);
    _controller.loadEditMenu(widget.itemId);
  }

  @override
  void dispose() {
    Get.delete<MenuController>(force: true);
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
          S.of(context).editMenu,
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        centerTitle: false,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: GetBuilder<MenuController>(
          init: _controller,
          builder: (c) {
            final menu = c.restaurantMenuDetails?.restaurantMenu;
            if (c.isRestaurantMenuDetailsLoading && menu == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: Color(0xFFFF5216)),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditMenuFieldLabel(S.of(context).itemNameEnglish),
                const SizedBox(height: 6),
                EditMenuTextField(
                  controller: c.nameEnCtrl,
                  hint: S.of(context).zestyChickenBurger,
                ),
                const SizedBox(height: 16),
                EditMenuFieldLabel(S.of(context).itemNameArabic),
                const SizedBox(height: 6),
                EditMenuTextField(
                  controller: c.nameArCtrl,
                  hint: 'برجر دجاج حار ولذيذ',
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                EditMenuFieldLabel(S.of(context).itemNameFrench),
                const SizedBox(height: 6),
                EditMenuTextField(
                  controller: c.nameFrCtrl,
                  hint: 'Burger au poulet épicé',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EditMenuFieldLabel(S.of(context).category),
                          const SizedBox(height: 6),
                          EditMenuDropdownField(
                            value: c.categoryDisplayNames.isEmpty
                                ? S.of(context).loading
                                : c.selectedEditCategoryDisplayName,
                            items: c.categoryDisplayNames.isEmpty
                                ? [S.of(context).loading]
                                : c.categoryDisplayNames,
                            onChanged: c.categoryDisplayNames.isEmpty
                                ? (_) {}
                                : c.setSelectedEditCategoryByName,
                            height: 46,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EditMenuFieldLabel(S.of(context).isVeg),
                          const SizedBox(height: 6),
                          EditMenuDropdownField(
                            value: c.selectedIsVeg,
                            items: MenuController.vegOptions,
                            onChanged: c.setSelectedIsVeg,
                            height: 46,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                EditMenuFieldLabel(S.of(context).descriptionEnglish),
                const SizedBox(height: 6),
                EditMenuTextAreaField(
                  controller: c.descEnCtrl,
                  hint: S.of(context).enterDescriptionInEnglish,
                ),
                const SizedBox(height: 16),
                EditMenuFieldLabel(S.of(context).descriptionArabic),
                const SizedBox(height: 6),
                EditMenuTextAreaField(
                  controller: c.descArCtrl,
                  hint: 'أدخل الوصف بالعربية...',
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                EditMenuFieldLabel(S.of(context).descriptionFrench),
                const SizedBox(height: 6),
                EditMenuTextAreaField(
                  controller: c.descFrCtrl,
                  hint: 'Entrez la description en français...',
                ),
                const SizedBox(height: 16),
                EditMenuFieldLabel(S.of(context).tags),
                const SizedBox(height: 6),
                EditMenuDropdownField(
                  value: c.tagDisplayNames.isEmpty
                      ? S.of(context).loading
                      : c.selectedEditTagDisplayName,
                  items: c.tagDisplayNames.isEmpty
                      ? [S.of(context).loading]
                      : c.tagDisplayNames,
                  onChanged: c.tagDisplayNames.isEmpty
                      ? (_) {}
                      : c.setSelectedEditTagByName,
                  height: 46,
                  width: MediaQuery.of(context).size.width * 0.9,
                ),
                const SizedBox(height: 16),
                EditMenuFieldLabel(S.of(context).preparationTimeMinutes),
                const SizedBox(height: 6),
                EditMenuTextField(
                  controller: c.prepTimeCtrl,
                  hint: '20 Min',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                EditMenuFieldLabel(S.of(context).maximumAllowedQuantity),
                const SizedBox(height: 6),
                EditMenuTextField(
                  controller: c.quantityAllowedCtrl,
                  hint: '10',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EditMenuFieldLabel(S.of(context).price),
                          const SizedBox(height: 6),
                          EditMenuTextField(
                            controller: c.priceCtrl,
                            hint: '20 MRU',
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
                          EditMenuFieldLabel(S.of(context).discountPrice),
                          const SizedBox(height: 6),
                          EditMenuTextField(
                            controller: c.discountPriceCtrl,
                            hint: '10 MRU',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                EditMenuFieldLabel(S.of(context).itemImage),
                const SizedBox(height: 6),
                EditMenuImageUploadArea(onTap: c.pickImages),
                const SizedBox(height: 12),
                EditMenuImageThumbnails(
                  networkImageUrls: c.existingMenuImageUrls,
                  localImages: c.uploadedImages,
                  onRemove: c.removeEditImageAt,
                ),
                const SizedBox(height: 24),
                EditMenuActionsRow(
                  onReset: c.resetEditForm,
                  onSubmit: () {
                    c.updateEditedMenu(context);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}
