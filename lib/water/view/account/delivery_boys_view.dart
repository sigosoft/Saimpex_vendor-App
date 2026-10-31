import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/delivery_boys_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/view/settings/add_delivery_boy_screen.dart';

class DeliveryBoysView extends StatefulWidget {
  const DeliveryBoysView({super.key});

  static const ink = Color(0xFF1E293B);
  static const orange = Color(0xFFFF5216);

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DeliveryBoysView()),
    );
  }

  @override
  State<DeliveryBoysView> createState() => _DeliveryBoysViewState();
}

class _Boy {
  const _Boy({
    required this.name,
    required this.phone,
    required this.address,
    this.avatar,
    this.status = 1,
    this.deliveryBoy,
  });

  final String name;
  final String phone;
  final String address;
  final String? avatar;
  final int status;
  final DeliveryBoy? deliveryBoy;
}

class _DeliveryBoysViewState extends State<DeliveryBoysView> {
  final _search = TextEditingController();
  bool _isLoading = true;
  List<_Boy> _boys = [];

  @override
  void initState() {
    super.initState();
    _fetchDeliveryBoys();
  }

  Future<void> _fetchDeliveryBoys() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await getSavedObject('token');
      if (token != null &&
          token.toString() != 'null' &&
          token.toString().isNotEmpty) {
        DioClient().updateToken(token);
      }

      debugPrint("==================== GET DELIVERY BOYS ====================");
      debugPrint("Endpoint: ${ApiEndPoints.getDeliveryBoys}");

      final response = await DioClient().get(
        ApiEndPoints.getDeliveryBoys,
        query: {"limit": 20},
      );

      debugPrint("==================== GET DELIVERY BOYS RESPONSE ====================");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Data: ${response.data}");

      List<DeliveryBoy> boysList = [];
      if (response.data is Map &&
          (response.data['status'] == true ||
              response.data['status']?.toString() == 'true')) {
        final data = response.data['data'];
        if (data is Map && data['delivery_staffs'] != null) {
          final staffs = data['delivery_staffs'];
          if (staffs is Map && staffs['data'] is List) {
            boysList = (staffs['data'] as List)
                .map((v) => DeliveryBoy.fromJson(v))
                .toList();
          } else if (staffs is List) {
            boysList = staffs.map((v) => DeliveryBoy.fromJson(v)).toList();
          }
        } else if (data is List) {
          boysList = data.map((v) => DeliveryBoy.fromJson(v)).toList();
        } else if (data is Map && data['data'] is List) {
          boysList = (data['data'] as List)
              .map((v) => DeliveryBoy.fromJson(v))
              .toList();
        }
      }

      final mapped = boysList.map((b) {
        final phone = (b.countryCode != null && b.countryCode!.isNotEmpty)
            ? '${b.countryCode} ${b.mobile ?? ''}'.trim()
            : (b.mobile ?? '');
        String? avatarUrl;
        if (b.image != null && b.image!.isNotEmpty) {
          avatarUrl = b.image!.startsWith('http')
              ? b.image
              : '${ApiConfigs.IMAGE_URL}${b.image}';
        }
        return _Boy(
          name: b.name ?? '',
          phone: phone,
          address: b.address ?? '',
          avatar: avatarUrl,
          status: b.status ?? 1,
          deliveryBoy: b,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _boys = mapped;
        });
      }
    } catch (e) {
      debugPrint("Error fetching delivery boys: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<_Boy> get _visible {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _boys;
    return _boys
        .where(
          (boy) =>
              boy.name.toLowerCase().contains(query) ||
              boy.phone.toLowerCase().contains(query) ||
              boy.address.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final boys = _visible;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE8E0), Color(0xFFFFF4EF), Colors.white],
              stops: [0, 0.22, 0.42],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              _Header(
                onBack: () => Navigator.of(context).maybePop(),
                onAdd: () async {
                  final added = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddDeliveryBoyScreen(),
                    ),
                  );
                  if (added == true) {
                    _fetchDeliveryBoys();
                  }
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  color: DeliveryBoysView.orange,
                  onRefresh: _fetchDeliveryBoys,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.inter(
                          color: DeliveryBoysView.ink,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: S.of(context).waterSearchDeliveryBoy,
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFFA9AEB6),
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(Icons.search,
                              size: 18, color: Color(0xFFA9AEB6)),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: _fieldBorder,
                          enabledBorder: _fieldBorder,
                          focusedBorder: _fieldBorder,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: DeliveryBoysView.orange,
                            ),
                          ),
                        )
                      else if (boys.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'lib/assets/images/nodata.png',
                                  height: 120,
                                  width: 140,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  S.of(context).noDeliveryBoysFound,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: DeliveryBoysView.ink,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  S.of(context).waterAddedDeliveryBoysAppearHere,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        for (final boy in boys) ...[
                          _BoyCard(
                            boy: boy,
                            onTap: () async {
                              if (boy.deliveryBoy != null) {
                                final updated = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddDeliveryBoyScreen(
                                      deliveryBoy: boy.deliveryBoy,
                                    ),
                                  ),
                                );
                                if (updated == true) {
                                  _fetchDeliveryBoys();
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _fieldBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  borderSide: BorderSide(color: Color(0xFFE6E8EC)),
);

class _Header extends StatelessWidget {
  const _Header({required this.onBack, this.onAdd});

  final VoidCallback onBack;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            InkWell(
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
                  color: DeliveryBoysView.orange,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                S.of(context).deliveryBoys,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: const Color(0xFF1C1D1B),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            if (onAdd != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: DeliveryBoysView.orange, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add,
                          color: DeliveryBoysView.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        S.of(context).waterAddDeliveryBoy,
                        style: GoogleFonts.inter(
                          color: DeliveryBoysView.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
    );
  }
}

class _BoyCard extends StatelessWidget {
  const _BoyCard({required this.boy, this.onTap});

  final _Boy boy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            _Avatar(avatarUrl: boy.avatar),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    boy.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: DeliveryBoysView.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Phone stays LTR ("+222 …") inside RTL text.
                  _MetaRow(
                    icon: Icons.phone_outlined,
                    text: boy.phone.isEmpty ? '' : '\u202A${boy.phone}\u202C',
                  ),
                  const SizedBox(height: 4),
                  _MetaRow(icon: Icons.location_on_outlined, text: boy.address),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _ActivePill(isActive: boy.status == 1),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          avatarUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2D7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        color: DeliveryBoysView.orange,
        size: 28,
      ),
    );
  }
}

class _ActivePill extends StatelessWidget {
  const _ActivePill({this.isActive = true});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? S.of(context).active : S.of(context).inactive,
        style: GoogleFonts.inter(
          color: isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
