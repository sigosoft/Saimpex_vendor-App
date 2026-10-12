import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/configs/Dioclient.dart';
import 'package:saimpex_vendor/model/profile_model.dart';
import 'package:saimpex_vendor/utils/utils.dart';
import 'package:saimpex_vendor/utils/vendor_app_router.dart';

class PharmacyWorkingHoursScreen extends StatefulWidget {
  const PharmacyWorkingHoursScreen({super.key});

  static const orange = Color(0xFFFF5216);
  static const ink = Color(0xFF1C1D1B);
  static const day = Color(0xFF2A2A2A);
  static const muted = Color(0xFF5A423B);
  static const closed = Color(0xFFBA1B1B);

  @override
  State<PharmacyWorkingHoursScreen> createState() => _PharmacyWorkingHoursScreenState();
}

class _DayHours {
  _DayHours(this.name, {this.closed = false, this.start, this.end});

  final String name;
  bool closed;
  bool open24 = false;
  TimeOfDay? start;
  TimeOfDay? end;

  static const allDayHours = '12:00 AM - 11:59 PM';

  String get label {
    if (closed) return 'Closed';
    if (open24) return allDayHours;
    if (start != null && end != null) {
      return '${_format12(start!)} - ${_format12(end!)}';
    }
    return 'Closed';
  }
}

String _format12(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '${hour.toString().padLeft(2, '0')}:$minute $period';
}

String _format24(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

class _PharmacyWorkingHoursScreenState extends State<PharmacyWorkingHoursScreen> {
  bool _open24 = false;

  final List<_DayHours> _days = [
    _DayHours('Monday', closed: true),
    _DayHours('Tuesday', closed: true),
    _DayHours('Wednesday', closed: true),
    _DayHours('Thursday', closed: true),
    _DayHours('Friday', closed: true),
    _DayHours('Saturday', closed: true),
    _DayHours('Sunday', closed: true),
  ];

  _DayHours get _today => _days[DateTime.now().weekday - 1];

  String get _todayHours {
    if (_open24) return _DayHours.allDayHours;
    return _today.label;
  }

  @override
  void initState() {
    super.initState();
    _fetchWorkingHours();
  }

  Future<void> _fetchWorkingHours() async {
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
        DioClient().updateToken(token);
      } else {
        return;
      }

      final savedVendorType = await getSavedObject("vendorType");
      final savedAppType = await getSavedObject(VendorAppRouter.storageKey);
      final vendorType = (savedVendorType != null &&
              savedVendorType.toString().isNotEmpty &&
              savedVendorType.toString() != "0")
          ? savedVendorType.toString()
          : (savedAppType?.toString().isNotEmpty == true
              ? savedAppType.toString()
              : "3");

      final now = DateTime.now();
      final fromDate =
          "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final queryParams = <String, dynamic>{
        "vendor_type": vendorType,
        "from_date": fromDate,
        "to_date": fromDate,
      };

      final response = await DioClient().get(
        ApiEndPoints.pharmacyProfile,
        query: queryParams,
      );

      Map<String, dynamic>? dataMap;
      if (response.data is Map<String, dynamic>) {
        dataMap = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        try {
          dataMap = jsonDecode(response.data as String) as Map<String, dynamic>?;
        } catch (_) {}
      }

      if (dataMap != null) {
        final profileModel = ProfileModel.fromJson(dataMap);
        final list = profileModel.workingHours;
        if (list != null && list.isNotEmpty && mounted) {
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
      final d = _days[i];
      if (h == null) {
        d.closed = true;
        d.open24 = false;
        d.start = null;
        d.end = null;
        all24 = false;
        continue;
      }
      if (h.isOpen24h == 1) {
        d.open24 = true;
        d.closed = false;
      } else {
        all24 = false;
        d.open24 = false;
        if (h.isClosed == true) {
          d.closed = true;
        } else {
          d.closed = false;
          String? open = h.openingTime;
          String? close = h.closingTime;
          if (h.timeSlots != null && h.timeSlots!.isNotEmpty) {
            open = h.timeSlots!.first.openTime ?? open;
            close = h.timeSlots!.first.closeTime ?? close;
          }
          if (open != null && open.isNotEmpty) {
            final t = _parseTimeString(open);
            if (t != null) d.start = t;
          }
          if (close != null && close.isNotEmpty) {
            final t = _parseTimeString(close);
            if (t != null) d.end = t;
          }
        }
      }
    }
    setState(() {
      _open24 = all24 && list.length == 7;
    });
  }

  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.trim().split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (_) {}
    return null;
  }

  String _getUpdateWorkingHoursUrl() {
    final rawBase = ApiConfigs.BASE_URL.trim();
    final base = rawBase.endsWith('/') ? rawBase.substring(0, rawBase.length - 1) : rawBase;
    final endpoint = ApiEndPoints.pharmacyUpdateWorkingHours.trim().replaceFirst(RegExp(r'^/'), '');
    return '$base/$endpoint';
  }

  Future<bool> _updateWorkingHours() async {
    showLoadingDialog(context);
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty) {
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
              : "3");
      final vendorType = int.tryParse(vendorTypeStr) ?? 3;

      final daysPayload = List.generate(7, (i) {
        final dayId = i + 1;
        final d = _days[i];
        if (_open24 || d.open24) {
          return {
            "day_id": dayId,
            "is_24h": 1,
            "hours": <dynamic>[],
          };
        }
        if (d.closed || d.start == null || d.end == null) {
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
              "open_time": _format24(d.start!),
              "close_time": _format24(d.end!),
            }
          ],
        };
      });

      final Map<String, dynamic> body = {
        "vendor_type": vendorType,
        "days": daysPayload,
      };

      final url = _getUpdateWorkingHoursUrl();
      debugPrint("==================== POST UPDATE WORKING HOURS ====================");
      debugPrint("API Call: POST $url");
      debugPrint("Endpoint: ${ApiEndPoints.pharmacyUpdateWorkingHours}");
      debugPrint("Body: ${jsonEncode(body)}");

      print("==================== POST UPDATE WORKING HOURS ====================");
      print("API Call: POST $url");
      print("Endpoint: ${ApiEndPoints.pharmacyUpdateWorkingHours}");
      print("Body: ${jsonEncode(body)}");

      final response = await DioClient().post(
        ApiEndPoints.pharmacyUpdateWorkingHours,
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
          String message = 'Working hours updated successfully';
          if (resData['message'] != null) {
            final msg = resData['message'];
            if (msg is Map) {
              final lang = FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';
              final key = lang == 'ar'
                  ? 'message_ar'
                  : lang == 'fr'
                      ? 'message_fr'
                      : 'message_en';
              if (msg[key] != null) {
                final raw = msg[key];
                if (raw is List && raw.isNotEmpty) {
                  message = raw.first.toString();
                } else {
                  message = raw.toString();
                }
              }
            } else if (msg is String) {
              message = msg;
            }
          }
          showToast(context, message);
        }
        return true;
      } else {
        if (mounted) {
          final message = resData is Map
              ? resData['message']?.toString() ?? 'Failed to update working hours'
              : 'Failed to update working hours';
          showToast(context, message);
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      debugPrint("==================== POST UPDATE WORKING HOURS ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("=========================================================================");

      print("==================== POST UPDATE WORKING HOURS ERROR ====================");
      print("Error: $e");
      print("=========================================================================");

      if (mounted) {
        showToast(context, e.toString());
      }
      return false;
    }
  }

  Future<void> _editDay(int index) async {
    final day = _days[index];
    final saved = await showDialog<_HourEdit>(
      context: context,
      barrierColor: const Color(0xFF1A1A1A).withValues(alpha: 0.45),
      builder: (context) => _EditHourDialog(
        dayName: day.name,
        open24: day.open24,
        start: day.start ?? const TimeOfDay(hour: 8, minute: 0),
        end: day.end ?? const TimeOfDay(hour: 22, minute: 0),
      ),
    );
    if (saved == null || !mounted) return;

    final prevOpen24 = day.open24;
    final prevStart = day.start;
    final prevEnd = day.end;
    final prevClosed = day.closed;

    setState(() {
      day.open24 = saved.open24;
      day.start = saved.start;
      day.end = saved.end;
      day.closed = false;
    });

    final success = await _updateWorkingHours();
    if (!success && mounted) {
      setState(() {
        day.open24 = prevOpen24;
        day.start = prevStart;
        day.end = prevEnd;
        day.closed = prevClosed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayClosed = !_open24 && _today.closed;
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
              _Header(onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Status',
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
                                color: PharmacyWorkingHoursScreen.ink,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              children: [
                                const TextSpan(text: 'Today: '),
                                TextSpan(
                                  text: _todayHours,
                                  style: TextStyle(
                                    color: todayClosed
                                        ? PharmacyWorkingHoursScreen.closed
                                        : PharmacyWorkingHoursScreen.orange,
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
                                color: PharmacyWorkingHoursScreen.orange,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '24-Hour Open',
                                style: GoogleFonts.inter(
                                  color: PharmacyWorkingHoursScreen.ink,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: _open24,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                onChanged: (value) async {
                                  HapticFeedback.lightImpact();
                                  final prev = _open24;
                                  setState(() => _open24 = value);
                                  final success = await _updateWorkingHours();
                                  if (!success && mounted) {
                                    setState(() => _open24 = prev);
                                  }
                                },
                                thumbColor: const WidgetStatePropertyAll(Colors.white),
                                trackColor: WidgetStateProperty.resolveWith((states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return PharmacyWorkingHoursScreen.orange;
                                  }
                                  return const Color(0xFFE9E8E4);
                                }),
                                trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Weekly Schedule',
                      style: GoogleFonts.inter(
                        color: PharmacyWorkingHoursScreen.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < _days.length; i++) ...[
                            if (i > 0)
                              const Divider(height: 1, thickness:.5, color: Color(0xFFF3F3F3)),
                            _DayRow(
                              day: _days[i],
                              hours: _open24 ? _DayHours.allDayHours : null,
                              onEdit: () => _editDay(i),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
              'Working Hours',
              style: GoogleFonts.inter(
                color: PharmacyWorkingHoursScreen.ink,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
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
                    color: PharmacyWorkingHoursScreen.ink,
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

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, this.hours, required this.onEdit});

  final _DayHours day;
  final String? hours;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final closed = hours == null && day.closed;
    final label = hours ?? day.label;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.name,
                  style: GoogleFonts.inter(
                    color: PharmacyWorkingHoursScreen.day,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: closed ? PharmacyWorkingHoursScreen.closed : PharmacyWorkingHoursScreen.muted,
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
                  image: AssetImage('lib/pharmacy/Assets/images/edit.png'),
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded, color: PharmacyWorkingHoursScreen.orange, size: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HourEdit {
  const _HourEdit({required this.open24, required this.start, required this.end});

  final bool open24;
  final TimeOfDay start;
  final TimeOfDay end;
}

class _EditHourDialog extends StatefulWidget {
  const _EditHourDialog({
    required this.dayName,
    required this.open24,
    required this.start,
    required this.end,
  });

  final String dayName;
  final bool open24;
  final TimeOfDay start;
  final TimeOfDay end;

  @override
  State<_EditHourDialog> createState() => _EditHourDialogState();
}

class _EditHourDialogState extends State<_EditHourDialog> {
  late bool _open24 = widget.open24;
  late TimeOfDay _start = widget.start;
  late TimeOfDay _end = widget.end;
  String? _error;

  Future<void> _pick(bool start) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF5317),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1C1D1B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _start = picked;
      } else {
        _end = picked;
      }
      _error = null;
    });
  }

  void _save() {
    final startMinutes = _start.hour * 60 + _start.minute;
    final endMinutes = _end.hour * 60 + _end.minute;
    if (!_open24 && endMinutes <= startMinutes) {
      setState(() => _error = 'End time must be after start time');
      return;
    }
    Navigator.of(context).pop(_HourEdit(open24: _open24, start: _start, end: _end));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 12,
      shadowColor: const Color(0x33000000),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Edit Working Hour',
                style: GoogleFonts.inter(
                  color: const Color(0xFF111111),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.dayName,
              style: GoogleFonts.inter(
                color: const Color(0xFF111111),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '24-Hour Open',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF1C1D1B),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _open24,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _open24 = value;
                      _error = null;
                    });
                  },
                  thumbColor: const WidgetStatePropertyAll(Colors.white),
                  trackColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) return const Color(0xFFFF5216);
                    return const Color(0xFFE9E8E4);
                  }),
                  trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _timeLabel('Start Time')),
                const SizedBox(width: 12),
                Expanded(child: _timeLabel('End Time')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _timeBox(_format24(_start), () => _pick(true))),
                const SizedBox(width: 12),
                Expanded(child: _timeBox(_format24(_end), () => _pick(false))),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: GoogleFonts.inter(
                  color: const Color(0xFFBA1B1B),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF626E7E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33FF5317), blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5317),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Save',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: const Color(0xFFA3A3A3),
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    );
  }

  Widget _timeBox(String value, VoidCallback onTap) {
    return Material(
      color: const Color(0xFFF3F3F3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 44,
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: const Color(0xFF3E3E3E),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
