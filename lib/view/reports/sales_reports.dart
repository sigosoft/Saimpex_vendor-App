import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../Utils/Utils.dart';
import '../../controller/sales_report_controller.dart';
import '../../generated/l10n.dart';
import '../../model/sales_report_model.dart';
import '../../resources/colors.dart';
import '../../utils/widgets/no_data_widget.dart';
import 'report_details_screen.dart';

/// Content under the "Restaurant Reports" tab: Sales Report filter + list from API with pagination.
class SalesReportsScreen extends StatefulWidget {
  const SalesReportsScreen({super.key});

  @override
  State<SalesReportsScreen> createState() => _SalesReportsScreenState();
}

class _SalesReportsScreenState extends State<SalesReportsScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;

  static const String _currency = 'MRU';

  @override
  Widget build(BuildContext context) {
    final localization = FlutterLocalization.instance;
    final isRtl = localization.currentLocale?.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: GetBuilder<SalesReportController>(
        init: SalesReportController(),
        builder: (controller) {
          if (controller.isLoading && controller.reportsList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: colorPrimary),
              ),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, controller),
              const SizedBox(height: 16),
              _buildDateFilterCard(context, controller),
              const SizedBox(height: 20),
              _buildReportList(context, controller),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReportList(BuildContext context, SalesReportController controller) {
    final list = controller.reportsList;
    if (list.isEmpty && !controller.isLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: NoDataWidget(
          context,
          S.of(context).noReportsInThisDateRange,
          S.of(context).noReportsInThisDateRange,
          'lib/assets/images/nonotifications.png',
        ),
      );
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.48,
      child: ListView.builder(
        controller: controller.scrollController,
        padding: EdgeInsets.zero,
        itemCount: list.length + (controller.isLoadMoreRunning ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == list.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: colorPrimary)),
            );
          }
          final datum = list[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildReportCardFromDatum(context, datum),
          );
        },
      ),
    );
  }

  String _customerName(Datum d) {
    if (d.userDisplayName != null && d.userDisplayName!.isNotEmpty) return d.userDisplayName!;
    if (d.userName != null) return userNameValues.reverse[d.userName!] ?? 'Customer';
    return 'Customer';
  }

  String _statusString(int? status) {
    if (status == null) return 'PENDING';
    return status == 1 ? 'COMPLETED' : 'PENDING';
  }

  String _dateTimeStr(DateTime? placedAt) {
    if (placedAt == null) return '—';
    return DateFormat('MMM dd, yyyy h:mm a').format(placedAt);
  }

  Widget _buildReportCardFromDatum(BuildContext context, Datum datum) {
    final statusStr = _statusString(datum.status);
    final isCompleted = statusStr == 'COMPLETED';
    final statusBg = isCompleted ? green : yellow;
    final amountColor = isCompleted ? const Color(0xFF1F1F1F) : colorPrimary;
    final phone = '${datum.countryCode ?? ''} ${datum.userMobile ?? ''}'.trim();
    final dateTimeStr = _dateTimeStr(datum.placedAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: buttonbg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  datum.orderCode ?? '—',
                  style: GoogleFonts.rubik(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusStr,
                  style: GoogleFonts.rubik(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _customerName(datum),
                      style: GoogleFonts.rubik(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.phone_rounded, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          phone.isEmpty ? '—' : phone,
                          style: GoogleFonts.rubik(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dateTimeStr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.rubik(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    S.of(context).totalAmount,
                    style: GoogleFonts.rubik(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${datum.total ?? '0'} $_currency',
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                final earning = datum.orderEarnings?.isNotEmpty == true
                    ? datum.orderEarnings!.first
                    : null;
                Get.to(() => ReportDetailsScreen(
                      params: ReportDetailsParams(
                        orderId: datum.orderCode ?? '—',
                        status: statusStr,
                        customerName: _customerName(datum),
                        phone: phone.isEmpty ? '—' : phone,
                        dateTime: dateTimeStr,
                        totalAmount: datum.total ?? '0',
                        subtotal: datum.subtotal ?? '0',
                        discount: datum.discount ?? '0',
                        deliveryFee: datum.deliveryFee ?? '0',
                        tax: datum.tax ?? '0',
                        earnings: earning?.totalAmount ?? datum.subtotal ?? '0',
                        commission: earning?.commissionAmount ?? '0',
                        paymentMethod: datum.paymentType ?? 'Cash',
                        currency: _currency,
                      ),
                    ));
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: colorPrimary,
                side: BorderSide(color: colorPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                S.of(context).viewDetails,
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SalesReportController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Sales Report',
          style: GoogleFonts.rubik(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F1F1F),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (_fromDate == null || _toDate == null) {
                showToast(context, S.of(context).pleaseSelectFromDateAndToDate);
                return;
              }
              controller.setDateRange(_fromDate, _toDate);
              controller.restaurantReportDownload(context);
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: buttonbg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorPrimary),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context).download,
                    style: GoogleFonts.rubik(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Image.asset(
                    'lib/assets/images/download.png',
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.download_rounded,
                      size: 15,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilterCard(BuildContext context, SalesReportController controller) {
    final fromStr = _fromDate != null
        ? '${_fromDate!.day.toString().padLeft(2, '0')}-${_fromDate!.month.toString().padLeft(2, '0')}-${_fromDate!.year}'
        : 'dd-mm-yyyy';
    final toStr = _toDate != null
        ? '${_toDate!.day.toString().padLeft(2, '0')}-${_toDate!.month.toString().padLeft(2, '0')}-${_toDate!.year}'
        : 'dd-mm-yyyy';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: S.of(context).fromDate,
                  value: fromStr,
                  onTap: () async {
                    final picked = await _showThemedDatePicker(
                      context: context,
                      initialDate: _fromDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _fromDate = picked);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  label: S.of(context).toDate,
                  value: toStr,
                  onTap: () async {
                    final picked = await _showThemedDatePicker(
                      context: context,
                      initialDate: _toDate ?? DateTime.now(),
                      firstDate: _fromDate ?? DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _toDate = picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                controller.setDateRange(_fromDate, _toDate);
                controller.getRestaurantReports(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'View Reports',
                style: GoogleFonts.rubik(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.rubik(
            fontSize: 12,
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.rubik(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: value == 'dd-mm-yyyy'
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF1F1F1F),
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: Color(0xFF1F1F1F),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<DateTime?> _showThemedDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        final base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            colorScheme: base.colorScheme.copyWith(
              primary: colorPrimary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
