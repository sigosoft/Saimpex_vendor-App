part of '../view/order_details_screen.dart';

class CreateQuotationController extends GetxController {
  static const medicineCatalog = <_QuotationMedicine>[
    _QuotationMedicine('Paracetamol 500 mg', 50, id: 4),
    _QuotationMedicine('Paracetamol 650 mg', 50, id: 4),
    _QuotationMedicine('Ibuprofen 400 mg', 65, id: 4),
    _QuotationMedicine('Ferrous Sulfate Syrup', 220, inStock: false, id: 4),
    _QuotationMedicine('Baby Diapers Size M', 380, id: 4),
  ];

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

  int get subtotal => lines.fold(0, (sum, line) => sum + line.lineTotal);

  bool get canSaveDraft {
    final current = draft;
    if (current == null || current.prescribedQty <= 0) return false;
    if (current.availability == _Availability.inStock) return true;
    if (current.availability == _Availability.limited) {
      return current.availableQty > 0;
    }
    if (current.availability == _Availability.outOfStock) {
      return current.alternatives.isNotEmpty;
    }
    return false;
  }

  List<_QuotationMedicine> filter(String query) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return const [];
    final matches = medicineCatalog
        .where((item) => item.name.toLowerCase().contains(text))
        .toList();
    if (matches.isEmpty) {
      return [_QuotationMedicine(query.trim(), 50, id: 4)];
    }
    return matches;
  }

  List<_QuotationMedicine> filterAlternatives(String query) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return const [];
    final current = draft?.medicine.name.toLowerCase();
    final matches = medicineCatalog.where((item) {
      final name = item.name.toLowerCase();
      return name.contains(text) && name != current;
    }).toList();
    if (matches.isEmpty) {
      return [_QuotationMedicine(query.trim(), 50, id: 4)];
    }
    return matches;
  }

  Future<bool> submitQuotation({
    required dynamic prescriptionId,
    int tax = 10,
    BuildContext? context,
  }) async {
    if (lines.isEmpty) {
      if (context != null && context.mounted) {
        showToast(context, 'Please add at least one medicine');
      } else {
        Fluttertoast.showToast(msg: 'Please add at least one medicine');
      }
      return false;
    }

    final parsedPrescriptionId = (prescriptionId is int)
        ? prescriptionId
        : int.tryParse(prescriptionId?.toString() ?? '');

    if (parsedPrescriptionId == null || parsedPrescriptionId <= 0) {
      if (context != null && context.mounted) {
        showToast(context, 'Prescription ID is required');
      } else {
        Fluttertoast.showToast(msg: 'Prescription ID is required');
      }
      return false;
    }

    isSubmitting = true;
    update();

    try {
      final int totalAmount = subtotal + tax;

      int days = 1;
      if (quoteValid != null && quoteValid!.isNotEmpty) {
        final match = RegExp(r'\d+').firstMatch(quoteValid!);
        if (match != null) {
          days = int.tryParse(match.group(0) ?? '') ?? 1;
        }
      }
      final expiryDate = DateTime.now().add(Duration(days: days));
      final quoteExpiresAt =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryDate);

      final List<Map<String, dynamic>> itemsList = [];
      for (final line in lines) {
        _QuotationMedicine med = line.medicine;
        if (line.availability == _Availability.outOfStock &&
            line.alternatives.isNotEmpty &&
            line.selectedAlternative < line.alternatives.length) {
          med = line.alternatives[line.selectedAlternative];
        }
        final qty = line.billedQty > 0 ? line.billedQty : line.prescribedQty;
        itemsList.add({
          'product_id': med.effectiveProductId,
          'name_en': med.effectiveNameEn,
          'name_ar': med.effectiveNameAr,
          'name_fr': med.effectiveNameFr,
          'quantity': qty > 0 ? qty : 1,
          'unit_price': med.priceMru,
        });
      }

      if (Get.isRegistered<PharmacyHomeController>()) {
        final homeCtrl = Get.find<PharmacyHomeController>();
        final ok = await homeCtrl.submitPharmacyPrescriptionQuote(
          prescriptionId: parsedPrescriptionId,
          quoteAmount: totalAmount,
          items: itemsList,
          quoteExpiresAt: quoteExpiresAt,
          context: context,
        );
        return ok;
      } else {
        final token = (await getSavedObject("token"))?.toString() ?? "";
        if (token.isNotEmpty) {
          DioClient().updateToken(token);
        }
        final formData = FormData.fromMap({
          'prescription_id': parsedPrescriptionId,
          'quote_amount': totalAmount,
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
      return false;
    } finally {
      isSubmitting = false;
      update();
    }
  }

  void onAltQueryChanged(String value) {
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

  void onMedicineQueryChanged(String _) => update();

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

  void setPrescribed(int value) {
    final current = draft;
    if (current == null) return;
    final wasLimited = current.availability == _Availability.limited;
    current.prescribedQty = value.clamp(0, 99);
    if (current.availableQty > current.prescribedQty) {
      current.availableQty = current.prescribedQty;
    }
    if (current.prescribedQty == 0) {
      current.availability = null;
      update();
      return;
    }
    if (!current.medicine.inStock) {
      current.availability = _Availability.outOfStock;
      update();
      return;
    }
    if (current.prescribedQty > 6) {
      current.availability = _Availability.limited;
      if (!wasLimited || current.availableQty == 0) {
        current.availableQty = 6.clamp(0, current.prescribedQty);
      }
    } else {
      current.availability = _Availability.inStock;
    }
    update();
  }

  void setAvailable(int value) {
    final current = draft;
    if (current == null) return;
    current.availableQty = value.clamp(0, current.prescribedQty);
    update();
  }

  void addAlternative(_QuotationMedicine medicine) {
    final current = draft;
    if (current == null) return;
    final existing = current.alternatives.indexWhere(
      (item) => item.name == medicine.name,
    );
    if (existing >= 0) {
      current.selectedAlternative = existing;
    } else {
      current.alternatives.add(medicine);
      current.selectedAlternative = current.alternatives.length - 1;
    }
    altController.clear();
    update();
  }

  @override
  void onClose() {
    medicineController.dispose();
    medicineFocus.dispose();
    altController.dispose();
    altFocus.dispose();
    super.onClose();
  }
}
