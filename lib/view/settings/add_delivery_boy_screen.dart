import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/delivery_boys_model.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class AddDeliveryBoyScreen extends StatefulWidget {
  const AddDeliveryBoyScreen({super.key, this.deliveryBoy});

  final DeliveryBoy? deliveryBoy;

  @override
  State<AddDeliveryBoyScreen> createState() => _AddDeliveryBoyScreenState();
}

class _AddDeliveryBoyScreenState extends State<AddDeliveryBoyScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal controllers
  final _nameController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '+222');
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _licenseController = TextEditingController();

  // Salary & Bank controllers
  final _salaryController = TextEditingController();
  final _countryController = TextEditingController(text: 'Mauritania');
  final _bankNameController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();

  String? _selectedGender = 'Male';
  final List<String> _genderOptions = ['Male', 'Female'];

  File? _imageFile;
  File? _idProofFile;
  String? _existingImageUrl;
  String? _existingIdProofUrl;
  bool _isSubmitting = false;

  bool get _isEditing => widget.deliveryBoy != null;

  @override
  void initState() {
    super.initState();
    if (widget.deliveryBoy != null) {
      final b = widget.deliveryBoy!;
      final raw = b.rawJson ?? {};
      _nameController.text = b.name ?? raw['name']?.toString() ?? '';
      _countryCodeController.text =
          b.countryCode ?? raw['country_code']?.toString() ?? '+222';
      _mobileController.text = b.mobile ?? raw['mobile']?.toString() ?? '';
      _emailController.text = b.email ?? raw['email']?.toString() ?? '';
      _addressController.text = b.address ?? raw['address']?.toString() ?? '';
      _licenseController.text =
          b.licenseNumber ?? raw['license_number']?.toString() ?? '';
      _salaryController.text = b.monthlySalary ??
          raw['monthly_salary']?.toString() ??
          raw['salary']?.toString() ??
          '';
      _countryController.text =
          b.country ?? raw['country']?.toString() ?? 'Mauritania';
      _bankNameController.text =
          b.bankName ?? raw['bank_name']?.toString() ?? '';
      _accountHolderController.text =
          b.accountHolderName ?? raw['account_holder_name']?.toString() ?? '';
      _accountNumberController.text =
          b.accountNumber ?? raw['account_number']?.toString() ?? '';
      _ifscController.text = b.ifscCode ?? raw['ifsc_code']?.toString() ?? '';

      final g = b.gender ?? int.tryParse(raw['gender']?.toString() ?? '');
      if (g == 2) {
        _selectedGender = 'Female';
      } else {
        _selectedGender = 'Male';
      }

      _existingImageUrl = b.image ?? raw['image']?.toString();
      _existingIdProofUrl = b.idProof ?? raw['id_proof']?.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryCodeController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _licenseController.dispose();
    _salaryController.dispose();
    _countryController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool isProfile}) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: colorPrimary),
                title: Text(
                  'Take Photo',
                  style: GoogleFonts.rubik(fontWeight: FontWeight.w500),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: colorPrimary),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.rubik(fontWeight: FontWeight.w500),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;
    try {
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        setState(() {
          if (isProfile) {
            _imageFile = File(picked.path);
          } else {
            _idProofFile = File(picked.path);
          }
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  String _getDeliveryBoyUrl() {
    final rawBase = ApiConfigs.BASE_URL.trim();
    String base = rawBase.endsWith('/') ? rawBase.substring(0, rawBase.length - 1) : rawBase;
    String endpoint = _isEditing
        ? ApiEndPoints.pharmacyUpdateDeliveryBoy.trim()
        : ApiEndPoints.pharmacyAddDeliveryBoys.trim();
    final cleanEndpoint = endpoint.replaceFirst(RegExp(r'^/'), '');
    return '$base/$cleanEndpoint';
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final countryCode = _countryCodeController.text.trim();
    final mobile = _mobileController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();
    final monthlySalary = _salaryController.text.trim();
    final bankName = _bankNameController.text.trim();
    final accountHolderName = _accountHolderController.text.trim();
    final accountNumber = _accountNumberController.text.trim();
    final ifscCode = _ifscController.text.trim();
    final country = _countryController.text.trim();
    final licenseNumber = _licenseController.text.trim();

    if (name.isEmpty) {
      showToast(context, 'Please enter name');
      return;
    }
    if (name.length < 3) {
      showToast(context, 'Name must be at least 3 characters');
      return;
    }
    if (countryCode.isEmpty) {
      showToast(context, 'Please enter country code');
      return;
    }
    if (mobile.isEmpty) {
      showToast(context, 'Please enter mobile number');
      return;
    }
    if (email.isEmpty) {
      showToast(context, 'Please enter email');
      return;
    }
    if (_selectedGender == null) {
      showToast(context, 'Please select gender');
      return;
    }
    if (address.isEmpty) {
      showToast(context, 'Please enter address');
      return;
    }
    if (address.length < 3) {
      showToast(context, 'Address must be at least 3 characters');
      return;
    }
    if (!_isEditing && _imageFile == null) {
      showToast(context, 'Please select profile image');
      return;
    }
    if (!_isEditing && _idProofFile == null) {
      showToast(context, 'Please select ID proof');
      return;
    }
    if (monthlySalary.isEmpty) {
      showToast(context, 'Please enter monthly salary');
      return;
    }
    if (bankName.isEmpty) {
      showToast(context, 'Please enter bank name');
      return;
    }
    if (accountHolderName.isEmpty) {
      showToast(context, 'Please enter account holder name');
      return;
    }
    if (accountNumber.isEmpty) {
      showToast(context, 'Please enter account number');
      return;
    }
    if (ifscCode.isEmpty) {
      showToast(context, 'Please enter IFSC code');
      return;
    }
    if (country.isEmpty) {
      showToast(context, 'Please enter country');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await getSavedObject("token");
      if (token != null && token.toString().isNotEmpty) {
        DioClient().updateToken(token.toString());
      }

      final genderVal = _selectedGender == 'Female' ? '2' : '1';

      final Map<String, dynamic> formMap = {
        "name": name,
        "country_code": countryCode,
        "gender": genderVal,
        "address": address,
        "account_holder_name": accountHolderName,
        "country": country,
        "bank_name": bankName,
        "monthly_salary": monthlySalary,
        "mobile": mobile,
        "email": email,
        "account_number": accountNumber,
        "ifsc_code": ifscCode,
        "license_number": licenseNumber,
      };

      if (_isEditing) {
        final userId = widget.deliveryBoy?.id ??
            widget.deliveryBoy?.rawJson?['id'] ??
            widget.deliveryBoy?.rawJson?['user_id'];
        if (userId != null) {
          formMap["user_id"] = userId.toString();
        }
      }

      if (_imageFile != null) {
        final imgName = _imageFile!.path.split(RegExp(r'[/\\]')).last;
        formMap["image"] = await MultipartFile.fromFile(
          _imageFile!.path,
          filename: imgName,
        );
      }

      if (_idProofFile != null) {
        final idName = _idProofFile!.path.split(RegExp(r'[/\\]')).last;
        formMap["id_proof"] = await MultipartFile.fromFile(
          _idProofFile!.path,
          filename: idName,
        );
      }

      final formData = FormData.fromMap(formMap);
      final url = _getDeliveryBoyUrl();
      final endpoint = _isEditing
          ? ApiEndPoints.pharmacyUpdateDeliveryBoy
          : ApiEndPoints.pharmacyAddDeliveryBoys;
      final actionLabel = _isEditing ? "UPDATE" : "ADD";

      debugPrint("==================== POST $actionLabel DELIVERY BOY ====================");
      debugPrint("API Call: POST $url");
      debugPrint("Endpoint: $endpoint");
      debugPrint("FormData fields: user_id: ${formMap['user_id']}, name: $name, country_code: $countryCode, mobile: $mobile, email: $email, gender: $genderVal, address: $address, salary: $monthlySalary, bank: $bankName, account: $accountNumber, ifsc: $ifscCode, holder: $accountHolderName, country: $country, license: $licenseNumber, image: ${_imageFile?.path}, id_proof: ${_idProofFile?.path}");

      print("==================== POST $actionLabel DELIVERY BOY ====================");
      print("API Call: POST $url");
      print("Endpoint: $endpoint");
      print("FormData fields: user_id: ${formMap['user_id']}, name: $name, country_code: $countryCode, mobile: $mobile, email: $email, gender: $genderVal, address: $address, salary: $monthlySalary, bank: $bankName, account: $accountNumber, ifsc: $ifscCode, holder: $accountHolderName, country: $country, license: $licenseNumber, image: ${_imageFile?.path}, id_proof: ${_idProofFile?.path}");

      final response = await DioClient().post(
        endpoint,
        body: formData,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("===============================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("===============================================================");

      final resData = response.data;
      final bool isSuccess = resData is Map &&
          (resData['status'] == true || resData['status'].toString() == 'true');

      if (isSuccess) {
        HapticFeedback.lightImpact();
        if (mounted) {
          final defaultMsg = _isEditing
              ? 'Delivery boy updated successfully'
              : 'Delivery boy added successfully';
          final message = resData['message']?.toString() ?? defaultMsg;
          try {
            showToast(context, message);
          } catch (_) {}
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          final defaultMsg = _isEditing
              ? 'Failed to update delivery boy'
              : 'Failed to add delivery boy';
          final message = resData is Map
              ? resData['message']?.toString() ?? defaultMsg
              : defaultMsg;
          try {
            showToast(context, message);
          } catch (_) {}
        }
      }
    } catch (e) {
      final actionLabel = _isEditing ? "UPDATE" : "ADD";
      debugPrint("==================== POST $actionLabel DELIVERY BOY ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("=====================================================================");

      print("==================== POST $actionLabel DELIVERY BOY ERROR ====================");
      print("Error: $e");
      print("=====================================================================");

      if (mounted) {
        try {
          showToast(context, e.toString());
        } catch (_) {}
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF333E63),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Update Delivery Boy' : 'Add Delivery Boy',
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF333E63),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(color: Colors.grey.withOpacity(0.1), height: 1),
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
              // Section: Personal Information
              _buildSectionHeader('Personal Information'),
              const SizedBox(height: 14),

              _buildLabel('Delivery Boy Name *'),
              const SizedBox(height: 8),
              _buildTextField(_nameController, 'Enter delivery boy name'),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Code *'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          _countryCodeController,
                          '+222',
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Mobile Number *'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          _mobileController,
                          'Enter mobile number',
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Email Address *'),
              const SizedBox(height: 8),
              _buildTextField(
                _emailController,
                'Enter email address',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildLabel('Gender *'),
              const SizedBox(height: 8),
              _buildGenderDropdown(),
              const SizedBox(height: 16),

              _buildLabel('Address *'),
              const SizedBox(height: 8),
              _buildTextField(
                _addressController,
                'Enter address',
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              _buildLabel('License Number (Optional)'),
              const SizedBox(height: 8),
              _buildTextField(_licenseController, 'Enter license number'),
              const SizedBox(height: 24),

              // Section: Documents
              _buildSectionHeader('Documents'),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildUploadCard(
                      label: 'Profile Photo *',
                      file: _imageFile,
                      existingUrl: _existingImageUrl,
                      onTap: () => _pickImage(isProfile: true),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildUploadCard(
                      label: 'ID Proof *',
                      file: _idProofFile,
                      existingUrl: _existingIdProofUrl,
                      onTap: () => _pickImage(isProfile: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section: Employment & Bank Information
              _buildSectionHeader('Employment & Bank Information'),
              const SizedBox(height: 14),

              _buildLabel('Monthly Salary *'),
              const SizedBox(height: 8),
              _buildTextField(
                _salaryController,
                'Enter monthly salary',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              _buildLabel('Country *'),
              const SizedBox(height: 8),
              _buildTextField(_countryController, 'Enter country'),
              const SizedBox(height: 16),

              _buildLabel('Bank Name *'),
              const SizedBox(height: 8),
              _buildTextField(_bankNameController, 'Enter bank name'),
              const SizedBox(height: 16),

              _buildLabel('Account Holder Name *'),
              const SizedBox(height: 8),
              _buildTextField(_accountHolderController, 'Enter account holder name'),
              const SizedBox(height: 16),

              _buildLabel('Account Number *'),
              const SizedBox(height: 8),
              _buildTextField(
                _accountNumberController,
                'Enter account number',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildLabel('IFSC Code *'),
              const SizedBox(height: 8),
              _buildTextField(_ifscController, 'Enter IFSC code'),
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
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Cancel',
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
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Update Delivery Boy' : 'Add Delivery Boy',
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.rubik(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.rubik(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF333E63),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
          borderSide: const BorderSide(color: colorPrimary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          isExpanded: true,
          items: _genderOptions
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String label,
    required File? file,
    String? existingUrl,
    required VoidCallback onTap,
  }) {
    final bool hasFile = file != null;
    final bool hasExisting =
        !hasFile && existingUrl != null && existingUrl.isNotEmpty;
    final bool isHighlighted = hasFile || hasExisting;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted ? colorPrimary : const Color(0xFFE5E7EB),
            width: isHighlighted ? 1.5 : 1.0,
          ),
        ),
        child: hasFile
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(
                      file,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.black.withOpacity(0.5),
                      child: Text(
                        'Change',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubik(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : hasExisting
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.network(
                          existingUrl.startsWith('http')
                              ? existingUrl
                              : ApiConfigs.IMAGE_URL + existingUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Center(
                            child:
                                Icon(Icons.person, color: Colors.grey, size: 40),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          color: Colors.black.withOpacity(0.5),
                          child: Text(
                            'Change',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rubik(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF0EB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_upload_outlined,
                          color: colorPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PNG, JPG up to 4MB',
                        style: GoogleFonts.rubik(
                          fontSize: 10,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
