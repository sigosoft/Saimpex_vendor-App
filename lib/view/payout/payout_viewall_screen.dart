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
import '../../utils/Widgets/custom_app_bar.dart';
import '../../utils/widgets/no_data_widget.dart';
import 'payoutitem.dart';

/// Full-screen payout history: app bar "History", balance card, search bar, and list with pagination.
class PayoutViewAllScreen extends StatefulWidget {
  const PayoutViewAllScreen({super.key});

  @override
  State<PayoutViewAllScreen> createState() => _PayoutViewAllScreenState();
}

class _PayoutViewAllScreenState extends State<PayoutViewAllScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  static const String _currency = 'MRU';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isRegistered<PayoutController>()) return;
      final controller = Get.find<PayoutController>();
      if (controller.receivedPayoutsList.isEmpty && !controller.isLoading) {
        controller.getReceivedPayouts(context);
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
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: CustomAppBar(
                title: S.of(context).history,
                onTap: () => Get.back(),
              ),
              body: const Center(
                child: CircularProgressIndicator(color: colorPrimary),
              ),
            );
          }
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: CustomAppBar(
              title: S.of(context).history,
              onTap: () => Get.back(),
            ),
            body: _buildBody(context, controller),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, PayoutController controller) {
    final payouts = controller.receivedPayoutsList;
    final showNoData = payouts.isEmpty && !controller.isLoading;

    return CustomScrollView(
      controller: controller.scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildTotalPayoutBalanceCard(controller.totalPayoutbalance),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: _buildSearchBar(context, controller),
          ),
        ),
        if (showNoData)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1,
              ),
              child: NoDataWidget(
                context,
                S.of(context).noPayoutsYet,
                S.of(context).noPayoutsYet,
                'lib/assets/images/nodata.png',
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == payouts.length) {
                    return controller.isLoadMoreRunning
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: colorPrimary,
                              ),
                            ),
                          )
                        : const SizedBox(height: 24);
                  }
                  final d = payouts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _payoutItemFromDatum(d),
                  );
                },
                childCount:
                    payouts.length + (controller.isLoadMoreRunning ? 1 : 0),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
          colors: [colorPrimary, colorPrimary.withOpacity(0.85)],
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

  Widget _buildSearchBar(BuildContext context, PayoutController controller) {
    if (_searchController.text != controller.keyword &&
        !_searchFocusNode.hasFocus) {
      _searchController.text = controller.keyword;
    }
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: S.of(context).searchAmountOrTransactionId,
        hintStyle: GoogleFonts.rubik(fontSize: 14, color: Colors.grey.shade500),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      style: GoogleFonts.rubik(fontSize: 14),
      onSubmitted: (value) => controller.searchPayouts(context, value),
      onChanged: (value) => controller.searchPayouts(context, value),
    );
  }
}
