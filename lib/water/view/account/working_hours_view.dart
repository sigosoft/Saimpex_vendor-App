import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/profile_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/vendor_app_router.dart';
import 'package:saimpex_vendor/water/view/account/edit_working_hour_dialog.dart';

class WorkingHoursView extends StatefulWidget {
  const WorkingHoursView({super.key});

  static const orange = Color(0xFFFF5216);
  static const ink = Color(0xFF1C1D1B);
  static const day = Color(0xFF2A2A2A);
  static const muted = Color(0xFF5A423B);
  static const closed = Color(0xFFBA1B1B);
  static const allDayHours = '12:00 AM - 11:59 PM';

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const WorkingHoursView()),
    );
  }

  @override
  State<WorkingHoursView> createState() => _WorkingHoursViewState();
}

class _WorkingHoursViewState extends State<WorkingHoursView> {
  bool open24Hours = false;

  final schedule = [
    _DayHours(day: 'Monday', hours: '08:00 AM - 10:00 PM'),
    _DayHours(day: 'Tuesday', hours: '08:00 AM - 10:00 PM'),
    _DayHours(day: 'Wednesday', hours: '08:00 AM - 10:00 PM'),
    _DayHours(day: 'Thursday', hours: '08:00 AM - 10:00 PM'),
    _DayHours(day: 'Friday', hours: '08:00 AM - 10:00 PM'),
    _DayHours(day: 'Saturday', hours: '08:00 AM - 10:00 PM'),
    _DayHours(day: 'Sunday', hours: 'Closed', closed: true),
  ];

  @override
  void initState() {
    super.initState();
    _fetchWorkingHours();
  }

  Future<void> _fetchWorkingHours() async {
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty && token != "null") {
        DioClient().updateToken(token);
      } else {
        return;
      }

      final savedVendorType = await getSavedObject("vendorType");
      final savedAppType = await getSavedObject(VendorAppRouter.storageKey);
      final vendorTypeStr = (savedVendorType != null &&
              savedVendorType.toString().isNotEmpty &&
              savedVendorType.toString() != "0")
          ? savedVendorType.toString()
          : (savedAppType?.toString().isNotEmpty == true
              ? savedAppType.toString()
              : "1");
      final vendorType = int.tryParse(vendorTypeStr) ?? 1;

      final queryParams = <String, dynamic>{
        "vendor_type": vendorType,
      };

      debugPrint("==================== GET WATER WORKING HOURS ====================");
      debugPrint("Endpoint: ${ApiEndPoints.profile}");
      debugPrint("Query: $queryParams");
      print("==================== GET WATER WORKING HOURS ====================");
      print("Endpoint: ${ApiEndPoints.profile}");
      print("Query: $queryParams");

      final response = await DioClient().get(
        ApiEndPoints.profile,
        query: queryParams,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      print("Response Status Code: ${response.statusCode}");

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        try {
          dataMap = jsonDecode(response.data as String) as Map<String, dynamic>?;
        } catch (_) {}
      }

      if (dataMap != null && mounted) {
        final profileModel = ProfileModel.fromJson(dataMap);
        final list = profileModel.workingHours;
        if (list != null && list.isNotEmpty) {
          _populateWorkingHours(list);
        }
      }
    } catch (e) {
      debugPrint("Error fetching working hours: $e");
    }
  }

  void _populateWorkingHours(List<WorkingHour> list) {
    bool all24 = true;
    for (int i = 0; i < 7; i++) {
      final dayId = i + 1;
      final h = list.cast<WorkingHour?>().firstWhere(
            (item) => item?.dayOfWeek == dayId,
            orElse: () => null,
          );
      if (h == null) {
        all24 = false;
        continue;
      }
      final dayName = schedule[i].day;
      if (h.isOpen24h == 1) {
        schedule[i] = _DayHours(
          day: dayName,
          hours: '24-Hour Open',
          closed: false,
          open24Hours: true,
          startTime: '00:00',
          endTime: '23:59',
        );
      } else if (h.isClosed == true) {
        all24 = false;
        schedule[i] = _DayHours(
          day: dayName,
          hours: 'Closed',
          closed: true,
          open24Hours: false,
        );
      } else {
        all24 = false;
        String open = h.openingTime ?? '08:00';
        String close = h.closingTime ?? '22:00';
        if (h.timeSlots != null && h.timeSlots!.isNotEmpty) {
          open = h.timeSlots!.first.openTime ?? open;
          close = h.timeSlots!.first.closeTime ?? close;
        }
        final startFormatted = _formatTimePart(open);
        final endFormatted = _formatTimePart(close);
        schedule[i] = _DayHours(
          day: dayName,
          hours: _formatRange(startFormatted, endFormatted),
          closed: false,
          open24Hours: false,
          startTime: startFormatted,
          endTime: endFormatted,
        );
      }
    }
    setState(() {
      open24Hours = all24 && list.length == 7;
    });
  }

  String _formatTimePart(String timeStr) {
    final parts = timeStr.trim().split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    }
    return timeStr.trim();
  }

  String _extractMessage(dynamic resData, String defaultMessage) {
    if (resData is Map && resData['message'] != null) {
      final msg = resData['message'];
      if (msg is Map) {
        String lang = 'en';
        try {
          lang = FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';
        } catch (_) {}
        final key = lang == 'ar'
            ? 'message_ar'
            : lang == 'fr'
                ? 'message_fr'
                : 'message_en';
        if (msg[key] != null) {
          final raw = msg[key];
          if (raw is List && raw.isNotEmpty) {
            return raw.first.toString();
          }
          return raw.toString();
        }
        if (msg['message_en'] != null) {
          final raw = msg['message_en'];
          if (raw is List && raw.isNotEmpty) {
            return raw.first.toString();
          }
          return raw.toString();
        }
      } else if (msg is String && msg.trim().isNotEmpty) {
        return msg.trim();
      }
    }
    return defaultMessage;
  }

  Future<bool> _uploadWorkingHours() async {
    showLoadingDialog(context);
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty && token != "null") {
        DioClient().updateToken(token);
      }

      final savedVendorType = await getSavedObject("vendorType");
      final savedAppType = await getSavedObject(VendorAppRouter.storageKey);
      final vendorTypeStr = (savedVendorType != null &&
              savedVendorType.toString().isNotEmpty &&
              savedVendorType.toString() != "0")
          ? savedVendorType.toString()
          : (savedAppType?.toString().isNotEmpty == true
              ? savedAppType.toString()
              : "1");
      final vendorType = int.tryParse(vendorTypeStr) ?? 1;

      final daysPayload = List.generate(7, (i) {
        final dayId = i + 1;
        final d = schedule[i];
        if (open24Hours || d.open24Hours) {
          return {
            "day_id": dayId,
            "is_24h": 1,
            "hours": <dynamic>[],
          };
        }
        if (d.closed) {
          return {
            "day_id": dayId,
            "is_24h": 2,
            "hours": <dynamic>[],
          };
        }
        return {
          "day_id": dayId,
          "is_24h": 2,
          "hours": [
            {
              "open_time": d.startTime,
              "close_time": d.endTime,
            }
          ],
        };
      });

      final Map<String, dynamic> body = {
        "vendor_type": vendorType,
        "days": daysPayload,
      };

      debugPrint("==================== POST UPLOAD WORKING HOURS ====================");
      debugPrint("Endpoint: ${ApiEndPoints.uploadWorkingHours}");
      debugPrint("Body: ${jsonEncode(body)}");

      print("==================== POST UPLOAD WORKING HOURS ====================");
      print("Endpoint: ${ApiEndPoints.uploadWorkingHours}");
      print("Body: ${jsonEncode(body)}");

      final response = await DioClient().post(
        ApiEndPoints.uploadWorkingHours,
        body: body,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("==================================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("==================================================================");

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      final resData = response.data;
      final bool isSuccess = resData is Map &&
          (resData['status'] == true ||
              resData['status'].toString() == 'true' ||
              resData['status'] == 1 ||
              resData['status'] == '1');

      if (isSuccess) {
        HapticFeedback.lightImpact();
        if (mounted) {
          String message = _extractMessage(resData, S.current.waterWorkingHoursUpdated);
          showToast(context, message);
        }
        return true;
      } else {
        if (mounted) {
          String message = _extractMessage(resData, S.current.waterFailedToUpdateWorkingHours);
          showToast(context, message);
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      debugPrint("==================== POST UPLOAD WORKING HOURS ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("=========================================================================");

      print("==================== POST UPLOAD WORKING HOURS ERROR ====================");
      print("Error: $e");
      print("=========================================================================");

      if (mounted) {
        showErrorMessage(e);
      }
      return false;
    }
  }

  Future<void> _editDay(int index) async {
    final item = schedule[index];
    final result = await showEditWorkingHourDialog(
      context,
      day: _dayLabel(context, index),
      startTime: item.startTime,
      endTime: item.endTime,
      open24Hours: item.open24Hours,
    );
    if (result == null || !mounted) return;

    final prevItem = schedule[index];
    setState(() {
      if (result.open24Hours) {
        schedule[index] = item.copyWith(
          hours: '24-Hour Open',
          closed: false,
          open24Hours: true,
          startTime: '00:00',
          endTime: '23:59',
        );
      } else {
        schedule[index] = item.copyWith(
          hours: _formatRange(result.startTime, result.endTime),
          closed: false,
          open24Hours: false,
          startTime: result.startTime,
          endTime: result.endTime,
        );
      }
    });

    final success = await _uploadWorkingHours();
    if (!success && mounted) {
      setState(() {
        schedule[index] = prevItem;
      });
    }
  }

  String _formatRange(String start, String end) {
    return '${_to12Hour(start)} - ${_to12Hour(end)}';
  }

  String _to12Hour(String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? parts[1] : '00';
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '${h12.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final today = schedule[DateTime.now().weekday - 1];
    final todayHours = open24Hours
        ? _ltr(WorkingHoursView.allDayHours)
        : _hoursLabel(context, today);
    final todayClosed = !open24Hours && today.closed;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE7DF), Color(0xFFFFF1EB), Colors.white],
              stops: [0, 0.28, 0.48],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              _Header(onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: RefreshIndicator(
                  color: WorkingHoursView.orange,
                  onRefresh: _fetchWorkingHours,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    children: [
                      _CurrentStatusCard(
                        todayHours: todayHours,
                        todayClosed: todayClosed,
                        open24Hours: open24Hours,
                        on24HourChanged: (value) async {
                          HapticFeedback.lightImpact();
                          final prev = open24Hours;
                          setState(() => open24Hours = value);
                          final success = await _uploadWorkingHours();
                          if (!success && mounted) {
                            setState(() => open24Hours = prev);
                          }
                        },
                      ),
                      const SizedBox(height: 22),
                      Text(
                        S.of(context).waterWeeklySchedule,
                        style: GoogleFonts.inter(
                          color: WorkingHoursView.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < schedule.length; i++) ...[
                              if (i > 0)
                                const Divider(height: 1, thickness: 1, color: Color(0xFFF3F3F3)),
                              _DayRow(
                                item: schedule[i],
                                dayLabel: _dayLabel(context, i),
                                hours: open24Hours ? WorkingHoursView.allDayHours : null,
                                onEdit: () => _editDay(i),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _dayLabel(BuildContext context, int index) {
  final s = S.of(context);
  return [
    s.monday,
    s.tuesday,
    s.wednesday,
    s.thursday,
    s.friday,
    s.saturday,
    s.sunday,
  ][index];
}

/// Display label for a day's hours. Time ranges are wrapped in an LTR
/// embedding so "08:00 AM - 10:00 PM" keeps its order inside RTL (Arabic) text.
String _hoursLabel(BuildContext context, _DayHours item) {
  if (item.open24Hours) return S.of(context).waterOpen24Hours;
  if (item.closed) return S.of(context).waterClosed;
  return _ltr(item.hours);
}

String _ltr(String text) => '\u202A$text\u202C';

class _DayHours {
  const _DayHours({
    required this.day,
    required this.hours,
    this.closed = false,
    this.open24Hours = false,
    this.startTime = '08:00',
    this.endTime = '22:00',
  });

  final String day;
  final String hours;
  final bool closed;
  final bool open24Hours;
  final String startTime;
  final String endTime;

  _DayHours copyWith({
    String? hours,
    bool? closed,
    bool? open24Hours,
    String? startTime,
    String? endTime,
  }) {
    return _DayHours(
      day: day,
      hours: hours ?? this.hours,
      closed: closed ?? this.closed,
      open24Hours: open24Hours ?? this.open24Hours,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              S.of(context).workingHours,
              style: GoogleFonts.inter(
                color: WorkingHoursView.ink,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: WorkingHoursView.orange,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentStatusCard extends StatelessWidget {
  const _CurrentStatusCard({
    required this.todayHours,
    required this.todayClosed,
    required this.open24Hours,
    required this.on24HourChanged,
  });

  final String todayHours;
  final bool todayClosed;
  final bool open24Hours;
  final ValueChanged<bool> on24HourChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).waterCurrentStatus,
            style: GoogleFonts.inter(
              color: const Color(0xFF8A7B76),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: GoogleFonts.inter(
                color: WorkingHoursView.ink,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              children: [
                TextSpan(text: '${S.of(context).today}: '),
                TextSpan(
                  text: todayHours,
                  style: TextStyle(
                    color: todayClosed ? WorkingHoursView.closed : WorkingHoursView.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.all_inclusive_rounded,
                color: WorkingHoursView.orange,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                S.of(context).waterOpen24Hours,
                style: GoogleFonts.inter(
                  color: WorkingHoursView.ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Switch(
                value: open24Hours,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                thumbColor: const WidgetStatePropertyAll(Colors.white),
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return WorkingHoursView.orange;
                  }
                  return const Color(0xFFE9E8E4);
                }),
                trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                onChanged: on24HourChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.item,
    required this.dayLabel,
    this.hours,
    required this.onEdit,
  });

  final _DayHours item;
  final String dayLabel;
  final String? hours;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final closed = hours == null && item.closed;
    final label = hours != null ? _ltr(hours!) : _hoursLabel(context, item);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayLabel,
                  style: GoogleFonts.inter(
                    color: WorkingHoursView.day,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: closed ? WorkingHoursView.closed : WorkingHoursView.muted,
                    fontWeight: closed ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            behavior: HitTestBehavior.opaque,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(
                  image: AssetImage('lib/water/Assets/Images/edit.png'),
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  color: WorkingHoursView.orange,
                  size: 22,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
