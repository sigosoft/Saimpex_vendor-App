import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../controller/payout_controller.dart';
import '../../generated/l10n.dart';
import '../../model/received_payout_model.dart';
import '../../resources/colors.dart';
import '../../utils/widgets/no_data_widget.dart';
import 'payoutitem.dart';
import 'payout_viewall_screen.dart';

/// Content to show under the "Received Payouts" tab: balance card, history header, search, and list (max 5).
class PayoutListScreen extends StatefulWidget {
  const PayoutListScreen({super.key});

  @override
  State<PayoutListScreen> createState() => _PayoutListScreenState();
}

class _PayoutListScreenState extends State<PayoutListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  static const String _currency = 'MRU';
  static const int _maxItems = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<PayoutController>()) {
        Get.find<PayoutController>().getReceivedPayouts(context);
      }
    });
  }

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
      child: GetBuilder<PayoutController>(
        init: PayoutController(),
        builder: (controller) {
          if (controller.isLoading && controller.receivedPayoutsList.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: colorPrimary));
          }
          return _buildContent(context, controller);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PayoutController controller) {
    final allPayouts = controller.receivedPayoutsList;
    final payouts = allPayouts.take(_maxItems).toList();
    final showNoData = payouts.isEmpty && !controller.isLoading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTotalPayoutBalanceCard(controller.totalPayoutbalance),
        const SizedBox(height: 10),
        _buildHistoryHeader(context),
        const SizedBox(height: 12),
        _buildSearchBar(context, controller),
        if (showNoData) ...[
          const SizedBox(height: 24),
          NoDataWidget(
            context,
            S.of(context).noPayoutsYet,
            S.of(context).noPayoutsYet,
            'lib/assets/images/nodata.png',
          ),
        ] else ...[
          const SizedBox(height: 16),
          ...payouts.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _payoutItemFromDatum(d),
              )),
        ],
      ],
    );
  }

  Widget _payoutItemFromDatum(Datum d) {
    final dateTimeStr = d.paidAt != null
        ? DateFormat('MMM dd, yyyy h:mm a').format(d.paidAt!)
        : '—';
    return PayoutItem(
      transactionId: 'PYT${d.id ?? ""}',
      dateTime: dateTimeStr,
      amount: d.amount ?? '0',
      balanceAfterPayout: d.balanceAmount ?? '0',
      currency: _currency,
    );
  }

  Widget _buildTotalPayoutBalanceCard(String balance) {
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
                balance,
                style: GoogleFonts.rubik(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _currency,
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

  Widget _buildSearchBar(BuildContext context, PayoutController controller) {
    if (_searchController.text != controller.keyword && !_searchFocusNode.hasFocus) {
      _searchController.text = controller.keyword;
    }
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
      onSubmitted: (value) => controller.searchPayouts(context, value),
      onChanged: (value) => controller.searchPayouts(context, value),
    );
  }
}
