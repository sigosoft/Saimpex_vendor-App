import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../utils/widgets/common_background.dart';
import '../../utils/widgets/no_data_widget.dart';
import '../../controller/profile_controller.dart';
import '../../generated/l10n.dart';
import '../../utils/widgets/app_loader.dart';

class LeaveHistoryScreen extends StatefulWidget {
  const LeaveHistoryScreen({super.key});

  @override
  State<LeaveHistoryScreen> createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final profileController = Get.find<ProfileController>();
      if (!profileController.isLoadMoreLeaveLoading &&
          profileController.hasMoreLeaveHistory) {
        profileController.getProfile(
          context,
          page: profileController.currentLeavePage + 1,
          isLoadMore: true,
        );
      }
    }
  }

  String _formatLeaveDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      return "${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}";
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: Text(
          S.of(context).leavesHistory,
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        centerTitle: false,
      ),
      child: GetBuilder<ProfileController>(
        builder: (profileController) {
          final upcomingLeaves = profileController.upcomingLeaves;
          final leaveHistory = profileController.leaveHistory;

          if (profileController.isProfileLoading &&
              upcomingLeaves.isEmpty &&
              leaveHistory.isEmpty) {
            return const AppLoader();
          }

          if (upcomingLeaves.isEmpty && leaveHistory.isEmpty) {
            return Center(
              child: NoDataWidget(
                context,
                S.of(context).noLeaveHistoryFound,
                "",
                "lib/assets/images/nodata.png",
                imgHeight: MediaQuery.of(context).size.height * 0.25,
                imgWidth: MediaQuery.of(context).size.width * 0.6,
                fontSize: 18,
              ),
            );
          }

          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              Text(
                S.of(context).upcomingLeaves,
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 95, 145, 245),
                ),
              ),
              const SizedBox(height: 12),
              if (upcomingLeaves.isNotEmpty)
                ...upcomingLeaves.map(
                  (leave) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildLeaveTile(
                      context: context,
                      controller: profileController,
                      dateRange: _formatLeaveDate(leave.date),
                      reason: leave.reason ?? S.of(context).leave,
                      status: S.of(context).scheduled,
                      isUpcoming: true,
                      leave_id: leave.id.toString()
                    ),
                  ),
                )
              else
                NoDataWidget(
                  context,
                  S.of(context).noUpcomingLeavesFound,
                  "",
                  "lib/assets/images/nodata.png",
                  imgHeight: MediaQuery.of(context).size.height * 0.25,
                  imgWidth: MediaQuery.of(context).size.width * 0.6,
                  fontSize: 18,
                ),
              const SizedBox(height: 24),
              Text(
                S.of(context).completedLeaves,
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 35, 208, 102),
                ),
              ),
              const SizedBox(height: 12),
              if (leaveHistory.isNotEmpty)
                ...leaveHistory.map(
                  (leave) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildLeaveTile(
                      context: context,
                      controller: profileController,
                      dateRange: _formatLeaveDate(leave.date),
                      reason: leave.reason ?? S.of(context).leave,
                      status: S.of(context).completed,
                      isUpcoming: false,
                      leave_id: leave.id.toString()
                    ),
                  ),
                )
              else
                NoDataWidget(
                  context,
                  S.of(context).noCompletedLeavesFound,
                  "",
                  "lib/assets/images/nodata.png",
                  imgHeight: MediaQuery.of(context).size.height * 0.25,
                  imgWidth: MediaQuery.of(context).size.width * 0.6,
                  fontSize: 18,
                ),
              if (profileController.isLoadMoreLeaveLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: AppLoader(size: 40)),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeaveTile({
    required BuildContext context,
    required ProfileController controller,
    required String dateRange,
    required String reason,
    required String status,
    required bool isUpcoming, required String leave_id,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateRange,
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F1F1F),
                    ),
                  ),
                  Text(
                    reason,
                    style: GoogleFonts.rubik(
                      fontSize: 10,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? const Color(0xFFEEF2FF)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.rubik(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isUpcoming
                        ? const Color(0xFF4F46E1)
                        : const Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
          if (isUpcoming) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: OutlinedButton(
                onPressed: () {
                  controller.unmarkLeave(
                    context,
                    leave_id);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFCCBD)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  S.of(context).cancelLeave,
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF5216),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
