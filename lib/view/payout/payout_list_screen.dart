import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../generated/l10n.dart';
import '../../resources/colors.dart';
import '../../utils/widgets/no_data_widget.dart';
import 'payoutitem.dart';
import 'payout_viewall_screen.dart';

/// Content to show under the "Received Payouts" tab: balance card, history header, search, and list.
/// Use this widget inside the tab view (e.g. in vendor_restaurant_screen); it has no Scaffold/AppBar.
class PayoutListScreen extends StatefulWidget {
  const PayoutListScreen({super.key});

  @override
  State<PayoutListScreen> createState() => _PayoutListScreenState();
}

class _PayoutListScreenState extends State<PayoutListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  /// Replace with your API/controller when wired.
  static List<_PayoutEntry> _samplePayouts = [
    _PayoutEntry(
      transactionId: 'PYT240',
      dateTime: 'Feb 07, 2026 10:45 AM, Today',
      amount: '400.00',
      balanceAfterPayout: '1,000.00',
    ),
    _PayoutEntry(
      transactionId: 'PYT239',
      dateTime: 'Feb 06, 2026 03:20 PM',
      amount: '250.00',
      balanceAfterPayout: '600.00',
    ),
    _PayoutEntry(
      transactionId: 'PYT238',
      dateTime: 'Feb 05, 2026 09:15 AM',
      amount: '500.00',
      balanceAfterPayout: '350.00',
    ),
  ];

  static const String _sampleTotalBalance = '10,140.00';
  static const String _sampleCurrency = 'MRU';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = FlutterLocalization.instance;
    final isRtl = localization.currentLocale?.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final payouts = _samplePayouts; // Replace with controller/API list

    if (payouts.isEmpty) {
      return NoDataWidget(
        context,
        S.of(context).receivedPayouts,
        S.of(context).noPayoutsYet,
        'lib/assets/images/nonotifications.png',
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTotalPayoutBalanceCard(),
        const SizedBox(height: 10),
        _buildHistoryHeader(context),
        const SizedBox(height: 12),
        _buildSearchBar(context),
        const SizedBox(height: 16),
        ...payouts.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PayoutItem(
                transactionId: p.transactionId,
                dateTime: p.dateTime,
                amount: p.amount,
                balanceAfterPayout: p.balanceAfterPayout,
                currency: _sampleCurrency,
              ),
            )),
      ],
    );
  }

  Widget _buildTotalPayoutBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorPrimary,
            colorPrimary.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorPrimary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).totalPayoutBalance,
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _sampleTotalBalance,
                    style: GoogleFonts.rubik(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _sampleCurrency,
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Positioned(
          //   right: -8,
          //   bottom: -8,
          //   child: Icon(
          //     Icons.waves_rounded,
          //     size: 64,
          //     color: Colors.white.withOpacity(0.12),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          S.of(context).history,
          style: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        TextButton(
          onPressed: () {
            Get.to(() => const PayoutViewAllScreen());
          },
          child: Text(
            S.of(context).viewAll,
            style: GoogleFonts.rubik(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: S.of(context).searchAmountOrTransactionId,
        hintStyle: GoogleFonts.rubik(
          fontSize: 14,
          color: Colors.grey.shade500,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 22,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: GoogleFonts.rubik(fontSize: 14),
      onChanged: (_) => setState(() {}),
    );
  }
}

class _PayoutEntry {
  final String transactionId;
  final String dateTime;
  final String amount;
  final String balanceAfterPayout;

  _PayoutEntry({
    required this.transactionId,
    required this.dateTime,
    required this.amount,
    required this.balanceAfterPayout,
  });
}
