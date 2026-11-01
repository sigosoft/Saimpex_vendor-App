import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/controller/preorders_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/widgets/app_loader.dart';
import 'package:saimpex_vendor/utils/widgets/no_data_widget.dart';
import 'package:saimpex_vendor/view/home/vendor_order_details.dart';
import 'package:saimpex_vendor/view/home/widgets/preorder_badge.dart';

/// Upcoming pre-orders, soonest first (`GET vendorapp/preorders`).
/// No Figma screen: built in the style of the order cards.
class PreordersScreen extends StatefulWidget {
  const PreordersScreen({super.key});

  @override
  State<PreordersScreen> createState() => _PreordersScreenState();
}

class _PreordersScreenState extends State<PreordersScreen> {
  final PreordersController controller = Get.isRegistered<PreordersController>()
      ? Get.find<PreordersController>()
      : Get.put(PreordersController());

  @override
  void initState() {
    super.initState();
    controller.fetch();
  }

  String _statusLabel(int status) {
    switch (status) {
      case 1:
        return S.current.pending;
      case 2:
        return S.current.accepted;
      case 3:
        return S.current.preparing;
      case 4:
        return S.current.ready;
      case 5:
        return S.current.assignedStatus;
      case 6:
        return S.current.reachedRestaurant;
      case 7:
        return S.current.pickedUp;
      case 8:
        return S.current.delivering;
      default:
        return S.current.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF333E63), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.of(context).preOrders,
          style: appFont('Rubik', 
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF333E63),
          ),
        ),
      ),
      body: GetBuilder<PreordersController>(
        builder: (c) => RefreshIndicator(
          color: colorPrimary,
          onRefresh: c.fetch,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (c.isLoading && c.preorders.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: AppLoader()),
                )
              else if (c.preorders.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: NoDataWidget(
                    context,
                    S.of(context).noUpcomingPreorders,
                    '',
                    'lib/assets/images/nodata.png',
                  ),
                )
              else
                for (final p in c.preorders) _card(context, p),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, PreOrder p) {
    return GestureDetector(
      onTap: () => Get.to(() => VendorOrderDetails(orderId: p.orderId)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    S.of(context).orderIdLabel(p.orderCode),
                    style: appFont('Rubik', 
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorPrimary,
                    ),
                  ),
                ),
                Text(
                  _statusLabel(p.status).toUpperCase(),
                  style: appFont('Rubik', 
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.schedule, size: 18, color: preorderColor),
                const SizedBox(width: 6),
                Text(
                  formatPreorderTime(p.scheduledFor),
                  textDirection: TextDirection.ltr,
                  style: appFont('Rubik', 
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    preorderDueText(p.scheduledFor),
                    style: appFont('Rubik', 
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: preorderColor,
                    ),
                  ),
                ),
                Text(
                  '${p.total.toStringAsFixed(2)} MRU',
                  textDirection: TextDirection.ltr,
                  style: appFont('Rubik', 
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF333E63),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (p.isSelfPickup) _chip(S.of(context).selfPickup),
                if (p.driverAssigned)
                  _chip(S.of(context).driverAssigned)
                else if (p.driverRequested)
                  _chip(S.of(context).driverRequested),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: appFont('Rubik', 
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
      );
}
