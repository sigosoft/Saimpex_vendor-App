part of 'order_details_screen.dart';

enum _Availability { inStock, limited, outOfStock }

class PharmacyCreateQuotationScreen extends StatefulWidget {
  const PharmacyCreateQuotationScreen({
    super.key,
    this.customerName = 'Ahmed',
    this.phone = '+222 45 12 34 56',
    this.requestId = '#22789007',
    this.requestMeta = 'Today • 10:45 AM',
  });

  final String customerName;
  final String phone;
  final String requestId;
  final String requestMeta;

  @override
  State<PharmacyCreateQuotationScreen> createState() =>
      _PharmacyCreateQuotationScreenState();
}

class _PharmacyCreateQuotationScreenState
    extends State<PharmacyCreateQuotationScreen> {
  static const Color _orange = Color(0xFFFF5722);
  static const Color _disabled = Color(0xFFFFCDBA);
  static const int _tax = 10;
  static const String _prescriptionAsset =
      'lib/pharmacy/Assets/images/Prescription Upload.png';

  static const _validityOptions = <String>[
    '1 Day',
    '3 Days',
    '7 Days',
    '15 Days',
    '30 Days',
  ];

  late final CreateQuotationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CreateQuotationController());
  }

  @override
  void dispose() {
    Get.delete<CreateQuotationController>();
    super.dispose();
  }

  void _openFullPrescription() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullPrescriptionViewer(
          assetPath: _prescriptionAsset,
          rotationTurns: controller.rotationTurns,
        ),
      ),
    );
  }

  Future<void> _send() async {
    if (controller.lines.isEmpty) return;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => const _QuotationSentDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateQuotationController>(
      builder: (_) {
        final initial = widget.customerName.isNotEmpty
            ? widget.customerName.substring(0, 1).toUpperCase()
            : 'A';
        final editing = controller.draft != null;

        return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFF0E8),
                      Color(0xFFFFF8F4),
                      Color(0xFFFFFFFF),
                    ],
                    stops: [0, 0.18, 1],
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.paddingOf(context).top + 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              'Create Quotation',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                letterSpacing: -0.2,
                                height: 1.2,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () => Navigator.of(context).maybePop(),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFFFE0D0),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.04,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.chevron_left_rounded,
                                    color: _orange,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        children: [
                          _CustomerCard(
                            initial: initial,
                            name: widget.customerName,
                            phone: widget.phone,
                            requestId: widget.requestId,
                            requestMeta: widget.requestMeta,
                            reviewCompleted: true,
                          ),
                          const SizedBox(height: 14),
                          _UploadedPrescriptionCard(
                            assetPath: _prescriptionAsset,
                            rotationTurns: controller.rotationTurns,
                            onZoom: _openFullPrescription,
                            onRotate: controller.rotatePrescription,
                            onViewFull: _openFullPrescription,
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Text(
                                'Quotation Items',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF3A3A3A),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  height: 1.2,
                                ),
                              ),
                              const Spacer(),
                              if (!editing)
                                _QuoteValidMenu(
                                  value: controller.quoteValid,
                                  options: _validityOptions,
                                  onSelected: controller.setQuoteValid,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (editing)
                            _DraftMedicineCard(
                              draft: controller.draft!,
                              altResults: controller.filterAlternatives(
                                controller.altController.text,
                              ),
                              altController: controller.altController,
                              altFocus: controller.altFocus,
                              onAltChanged: controller.onAltQueryChanged,
                              onDiscard: controller.discardDraft,
                              onPrescribed: controller.setPrescribed,
                              onAvailable: controller.setAvailable,
                              onAddAlternative: controller.addAlternative,
                            )
                          else
                            _SavedLinesCard(
                              lines: controller.lines,
                              query: controller.medicineController.text,
                              results: controller.filter(
                                controller.medicineController.text,
                              ),
                              controller: controller.medicineController,
                              focusNode: controller.medicineFocus,
                              onQueryChanged: controller.onMedicineQueryChanged,
                              onAddMedicine: controller.focusMedicineSearch,
                              onPick: controller.beginDraft,
                              onEdit: controller.editLine,
                              onRemove: controller.removeSavedLine,
                            ),
                          if (!editing && controller.lines.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _CreateQuoteSummary(
                              itemTotal: controller.subtotal,
                              tax: _tax,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!editing || controller.canSaveDraft)
              _QuoteActionBar(
                label: editing ? 'Save & Add Next Medicine' : 'Send Quotation',
                enabled: editing ? controller.canSaveDraft : controller.lines.isNotEmpty,
                enabledColor: _orange,
                disabledColor: _disabled,
                onPressed: editing ? controller.saveDraft : _send,
              ),
          ],
        ),
      ),
    );
      },
    );
  }
}

class _QuotationMedicine {
  const _QuotationMedicine(this.name, this.priceMru, {this.inStock = true});

  final String name;
  final int priceMru;
  final bool inStock;
}

class _QuotationLine {
  _QuotationLine(this.medicine);

  final _QuotationMedicine medicine;
  int prescribedQty = 0;
  int availableQty = 0;
  _Availability? availability;
  final List<_QuotationMedicine> alternatives = [];
  int selectedAlternative = 0;

  int get billedQty => availability == _Availability.limited
      ? availableQty
      : prescribedQty;

  int get lineTotal => medicine.priceMru * billedQty;

  _QuotationLine copy() {
    final line = _QuotationLine(medicine)
      ..prescribedQty = prescribedQty
      ..availableQty = availableQty
      ..availability = availability
      ..selectedAlternative = selectedAlternative;
    line.alternatives.addAll(alternatives);
    return line;
  }
}

class _SavedLinesCard extends StatelessWidget {
  const _SavedLinesCard({
    required this.lines,
    required this.query,
    required this.results,
    required this.controller,
    required this.focusNode,
    required this.onQueryChanged,
    required this.onAddMedicine,
    required this.onPick,
    required this.onEdit,
    required this.onRemove,
  });

  final List<_QuotationLine> lines;
  final String query;
  final List<_QuotationMedicine> results;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onAddMedicine;
  final ValueChanged<_QuotationMedicine> onPick;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return _QuoteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFF1F1F1)),
              const SizedBox(height: 14),
            ],
            _SavedLineTile(
              index: i,
              line: lines[i],
              onEdit: () => onEdit(i),
              onRemove: () => onRemove(i),
            ),
          ],
          if (lines.isNotEmpty) const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onAddMedicine,
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              'Add Medicine',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF5722),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerLeft,
            ),
          ),
          _MedicineField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onQueryChanged,
          ),
          if (query.trim().isNotEmpty)
            for (final medicine in results)
              _CatalogTile(
                medicine: medicine,
                onAdd: () => onPick(medicine),
              ),
        ],
      ),
    );
  }
}

class _DraftMedicineCard extends StatelessWidget {
  const _DraftMedicineCard({
    required this.draft,
    required this.altResults,
    required this.altController,
    required this.altFocus,
    required this.onAltChanged,
    required this.onDiscard,
    required this.onPrescribed,
    required this.onAvailable,
    required this.onAddAlternative,
  });

  final _QuotationLine draft;
  final List<_QuotationMedicine> altResults;
  final TextEditingController altController;
  final FocusNode altFocus;
  final ValueChanged<String> onAltChanged;
  final VoidCallback onDiscard;
  final ValueChanged<int> onPrescribed;
  final ValueChanged<int> onAvailable;
  final ValueChanged<_QuotationMedicine> onAddAlternative;

  @override
  Widget build(BuildContext context) {
    final showTotal = draft.prescribedQty > 0 &&
        (draft.availability == _Availability.inStock ||
            (draft.availability == _Availability.limited &&
                draft.availableQty > 0) ||
            (draft.availability == _Availability.outOfStock &&
                draft.alternatives.isNotEmpty));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuoteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      draft.medicine.name,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.2,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onDiscard,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFB8B8B8),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
          Text(
            'Prescribed Quantity',
            style: GoogleFonts.inter(
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                _QtyStepper(
                  value: draft.prescribedQty,
                  onChanged: onPrescribed,
                ),
                const Spacer(),
                Text(
                  'Unit',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFB0B0B0),
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                _PricePill(price: draft.medicine.priceMru),
              ],
            ),
          ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Pharmacy Availability',
            style: GoogleFonts.inter(
              color: const Color(0xFF3A3A3A),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          _AvailabilityRow(selected: draft.availability),
          if (draft.availability == _Availability.limited) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF4),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFF3E0A6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Available Quantity',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF78350F),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      _AvailableCountPill(
                        available: draft.availableQty,
                        prescribed: draft.prescribedQty,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _OutlinedQtyStepper(
                    value: draft.availableQty,
                    onChanged: onAvailable,
                  ),
                ],
              ),
            ),
          ],
          if (draft.availability == _Availability.outOfStock) ...[
            const SizedBox(height: 18),
            Text(
              draft.alternatives.isEmpty
                  ? 'Suggest Alternative Medicine'
                  : 'Suggested Alternative',
              style: GoogleFonts.inter(
                color: const Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (draft.alternatives.isNotEmpty) ...[
              const SizedBox(height: 10),
              _SuggestedAlternativeBox(
                original: draft.medicine,
                medicines: draft.alternatives,
              ),
            ] else ...[
              const SizedBox(height: 12),
              _AltSearchField(
                controller: altController,
                focusNode: altFocus,
                onChanged: onAltChanged,
              ),
              for (final medicine in altResults)
                _CatalogTile(
                  medicine: medicine,
                  onAdd: () => onAddAlternative(medicine),
                ),
            ],
          ],
          if (showTotal) ...[
            const SizedBox(height: 30),
            const _FullWidthDivider(),
            const SizedBox(height: 20),
            _ItemTotalRow(
              quantity: draft.billedQty,
              price: draft.medicine.priceMru,
              total: draft.lineTotal,
            ),
          ],
      ],
    );
  }
}

class _FullWidthDivider extends StatelessWidget {
  const _FullWidthDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(painter: _FullWidthLinePainter()),
    );
  }
}

class _FullWidthLinePainter extends CustomPainter {
  const _FullWidthLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(-16, 0, size.width + 32, 1),
      Paint()..color = const Color(0xFFECECEC),
    );
  }

  @override
  bool shouldRepaint(covariant _FullWidthLinePainter oldDelegate) => false;
}

class _SavedLineTile extends StatelessWidget {
  const _SavedLineTile({
    required this.index,
    required this.line,
    required this.onEdit,
    required this.onRemove,
  });

  final int index;
  final _QuotationLine line;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AvailabilityStatus(availability: line.availability),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '${index + 1}. ${line.medicine.name}',
                style: GoogleFonts.inter(
                  color: const Color(0xFF2C2C2C),
                  fontWeight: FontWeight.w700,
                  fontSize: 15.5,
                  height: 1.25,
                ),
              ),
            ),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(
                  Icons.edit_outlined,
                  color: Color(0xFFB0B0B0),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFB0B0B0),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        if (line.availability == _Availability.limited) ...[
          const SizedBox(height: 8),
          _AvailableCountPill(
            available: line.availableQty,
            prescribed: line.prescribedQty,
          ),
        ],
        if (line.availability == _Availability.outOfStock &&
            line.alternatives.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Suggested Alternative',
            style: GoogleFonts.inter(
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 8),
          _SuggestedAlternativeBox(
            original: line.medicine,
            medicines: line.alternatives,
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Unit',
              style: GoogleFonts.inter(
                color: const Color(0xFFB0B0B0),
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Text(
              'Total',
              style: GoogleFonts.inter(
                color: const Color(0xFFB0B0B0),
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '${line.billedQty} tablets × ${line.medicine.priceMru} MRU',
              style: GoogleFonts.inter(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              '${line.lineTotal} MRU',
              style: GoogleFonts.inter(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AvailabilityStatus extends StatelessWidget {
  const _AvailabilityStatus({required this.availability});

  final _Availability? availability;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (availability) {
      _Availability.inStock => (
          const Color(0xFF16A34A),
          'Available (In Stock)',
        ),
      _Availability.limited => (
          const Color(0xFFE8A317),
          'Partially Available (Limited)',
        ),
      _Availability.outOfStock => (
          const Color(0xFFE11D48),
          'Not Available (Out of Stock)',
        ),
      null => (const Color(0xFF9CA3AF), ''),
    };
    if (label.isEmpty) return const SizedBox.shrink();
    final background = switch (availability) {
      _Availability.inStock => const Color(0xFFE7F8EE),
      _Availability.limited => const Color(0xFFFFF5CD),
      _Availability.outOfStock => const Color(0xFFFFF1F3),
      null => const Color(0xFFF3F4F6),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: availability == _Availability.outOfStock
            ? Border.all(color: const Color(0xFFFFB4BE))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityRow extends StatelessWidget {
  const _AvailabilityRow({required this.selected});

  final _Availability? selected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _AvailabilityChoice(
            selected: selected == _Availability.inStock,
            selectedFill: const Color(0xFFFFF1EC),
            label: 'Available',
            badge: const _InStockBadge(),
          ),
          const SizedBox(width: 8),
          _AvailabilityChoice(
            selected: selected == _Availability.limited,
            selectedFill: const Color(0xFFFFF6D9),
            label: 'Partially Available',
            badge: const _LimitedBadge(),
          ),
          const SizedBox(width: 8),
          _AvailabilityChoice(
            selected: selected == _Availability.outOfStock,
            selectedFill: const Color(0xFFFFF1EC),
            label: 'Not Available',
            badge: const _OutOfStockBadge(),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityChoice extends StatelessWidget {
  const _AvailabilityChoice({
    required this.selected,
    required this.selectedFill,
    required this.label,
    required this.badge,
  });

  final bool selected;
  final Color selectedFill;
  final String label;
  final Widget badge;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: selected ? selectedFill : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFFF5722) : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            badge,
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: GoogleFonts.inter(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 1.2,
              ),
            ),
          ],
        ),
    );
  }
}

class _AvailableCountPill extends StatelessWidget {
  const _AvailableCountPill({
    required this.available,
    required this.prescribed,
  });

  final int available;
  final int prescribed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$available of $prescribed available',
        style: GoogleFonts.inter(
          color: const Color(0xFF78350F),
          fontWeight: FontWeight.w600,
          fontSize: 12,
          height: 1,
        ),
      ),
    );
  }
}

class _SuggestedAlternativeBox extends StatelessWidget {
  const _SuggestedAlternativeBox({
    required this.original,
    required this.medicines,
  });

  final _QuotationMedicine original;
  final List<_QuotationMedicine> medicines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4E4FF)),
      ),
      child: Column(
        children: [
          _SuggestedAlternativeRow(
            name: original.name,
            inStock: false,
            showChevron: true,
          ),
          for (final medicine in medicines)
            _SuggestedAlternativeRow(
              name: medicine.name,
              inStock: medicine.inStock,
            ),
        ],
      ),
    );
  }
}

class _SuggestedAlternativeRow extends StatelessWidget {
  const _SuggestedAlternativeRow({
    required this.name,
    required this.inStock,
    this.showChevron = false,
  });

  final String name;
  final bool inStock;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: inStock
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFFF3250),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF2C2C2C),
                    fontWeight: FontWeight.w500,
                    fontSize: 14.5,
                  ),
                ),
              ),
              if (!inStock) const _OutOfStockBadge(),
            ],
          ),
          if (showChevron)
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFFC5C5C5),
            ),
        ],
      ),
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({
    required this.medicine,
    required this.onAdd,
    this.showOutOfStock = true,
  });

  final _QuotationMedicine medicine;
  final VoidCallback onAdd;
  final bool showOutOfStock;

  @override
  Widget build(BuildContext context) {
    final showBadge = medicine.inStock || showOutOfStock;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF3A3A3A),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
                if (showBadge) ...[
                  const SizedBox(height: 6),
                  if (medicine.inStock)
                    const _InStockBadge()
                  else
                    const _OutOfStockBadge(),
                ],
              ],
            ),
          ),
          Text(
            '${medicine.priceMru} MRU',
            style: GoogleFonts.inter(
              color: const Color(0xFFFF5722),
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5722),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemTotalRow extends StatelessWidget {
  const _ItemTotalRow({
    required this.quantity,
    required this.price,
    required this.total,
  });

  final int quantity;
  final int price;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Item total',
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$quantity tablets × $price MRU',
              style: GoogleFonts.inter(
                color: const Color(0xFF9CA3AF),
                fontWeight: FontWeight.w400,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$total MRU',
              style: GoogleFonts.inter(
                color: const Color(0xFFFF5722),
                fontWeight: FontWeight.w700,
                fontSize: 18,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OutlinedQtyStepper extends StatelessWidget {
  const _OutlinedQtyStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _OutlinedQtyHit(
            label: '−',
            onTap: () => onChanged(value - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$value',
              style: GoogleFonts.inter(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          _OutlinedQtyHit(
            label: '+',
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _OutlinedQtyHit extends StatelessWidget {
  const _OutlinedQtyHit({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
            fontSize: 18,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final canDecrease = value > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QtyButton(
          icon: Icons.remove,
          background: const Color(0xFFF3F4F6),
          iconColor: canDecrease
              ? const Color(0xFF6B7280)
              : const Color(0xFFD1D5DB),
          onTap: () => onChanged(value - 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            '$value',
            style: GoogleFonts.inter(
              color: const Color(0xFF2C2C2C),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        _QtyButton(
          icon: Icons.add,
          background: const Color(0xFFFF5722),
          iconColor: Colors.white,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _PricePill extends StatelessWidget {
  const _PricePill({required this.price});

  final int price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        '$price MRU',
        style: GoogleFonts.inter(
          color: const Color(0xFF1A1A1A),
          fontWeight: FontWeight.w700,
          fontSize: 14,
          height: 1.1,
        ),
      ),
    );
  }
}

class _AltSearchField extends StatelessWidget {
  const _AltSearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      style: GoogleFonts.inter(
        color: const Color(0xFF3A3A3A),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: 'Type medicine name...',
        hintStyle: GoogleFonts.inter(
          color: const Color(0xFFB0B0B0),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
    );
  }
}

class _MedicineField extends StatelessWidget {
  const _MedicineField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      style: GoogleFonts.inter(
        color: const Color(0xFF4A4A4A),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: 'Type medicine name...',
        hintStyle: GoogleFonts.inter(
          color: const Color(0xFFB0A8A2),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        filled: true,
        fillColor: const Color(0xFFFFF4EC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFF4EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFE4D4)),
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CreateQuoteSummary extends StatelessWidget {
  const _CreateQuoteSummary({required this.itemTotal, required this.tax});

  final int itemTotal;
  final int tax;

  @override
  Widget build(BuildContext context) {
    final total = itemTotal + tax;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'lib/pharmacy/Assets/images/quotation_summary.png',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Text(
                'QUOTATION SUMMARY',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.3,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SummaryLine(label: 'Item total', value: '$itemTotal MRU'),
          const SizedBox(height: 12),
          _SummaryLine(label: 'Tax', value: '$tax'),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: Color(0xFF5C5C5C)),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                '$total MRU',
                style: GoogleFonts.inter(
                  color: const Color(0xFFFF5722),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFFD0D0D0),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _QuoteActionBar extends StatelessWidget {
  const _QuoteActionBar({
    required this.label,
    required this.enabled,
    required this.enabledColor,
    required this.disabledColor,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final Color enabledColor;
  final Color disabledColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: enabled ? enabledColor : disabledColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: enabledColor.withValues(alpha: 0.32),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuotationSentDialog extends StatelessWidget {
  const _QuotationSentDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5722),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Quotation has been sent to the customer\nfor review and approval',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
                fontSize: 14.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, color: iconColor, size: 16),
        ),
      ),
    );
  }
}

class _InStockBadge extends StatelessWidget {
  const _InStockBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 3, 8, 3),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'In Stock',
            style: GoogleFonts.inter(
              color: const Color(0xFF10B981),
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitedBadge extends StatelessWidget {
  const _LimitedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5CD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFFBBF24),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'Limited',
            style: GoogleFonts.inter(
              color: const Color(0xFFD97706),
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutOfStockBadge extends StatelessWidget {
  const _OutOfStockBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDCD9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF8694)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFFF3250),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'Out of Stock',
            style: GoogleFonts.inter(
              color: const Color(0xFFFF3250),
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteValidMenu extends StatelessWidget {
  const _QuoteValidMenu({
    required this.value,
    required this.options,
    required this.onSelected,
  });

  final String? value;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        for (final option in options)
          PopupMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 7, 8, 7),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4EE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFE0D0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value ?? 'Quote Valid',
              style: GoogleFonts.inter(
                color: const Color(0xFFFF5722),
                fontWeight: FontWeight.w500,
                fontSize: 13,
                height: 1,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFFFF5722),
            ),
          ],
        ),
      ),
    );
  }
}
