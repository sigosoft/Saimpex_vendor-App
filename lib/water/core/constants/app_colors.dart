import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // —— Brand ——
  static const Color primaryOrange = Color(0xFFFF5E21);
  static const Color orangeSoft = Color(0xFFFF8A50);
  static const Color orangeAccent = Color(0xFFFF5722);
  static const Color languageChip = Color(0xFFFFEDE6);
  static const Color orangeSoftBg = Color(0xFFFFF0E6);
  static const Color orangeChipBg = Color(0xFFFFF8F3);
  static const Color orangeChipBorder = Color(0xFFFFE0D0);
  static const Color orangeGlow = Color(0xFFFFE8DF);

  // —— Backgrounds ——
  static const Color backgroundTop = Color(0xFFFFF0E8);
  static const Color backgroundMid = Color(0xFFFFF8F4);
  static const Color backgroundBottom = Color(0xFFF7F7F7);
  static const Color scaffoldBg = Color(0xFFF5F5F5);

  // —— Text ——
  static const Color textDark = Color(0xFF1E212C);
  static const Color textTitle = Color(0xFF2A2A2A);
  static const Color textBody = Color(0xFF333333);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color textSecondary = Color(0xFF8E8E8E);
  static const Color textHint = Color(0xFFB0B0B0);
  static const Color textMeta = Color(0xFF5A5A5A);
  static const Color textLabel = Color(0xFF555555);
  static const Color label = Color(0xFF555555);
  static const Color sectionTitle = Color(0xFF8C91A0);
  static const Color detailGray = Color(0xFF6B7280);
  static const Color labelGray = Color(0xFF9AA0A6);
  static const Color homeLabel = Color(0xFF7A6E67);
  static const Color homeValue = Color(0xFF1A1A1A);

  // —— Surfaces ——
  static const Color fieldBorder = Color(0xFFE0E0E0);
  static const Color fieldFill = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFF0F0F0);
  static const Color divider = Color(0xFFF0F0F0);
  static const Color softGray = Color(0xFFF2F2F2);
  static const Color softGrayAlt = Color(0xFFE8E8E8);
  static const Color softGrayFill = Color(0xFFF8F8F8);
  static const Color error = Color(0xFFE53935);
  static const Color rejectTitleRed = Color(0xFFE84B5E);
  static const Color borderMuted = Color(0xFFD0D0D0);
  static const Color inputFill = Color(0xFFF3F3F3);
  static const Color unselectedGray = Color(0xFFBDBDBD);

  // —— Status: success / active ——
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color successSoft = Color(0xFFE8F5E9);
  static const Color activeGreen = Color(0xFF2EAD5B);
  static const Color deliveredGreen = Color(0xFF0A6B3D);
  static const Color deliveredBg = Color(0xFFE8F5EE);
  static const Color storeIconBg = Color(0xFFC8E6C9);
  static const Color deliveriesGreen = Color(0xFF66BB6A);
  static const Color readyGreen = Color(0xFF43A047);
  static const Color iconGreen = Color(0xFF006D3C);
  static const Color iconGreenBg = Color(0xFFE4F9E8);

  // —— Status: pause / warning ——
  static const Color pausedAmber = Color(0xFFF2A000);
  static const Color pausedAmberAlt = Color(0xFFF5A623);
  static const Color pausedCardBg = Color(0xFFFFF6E8);
  static const Color pausedCardBorder = Color(0xFFFFE4B8);
  static const Color preparingOrange = Color(0xFFFF8A00);
  static const Color newBadge = Color(0xFFF2A000);

  // —— Status: info / progress ——
  static const Color progressBlue = Color(0xFF005B99);
  static const Color progressBg = Color(0xFFEBF2F9);
  static const Color selfPickupBlue = Color(0xFF2F80ED);
  static const Color scheduledBg = Color(0xFFE8F1FF);
  static const Color scheduledText = Color(0xFF1565C0);
  static const Color scheduledBlue = Color(0xFF2F80ED);

  // —— Purple / plan ——
  static const Color planPurple = Color(0xFF6C63FF);
  static const Color planPurpleBg = Color(0xFFF3EFFF);
  static const Color planPurpleSoft = Color(0xFF8B83C7);
  static const Color planPurpleAlt = Color(0xFFEEEAFF);
  static const Color calendarPurple = Color(0xFF7E57C2);
  static const Color partnerPurple = Color(0xFF7B5CFF);
  static const Color partnerBg = Color(0xFFF3E8FF);

  // —— Avatar ——
  static const Color avatarPink = Color(0xFFFFE4E8);
  static const Color avatarPinkAlt = Color(0xFFFFE9E9);
  static const Color avatarText = Color(0xFFC62828);
  static const Color avatarTextAlt = Color(0xFFE53935);

  // —— Payment ——
  static const Color paymentCard = Color(0xFF2A2A2A);
  static const Color paymentDivider = Color(0xFF444444);

  // —— Chat ——
  static const Color chatBg = Color(0xFFFCF8F1);
  static const Color chatInputBg = Color(0xFFF5EFE6);
  static const Color chatDatePill = Color(0xFFF0EAE0);
  static const Color chatBubbleIncoming = Color(0xFFFFFFFF);
  static const Color chatBubbleOutgoing = Color(0xFF1A1A1A);
  static const Color chatTimeText = Color(0xFF8E8E93);
  static const Color chatPlayCircle = Color(0xFF2A2A2A);
  static const Color messagesNavBg = Color(0xFFF9F9F7);

  // —— Notifications ——
  static const Color notifOrderAccent = Color(0xFFFF5E21);
  static const Color notifOrderIconBg = Color(0xFFFFE8DF);
  static const Color notifSubscriptionAccent = Color(0xFF2F80ED);
  static const Color notifSubscriptionIconBg = Color(0xFFE8F1FF);
  static const Color notifStockAccent = Color(0xFFF2A000);
  static const Color notifStockIconBg = Color(0xFFFFF0D9);
  static const Color notifBodyText = Color(0xFF6B7280);
  static const Color notifTimeText = Color(0xFF9CA3AF);

  // —— Inventory ——
  static const Color inventoryAvailable = Color(0xFF2EAD5B);
  static const Color inventoryAvailableBg = Color(0xFFE8F7EE);
  static const Color inventoryOrders = Color(0xFF2F80ED);
  static const Color inventoryOrdersBg = Color(0xFFE8F1FF);
  static const Color inventoryLowStock = Color(0xFFF2A000);
  static const Color inventoryLowStockBg = Color(0xFFFFF4D9);
  static const Color inventoryOutOfStock = Color(0xFFE53935);
  static const Color inventoryOutOfStockBg = Color(0xFFFFEBEE);
  static const Color inventoryImageBg = Color(0xFFEAF4FF);
  static const Color inventoryCategoryBg = Color(0xFFFFF0E8);
  static const Color inventoryStrike = Color(0xFF9E9E9E);
  static const Color inventoryHeroBg = Color(0xFFF0EFFF);
  static const Color inventorySoftCard = Color(0xFFF7F7F7);
  static const Color inventorySalesBg = Color(0xFFFFF5F0);
  static const Color inventoryRevenueGreen = Color(0xFF2EAD5B);
  static const Color inventoryBottleGreen = Color(0xFF2EAD5B);
  static const Color inventoryResetBtn = Color(0xFFE8EEF5);

  // —— Misc ——
  static const Color navInactive = Color(0xFF9E9E9E);
  static const Color cancelledGray = Color(0xFF9E9E9E);
  static const Color homeDivider = Color(0xFFE8D5C8);
}
