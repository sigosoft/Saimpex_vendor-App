import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../controller/notification_controller.dart';
import '../../generated/l10n.dart';
import '../../resources/colors.dart';
import '../../utils/Widgets/custom_app_bar.dart';
import '../../utils/widgets/common_background.dart';
import '../../utils/widgets/no_data_widget.dart';
import '../shimmer_loading/shimmer_notification.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  void initState() {
    super.initState();
    Get.put(NotificationController(), permanent: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<NotificationController>().getNotifications(context);
    });
  }

  @override
  void dispose() {
    if (Get.isRegistered<NotificationController>()) {
      Get.delete<NotificationController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = FlutterLocalization.instance;

    return Directionality(
      textDirection: localization.currentLocale?.languageCode == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: CommonBackground(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(title: S.of(context).notifications,onTap: (){Get.back();},),
        child: GetBuilder<NotificationController>(
          builder: (controller) {
            if (controller.isLoading) {
              return const ShimmerNotification();
            }
            if (controller.notificationList.isEmpty) {
              return NoDataWidget(
                  context,
                  S.of(context).noNotifications,
                  S.of(context).noNotificationsFound,
                  "lib/assets/images/nonotifications.png",
              );
            }
            return ListView.separated(
              controller: controller.scrollController,
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                bottom: 15,
                top: 10,
              ),
              itemCount: controller.notificationList.length +
                  (controller.isLoadMoreRunning ? 1 : 0),
              separatorBuilder: (context, index) {
                if (index == controller.notificationList.length - 1) {
                  return const SizedBox(height: 10);
                }
                return const SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                // Show loading indicator at the end when loading more
                if (index == controller.notificationList.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator(color: colorPrimary,)),
                  );
                }

                final notification = controller.notificationList[index];
                String? content = notification.contentEn.toString();
                if (localization.currentLocale!.languageCode == "ar") {
                  content = notification.contentAr!.isNotEmpty
                      ? notification.contentAr
                      : notification.contentEn;
                } else if (localization.currentLocale!.languageCode == "fr") {
                  content = notification.contentFr!.isNotEmpty
                      ? notification.contentFr
                      : notification.contentEn;
                }
                return NotificationItem(
                  context: context,
                  message: content,
                  time: _formatNotificationTime(
                    notification.createdAt.toString(),
                    notification.time.toString(),
                    notification.date.toString(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatNotificationTime(String createdAt, String time, String date) {
    try {
      DateTime dateTime;

      // First, try to use notificationsCreatedAt (full datetime string)
      if (createdAt.isNotEmpty) {
        try {
          dateTime = DateTime.parse(createdAt);
          return DateFormat('h:mm a').format(dateTime);
        } catch (e) {
          debugPrint("Failed to parse createdAt: $e");
        }
      }

      // Fallback: Try combining date and time
      if (date.isNotEmpty && time.isNotEmpty) {
        try {
          dateTime = DateTime.parse("$date $time");
          return DateFormat('h:mm a').format(dateTime);
        } catch (e) {
          // If that fails, try parsing just the time with today's date
          try {
            final now = DateTime.now();
            final parsedTime = DateFormat("HH:mm").parse(time);
            dateTime = DateTime(
              now.year,
              now.month,
              now.day,
              parsedTime.hour,
              parsedTime.minute,
            );
            return DateFormat('h:mm a').format(dateTime);
          } catch (e2) {
            // If time parsing fails, try parsing the date
            try {
              dateTime = DateTime.parse(date);
              return DateFormat('h:mm a').format(dateTime);
            } catch (e3) {
              // Return original time if all parsing fails
            }
          }
        }
      } else if (time.isNotEmpty) {
        // If only time is available, parse it with today's date
        try {
          final now = DateTime.now();
          final parsedTime = DateFormat("HH:mm").parse(time);
          dateTime = DateTime(
            now.year,
            now.month,
            now.day,
            parsedTime.hour,
            parsedTime.minute,
          );
          return DateFormat('h:mm a').format(dateTime);
        } catch (e) {
          // If time is not in HH:mm format, try parsing as full datetime
          try {
            dateTime = DateTime.parse(time);
            return DateFormat('h:mm a').format(dateTime);
          } catch (e2) {
            // Return original if parsing fails
          }
        }
      } else if (date.isNotEmpty) {
        // If only date is available
        try {
          dateTime = DateTime.parse(date);
          return DateFormat('h:mm a').format(dateTime);
        } catch (e) {
          // Return original if parsing fails
        }
      }

      // If all parsing attempts fail, return the original time or date
      return time.isNotEmpty ? time : (date.isNotEmpty ? date : "");
    } catch (e) {
      debugPrint("Error formatting notification time: $e");
      return time.isNotEmpty ? time : (date.isNotEmpty ? date : "");
    }
  }

  Widget NotificationItem({
    required BuildContext context,
    required String? message,
    required String time,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          elevation: 2,
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message!,
                  style: GoogleFonts.rubik(fontSize: 13, color: Colors.black),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: AlignmentDirectional.topEnd,
                  child: Text(
                    time,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.rubik(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
