import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class AppSettings extends StatelessWidget {
  const AppSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          onPressed: () => Get.back(),
        ),
        title: Text(
          S.of(context).settings,
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF333E63),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(color: Colors.grey.withOpacity(0.1), height: 1),
        ),
      ),
      body: GetBuilder<ProfileController>(
        builder: (controller) {
          return Column(
            children: [
              const SizedBox(height: 10),
              // _buildSettingItem(
              //   title: S.of(context).notification,
              //   trailing: Transform.scale(
              //     scale: 0.8,
              //     child: Switch(
              //       value: controller.notificationEnabled,
              //       activeTrackColor: const Color(0xFFFF5216),
              //       activeColor: Colors.white,
              //       onChanged: (value) {
              //         controller.notificationEnabled = value;
              //         controller.updateNotificationStatus(context);
              //       },
              //     ),
              //   ),
              // ),
              // SizedBox(height: 5),
              // const Divider(height: 1, indent: 0, endIndent: 0),
              SizedBox(height: 5),
              _buildSettingItem(
                title: S.of(context).deleteAccount,
                titleColor: const Color(0xFFFF5216),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
                onTap: () {
                  _showDeleteConfirmationDialog(context, controller);
                },
              ),
              SizedBox(height: 5),
               Divider(height: 1, indent: 0, endIndent: 0,color: Colors.grey.shade200,),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required Widget trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.rubik(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: titleColor ?? const Color(0xFF475569),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    ProfileController controller,
  ) {
    showConfirmationBottomSheet(
      context: context,
      title: S.of(context).deleteAccount,
      message: S.of(context).areYouSureYouWantToDeleteYourAccount,
      leftButtonText: S.of(context).cancel,
      rightButtonText: S.of(context).delete,
      onConfirm: () => controller.deleteAccount(context),
    );
  }
}
