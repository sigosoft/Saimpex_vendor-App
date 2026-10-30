import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saimpex_vendor/home_cleaning/view/my_services_view.dart';

class SpacePricingItem {
  SpacePricingItem({
    required this.name,
    required this.rate,
    required this.unit,
  });

  String name;
  String rate;
  String unit;
}

class AddonPricingItem {
  AddonPricingItem({
    required this.name,
    required this.rate,
    required this.unit,
  });

  String name;
  String rate;
  String unit;
}

class AddServiceView extends StatefulWidget {
  const AddServiceView({super.key, this.initialService});

  final ServiceItem? initialService;

  static const _orange = Color(0xFFFF5722);
  static const _ink = Color(0xFF1A1A1A);

  @override
  State<AddServiceView> createState() => _AddServiceViewState();
}

class _AddServiceViewState extends State<AddServiceView> {
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isApartmentSelected = true;
  bool _isVillaSelected = true;

  String _selectedServiceType = 'Select Service';
  final List<String> _serviceTypes = [
    'Select Service',
    'Regular Cleaning',
    'Pest Control & Disinfection',
    'Deep Cleaning',
    'Office Cleaning',
    'Move-in / Move-out Cleaning',
  ];

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _supplyFeeController = TextEditingController(text: '120');

  bool _customerProvidesProducts = true;
  bool _iProvideProducts = true;

  late List<SpacePricingItem> _spaces;
  late List<AddonPricingItem> _addons;
  Set<String> _selectedIssues = <String>{};

  bool get _isCleaningService =>
      _selectedServiceType == 'Regular Cleaning' ||
      _selectedServiceType == 'Deep Cleaning' ||
      _selectedServiceType == 'Office Cleaning' ||
      _selectedServiceType == 'Move-in / Move-out Cleaning';

  bool get _isPestControl =>
      _selectedServiceType == 'Pest Control & Disinfection' ||
      _selectedServiceType == 'Select Service';

  @override
  void initState() {
    super.initState();
    if (widget.initialService != null) {
      _selectedServiceType = widget.initialService!.title;
      _descriptionController.text = widget.initialService!.description;
      _spaces = [
        SpacePricingItem(name: 'Bedrooms', rate: widget.initialService!.startingRate, unit: 'Room'),
        SpacePricingItem(name: 'Kitchens', rate: widget.initialService!.startingRate, unit: 'Room'),
      ];
      _addons = widget.initialService!.badges
          .where((b) => b.price != null)
          .map((b) => AddonPricingItem(
                name: b.label,
                rate: b.price!.replaceAll(RegExp(r'[^0-9]'), ''),
                unit: 'Unit',
              ))
          .toList();
      _selectedIssues = widget.initialService!.badges
          .where((b) => b.price == null)
          .map((b) {
            if (b.label == 'Viral Disinfection') return 'General Sanitization';
            return b.label;
          })
          .toSet();
    } else {
      _spaces = [
        SpacePricingItem(name: 'Bedrooms', rate: '100', unit: 'Room'),
        SpacePricingItem(name: 'Kitchens', rate: '100', unit: 'Room'),
        SpacePricingItem(name: 'Bathrooms / WC', rate: '100', unit: 'Room'),
        SpacePricingItem(name: 'Balconies', rate: '100', unit: 'Unit'),
      ];
      _addons = [
        AddonPricingItem(name: 'Fridge Cleaning', rate: '100', unit: 'Unit'),
      ];
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _supplyFeeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _pickedImage = File(image.path);
        });
      }
    } catch (_) {}
  }

  void _resetAll() {
    HapticFeedback.lightImpact();
    setState(() {
      _pickedImage = null;
      _isApartmentSelected = false;
      _isVillaSelected = false;
      _selectedServiceType = 'Select Service';
      _descriptionController.clear();
      _supplyFeeController.clear();
      _customerProvidesProducts = false;
      _iProvideProducts = false;
      _spaces.clear();
      _addons.clear();
      _selectedIssues.clear();
    });
  }

  void _showAddSpaceDialog({SpacePricingItem? editingItem, int? index}) {
    final nameCtrl = TextEditingController(text: editingItem?.name ?? '');
    final priceCtrl = TextEditingController(text: editingItem?.rate ?? '');
    String currentUnit = editingItem?.unit ?? 'Room';
    final units = ['Room', 'Unit', 'Hour', 'Sq. Ft'];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.viewInsetsOf(context).bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        editingItem != null ? 'Edit Space' : 'Add Space',
                        style: GoogleFonts.inter(
                          color: AddServiceView._ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Space Name',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF616161),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    style: GoogleFonts.inter(fontSize: 13, color: AddServiceView._ink),
                    decoration: InputDecoration(
                      hintText: 'e.g. Master Bedroom, Living Room, Corridor, Balcony',
                      hintStyle: GoogleFonts.inter(
                        color: const Color(0xFFBDBDBD),
                        fontSize: 12.5,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F8),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Unit',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF616161),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentUnit,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF757575)),
                        style: GoogleFonts.inter(fontSize: 13, color: AddServiceView._ink, fontWeight: FontWeight.w600),
                        items: units
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => currentUnit = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Price',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF616161),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.inter(fontSize: 13, color: AddServiceView._ink),
                            decoration: InputDecoration(
                              hintText: 'Enter the Price',
                              hintStyle: GoogleFonts.inter(
                                color: const Color(0xFFBDBDBD),
                                fontSize: 12.5,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF5FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'MRU',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF1E6BE6),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF424242),
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
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
                              final name = nameCtrl.text.trim();
                              final price = priceCtrl.text.trim();
                              if (name.isNotEmpty && price.isNotEmpty) {
                                setState(() {
                                  if (editingItem != null && index != null) {
                                    _spaces[index] = SpacePricingItem(
                                      name: name,
                                      rate: price,
                                      unit: currentUnit,
                                    );
                                  } else {
                                    _spaces.add(SpacePricingItem(
                                      name: name,
                                      rate: price,
                                      unit: currentUnit,
                                    ));
                                  }
                                });
                                Navigator.pop(ctx);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AddServiceView._orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              editingItem != null ? 'Save Space' : 'Add Space',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddAddonDialog({AddonPricingItem? editingItem, int? index}) {
    final nameCtrl = TextEditingController(text: editingItem?.name ?? '');
    final priceCtrl = TextEditingController(text: editingItem?.rate ?? '');
    String currentUnit = editingItem?.unit ?? 'Unit';
    final units = ['Unit', 'Hour', 'Room', 'Piece'];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.viewInsetsOf(context).bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        editingItem != null ? 'Edit Add-on' : 'Add Add-on',
                        style: GoogleFonts.inter(
                          color: AddServiceView._ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Add-on Name',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF616161),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    style: GoogleFonts.inter(fontSize: 13, color: AddServiceView._ink),
                    decoration: InputDecoration(
                      hintText: 'e.g. Fridge Cleaning, Oven Cleaning',
                      hintStyle: GoogleFonts.inter(
                        color: const Color(0xFFBDBDBD),
                        fontSize: 12.5,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F8),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Unit',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF616161),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentUnit,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF757575)),
                        style: GoogleFonts.inter(fontSize: 13, color: AddServiceView._ink, fontWeight: FontWeight.w600),
                        items: units
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => currentUnit = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Price',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF616161),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.inter(fontSize: 13, color: AddServiceView._ink),
                            decoration: InputDecoration(
                              hintText: 'Enter the Price',
                              hintStyle: GoogleFonts.inter(
                                color: const Color(0xFFBDBDBD),
                                fontSize: 12.5,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF5FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'MRU',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF1E6BE6),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF424242),
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
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
                              final name = nameCtrl.text.trim();
                              final price = priceCtrl.text.trim();
                              if (name.isNotEmpty && price.isNotEmpty) {
                                setState(() {
                                  if (editingItem != null && index != null) {
                                    _addons[index] = AddonPricingItem(
                                      name: name,
                                      rate: price,
                                      unit: currentUnit,
                                    );
                                  } else {
                                    _addons.add(AddonPricingItem(
                                      name: name,
                                      rate: price,
                                      unit: currentUnit,
                                    ));
                                  }
                                });
                                Navigator.pop(ctx);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AddServiceView._orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              editingItem != null ? 'Save Add-on' : 'Add Add-on',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRequestServiceTypeSheet() {
    final typeCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.add_rounded,
                    color: AddServiceView._orange,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Request New Service Type',
                    style: GoogleFonts.inter(
                      color: AddServiceView._ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Service Type Name',
                style: GoogleFonts.inter(
                  color: const Color(0xFF616161),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: typeCtrl,
                style: GoogleFonts.inter(fontSize: 13, color: AddServiceView._ink),
                decoration: InputDecoration(
                  hintText: 'Enter service type',
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFFBDBDBD),
                    fontSize: 12.5,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7F7F8),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Reason / Description',
                style: GoogleFonts.inter(
                  color: const Color(0xFF616161),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: reasonCtrl,
                minLines: 3,
                maxLines: 4,
                style: GoogleFonts.inter(fontSize: 13, color: AddServiceView._ink),
                decoration: InputDecoration(
                  hintText: 'Briefly describe why you need this service type',
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFFBDBDBD),
                    fontSize: 12.5,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7F7F8),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                              'Cancel',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF424242),
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
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
                          final requested = typeCtrl.text.trim();
                          if (requested.isNotEmpty) {
                            if (!_serviceTypes.contains(requested)) {
                              setState(() {
                                _serviceTypes.add(requested);
                                _selectedServiceType = requested;
                              });
                            }
                          }
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AddServiceView._orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'Submit Request',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 260,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFE8DC),
                      Color(0xFFFFF3EC),
                      Color(0xFFFFFFFF),
                    ],
                    stops: [0, 0.45, 1],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            widget.initialService != null ? 'Edit Service' : 'Add Service',
                            style: GoogleFonts.inter(
                              color: AddServiceView._ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.maybePop(context);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFFE0D0)),
                                ),
                                child: const Icon(
                                  Icons.chevron_left_rounded,
                                  color: AddServiceView._orange,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                      children: [
                        Text(
                          'Service Image',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF424242),
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickImage,
                          child: CustomPaint(
                            painter: const _DashedBorderPainter(
                              color: Color(0xFFFFCCBC),
                              radius: 16,
                            ),
                            child: Container(
                              height: 125,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8F5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _pickedImage != null
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.file(
                                          _pickedImage!,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          right: 8,
                                          bottom: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.6),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Change Image',
                                              style: GoogleFonts.inter(color: Colors.white, fontSize: 11),
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
                                            color: Color(0xFFDCE9FF),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_outlined,
                                            color: AddServiceView._orange,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to upload image',
                                          style: GoogleFonts.inter(
                                            color: AddServiceView._ink,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'PNG, JPG up to 5MB',
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF9E9E9E),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildPropertyTypesCard(),
                        const SizedBox(height: 14),
                        _buildBasicInfoCard(),
                        if (_isCleaningService) ...[
                          const SizedBox(height: 14),
                          _buildCleaningProductsCard(),
                        ],
                        const SizedBox(height: 14),
                        _buildSpacePricingCard(),
                        if (_isCleaningService) ...[
                          const SizedBox(height: 14),
                          _buildAddonsCard(),
                        ],
                        if (_isPestControl) ...[
                          const SizedBox(height: 14),
                          _buildIssuesCoveredCard(),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _resetAll,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: const Color(0xFFF1F5F9),
                                foregroundColor: const Color(0xFF1E6BE6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Reset',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF1E6BE6),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: AddServiceView._orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Add Service',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPropertyTypesCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.home_outlined,
                color: AddServiceView._orange,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'PROPERTY TYPES',
                style: GoogleFonts.inter(
                  color: const Color(0xFF424242),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isApartmentSelected = !_isApartmentSelected);
                  },
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: _isApartmentSelected ? Colors.white : const Color(0xFFF7F7F8),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _isApartmentSelected ? AddServiceView._orange : const Color(0xFFE8E8E8),
                        width: _isApartmentSelected ? 1.2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.apartment,
                          size: 18,
                          color: _isApartmentSelected ? AddServiceView._orange : const Color(0xFF424242),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Apartment',
                          style: GoogleFonts.inter(
                            color: _isApartmentSelected ? AddServiceView._orange : const Color(0xFF424242),
                            fontWeight: _isApartmentSelected ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isVillaSelected = !_isVillaSelected);
                  },
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: _isVillaSelected ? Colors.white : const Color(0xFFF7F7F8),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _isVillaSelected ? AddServiceView._orange : const Color(0xFFE8E8E8),
                        width: _isVillaSelected ? 1.2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.holiday_village_outlined,
                          size: 18,
                          color: _isVillaSelected ? AddServiceView._orange : const Color(0xFF424242),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Villa',
                          style: GoogleFonts.inter(
                            color: _isVillaSelected ? AddServiceView._orange : const Color(0xFF424242),
                            fontWeight: _isVillaSelected ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AddServiceView._orange,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'BASIC INFORMATION',
                style: GoogleFonts.inter(
                  color: const Color(0xFF424242),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Service Type',
                style: GoogleFonts.inter(
                  color: const Color(0xFF616161),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _showRequestServiceTypeSheet,
                child: Text(
                  '+ Request New Service Type',
                  style: GoogleFonts.inter(
                    color: AddServiceView._orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedServiceType,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF757575)),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _selectedServiceType == 'Select Service'
                      ? const Color(0xFF757575)
                      : AddServiceView._ink,
                  fontWeight: FontWeight.w500,
                ),
                items: _serviceTypes
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedServiceType = val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Short Description',
            style: GoogleFonts.inter(
              color: const Color(0xFF616161),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _descriptionController,
            minLines: 3,
            maxLines: 4,
            style: GoogleFonts.inter(fontSize: 13, color: AddServiceView._ink),
            decoration: InputDecoration(
              hintText: 'Enter Description',
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFFBDBDBD),
                fontSize: 12.5,
              ),
              filled: true,
              fillColor: const Color(0xFFF7F7F8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleaningProductsCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cleaning_services_outlined,
                color: AddServiceView._orange,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'CLEANING PRODUCTS',
                style: GoogleFonts.inter(
                  color: const Color(0xFF424242),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _customerProvidesProducts = !_customerProvidesProducts),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _customerProvidesProducts ? Icons.check : Icons.circle_outlined,
                    color: AddServiceView._orange,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer provides products',
                          style: GoogleFonts.inter(
                            color: AddServiceView._ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Customer brings their own detergents, mop, and cleaning cloths.',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF757575),
                            fontWeight: FontWeight.w400,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _iProvideProducts = !_iProvideProducts),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _iProvideProducts ? Icons.check : Icons.circle_outlined,
                        color: AddServiceView._orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'I provide the products',
                              style: GoogleFonts.inter(
                                color: AddServiceView._ink,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Your team brings professional cleaning detergents, vacuums & cloths.',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF757575),
                                fontWeight: FontWeight.w400,
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Product Supply Fee',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF616161),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 110,
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFDCDCDC)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _supplyFeeController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AddServiceView._ink,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'MRU',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF757575),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacePricingCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.grid_view_rounded,
                color: AddServiceView._orange,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'SPACE PRICING',
                style: GoogleFonts.inter(
                  color: const Color(0xFF424242),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _spaces.length; i++) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F8F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _spaces[i].name,
                      style: GoogleFonts.inter(
                        color: AddServiceView._ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${_spaces[i].rate} ',
                            style: GoogleFonts.inter(
                              color: AddServiceView._ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: 'MRU/${_spaces[i].unit}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF757575),
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showAddSpaceDialog(editingItem: _spaces[i], index: i),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AddServiceView._orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
          GestureDetector(
            onTap: () => _showAddSpaceDialog(),
            child: CustomPaint(
              painter: const _DashedBorderPainter(
                color: Color(0xFFFFCCBC),
                radius: 12,
              ),
              child: Container(
                height: 44,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+ Add Space',
                  style: GoogleFonts.inter(
                    color: AddServiceView._orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddonsCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                color: AddServiceView._orange,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'ADD-ON SERVICES',
                style: GoogleFonts.inter(
                  color: const Color(0xFF424242),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _addons.length; i++) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F8F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _addons[i].name,
                      style: GoogleFonts.inter(
                        color: AddServiceView._ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${_addons[i].rate} ',
                            style: GoogleFonts.inter(
                              color: AddServiceView._ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          TextSpan(
                            text: 'MRU/${_addons[i].unit}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF757575),
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showAddAddonDialog(editingItem: _addons[i], index: i),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AddServiceView._orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
          GestureDetector(
            onTap: () => _showAddAddonDialog(),
            child: CustomPaint(
              painter: const _DashedBorderPainter(
                color: Color(0xFFFFCCBC),
                radius: 12,
              ),
              child: Container(
                height: 44,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+ Add Add-on',
                  style: GoogleFonts.inter(
                    color: AddServiceView._orange,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesCoveredCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ISSUES COVERED',
            style: GoogleFonts.inter(
              color: const Color(0xFF424242),
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildIssueItem(
                id: 'Cockroaches',
                label: 'Cockroaches',
                icon: const CustomPaint(
                  size: Size(22, 22),
                  painter: _CockroachPainter(),
                ),
              ),
              const SizedBox(width: 8),
              _buildIssueItem(
                id: 'Ants',
                label: 'Ants',
                icon: const CustomPaint(
                  size: Size(22, 22),
                  painter: _AntPainter(),
                ),
              ),
              const SizedBox(width: 8),
              _buildIssueItem(
                id: 'Bed Bugs',
                label: 'Bed Bugs',
                icon: const CustomPaint(
                  size: Size(22, 22),
                  painter: _BedBugPainter(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildIssueItem(
                id: 'Mosquitoes',
                label: 'Mosquitoes',
                icon: const CustomPaint(
                  size: Size(22, 22),
                  painter: _MosquitoPainter(),
                ),
              ),
              const SizedBox(width: 8),
              _buildIssueItem(
                id: 'Rodents',
                label: 'Rodents',
                icon: const CustomPaint(
                  size: Size(22, 22),
                  painter: _RodentPainter(),
                ),
              ),
              const SizedBox(width: 8),
              _buildIssueItem(
                id: 'Termites',
                label: 'Termites',
                icon: const CustomPaint(
                  size: Size(22, 22),
                  painter: _TermitePainter(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildIssueItem(
                id: 'General Sanitization',
                label: 'General\nSanitization',
                circleBg: const Color(0xFFDCE9FF),
                icon: const CustomPaint(
                  size: Size(22, 22),
                  painter: _SanitizationPainter(),
                ),
              ),
              const SizedBox(width: 8),
              _buildIssueItem(
                id: 'Flies',
                label: 'Flies',
                icon: const CustomPaint(
                  size: Size(22, 22),
                  painter: _FlyPainter(),
                ),
              ),
              const SizedBox(width: 8),
              _buildIssueItem(
                id: 'Other Pests',
                label: 'Other Pests',
                icon: const CustomPaint(
                  size: Size(22, 22),
                  painter: _OtherPestsPainter(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIssueItem({
    required String id,
    required String label,
    required Widget icon,
    Color circleBg = const Color(0xFFEFF4FC),
  }) {
    final bool isSelected = _selectedIssues.contains(id);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            if (isSelected) {
              _selectedIssues.remove(id);
            } else {
              _selectedIssues.add(id);
            }
          });
        },
        child: Container(
          height: 98,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF9F5) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AddServiceView._orange : const Color(0xFFEEEEEE),
              width: isSelected ? 1.2 : 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: circleBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: icon,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: isSelected ? AddServiceView._orange : const Color(0xFF2D3748),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 10.5,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CockroachPainter extends CustomPainter {
  const _CockroachPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintBody = Paint()
      ..color = const Color(0xFF532B1D)
      ..style = PaintingStyle.fill;

    final paintDark = Paint()
      ..color = const Color(0xFF3E1D11)
      ..style = PaintingStyle.fill;

    final paintLegs = Paint()
      ..color = const Color(0xFF4A2514)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final antPath = Path()
      ..moveTo(w * 0.44, h * 0.22)
      ..quadraticBezierTo(w * 0.35, h * 0.08, w * 0.22, h * 0.05)
      ..moveTo(w * 0.56, h * 0.22)
      ..quadraticBezierTo(w * 0.65, h * 0.08, w * 0.78, h * 0.05);
    canvas.drawPath(antPath, paintLegs);

    final legPath = Path()
      ..moveTo(w * 0.36, h * 0.35)
      ..lineTo(w * 0.18, h * 0.26)
      ..lineTo(w * 0.14, h * 0.32)
      ..moveTo(w * 0.64, h * 0.35)
      ..lineTo(w * 0.82, h * 0.26)
      ..lineTo(w * 0.86, h * 0.32)
      ..moveTo(w * 0.34, h * 0.50)
      ..lineTo(w * 0.14, h * 0.48)
      ..lineTo(w * 0.10, h * 0.58)
      ..moveTo(w * 0.66, h * 0.50)
      ..lineTo(w * 0.86, h * 0.48)
      ..lineTo(w * 0.90, h * 0.58)
      ..moveTo(w * 0.36, h * 0.68)
      ..lineTo(w * 0.16, h * 0.76)
      ..lineTo(w * 0.12, h * 0.92)
      ..moveTo(w * 0.64, h * 0.68)
      ..lineTo(w * 0.84, h * 0.76)
      ..lineTo(w * 0.88, h * 0.92);
    canvas.drawPath(legPath, paintLegs);

    final bodyRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.58),
      width: w * 0.38,
      height: h * 0.54,
    );
    canvas.drawOval(bodyRect, paintBody);

    final seamPaint = Paint()
      ..color = const Color(0xFF2C140A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(w * 0.5, h * 0.34), Offset(w * 0.5, h * 0.85), seamPaint);

    final shieldRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.32),
      width: w * 0.34,
      height: h * 0.22,
    );
    canvas.drawOval(shieldRect, paintDark);

    canvas.drawCircle(Offset(w * 0.5, h * 0.22), w * 0.08, paintDark);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AntPainter extends CustomPainter {
  const _AntPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintDark = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.fill;

    final paintLegs = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final antPath = Path()
      ..moveTo(w * 0.45, h * 0.22)
      ..lineTo(w * 0.32, h * 0.10)
      ..lineTo(w * 0.22, h * 0.12)
      ..moveTo(w * 0.55, h * 0.22)
      ..lineTo(w * 0.68, h * 0.10)
      ..lineTo(w * 0.78, h * 0.12);
    canvas.drawPath(antPath, paintLegs);

    final legPath = Path()
      ..moveTo(w * 0.40, h * 0.42)
      ..lineTo(w * 0.20, h * 0.32)
      ..lineTo(w * 0.16, h * 0.40)
      ..moveTo(w * 0.60, h * 0.42)
      ..lineTo(w * 0.80, h * 0.32)
      ..lineTo(w * 0.84, h * 0.40)
      ..moveTo(w * 0.40, h * 0.50)
      ..lineTo(w * 0.16, h * 0.52)
      ..lineTo(w * 0.12, h * 0.62)
      ..moveTo(w * 0.60, h * 0.50)
      ..lineTo(w * 0.84, h * 0.52)
      ..lineTo(w * 0.88, h * 0.62)
      ..moveTo(w * 0.42, h * 0.56)
      ..lineTo(w * 0.22, h * 0.68)
      ..lineTo(w * 0.18, h * 0.82)
      ..moveTo(w * 0.58, h * 0.56)
      ..lineTo(w * 0.78, h * 0.68)
      ..lineTo(w * 0.82, h * 0.82);
    canvas.drawPath(legPath, paintLegs);

    canvas.drawCircle(Offset(w * 0.5, h * 0.24), w * 0.09, paintDark);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.46), width: w * 0.14, height: h * 0.22),
      paintDark,
    );

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.74), width: w * 0.26, height: h * 0.32),
      paintDark,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BedBugPainter extends CustomPainter {
  const _BedBugPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintBody = Paint()
      ..color = const Color(0xFF7A2518)
      ..style = PaintingStyle.fill;

    final paintDark = Paint()
      ..color = const Color(0xFF551910)
      ..style = PaintingStyle.fill;

    final paintLegs = Paint()
      ..color = const Color(0xFF6B2014)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final antPath = Path()
      ..moveTo(w * 0.44, h * 0.22)
      ..lineTo(w * 0.30, h * 0.10)
      ..moveTo(w * 0.56, h * 0.22)
      ..lineTo(w * 0.70, h * 0.10);
    canvas.drawPath(antPath, paintLegs);

    final legPath = Path()
      ..moveTo(w * 0.34, h * 0.34)
      ..lineTo(w * 0.16, h * 0.26)
      ..lineTo(w * 0.12, h * 0.32)
      ..moveTo(w * 0.66, h * 0.34)
      ..lineTo(w * 0.84, h * 0.26)
      ..lineTo(w * 0.88, h * 0.32)
      ..moveTo(w * 0.30, h * 0.48)
      ..lineTo(w * 0.12, h * 0.48)
      ..lineTo(w * 0.08, h * 0.58)
      ..moveTo(w * 0.70, h * 0.48)
      ..lineTo(w * 0.88, h * 0.48)
      ..lineTo(w * 0.92, h * 0.58)
      ..moveTo(w * 0.32, h * 0.64)
      ..lineTo(w * 0.16, h * 0.72)
      ..lineTo(w * 0.12, h * 0.86)
      ..moveTo(w * 0.68, h * 0.64)
      ..lineTo(w * 0.84, h * 0.72)
      ..lineTo(w * 0.88, h * 0.86);
    canvas.drawPath(legPath, paintLegs);

    final abRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.58),
      width: w * 0.44,
      height: h * 0.48,
    );
    canvas.drawOval(abRect, paintBody);

    final stripePaint = Paint()
      ..color = const Color(0xFF4E160E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(w * 0.32, h * 0.50), Offset(w * 0.68, h * 0.50), stripePaint);
    canvas.drawLine(Offset(w * 0.30, h * 0.60), Offset(w * 0.70, h * 0.60), stripePaint);
    canvas.drawLine(Offset(w * 0.34, h * 0.70), Offset(w * 0.66, h * 0.70), stripePaint);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.32), width: w * 0.32, height: h * 0.16),
      paintDark,
    );

    canvas.drawCircle(Offset(w * 0.5, h * 0.22), w * 0.08, paintDark);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MosquitoPainter extends CustomPainter {
  const _MosquitoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintDark = Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    final paintWing = Paint()
      ..color = const Color(0x6694A3B8)
      ..style = PaintingStyle.fill;

    canvas.drawLine(Offset(w * 0.5, h * 0.20), Offset(w * 0.5, h * 0.08), paintStroke);
    canvas.drawLine(Offset(w * 0.48, h * 0.20), Offset(w * 0.36, h * 0.12), paintStroke);
    canvas.drawLine(Offset(w * 0.52, h * 0.20), Offset(w * 0.64, h * 0.12), paintStroke);

    final leftWing = Path()
      ..moveTo(w * 0.48, h * 0.36)
      ..quadraticBezierTo(w * 0.14, h * 0.38, w * 0.20, h * 0.56)
      ..quadraticBezierTo(w * 0.36, h * 0.52, w * 0.48, h * 0.42);
    canvas.drawPath(leftWing, paintWing);
    canvas.drawPath(leftWing, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 0.8);

    final rightWing = Path()
      ..moveTo(w * 0.52, h * 0.36)
      ..quadraticBezierTo(w * 0.86, h * 0.38, w * 0.80, h * 0.56)
      ..quadraticBezierTo(w * 0.64, h * 0.52, w * 0.52, h * 0.42);
    canvas.drawPath(rightWing, paintWing);
    canvas.drawPath(rightWing, Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 0.8);

    final legPath = Path()
      ..moveTo(w * 0.46, h * 0.34)
      ..lineTo(w * 0.18, h * 0.26)
      ..lineTo(w * 0.10, h * 0.36)
      ..moveTo(w * 0.54, h * 0.34)
      ..lineTo(w * 0.82, h * 0.26)
      ..lineTo(w * 0.90, h * 0.36)
      ..moveTo(w * 0.46, h * 0.40)
      ..lineTo(w * 0.14, h * 0.48)
      ..lineTo(w * 0.08, h * 0.62)
      ..moveTo(w * 0.54, h * 0.40)
      ..lineTo(w * 0.86, h * 0.48)
      ..lineTo(w * 0.92, h * 0.62)
      ..moveTo(w * 0.48, h * 0.46)
      ..lineTo(w * 0.22, h * 0.70)
      ..lineTo(w * 0.14, h * 0.88)
      ..moveTo(w * 0.52, h * 0.46)
      ..lineTo(w * 0.78, h * 0.70)
      ..lineTo(w * 0.86, h * 0.88);
    canvas.drawPath(legPath, paintStroke);

    canvas.drawCircle(Offset(w * 0.5, h * 0.22), w * 0.06, paintDark);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.36), width: w * 0.12, height: h * 0.18),
      paintDark,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.64), width: w * 0.09, height: h * 0.36),
      paintDark,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RodentPainter extends CustomPainter {
  const _RodentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintBody = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final body = Path()
      ..moveTo(w * 0.68, h * 0.44)
      ..quadraticBezierTo(w * 0.56, h * 0.32, w * 0.50, h * 0.36)
      ..quadraticBezierTo(w * 0.48, h * 0.24, w * 0.42, h * 0.30)
      ..quadraticBezierTo(w * 0.42, h * 0.38, w * 0.40, h * 0.42)
      ..quadraticBezierTo(w * 0.24, h * 0.42, w * 0.22, h * 0.58)
      ..quadraticBezierTo(w * 0.22, h * 0.74, w * 0.36, h * 0.72)
      ..quadraticBezierTo(w * 0.50, h * 0.70, w * 0.62, h * 0.58)
      ..close();
    canvas.drawPath(body, paintBody);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.48, h * 0.30), width: w * 0.08, height: h * 0.12),
      paintBody,
    );

    final tail = Path()
      ..moveTo(w * 0.22, h * 0.64)
      ..cubicTo(w * 0.10, h * 0.66, w * 0.14, h * 0.42, w * 0.24, h * 0.32)
      ..cubicTo(w * 0.28, h * 0.26, w * 0.24, h * 0.20, w * 0.18, h * 0.22);
    canvas.drawPath(tail, paintStroke);

    canvas.drawCircle(Offset(w * 0.58, h * 0.42), w * 0.025, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TermitePainter extends CustomPainter {
  const _TermitePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintBody = Paint()
      ..color = const Color(0xFF9E5B2B)
      ..style = PaintingStyle.fill;

    final paintHead = Paint()
      ..color = const Color(0xFF6E3917)
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = const Color(0xFF6E3917)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.46, h * 0.22), Offset(w * 0.36, h * 0.10), paintStroke);
    canvas.drawLine(Offset(w * 0.54, h * 0.22), Offset(w * 0.64, h * 0.10), paintStroke);

    final legPath = Path()
      ..moveTo(w * 0.40, h * 0.36)
      ..lineTo(w * 0.22, h * 0.28)
      ..lineTo(w * 0.18, h * 0.36)
      ..moveTo(w * 0.60, h * 0.36)
      ..lineTo(w * 0.78, h * 0.28)
      ..lineTo(w * 0.82, h * 0.36)
      ..moveTo(w * 0.40, h * 0.48)
      ..lineTo(w * 0.18, h * 0.48)
      ..lineTo(w * 0.14, h * 0.58)
      ..moveTo(w * 0.60, h * 0.48)
      ..lineTo(w * 0.82, h * 0.48)
      ..lineTo(w * 0.86, h * 0.58)
      ..moveTo(w * 0.42, h * 0.62)
      ..lineTo(w * 0.24, h * 0.70)
      ..lineTo(w * 0.20, h * 0.82)
      ..moveTo(w * 0.58, h * 0.62)
      ..lineTo(w * 0.76, h * 0.70)
      ..lineTo(w * 0.80, h * 0.82);
    canvas.drawPath(legPath, paintStroke);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.24), width: w * 0.22, height: h * 0.20),
      paintHead,
    );

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.44), width: w * 0.20, height: h * 0.18),
      paintBody,
    );

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.68), width: w * 0.26, height: h * 0.36),
      paintBody,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SanitizationPainter extends CustomPainter {
  const _SanitizationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final shield = Path()
      ..moveTo(w * 0.5, h * 0.18)
      ..lineTo(w * 0.80, h * 0.28)
      ..lineTo(w * 0.80, h * 0.56)
      ..cubicTo(w * 0.80, h * 0.76, w * 0.54, h * 0.88, w * 0.5, h * 0.92)
      ..cubicTo(w * 0.46, h * 0.88, w * 0.20, h * 0.76, w * 0.20, h * 0.56)
      ..lineTo(w * 0.20, h * 0.28)
      ..close();

    final paintShield = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shield, paintShield);

    final check = Path()
      ..moveTo(w * 0.36, h * 0.52)
      ..lineTo(w * 0.46, h * 0.62)
      ..lineTo(w * 0.64, h * 0.42);

    final paintCheck = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(check, paintCheck);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FlyPainter extends CustomPainter {
  const _FlyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintDark = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.fill;

    final paintEyes = Paint()
      ..color = const Color(0xFF7F1D1D)
      ..style = PaintingStyle.fill;

    final paintWing = Paint()
      ..color = const Color(0x6694A3B8)
      ..style = PaintingStyle.fill;

    final paintWingStroke = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final paintStroke = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    final legPath = Path()
      ..moveTo(w * 0.36, h * 0.40)
      ..lineTo(w * 0.16, h * 0.30)
      ..lineTo(w * 0.12, h * 0.38)
      ..moveTo(w * 0.64, h * 0.40)
      ..lineTo(w * 0.84, h * 0.30)
      ..lineTo(w * 0.88, h * 0.38)
      ..moveTo(w * 0.34, h * 0.52)
      ..lineTo(w * 0.12, h * 0.52)
      ..lineTo(w * 0.08, h * 0.62)
      ..moveTo(w * 0.66, h * 0.52)
      ..lineTo(w * 0.88, h * 0.52)
      ..lineTo(w * 0.92, h * 0.62)
      ..moveTo(w * 0.38, h * 0.64)
      ..lineTo(w * 0.18, h * 0.74)
      ..lineTo(w * 0.14, h * 0.86)
      ..moveTo(w * 0.62, h * 0.64)
      ..lineTo(w * 0.82, h * 0.74)
      ..lineTo(w * 0.86, h * 0.86);
    canvas.drawPath(legPath, paintStroke);

    final leftWing = Path()
      ..moveTo(w * 0.44, h * 0.38)
      ..quadraticBezierTo(w * 0.16, h * 0.34, w * 0.22, h * 0.66)
      ..quadraticBezierTo(w * 0.38, h * 0.62, w * 0.44, h * 0.48);
    canvas.drawPath(leftWing, paintWing);
    canvas.drawPath(leftWing, paintWingStroke);

    final rightWing = Path()
      ..moveTo(w * 0.56, h * 0.38)
      ..quadraticBezierTo(w * 0.84, h * 0.34, w * 0.78, h * 0.66)
      ..quadraticBezierTo(w * 0.62, h * 0.62, w * 0.56, h * 0.48);
    canvas.drawPath(rightWing, paintWing);
    canvas.drawPath(rightWing, paintWingStroke);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.42), width: w * 0.22, height: h * 0.20),
      paintDark,
    );

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.64), width: w * 0.24, height: h * 0.30),
      paintDark,
    );

    canvas.drawCircle(Offset(w * 0.5, h * 0.26), w * 0.08, paintDark);
    canvas.drawCircle(Offset(w * 0.44, h * 0.24), w * 0.04, paintEyes);
    canvas.drawCircle(Offset(w * 0.56, h * 0.24), w * 0.04, paintEyes);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OtherPestsPainter extends CustomPainter {
  const _OtherPestsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintCircle = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.36, paintCircle);

    final paintArrow = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawLine(Offset(w * 0.38, h * 0.62), Offset(w * 0.60, h * 0.40), paintArrow);

    final head = Path()
      ..moveTo(w * 0.46, h * 0.40)
      ..lineTo(w * 0.60, h * 0.40)
      ..lineTo(w * 0.60, h * 0.54);
    canvas.drawPath(head, paintArrow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  static const double _strokeWidth = 1.2;
  static const double _dashWidth = 5.0;
  static const double _dashSpace = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        _strokeWidth / 2,
        _strokeWidth / 2,
        size.width - _strokeWidth,
        size.height - _strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = (distance + _dashWidth < metric.length)
            ? _dashWidth
            : metric.length - distance;
        final extractPath = metric.extractPath(distance, distance + len);
        canvas.drawPath(extractPath, paint);
        distance += _dashWidth + _dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
