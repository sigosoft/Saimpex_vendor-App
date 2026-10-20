import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saimpex_vendor/controller/item_controller.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/add_items_screen_widgets.dart';

class AddItemsScreen extends StatefulWidget {
  final String? initialMenuName;
  const AddItemsScreen({super.key, this.initialMenuName});

  @override
  State<AddItemsScreen> createState() => _AddItemsScreenState();
}

class _VariantItemModel {
  XFile? imageFile;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  String selectionRequirement = 'Optional';
}

class _OptionItemModel {
  _OptionItemModel({
    required this.name,
    required this.price,
    this.imageFile,
  });

  String name;
  String price;
  XFile? imageFile;
}

class _OptionGroupModel {
  final TextEditingController groupNameCtrl = TextEditingController();
  final TextEditingController minSelectionsCtrl = TextEditingController();
  final TextEditingController maxSelectionsCtrl = TextEditingController();
  String selectionRequirement = 'Optional';
  final List<_OptionItemModel> options = [];
}

class _AddItemsScreenState extends State<AddItemsScreen> {
  final TextEditingController itemNameCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();
  String isVeg = 'No';

  bool isVariantsEnabled = false;
  final TextEditingController variantGroupNameCtrl = TextEditingController();
  final List<_VariantItemModel> variants = [];

  final List<_OptionGroupModel> optionGroups = [];

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
                            'Tags',
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
                            'Reset',
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
                          'Done',
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

  Future<void> _openAddOptionDialog(
    BuildContext context,
    _OptionGroupModel group, {
    int? editingOptionIndex,
  }) async {
    final isEditing = editingOptionIndex != null;
    final existingOption = isEditing ? group.options[editingOptionIndex] : null;

    final optNameCtrl = TextEditingController(
      text: existingOption?.name ?? '',
    );
    final optPriceCtrl = TextEditingController(
      text: existingOption?.price ?? '0',
    );
    XFile? optImage = existingOption?.imageFile;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Add Option',
                          style: GoogleFonts.rubik(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(dialogCtx),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const AddItemsFieldLabel('Option name'),
                    const SizedBox(height: 6),
                    AddItemsTextField(
                      controller: optNameCtrl,
                      hint: 'Enter option name',
                    ),
                    const SizedBox(height: 14),
                    const AddItemsFieldLabel('Option Image'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: optImage != null
                              ? Image.file(
                                  File(optImage!.path),
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAF5FF),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFD8B4FE),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.photo_outlined,
                                      color: Color(0xFFA855F7),
                                      size: 22,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () async {
                            final picked = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 85,
                            );
                            if (picked != null) {
                              setDialogState(() => optImage = picked);
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF5FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFD8B4FE),
                              ),
                            ),
                            child: Text(
                              'Upload Image',
                              style: GoogleFonts.rubik(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFA855F7),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const AddItemsFieldLabel('Additional price'),
                    const SizedBox(height: 6),
                    AddItemsTextField(
                      controller: optPriceCtrl,
                      hint: '0',
                      keyboardType: TextInputType.number,
                      suffixText: 'MRU',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(dialogCtx),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F5F9),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.rubik(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () {
                                final name = optNameCtrl.text.trim();
                                if (name.isEmpty) return;
                                final price = optPriceCtrl.text.trim().isEmpty
                                    ? '0'
                                    : optPriceCtrl.text.trim();
                                setState(() {
                                  if (isEditing) {
                                    group.options[editingOptionIndex] =
                                        _OptionItemModel(
                                      name: name,
                                      price: price,
                                      imageFile: optImage,
                                    );
                                  } else {
                                    group.options.add(
                                      _OptionItemModel(
                                        name: name,
                                        price: price,
                                        imageFile: optImage,
                                      ),
                                    );
                                  }
                                });
                                Navigator.pop(dialogCtx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5216),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Save Option',
                                style: GoogleFonts.rubik(
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.isRegistered<ItemController>()
          ? Get.find<ItemController>()
          : Get.put(ItemController());
      controller.reset();
      if (widget.initialMenuName != null) {
        controller.setSelectedType(widget.initialMenuName);
      }
      if (controller.restaurantTags.isEmpty &&
          !controller.isRestaurantTagsLoading) {
        controller.getAllTags();
      }
    });
  }

  @override
  void dispose() {
    itemNameCtrl.dispose();
    descriptionCtrl.dispose();
    variantGroupNameCtrl.dispose();
    for (final v in variants) {
      v.nameCtrl.dispose();
      v.priceCtrl.dispose();
    }
    for (final g in optionGroups) {
      g.groupNameCtrl.dispose();
      g.minSelectionsCtrl.dispose();
      g.maxSelectionsCtrl.dispose();
    }
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
            Icons.arrow_back_ios_new,
            color: Color(0xFF1F2937),
            size: 18,
          ),
        ),
        title: Text(
          'Add Item',
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: false,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: GetBuilder<ItemController>(
          init: ItemController(),
          builder: (controller) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Item Images upload dashed box ─────────────────────────────
              const AddItemsFieldLabel('Item Images'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => controller.pickAndCropImage(context),
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: const Color(0xFFBFDBFE),
                    radius: 16,
                    dash: 6,
                    gap: 4,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: controller.pickedImageFile != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  File(controller.pickedImageFile!.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    controller.pickedImageFile = null;
                                    controller.update();
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Color(0xFFFF5216),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEFF6FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.file_upload_outlined,
                                    size: 22,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Upload image here',
                                style: GoogleFonts.rubik(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Section 1: Product Details ────────────────────────────────
              AddItemsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFF5216),
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Color(0xFFFF5216),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Product Details',
                          style: GoogleFonts.rubik(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const AddItemsFieldLabel('Item Name (English)'),
                    const SizedBox(height: 6),
                    AddItemsTextField(
                      controller: itemNameCtrl,
                      hint: 'Enter item name',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AddItemsFieldLabel('Category'),
                              const SizedBox(height: 6),
                              AddItemsDropdownField(
                                value: controller.selectedType != null &&
                                        controller.typeDisplayNames.contains(
                                          controller.selectedType,
                                        )
                                    ? controller.selectedType
                                    : null,
                                hint: controller.isMenuListLoading
                                    ? 'Loading...'
                                    : 'Select Category',
                                items: controller.typeDisplayNames,
                                onChanged: controller.isMenuListLoading
                                    ? (_) {}
                                    : controller.setSelectedType,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AddItemsFieldLabel('Is Veg'),
                              const SizedBox(height: 6),
                              AddItemsDropdownField(
                                value: isVeg,
                                items: const ['No', 'Yes'],
                                onChanged: (v) =>
                                    setState(() => isVeg = v ?? 'No'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const AddItemsFieldLabel('Serial Number'),
                    const SizedBox(height: 6),
                    AddItemsTextField(
                      controller: controller.serialNumberCtrl,
                      hint: 'Enter item name',
                    ),
                    const SizedBox(height: 14),
                    const AddItemsFieldLabel('Description (English)'),
                    const SizedBox(height: 6),
                    AddItemsTextField(
                      controller: descriptionCtrl,
                      hint: 'Enter description',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),
                    const AddItemsFieldLabel('Tags'),
                    const SizedBox(height: 6),
                    AddItemsMultiSelectField(
                      displayText: controller.selectedTagDisplayText,
                      hint: controller.isRestaurantTagsLoading
                          ? 'Loading...'
                          : 'Select tags',
                      onTap: controller.isRestaurantTagsLoading
                          ? () {}
                          : () => _openTagsMultiSelect(context, controller),
                    ),
                    const SizedBox(height: 14),
                    const AddItemsFieldLabel('Preparation Time (minutes)'),
                    const SizedBox(height: 6),
                    AddItemsTextField(
                      controller: controller.prepTimeCtrl,
                      hint: 'Enter minutes',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AddItemsFieldLabel('Price'),
                              const SizedBox(height: 6),
                              AddItemsTextField(
                                controller: controller.priceCtrl,
                                hint: 'Enter Price',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AddItemsFieldLabel('Discount Price'),
                              const SizedBox(height: 6),
                              AddItemsTextField(
                                controller: controller.discountPriceCtrl,
                                hint: 'Enter Discount Price',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Section 2: Variants ───────────────────────────────────────
              AddItemsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.layers_outlined,
                          color: Color(0xFFFF5216),
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Variants',
                          style: GoogleFonts.rubik(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: isVariantsEnabled,
                          activeColor: const Color(0xFF10B981),
                          activeTrackColor:
                              const Color(0xFF10B981).withOpacity(0.4),
                          inactiveThumbColor: const Color(0xFF94A3B8),
                          inactiveTrackColor: const Color(0xFFE2E8F0),
                          onChanged: (val) {
                            setState(() {
                              isVariantsEnabled = val;
                              if (val && variants.isEmpty) {
                                variants.add(_VariantItemModel());
                                variants.add(_VariantItemModel());
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if (isVariantsEnabled) ...[
                      const SizedBox(height: 16),
                      const AddItemsFieldLabel('Variant Group Name'),
                      const SizedBox(height: 6),
                      AddItemsTextField(
                        controller: variantGroupNameCtrl,
                        hint: 'e.g. Choose Your Portion',
                      ),
                      const SizedBox(height: 16),
                      ...variants.asMap().entries.map((entry) {
                        final item = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AddItemsFieldLabel('Variant Image'),
                            const SizedBox(height: 8),
                            if (item.imageFile == null)
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAF5FF),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFD8B4FE),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.photo_outlined,
                                        color: Color(0xFFA855F7),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    onTap: () async {
                                      final picked =
                                          await ImagePicker().pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 85,
                                      );
                                      if (picked != null) {
                                        setState(
                                          () => item.imageFile = picked,
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAF5FF),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFD8B4FE),
                                        ),
                                      ),
                                      child: Text(
                                        'Upload Image',
                                        style: GoogleFonts.rubik(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFA855F7),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(item.imageFile!.path),
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const Spacer(),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final picked =
                                              await ImagePicker().pickImage(
                                            source: ImageSource.gallery,
                                            imageQuality: 85,
                                          );
                                          if (picked != null) {
                                            setState(
                                              () => item.imageFile = picked,
                                            );
                                          }
                                        },
                                        child: const Icon(
                                          Icons.edit_outlined,
                                          size: 16,
                                          color: Color(0xFFFF5216),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      GestureDetector(
                                        onTap: () {
                                          setState(
                                            () => item.imageFile = null,
                                          );
                                        },
                                        child: const Icon(
                                          Icons.delete_outline,
                                          size: 16,
                                          color: Color(0xFFEF4444),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const AddItemsFieldLabel('Variant Name'),
                                      const SizedBox(height: 6),
                                      AddItemsTextField(
                                        controller: item.nameCtrl,
                                        hint: '',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const AddItemsFieldLabel('Price'),
                                      const SizedBox(height: 6),
                                      AddItemsTextField(
                                        controller: item.priceCtrl,
                                        hint: '',
                                        keyboardType: TextInputType.number,
                                        suffixText: 'MRU',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const AddItemsFieldLabel('Selection requirement'),
                            const SizedBox(height: 6),
                            AddItemsDropdownField(
                              value: item.selectionRequirement,
                              items: const ['Optional', 'Required'],
                              onChanged: (v) {
                                if (v != null) {
                                  setState(
                                    () => item.selectionRequirement = v,
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }),
                      InkWell(
                        onTap: () {
                          setState(() {
                            variants.add(_VariantItemModel());
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF5FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFE9D5FF),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add,
                                color: Color(0xFFA855F7),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Add Variant',
                                style: GoogleFonts.rubik(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFA855F7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Section 3: Option Groups ──────────────────────────────────
              AddItemsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.format_list_bulleted,
                          color: Color(0xFFFF5216),
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Option Groups',
                          style: GoogleFonts.rubik(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    if (optionGroups.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...optionGroups.asMap().entries.map((entry) {
                        final gIndex = entry.key;
                        final group = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AddItemsFieldLabel('Group Name'),
                            const SizedBox(height: 6),
                            AddItemsTextField(
                              controller: group.groupNameCtrl,
                              hint: 'e.g. Choose Your Side, Add Extra...',
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const AddItemsFieldLabel(
                                        'Minimum selections',
                                      ),
                                      const SizedBox(height: 6),
                                      AddItemsTextField(
                                        controller: group.minSelectionsCtrl,
                                        hint: '',
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const AddItemsFieldLabel(
                                        'Maximum selections',
                                      ),
                                      const SizedBox(height: 6),
                                      AddItemsTextField(
                                        controller: group.maxSelectionsCtrl,
                                        hint: '',
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const AddItemsFieldLabel('Selection requirement'),
                            const SizedBox(height: 6),
                            AddItemsDropdownField(
                              value: group.selectionRequirement,
                              items: const ['Optional', 'Required'],
                              onChanged: (v) {
                                if (v != null) {
                                  setState(
                                    () => group.selectionRequirement = v,
                                  );
                                }
                              },
                            ),
                            if (group.options.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              const AddItemsFieldLabel('Option Image'),
                              const SizedBox(height: 8),
                              ...group.options.asMap().entries.map((optEntry) {
                                final optIndex = optEntry.key;
                                final opt = optEntry.value;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        child: opt.imageFile != null
                                            ? Image.file(
                                                File(opt.imageFile!.path),
                                                width: 44,
                                                height: 44,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                width: 44,
                                                height: 44,
                                                color: const Color(
                                                  0xFFF1F5F9,
                                                ),
                                                child: const Icon(
                                                  Icons.fastfood,
                                                  size: 22,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              opt.name,
                                              style: GoogleFonts.rubik(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(
                                                  0xFF1F2937,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${opt.price} MRU',
                                              style: GoogleFonts.rubik(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(
                                                  0xFF64748B,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () => _openAddOptionDialog(
                                              context,
                                              group,
                                              editingOptionIndex: optIndex,
                                            ),
                                            child: const Icon(
                                              Icons.edit_outlined,
                                              size: 16,
                                              color: Color(0xFFFF5216),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                group.options.removeAt(
                                                  optIndex,
                                                );
                                              });
                                            },
                                            child: const Icon(
                                              Icons.delete_outline,
                                              size: 16,
                                              color: Color(0xFFEF4444),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () =>
                                      _openAddOptionDialog(context, group),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAF5FF),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFE9D5FF),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.add,
                                          color: Color(0xFFA855F7),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Add Option',
                                          style: GoogleFonts.rubik(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFA855F7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      optionGroups.removeAt(gIndex);
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFFCA5A5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.delete_outline,
                                          color: Color(0xFFEF4444),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Delete Group',
                                          style: GoogleFonts.rubik(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFEF4444),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      }),
                    ],
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          optionGroups.add(_OptionGroupModel());
                        });
                      },
                      child: CustomPaint(
                        painter: DashedBorderPainter(
                          color: const Color(0xFFFF8A65),
                          radius: 12,
                          dash: 5,
                          gap: 4,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add,
                                color: Color(0xFFFF5216),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Add Option Group',
                                style: GoogleFonts.rubik(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFF5216),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AddItemsBottomBar(
        onReset: () {
          final c = Get.find<ItemController>();
          c.reset();
          itemNameCtrl.clear();
          descriptionCtrl.clear();
          variantGroupNameCtrl.clear();
          setState(() {
            isVeg = 'No';
            isVariantsEnabled = false;
            variants.clear();
            optionGroups.clear();
          });
        },
        onSubmit: () {
          final c = Get.find<ItemController>();
          if (c.serialNumberCtrl.text.trim().isEmpty &&
              itemNameCtrl.text.trim().isNotEmpty) {
            c.serialNumberCtrl.text = itemNameCtrl.text.trim();
          }
          if (c.selectedRestaurantAttributeId == null &&
              c.restaurantAttributes.isNotEmpty) {
            c.selectedRestaurantAttributeId = c.restaurantAttributes.first.id;
          }
          c.addItem(
            context,
            menuId: c.selectedMenuId?.toString() ?? '',
            menuItemId: c.serialNumberCtrl.text.trim(),
            restaurantAttributeId:
                c.selectedRestaurantAttributeId?.toString() ?? '1',
          );
        },
      ),
    );
  }
}

