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
    name = json['name']?.toString();
    countryCodeId = json['country_code_id'] is int
        ? json['country_code_id']
        : int.tryParse(json['country_code_id']?.toString() ?? '');
    countryCode = json['country_code']?.toString() ?? '+222';
    mobile = json['mobile']?.toString();
    email = json['email']?.toString();
    address = json['address']?.toString();
    image = json['image']?.toString();
    idProof = json['id_proof']?.toString();
    gender = json['gender'] is int
        ? json['gender']
        : int.tryParse(json['gender']?.toString() ?? '');
    status = json['status'] is int
        ? json['status']
        : int.tryParse(json['status']?.toString() ?? '');
    licenseNumber = json['license_number']?.toString();
    monthlySalary = json['monthly_salary']?.toString() ?? json['salary']?.toString();
    bankName = json['bank_name']?.toString();
    accountHolderName = json['account_holder_name']?.toString();
    accountNumber = json['account_number']?.toString();
    ifscCode = json['ifsc_code']?.toString();
    country = json['country']?.toString();
    createdAt = json['created_at']?.toString();
    formattedCreatedOn = json['formatted_created_on']?.toString();
  }
}
