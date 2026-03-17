import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/controller/menucontroller.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/edit_menu_screen_widgets.dart';

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
          'Edit Menu',
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
                EditMenuFieldLabel('Item Name (English)'),
                const SizedBox(height: 6),
                EditMenuTextField(
                  controller: c.nameEnCtrl,
                  hint: 'Zesty Chicken Burger',
                ),
                const SizedBox(height: 16),
                EditMenuFieldLabel('Item Name (Arabic)'),
                const SizedBox(height: 6),
                EditMenuTextField(
                  controller: c.nameArCtrl,
                  hint: 'برجر دجاج حار ولذيذ',
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                EditMenuFieldLabel('Item Name (French)'),
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
                          EditMenuFieldLabel('Category'),
                          const SizedBox(height: 6),
                          EditMenuDropdownField(
                            value: c.categoryDisplayNames.isEmpty
                                ? 'Loading...'
                                : c.selectedEditCategoryDisplayName,
                            items: c.categoryDisplayNames.isEmpty
                                ? ['Loading...']
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
                          EditMenuFieldLabel('Is Veg'),
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
                EditMenuFieldLabel('Description (English)'),
                const SizedBox(height: 6),
                EditMenuTextAreaField(
                  controller: c.descEnCtrl,
                  hint: 'Enter description in English...',
                ),
                const SizedBox(height: 16),
                EditMenuFieldLabel('Description (Arabic)'),
                const SizedBox(height: 6),
                EditMenuTextAreaField(
                  controller: c.descArCtrl,
                  hint: 'أدخل الوصف بالعربية...',
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                EditMenuFieldLabel('Description (French)'),
                const SizedBox(height: 6),
                EditMenuTextAreaField(
                  controller: c.descFrCtrl,
                  hint: 'Entrez la description en français...',
                ),
                const SizedBox(height: 16),
                EditMenuFieldLabel('Tags'),
                const SizedBox(height: 6),
                EditMenuDropdownField(
                  value: c.tagDisplayNames.isEmpty
                      ? 'Loading...'
                      : c.selectedEditTagDisplayName,
                  items: c.tagDisplayNames.isEmpty
                      ? ['Loading...']
                      : c.tagDisplayNames,
                  onChanged: c.tagDisplayNames.isEmpty
                      ? (_) {}
                      : c.setSelectedEditTagByName,
                  height: 46,
                  width: MediaQuery.of(context).size.width * 0.9,
                ),
                const SizedBox(height: 16),
                EditMenuFieldLabel('Preparation Time (minutes)'),
                const SizedBox(height: 6),
                EditMenuTextField(
                  controller: c.prepTimeCtrl,
                  hint: '20 Min',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EditMenuFieldLabel('Price'),
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
                          EditMenuFieldLabel('Discount Price'),
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
                EditMenuFieldLabel('Item Image'),
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
