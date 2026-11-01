import 'package:saimpex_vendor/resources/fonts.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/delivery_boys_model.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/widgets/app_loader.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;

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
  final _countryCodeController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _licenseController = TextEditingController();

  // Salary & Bank controllers
  final _salaryController = TextEditingController();
  final _countryController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();

  String? _selectedGender;
  final List<String> _genderOptions = ['Male', 'Female'];

  File? _imageFile;
  File? _idProofFile;
  String? _existingImageUrl;
  String? _existingIdProofUrl;
  String? _addedOnTime;
  bool _isSubmitting = false;
  bool _isLoadingDetails = false;

  bool get _isEditing => widget.deliveryBoy != null;

  String? _resolveVal(Map<String, dynamic> data, List<String> keys) {
    // 1. Direct keys on top-level
    for (final k in keys) {
      if (data.containsKey(k) && data[k] != null) {
        final val = data[k].toString().trim();
        if (val.isNotEmpty && val != 'null') return val;
      }
    }
    // 2. Check nested objects
    for (final containerKey in [
      'delivery_staff',
      'deliveryStaff',
      'delivery_boy',
      'deliveryBoy',
      'staff',
      'user',
      'bank_detail',
      'bank_details',
      'bank_info',
      'bank',
      'document',
      'documents',
    ]) {
      final container = data[containerKey];
      if (container is Map) {
        final subMap = Map<String, dynamic>.from(container);
        for (final k in keys) {
          if (subMap.containsKey(k) && subMap[k] != null) {
            final val = subMap[k].toString().trim();
            if (val.isNotEmpty && val != 'null') return val;
          }
        }
      }
    }
    return null;
  }

  void _safeMerge(Map<String, dynamic> target, Map<String, dynamic> source) {
    source.forEach((key, value) {
      if (value != null &&
          value.toString().trim().isNotEmpty &&
          value.toString().trim() != 'null') {
        target[key] = value;
      }
    });
  }

  void _populateFields(Map<String, dynamic> data) {
    final name = _resolveVal(data, [
      'name',
      'full_name',
      'delivery_boy_name',
      'delivery_staff_name',
      'username',
      'user_name',
    ]);
    if (name != null) _nameController.text = name;

    final code = _resolveVal(data, [
      'country_code',
      'countryCode',
      'phone_code',
      'dial_code',
      'code',
    ]);
    if (code != null) _countryCodeController.text = code;

    final mobile = _resolveVal(data, [
      'mobile',
      'phone',
      'mobile_number',
      'phone_number',
      'contact_number',
    ]);
    if (mobile != null) _mobileController.text = mobile;

    final email = _resolveVal(data, [
      'email',
      'email_address',
      'mail',
    ]);
    if (email != null) _emailController.text = email;

    final address = _resolveVal(data, [
      'address',
      'full_address',
      'location',
    ]);
    if (address != null) _addressController.text = address;

    final license = _resolveVal(data, [
      'license_number',
      'license',
      'licenseNumber',
      'license_no',
      'driving_license',
    ]);
    if (license != null) _licenseController.text = license;

    final salary = _resolveVal(data, [
      'monthly_salary',
      'salary',
      'monthlySalary',
      'amount',
    ]);
    if (salary != null) _salaryController.text = salary;

    final country = _resolveVal(data, [
      'country',
      'country_name',
      'countryName',
    ]);
    if (country != null) _countryController.text = country;

    final bank = _resolveVal(data, [
      'bank_name',
      'bank',
      'bankName',
      'bank_title',
    ]);
    if (bank != null) _bankNameController.text = bank;

    final holder = _resolveVal(data, [
      'account_holder_name',
      'account_holder',
      'holder',
      'accountHolderName',
      'holder_name',
      'beneficiary_name',
    ]);
    if (holder != null) _accountHolderController.text = holder;

    final account = _resolveVal(data, [
      'account_number',
      'account',
      'iban',
      'accountNumber',
      'account_no',
    ]);
    if (account != null) _accountNumberController.text = account;

    final ifsc = _resolveVal(data, [
      'ifsc_code',
      'ifsc',
      'swift_code',
      'swift',
      'ifscCode',
      'swiftCode',
      'bic',
    ]);
    if (ifsc != null) _ifscController.text = ifsc;

    final genderVal = _resolveVal(data, [
      'gender',
      'gender_name',
      'sex',
    ]);
    if (genderVal != null) {
      if (genderVal == '2' || genderVal.toLowerCase() == 'female') {
        _selectedGender = 'Female';
      } else if (genderVal == '1' || genderVal.toLowerCase() == 'male') {
        _selectedGender = 'Male';
      }
    }

    final img = _resolveVal(data, [
      'image',
      'profile_image',
      'avatar',
      'photo',
      'image_url',
      'profile_photo',
    ]);
    if (img != null) _existingImageUrl = img;

    final proof = _resolveVal(data, [
      'id_proof',
      'idProof',
      'id_proof_url',
      'proof',
      'document',
      'identity_proof',
      'id_document',
    ]);
    if (proof != null) _existingIdProofUrl = proof;

    final addedTime = _resolveVal(data, [
      'formatted_created_on',
      'created_at',
      'created_on',
      'createdOn',
      'date_of_joining',
    ]);
    if (addedTime != null) _addedOnTime = addedTime;
  }

  @override
  void initState() {
    super.initState();
    if (widget.deliveryBoy != null) {
      final initialData = <String, dynamic>{};
      if (widget.deliveryBoy!.rawJson != null) {
        initialData.addAll(widget.deliveryBoy!.rawJson!);
      }
      final b = widget.deliveryBoy!;
      if (b.name != null) initialData['name'] ??= b.name;
      if (b.countryCode != null) initialData['country_code'] ??= b.countryCode;
      if (b.mobile != null) initialData['mobile'] ??= b.mobile;
      if (b.email != null) initialData['email'] ??= b.email;
      if (b.gender != null) initialData['gender'] ??= b.gender;
      if (b.address != null) initialData['address'] ??= b.address;
      if (b.licenseNumber != null) initialData['license_number'] ??= b.licenseNumber;
      if (b.monthlySalary != null) initialData['monthly_salary'] ??= b.monthlySalary;
      if (b.country != null) initialData['country'] ??= b.country;
      if (b.bankName != null) initialData['bank_name'] ??= b.bankName;
      if (b.accountHolderName != null) initialData['account_holder_name'] ??= b.accountHolderName;
      if (b.accountNumber != null) initialData['account_number'] ??= b.accountNumber;
      if (b.ifscCode != null) initialData['ifsc_code'] ??= b.ifscCode;
      if (b.image != null) initialData['image'] ??= b.image;
      if (b.idProof != null) initialData['id_proof'] ??= b.idProof;
      if (b.formattedCreatedOn != null) initialData['formatted_created_on'] ??= b.formattedCreatedOn;
      if (b.createdAt != null) initialData['created_at'] ??= b.createdAt;

      _populateFields(initialData);

      _fetchDeliveryBoyDetails();
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
                  style: appFont('Rubik', fontWeight: FontWeight.w500),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: colorPrimary),
                title: Text(
                  'Choose from Gallery',
                  style: appFont('Rubik', fontWeight: FontWeight.w500),
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

  Future<void> _fetchDeliveryBoyDetails() async {
    final userId =
        widget.deliveryBoy?.rawJson?['user_id'] ??
        widget.deliveryBoy?.id ??
        widget.deliveryBoy?.rawJson?['id'] ??
        widget.deliveryBoy?.rawJson?['delivery_staff_id'];
    if (userId == null) return;

    setState(() => _isLoadingDetails = true);

    try {
      final token = await getSavedObject("token");
      if (token != null && token.toString().isNotEmpty) {
        DioClient().updateToken(token.toString());
      }

      final queryParams = <String, dynamic>{"user_id": userId.toString()};

      String base = ApiConfigs.BASE_URL.trim();
      if (base.endsWith('/')) base = base.substring(0, base.length - 1);
      final cleanEndpoint = ApiEndPoints.deliveryBoyDetail.replaceFirst(
        RegExp(r'^/'),
        '',
      );
      final fullUrl = cleanEndpoint.startsWith('vendorapp/')
          ? "$base/$cleanEndpoint"
          : "$base/vendorapp/$cleanEndpoint";

      final headers = <String, dynamic>{
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      debugPrint(
        "==================== GET DELIVERY BOY DETAIL ====================",
      );
      debugPrint("API Call: GET $fullUrl");
      debugPrint("Header: $headers");
      debugPrint("Query Parameters: $queryParams");

      print(
        "==================== GET DELIVERY BOY DETAIL ====================",
      );
      print("API Call: GET $fullUrl");
      print("Header: $headers");
      print("Query Parameters: $queryParams");

      final response = await DioClient().get(
        ApiEndPoints.deliveryBoyDetail,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "=================================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print(
        "=================================================================",
      );

      final resData = response.data;
      if (resData is Map &&
          (resData['status'] == true ||
              resData['status'].toString() == 'true')) {
        Map<String, dynamic>? staffData;
        if (resData['data'] is Map &&
            resData['data']['delivery_staff'] is Map) {
          staffData = Map<String, dynamic>.from(
            resData['data']['delivery_staff'] as Map,
          );
        } else if (resData['data'] is Map) {
          staffData = Map<String, dynamic>.from(resData['data'] as Map);
        } else if (resData['delivery_staff'] is Map) {
          staffData = Map<String, dynamic>.from(
            resData['delivery_staff'] as Map,
          );
        }

        final merged = <String, dynamic>{};
        if (widget.deliveryBoy?.rawJson != null) {
          _safeMerge(merged, widget.deliveryBoy!.rawJson!);
        }
        if (resData['data'] is Map) {
          _safeMerge(merged, Map<String, dynamic>.from(resData['data'] as Map));
        }
        if (staffData != null) {
          _safeMerge(merged, staffData);
        }

        if (mounted) {
          setState(() {
            _populateFields(merged);
          });
        }
      }
    } catch (e) {
      debugPrint(
        "==================== GET DELIVERY BOY DETAIL ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "=======================================================================",
      );
      print(
        "==================== GET DELIVERY BOY DETAIL ERROR ====================",
      );
      print("Error: $e");
      print(
        "=======================================================================",
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    }
  }

  Future<void> _onDeleteDeliveryBoy() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Text(
          'Delete Delivery Boy',
          style: appFont('Rubik', 
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF1F2937),
          ),
        ),
        content: Text(
          _nameController.text.trim().isNotEmpty
              ? 'Are you sure you want to delete "${_nameController.text.trim()}"?'
              : 'Are you sure you want to delete this delivery boy?',
          style: appFont('Rubik', 
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: appFont('Rubik', 
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: appFont('Rubik', 
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _deleteDeliveryBoyApi();
  }

  Future<void> _deleteDeliveryBoyApi() async {
    final userId =
        widget.deliveryBoy?.id ??
        widget.deliveryBoy?.rawJson?['id'] ??
        widget.deliveryBoy?.rawJson?['user_id'];
    if (userId == null) return;

    showLoadingDialog(context);

    try {
      final token = await getSavedObject("token");
      if (token != null && token.toString().isNotEmpty) {
        DioClient().updateToken(token.toString());
      }

      final bodyMap = <String, dynamic>{
        "user_id": userId.toString(),
        "id": userId.toString(),
      };

      String base = ApiConfigs.BASE_URL.trim();
      if (base.endsWith('/')) base = base.substring(0, base.length - 1);
      final cleanEndpoint = ApiEndPoints.deleteDeliveryBoy.replaceFirst(
        RegExp(r'^/'),
        '',
      );
      final fullUrl = cleanEndpoint.startsWith('vendorapp/')
          ? "$base/$cleanEndpoint"
          : "$base/vendorapp/$cleanEndpoint";

      final headers = <String, dynamic>{
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      debugPrint(
        "==================== POST DELETE DELIVERY BOY ====================",
      );
      debugPrint("API Call: POST $fullUrl");
      debugPrint("Header: $headers");
      debugPrint("Request Body: $bodyMap");

      print(
        "==================== POST DELETE DELIVERY BOY ====================",
      );
      print("API Call: POST $fullUrl");
      print("Header: $headers");
      print("Request Body: $bodyMap");

      final response = await DioClient().post(
        ApiEndPoints.deleteDeliveryBoy,
        body: FormData.fromMap(bodyMap),
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "==================================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print(
        "==================================================================",
      );

      if (mounted) {
        Get.back();
      }

      final resData = response.data;
      final bool isSuccess =
          resData is Map &&
          (resData['status'] == true || resData['status'].toString() == 'true');

      if (isSuccess) {
        final message =
            resData['message']?.toString() ??
            'Delivery boy deleted successfully';
        if (mounted) {
          showToast(context, message);
          Navigator.of(context).pop(true);
        }
      } else {
        final message = resData is Map
            ? resData['message']?.toString() ?? 'Failed to delete delivery boy'
            : 'Failed to delete delivery boy';
        if (mounted) {
          showToast(context, message);
        }
      }
    } catch (e) {
      if (mounted) {
        Get.back();
      }
      debugPrint(
        "==================== POST DELETE DELIVERY BOY ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "========================================================================",
      );
      print(
        "==================== POST DELETE DELIVERY BOY ERROR ====================",
      );
      print("Error: $e");
      print(
        "========================================================================",
      );
      if (mounted) {
        showToast(context, e.toString().replaceFirst('Exception: ', '').trim());
      }
    }
  }

  String _getDeliveryBoyUrl() {
    final rawBase = ApiConfigs.BASE_URL.trim();
    String base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    String endpoint = _isEditing
        ? ApiEndPoints.pharmacyUpdateDeliveryBoy.trim()
        : ApiEndPoints.pharmacyAddDeliveryBoys.trim();
    final cleanEndpoint = endpoint.replaceFirst(RegExp(r'^/'), '');
    if (cleanEndpoint.startsWith('vendorapp/')) {
      return '$base/$cleanEndpoint';
    }
    return '$base/vendorapp/$cleanEndpoint';
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

    final cleanAccountNumber = accountNumber.trim().toUpperCase().replaceAll(' ', '');

    if (ifscCode.isEmpty) {
      showToast(context, 'Please enter IFSC / SWIFT code');
      return;
    }

    final cleanIfsc = ifscCode.trim().toUpperCase().replaceAll(' ', '');

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
        "account_number": cleanAccountNumber,
        "ifsc_code": cleanIfsc,
        "license_number": licenseNumber,
        "salary": monthlySalary,
        "bank": bankName,
        "holder": accountHolderName,
        "account": cleanAccountNumber,
        "ifsc": cleanIfsc,
        "license": licenseNumber,
      };

      if (_isEditing) {
        final userId =
            widget.deliveryBoy?.rawJson?['user_id'] ??
            widget.deliveryBoy?.id ??
            widget.deliveryBoy?.rawJson?['id'] ??
            widget.deliveryBoy?.rawJson?['delivery_staff_id'];
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

      debugPrint(
        "==================== POST $actionLabel DELIVERY BOY ====================",
      );
      debugPrint("API Call: POST $url");
      debugPrint("Endpoint: $endpoint");
      debugPrint(
        "FormData fields: user_id: ${formMap['user_id']}, name: $name, country_code: $countryCode, mobile: $mobile, email: $email, gender: $genderVal, address: $address, salary: $monthlySalary, bank: $bankName, account: $cleanAccountNumber, ifsc: $cleanIfsc, holder: $accountHolderName, country: $country, license: $licenseNumber, image: ${_imageFile?.path}, id_proof: ${_idProofFile?.path}",
      );

      print(
        "==================== POST $actionLabel DELIVERY BOY ====================",
      );
      print("API Call: POST $url");
      print("Endpoint: $endpoint");
      print(
        "FormData fields: user_id: ${formMap['user_id']}, name: $name, country_code: $countryCode, mobile: $mobile, email: $email, gender: $genderVal, address: $address, salary: $monthlySalary, bank: $bankName, account: $cleanAccountNumber, ifsc: $cleanIfsc, holder: $accountHolderName, country: $country, license: $licenseNumber, image: ${_imageFile?.path}, id_proof: ${_idProofFile?.path}",
      );

      final response = await DioClient().post(endpoint, body: formData);

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint(
        "===============================================================",
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("===============================================================");

      final resData = response.data;
      final bool isSuccess =
          resData is Map &&
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
      debugPrint(
        "==================== POST $actionLabel DELIVERY BOY ERROR ====================",
      );
      debugPrint("Error: $e");
      debugPrint(
        "=====================================================================",
      );

      print(
        "==================== POST $actionLabel DELIVERY BOY ERROR ====================",
      );
      print("Error: $e");
      print(
        "=====================================================================",
      );

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isEditing ? 'Update Delivery Boy' : 'Add Delivery Boy',
              style: appFont('Rubik', 
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF333E63),
              ),
            ),
            if (_isEditing && _addedOnTime != null && _addedOnTime!.isNotEmpty)
              Text(
                'Added on: $_addedOnTime',
                style: appFont('Rubik', 
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
                ),
              ),
          ],
        ),
        actions: [
          if (_isEditing)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF333E63)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              elevation: 4,
              onSelected: (value) {
                if (value == 'delete') {
                  _onDeleteDeliveryBoy();
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: appFont('Rubik', 
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(color: Colors.grey.withOpacity(0.1), height: 1),
        ),
      ),
      body: _isLoadingDetails
          ? const Center(child: AppLoader())
          : SingleChildScrollView(
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
                                'Code',
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
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
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
                    _buildTextField(
                      _accountHolderController,
                      'Enter account holder name',
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Account Number *'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      _accountNumberController,
                      'Enter account number / IBAN',
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('IFSC / SWIFT Code *'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      _ifscController,
                      'Enter SWIFT/BIC code (8 or 11 characters)',
                      textCapitalization: TextCapitalization.characters,
                    ),
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
                    style: appFont('Rubik', 
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
                  onPressed: (_isSubmitting || _isLoadingDetails)
                      ? null
                      : _submit,
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
                          _isEditing ? 'Update' : 'Add Delivery Boy',
                          style: appFont('Rubik', 
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
      style: appFont('Rubik', 
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: appFont('Rubik', 
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
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      style: appFont('Rubik', fontSize: 14, color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: appFont('Rubik', 
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
          hint: Text(
            'Select Gender',
            style: appFont('Rubik', 
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          isExpanded: true,
          items: _genderOptions
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: appFont('Rubik', 
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
                    child: Image.file(file, fit: BoxFit.cover),
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
                        style: appFont('Rubik', 
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
                        child: Icon(Icons.person, color: Colors.grey, size: 40),
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
                        style: appFont('Rubik', 
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
                    style: appFont('Rubik', 
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'PNG, JPG up to 4MB',
                    style: appFont('Rubik', 
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
