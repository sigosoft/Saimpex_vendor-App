part of '../view/order_details_screen.dart';

/// Create Quotation for a prescription (API doc §6.15, task V11).
///
/// Medicines come from the pharmacy's own inventory (`pharmacyMenuItems`,
/// with stock and price). For each prescribed medicine the availability
/// follows the stock: enough → available, some → partial (offers what is in
/// stock), none or not carried → unavailable, optionally with an in-stock
/// alternative the customer accepts or rejects. The server computes the
/// quote amount (available + partial lines, plus accepted alternatives).
class CreateQuotationController extends GetxController {
  /// [search] returns `pharmacyMenuItems` rows (the API by default; tests
  /// pass fixed rows).
  CreateQuotationController({Future<List<Map<String, dynamic>>> Function(String keyword)? search})
      : _search = search ?? _searchInventory;

  final Future<List<Map<String, dynamic>>> Function(String keyword) _search;

  final medicineController = TextEditingController();
  final medicineFocus = FocusNode();
  final altController = TextEditingController();
  final altFocus = FocusNode();
  final lines = <_QuotationLine>[];

  _QuotationLine? draft;
  int? editingIndex;
  String? quoteValid;
  double rotationTurns = 0;
  bool isSubmitting = false;

  /// Latest search results for the medicine and alternative fields.
  List<_QuotationMedicine> results = const [];
  List<_QuotationMedicine> altResults = const [];
  bool searching = false;
  Timer? _debounce;
  int _searchSeq = 0;

  static Future<List<Map<String, dynamic>>> _searchInventory(String keyword) async {
    final token = (await getSavedObject('token'))?.toString() ?? '';
    if (token.isNotEmpty) DioClient().updateToken(token);
    final res = await DioClient().get(ApiEndPoints.pharmacyMenuItems, query: {
      'limit': 20,
      'page': 1,
      'status': 1,
      'keyword': keyword,
    });
    final data = res.data is Map ? res.data['data'] : null;
    final page = data is Map ? data['pharmacy_menu_items'] : null;
    final rows = page is Map ? page['data'] : page;
    if (rows is! List) return const [];
    return rows.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
  }

  /// What the customer pays now: available and partial lines.
  num get subtotal => lines.fold<num>(0, (sum, line) => sum + line.lineTotal);

  /// Alternatives, charged only if the customer accepts them.
  num get alternativesTotal => lines.fold<num>(0, (sum, line) => sum + line.alternativeTotal);

  bool get canSaveDraft {
    final current = draft;
    if (current == null || current.prescribedQty <= 0) return false;
    return switch (current.availability) {
      _Availability.inStock => true,
      _Availability.limited => current.availableQty > 0,
      _Availability.outOfStock => true, // shown to the customer at no cost
      null => false,
    };
  }

  /// Inventory matches, plus the typed name as a medicine the store does
  /// not carry (it is quoted as unavailable).
  List<_QuotationMedicine> filter(String query) {
    final text = query.trim();
    if (text.isEmpty) return const [];
    final exact = results.any((m) => m.name.toLowerCase() == text.toLowerCase());
    return [...results, if (!exact && !searching) _QuotationMedicine(text, 0, stock: 0)];
  }

  /// In-stock inventory items other than the medicine being quoted.
  List<_QuotationMedicine> filterAlternatives(String query) {
    if (query.trim().isEmpty) return const [];
    final current = draft?.medicine;
    return altResults
        .where((m) => m.inStock && (current?.productId == null || m.productId != current!.productId))
        .toList();
  }

  void _schedule(String value, {required bool alt}) {
    _debounce?.cancel();
    final keyword = value.trim();
    if (keyword.isEmpty) {
      if (alt) {
        altResults = const [];
      } else {
        results = const [];
      }
      searching = false;
      update();
      return;
    }
    searching = true;
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final seq = ++_searchSeq;
      List<_QuotationMedicine> found = const [];
      try {
        found = (await _search(keyword)).map(_QuotationMedicine.fromInventory).toList();
      } catch (e) {
        debugPrint('pharmacy inventory search: $e');
      }
      if (seq != _searchSeq || isClosed) return;
      if (alt) {
        altResults = found;
      } else {
        results = found;
      }
      searching = false;
      update();
    });
  }

  /// Items as §6.15 expects them.
  List<Map<String, dynamic>> buildItems() {
    Map<String, dynamic> row(_QuotationMedicine med, int qty, String availability) => {
          if (med.productId != null) 'product_id': med.productId,
          'name_en': med.effectiveNameEn,
          if (med.effectiveNameAr.isNotEmpty) 'name_ar': med.effectiveNameAr,
          if (med.effectiveNameFr.isNotEmpty) 'name_fr': med.effectiveNameFr,
          'quantity': qty < 1 ? 1 : qty,
          'unit_price': med.priceMru,
          'availability': availability,
        };

    final items = <Map<String, dynamic>>[];
    for (final line in lines) {
      final med = line.medicine;
      switch (line.availability) {
        case _Availability.inStock:
          items.add(row(med, line.prescribedQty, 'available'));
        case _Availability.limited:
          items.add(row(med, line.availableQty, 'partial')..['requested_quantity'] = line.prescribedQty);
        case _Availability.outOfStock:
          items.add(row(med, line.prescribedQty, 'unavailable'));
          final alt = line.alternative;
          if (alt != null) {
            items.add(row(alt, line.alternativeQty, 'available')..['alternative_for'] = med.effectiveNameEn);
          }
        case null:
          break;
      }
    }
    return items;
  }

  Future<bool> submitQuotation({
    required dynamic prescriptionId,
    BuildContext? context,
  }) async {
    void toast(String msg) {
      if (context != null && context.mounted) {
        showToast(context, msg);
      } else {
        Fluttertoast.showToast(msg: msg);
      }
    }

    if (lines.isEmpty) {
      toast(S.current.quoteAddOneMedicine);
      return false;
    }

    final parsedPrescriptionId = (prescriptionId is int)
        ? prescriptionId
        : int.tryParse(prescriptionId?.toString() ?? '');

    if (parsedPrescriptionId == null || parsedPrescriptionId <= 0) {
      toast(S.current.quotePrescriptionMissing);
      return false;
    }

    isSubmitting = true;
    update();

    try {
      int days = 1;
      if (quoteValid != null && quoteValid!.isNotEmpty) {
        final match = RegExp(r'\d+').firstMatch(quoteValid!);
        if (match != null) {
          days = int.tryParse(match.group(0) ?? '') ?? 1;
        }
      }
      final expiryDate = DateTime.now().add(Duration(days: days));
      final quoteExpiresAt = DateFormat('yyyy-MM-dd HH:mm:ss', 'en').format(expiryDate);
      final itemsList = buildItems();

      if (Get.isRegistered<PharmacyHomeController>()) {
        final homeCtrl = Get.find<PharmacyHomeController>();
        return await homeCtrl.submitPharmacyPrescriptionQuote(
          prescriptionId: parsedPrescriptionId,
          // The server recomputes it from the lines; sent for older servers.
          quoteAmount: subtotal,
          items: itemsList,
          quoteExpiresAt: quoteExpiresAt,
          context: context,
        );
      } else {
        final token = (await getSavedObject("token"))?.toString() ?? "";
        if (token.isNotEmpty) {
          DioClient().updateToken(token);
        }
        final formData = FormData.fromMap({
          'prescription_id': parsedPrescriptionId,
          'quote_amount': subtotal,
          'items': jsonEncode(itemsList),
          'quote_expires_at': quoteExpiresAt,
        });
        final response = await DioClient().post(
          ApiEndPoints.submitPharmacyPrescriptionQuote,
          body: formData,
        );
        return response.statusCode == 200;
      }
    } catch (e) {
      debugPrint("Error submitting quote: $e");
      toast(e is String && e.trim().isNotEmpty ? e : S.current.somethingWentWrong);
      return false;
    } finally {
      isSubmitting = false;
      update();
    }
  }

  void onAltQueryChanged(String value) {
    _schedule(value, alt: true);
    update();
    if (value.trim().isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fieldContext = altFocus.context;
      if (fieldContext == null) return;
      Scrollable.ensureVisible(
        fieldContext,
        alignment: 0.05,
        duration: const Duration(milliseconds: 250),
      );
    });
  }

  void onMedicineQueryChanged(String value) {
    _schedule(value, alt: false);
    update();
  }

  void setQuoteValid(String value) {
    quoteValid = value;
    update();
  }

  void rotatePrescription() {
    rotationTurns += 0.25;
    update();
  }

  void focusMedicineSearch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      medicineFocus.requestFocus();
    });
  }

  void beginDraft(_QuotationMedicine medicine) {
    medicineFocus.unfocus();
    final line = _QuotationLine(medicine);
    medicineController.clear();
    altController.clear();
    results = const [];
    altResults = const [];
    draft = line;
    editingIndex = null;
    update();
  }

  void removeSavedLine(int index) {
    lines.removeAt(index);
    update();
  }

  void editLine(int index) {
    draft = lines[index].copy();
    editingIndex = index;
    altController.clear();
    update();
  }

  void discardDraft() {
    if (editingIndex != null) {
      lines.removeAt(editingIndex!);
    }
    draft = null;
    editingIndex = null;
    altController.clear();
    update();
  }

  void saveDraft() {
    final current = draft;
    if (current == null || !canSaveDraft) return;
    final index = editingIndex;
    if (index != null && index < lines.length) {
      lines[index] = current;
    } else {
      lines.add(current);
    }
    draft = null;
    editingIndex = null;
    altController.clear();
    update();
  }

  /// Availability follows the stock the inventory reports.
  void setPrescribed(int value) {
    final current = draft;
    if (current == null) return;
    current.prescribedQty = value.clamp(0, 999);
    if (current.prescribedQty == 0) {
      current.availability = null;
      update();
      return;
    }
    final stock = current.medicine.stock;
    if (!current.medicine.inStock) {
      current.availability = _Availability.outOfStock;
    } else if (stock != null && stock < current.prescribedQty) {
      current.availability = _Availability.limited;
      current.availableQty = stock;
    } else {
      current.availability = _Availability.inStock;
      current.availableQty = current.prescribedQty;
    }
    update();
  }

  /// Partial lines: at least 1, below the prescribed quantity, within stock.
  void setAvailable(int value) {
    final current = draft;
    if (current == null) return;
    var max = current.prescribedQty - 1;
    final stock = current.medicine.stock;
    if (stock != null && stock < max) max = stock;
    current.availableQty = value.clamp(0, max < 0 ? 0 : max);
    update();
  }

  /// One alternative per unavailable medicine; picking another replaces it.
  void addAlternative(_QuotationMedicine medicine) {
    final current = draft;
    if (current == null) return;
    current.alternatives
      ..clear()
      ..add(medicine);
    current.selectedAlternative = 0;
    altController.clear();
    altResults = const [];
    update();
  }

  void removeAlternative() {
    draft?.alternatives.clear();
    update();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    medicineController.dispose();
    medicineFocus.dispose();
    altController.dispose();
    altFocus.dispose();
    super.onClose();
  }
}
