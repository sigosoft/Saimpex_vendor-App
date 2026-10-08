import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PharmacyProfileScreen extends StatelessWidget {
  const PharmacyProfileScreen({super.key});

  static const _label = Color(0xFF8A97A8);
  static const _value = Color(0xFF4C5260);
  static const _ink = Color(0xFF1C1D1B);
  static const _orange = Color(0xFFFF5216);

  @override
  Widget build(BuildContext context) {
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
                  children: const [
                    _SectionTitle('Pharmacy Details'),
                    SizedBox(height: 18),
                    _InfoCard(
                      rows: [
                        _InfoRow('Name', 'Pharmacy SAIMPEX'),
                        _InfoRow('Owner', 'Salman'),
                        _InfoRow('ID', '1'),
                        _InfoRow('Contact', '+22241518211'),
                        _InfoRow('Email', 'pharmacy@saimpex.com'),
                        _InfoRow('Status', 'ACTIVE', badge: true),
                        _InfoRow('Address', 'Pharmacy Block 5, Mauritania'),
                      ],
                    ),
                    SizedBox(height: 18),
                    _SectionTitle('Bank Details'),
                    SizedBox(height: 8),
                    _InfoCard(
                      rows: [
                        _InfoRow('Holder Name', 'Salman H'),
                        _InfoRow('IBAN Number', '12123562189536189111'),
                        _InfoRow('SWIFT Code', 'TESTMRMR001'),
                      ],
                    ),
                    SizedBox(height: 18),
                    _SectionTitle('Registration Details'),
                    SizedBox(height: 8),
                    _InfoCard(
                      rows: [
                        _InfoRow('Reg. Number', 'RESTTMAUR13'),
                        _InfoRow('Reg. Date', 'Dec 7, 2025'),
                        _InfoRow('TIN/NIF Number', 'MR-TIN-127444'),
                      ],
                    ),
                    SizedBox(height: 18),
                    _SectionTitle('Payment Details'),
                    SizedBox(height: 8),
                    _InfoCard(
                      rows: [
                        _InfoRow('Commission %', '5.00%'),
                        _InfoRow('Total Profit', '0 MRU', emphasize: true),
                      ],
                    ),
                    SizedBox(height: 18),
                    _SectionTitle('Owner Identity Proof'),
                    SizedBox(height: 8),
                    _EmptyCard(),
                    SizedBox(height: 18),
                    _SectionTitle('Certificate'),
                    SizedBox(height: 8),
                    _EmptyCard(),
                    SizedBox(height: 20),
                    _ReviewsHeader(),
                    SizedBox(height: 10),
                    _ReviewCard(),
                    SizedBox(height: 10),
                    _ReviewCard(),
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
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
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
