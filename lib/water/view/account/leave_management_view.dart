import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
  _Leave({required this.from, required this.to, required this.reason, required this.completed});

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

  final List<_Leave> _leaves = [
    _Leave(from: DateTime(2026, 2, 20), to: DateTime(2026, 2, 25), reason: 'Renovation Work', completed: false),
    _Leave(from: DateTime(2026, 2, 20), to: DateTime(2026, 2, 25), reason: 'Renovation Work', completed: false),
    _Leave(from: DateTime(2025, 1, 20), to: DateTime(2025, 1, 25), reason: 'Renovation Work', completed: true),
    _Leave(from: DateTime(2025, 1, 20), to: DateTime(2025, 1, 25), reason: 'Renovation Work', completed: true),
  ];

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
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

  void _markLeave() {
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
    HapticFeedback.lightImpact();
    setState(() {
      _leaves.insert(0, _Leave(from: _from!, to: _to!, reason: reason, completed: false));
      _from = null;
      _to = null;
      _reason.clear();
      _error = null;
    });
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
                child: ListView(
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
                    const _GroupTitle('Upcoming Leaves', color: Color(0xFF3B82F6)),
                    const SizedBox(height: 10),
                    for (final leave in upcoming) ...[
                      _LeaveCard(
                        leave: leave,
                        onCancel: () {
                          HapticFeedback.lightImpact();
                          setState(() => _leaves.remove(leave));
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
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
