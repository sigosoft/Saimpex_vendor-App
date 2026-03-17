import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/utils/widgets/common_background.dart';
import '../../generated/l10n.dart';
import '../../resources/colors.dart';
import '../../utils/Widgets/custom_app_bar.dart';
import '../../utils/widgets/no_data_widget.dart';
import 'payoutitem.dart';

/// Full-screen payout history: app bar "History", balance card, search bar, and list.
class PayoutViewAllScreen extends StatefulWidget {
  const PayoutViewAllScreen({super.key});

  @override
  State<PayoutViewAllScreen> createState() => _PayoutViewAllScreenState();
}

class _PayoutViewAllScreenState extends State<PayoutViewAllScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  static const String _sampleTotalBalance = '10,140.00';
  static const String _sampleCurrency = 'MRU';

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
    _PayoutEntry(
      transactionId: 'PYT237',
      dateTime: 'Feb 04, 2026 02:30 PM',
      amount: '320.00',
      balanceAfterPayout: '850.00',
    ),
    _PayoutEntry(
      transactionId: 'PYT236',
      dateTime: 'Feb 03, 2026 11:00 AM',
      amount: '180.00',
      balanceAfterPayout: '530.00',
    ),
  ];

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
      child: CommonBackground(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: S.of(context).history,
          onTap: () => Get.back(),
        ),
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final payouts = _samplePayouts; // Replace with controller/API list

    if (payouts.isEmpty) {
      return NoDataWidget(
        context,
        S.of(context).history,
        S.of(context).noPayoutsYet,
        'lib/assets/images/nonotifications.png',
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildTotalPayoutBalanceCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: _buildSearchBar(context),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final p = payouts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PayoutItem(
                    transactionId: p.transactionId,
                    dateTime: p.dateTime,
                    amount: p.amount,
                    balanceAfterPayout: p.balanceAfterPayout,
                    currency: _sampleCurrency,
                  ),
                );
              },
              childCount: payouts.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
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
      child: Column(
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
