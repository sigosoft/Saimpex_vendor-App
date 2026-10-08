import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/profile_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/vendor_app_router.dart';

class PharmacyProfileScreen extends StatefulWidget {
  const PharmacyProfileScreen({super.key});

  static const _label = Color(0xFF8A97A8);
  static const _value = Color(0xFF4C5260);
  static const _ink = Color(0xFF1C1D1B);
  static const _orange = Color(0xFFFF5216);

  @override
  State<PharmacyProfileScreen> createState() => _PharmacyProfileScreenState();
}

class _PharmacyProfileScreenState extends State<PharmacyProfileScreen> {
  ProfileData? _profileData;
  Map<String, dynamic>? _rawVendorData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPharmacyProfile();
  }

  Future<void> _fetchPharmacyProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        debugPrint("⚠️ No auth token found. Skipping profile API call in PharmacyProfileScreen.");
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final savedVendorType = await getSavedObject("vendorType");
      final savedAppType = await getSavedObject(VendorAppRouter.storageKey);
      final vendorType = (savedVendorType != null &&
              savedVendorType.toString().isNotEmpty &&
              savedVendorType.toString() != "0")
          ? savedVendorType.toString()
          : (savedAppType?.toString().isNotEmpty == true
              ? savedAppType.toString()
              : "3");

      final now = DateTime.now();
      final fromDate =
          "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final toDate = fromDate;

      final queryParams = <String, dynamic>{
        "vendor_type": vendorType,
        "from_date": fromDate,
        "to_date": toDate,
      };

      final headers = <String, dynamic>{
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      String base = ApiConfigs.BASE_URL.trim();
      if (base.endsWith('/')) base = base.substring(0, base.length - 1);
      if (base.endsWith('/vendor')) {
        base = base.substring(0, base.length - 7);
      } else if (base.endsWith('/vendorapp')) {
        base = base.substring(0, base.length - 10);
      }
      final fullUrl =
          Uri.parse("$base/${ApiEndPoints.pharmacyProfile}")
              .replace(queryParameters: queryParams);

      debugPrint("==================== GET VENDOR PROFILE ====================");
      debugPrint("API Call: GET $fullUrl");
      debugPrint("Header: $headers");
      debugPrint("Request Body: null (GET request)");

      print("==================== GET VENDOR PROFILE ====================");
      print("API Call: GET $fullUrl");
      print("Header: $headers");
      print("Request Body: null (GET request)");

      final response = await DioClient().get(
        ApiEndPoints.pharmacyProfile,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("============================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("============================================================");

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        try {
          dataMap = jsonDecode(response.data as String) as Map<String, dynamic>?;
        } catch (_) {}
      }

      if (dataMap != null) {
        final profileModel = ProfileModel.fromJson(dataMap);
        final fetchedData = profileModel.data;
        final rawData = (dataMap['data'] is Map<String, dynamic>)
            ? ((dataMap['data']['vendor'] as Map<String, dynamic>?) ??
                dataMap['data'] as Map<String, dynamic>?)
            : null;

        if (mounted) {
          setState(() {
            _profileData = fetchedData;
            _rawVendorData = rawData;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("==================== GET VENDOR PROFILE ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("==================================================================");

      print("==================== GET VENDOR PROFILE ERROR ====================");
      print("Error: $e");
      print("==================================================================");

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatContact(String? code, String? mobile) {
    if ((mobile == null || mobile.trim().isEmpty) &&
        (code == null || code.trim().isEmpty)) {
      return '+22241518211';
    }
    final c = (code ?? '').trim();
    final m = (mobile ?? '').trim();
    if (c.isEmpty) return m;
    if (m.isEmpty) return c;
    return '$c$m';
  }

  String _formatCommission(String? value) {
    if (value == null || value.trim().isEmpty) return '5.00%';
    final trimmed = value.trim();
    return trimmed.endsWith('%') ? trimmed : '$trimmed%';
  }

  String _formatProfit(String? value) {
    if (value == null || value.trim().isEmpty) return '0 MRU';
    final trimmed = value.trim();
    return trimmed.contains('MRU') ? trimmed : '$trimmed MRU';
  }

  @override
  Widget build(BuildContext context) {
    final pharmacyName = _profileData?.name ??
        _rawVendorData?['name']?.toString() ??
        _rawVendorData?['pharmacy_name']?.toString() ??
        'Pharmacy SAIMPEX';
    final ownerName = _profileData?.owner ??
        _rawVendorData?['owner']?.toString() ??
        _rawVendorData?['owner_name']?.toString() ??
        'Salman';
    final pharmacyId = _profileData?.id?.toString() ??
        _rawVendorData?['id']?.toString() ??
        '1';
    final contact = _formatContact(
      _profileData?.countryCode ?? _rawVendorData?['country_code']?.toString(),
      _profileData?.mobile ?? _rawVendorData?['mobile']?.toString(),
    );
    final email = _profileData?.email ??
        _rawVendorData?['email']?.toString() ??
        'pharmacy@saimpex.com';
    final status = _profileData?.status ??
        (_rawVendorData?['status']?.toString() == '1'
            ? 'ACTIVE'
            : (_rawVendorData?['status']?.toString() == '0'
                ? 'INACTIVE'
                : _rawVendorData?['status']?.toString())) ??
        'ACTIVE';
    final address = _profileData?.address ??
        _rawVendorData?['address']?.toString() ??
        'Pharmacy Block 5, Mauritania';

    final holderName = _profileData?.accountHolderName ??
        _rawVendorData?['account_holder_name']?.toString() ??
        _rawVendorData?['holder_name']?.toString() ??
        _rawVendorData?['bank_holder_name']?.toString() ??
        'Salman H';
    final ibanNumber = _profileData?.accountNumber ??
        _rawVendorData?['account_number']?.toString() ??
        _rawVendorData?['iban']?.toString() ??
        _rawVendorData?['iban_number']?.toString() ??
        '12123562189536189111';
    final swiftCode = _profileData?.ifscCode ??
        _rawVendorData?['ifsc_code']?.toString() ??
        _rawVendorData?['swift']?.toString() ??
        _rawVendorData?['swift_code']?.toString() ??
        'TESTMRMR001';

    final regNumber = _profileData?.registrationNumber ??
        _rawVendorData?['registration_number']?.toString() ??
        _rawVendorData?['reg_number']?.toString() ??
        'RESTTMAUR13';
    final regDate = _profileData?.registrationDate ??
        _rawVendorData?['registration_date']?.toString() ??
        _rawVendorData?['reg_date']?.toString() ??
        'Dec 7, 2025';
    final tinNumber = _profileData?.gstNo ??
        _rawVendorData?['gst_no']?.toString() ??
        _rawVendorData?['tin_number']?.toString() ??
        _rawVendorData?['nif_number']?.toString() ??
        'MR-TIN-127444';

    final commission = _formatCommission(
      _profileData?.commissionPercentage ??
          _rawVendorData?['commission_percentage']?.toString() ??
          _rawVendorData?['commission']?.toString(),
    );
    final totalProfit = _formatProfit(
      _profileData?.totalProfit ??
          _rawVendorData?['total_profit']?.toString() ??
          _rawVendorData?['profit']?.toString(),
    );

    final ownerIdProof = _profileData?.ownerIdProof ??
        _rawVendorData?['owner_id_proof']?.toString();
    final certificate = _profileData?.certificate ??
        _rawVendorData?['certificate']?.toString();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE8E0), Color(0xFFFFF4F0), Colors.white],
              stops: [0, 0.18, 0.36],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              _Header(onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                  children: [
                    const _SectionTitle('Pharmacy Details'),
                    const SizedBox(height: 18),
                    _InfoCard(
                      rows: [
                        _InfoRow('Name', pharmacyName),
                        _InfoRow('Owner', ownerName),
                        _InfoRow('ID', pharmacyId),
                        _InfoRow('Contact', contact),
                        _InfoRow('Email', email),
                        _InfoRow('Status', status, badge: true),
                        _InfoRow('Address', address),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _SectionTitle('Bank Details'),
                    const SizedBox(height: 8),
                    _InfoCard(
                      rows: [
                        _InfoRow('Holder Name', holderName),
                        _InfoRow('IBAN Number', ibanNumber),
                        _InfoRow('SWIFT Code', swiftCode),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _SectionTitle('Registration Details'),
                    const SizedBox(height: 8),
                    _InfoCard(
                      rows: [
                        _InfoRow('Reg. Number', regNumber),
                        _InfoRow('Reg. Date', regDate),
                        _InfoRow('TIN/NIF Number', tinNumber),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _SectionTitle('Payment Details'),
                    const SizedBox(height: 8),
                    _InfoCard(
                      rows: [
                        _InfoRow('Commission %', commission),
                        _InfoRow('Total Profit', totalProfit, emphasize: true),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _SectionTitle('Owner Identity Proof'),
                    const SizedBox(height: 8),
                    _EmptyCard(imageUrl: ownerIdProof),
                    const SizedBox(height: 18),
                    const _SectionTitle('Certificate'),
                    const SizedBox(height: 8),
                    _EmptyCard(imageUrl: certificate),
                    const SizedBox(height: 20),
                    const _ReviewsHeader(),
                    const SizedBox(height: 10),
                    const _ReviewCard(),
                    const SizedBox(height: 10),
                    const _ReviewCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'Pharmacy Profile',
              style: GoogleFonts.inter(
                color: PharmacyProfileScreen._ink,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onBack,
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
                    color: PharmacyProfileScreen._orange,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: const Color.fromARGB(255, 55, 56, 58),
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow(this.label, this.value, {this.valueColor, this.emphasize = false, this.badge = false});

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;
  final bool badge;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      row.label,
                      style: GoogleFonts.inter(
                        color: PharmacyProfileScreen._label,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (row.badge)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        row.value,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF16A34A),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      flex: 6,
                      child: Text(
                        row.value,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.inter(
                          color: row.valueColor ??
                              (row.emphasize ? PharmacyProfileScreen._ink : PharmacyProfileScreen._value),
                          fontWeight: row.emphasize ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final String? fullUrl = imageUrl != null && imageUrl!.trim().isNotEmpty
        ? (imageUrl!.startsWith('http')
            ? imageUrl
            : '${ApiConfigs.IMAGE_URL}$imageUrl')
        : null;

    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: fullUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                fullUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            )
          : null,
    );
  }
}

class _ReviewsHeader extends StatelessWidget {
  const _ReviewsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'RATING & REVIEWS',
          style: GoogleFonts.inter(
            color: const Color.fromARGB(255, 46, 48, 50),
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.4,
          ),
        ),
        const Spacer(),
        Text(
          'See All',
          style: GoogleFonts.inter(
            color: PharmacyProfileScreen._orange,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  'S',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF059669),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Aicha Mint Ahmed',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF3F4555),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          'Jan 12 2026, 07:13 am',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF9AA8B8),
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        for (var i = 0; i < 5; i++)
                          Icon(
                            i < 3 ? Icons.star_rounded : Icons.star_border_rounded,
                            color: i < 3 ? const Color(0xFFFBBF24) : const Color(0xFFD1D5DB),
                            size: 16,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          '3.0',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF9AA8B8),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Fast prescription verification.',
            style: GoogleFonts.inter(
              color: const Color(0xFF3F4555),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 34,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Order: ORD-000091',
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
