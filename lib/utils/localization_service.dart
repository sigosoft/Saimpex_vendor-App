import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:get/get.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/utils/utils.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();

  factory LocalizationService() {
    return _instance;
  }

  LocalizationService._internal();

  final FlutterLocalization _localization = FlutterLocalization.instance;

  static String currentLanguageCode = 'en';

  static final ValueNotifier<Locale> localeNotifier =
      ValueNotifier<Locale>(const Locale('en'));

  /// Initializes the language state synchronously from the stored/passed language code.
  static void init(String langCode) {
    if (langCode == "French" || langCode == "fr") {
      currentLanguageCode = 'fr';
    } else if (langCode == "Arabic" || langCode == "ar") {
      currentLanguageCode = 'ar';
    } else {
      currentLanguageCode = 'en';
    }
    localeNotifier.value = Locale(currentLanguageCode);
  }

  /// Updates the application locale and persists the selection.
  /// Accepts either language name (English, French, Arabic) or language code (en, fr, ar).
  Future<void> updateLocale(String language) async {
    String langCode = 'en';
    if (language == "English" || language == "en") {
      langCode = 'en';
    } else if (language == "French" || language == "fr") {
      langCode = 'fr';
    } else if (language == "Arabic" || language == "ar") {
      langCode = 'ar';
    }

    currentLanguageCode = langCode;
    final locale = Locale(langCode);
    await savename("selected_locale", langCode);
    try {
      await S.load(locale);
    } catch (_) {}
    try {
      _localization.translate(langCode);
    } catch (_) {}
    try {
      Get.updateLocale(locale);
    } catch (_) {}
    localeNotifier.value = locale;
  }

  /// Returns the readable language name based on the current locale code.
  String getCurrentLanguageName() {
    switch (currentLanguageCode) {
      case 'fr':
        return 'French';
      case 'ar':
        return 'Arabic';
      default:
        return 'English';
    }
  }

  /// Returns the current locale's text direction (RTL for Arabic, LTR otherwise).
  TextDirection getTextDirection() {
    return currentLanguageCode == "ar"
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  /// Centralized translation dictionary for app & pharmacy screens
  static const Map<String, Map<String, String>> _dictionary = {
    // Navigation
    'Home': {'en': 'Home', 'fr': 'Accueil', 'ar': 'الرئيسية'},
    'Orders': {'en': 'Orders', 'fr': 'Commandes', 'ar': 'الطلبات'},
    'Chat': {'en': 'Chat', 'fr': 'Discussion', 'ar': 'المحادثة'},
    'Inventory': {'en': 'Inventory', 'fr': 'Inventaire', 'ar': 'المخزون'},
    'Account': {'en': 'Account', 'fr': 'Compte', 'ar': 'الحساب'},

    // Account & Settings
    'Delete Account': {
      'en': 'Delete Account',
      'fr': 'Supprimer le compte',
      'ar': 'حذف الحساب',
    },
    'Language': {'en': 'Language', 'fr': 'Langue', 'ar': 'اللغة'},
    'Business': {'en': 'Business', 'fr': 'Entreprise', 'ar': 'الأعمال'},
    'Notification': {
      'en': 'Notification',
      'fr': 'Notification',
      'ar': 'الإشعارات',
    },
    'Pharmacy Profile': {
      'en': 'Pharmacy Profile',
      'fr': 'Profil de la pharmacie',
      'ar': 'ملف الصيدلية',
    },
    'Working hours': {
      'en': 'Working hours',
      'fr': 'Heures de travail',
      'ar': 'ساعات العمل',
    },
    'Business settings': {
      'en': 'Business settings',
      'fr': 'Paramètres de l\'entreprise',
      'ar': 'إعدادات الأعمال',
    },
    'Leave Management': {
      'en': 'Leave Management',
      'fr': 'Gestion des congés',
      'ar': 'إدارة الإجازات',
    },
    'Earnings': {'en': 'Earnings', 'fr': 'Gains', 'ar': 'الأرباح'},
    'Received Payouts': {
      'en': 'Received Payouts',
      'fr': 'Paiements reçus',
      'ar': 'المدفوعات المستلمة',
    },
    'Coupons': {'en': 'Coupons', 'fr': 'Coupons', 'ar': 'القسائم'},
    'Delivery Boys': {
      'en': 'Delivery Boys',
      'fr': 'Livreurs',
      'ar': 'عمال التوصيل',
    },
    'Support & Legal': {
      'en': 'Support & Legal',
      'fr': 'Assistance et Mentions Légales',
      'ar': 'الدعم والقانوني',
    },
    'Help & Support': {
      'en': 'Help & Support',
      'fr': 'Aide et support',
      'ar': 'المساعدة والدعم',
    },
    'Terms & Conditions': {
      'en': 'Terms & Conditions',
      'fr': 'Termes et conditions',
      'ar': 'الشروط والأحكام',
    },
    'Privacy Policy': {
      'en': 'Privacy Policy',
      'fr': 'Politique de confidentialité',
      'ar': 'سياسة الخصوصية',
    },
    'Logout': {'en': 'Logout', 'fr': 'Déconnexion', 'ar': 'تسجيل الخروج'},
    'Are you sure you want to log out?': {
      'en': 'Are you sure you want to log out?',
      'fr': 'Voulez-vous vraiment vous déconnecter ?',
      'ar': 'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
    },
    'Are you sure you want to delete your\naccount?': {
      'en': 'Are you sure you want to delete your\naccount?',
      'fr': 'Voulez-vous vraiment supprimer\nvotre compte ?',
      'ar': 'هل أنت متأكد أنك تريد حذف\nحسابك؟',
    },
    'Check for update': {
      'en': 'Check for update',
      'fr': 'Vérifier les mises à jour',
      'ar': 'التحقق من التحديثات',
    },
    'No': {'en': 'No', 'fr': 'Non', 'ar': 'لا'},
    'Yes': {'en': 'Yes', 'fr': 'Oui', 'ar': 'نعم'},
    'Open': {'en': 'Open', 'fr': 'Ouvert', 'ar': 'مفتوح'},
    'Closed': {'en': 'Closed', 'fr': 'Fermé', 'ar': 'مغلق'},
    'Verified': {'en': 'Verified', 'fr': 'Vérifié', 'ar': 'موثق'},
    'Unverified': {'en': 'Unverified', 'fr': 'Non vérifié', 'ar': 'غير موثق'},

    // Home / Pharmacy Common
    'Store is Open': {
      'en': 'Store is Open',
      'fr': 'Le magasin est ouvert',
      'ar': 'المتجر مفتوح',
    },
    'Store is Closed': {
      'en': 'Store is Closed',
      'fr': 'Le magasin est fermé',
      'ar': 'المتجر مغلق',
    },
    'Accepting orders now': {
      'en': 'Accepting orders now',
      'fr': 'Accepte les commandes maintenant',
      'ar': 'قبول الطلبات الآن',
    },
    'Not accepting orders': {
      'en': 'Not accepting orders',
      'fr': 'N\'accepte pas les commandes',
      'ar': 'عدم قبول الطلبات',
    },
    'New Prescriptions': {
      'en': 'New Prescriptions',
      'fr': 'Nouvelles ordonnances',
      'ar': 'وصفات طبية جديدة',
    },
    'New OTC Orders': {
      'en': 'New OTC Orders',
      'fr': 'Nouvelles commandes OTC',
      'ar': 'طلبات بدون وصفة جديدة',
    },
    'Preparing': {'en': 'Preparing', 'fr': 'En préparation', 'ar': 'قيد التحضير'},
    'Ready to Deliver': {
      'en': 'Ready to Deliver',
      'fr': 'Prêt à livrer',
      'ar': 'جاهز للتسليم',
    },
    'Ready': {'en': 'Ready', 'fr': 'Prêt', 'ar': 'جاهز'},
    'Total Orders': {
      'en': 'Total Orders',
      'fr': 'Total des commandes',
      'ar': 'إجمالي الطلبات',
    },
    'Completed Orders': {
      'en': 'Completed Orders',
      'fr': 'Commandes terminées',
      'ar': 'الطلبات المكتملة',
    },
    'Total Revenue': {
      'en': 'Total Revenue',
      'fr': 'Revenu total',
      'ar': 'إجمالي الإيرادات',
    },
    'See All': {'en': 'See All', 'fr': 'Voir tout', 'ar': 'عرض الكل'},
    'View All': {'en': 'View All', 'fr': 'Voir tout', 'ar': 'عرض الكل'},
    'Prescription': {
      'en': 'Prescription',
      'fr': 'Ordonnance',
      'ar': 'الوصفة الطبية',
    },
    'OTC Orders': {
      'en': 'OTC Orders',
      'fr': 'Commandes OTC',
      'ar': 'طلبات بدون وصفة',
    },
    'New Orders': {
      'en': 'New Orders',
      'fr': 'Nouvelles commandes',
      'ar': 'طلبات جديدة',
    },
    'Under Review': {
      'en': 'Under Review',
      'fr': 'En cours d\'examen',
      'ar': 'قيد المراجعة',
    },
    'Review Completed': {
      'en': 'Review Completed',
      'fr': 'Examen terminé',
      'ar': 'اكتملت المراجعة',
    },
    'Awaiting Payment': {
      'en': 'Awaiting Payment',
      'fr': 'En attente de paiement',
      'ar': 'في انتظار الدفع',
    },
    'To Prepare': {'en': 'To Prepare', 'fr': 'À préparer', 'ar': 'للتحضير'},
    'Delivered': {'en': 'Delivered', 'fr': 'Livré', 'ar': 'تم التوصيل'},
    'Cancelled': {'en': 'Cancelled', 'fr': 'Annulé', 'ar': 'ملغى'},
    'Rejected': {'en': 'Rejected', 'fr': 'Rejeté', 'ar': 'مرفوض'},
    'Active': {'en': 'Active', 'fr': 'Actif', 'ar': 'نشط'},
    'Inactive': {'en': 'Inactive', 'fr': 'Inactif', 'ar': 'غير نشط'},
    'Delete': {'en': 'Delete', 'fr': 'Supprimer', 'ar': 'حذف'},
    'Edit': {'en': 'Edit', 'fr': 'Modifier', 'ar': 'تعديل'},
    'Save': {'en': 'Save', 'fr': 'Enregistrer', 'ar': 'حفظ'},
    'Update': {'en': 'Update', 'fr': 'Mettre à jour', 'ar': 'تحديث'},
    'Submit': {'en': 'Submit', 'fr': 'Soumettre', 'ar': 'إرسال'},
    'Cancel': {'en': 'Cancel', 'fr': 'Annuler', 'ar': 'إلغاء'},

    // Additional Pharmacy Dashboard & General
    'ORDERS': {'en': 'ORDERS', 'fr': 'COMMANDES', 'ar': 'الطلبات'},
    'COMPLETED': {'en': 'COMPLETED', 'fr': 'TERMINÉ', 'ar': 'المكتملة'},
    'REVENUE': {'en': 'REVENUE', 'fr': 'REVENU', 'ar': 'الإيرادات'},
    'OTC': {'en': 'OTC', 'fr': 'Sans ordonnance', 'ar': 'بدون وصفة'},
    'New prescriptions': {
      'en': 'New prescriptions',
      'fr': 'Nouvelles ordonnances',
      'ar': 'وصفات طبية جديدة',
    },
    'New OTC orders': {
      'en': 'New OTC orders',
      'fr': 'Nouvelles commandes OTC',
      'ar': 'طلبات بدون وصفة جديدة',
    },
    'Open • Accepting orders': {
      'en': 'Open • Accepting orders',
      'fr': 'Ouvert • Accepte les commandes',
      'ar': 'مفتوح • قبول الطلبات',
    },
    'Closed • Not accepting': {
      'en': 'Closed • Not accepting',
      'fr': 'Fermé • N\'accepte pas',
      'ar': 'مغلق • لا نقبل الطلبات',
    },
    'Today: 08:00 - 22:00': {
      'en': 'Today: 08:00 - 22:00',
      'fr': 'Aujourd\'hui : 08:00 - 22:00',
      'ar': 'اليوم: 08:00 - 22:00',
    },
    'Search': {'en': 'Search', 'fr': 'Rechercher', 'ar': 'بحث'},
    'Search orders, prescription ID...': {
      'en': 'Search orders, prescription ID...',
      'fr': 'Rechercher des commandes, ID ordonnance...',
      'ar': 'البحث عن الطلبات، رقم الوصفة...',
    },
    'Search medicines, barcode...': {
      'en': 'Search medicines, barcode...',
      'fr': 'Rechercher des médicaments, code-barres...',
      'ar': 'البحث عن الأدوية، الباركود...',
    },
    'Search products, brand, barcode...': {
      'en': 'Search products, brand, barcode...',
      'fr': 'Rechercher des produits, marque, code-barres...',
      'ar': 'البحث عن المنتجات، العلامة التجارية، الباركود...',
    },
    'No orders found': {
      'en': 'No orders found',
      'fr': 'Aucune commande trouvée',
      'ar': 'لم يتم العثور على طلبات',
    },
    'No prescriptions found': {
      'en': 'No prescriptions found',
      'fr': 'Aucune ordonnance trouvée',
      'ar': 'لم يتم العثور على وصفات طبية',
    },
    'No medicines found': {
      'en': 'No medicines found',
      'fr': 'Aucun médicament trouvé',
      'ar': 'لم يتم العثور على أدوية',
    },
    'TOTAL MEDICINES': {
      'en': 'TOTAL MEDICINES',
      'fr': 'TOTAL MÉDICAMENTS',
      'ar': 'إجمالي الأدوية',
    },
    'LOW STOCK': {
      'en': 'LOW STOCK',
      'fr': 'STOCK FAIBLE',
      'ar': 'مخزون منخفض',
    },
    'OUT OF STOCK': {
      'en': 'OUT OF STOCK',
      'fr': 'RUPTURE DE STOCK',
      'ar': 'نفذ من المخزون',
    },
    'EXPIRING SOON': {
      'en': 'EXPIRING SOON',
      'fr': 'EXPIRE BIENTÔT',
      'ar': 'قريب الانتهاء',
    },
    'Low Stock Alert': {
      'en': 'Low Stock Alert',
      'fr': 'Alerte stock faible',
      'ar': 'تنبيه مخزون منخفض',
    },
    'All': {'en': 'All', 'fr': 'Tout', 'ar': 'الكل'},
    'In Stock': {'en': 'In Stock', 'fr': 'En stock', 'ar': 'متوفر'},
    'Low Stock': {'en': 'Low Stock', 'fr': 'Stock faible', 'ar': 'مخزون منخفض'},
    'Out of Stock': {
      'en': 'Out of Stock',
      'fr': 'Rupture de stock',
      'ar': 'نفذ من المخزون',
    },
    'Categories': {'en': 'Categories', 'fr': 'Catégories', 'ar': 'الفئات'},
    'Add Product': {
      'en': 'Add Product',
      'fr': 'Ajouter un produit',
      'ar': 'إضافة منتج',
    },
    'Update Delivery Boy': {
      'en': 'Update Delivery Boy',
      'fr': 'Mettre à jour le livreur',
      'ar': 'تحديث عامل التوصيل',
    },
    'Add Delivery Boy': {
      'en': 'Add Delivery Boy',
      'fr': 'Ajouter un livreur',
      'ar': 'إضافة عامل توصيل',
    },
    'Update Coupon': {
      'en': 'Update Coupon',
      'fr': 'Mettre à jour le coupon',
      'ar': 'تحديث القسيمة',
    },
    'Add Coupon': {
      'en': 'Add Coupon',
      'fr': 'Ajouter un coupon',
      'ar': 'إضافة قسيمة',
    },
    'Are you sure you want to delete this coupon?': {
      'en': 'Are you sure you want to delete this coupon?',
      'fr': 'Voulez-vous vraiment supprimer ce coupon ?',
      'ar': 'هل أنت متأكد من حذف هذه القسيمة؟',
    },
    'Are you sure you want to delete this delivery boy?': {
      'en': 'Are you sure you want to delete this delivery boy?',
      'fr': 'Voulez-vous vraiment supprimer ce livreur ?',
      'ar': 'هل أنت متأكد من حذف عامل التوصيل هذا؟',
    },
    'Are you sure you want to change coupon status?': {
      'en': 'Are you sure you want to change coupon status?',
      'fr': 'Voulez-vous vraiment modifier le statut du coupon ?',
      'ar': 'هل أنت متأكد من تغيير حالة القسيمة؟',
    },
    'Confirmation': {
      'en': 'Confirmation',
      'fr': 'Confirmation',
      'ar': 'تأكيد',
    },
    'Phone Number': {
      'en': 'Phone Number',
      'fr': 'Numéro de téléphone',
      'ar': 'رقم الهاتف',
    },
    'Email': {'en': 'Email', 'fr': 'E-mail', 'ar': 'البريد الإلكتروني'},
    'Password': {'en': 'Password', 'fr': 'Mot de passe', 'ar': 'كلمة المرور'},
    'Status': {'en': 'Status', 'fr': 'Statut', 'ar': 'الحالة'},
    'Title': {'en': 'Title', 'fr': 'Titre', 'ar': 'العنوان'},
    'Code': {'en': 'Code', 'fr': 'Code', 'ar': 'الرمز'},
    'Discount': {'en': 'Discount', 'fr': 'Remise', 'ar': 'الخصم'},
    'Expire Date': {
      'en': 'Expire Date',
      'fr': 'Date d\'expiration',
      'ar': 'تاريخ الانتهاء',
    },
  };

  /// Translates a key according to the active language code
  static String tr(String key) {
    return _dictionary[key]?[currentLanguageCode] ??
        _dictionary[key]?['en'] ??
        key;
  }
}
