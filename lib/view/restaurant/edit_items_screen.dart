import 'package:saimpex_vendor/resources/fonts.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saimpex_vendor/controller/item_controller.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import 'package:saimpex_vendor/view/restaurant/Widgets/edit_items_screen_widgets.dart';

class EditItemsScreen extends StatefulWidget {
  final String itemId;

  const EditItemsScreen({super.key, required this.itemId});

  @override
  State<EditItemsScreen> createState() => _EditItemsScreenState();
}

class _VariantItemModel {
  /// Server id when the variant already exists (kept so the server updates it in place).
  int? id;
  XFile? imageFile;
  String? assetPath;
  String? imageUrl;
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  String selectionRequirement;

  _VariantItemModel({
    this.id,
    this.imageFile,
    this.assetPath,
    this.imageUrl,
    String name = '',
    String price = '',
    this.selectionRequirement = 'Optional',
  })  : nameCtrl = TextEditingController(text: name),
        priceCtrl = TextEditingController(text: price);

  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
  }
}

class _OptionItemModel {
  _OptionItemModel({
    this.id,
    required this.name,
    required this.price,
    this.imageFile,
    this.assetPath,
    this.imageUrl,
    this.isAvailable = true,
  });

  /// Server id when the option already exists; keeps carts that picked it valid.
  int? id;
  String name;
  String price;
  XFile? imageFile;
  String? assetPath;
  String? imageUrl;
  bool isAvailable;
}

class _OptionGroupModel {
  /// Server id when the group already exists.
  int? id;
  final TextEditingController groupNameCtrl;
  final TextEditingController minSelectionsCtrl;
  final TextEditingController maxSelectionsCtrl;
  String selectionRequirement;
  final List<_OptionItemModel> options;

  _OptionGroupModel({
    this.id,
    String groupName = '',
    String minSelections = '',
    String maxSelections = '',
    this.selectionRequirement = 'Optional',
    List<_OptionItemModel>? options,
  })  : groupNameCtrl = TextEditingController(text: groupName),
        minSelectionsCtrl = TextEditingController(text: minSelections),
        maxSelectionsCtrl = TextEditingController(text: maxSelections),
        options = options ?? [];

  void dispose() {
    groupNameCtrl.dispose();
    minSelectionsCtrl.dispose();
    maxSelectionsCtrl.dispose();
  }
}

class _ExtraItemModel {
  /// Server id when the extra already exists.
  int? id;
  XFile? imageFile;
  String? assetPath;
  String? imageUrl;
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;

  _ExtraItemModel({
    this.id,
    this.imageFile,
    this.assetPath,
    this.imageUrl,
    String name = '',
    String price = '',
    VoidCallback? onChanged,
  })  : nameCtrl = TextEditingController(text: name),
        priceCtrl = TextEditingController(text: price) {
    if (onChanged != null) {
      nameCtrl.addListener(onChanged);
      priceCtrl.addListener(onChanged);
    }
  }

  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
  }
}

class _EditItemsScreenState extends State<EditItemsScreen> {
  bool _didLoadDetails = false;

  final TextEditingController itemNameCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();
  String isVeg = 'No';

  bool isVariantsEnabled = false;
  final TextEditingController variantGroupNameCtrl = TextEditingController();
  final List<_VariantItemModel> variants = [];

  final List<_OptionGroupModel> optionGroups = [];

  final TextEditingController extraMaxSelectionsCtrl = TextEditingController();
  String extraSelectionRequirement = 'Optional';
  final List<_ExtraItemModel> extraItems = [];

  @override
  void dispose() {
    itemNameCtrl.dispose();
    descriptionCtrl.dispose();
    variantGroupNameCtrl.dispose();
    for (final v in variants) {
      v.dispose();
    }
    for (final g in optionGroups) {
      g.dispose();
    }
    extraMaxSelectionsCtrl.dispose();
    for (final extra in extraItems) {
      extra.dispose();
    }
    super.dispose();
  }

  String _requirementLabel(dynamic value) =>
      value?.toString().toLowerCase() == 'required' ? 'Required' : 'Optional';

  String _numText(dynamic value) {
    if (value == null) return '';
    final n = num.tryParse(value.toString());
    if (n == null) return value.toString();
    return n == n.roundToDouble() ? n.toInt().toString() : n.toString();
  }

  int? _id(dynamic value) => value == null ? null : int.tryParse(value.toString());

  /// Fills the screen from restaurantCatalogItemDetail so the vendor edits what is
  /// really saved: variants, option groups and extras with their server ids.
  void _fillFromCatalog(Map<String, dynamic>? data) {
    if (data == null) return;

    itemNameCtrl.text = data['name_en']?.toString() ?? itemNameCtrl.text;
    descriptionCtrl.text = data['description_en']?.toString() ?? '';

    for (final v in variants) {
      v.dispose();
    }
    variants.clear();
    final rawVariants = (data['variants'] as List? ?? const []).whereType<Map>();
    for (final v in rawVariants) {
      variants.add(_VariantItemModel(
        id: _id(v['id']),
        name: v['name']?.toString() ?? '',
        price: _numText(v['price']),
        imageUrl: v['image_url']?.toString(),
        selectionRequirement: _requirementLabel(v['selection_requirement']),
      ));
    }
    isVariantsEnabled = data['has_variants'] == true ||
        data['has_variants']?.toString() == '1' ||
        variants.isNotEmpty;
    variantGroupNameCtrl.text = data['variant_group_name']?.toString() ?? '';

    for (final g in optionGroups) {
      g.dispose();
    }
    optionGroups.clear();
    for (final g in (data['option_groups'] as List? ?? const []).whereType<Map>()) {
      optionGroups.add(_OptionGroupModel(
        id: _id(g['id']),
        groupName: g['name']?.toString() ?? '',
        minSelections: _numText(g['min_selections']),
        maxSelections: _numText(g['max_selections']),
        selectionRequirement: _requirementLabel(g['selection_requirement']),
        options: [
          for (final o in (g['options'] as List? ?? const []).whereType<Map>())
            _OptionItemModel(
              id: _id(o['id']),
              name: o['name']?.toString() ?? '',
              price: _numText(o['additional_price']),
              imageUrl: o['image_url']?.toString(),
              isAvailable: o['available_status']?.toString() != '2',
            ),
        ],
      ));
    }

    for (final e in extraItems) {
      e.dispose();
    }
    extraItems.clear();
    final extras = data['extras'] is Map ? data['extras'] as Map : const {};
    extraSelectionRequirement = _requirementLabel(extras['selection_requirement']);
    extraMaxSelectionsCtrl.text = _numText(extras['max_selections']);
    for (final e in (extras['items'] as List? ?? const []).whereType<Map>()) {
      // Hidden extras (available_status 2) are kept on the server for old orders;
      // they are not shown, so saving leaves them hidden.
      if (e['available_status']?.toString() == '2') continue;
      extraItems.add(_ExtraItemModel(
        id: _id(e['id']),
        name: e['name']?.toString() ?? '',
        price: _numText(e['additional_price']),
        imageUrl: e['image_url']?.toString(),
      ));
    }
  }

  /// Restaurant save: same fields as add, plus ids so existing rows update in place.
  void _submitCatalog(ItemController c) {
    final validExtras = extraItems
        .where((e) => e.nameCtrl.text.trim().isNotEmpty)
        .map((e) => CatalogExtraItem(
              id: e.id,
              name: e.nameCtrl.text.trim(),
              additionalPrice: num.tryParse(e.priceCtrl.text.trim()) ?? 0,
              availableStatus: 1,
              imagePath: e.imageFile?.path,
            ))
        .toList();

    final validVariants = !isVariantsEnabled
        ? const <CatalogVariant>[]
        : variants
            .where((v) =>
                v.nameCtrl.text.trim().isNotEmpty &&
                num.tryParse(v.priceCtrl.text.trim()) != null)
            .map((v) => CatalogVariant(
                  id: v.id,
                  name: v.nameCtrl.text.trim(),
                  price: num.parse(v.priceCtrl.text.trim()),
                  selectionRequirement: v.selectionRequirement.toLowerCase(),
                  imagePath: v.imageFile?.path,
                ))
            .toList();
    if (isVariantsEnabled && validVariants.isEmpty) {
      Get.snackbar('', 'Add at least one variant with a name and price',
          titleText: const SizedBox.shrink());
      return;
    }

    final validGroups = optionGroups
        .where((g) => g.groupNameCtrl.text.trim().isNotEmpty)
        .map((g) => CatalogOptionGroup(
              id: g.id,
              name: g.groupNameCtrl.text.trim(),
              selectionRequirement: g.selectionRequirement.toLowerCase(),
              minSelections: int.tryParse(g.minSelectionsCtrl.text.trim()),
              maxSelections: int.tryParse(g.maxSelectionsCtrl.text.trim()),
              options: g.options
                  .where((o) => o.name.trim().isNotEmpty)
                  .map((o) => CatalogOption(
                        id: o.id,
                        name: o.name.trim(),
                        additionalPrice: num.tryParse(o.price.trim()) ?? 0,
                        availableStatus: o.isAvailable ? 1 : 2,
                        imagePath: o.imageFile?.path,
                      ))
                  .toList(),
            ))
        .toList();

    c.updateCatalogItem(
      context,
      itemId: widget.itemId,
      menuId: c.selectedMenuId?.toString() ?? '',
      itemName: itemNameCtrl.text.trim(),
      description: descriptionCtrl.text.trim(),
      isVeg: isVeg,
      extraSelectionRequirement: extraSelectionRequirement,
      extraMaxSelections: extraMaxSelectionsCtrl.text.trim(),
      catalogExtras: validExtras,
      variantGroupName: variantGroupNameCtrl.text.trim(),
      variants: validVariants,
      optionGroups: validGroups,
    );
  }

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
                            style: appFont('Rubik', 
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
                              style: appFont('Rubik', 
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

  Future<void> _openEditOptionDialog(
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
      text: existingOption?.price ?? '',
    );
    XFile? optImage = existingOption?.imageFile;
    String? optAssetPath = existingOption?.assetPath;
    String? optImageUrl = existingOption?.imageUrl;
    bool optIsAvailable = existingOption?.isAvailable ?? true;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final hasImage = optImage != null ||
                (optAssetPath != null && optAssetPath!.isNotEmpty) ||
                (optImageUrl != null && optImageUrl!.isNotEmpty);

            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isEditing ? 'Edit Option' : 'Add Option',
                          style: appFont('Rubik', 
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
                    const EditItemsFieldLabel('Option name'),
                    const SizedBox(height: 6),
                    EditItemsTextField(
                      controller: optNameCtrl,
                      hint: 'Enter option name',
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Option Image',
                      style: appFont('Rubik', 
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA855F7),
                      ),
                    ),
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
                              : (optAssetPath != null &&
                                      optAssetPath!.isNotEmpty)
                                  ? Image.asset(
                                      optAssetPath!,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                    )
                                  : (optImageUrl != null &&
                                          optImageUrl!.isNotEmpty)
                                      ? CachedNetworkImage(
                                          imageUrl: optImageUrl!,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFAF5FF),
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () async {
                            final picked = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 85,
                            );
                            if (picked != null) {
                              setDialogState(() {
                                optImage = picked;
                                optAssetPath = null;
                                optImageUrl = null;
                              });
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
                              hasImage ? 'Change Image' : 'Upload image',
                              style: appFont('Rubik', 
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
                    const EditItemsFieldLabel('Additional price'),
                    const SizedBox(height: 6),
                    EditItemsTextField(
                      controller: optPriceCtrl,
                      hint: '0',
                      keyboardType: TextInputType.number,
                      suffixText: 'MRU',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Switch(
                          value: optIsAvailable,
                          activeColor: const Color(0xFF10B981),
                          activeTrackColor:
                              const Color(0xFF10B981).withOpacity(0.4),
                          inactiveThumbColor: const Color(0xFF94A3B8),
                          inactiveTrackColor: const Color(0xFFE2E8F0),
                          onChanged: (val) {
                            setDialogState(() => optIsAvailable = val);
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Available',
                          style: appFont('Rubik', 
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ],
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
                                style: appFont('Rubik', 
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
                                      id: existingOption?.id,
                                      name: name,
                                      price: price,
                                      imageFile: optImage,
                                      assetPath: optAssetPath,
                                      imageUrl: optImageUrl,
                                      isAvailable: optIsAvailable,
                                    );
                                  } else {
                                    group.options.add(
                                      _OptionItemModel(
                                        name: name,
                                        price: price,
                                        imageFile: optImage,
                                        assetPath: optAssetPath,
                                        imageUrl: optImageUrl,
                                        isAvailable: optIsAvailable,
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
          'Edit Item',
          style: appFont('Rubik', 
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: false,
      ),
      child: GetBuilder<ItemController>(
        init: ItemController(editRestaurantMenuItemId: widget.itemId),
        builder: (controller) {
          if (!_didLoadDetails &&
              controller.editRestaurantMenuItemId != null &&
              controller.editRestaurantMenuItemId!.isNotEmpty) {
            _didLoadDetails = true;
            Future.microtask(() async {
              await controller.loadItemForEdit(widget.itemId);
              if (mounted && controller.isCatalogEdit) {
                setState(() => _fillFromCatalog(controller.catalogItemDetail));
              }
              if (mounted) {
                setState(() {
                  if (itemNameCtrl.text.isEmpty) {
                    itemNameCtrl.text = controller.currentMenuData?.nameEn ??
                        controller.serialNumberCtrl.text;
                  }
                  if (descriptionCtrl.text.isEmpty) {
                    descriptionCtrl.text =
                        controller.currentMenuData?.descriptionEn ?? '';
                  }
                  if (controller.currentMenuData?.isVeg != null) {
                    isVeg =
                        controller.currentMenuData!.isVeg == 1 ? 'Yes' : 'No';
                  }
                });
              }
            });
          }

          if (controller.restaurantTags.isEmpty &&
              !controller.isRestaurantTagsLoading) {
            controller.getAllTags();
          }
          if (controller.menuList.isEmpty && !controller.isMenuListLoading) {
            controller.getAllMenus();
          }

          final existingImageUrl = controller.isCatalogEdit
              ? controller.catalogImageUrl
              : controller.currentMenuData?.image;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Item Images upload dashed box ───────────────────────────
                const EditItemsFieldLabel('Item Images'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => controller.pickAndCropImage(context),
                  child: CustomPaint(
                    foregroundPainter: DashedBorderPainter(
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
                          : (existingImageUrl != null &&
                                  existingImageUrl.isNotEmpty)
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: CachedNetworkImage(
                                        imageUrl: existingImageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
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
                                      style: appFont('Rubik', 
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

                // ── Section 1: Product Details ──────────────────────────────
                EditItemsCard(
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
                            style: appFont('Rubik', 
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const EditItemsFieldLabel('Item Name (English)'),
                      const SizedBox(height: 6),
                      EditItemsTextField(
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
                                const EditItemsFieldLabel('Category'),
                                const SizedBox(height: 6),
                                EditItemsDropdownField(
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
                                const EditItemsFieldLabel('Is Veg'),
                                const SizedBox(height: 6),
                                EditItemsDropdownField(
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
                      const EditItemsFieldLabel('Serial Number'),
                      const SizedBox(height: 6),
                      EditItemsTextField(
                        controller: controller.serialNumberCtrl,
                        hint: 'Enter item name',
                      ),
                      const SizedBox(height: 14),
                      const EditItemsFieldLabel('Description (English)'),
                      const SizedBox(height: 6),
                      EditItemsTextField(
                        controller: descriptionCtrl,
                        hint: 'Enter description',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 14),
                      const EditItemsFieldLabel('Tags'),
                      const SizedBox(height: 6),
                      EditItemsMultiSelectField(
                        displayText: controller.selectedTagDisplayText,
                        hint: controller.isRestaurantTagsLoading
                            ? 'Loading...'
                            : 'Select tags',
                        onTap: controller.isRestaurantTagsLoading
                            ? () {}
                            : () => _openTagsMultiSelect(context, controller),
                      ),
                      const SizedBox(height: 14),
                      const EditItemsFieldLabel('Preparation Time (minutes)'),
                      const SizedBox(height: 6),
                      EditItemsTextField(
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
                                const EditItemsFieldLabel('Price'),
                                const SizedBox(height: 6),
                                EditItemsTextField(
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
                                const EditItemsFieldLabel('Discount Price'),
                                const SizedBox(height: 6),
                                EditItemsTextField(
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

                // ── Section 2: Variants ─────────────────────────────────────
                EditItemsCard(
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
                            style: appFont('Rubik', 
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
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      if (isVariantsEnabled) ...[
                        const SizedBox(height: 16),
                        const EditItemsFieldLabel('Variant Group Name'),
                        const SizedBox(height: 6),
                        EditItemsTextField(
                          controller: variantGroupNameCtrl,
                          hint: 'e.g. Choose Your Portion',
                        ),
                        const SizedBox(height: 16),
                        ...variants.asMap().entries.map((entry) {
                          final item = entry.value;
                          final hasImg = item.imageFile != null ||
                              (item.assetPath != null &&
                                  item.assetPath!.isNotEmpty) ||
                              (item.imageUrl != null &&
                                  item.imageUrl!.isNotEmpty);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Variant Image',
                                style: appFont('Rubik', 
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: hasImg
                                      ? const Color(0xFF475569)
                                      : const Color(0xFFA855F7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (!hasImg)
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
                                          'Upload image',
                                          style: appFont('Rubik', 
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
                                      child: item.imageFile != null
                                          ? Image.file(
                                              File(item.imageFile!.path),
                                              width: 44,
                                              height: 44,
                                              fit: BoxFit.cover,
                                            )
                                          : (item.assetPath != null &&
                                                  item.assetPath!.isNotEmpty)
                                              ? Image.asset(
                                                  item.assetPath!,
                                                  width: 44,
                                                  height: 44,
                                                  fit: BoxFit.cover,
                                                )
                                              : CachedNetworkImage(
                                                  imageUrl: item.imageUrl!,
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
                                            setState(() {
                                              item.imageFile = null;
                                              item.assetPath = null;
                                              item.imageUrl = null;
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
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const EditItemsFieldLabel(
                                          'Variant Name',
                                        ),
                                        const SizedBox(height: 6),
                                        EditItemsTextField(
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
                                        const EditItemsFieldLabel('Price'),
                                        const SizedBox(height: 6),
                                        EditItemsTextField(
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
                                  style: appFont('Rubik', 
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

                // ── Section 3: Option Groups ────────────────────────────────
                EditItemsCard(
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
                            style: appFont('Rubik', 
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
                              const EditItemsFieldLabel('Group Name'),
                              const SizedBox(height: 6),
                              EditItemsTextField(
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
                                        const EditItemsFieldLabel(
                                          'Minimum selections',
                                        ),
                                        const SizedBox(height: 6),
                                        EditItemsTextField(
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
                                        const EditItemsFieldLabel(
                                          'Maximum selections',
                                        ),
                                        const SizedBox(height: 6),
                                        EditItemsTextField(
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
                              const EditItemsFieldLabel(
                                'Selection requirement',
                              ),
                              const SizedBox(height: 6),
                              EditItemsDropdownField(
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
                                const EditItemsFieldLabel('Option Image'),
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
                                              : (opt.assetPath != null &&
                                                      opt.assetPath!.isNotEmpty)
                                                  ? Image.asset(
                                                      opt.assetPath!,
                                                      width: 44,
                                                      height: 44,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : (opt.imageUrl != null &&
                                                          opt.imageUrl!
                                                              .isNotEmpty)
                                                      ? CachedNetworkImage(
                                                          imageUrl:
                                                              opt.imageUrl!,
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
                                                            color: Color(
                                                              0xFF94A3B8,
                                                            ),
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
                                                style: appFont('Rubik', 
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
                                                style: appFont('Rubik', 
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
                                              onTap: () => _openEditOptionDialog(
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
                                        _openEditOptionDialog(context, group),
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
                                            style: appFont('Rubik', 
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFFA855F7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (optionGroups.length > 1) ...[
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
                                              style: appFont('Rubik', 
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
                          foregroundPainter: DashedBorderPainter(
                            color: const Color(0xFFFF5216),
                            strokeWidth: 1.2,
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
                                  style: appFont('Rubik', 
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
                const SizedBox(height: 16),

                // ── Section 4: Add Extras ────────────────────────────────────
                EditItemsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.add,
                            color: Color(0xFFFF5216),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add Extras',
                            style: appFont('Rubik', 
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const EditItemsFieldLabel('Maximum selections'),
                                const SizedBox(height: 6),
                                EditItemsTextField(
                                  controller: extraMaxSelectionsCtrl,
                                  hint: '',
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
                                const EditItemsFieldLabel(
                                  'Selection requirement',
                                ),
                                const SizedBox(height: 6),
                                EditItemsDropdownField(
                                  value: extraSelectionRequirement,
                                  items: const ['Optional', 'Required'],
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(
                                        () => extraSelectionRequirement = v,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (extraItems.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ...extraItems.asMap().entries.map((entry) {
                          final extraIndex = entry.key;
                          final extra = entry.value;
                          final hasImg = extra.imageFile != null ||
                              (extra.assetPath != null &&
                                  extra.assetPath!.isNotEmpty) ||
                              (extra.imageUrl != null &&
                                  extra.imageUrl!.isNotEmpty);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              EditItemsFieldLabel(
                                'Item image',
                                color: hasImg
                                    ? const Color(0xFFA855F7)
                                    : const Color(0xFFA855F7),
                              ),
                              const SizedBox(height: 8),
                              if (!hasImg)
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAF5FF),
                                        borderRadius:
                                            BorderRadius.circular(10),
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
                                            () => extra.imageFile = picked,
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
                                          'Upload image',
                                          style: appFont('Rubik', 
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
                                Container(
                                  margin: const EdgeInsets.only(bottom: 2),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        child: extra.imageFile != null
                                            ? Image.file(
                                                File(extra.imageFile!.path),
                                                width: 44,
                                                height: 44,
                                                fit: BoxFit.cover,
                                              )
                                            : (extra.assetPath != null &&
                                                    extra.assetPath!.isNotEmpty)
                                                ? Image.asset(
                                                    extra.assetPath!,
                                                    width: 44,
                                                    height: 44,
                                                    fit: BoxFit.cover,
                                                  )
                                                : (extra.imageUrl != null &&
                                                        extra.imageUrl!
                                                            .isNotEmpty)
                                                    ? CachedNetworkImage(
                                                        imageUrl:
                                                            extra.imageUrl!,
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
                                                          color: Color(
                                                            0xFF94A3B8,
                                                          ),
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
                                              extra.nameCtrl.text.isNotEmpty
                                                  ? extra.nameCtrl.text
                                                  : '',
                                              style: appFont('Rubik', 
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    const Color(0xFF1F2937),
                                              ),
                                            ),
                                            if (extra.priceCtrl.text
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                '+${extra.priceCtrl.text} MRU',
                                                style: appFont('Rubik', 
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      const Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
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
                                                setState(() {
                                                  extra.imageFile = picked;
                                                  extra.assetPath = null;
                                                  extra.imageUrl = null;
                                                });
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
                                              setState(() {
                                                final removed =
                                                    extraItems.removeAt(
                                                  extraIndex,
                                                );
                                                removed.dispose();
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
                                ),
                              const SizedBox(height: 12),
                              const EditItemsFieldLabel('Item Name'),
                              const SizedBox(height: 6),
                              EditItemsTextField(
                                controller: extra.nameCtrl,
                                hint: 'e.g. Burger',
                              ),
                              const SizedBox(height: 12),
                              const EditItemsFieldLabel('Price'),
                              const SizedBox(height: 6),
                              EditItemsTextField(
                                controller: extra.priceCtrl,
                                hint: '',
                                keyboardType: TextInputType.number,
                                suffixText: 'MRU',
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }),
                      ],
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            extraItems.add(
                              _ExtraItemModel(
                                onChanged: () => setState(() {}),
                              ),
                            );
                          });
                        },
                        child: CustomPaint(
                          foregroundPainter: DashedBorderPainter(
                            color: const Color(0xFFFF5216),
                            strokeWidth: 1.2,
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
                                  extraItems.isEmpty
                                      ? 'Add Item'
                                      : 'Add Another Item',
                                  style: appFont('Rubik', 
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
          );
        },
      ),
      bottomNavigationBar: EditItemsBottomBar(
        onReset: () {
          final c = Get.find<ItemController>();
          c.reset();
          itemNameCtrl.clear();
          descriptionCtrl.clear();
          variantGroupNameCtrl.clear();
          extraMaxSelectionsCtrl.clear();
          setState(() {
            isVeg = 'No';
            isVariantsEnabled = false;
            variants.clear();
            optionGroups.clear();
            for (final extra in extraItems) {
              extra.dispose();
            }
            extraItems.clear();
            extraSelectionRequirement = 'Optional';
          });
        },
        onSubmit: () {
          final c = Get.find<ItemController>();
          if (c.isCatalogEdit) {
            _submitCatalog(c);
            return;
          }
          if (c.serialNumberCtrl.text.trim().isEmpty &&
              itemNameCtrl.text.trim().isNotEmpty) {
            c.serialNumberCtrl.text = itemNameCtrl.text.trim();
          }
          c.updateItemAfterEdit(
            context,
            menuId: c.selectedMenuId?.toString() ?? '',
            menuItemId: widget.itemId,
            restaurantAttributeId:
                c.selectedRestaurantAttributeId?.toString() ?? '',
          );
        },
      ),
    );
  }
}
