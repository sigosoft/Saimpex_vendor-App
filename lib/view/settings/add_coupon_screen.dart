import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/localization_service.dart';
import 'package:saimpex_vendor/controller/coupon_controller.dart';
import '../../utils/utils.dart';

class AddCouponScreen extends StatefulWidget {
  final Map<String, dynamic>? couponData;
  const AddCouponScreen({super.key, this.couponData});

  @override
  State<AddCouponScreen> createState() => _AddCouponScreenState();
}

class _AddCouponScreenState extends State<AddCouponScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _discountController = TextEditingController();
  final _countController = TextEditingController();
  final _validUptoController = TextEditingController();

  String? _selectedType;
  final List<String> _couponTypes = ['Percentage', 'Amount'];

  @override
  void initState() {
    super.initState();
    if (widget.couponData != null) {
      _nameController.text =
          widget.couponData!['name_en']?.toString() ??
          widget.couponData!['name']?.toString() ??
          '';
      _codeController.text = widget.couponData!['code']?.toString() ?? '';

      // Handle type selection
      String? type = widget.couponData!['type']?.toString();
      if (type != null) {
        if (type == '2' || type.toUpperCase() == 'PERCENTAGE') {
          _selectedType = 'Percentage';
        } else if (type == '1' ||
            type.toUpperCase() == 'AMOUNT' ||
            type.toUpperCase() == 'FIXED' ||
            type.toUpperCase() == 'FIXED_AMOUNT') {
          _selectedType = 'Amount';
        }
      }

      // Handle discount
      _discountController.text =
          widget.couponData!['discount_value']?.toString() ??
          widget.couponData!['discount']?.toString() ??
          '';
      // Clean up percentage symbol if needed
      if (_discountController.text.contains('%')) {
        _discountController.text = _discountController.text
            .replaceAll('%', '')
            .trim();
      }

      _countController.text = widget.couponData!['count']?.toString() ?? '';

      // Handle date formatting (convert yyyy-mm-dd to dd-mm-yyyy)
      String validUpto = widget.couponData!['valid_upto']?.toString() ?? '';
      if (validUpto.contains('-') && validUpto.split('-').first.length == 4) {
        List<String> parts = validUpto.split('-');
        if (parts.length == 3) {
          _validUptoController.text = "${parts[2]}-${parts[1]}-${parts[0]}";
        }
      } else {
        _validUptoController.text = validUpto;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isEdit = widget.couponData != null;

    return Directionality(
      textDirection: LocalizationService().getTextDirection(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF7F3),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 40,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          title: Text(
            isEdit ? S.of(context).updateCoupon : S.of(context).addCoupon,
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel(S.of(context).couponName),
                const SizedBox(height: 8),
                _buildTextField(_nameController, S.of(context).enterCouponName),
                const SizedBox(height: 16),
                _buildLabel(S.of(context).couponCode),
                const SizedBox(height: 8),
                _buildTextField(_codeController, S.of(context).enterCouponCode),
                const SizedBox(height: 16),
                _buildLabel(S.of(context).couponType),
                const SizedBox(height: 8),
                _buildDropdown(),
                const SizedBox(height: 16),
                _buildLabel(S.of(context).discount),
                const SizedBox(height: 8),
                _buildTextField(
                  _discountController,
                  S.of(context).enterDiscount,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildLabel(S.of(context).countLabel),
                const SizedBox(height: 8),
                _buildTextField(
                  _countController,
                  S.of(context).enterCount,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildLabel(S.of(context).validUptoLabel),
                const SizedBox(height: 8),
                _buildDatePickerField(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.05,
            10,
            screenWidth * 0.05,
            MediaQuery.of(context).padding.bottom + 20,
          ),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      // Light grey
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      S.of(context).cancel,
                      style: GoogleFonts.rubik(
                        color: const Color(0xFF374151),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedType == null) {
                          final ctx = Get.overlayContext ?? Get.context;
                          if (ctx != null) {
                            showToast(
                              ctx,
                              S.of(context).pleaseSelectCouponType,
                            );
                          }
                          return;
                        }

                        final couponController =
                            Get.isRegistered<CouponController>()
                            ? Get.find<CouponController>()
                            : Get.put(CouponController());

                        if (!isEdit) {
                          // Format date from dd-mm-yyyy to yyyy-mm-dd for API
                          String validUpto = _validUptoController.text;
                          if (validUpto.contains('-')) {
                            List<String> parts = validUpto.split('-');
                            if (parts.length == 3) {
                              validUpto = "${parts[2]}-${parts[1]}-${parts[0]}";
                            }
                          }

                          couponController.addCoupon(
                            context: context,
                            name: _nameController.text,
                            code: _codeController.text,
                            type: _selectedType == 'Percentage' ? 2 : 1,
                            discountValue: _discountController.text,
                            count: _countController.text,
                            validUpto: validUpto,
                          );
                        } else {
                          // Format date from dd-mm-yyyy to yyyy-mm-dd for API
                          String validUpto = _validUptoController.text;
                          if (validUpto.contains('-')) {
                            List<String> parts = validUpto.split('-');
                            if (parts.length == 3) {
                              validUpto = "${parts[2]}-${parts[1]}-${parts[0]}";
                            }
                          }

                          couponController.updateCoupon(
                            context: context,
                            couponId:
                                int.tryParse(
                                  widget.couponData!['id']?.toString() ?? '0',
                                ) ??
                                0,
                            name: _nameController.text,
                            code: _codeController.text,
                            type: _selectedType == 'Percentage' ? 2 : 1,
                            discountValue: _discountController.text,
                            count: _countController.text,
                            validUpto: validUpto,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isEdit
                          ? S.of(context).updateCoupon
                          : S.of(context).addCoupon,
                      style: GoogleFonts.rubik(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.rubik(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.rubik(fontSize: 14, color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.rubik(
          fontSize: 13,
          color: const Color(0xFF9CA3AF),
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5216), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          hint: Text(
            S.of(context).select,
            style: GoogleFonts.rubik(
              fontSize: 13,
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w400,
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF)),
          items: _couponTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(
                type == 'Percentage'
                    ? S.of(context).percentage
                    : S.of(context).amount,
                style: GoogleFonts.rubik(fontSize: 14, color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedType = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return TextFormField(
      controller: _validUptoController,
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(
                context,
              ).copyWith(colorScheme: ColorScheme.light(primary: colorPrimary)),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          setState(() {
            _validUptoController.text =
                "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
          });
        }
      },
      style: GoogleFonts.rubik(fontSize: 14, color: Colors.black),
      decoration: InputDecoration(
        hintText: 'dd-mm-yyyy',
        hintStyle: GoogleFonts.rubik(
          fontSize: 13,
          color: const Color(0xFF9CA3AF),
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: const Icon(
          Icons.calendar_month_outlined,
          color: Color(0xFF1F2937),
          size: 22,
        ),
      ),
    );
  }
}
