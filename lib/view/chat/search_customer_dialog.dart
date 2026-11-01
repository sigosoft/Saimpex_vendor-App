import 'package:saimpex_vendor/resources/fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/controller/chat_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/widgets/app_loader.dart';
import 'package:saimpex_vendor/utils/widgets/custom_search_box.dart';
import 'package:saimpex_vendor/view/chat/ChatDetails.dart';
import '../../configs/ApiConfigs.dart';
import '../../resources/colors.dart';

class SearchCustomerDialog extends StatelessWidget {
  const SearchCustomerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: GetBuilder<ChatController>(
          builder: (controller) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).search,
                      style: appFont('Rubik', 
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomSearchBox(
                  hintText: S.of(context).searchNameOrMobileNumber,
                  boxColor: const Color(0xFFF1F5F9),
                  width: double.infinity,
                  controller: controller.customerSearchController,
                  onChanged: (value) {
                    controller.searchCustomers(value);
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: controller.isLoadingSearch
                      ? const Center(child: AppLoader())
                      : controller.customerSearchController.text.trim().isEmpty
                      ? const SizedBox.shrink()
                      : controller.customerResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "lib/assets/images/nodata.png",
                                height: 100,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                S
                                    .of(context)
                                    .currentlyNoContactsFoundPleaseTryLater,
                                style: appFont('Rubik', 
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: controller.customerResults.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final customer = controller.customerResults[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              onTap: () {
                                Get.back(); // close dialog
                                Get.to(
                                  () => ChatDetails(
                                    contactName:
                                        customer.name ?? S.of(context).unknown,
                                    conversationId: 0,
                                    customerId: customer.id,
                                  ),
                                );
                              },
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE8EAF6),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: ClipOval(
                                  child:
                                      customer.image != null &&
                                          customer.image!.isNotEmpty
                                      ? Image.network(
                                          ApiConfigs.IMAGE_URL +
                                              customer.image!,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  _buildInitials(customer.name),
                                        )
                                      : _buildInitials(customer.name),
                                ),
                              ),
                              title: Text(
                                customer.name ?? S.of(context).unknown,
                                style: appFont('Rubik', 
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                customer.mobile ?? "",
                                style: appFont('Rubik', 
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInitials(String? name) {
    return Text(
      name?.isNotEmpty == true ? name!.substring(0, 1).toUpperCase() : "U",
      style: appFont('Rubik', 
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorPrimary,
      ),
    );
  }
}
