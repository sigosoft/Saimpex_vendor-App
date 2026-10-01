import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saimpex_vendor/water/core/constants/app_colors.dart';
import 'package:saimpex_vendor/water/view/account/add_coupon_view.dart';

class CouponsView extends StatefulWidget {
  const CouponsView({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CouponsView()),
    );
  }

  @override
  State<CouponsView> createState() => _CouponsViewState();
}

class _CouponsViewState extends State<CouponsView> {
  final searchController = TextEditingController();

  final coupons = <_CouponItem>[
    const _CouponItem(
      title: 'WELCOME COUPON',
      code: 'WELCOME50',
      discount: '12.00%',
      count: '2',
      validUpto: 'Feb 10,2026',
      createdOn: 'Feb 07, 2026 10:45 AM, Today',
      updatedOn: 'Feb 07, 2026 10:45 AM, Today',
      active: true,
      type: 'PERCENTAGE',
    ),
  ];

  List<_CouponItem> get filtered {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return List<_CouponItem>.from(coupons);
    return coupons
        .where(
          (c) =>
              c.title.toLowerCase().contains(q) ||
              c.code.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
                      Row(
                        children: [
                          Expanded(
                            child: _SearchField(
                              controller: searchController,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 46,
                            child: ElevatedButton.icon(
                              onPressed: () => AddCouponView.open(context),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text(
                                'Add Coupon',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryOrange,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      for (final coupon in filtered) ...[
                        _CouponCard(
                          coupon: coupon,
                          onEdit: () => AddCouponView.open(context),
                          onDelete: () {
                            setState(() => coupons.remove(coupon));
                          },
                        ),
                        const SizedBox(height: 12),
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

class _CouponItem {
  const _CouponItem({
    required this.title,
    required this.code,
    required this.discount,
    required this.count,
    required this.validUpto,
    required this.createdOn,
    required this.updatedOn,
    required this.active,
    required this.type,
  });

  final String title;
  final String code;
  final String discount;
  final String count;
  final String validUpto;
  final String createdOn;
  final String updatedOn;
  final bool active;
  final String type;
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
              'Coupons',
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

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fieldBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppColors.textHint,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'Search Coupon',
                hintStyle: TextStyle(
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w400,
                  fontSize: 13.5,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.onEdit,
    required this.onDelete,
  });

  final _CouponItem coupon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.title,
                      style: const TextStyle(
                        color: AppColors.textMeta,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'CODE: ',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text: coupon.code,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Badge(
                    label: coupon.active ? 'ACTIVE' : 'INACTIVE',
                    bg: const Color(0xFFE8F5E9),
                    fg: const Color(0xFF2D8A56),
                  ),
                  const SizedBox(height: 6),
                  _Badge(
                    label: coupon.type,
                    bg: AppColors.orangeSoftBg,
                    fg: AppColors.primaryOrange,
                  ),
                ],
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: _CouponMoreMenu(
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _DottedDivider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatColumn(
                  label: 'DISCOUNT',
                  value: coupon.discount,
                ),
              ),
              Container(width: 1, height: 38, color: AppColors.divider),
              Expanded(
                child: _StatColumn(
                  label: 'COUNT',
                  value: coupon.count,
                ),
              ),
              Container(width: 1, height: 38, color: AppColors.divider),
              Expanded(
                child: _StatColumn(
                  label: 'VALID UPTO',
                  value: coupon.validUpto,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _DottedDivider(),
          const SizedBox(height: 12),
          _MetaRow(label: 'CREATED ON:', value: coupon.createdOn),
          const SizedBox(height: 8),
          _MetaRow(label: 'UPDATED ON:', value: coupon.updatedOn),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Update Coupon Status',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponMoreMenu extends StatelessWidget {
  const _CouponMoreMenu({
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_CouponMenuAction>(
      tooltip: 'More',
      offset: const Offset(0, 36),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 150),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFF2F2F2),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      surfaceTintColor: const Color(0xFFF2F2F2),
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AppColors.textMuted,
        size: 20,
      ),
      onSelected: (action) {
        switch (action) {
          case _CouponMenuAction.edit:
            onEdit();
          case _CouponMenuAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _CouponMenuAction.edit,
          height: 44,
          child: _CouponMenuRow(
            icon: Icons.edit_outlined,
            label: 'Edit',
          ),
        ),
        const PopupMenuDivider(height: 1),
        const PopupMenuItem(
          value: _CouponMenuAction.delete,
          height: 44,
          child: _CouponMenuRow(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
          ),
        ),
      ],
    );
  }
}

enum _CouponMenuAction { edit, delete }

class _CouponMenuRow extends StatelessWidget {
  const _CouponMenuRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMeta, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textMuted,
          size: 20,
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.bg,
    required this.fg,
  });

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.2,
          height: 1.1,
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 10.5,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.primaryOrange,
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 11,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedLinePainter(color: AppColors.borderMuted),
      child: const SizedBox(width: double.infinity, height: 1),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  _DottedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    const dash = 3.0;
    const gap = 3.5;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
