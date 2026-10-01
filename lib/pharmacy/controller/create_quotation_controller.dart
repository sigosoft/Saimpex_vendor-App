part of '../view/order_details_screen.dart';

class CreateQuotationController extends GetxController {
  static const medicineCatalog = <_QuotationMedicine>[
    _QuotationMedicine('Paracetamol 500 mg', 50),
    _QuotationMedicine('Paracetamol 650 mg', 50),
    _QuotationMedicine('Ibuprofen 400 mg', 65),
    _QuotationMedicine('Ferrous Sulfate Syrup', 220, inStock: false),
    _QuotationMedicine('Baby Diapers Size M', 380),
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
    return medicineCatalog
        .where((item) => item.name.toLowerCase().contains(text))
        .toList();
  }

  List<_QuotationMedicine> filterAlternatives(String query) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return const [];
    final current = draft?.medicine.name.toLowerCase();
    return medicineCatalog.where((item) {
      final name = item.name.toLowerCase();
      return name.contains(text) && name != current;
    }).toList();
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
