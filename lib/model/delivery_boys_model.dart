class DeliveryBoysModel {
  bool? status;
  DeliveryBoysData? data;
  String? message;

  DeliveryBoysModel({this.status, this.data, this.message});

  DeliveryBoysModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    status = json['status'] == true || json['status']?.toString() == "true";
    data = json['data'] != null
        ? DeliveryBoysData.fromJson(json['data'])
        : null;
    message = json['message']?.toString();
  }
}

class DeliveryBoysData {
  DeliveryStaffs? deliveryStaffs;

  DeliveryBoysData({this.deliveryStaffs});

  DeliveryBoysData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    deliveryStaffs = json['delivery_staffs'] != null
        ? DeliveryStaffs.fromJson(json['delivery_staffs'])
        : null;
  }
}

class DeliveryStaffs {
  int? currentPage;
  List<DeliveryBoy>? data;
  int? lastPage;
  int? perPage;
  int? total;

  DeliveryStaffs({
    this.currentPage,
    this.data,
    this.lastPage,
    this.perPage,
    this.total,
  });

  DeliveryStaffs.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <DeliveryBoy>[];
      json['data'].forEach((v) {
        data!.add(DeliveryBoy.fromJson(v));
      });
    }
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
  }
}

class DeliveryBoy {
  int? id;
  String? name;
  int? countryCodeId;
  String? countryCode;
  String? mobile;
  String? email;
  String? address;
  String? image;
  String? idProof;
  int? gender;
  int? status;
  String? licenseNumber;
  String? monthlySalary;
  String? bankName;
  String? accountHolderName;
  String? accountNumber;
  String? ifscCode;
  String? country;
  String? createdAt;
  String? formattedCreatedOn;
  Map<String, dynamic>? rawJson;

  DeliveryBoy({
    this.id,
    this.name,
    this.countryCodeId,
    this.countryCode,
    this.mobile,
    this.email,
    this.address,
    this.image,
    this.idProof,
    this.gender,
    this.status,
    this.licenseNumber,
    this.monthlySalary,
    this.bankName,
    this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
    this.country,
    this.createdAt,
    this.formattedCreatedOn,
    this.rawJson,
  });

  DeliveryBoy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    rawJson = json;
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString() ?? json['full_name']?.toString() ?? json['delivery_boy_name']?.toString();
    countryCodeId = json['country_code_id'] is int
        ? json['country_code_id']
        : int.tryParse(json['country_code_id']?.toString() ?? '');
    countryCode = json['country_code']?.toString() ?? json['code']?.toString() ?? json['countryCode']?.toString();
    mobile = json['mobile']?.toString() ?? json['phone']?.toString() ?? json['mobile_number']?.toString();
    email = json['email']?.toString() ?? json['email_address']?.toString();
    address = json['address']?.toString() ?? json['full_address']?.toString();
    image = json['image']?.toString() ?? json['profile_image']?.toString() ?? json['avatar']?.toString() ?? json['photo']?.toString();
    idProof = json['id_proof']?.toString() ?? json['idProof']?.toString() ?? json['identity_proof']?.toString() ?? json['document']?.toString();
    gender = json['gender'] is int
        ? json['gender']
        : int.tryParse(json['gender']?.toString() ?? '');
    status = json['status'] is int
        ? json['status']
        : int.tryParse(json['status']?.toString() ?? '');
    licenseNumber = json['license_number']?.toString() ?? json['license']?.toString() ?? json['license_no']?.toString();
    monthlySalary = json['monthly_salary']?.toString() ?? json['salary']?.toString() ?? json['monthlySalary']?.toString();
    bankName = json['bank_name']?.toString() ?? json['bank']?.toString() ?? json['bankName']?.toString();
    accountHolderName = json['account_holder_name']?.toString() ?? json['account_holder']?.toString() ?? json['holder']?.toString() ?? json['holder_name']?.toString();
    accountNumber = json['account_number']?.toString() ?? json['account']?.toString() ?? json['iban']?.toString();
    ifscCode = json['ifsc_code']?.toString() ?? json['ifsc']?.toString() ?? json['swift_code']?.toString() ?? json['swift']?.toString();
    country = json['country']?.toString() ?? json['country_name']?.toString();
    createdAt = json['created_at']?.toString() ?? json['created_on']?.toString();
    formattedCreatedOn = json['formatted_created_on']?.toString() ?? json['formattedCreatedOn']?.toString();

    final bankObj = json['bank_detail'] ?? json['bank_details'] ?? json['bank_info'] ?? (json['bank'] is Map ? json['bank'] : null);
    if (bankObj is Map) {
      bankName ??= bankObj['bank_name']?.toString() ?? bankObj['bank']?.toString();
      accountHolderName ??= bankObj['account_holder_name']?.toString() ?? bankObj['holder']?.toString() ?? bankObj['account_holder']?.toString();
      accountNumber ??= bankObj['account_number']?.toString() ?? bankObj['account']?.toString() ?? bankObj['iban']?.toString();
      ifscCode ??= bankObj['ifsc_code']?.toString() ?? bankObj['ifsc']?.toString() ?? bankObj['swift_code']?.toString() ?? bankObj['swift']?.toString();
      country ??= bankObj['country']?.toString() ?? bankObj['country_name']?.toString();
    }
  }
}
