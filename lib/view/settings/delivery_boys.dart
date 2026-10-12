import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/controller/delivery_boys_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/model/delivery_boys_model.dart';
import 'package:saimpex_vendor/resources/colors.dart';
import 'package:saimpex_vendor/utils/widgets/app_loader.dart';
import 'package:saimpex_vendor/utils/widgets/custom_search_box.dart';
import 'package:saimpex_vendor/utils/widgets/no_data_widget.dart';
import 'package:saimpex_vendor/view/settings/add_delivery_boy_screen.dart';

class DeliveryBoysScreen extends StatefulWidget {
  const DeliveryBoysScreen({super.key, this.isPharmacy = false});

  final bool isPharmacy;

  @override
  State<DeliveryBoysScreen> createState() => _DeliveryBoysScreenState();
}

class _DeliveryBoysScreenState extends State<DeliveryBoysScreen> {
  final FlutterLocalization localization = FlutterLocalization.instance;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: localization.currentLocale?.languageCode == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF7F3),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF333E63),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            S.of(context).deliveryBoys,
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF333E63),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    final added = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddDeliveryBoyScreen(),
                      ),
                    );
                    if (added == true) {
                      final c = Get.isRegistered<DeliveryBoysController>()
                          ? Get.find<DeliveryBoysController>()
                          : Get.put(DeliveryBoysController());
                      c.getDeliveryBoys(isPharmacy: widget.isPharmacy);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: colorPrimary, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, color: colorPrimary, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'Add Delivery Boy',
                          style: GoogleFonts.rubik(
                            color: colorPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Divider(color: Colors.grey.withOpacity(0.1), height: 1),
          ),
        ),
        body: GetBuilder<DeliveryBoysController>(
          init: DeliveryBoysController(),
          didChangeDependencies: (state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              state.controller?.getDeliveryBoys(isPharmacy: widget.isPharmacy);
            });
          },
          builder: (controller) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  CustomSearchBox(
                    hintText: S.of(context).searchNameOrMobileNumber,
                    boxColor: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.9,
                    controller: searchController,
                    onChanged: (value) {
                      controller.filterBoys(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (controller.isLoading)
                    const AppLoader()
                  else if (controller.filteredList.isEmpty)
                    NoDataWidget(
                      context,
                      S.of(context).noDeliveryBoysFound,
                      "",
                      "lib/assets/images/nodata.png",
                    )
                  else
                    ...controller.filteredList
                        .map((data) => _buildDeliveryBoyTile(data))
                        .toList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDeliveryBoyTile(DeliveryBoy data) {
    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => AddDeliveryBoyScreen(deliveryBoy: data),
          ),
        );
        if (updated == true) {
          final c = Get.isRegistered<DeliveryBoysController>()
              ? Get.find<DeliveryBoysController>()
              : Get.put(DeliveryBoysController());
          c.getDeliveryBoys(isPharmacy: widget.isPharmacy);
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.13,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: MediaQuery.of(context).size.width * 0.15,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(15),
                    image: data.image != null && data.image!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(
                              ApiConfigs.IMAGE_URL + data.image!,
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: data.image == null || data.image!.isEmpty
                      ? const Icon(Icons.person, color: Colors.grey, size: 40)
                      : null,
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: data.status == 1
                              ? const Color(0xFF10B981)
                              : Colors.grey, // Green dot if active
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.name ?? "",
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333E63),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: data.status == 1
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          data.status == 1
                              ? S.of(context).active
                              : S.of(context).inactive,
                          style: GoogleFonts.rubik(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: data.status == 1
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 12,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        data.mobile ?? "",
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          data.address ?? "",
                          style: GoogleFonts.rubik(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
