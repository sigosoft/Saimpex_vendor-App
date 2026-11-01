part of 'order_details_screen.dart';

enum _Availability { inStock, limited, outOfStock }

class PharmacyCreateQuotationScreen extends StatefulWidget {
  const PharmacyCreateQuotationScreen({
    super.key,
    this.customerName = '',
    this.phone = '',
    this.requestId = '',
    this.requestMeta = '',
    this.imageUrl,
    this.imageBytes,
    this.prescriptionId,
  });

  final String customerName;
  final String phone;
  final String requestId;
  final String requestMeta;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final int? prescriptionId;

  @override
  State<PharmacyCreateQuotationScreen> createState() =>
      _PharmacyCreateQuotationScreenState();
}

class _PharmacyCreateQuotationScreenState
    extends State<PharmacyCreateQuotationScreen> {
  static const Color _orange = Color(0xFFFF5216);
  static const Color _disabled = Color(0xFFFFCDBA);
  bool _isSending = false;

  List<String> _validityOptions(BuildContext context) => [
        S.of(context).quoteValidityOneDay,
        for (final n in const [3, 7, 15, 30]) S.of(context).quoteValidityDays('$n'),
      ];

  late final CreateQuotationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CreateQuotationController>()
        ? Get.find<CreateQuotationController>()
        : Get.put(CreateQuotationController());
  }

  @override
  void dispose() {
    Get.delete<CreateQuotationController>();
    super.dispose();
  }

  void _openFullPrescription() {
    final effectiveImageUrl = widget.imageUrl ??
        (Get.isRegistered<PharmacyOrderDetailsController>()
            ? Get.find<PharmacyOrderDetailsController>()
                .prescriptionDetailData
                ?.primaryImageUrl
            : null);
    final effectiveBytes = widget.imageBytes ??
        (Get.isRegistered<PharmacyOrderDetailsController>()
            ? Get.find<PharmacyOrderDetailsController>().prescriptionImageBytes
            : null);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullPrescriptionViewer(
          imageUrl: effectiveImageUrl,
          imageBytes: effectiveBytes,
          rotationTurns: controller.rotationTurns,
        ),
      ),
    );
  }

  Future<void> _confirmRemove(int index) async {
    final name = controller.lines[index].medicine.name;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => _DeleteMedicineDialog(name: name),
    );
    if (confirmed == true && mounted) {
      controller.removeSavedLine(index);
    }
  }

  Future<void> _send() async {
    if (controller.lines.isEmpty) return;
    if (_isSending || controller.isSubmitting) return;

    final effectivePrescriptionId = widget.prescriptionId ??
        (Get.isRegistered<PharmacyOrderDetailsController>()
            ? Get.find<PharmacyOrderDetailsController>()
                .prescriptionObj
                ?.prescriptionId
            : null);

    if (effectivePrescriptionId == null) {
      Fluttertoast.showToast(msg: S.of(context).quotePrescriptionMissing);
      return;
    }

    setState(() {
      _isSending = true;
    });

    final success = await controller.submitQuotation(
      prescriptionId: effectivePrescriptionId,
      context: context,
    );

    if (!mounted) return;
    setState(() {
      _isSending = false;
    });

    if (success) {
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierLabel: S.of(context).quoteSentLabel,
        barrierColor: Colors.transparent,
        pageBuilder: (context, _, __) => const _QuotationSentDialog(),
      );
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      final navigator = Navigator.of(context);
      navigator.pop();
      if (Get.isRegistered<PharmacyHomeController>()) {
        Get.find<PharmacyHomeController>().showReviewCompleted();
      }
      navigator.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateQuotationController>(
      builder: (_) {
        final prescObj = Get.isRegistered<PharmacyOrderDetailsController>()
            ? Get.find<PharmacyOrderDetailsController>().prescriptionObj
            : null;
        final rawCustName = widget.customerName.trim();
        final effectiveCustomerName = rawCustName.isNotEmpty && rawCustName != 'Ahmed'
            ? rawCustName
            : (prescObj?.customerName?.trim().isNotEmpty == true
                ? prescObj!.customerName!
                : (rawCustName.isNotEmpty ? rawCustName : S.of(context).quoteCustomer));
        final initial = effectiveCustomerName.isNotEmpty
            ? effectiveCustomerName.substring(0, 1).toUpperCase()
            : 'C';
        final rawPhone = widget.phone.trim();
        final effectivePhone = rawPhone.isNotEmpty && rawPhone != '+222 45 12 34 56'
            ? rawPhone
            : (prescObj?.displayPhone.trim().isNotEmpty == true
                ? prescObj!.displayPhone
                : (rawPhone.isNotEmpty ? rawPhone : ''));
        final rawRequestId = widget.requestId.trim();
        final effectiveRequestId = rawRequestId.isNotEmpty && rawRequestId != '#22789007'
            ? rawRequestId
            : (widget.prescriptionId != null
                ? '#${widget.prescriptionId}'
                : (prescObj?.prescriptionId != null
                    ? '#${prescObj!.prescriptionId}'
                    : (rawRequestId.isNotEmpty ? rawRequestId : '')));
        final rawRequestMeta = widget.requestMeta.trim();
        final effectiveRequestMeta = rawRequestMeta.isNotEmpty && rawRequestMeta != 'Today • 10:45 AM'
            ? rawRequestMeta
            : (prescObj?.createdAt?.trim().isNotEmpty == true
                ? prescObj!.createdAt!
                : (rawRequestMeta.isNotEmpty ? rawRequestMeta : ''));
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
                              S.of(context).quoteCreateTitle,
                              style: appFont('Inter', 
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
                            name: effectiveCustomerName,
                            phone: effectivePhone,
                            requestId: effectiveRequestId,
                            requestMeta: effectiveRequestMeta,
                            reviewCompleted: true,
                            onChatTap: () => _openCustomerChat(
                              context,
                              customerName: effectiveCustomerName,
                              customerId: prescObj?.userId,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _UploadedPrescriptionCard(
                            imageUrl: widget.imageUrl ??
                                (Get.isRegistered<PharmacyOrderDetailsController>()
                                    ? Get.find<PharmacyOrderDetailsController>()
                                        .prescriptionDetailData
                                        ?.primaryImageUrl
                                    : null),
                            imageBytes: widget.imageBytes ??
                                (Get.isRegistered<PharmacyOrderDetailsController>()
                                    ? Get.find<PharmacyOrderDetailsController>()
                                        .prescriptionImageBytes
                                    : null),
                            isLoading: (Get.isRegistered<PharmacyOrderDetailsController>()
                                ? Get.find<PharmacyOrderDetailsController>().isLoadingPrescriptionImage
                                : false),
                            rotationTurns: controller.rotationTurns,
                            onZoom: _openFullPrescription,
                            onRotate: controller.rotatePrescription,
                            onViewFull: _openFullPrescription,
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Text(
                                S.of(context).quoteItemsTitle,
                                style: appFont('Inter', 
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
                                  options: _validityOptions(context),
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
                              onRemoveAlternative: controller.removeAlternative,
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
                              onRemove: (index) {
                                _confirmRemove(index);
                              },
                            ),
                          if (!editing && controller.lines.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _CreateQuoteSummary(
                              itemTotal: controller.subtotal,
                              alternativesTotal: controller.alternativesTotal,
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
                label: editing ? S.of(context).quoteSaveAndNext : S.of(context).quoteSend,
                enabled: editing
                    ? controller.canSaveDraft
                    : (controller.lines.isNotEmpty &&
                        !_isSending &&
                        !controller.isSubmitting),
                isLoading: !editing && (_isSending || controller.isSubmitting),
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

/// "50 MRU" / "12.50 MRU" style amount without the currency.
String _amount(num v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

class _QuotationMedicine {
  const _QuotationMedicine(
    this.name,
    this.priceMru, {
    this.stock,
    this.productId,
    this.nameEn,
    this.nameAr,
    this.nameFr,
  });

  /// A row of `pharmacyMenuItems` (id = pharmacy_menu_items.id).
  factory _QuotationMedicine.fromInventory(Map<String, dynamic> m) {
    String clean(dynamic v) => (v == null || '$v' == 'null') ? '' : '$v'.trim();
    final lang = LocalizationService.currentLanguageCode;
    final en = clean(m['menu_name_en']);
    final local = clean(m['menu_name_$lang']);
    final variant = [clean(m['attribute_value']), clean(m['attribute_name_en'])]
        .where((e) => e.isNotEmpty)
        .join(' ');
    String withVariant(String n) => variant.isEmpty || n.contains(variant) ? n : '$n $variant';
    final offer = num.tryParse(clean(m['offer_price']));
    final price = offer != null && offer > 0
        ? offer
        : (num.tryParse(clean(m['selling_price'])) ?? num.tryParse(clean(m['price'])) ?? 0);
    return _QuotationMedicine(
      withVariant(local.isNotEmpty ? local : en),
      price,
      stock: int.tryParse(clean(m['stock'])) ?? 0,
      productId: int.tryParse(clean(m['id'])),
      nameEn: withVariant(en),
      nameAr: clean(m['menu_name_ar']).isEmpty ? null : withVariant(clean(m['menu_name_ar'])),
      nameFr: clean(m['menu_name_fr']).isEmpty ? null : withVariant(clean(m['menu_name_fr'])),
    );
  }

  final String name;
  final num priceMru;

  /// Units in stock; null when unknown (treated as available).
  final int? stock;
  final int? productId;
  final String? nameEn;
  final String? nameAr;
  final String? nameFr;

  bool get inStock => stock == null || stock! > 0;

  /// Typed by the vendor, not in the inventory (quoted as unavailable).
  bool get notCarried => productId == null;

  String get effectiveNameEn =>
      (nameEn != null && nameEn!.isNotEmpty) ? nameEn! : name;
  String get effectiveNameAr => nameAr ?? '';
  String get effectiveNameFr => nameFr ?? '';
}

class _QuotationLine {
  _QuotationLine(this.medicine);

  final _QuotationMedicine medicine;
  int prescribedQty = 0;
  int availableQty = 0;
  _Availability? availability;
  final List<_QuotationMedicine> alternatives = [];
  int selectedAlternative = 0;

  int get billedQty => switch (availability) {
        _Availability.limited => availableQty,
        _Availability.outOfStock => 0,
        _ => prescribedQty,
      };

  /// Charged now (unavailable lines cost nothing).
  num get lineTotal => medicine.priceMru * billedQty;

  _QuotationMedicine? get alternative =>
      availability == _Availability.outOfStock && alternatives.isNotEmpty
          ? alternatives[selectedAlternative.clamp(0, alternatives.length - 1)]
          : null;

  /// The alternative covers the prescribed quantity, within its stock.
  int get alternativeQty {
    final alt = alternative;
    if (alt == null) return 0;
    final stock = alt.stock;
    return stock != null && stock < prescribedQty ? stock : prescribedQty;
  }

  /// Charged only if the customer accepts the alternative.
  num get alternativeTotal => (alternative?.priceMru ?? 0) * alternativeQty;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines.length; i++) ...[
          _QuoteCard(
            child: _SavedLineTile(
              index: i,
              line: lines[i],
              onEdit: () => onEdit(i),
              onRemove: () => onRemove(i),
            ),
          ),
          const SizedBox(height: 12),
        ],
        _QuoteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          TextButton.icon(
            onPressed: onAddMedicine,
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              S.of(context).quoteAddMedicine,
              style: appFont('Inter', 
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF5216),
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
        ),
      ],
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
    required this.onRemoveAlternative,
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
  final VoidCallback onRemoveAlternative;

  @override
  Widget build(BuildContext context) {
    final alt = draft.alternative;
    final showTotal = draft.prescribedQty > 0 &&
        (draft.availability == _Availability.inStock ||
            (draft.availability == _Availability.limited &&
                draft.availableQty > 0) ||
            alt != null);
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
                      style: appFont('Inter', 
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
                        Icons.delete,
                        color: Color(0xFFE53935),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
          Text(
            S.of(context).quotePrescribedQty,
            style: appFont('Inter', 
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
                  S.of(context).quoteUnit,
                  style: appFont('Inter', 
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
          S.of(context).quoteAvailabilityTitle,
            style: appFont('Inter', 
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
                        S.of(context).quoteAvailableQty,
                        style: appFont('Inter', 
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
            if (draft.alternatives.isNotEmpty) ...[
              _SuggestedAlternativeBox(
                original: draft.medicine,
                medicines: draft.alternatives,
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: onRemoveAlternative,
                  icon: const Icon(Icons.close, size: 16, color: Color(0xFFE53935)),
                  label: Text(
                    S.of(context).quoteDelete,
                    style: appFont('Inter', color: const Color(0xFFE53935), fontSize: 13),
                  ),
                ),
              ),
            ] else ...[
              Text(
                S.of(context).quoteSuggestAlternative,
                style: appFont('Inter', 
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
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
              quantity: alt != null ? draft.alternativeQty : draft.billedQty,
              price: alt?.priceMru ?? draft.medicine.priceMru,
              total: alt != null ? draft.alternativeTotal : draft.lineTotal,
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
    final showAlternative = line.availability == _Availability.outOfStock &&
        line.alternatives.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _AvailabilityStatus(availability: line.availability),
            const Spacer(),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.delete,
                  color: Color(0xFFE53935),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${index + 1}. ${line.medicine.name}',
          style: appFont('Inter', 
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
            height: 1.25,
          ),
        ),
        if (line.availability == _Availability.limited) ...[
          const SizedBox(height: 8),
          _AvailableCountPill(
            available: line.availableQty,
            prescribed: line.prescribedQty,
          ),
        ],
        if (showAlternative) ...[
          const SizedBox(height: 14),
          _SuggestedAlternativeBox(
            original: line.medicine,
            medicines: line.alternatives,
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              S.of(context).quoteUnit,
              style: appFont('Inter', 
                color: const Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
            const Spacer(),
            Text(
              S.of(context).quoteTotal,
              style: appFont('Inter', 
                color: const Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              line.alternative != null
                  ? S.of(context).quoteQtyTimesPrice('${line.alternativeQty}', _amount(line.alternative!.priceMru))
                  : S.of(context).quoteQtyTimesPrice('${line.billedQty}', _amount(line.medicine.priceMru)),
              style: appFont('Inter', 
                color: const Color(0xFF3F2A24),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: _amount(line.alternative != null ? line.alternativeTotal : line.lineTotal),
                    style: appFont('Inter', 
                      color: const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      height: 1,
                    ),
                  ),
                  TextSpan(
                    text: ' MRU',
                    style: appFont('Inter', 
                      color: const Color(0xFFFF5216),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1,
                    ),
                  ),
                ],
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
    final style = switch (availability) {
      _Availability.inStock => _StatusPillStyle(
          label: S.of(context).quoteAvailableInStock,
          foreground: Color(0xFF16A34A),
          background: Color(0xFFE8F8EF),
          border: Color(0xFF86E0A8),
          dot: Color(0xFF22C55E),
        ),
      _Availability.limited => _StatusPillStyle(
          label: S.of(context).quotePartialLimited,
          foreground: Color(0xFFC4841A),
          background: Color(0xFFFFF6D8),
          border: Color(0xFFF0D090),
          dot: Color(0xFFF5B400),
        ),
      _Availability.outOfStock => _StatusPillStyle(
          label: S.of(context).quoteNotAvailableOut,
          foreground: Color(0xFF1A1A1A),
          background: Color(0xFFFFF7F8),
          border: Color(0xFFFFB3C1),
          dot: Color(0xFFFF4D6A),
        ),
      null => null,
    };
    if (style == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 12, 5),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: style.dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            style.label,
            style: appFont('Inter', 
              color: style.foreground,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPillStyle {
  const _StatusPillStyle({
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
    required this.dot,
  });

  final String label;
  final Color foreground;
  final Color background;
  final Color border;
  final Color dot;
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
            label: S.of(context).quoteAvailable,
            badge: const _InStockBadge(),
          ),
          const SizedBox(width: 8),
          _AvailabilityChoice(
            selected: selected == _Availability.limited,
            selectedFill: const Color(0xFFFFF6D9),
            label: S.of(context).quotePartiallyAvailable,
            badge: const _LimitedBadge(),
          ),
          const SizedBox(width: 8),
          _AvailabilityChoice(
            selected: selected == _Availability.outOfStock,
            selectedFill: const Color(0xFFFFF1EC),
            label: S.of(context).quoteNotAvailable,
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
            color: selected ? const Color(0xFFFF5216) : const Color(0xFFE2E8F0),
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
              style: appFont('Inter', 
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
        S.of(context).quoteAvailableOf('$available', '$prescribed'),
        style: appFont('Inter', 
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
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).quoteSuggestedAlternative,
            style: appFont('Inter', 
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _SuggestedAlternativeRow(
                  name: original.name,
                  inStock: false,
                ),
                for (final medicine in medicines) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 246, 253),
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          size: 16,
                          color: Color(0xFFFF5216),
                        ),
                      ),
                    ),
                  ),
                  _SuggestedAlternativeRow(
                    name: medicine.name,
                    inStock: medicine.inStock,
                    bold: true,
                  ),
                ],
              ],
            ),
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
    this.bold = false,
  });

  final String name;
  final bool inStock;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: inStock ? const Color(0xFF22C55E) : const Color(0xFFFF3250),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: appFont('Inter', 
              color: const Color(0xFF1E293B),
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ],
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
                  style: appFont('Inter', 
                    color: const Color(0xFF3A3A3A),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
                if (showBadge) ...[
                  const SizedBox(height: 6),
                  if (medicine.inStock)
                    Row(children: [
                      const _InStockBadge(),
                      if (medicine.stock != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          S.of(context).quoteStockLeft('${medicine.stock}'),
                          style: appFont('Inter', color: const Color(0xFF6B7280), fontSize: 12),
                        ),
                      ],
                    ])
                  else
                    const _OutOfStockBadge(),
                ],
              ],
            ),
          ),
          Text(
            medicine.notCarried ? S.of(context).quoteNotCarried : '${_amount(medicine.priceMru)} MRU',
            style: appFont('Inter', 
              color: const Color(0xFFFF5216),
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
                color: Color(0xFFFF5216),
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
  final num price;
  final num total;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          S.of(context).quoteItemTotal,
          style: appFont('Inter', 
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
              S.of(context).quoteQtyTimesPrice('$quantity', _amount(price)),
              style: appFont('Inter', 
                color: const Color(0xFF9CA3AF),
                fontWeight: FontWeight.w400,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${_amount(total)} MRU',
              style: appFont('Inter', 
                color: const Color(0xFFFF5216),
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
              style: appFont('Inter', 
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
          style: appFont('Inter', 
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
            style: appFont('Inter', 
              color: const Color(0xFF2C2C2C),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        _QtyButton(
          icon: Icons.add,
          background: const Color(0xFFFF5216),
          iconColor: Colors.white,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _PricePill extends StatelessWidget {
  const _PricePill({required this.price});

  final num price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        '${_amount(price)} MRU',
        style: appFont('Inter', 
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
      style: appFont('Inter', 
        color: const Color(0xFF3A3A3A),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: S.of(context).quoteTypeMedicine,
        hintStyle: appFont('Inter', 
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
      style: appFont('Inter', 
        color: const Color(0xFF4A4A4A),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: S.of(context).quoteTypeMedicine,
        hintStyle: appFont('Inter', 
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
  const _CreateQuoteSummary({required this.itemTotal, required this.alternativesTotal});

  final num itemTotal;
  final num alternativesTotal;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                s.quoteSummary,
                style: appFont('Inter', 
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
          _SummaryLine(label: s.quoteItemTotal, value: '${_amount(itemTotal)} MRU'),
          if (alternativesTotal > 0) ...[
            const SizedBox(height: 12),
            _SummaryLine(label: s.quoteAlternativesIfAccepted, value: '${_amount(alternativesTotal)} MRU'),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: Color(0xFF5C5C5C)),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                s.quoteTotalAmount,
                style: appFont('Inter', 
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                '${_amount(itemTotal)} MRU',
                style: appFont('Inter', 
                  color: const Color(0xFFFF5216),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            s.quoteServerTotalNote,
            style: appFont('Inter', color: const Color(0xFFD0D0D0), fontSize: 11.5, height: 1.3),
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
          style: appFont('Inter', 
            color: const Color(0xFFD0D0D0),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: appFont('Inter', 
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
    this.isLoading = false,
  });

  final String label;
  final bool enabled;
  final Color enabledColor;
  final Color disabledColor;
  final VoidCallback onPressed;
  final bool isLoading;

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
            onPressed: (enabled && !isLoading) ? onPressed : null,
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
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    label,
                    style: appFont('Inter', 
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

class _DeleteMedicineDialog extends StatelessWidget {
  const _DeleteMedicineDialog({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1F3),
                shape: BoxShape.circle,
              ),
              child: const _TrashDropIcon(),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).quoteDeleteTitle,
              textAlign: TextAlign.center,
              style: appFont('Inter', 
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).quoteDeleteBody(name),
              textAlign: TextAlign.center,
              style: appFont('Inter', 
                color: const Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
                fontSize: 14.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A1A1A),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      S.of(context).cancel,
                      style: appFont('Inter', 
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      S.of(context).quoteDelete,
                      style: appFont('Inter', 
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
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
}

class _TrashDropIcon extends StatefulWidget {
  const _TrashDropIcon();

  @override
  State<_TrashDropIcon> createState() => _TrashDropIconState();
}

class _TrashDropIconState extends State<_TrashDropIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _lidOpen(double t) {
    if (t < 0.22) return Curves.easeOut.transform(t / 0.22);
    if (t < 0.62) return 1;
    if (t < 0.82) {
      return 1 - Curves.easeIn.transform((t - 0.62) / 0.20);
    }
    return 0;
  }

  double _wasteDrop(double t) {
    if (t < 0.24 || t > 0.60) return -1;
    return Curves.easeIn.transform((t - 0.24) / 0.36);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _TrashDropPainter(
              lidOpen: _lidOpen(_controller.value),
              wasteDrop: _wasteDrop(_controller.value),
            ),
          );
        },
      ),
    );
  }
}

class _TrashDropPainter extends CustomPainter {
  const _TrashDropPainter({required this.lidOpen, required this.wasteDrop});

  final double lidOpen;
  final double wasteDrop;

  @override
  void paint(Canvas canvas, Size size) {
    const red = Color(0xFFE53935);
    final binPaint = Paint()..color = red..style = PaintingStyle.fill;

    final body = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        size.width * 0.20,
        size.height * 0.36,
        size.width * 0.60,
        size.height * 0.56,
      ),
      bottomLeft: const Radius.circular(3.5),
      bottomRight: const Radius.circular(3.5),
    );
    canvas.drawRRect(body, binPaint);

    final slotPaint = Paint()..color = Colors.white;
    final slotTop = body.top + body.height * 0.16;
    final slotHeight = body.height * 0.58;
    final slotWidth = size.width * 0.075;
    for (final left in [
      body.left + body.width * 0.30,
      body.left + body.width * 0.58,
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, slotTop, slotWidth, slotHeight),
          const Radius.circular(2),
        ),
        slotPaint,
      );
    }

    _paintWaste(canvas, size, body.outerRect);

    final lid = Rect.fromLTWH(
      size.width * 0.10,
      size.height * 0.26,
      size.width * 0.80,
      size.height * 0.10,
    );
    final hinge = Offset(lid.left, lid.bottom);
    canvas.save();
    canvas.translate(hinge.dx, hinge.dy);
    canvas.rotate(-0.85 * lidOpen);
    canvas.translate(-hinge.dx, -hinge.dy);
    canvas.drawRRect(
      RRect.fromRectAndRadius(lid, const Radius.circular(1.5)),
      binPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.36,
          size.height * 0.15,
          size.width * 0.28,
          size.height * 0.11,
        ),
        const Radius.circular(2),
      ),
      binPaint,
    );
    canvas.restore();
  }

  void _paintWaste(Canvas canvas, Size size, Rect bin) {
    if (wasteDrop < 0) return;
    final width = size.width * 0.22;
    final height = size.height * 0.14;
    final left = (size.width - width) / 2;
    final startY = size.height * 0.02;
    final endY = bin.top + bin.height * 0.42;
    final top = startY + (endY - startY) * wasteDrop;
    final scrap = Rect.fromLTWH(left, top, width, height);
    final scrapRadius = RRect.fromRectAndRadius(
      scrap,
      const Radius.circular(2),
    );
    final rim = bin.top + 1;

    if (scrap.bottom <= rim) {
      canvas.drawRRect(
        scrapRadius,
        Paint()..color = const Color(0xFFFFE4C8),
      );
      return;
    }

    if (scrap.top < rim) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width, rim));
      canvas.drawRRect(
        scrapRadius,
        Paint()..color = const Color(0xFFFFE4C8),
      );
      canvas.restore();
    }

    final fade = ((scrap.top - rim) / (bin.height * 0.4)).clamp(0.0, 1.0);
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(bin.left + 2, rim, bin.width - 4, bin.height),
    );
    canvas.drawRRect(
      scrapRadius,
      Paint()..color = const Color(0xFFFFE4C8).withValues(alpha: 1 - fade),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TrashDropPainter oldDelegate) {
    return oldDelegate.lidOpen != lidOpen || oldDelegate.wasteDrop != wasteDrop;
  }
}

class _QuotationSentDialog extends StatelessWidget {
  const _QuotationSentDialog();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.25),
          child: Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'lib/pharmacy/Assets/images/tick.png',
                    width: 72,
                    height: 72,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context).quoteSentBody,
                    textAlign: TextAlign.center,
                    style: appFont('Inter', 
                      color: const Color(0xFF4B5563),
                      fontWeight: FontWeight.w500,
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
            S.of(context).quoteInStock,
            style: appFont('Inter', 
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
            S.of(context).quoteLimited,
            style: appFont('Inter', 
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
            S.of(context).outOfStock,
            style: appFont('Inter', 
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
              style: appFont('Inter', 
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
              value ?? S.of(context).quoteValidLabel,
              style: appFont('Inter', 
                color: const Color(0xFFFF5216),
                fontWeight: FontWeight.w500,
                fontSize: 13,
                height: 1,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFFFF5216),
            ),
          ],
        ),
      ),
    );
  }
}
