import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PharmacyPrivacyScreen extends StatelessWidget {
  const PharmacyPrivacyScreen({super.key});

  static const orange = Color(0xFFFF5216);
  static const page = Color(0xFFFDF9F0);

  static const _paragraph =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin in imperdiet velit. Cras rhoncus semper felis, a venenatis enim aliquam eu. Pellentesque viverra magna eget velit lobortis, in feugiat orci tristique. Aenean dictum euismod tincidunt. Nullam velit ante, euismod ut bibendum vitae, suscipit eu risus. Proin consequat nunc quis diam pretium eleifend. Donec quis pharetra nisl. Aenean vel posuere ex, in hendrerit mauris.';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: page,
        body: Column(
          children: [
            SizedBox(height: MediaQuery.paddingOf(context).top + 8),
            _Header(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  for (var i = 0; i < 6; i++) ...[
                    Text(
                      _paragraph,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF333333),
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    if (i < 5) const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
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
              'Privacy & Security',
              style: GoogleFonts.inter(
                color: const Color(0xFF000000),
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
                    color: PharmacyPrivacyScreen.orange,
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
