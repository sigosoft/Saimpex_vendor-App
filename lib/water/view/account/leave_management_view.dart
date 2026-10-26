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

class LeaveManagementView extends StatefulWidget {
  const LeaveManagementView({super.key});

  static const orange = Color(0xFFFF5216);
  static const ink = Color(0xFF1C1D1B);
  static const button = Color(0xFFFF5317);

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LeaveManagementView()),
    );
  }

  @override
  State<LeaveManagementView> createState() => _LeaveManagementViewState();
}

class _Leave {
  _Leave({
    this.id,
    required this.from,
    required this.to,
    required this.reason,
    required this.completed,
  });

  final String? id;
  final DateTime from;
  final DateTime to;
  final String reason;
  final bool completed;
}

class _LeaveManagementViewState extends State<LeaveManagementView> {
  DateTime? _from;
  DateTime? _to;
  final _reason = TextEditingController();
  String? _error;

  bool _isLoading = true;
  List<_Leave> _leaves = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaves();
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    return "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
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

  DateTime? _parseSingleDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final standard = DateTime.tryParse(s);
    if (standard != null) return standard;
    final parts = s.split(RegExp(r'[-/]'));
    if (parts.length == 3) {
      if (parts[0].length == 4) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (y != null && m != null && d != null) return DateTime(y, m, d);
      } else if (parts[2].length == 4) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);
        if (y != null && m != null && d != null) return DateTime(y, m, d);
      }
    }
    return null;
  }

  (DateTime, DateTime)? _parseDateRange(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    try {
      final s = dateStr.trim();
      if (s.contains(' to ')) {
        final parts = s.split(' to ');
        final f = _parseSingleDate(parts[0]);
        final t = _parseSingleDate(parts[1]);
        if (f != null && t != null) return (f, t);
        if (f != null) return (f, f);
      }
      if (s.contains(' - ')) {
        final parts = s.split(' - ');
        final f = _parseSingleDate(parts[0]);
        final t = _parseSingleDate(parts[1]);
        if (f != null && t != null) return (f, t);
        if (f != null) return (f, f);
      }
      final dt = _parseSingleDate(s);
      if (dt != null) return (dt, dt);
    } catch (_) {}
    return null;
  }

  Future<void> _fetchLeaves() async {
    setState(() => _isLoading = true);
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty && token != "null") {
        DioClient().updateToken(token);
      }

      final savedVendorType = await getSavedObject("vendorType");
      final savedAppType = await getSavedObject(VendorAppRouter.storageKey);
      final vendorType = (savedVendorType != null &&
              savedVendorType.toString().isNotEmpty &&
              savedVendorType.toString() != "0")
          ? savedVendorType.toString()
          : (savedAppType?.toString().isNotEmpty == true
              ? savedAppType.toString()
              : "1");

      final queryParams = <String, dynamic>{
        "vendor_type": vendorType,
        "limit": 100,
        "page": 1,
      };

      debugPrint("==================== GET WATER LEAVES ====================");
      debugPrint("Endpoint: ${ApiEndPoints.profile}");
      debugPrint("Query: $queryParams");
      print("==================== GET WATER LEAVES ====================");
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
        List<LeaveData>? upcoming = profileModel.upcomingLeaves;
        List<LeaveData>? history = profileModel.leaveHistory;

        if (upcoming == null && dataMap['data'] is Map) {
          final d = dataMap['data'];
          if (d['upcoming_leaves'] is List) {
            upcoming = (d['upcoming_leaves'] as List).map((i) => LeaveData.fromJson(i)).toList();
          } else if (d['vendor'] is Map && d['vendor']['upcoming_leaves'] is List) {
            upcoming = (d['vendor']['upcoming_leaves'] as List).map((i) => LeaveData.fromJson(i)).toList();
          }
        }
        if (history == null && dataMap['data'] is Map) {
          final d = dataMap['data'];
          if (d['leave_history'] is List) {
            history = (d['leave_history'] as List).map((i) => LeaveData.fromJson(i)).toList();
          } else if (d['vendor'] is Map && d['vendor']['leave_history'] is List) {
            history = (d['vendor']['leave_history'] as List).map((i) => LeaveData.fromJson(i)).toList();
          }
        }

        final List<_Leave> fetched = [];
        if (upcoming != null && upcoming.isNotEmpty) {
          for (final item in upcoming) {
            final parsed = _parseDateRange(item.date);
            if (parsed != null) {
              fetched.add(_Leave(
                id: item.id?.toString(),
                from: parsed.$1,
                to: parsed.$2,
                reason: (item.reason != null && item.reason!.isNotEmpty)
                    ? item.reason!
                    : 'Leave',
                completed: false,
              ));
            }
          }
        }
        if (history != null && history.isNotEmpty) {
          for (final item in history) {
            final parsed = _parseDateRange(item.date);
            if (parsed != null) {
              fetched.add(_Leave(
                id: item.id?.toString(),
                from: parsed.$1,
                to: parsed.$2,
                reason: (item.reason != null && item.reason!.isNotEmpty)
                    ? item.reason!
                    : 'Leave',
                completed: true,
              ));
            }
          }
        }

        setState(() {
          _leaves = fetched;
          _isLoading = false;
        });
      } else {
        setState(() {
          _leaves = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching leaves: $e");
      if (mounted) {
        setState(() {
          _leaves = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickDate({required bool from}) async {
    final initial = (from ? _from : _to) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: LeaveManagementView.button,
              onPrimary: Colors.white,
              onSurface: LeaveManagementView.ink,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (from) {
        _from = picked;
      } else {
        _to = picked;
      }
      _error = null;
    });
  }

  Future<bool?> _showMarkConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          elevation: 6,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFECE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_note_rounded,
                    color: LeaveManagementView.orange,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Mark Leave',
                  style: GoogleFonts.inter(
                    color: LeaveManagementView.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to mark leave for the selected dates?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF454E5D),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'No',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: LeaveManagementView.button,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Yes',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
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
      },
    );
  }

  Future<bool?> _showCancelConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          elevation: 6,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFECE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_busy_rounded,
                    color: LeaveManagementView.orange,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cancel Leave',
                  style: GoogleFonts.inter(
                    color: LeaveManagementView.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to cancel this leave?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF454E5D),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'No',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: LeaveManagementView.button,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Yes',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
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
      },
    );
  }

  Future<void> _markLeave() async {
    final reason = _reason.text.trim();
    if (_from == null || _to == null) {
      setState(() => _error = 'Select from and to dates');
      return;
    }
    if (_to!.isBefore(_from!)) {
      setState(() => _error = 'To date must be after from date');
      return;
    }
    if (reason.isEmpty) {
      setState(() => _error = 'Enter a reason');
      return;
    }

    setState(() => _error = null);

    final confirmed = await _showMarkConfirmationDialog();
    if (confirmed != true || !mounted) return;

    showLoadingDialog(context);

    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty && token != "null") {
        DioClient().updateToken(token);
      }

      final savedVendorType = await getSavedObject("vendorType");
      final savedAppType = await getSavedObject(VendorAppRouter.storageKey);
      final vendorType = (savedVendorType != null &&
              savedVendorType.toString().isNotEmpty &&
              savedVendorType.toString() != "0")
          ? savedVendorType.toString()
          : (savedAppType?.toString().isNotEmpty == true
              ? savedAppType.toString()
              : "1");

      final fromDate = _formatDate(_from!);
      final toDate = _formatDate(_to!);

      final Map<String, dynamic> body = {
        "vendor_type": vendorType,
        "from_date": fromDate,
        "to_date": toDate,
        "reason": reason,
      };

      debugPrint("==================== POST MARK LEAVE ====================");
      debugPrint("Endpoint: ${ApiEndPoints.MarkLeave}");
      debugPrint("Body: ${jsonEncode(body)}");

      print("==================== POST MARK LEAVE ====================");
      print("Endpoint: ${ApiEndPoints.MarkLeave}");
      print("Body: ${jsonEncode(body)}");

      final response = await DioClient().post(
        ApiEndPoints.MarkLeave,
        body: body,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("=========================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("=========================================================");

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
          String message = _extractMessage(resData, 'Leave marked successfully');
          showToast(context, message);
          setState(() {
            _from = null;
            _to = null;
            _reason.clear();
            _error = null;
          });
          _fetchLeaves();
        }
      } else {
        if (mounted) {
          String message = _extractMessage(resData, 'Failed to mark leave');
          showToast(context, message);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      debugPrint("==================== POST MARK LEAVE ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("===============================================================");
      print("==================== POST MARK LEAVE ERROR ====================");
      print("Error: $e");
      print("===============================================================");

      if (mounted) {
        showErrorMessage(e);
      }
    }
  }

  Future<void> _cancelLeave(_Leave leave) async {
    final confirmed = await _showCancelConfirmationDialog();
    if (confirmed != true || !mounted) return;

    HapticFeedback.lightImpact();
    if (leave.id == null || leave.id!.isEmpty) {
      setState(() => _leaves.remove(leave));
      showToast(context, 'Leave cancelled successfully');
      return;
    }

    showLoadingDialog(context);
    try {
      final token = (await getSavedObject("token"))?.toString() ?? "";
      if (token.isNotEmpty && token != "null") {
        DioClient().updateToken(token);
      }

      final savedVendorType = await getSavedObject("vendorType");
      final savedAppType = await getSavedObject(VendorAppRouter.storageKey);
      final vendorType = (savedVendorType != null &&
              savedVendorType.toString().isNotEmpty &&
              savedVendorType.toString() != "0")
          ? savedVendorType.toString()
          : (savedAppType?.toString().isNotEmpty == true
              ? savedAppType.toString()
              : "1");

      final Map<String, dynamic> body = {
        "vendor_type": vendorType,
        "leave_id": leave.id!,
      };

      debugPrint("==================== POST UNMARK LEAVE ====================");
      debugPrint("Endpoint: ${ApiEndPoints.UnmarkLeave}");
      debugPrint("Body: ${jsonEncode(body)}");

      print("==================== POST UNMARK LEAVE ====================");
      print("Endpoint: ${ApiEndPoints.UnmarkLeave}");
      print("Body: ${jsonEncode(body)}");

      final response = await DioClient().post(
        ApiEndPoints.UnmarkLeave,
        body: body,
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("===========================================================");

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.data}");
      print("===========================================================");

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
          String message = _extractMessage(resData, 'Leave cancelled successfully');
          showToast(context, message);
          _fetchLeaves();
        }
      } else {
        if (mounted) {
          String message = _extractMessage(resData, 'Failed to cancel leave');
          showToast(context, message);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      debugPrint("==================== POST UNMARK LEAVE ERROR ====================");
      debugPrint("Error: $e");
      debugPrint("=================================================================");
      print("==================== POST UNMARK LEAVE ERROR ====================");
      print("Error: $e");
      print("=================================================================");

      if (mounted) {
        showErrorMessage(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _leaves.where((leave) => !leave.completed).toList();
    final completed = _leaves.where((leave) => leave.completed).toList();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFE8E0), Color(0xFFFFF6F2), Colors.white],
              stops: [0, 0.2, 0.38],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + 8),
              _Header(onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: RefreshIndicator(
                  color: LeaveManagementView.orange,
                  onRefresh: _fetchLeaves,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      Text(
                        'Mark Leave',
                        style: GoogleFonts.inter(
                          color: LeaveManagementView.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: _fieldLabel('From Date')),
                                const SizedBox(width: 12),
                                Expanded(child: _fieldLabel('To Date')),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _DateBox(
                                    value: _from,
                                    onTap: () => _pickDate(from: true),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _DateBox(
                                    value: _to,
                                    onTap: () => _pickDate(from: false),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _fieldLabel('Reason For Leave'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _reason,
                              maxLines: 3,
                              onChanged: (_) {
                                if (_error != null) setState(() => _error = null);
                              },
                              style: GoogleFonts.inter(
                                color: const Color(0xFF3F4555),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: 'e.g. Annual vacation, renovation...',
                                hintStyle: GoogleFonts.inter(
                                  color: const Color(0xFFB7C2D0),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF3F5F7),
                                contentPadding: const EdgeInsets.all(12),
                                border: _reasonBorder,
                                enabledBorder: _reasonBorder,
                                focusedBorder: _reasonBorder,
                              ),
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
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x33FF5317), blurRadius: 12, offset: Offset(0, 6)),
                                ],
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: FilledButton(
                                  onPressed: _markLeave,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: LeaveManagementView.button,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    'Mark Leave',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _HistoryHeader(),
                      const SizedBox(height: 14),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: LeaveManagementView.orange,
                            ),
                          ),
                        )
                      else if (_leaves.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'lib/assets/images/nodata.png',
                                  height: 120,
                                  width: 140,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Leaves Found',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: LeaveManagementView.ink,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Marked leaves will appear here',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF8B97A8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        if (upcoming.isNotEmpty) ...[
                          const _GroupTitle('Upcoming Leaves', color: Color(0xFF3B82F6)),
                          const SizedBox(height: 10),
                          for (final leave in upcoming) ...[
                            _LeaveCard(
                              leave: leave,
                              onCancel: () => _cancelLeave(leave),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                        if (completed.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          const Row(
                            children: [
                              _GroupTitle('Completed Leaves', color: Color(0xFF16A34A)),
                              Spacer(),
                              _SeeAll(),
                            ],
                          ),
                          const SizedBox(height: 10),
                          for (final leave in completed) ...[
                            _LeaveCard(leave: leave),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ],
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

const _reasonBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  borderSide: BorderSide.none,
);

Widget _fieldLabel(String text) {
  return Text(
    text,
    style: GoogleFonts.inter(
      color: const Color(0xFF8A97A8),
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
  );
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
              'Leave Management',
              style: GoogleFonts.inter(
                color: LeaveManagementView.ink,
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
                    border: Border.all(color: const Color(0xFFFFE0D0)),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: LeaveManagementView.orange,
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

class _DateBox extends StatelessWidget {
  const _DateBox({required this.value, required this.onTap});

  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'dd-mm-yyyy'
        : '${value!.day.toString().padLeft(2, '0')}-${value!.month.toString().padLeft(2, '0')}-${value!.year}';
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD7DDE4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.inter(
                    color: value == null ? const Color(0xFF9AA8B8) : const Color(0xFF29324C),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              Image.asset(
                'lib/pharmacy/Assets/images/calender.png',
                width: 18,
                height: 18,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'LEAVES HISTORY',
          style: GoogleFonts.inter(
            color: const Color(0xFF3F4454),
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.6,
          ),
        ),
        const Spacer(),
        const _SeeAll(),
      ],
    );
  }
}

class _SeeAll extends StatelessWidget {
  const _SeeAll();

  @override
  Widget build(BuildContext context) {
    return Text(
      'See All',
      style: GoogleFonts.inter(
        color: LeaveManagementView.orange,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.leave, this.onCancel});

  final _Leave leave;
  final VoidCallback? onCancel;

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  String _date(DateTime date) => '${_months[date.month - 1]} ${date.day}';

  @override
  Widget build(BuildContext context) {
    final scheduled = onCancel != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF3)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_date(leave.from)} - ${_date(leave.to)}, ${leave.to.year}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF3F4555),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      leave.reason,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8B97A8),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheduled ? const Color(0xFFDBEAFE) : const Color(0xFFE6F3EB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  scheduled ? 'SCHEDULED' : 'COMPLETED',
                  style: GoogleFonts.inter(
                    color: scheduled ? const Color(0xFF3B82F6) : const Color(0xFF16A34A),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          if (scheduled) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: LeaveManagementView.orange,
                  side: const BorderSide(color: LeaveManagementView.orange, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Cancel Leave',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
