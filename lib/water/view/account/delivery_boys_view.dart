import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
    required this.avatar,
  });

  final String name;
  final String phone;
  final String address;
  final String avatar;
}

class _DeliveryBoysViewState extends State<DeliveryBoysView> {
  final _search = TextEditingController();
  final _boys = const [
    _Boy(
      name: 'Cheikh Ould Ely',
      phone: '+222 22345678',
      address: 'Apt 3B Ilot k, Nouakchott',
      avatar: 'lib/water/Assets/Images/delivery_boy1.png',
    ),
    _Boy(
      name: 'Ismail Ould Ahmed',
      phone: '+222 22345678',
      address: 'Apt 3B Ilot k, Nouakchott',
      avatar: 'lib/water/Assets/Images/delivery_boy2.png',
    ),
    _Boy(
      name: 'Abdallahi Ould Mahmoud',
      phone: '+222 22345678',
      address: 'Apt 3B Ilot k, Nouakchott',
      avatar: 'lib/water/Assets/Images/delivery_boy3.png',
    ),
  ];

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
              _Header(onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: ListView(
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
                        hintText: 'Search Coupon',
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFFA9AEB6),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFFA9AEB6)),
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: _fieldBorder,
                        enabledBorder: _fieldBorder,
                        focusedBorder: _fieldBorder,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final boy in boys) ...[
                      _BoyCard(boy: boy),
                      const SizedBox(height: 12),
                    ],
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

const _fieldBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  borderSide: BorderSide(color: Color(0xFFE6E8EC)),
);

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
              'Delivery Boys',
              style: GoogleFonts.inter(
                color: const Color(0xFF1C1D1B),
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
                    color: DeliveryBoysView.orange,
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

class _BoyCard extends StatelessWidget {
  const _BoyCard({required this.boy});

  final _Boy boy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          _Avatar(asset: boy.avatar),
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
                _MetaRow(icon: Icons.phone_outlined, text: boy.phone),
                const SizedBox(height: 4),
                _MetaRow(icon: Icons.location_on_outlined, text: boy.address),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const _ActivePill(),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: 56,
      height: 56,
      fit: BoxFit.contain,
    );
  }
}

class _ActivePill extends StatelessWidget {
  const _ActivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'ACTIVE',
        style: GoogleFonts.inter(
          color: const Color(0xFF16A34A),
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
