import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';

class LeaveManagementView extends StatefulWidget {
  const LeaveManagementView({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LeaveManagementView()),
    );
  }

  @override
  State<LeaveManagementView> createState() => _LeaveManagementViewState();
}

class _LeaveManagementViewState extends State<LeaveManagementView> {
  DateTime? fromDate;
  DateTime? toDate;
  final reasonController = TextEditingController();

  final upcoming = [
    const _LeaveItem(
      range: 'Feb 20 - Feb 25, 2026',
      reason: 'Renovation Work',
      status: _LeaveStatus.scheduled,
    ),
    const _LeaveItem(
      range: 'Feb 20 - Feb 25, 2026',
      reason: 'Renovation Work',
      status: _LeaveStatus.scheduled,
    ),
  ];

  final completed = [
    const _LeaveItem(
      range: 'Jan 20 - Jan 25, 2025',
      reason: 'Renovation Work',
      status: _LeaveStatus.completed,
    ),
    const _LeaveItem(
      range: 'Jan 20 - Jan 25, 2025',
      reason: 'Renovation Work',
      status: _LeaveStatus.completed,
    ),
  ];

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'dd-mm-yyyy';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d-$m-${date.year}';
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = isFrom ? (fromDate ?? now) : (toDate ?? fromDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primaryOrange,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        fromDate = picked;
        if (toDate != null && toDate!.isBefore(picked)) {
          toDate = picked;
        }
      } else {
        toDate = picked;
      }
    });
  }

  void _submitLeave() {
    if (fromDate == null || toDate == null) return;
    final reason = reasonController.text.trim().isEmpty
        ? 'Renovation Work'
        : reasonController.text.trim();
    final range =
        '${_shortRange(fromDate!)} - ${_shortRange(toDate!)}, ${toDate!.year}';
    setState(() {
      upcoming.insert(
        0,
        _LeaveItem(
          range: range,
          reason: reason,
          status: _LeaveStatus.scheduled,
        ),
      );
      fromDate = null;
      toDate = null;
      reasonController.clear();
    });
  }

  String _shortRange(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundMid,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundTop,
                AppColors.backgroundMid,
                Colors.white,
              ],
              stops: [0, 0.2, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _Header(onBack: () => Navigator.of(context).maybePop()),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                    children: [
                      const Text(
                        'Mark Leave',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MarkLeaveCard(
                        fromLabel: _formatDate(fromDate),
                        toLabel: _formatDate(toDate),
                        reasonController: reasonController,
                        onPickFrom: () => _pickDate(isFrom: true),
                        onPickTo: () => _pickDate(isFrom: false),
                        onSubmit: _submitLeave,
                      ),
                      const SizedBox(height: 22),
                      const _SectionHeader(
                        title: 'LEAVES HISTORY',
                        showSeeAll: true,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Upcoming Leaves',
                        style: TextStyle(
                          color: AppColors.scheduledText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (var i = 0; i < upcoming.length; i++) ...[
                        _LeaveCard(
                          item: upcoming[i],
                          onCancel: () => setState(() => upcoming.removeAt(i)),
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 8),
                      const _SectionHeader(
                        title: 'Completed Leaves',
                        titleColor: AppColors.inventoryAvailable,
                        showSeeAll: true,
                      ),
                      const SizedBox(height: 10),
                      for (final item in completed) ...[
                        _LeaveCard(item: item),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _LeaveStatus { scheduled, completed }

class _LeaveItem {
  const _LeaveItem({
    required this.range,
    required this.reason,
    required this.status,
  });

  final String range;
  final String reason;
  final _LeaveStatus status;
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
            const Text(
              'Leave Management',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 17,
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.primaryOrange,
                    size: 28,
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

class _MarkLeaveCard extends StatelessWidget {
  const _MarkLeaveCard({
    required this.fromLabel,
    required this.toLabel,
    required this.reasonController,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onSubmit,
  });

  final String fromLabel;
  final String toLabel;
  final TextEditingController reasonController;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Expanded(
                child: _DateField(
                  label: 'From Date',
                  value: fromLabel,
                  onTap: onPickFrom,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: 'To Date',
                  value: toLabel,
                  onTap: onPickTo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Reason For Leave',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: reasonController,
            maxLines: 3,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. Annual vacation, renovation...',
              hintStyle: const TextStyle(
                color: AppColors.textHint,
                fontWeight: FontWeight.w400,
                fontSize: 13.5,
              ),
              filled: true,
              fillColor: const Color(0xFFF5F6F8),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryOrange,
                  width: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: AppColors.primaryOrange.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Mark Leave',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = value == 'dd-mm-yyyy';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isPlaceholder
                          ? AppColors.textHint
                          : AppColors.textDark,
                      fontWeight: FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textDark,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.titleColor = AppColors.textDark,
    this.showSeeAll = false,
  });

  final String title;
  final Color titleColor;
  final bool showSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w600,
              fontSize: title == title.toUpperCase() ? 14 : 14.5,
              letterSpacing: title == title.toUpperCase() ? 0.3 : 0,
            ),
          ),
        ),
        if (showSeeAll)
          GestureDetector(
            onTap: () {},
            child: const Text(
              'See All',
              style: TextStyle(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ),
      ],
    );
  }
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({
    required this.item,
    this.onCancel,
  });

  final _LeaveItem item;
  final VoidCallback? onCancel;

  bool get isScheduled => item.status == _LeaveStatus.scheduled;

  @override
  Widget build(BuildContext context) {
    final badgeBg =
        isScheduled ? AppColors.scheduledBg : AppColors.inventoryAvailableBg;
    final badgeColor =
        isScheduled ? AppColors.scheduledText : AppColors.inventoryAvailable;
    final badgeLabel = isScheduled ? 'SCHEDULED' : 'COMPLETED';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                      item.range,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,  
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.reason,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (isScheduled && onCancel != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryOrange,
                  side: const BorderSide(
                    color: AppColors.primaryOrange,
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel Leave',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
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
