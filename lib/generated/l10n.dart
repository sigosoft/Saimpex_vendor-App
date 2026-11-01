// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `About Us`
  String get aboutUs {
    return Intl.message('About Us', name: 'aboutUs', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Add delivery notes (optional)`
  String get addDeliveryNotesOptional {
    return Intl.message(
      'Add delivery notes (optional)',
      name: 'addDeliveryNotesOptional',
      desc: '',
      args: [],
    );
  }

  /// `Add Item`
  String get addItem {
    return Intl.message('Add Item', name: 'addItem', desc: '', args: []);
  }

  /// `Add More Items`
  String get addMoreItems {
    return Intl.message(
      'Add More Items',
      name: 'addMoreItems',
      desc: '',
      args: [],
    );
  }

  /// `Address not available`
  String get addressNotAvailable {
    return Intl.message(
      'Address not available',
      name: 'addressNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `All Items from This Restaurant`
  String get allItemsFromThisRestaurant {
    return Intl.message(
      'All Items from This Restaurant',
      name: 'allItemsFromThisRestaurant',
      desc: '',
      args: [],
    );
  }

  /// `All Items from this Store`
  String get allItemsFromThisStore {
    return Intl.message(
      'All Items from this Store',
      name: 'allItemsFromThisStore',
      desc: '',
      args: [],
    );
  }

  /// `All Restaurants`
  String get allRestaurants {
    return Intl.message(
      'All Restaurants',
      name: 'allRestaurants',
      desc: '',
      args: [],
    );
  }

  /// `All Revenue`
  String get allRevenue {
    return Intl.message('All Revenue', name: 'allRevenue', desc: '', args: []);
  }

  /// `All Stores`
  String get allStores {
    return Intl.message('All Stores', name: 'allStores', desc: '', args: []);
  }

  /// `Already one coupon is applied on this order, if you want to aaply this please remove already applied coupon`
  String get alreadyOneCouponIsAppliedOnThisOrderIfYou {
    return Intl.message(
      'Already one coupon is applied on this order, if you want to aaply this please remove already applied coupon',
      name: 'alreadyOneCouponIsAppliedOnThisOrderIfYou',
      desc: '',
      args: [],
    );
  }

  /// `A new update is available for this app. Please download the latest version to continue using the app.`
  String get aNewUpdateIsAvailableForThisAppPleaseDownload {
    return Intl.message(
      'A new update is available for this app. Please download the latest version to continue using the app.',
      name: 'aNewUpdateIsAvailableForThisAppPleaseDownload',
      desc: '',
      args: [],
    );
  }

  /// `Applied`
  String get applied {
    return Intl.message('Applied', name: 'applied', desc: '', args: []);
  }

  /// `Apply`
  String get apply {
    return Intl.message('Apply', name: 'apply', desc: '', args: []);
  }

  /// `Apply Coupon`
  String get applyCoupon {
    return Intl.message(
      'Apply Coupon',
      name: 'applyCoupon',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel this order?`
  String get areYouSureYouWantToCancelThisOrder {
    return Intl.message(
      'Are you sure you want to cancel this order?',
      name: 'areYouSureYouWantToCancelThisOrder',
      desc: '',
      args: [],
    );
  }

  /// `Are You Sure You Want to Clear This Chat?`
  String get areYouSureYouWantToClearThisChat {
    return Intl.message(
      'Are You Sure You Want to Clear This Chat?',
      name: 'areYouSureYouWantToClearThisChat',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete item from your cart?`
  String get areYouSureYouWantToDeleteItemFromYour {
    return Intl.message(
      'Are you sure you want to delete item from your cart?',
      name: 'areYouSureYouWantToDeleteItemFromYour',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your account?`
  String get areYouSureYouWantToDeleteYourAccount {
    return Intl.message(
      'Are you sure you want to delete your account?',
      name: 'areYouSureYouWantToDeleteYourAccount',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout?`
  String get areYouSureYouWantToLogout {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'areYouSureYouWantToLogout',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to place this order?`
  String get areYouSureYouWantToPlaceThisOrder {
    return Intl.message(
      'Are you sure you want to place this order?',
      name: 'areYouSureYouWantToPlaceThisOrder',
      desc: '',
      args: [],
    );
  }

  /// `Available at`
  String get availableAt {
    return Intl.message(
      'Available at',
      name: 'availableAt',
      desc: '',
      args: [],
    );
  }

  /// `Available Points`
  String get availablePoints {
    return Intl.message(
      'Available Points',
      name: 'availablePoints',
      desc: '',
      args: [],
    );
  }

  /// `Basket Items`
  String get basketItems {
    return Intl.message(
      'Basket Items',
      name: 'basketItems',
      desc: '',
      args: [],
    );
  }

  /// `Basket Order Details`
  String get basketOrderDetails {
    return Intl.message(
      'Basket Order Details',
      name: 'basketOrderDetails',
      desc: '',
      args: [],
    );
  }

  /// `Basket Orders`
  String get basketOrders {
    return Intl.message(
      'Basket Orders',
      name: 'basketOrders',
      desc: '',
      args: [],
    );
  }

  /// `Basket Orders`
  String get basketOrderss {
    return Intl.message(
      'Basket Orders',
      name: 'basketOrderss',
      desc: '',
      args: [],
    );
  }

  /// `Beverages`
  String get beverages {
    return Intl.message('Beverages', name: 'beverages', desc: '', args: []);
  }

  /// `Buy Now`
  String get buyNow {
    return Intl.message('Buy Now', name: 'buyNow', desc: '', args: []);
  }

  /// `Call us`
  String get callUs {
    return Intl.message('Call us', name: 'callUs', desc: '', args: []);
  }

  /// `Camera`
  String get camera {
    return Intl.message('Camera', name: 'camera', desc: '', args: []);
  }

  /// `Camera permission is required to scan barcodes`
  String get cameraPermissionIsRequiredToScanBarcodes {
    return Intl.message(
      'Camera permission is required to scan barcodes',
      name: 'cameraPermissionIsRequiredToScanBarcodes',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Cancel Order`
  String get cancelOrder {
    return Intl.message(
      'Cancel Order',
      name: 'cancelOrder',
      desc: '',
      args: [],
    );
  }

  /// `Cart`
  String get cart {
    return Intl.message('Cart', name: 'cart', desc: '', args: []);
  }

  /// `Cash on Delivery`
  String get cashOnDelivery {
    return Intl.message(
      'Cash on Delivery',
      name: 'cashOnDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat {
    return Intl.message('Chat', name: 'chat', desc: '', args: []);
  }

  /// `Chat now`
  String get chatNow {
    return Intl.message('Chat now', name: 'chatNow', desc: '', args: []);
  }

  /// `Checkout`
  String get checkout {
    return Intl.message('Checkout', name: 'checkout', desc: '', args: []);
  }

  /// `Choose Image From :`
  String get chooseImageFrom {
    return Intl.message(
      'Choose Image From :',
      name: 'chooseImageFrom',
      desc: '',
      args: [],
    );
  }

  /// `Clear All`
  String get clearAll {
    return Intl.message('Clear All', name: 'clearAll', desc: '', args: []);
  }

  /// `Confirm & Proceed`
  String get confirmProceed {
    return Intl.message(
      'Confirm & Proceed',
      name: 'confirmProceed',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations! You’ve earned`
  String get congratulationsYouveEarned {
    return Intl.message(
      'Congratulations! You’ve earned',
      name: 'congratulationsYouveEarned',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continuee {
    return Intl.message('Continue', name: 'continuee', desc: '', args: []);
  }

  /// `Continue`
  String get continueText {
    return Intl.message('Continue', name: 'continueText', desc: '', args: []);
  }

  /// `Coupon code copied!`
  String get couponCodeCopied {
    return Intl.message(
      'Coupon code copied!',
      name: 'couponCodeCopied',
      desc: '',
      args: [],
    );
  }

  /// `Cravings calling? Answer with a bite!`
  String get cravingsCallingAnswerWithABite {
    return Intl.message(
      'Cravings calling? Answer with a bite!',
      name: 'cravingsCallingAnswerWithABite',
      desc: '',
      args: [],
    );
  }

  /// `Credit`
  String get credit {
    return Intl.message('Credit', name: 'credit', desc: '', args: []);
  }

  /// `Crop`
  String get crop {
    return Intl.message('Crop', name: 'crop', desc: '', args: []);
  }

  /// `Crop Image`
  String get cropImage {
    return Intl.message('Crop Image', name: 'cropImage', desc: '', args: []);
  }

  /// `Current Location`
  String get currentLocation {
    return Intl.message(
      'Current Location',
      name: 'currentLocation',
      desc: '',
      args: [],
    );
  }

  /// `Currently Closed`
  String get currentlyClosed {
    return Intl.message(
      'Currently Closed',
      name: 'currentlyClosed',
      desc: '',
      args: [],
    );
  }

  /// `Currently closed • Opens`
  String get currentlyClosedOpens {
    return Intl.message(
      'Currently closed • Opens',
      name: 'currentlyClosedOpens',
      desc: '',
      args: [],
    );
  }

  /// `Currently no items Found, Please try later...`
  String get currentlyNoItemsFoundPleaseTryLater {
    return Intl.message(
      'Currently no items Found, Please try later...',
      name: 'currentlyNoItemsFoundPleaseTryLater',
      desc: '',
      args: [],
    );
  }

  /// `Currently no contacts found, Please try later...`
  String get currentlyNoContactsFoundPleaseTryLater {
    return Intl.message(
      'Currently no contacts found, Please try later...',
      name: 'currentlyNoContactsFoundPleaseTryLater',
      desc: '',
      args: [],
    );
  }

  /// `Upload Image`
  String get uploadImage {
    return Intl.message(
      'Upload Image',
      name: 'uploadImage',
      desc: '',
      args: [],
    );
  }

  /// `Currently no restaurants are available in this area. Try again later.`
  String get currentlyNoRestaurantsAreAvailableInThisAreaTryAgain {
    return Intl.message(
      'Currently no restaurants are available in this area. Try again later.',
      name: 'currentlyNoRestaurantsAreAvailableInThisAreaTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Currently no restaurants found`
  String get currentlyNoRestaurantsFound {
    return Intl.message(
      'Currently no restaurants found',
      name: 'currentlyNoRestaurantsFound',
      desc: '',
      args: [],
    );
  }

  /// `Currently no stores found`
  String get currentlyNoStoresFound {
    return Intl.message(
      'Currently no stores found',
      name: 'currentlyNoStoresFound',
      desc: '',
      args: [],
    );
  }

  /// `d ago`
  String get dAgo {
    return Intl.message('d ago', name: 'dAgo', desc: '', args: []);
  }

  /// `Debit`
  String get debit {
    return Intl.message('Debit', name: 'debit', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Delete Account`
  String get deleteAccount {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Delete Cart`
  String get deleteCart {
    return Intl.message('Delete Cart', name: 'deleteCart', desc: '', args: []);
  }

  /// `Delete Chat`
  String get deleteChat {
    return Intl.message('Delete Chat', name: 'deleteChat', desc: '', args: []);
  }

  /// `Delivery Fee`
  String get deliveryFee {
    return Intl.message(
      'Delivery Fee',
      name: 'deliveryFee',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Location`
  String get deliveryLocation {
    return Intl.message(
      'Delivery Location',
      name: 'deliveryLocation',
      desc: '',
      args: [],
    );
  }

  /// `Didn’t get the OTP?`
  String get didntGetTheOtp {
    return Intl.message(
      'Didn’t get the OTP?',
      name: 'didntGetTheOtp',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `. Do you want to replace them with items from`
  String get doYouWantToReplaceThemWithDishesFrom {
    return Intl.message(
      '. Do you want to replace them with items from',
      name: 'doYouWantToReplaceThemWithDishesFrom',
      desc: '',
      args: [],
    );
  }

  /// `Driver`
  String get driver {
    return Intl.message('Driver', name: 'driver', desc: '', args: []);
  }

  /// `Driver Details`
  String get driverDetails {
    return Intl.message(
      'Driver Details',
      name: 'driverDetails',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Expires in {days} days`
  String expiresInDays(String days) {
    return Intl.message(
      'Expires in $days days',
      name: 'expiresInDays',
      desc: '',
      args: [days],
    );
  }

  /// `Email us`
  String get emailUs {
    return Intl.message('Email us', name: 'emailUs', desc: '', args: []);
  }

  /// `Enter your name`
  String get enterYourName {
    return Intl.message(
      'Enter your name',
      name: 'enterYourName',
      desc: '',
      args: [],
    );
  }

  /// `Enter your quantity here`
  String get enterYourQuantityHere {
    return Intl.message(
      'Enter your quantity here',
      name: 'enterYourQuantityHere',
      desc: '',
      args: [],
    );
  }

  /// `Enter your whatsapp number`
  String get enterYourWhatsappNumber {
    return Intl.message(
      'Enter your whatsapp number',
      name: 'enterYourWhatsappNumber',
      desc: '',
      args: [],
    );
  }

  /// `Filters`
  String get filters {
    return Intl.message('Filters', name: 'filters', desc: '', args: []);
  }

  /// `Filters & Sorting`
  String get filtersSorting {
    return Intl.message(
      'Filters & Sorting',
      name: 'filtersSorting',
      desc: '',
      args: [],
    );
  }

  /// `Find something from this restaurant`
  String get findSomethingFromThisRestaurant {
    return Intl.message(
      'Find something from this restaurant',
      name: 'findSomethingFromThisRestaurant',
      desc: '',
      args: [],
    );
  }

  /// `Food`
  String get food {
    return Intl.message('Food', name: 'food', desc: '', args: []);
  }

  /// `Gallery`
  String get gallery {
    return Intl.message('Gallery', name: 'gallery', desc: '', args: []);
  }

  /// `Got It`
  String get gotIt {
    return Intl.message('Got It', name: 'gotIt', desc: '', args: []);
  }

  /// `Grocery`
  String get grocery {
    return Intl.message('Grocery', name: 'grocery', desc: '', args: []);
  }

  /// `h ago`
  String get hAgo {
    return Intl.message('h ago', name: 'hAgo', desc: '', args: []);
  }

  /// `Help & Support`
  String get helpSupport {
    return Intl.message(
      'Help & Support',
      name: 'helpSupport',
      desc: '',
      args: [],
    );
  }

  /// `Invalid product ID`
  String get invalidProductId {
    return Intl.message(
      'Invalid product ID',
      name: 'invalidProductId',
      desc: '',
      args: [],
    );
  }

  /// `Invalid product information`
  String get invalidProductInformation {
    return Intl.message(
      'Invalid product information',
      name: 'invalidProductInformation',
      desc: '',
      args: [],
    );
  }

  /// `Item`
  String get item {
    return Intl.message('Item', name: 'item', desc: '', args: []);
  }

  /// `Items`
  String get items {
    return Intl.message('Items', name: 'items', desc: '', args: []);
  }

  /// `Item Total`
  String get itemTotal {
    return Intl.message('Item Total', name: 'itemTotal', desc: '', args: []);
  }

  /// `Km`
  String get km {
    return Intl.message('Km', name: 'km', desc: '', args: []);
  }

  /// `Loading location...`
  String get loadingLocation {
    return Intl.message(
      'Loading location...',
      name: 'loadingLocation',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Login or Sign up`
  String get loginOrSignUp {
    return Intl.message(
      'Login or Sign up',
      name: 'loginOrSignUp',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `m ago`
  String get mAgo {
    return Intl.message('m ago', name: 'mAgo', desc: '', args: []);
  }

  /// `Mins`
  String get mins {
    return Intl.message('Mins', name: 'mins', desc: '', args: []);
  }

  /// `Missed Something?`
  String get missedSomething {
    return Intl.message(
      'Missed Something?',
      name: 'missedSomething',
      desc: '',
      args: [],
    );
  }

  /// `More Points`
  String get morePoints {
    return Intl.message('More Points', name: 'morePoints', desc: '', args: []);
  }

  /// `MRU on this order`
  String get mruOnThisOrder {
    return Intl.message(
      'MRU on this order',
      name: 'mruOnThisOrder',
      desc: '',
      args: [],
    );
  }

  /// `MRU with this code`
  String get mruWithThisCode {
    return Intl.message(
      'MRU with this code',
      name: 'mruWithThisCode',
      desc: '',
      args: [],
    );
  }

  /// `My Orders`
  String get myOrders {
    return Intl.message('My Orders', name: 'myOrders', desc: '', args: []);
  }

  /// `My Points`
  String get myPoints {
    return Intl.message('My Points', name: 'myPoints', desc: '', args: []);
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Need`
  String get need {
    return Intl.message('Need', name: 'need', desc: '', args: []);
  }

  /// `Need it fresh? Add it to your cart!`
  String get needItFreshAddItToYourCart {
    return Intl.message(
      'Need it fresh? Add it to your cart!',
      name: 'needItFreshAddItToYourCart',
      desc: '',
      args: [],
    );
  }

  /// `Needs An Update`
  String get needsAnUpdate {
    return Intl.message(
      'Needs An Update',
      name: 'needsAnUpdate',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `No Categories Found`
  String get noCategoriesFound {
    return Intl.message(
      'No Categories Found',
      name: 'noCategoriesFound',
      desc: '',
      args: [],
    );
  }

  /// `No Conversations`
  String get noConversations {
    return Intl.message(
      'No Conversations',
      name: 'noConversations',
      desc: '',
      args: [],
    );
  }

  /// `No conversations found`
  String get noConversationsFound {
    return Intl.message(
      'No conversations found',
      name: 'noConversationsFound',
      desc: '',
      args: [],
    );
  }

  /// `No Coupons Available`
  String get noCouponsAvailable {
    return Intl.message(
      'No Coupons Available',
      name: 'noCouponsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No coupons available right now.`
  String get noCouponsAvailableRightNow {
    return Intl.message(
      'No coupons available right now.',
      name: 'noCouponsAvailableRightNow',
      desc: '',
      args: [],
    );
  }

  /// `No Groceries Found`
  String get noGroceriesFound {
    return Intl.message(
      'No Groceries Found',
      name: 'noGroceriesFound',
      desc: '',
      args: [],
    );
  }

  /// `No grocery orders yet`
  String get noGroceryOrdersYet {
    return Intl.message(
      'No grocery orders yet',
      name: 'noGroceryOrdersYet',
      desc: '',
      args: [],
    );
  }

  /// `No Internet Connection`
  String get noInternetConnection {
    return Intl.message(
      'No Internet Connection',
      name: 'noInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `Please check your internet connection and try again.`
  String get noInternetConnectionDescription {
    return Intl.message(
      'Please check your internet connection and try again.',
      name: 'noInternetConnectionDescription',
      desc: '',
      args: [],
    );
  }

  /// `No Items Found`
  String get noItemsFound {
    return Intl.message(
      'No Items Found',
      name: 'noItemsFound',
      desc: '',
      args: [],
    );
  }

  /// `No messages`
  String get noMessages {
    return Intl.message('No messages', name: 'noMessages', desc: '', args: []);
  }

  /// `No messages yet`
  String get noMessagesYet {
    return Intl.message(
      'No messages yet',
      name: 'noMessagesYet',
      desc: '',
      args: [],
    );
  }

  /// `No notifications`
  String get noNotifications {
    return Intl.message(
      'No notifications',
      name: 'noNotifications',
      desc: '',
      args: [],
    );
  }

  /// `No notifications found`
  String get noNotificationsFound {
    return Intl.message(
      'No notifications found',
      name: 'noNotificationsFound',
      desc: '',
      args: [],
    );
  }

  /// `No options available`
  String get noOptionsAvailable {
    return Intl.message(
      'No options available',
      name: 'noOptionsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No order details found`
  String get noOrderDetailsFound {
    return Intl.message(
      'No order details found',
      name: 'noOrderDetailsFound',
      desc: '',
      args: [],
    );
  }

  /// `No Orders`
  String get noOrders {
    return Intl.message('No Orders', name: 'noOrders', desc: '', args: []);
  }

  /// `No redeemable rewards`
  String get noRedeemableRewards {
    return Intl.message(
      'No redeemable rewards',
      name: 'noRedeemableRewards',
      desc: '',
      args: [],
    );
  }

  /// `No Restaurants Found`
  String get noRestaurantsFound {
    return Intl.message(
      'No Restaurants Found',
      name: 'noRestaurantsFound',
      desc: '',
      args: [],
    );
  }

  /// `No Restaurants Founds`
  String get noRestaurantsFounds {
    return Intl.message(
      'No Restaurants Founds',
      name: 'noRestaurantsFounds',
      desc: '',
      args: [],
    );
  }

  /// `No Stores Found`
  String get noStoresFound {
    return Intl.message(
      'No Stores Found',
      name: 'noStoresFound',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Popular Items`
  String get popularItems {
    return Intl.message(
      'Popular Items',
      name: 'popularItems',
      desc: '',
      args: [],
    );
  }

  /// `Revenue Report`
  String get revenueReport {
    return Intl.message(
      'Revenue Report',
      name: 'revenueReport',
      desc: '',
      args: [],
    );
  }

  /// `No tracking details found`
  String get noTrackingDetailsFound {
    return Intl.message(
      'No tracking details found',
      name: 'noTrackingDetailsFound',
      desc: '',
      args: [],
    );
  }

  /// `No transaction history available`
  String get noTransactionHistoryAvailable {
    return Intl.message(
      'No transaction history available',
      name: 'noTransactionHistoryAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Now`
  String get now {
    return Intl.message('Now', name: 'now', desc: '', args: []);
  }

  /// `OFF`
  String get off {
    return Intl.message('OFF', name: 'off', desc: '', args: []);
  }

  /// `Online Payment`
  String get onlinePayment {
    return Intl.message(
      'Online Payment',
      name: 'onlinePayment',
      desc: '',
      args: [],
    );
  }

  /// `SAIMPEX Wallet`
  String get walletPayment {
    return Intl.message(
      'SAIMPEX Wallet',
      name: 'walletPayment',
      desc: '',
      args: [],
    );
  }

  /// `Pay After Delivery`
  String get payAfterDelivery {
    return Intl.message(
      'Pay After Delivery',
      name: 'payAfterDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Balance adjustments`
  String get balanceAdjustments {
    return Intl.message(
      'Balance adjustments',
      name: 'balanceAdjustments',
      desc: '',
      args: [],
    );
  }

  /// `No balance adjustments yet`
  String get noBalanceAdjustmentsYet {
    return Intl.message(
      'No balance adjustments yet',
      name: 'noBalanceAdjustmentsYet',
      desc: '',
      args: [],
    );
  }

  /// `Admin adjustment`
  String get adminAdjustment {
    return Intl.message(
      'Admin adjustment',
      name: 'adminAdjustment',
      desc: '',
      args: [],
    );
  }

  /// `Balance after`
  String get balanceAfter {
    return Intl.message(
      'Balance after',
      name: 'balanceAfter',
      desc: '',
      args: [],
    );
  }

  /// `Order Details`
  String get orderDetails {
    return Intl.message(
      'Order Details',
      name: 'orderDetails',
      desc: '',
      args: [],
    );
  }

  /// `Ordered`
  String get ordered {
    return Intl.message('Ordered', name: 'ordered', desc: '', args: []);
  }

  /// `Ordered Items`
  String get orderedItems {
    return Intl.message(
      'Ordered Items',
      name: 'orderedItems',
      desc: '',
      args: [],
    );
  }

  /// `Order placed successfully!`
  String get orderPlacedSuccessfully {
    return Intl.message(
      'Order placed successfully!',
      name: 'orderPlacedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `OTP Verification`
  String get otpVerification {
    return Intl.message(
      'OTP Verification',
      name: 'otpVerification',
      desc: '',
      args: [],
    );
  }

  /// `Out of Stock`
  String get outOfStock {
    return Intl.message('Out of Stock', name: 'outOfStock', desc: '', args: []);
  }

  /// `Pay`
  String get pay {
    return Intl.message('Pay', name: 'pay', desc: '', args: []);
  }

  /// `PAYMENT DETAILS`
  String get paymentDetails {
    return Intl.message(
      'PAYMENT DETAILS',
      name: 'paymentDetails',
      desc: '',
      args: [],
    );
  }

  /// `Payment Type`
  String get paymentType {
    return Intl.message(
      'Payment Type',
      name: 'paymentType',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Pick what you want and fill your basket!`
  String get pickWhatYouWantAndFillYourBasket {
    return Intl.message(
      'Pick what you want and fill your basket!',
      name: 'pickWhatYouWantAndFillYourBasket',
      desc: '',
      args: [],
    );
  }

  /// `Pick your favourites and start your feast!`
  String get pickYourFavouritesAndStartYourFeast {
    return Intl.message(
      'Pick your favourites and start your feast!',
      name: 'pickYourFavouritesAndStartYourFeast',
      desc: '',
      args: [],
    );
  }

  /// `Place Order`
  String get placeOrder {
    return Intl.message('Place Order', name: 'placeOrder', desc: '', args: []);
  }

  /// `Please add your items to cart`
  String get pleaseAddYourItemsToCart {
    return Intl.message(
      'Please add your items to cart',
      name: 'pleaseAddYourItemsToCart',
      desc: '',
      args: [],
    );
  }

  /// `Please choose location`
  String get pleaseChooseLocation {
    return Intl.message(
      'Please choose location',
      name: 'pleaseChooseLocation',
      desc: '',
      args: [],
    );
  }

  /// `Please enter coupon code`
  String get pleaseEnterCouponCode {
    return Intl.message(
      'Please enter coupon code',
      name: 'pleaseEnterCouponCode',
      desc: '',
      args: [],
    );
  }

  /// `Please enter name of length atleast 3`
  String get pleaseEnterNameOfLengthAtleast3 {
    return Intl.message(
      'Please enter name of length atleast 3',
      name: 'pleaseEnterNameOfLengthAtleast3',
      desc: '',
      args: [],
    );
  }

  /// `Please enter otp`
  String get pleaseEnterOtp {
    return Intl.message(
      'Please enter otp',
      name: 'pleaseEnterOtp',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the verification code sent to`
  String get pleaseEnterTheVerificationCodeSentTo {
    return Intl.message(
      'Please enter the verification code sent to',
      name: 'pleaseEnterTheVerificationCodeSentTo',
      desc: '',
      args: [],
    );
  }

  /// `Please enter valid otp`
  String get pleaseEnterValidOtp {
    return Intl.message(
      'Please enter valid otp',
      name: 'pleaseEnterValidOtp',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your mobile number`
  String get pleaseEnterYourMobileNumber {
    return Intl.message(
      'Please enter your mobile number',
      name: 'pleaseEnterYourMobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your name`
  String get pleaseEnterYourName {
    return Intl.message(
      'Please enter your name',
      name: 'pleaseEnterYourName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your quantity`
  String get pleaseEnterYourQuantity {
    return Intl.message(
      'Please enter your quantity',
      name: 'pleaseEnterYourQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Please login`
  String get pleaseLogin {
    return Intl.message(
      'Please login',
      name: 'pleaseLogin',
      desc: '',
      args: [],
    );
  }

  /// `Please login to use this feature`
  String get pleaseLoginToUseThisFeature {
    return Intl.message(
      'Please login to use this feature',
      name: 'pleaseLoginToUseThisFeature',
      desc: '',
      args: [],
    );
  }

  /// `points`
  String get points {
    return Intl.message('points', name: 'points', desc: '', args: []);
  }

  /// `Position the barcode within the frame`
  String get positionTheBarcodeWithinTheFrame {
    return Intl.message(
      'Position the barcode within the frame',
      name: 'positionTheBarcodeWithinTheFrame',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Proceed`
  String get proceed {
    return Intl.message('Proceed', name: 'proceed', desc: '', args: []);
  }

  /// `Product out of stock`
  String get productOutOfStock {
    return Intl.message(
      'Product out of stock',
      name: 'productOutOfStock',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get quantity {
    return Intl.message('Quantity', name: 'quantity', desc: '', args: []);
  }

  /// `Rate Order`
  String get rateOrder {
    return Intl.message('Rate Order', name: 'rateOrder', desc: '', args: []);
  }

  /// `Rate Ordered Items`
  String get rateOrderedItems {
    return Intl.message(
      'Rate Ordered Items',
      name: 'rateOrderedItems',
      desc: '',
      args: [],
    );
  }

  /// `Rate Restaurant Review`
  String get rateRestaurantReview {
    return Intl.message(
      'Rate Restaurant Review',
      name: 'rateRestaurantReview',
      desc: '',
      args: [],
    );
  }

  /// `Rate Store Review`
  String get rateStoreReview {
    return Intl.message(
      'Rate Store Review',
      name: 'rateStoreReview',
      desc: '',
      args: [],
    );
  }

  /// `Rate Your Delivery Experience`
  String get rateYourDeliveryExperience {
    return Intl.message(
      'Rate Your Delivery Experience',
      name: 'rateYourDeliveryExperience',
      desc: '',
      args: [],
    );
  }

  /// `Rate Your Order`
  String get rateYourOrder {
    return Intl.message(
      'Rate Your Order',
      name: 'rateYourOrder',
      desc: '',
      args: [],
    );
  }

  /// `Redeemable Rewards`
  String get redeemableRewards {
    return Intl.message(
      'Redeemable Rewards',
      name: 'redeemableRewards',
      desc: '',
      args: [],
    );
  }

  /// `Redeemed`
  String get redeemed {
    return Intl.message('Redeemed', name: 'redeemed', desc: '', args: []);
  }

  /// `Redeemed Amount`
  String get redeemedAmount {
    return Intl.message(
      'Redeemed Amount',
      name: 'redeemedAmount',
      desc: '',
      args: [],
    );
  }

  /// `Redeemed Points`
  String get redeemedPoints {
    return Intl.message(
      'Redeemed Points',
      name: 'redeemedPoints',
      desc: '',
      args: [],
    );
  }

  /// `Redeem Now`
  String get redeemNow {
    return Intl.message('Redeem Now', name: 'redeemNow', desc: '', args: []);
  }

  /// `Remove`
  String get remove {
    return Intl.message('Remove', name: 'remove', desc: '', args: []);
  }

  /// `Replace`
  String get replace {
    return Intl.message('Replace', name: 'replace', desc: '', args: []);
  }

  /// `Replace cart item?`
  String get replaceCartItem {
    return Intl.message(
      'Replace cart item?',
      name: 'replaceCartItem',
      desc: '',
      args: [],
    );
  }

  /// `Resend code in 30 sec`
  String get resendCodeIn30Sec {
    return Intl.message(
      'Resend code in 30 sec',
      name: 'resendCodeIn30Sec',
      desc: '',
      args: [],
    );
  }

  /// `Resend OTP`
  String get resendOtp {
    return Intl.message('Resend OTP', name: 'resendOtp', desc: '', args: []);
  }

  /// `Restaurant`
  String get restaurant {
    return Intl.message('Restaurant', name: 'restaurant', desc: '', args: []);
  }

  /// `reviews`
  String get reviews {
    return Intl.message('reviews', name: 'reviews', desc: '', args: []);
  }

  /// `SAIMPEX`
  String get saimpex {
    return Intl.message('SAIMPEX', name: 'saimpex', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Scan Barcode`
  String get scanBarcode {
    return Intl.message(
      'Scan Barcode',
      name: 'scanBarcode',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Search Categories`
  String get searchCategories {
    return Intl.message(
      'Search Categories',
      name: 'searchCategories',
      desc: '',
      args: [],
    );
  }

  /// `Search for area, street name.....`
  String get searchForAreaStreetName {
    return Intl.message(
      'Search for area, street name.....',
      name: 'searchForAreaStreetName',
      desc: '',
      args: [],
    );
  }

  /// `Search for items`
  String get searchForItems {
    return Intl.message(
      'Search for items',
      name: 'searchForItems',
      desc: '',
      args: [],
    );
  }

  /// `Select Delivery Location`
  String get selectDeliveryLocation {
    return Intl.message(
      'Select Delivery Location',
      name: 'selectDeliveryLocation',
      desc: '',
      args: [],
    );
  }

  /// `Select Your Location`
  String get selectYourLocation {
    return Intl.message(
      'Select Your Location',
      name: 'selectYourLocation',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
  }

  /// `Server Down`
  String get serverDown {
    return Intl.message('Server Down', name: 'serverDown', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Sorry, we're down for maintenance  We'll be back up shortly.`
  String get sorryWereDownForMaintenanceWellBeBackUpShortly {
    return Intl.message(
      'Sorry, we\'re down for maintenance  We\'ll be back up shortly.',
      name: 'sorryWereDownForMaintenanceWellBeBackUpShortly',
      desc: '',
      args: [],
    );
  }

  /// `Sort By`
  String get sortBy {
    return Intl.message('Sort By', name: 'sortBy', desc: '', args: []);
  }

  /// `Sort & Filter`
  String get sortFilter {
    return Intl.message(
      'Sort & Filter',
      name: 'sortFilter',
      desc: '',
      args: [],
    );
  }

  /// `Start typing to search`
  String get startTypingToSearch {
    return Intl.message(
      'Start typing to search',
      name: 'startTypingToSearch',
      desc: '',
      args: [],
    );
  }

  /// `Submit Rating`
  String get submitRating {
    return Intl.message(
      'Submit Rating',
      name: 'submitRating',
      desc: '',
      args: [],
    );
  }

  /// `Tax`
  String get tax {
    return Intl.message('Tax', name: 'tax', desc: '', args: []);
  }

  /// `Terms & Conditions`
  String get termsConditions {
    return Intl.message(
      'Terms & Conditions',
      name: 'termsConditions',
      desc: '',
      args: [],
    );
  }

  /// `The restaurant preparing your food`
  String get theRestaurantPreparingYourFood {
    return Intl.message(
      'The restaurant preparing your food',
      name: 'theRestaurantPreparingYourFood',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `To Pay`
  String get toPay {
    return Intl.message('To Pay', name: 'toPay', desc: '', args: []);
  }

  /// `Top Selling Dishes`
  String get topSellingDishes {
    return Intl.message(
      'Top Selling Dishes',
      name: 'topSellingDishes',
      desc: '',
      args: [],
    );
  }

  /// `Total Bill`
  String get totalBill {
    return Intl.message('Total Bill', name: 'totalBill', desc: '', args: []);
  }

  /// `Track Order`
  String get trackOrder {
    return Intl.message('Track Order', name: 'trackOrder', desc: '', args: []);
  }

  /// `Track Your Order`
  String get trackYourOrder {
    return Intl.message(
      'Track Your Order',
      name: 'trackYourOrder',
      desc: '',
      args: [],
    );
  }

  /// `Transaction History`
  String get transactionHistory {
    return Intl.message(
      'Transaction History',
      name: 'transactionHistory',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get tryAgain {
    return Intl.message('Try Again', name: 'tryAgain', desc: '', args: []);
  }

  /// `Try searching with different keywords`
  String get trySearchingWithDifferentKeywords {
    return Intl.message(
      'Try searching with different keywords',
      name: 'trySearchingWithDifferentKeywords',
      desc: '',
      args: [],
    );
  }

  /// `Type a message…`
  String get typeAMessage {
    return Intl.message(
      'Type a message…',
      name: 'typeAMessage',
      desc: '',
      args: [],
    );
  }

  /// `Type your review here`
  String get typeYourReviewHere {
    return Intl.message(
      'Type your review here',
      name: 'typeYourReviewHere',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Driver`
  String get unknownDriver {
    return Intl.message(
      'Unknown Driver',
      name: 'unknownDriver',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Vendor`
  String get unknownVendor {
    return Intl.message(
      'Unknown Vendor',
      name: 'unknownVendor',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Upto`
  String get upto {
    return Intl.message('Upto', name: 'upto', desc: '', args: []);
  }

  /// `Vendor`
  String get vendor {
    return Intl.message('Vendor', name: 'vendor', desc: '', args: []);
  }

  /// `View all coupons`
  String get viewAllCoupons {
    return Intl.message(
      'View all coupons',
      name: 'viewAllCoupons',
      desc: '',
      args: [],
    );
  }

  /// `View Orders`
  String get viewOrders {
    return Intl.message('View Orders', name: 'viewOrders', desc: '', args: []);
  }

  /// `We'll be back soon`
  String get wellBeBackSoon {
    return Intl.message(
      'We\'ll be back soon',
      name: 'wellBeBackSoon',
      desc: '',
      args: [],
    );
  }

  /// `We’ve sent a verification code to your WhatsApp`
  String get weveSentAVerificationCodeToYourWhatsapp {
    return Intl.message(
      'We’ve sent a verification code to your WhatsApp',
      name: 'weveSentAVerificationCodeToYourWhatsapp',
      desc: '',
      args: [],
    );
  }

  /// `What do you need today?`
  String get whatDoYouNeedToday {
    return Intl.message(
      'What do you need today?',
      name: 'whatDoYouNeedToday',
      desc: '',
      args: [],
    );
  }

  /// `What’s your name?`
  String get whatsYourName {
    return Intl.message(
      'What’s your name?',
      name: 'whatsYourName',
      desc: '',
      args: [],
    );
  }

  /// `% with this code`
  String get withThisCode {
    return Intl.message(
      '% with this code',
      name: 'withThisCode',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `Yesterday`
  String get yesterday {
    return Intl.message('Yesterday', name: 'yesterday', desc: '', args: []);
  }

  /// `You are logged out successfully.`
  String get youAreLoggedOutSuccessfully {
    return Intl.message(
      'You are logged out successfully.',
      name: 'youAreLoggedOutSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `You cannot delete this item from here, to checkout minimum one product is required`
  String get youCannotDeleteThisItemFromHereToCheckoutMinimum {
    return Intl.message(
      'You cannot delete this item from here, to checkout minimum one product is required',
      name: 'youCannotDeleteThisItemFromHereToCheckoutMinimum',
      desc: '',
      args: [],
    );
  }

  /// `You might also like`
  String get youMightAlsoLike {
    return Intl.message(
      'You might also like',
      name: 'youMightAlsoLike',
      desc: '',
      args: [],
    );
  }

  /// `Your cart has items from`
  String get yourCartHasDishesFrom {
    return Intl.message(
      'Your cart has items from',
      name: 'yourCartHasDishesFrom',
      desc: '',
      args: [],
    );
  }

  /// `Your Cart is Empty`
  String get yourCartIsEmpty {
    return Intl.message(
      'Your Cart is Empty',
      name: 'yourCartIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Your order has been delivered`
  String get yourOrderHasBeenDelivered {
    return Intl.message(
      'Your order has been delivered',
      name: 'yourOrderHasBeenDelivered',
      desc: '',
      args: [],
    );
  }

  /// `Your order has been picked up for delivery`
  String get yourOrderHasBeenPickedUpForDelivery {
    return Intl.message(
      'Your order has been picked up for delivery',
      name: 'yourOrderHasBeenPickedUpForDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Your order has been received`
  String get yourOrderHasBeenReceived {
    return Intl.message(
      'Your order has been received',
      name: 'yourOrderHasBeenReceived',
      desc: '',
      args: [],
    );
  }

  /// `Your Orders`
  String get yourOrders {
    return Intl.message('Your Orders', name: 'yourOrders', desc: '', args: []);
  }

  /// `Your trusted food & grocery delivery partner`
  String get yourTrustedFoodGroceryDeliveryPartner {
    return Intl.message(
      'Your trusted food & grocery delivery partner',
      name: 'yourTrustedFoodGroceryDeliveryPartner',
      desc: '',
      args: [],
    );
  }

  /// `You saved`
  String get youSaved {
    return Intl.message('You saved', name: 'youSaved', desc: '', args: []);
  }

  /// `ORDER`
  String get order {
    return Intl.message('ORDER', name: 'order', desc: '', args: []);
  }

  /// `DATE & TIME`
  String get dateTime {
    return Intl.message('DATE & TIME', name: 'dateTime', desc: '', args: []);
  }

  /// `DELIVERY ADDRESS`
  String get deliveryAddress {
    return Intl.message(
      'DELIVERY ADDRESS',
      name: 'deliveryAddress',
      desc: '',
      args: [],
    );
  }

  /// `ORDER ITEMS`
  String get orderItems {
    return Intl.message('ORDER ITEMS', name: 'orderItems', desc: '', args: []);
  }

  /// `CUSTOMER NOTES`
  String get customerNotes {
    return Intl.message(
      'CUSTOMER NOTES',
      name: 'customerNotes',
      desc: '',
      args: [],
    );
  }

  /// `PAYMENT SUMMARY`
  String get paymentSummary {
    return Intl.message(
      'PAYMENT SUMMARY',
      name: 'paymentSummary',
      desc: '',
      args: [],
    );
  }

  /// `Please leave the package at the front door and ring the bell. Thank you!`
  String get pleaseLeaveThePackageAtTheFrontDoorAndRing {
    return Intl.message(
      'Please leave the package at the front door and ring the bell. Thank you!',
      name: 'pleaseLeaveThePackageAtTheFrontDoorAndRing',
      desc: '',
      args: [],
    );
  }

  /// `Subtotal`
  String get subtotal {
    return Intl.message('Subtotal', name: 'subtotal', desc: '', args: []);
  }

  /// `Payment On`
  String get paymentOn {
    return Intl.message('Payment On', name: 'paymentOn', desc: '', args: []);
  }

  /// `Total Amount`
  String get totalAmount {
    return Intl.message(
      'Total Amount',
      name: 'totalAmount',
      desc: '',
      args: [],
    );
  }

  /// `Order Timeline`
  String get orderTimeline {
    return Intl.message(
      'Order Timeline',
      name: 'orderTimeline',
      desc: '',
      args: [],
    );
  }

  /// `Order Duration Breakdown`
  String get orderDurationBreakdown {
    return Intl.message(
      'Order Duration Breakdown',
      name: 'orderDurationBreakdown',
      desc: '',
      args: [],
    );
  }

  /// `Qty`
  String get qty {
    return Intl.message('Qty', name: 'qty', desc: '', args: []);
  }

  /// `Assigned Delivery Partner`
  String get assignedDeliveryPartner {
    return Intl.message(
      'Assigned Delivery Partner',
      name: 'assignedDeliveryPartner',
      desc: '',
      args: [],
    );
  }

  /// `Reject`
  String get reject {
    return Intl.message('Reject', name: 'reject', desc: '', args: []);
  }

  /// `Accept Order`
  String get acceptOrder {
    return Intl.message(
      'Accept Order',
      name: 'acceptOrder',
      desc: '',
      args: [],
    );
  }

  /// `Mark as Ready`
  String get markAsReady {
    return Intl.message(
      'Mark as Ready',
      name: 'markAsReady',
      desc: '',
      args: [],
    );
  }

  /// `Prepare Order`
  String get prepareOrder {
    return Intl.message(
      'Prepare Order',
      name: 'prepareOrder',
      desc: '',
      args: [],
    );
  }

  /// `Order details not found`
  String get orderDetailsNotFound {
    return Intl.message(
      'Order details not found',
      name: 'orderDetailsNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Owner`
  String get owner {
    return Intl.message('Owner', name: 'owner', desc: '', args: []);
  }

  /// `ID`
  String get idNumber {
    return Intl.message('ID', name: 'idNumber', desc: '', args: []);
  }

  /// `Contact`
  String get contact {
    return Intl.message('Contact', name: 'contact', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `Address`
  String get address {
    return Intl.message('Address', name: 'address', desc: '', args: []);
  }

  /// `Delivery Boys`
  String get deliveryBoys {
    return Intl.message(
      'Delivery Boys',
      name: 'deliveryBoys',
      desc: '',
      args: [],
    );
  }

  /// `ACTIVE`
  String get active {
    return Intl.message('ACTIVE', name: 'active', desc: '', args: []);
  }

  /// `INACTIVE`
  String get inactive {
    return Intl.message('INACTIVE', name: 'inactive', desc: '', args: []);
  }

  /// `Search name or mobile number`
  String get searchNameOrMobileNumber {
    return Intl.message(
      'Search name or mobile number',
      name: 'searchNameOrMobileNumber',
      desc: '',
      args: [],
    );
  }

  /// `No delivery boys found`
  String get noDeliveryBoysFound {
    return Intl.message(
      'No delivery boys found',
      name: 'noDeliveryBoysFound',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message('Version', name: 'version', desc: '', args: []);
  }

  /// `View All`
  String get viewAll {
    return Intl.message('View All', name: 'viewAll', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `My Restaurant`
  String get myRestaurant {
    return Intl.message(
      'My Restaurant',
      name: 'myRestaurant',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant Management`
  String get restaurantManagement {
    return Intl.message(
      'Restaurant Management',
      name: 'restaurantManagement',
      desc: '',
      args: [],
    );
  }

  /// `Auto-Accept Orders`
  String get autoAcceptOrdersTitle {
    return Intl.message(
      'Auto-Accept Orders',
      name: 'autoAcceptOrdersTitle',
      desc: '',
      args: [],
    );
  }

  /// `Orders will be accepted automatically`
  String get autoAcceptOrdersSubtitle {
    return Intl.message(
      'Orders will be accepted automatically',
      name: 'autoAcceptOrdersSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter category name`
  String get enterCategoryNameHint {
    return Intl.message(
      'Enter category name',
      name: 'enterCategoryNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Enter tag name`
  String get enterTagNameHint {
    return Intl.message(
      'Enter tag name',
      name: 'enterTagNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Working Hours`
  String get workingHours {
    return Intl.message(
      'Working Hours',
      name: 'workingHours',
      desc: '',
      args: [],
    );
  }

  /// `Leaves`
  String get leaves {
    return Intl.message('Leaves', name: 'leaves', desc: '', args: []);
  }

  /// `Menu`
  String get menu {
    return Intl.message('Menu', name: 'menu', desc: '', args: []);
  }

  /// `Menu Bulk Import`
  String get menuBulkImport {
    return Intl.message(
      'Menu Bulk Import',
      name: 'menuBulkImport',
      desc: '',
      args: [],
    );
  }

  /// `Basket`
  String get basket {
    return Intl.message('Basket', name: 'basket', desc: '', args: []);
  }

  /// `Search by ID, item name`
  String get basketSearchHint {
    return Intl.message(
      'Search by ID, item name',
      name: 'basketSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `Received Payouts`
  String get receivedPayouts {
    return Intl.message(
      'Received Payouts',
      name: 'receivedPayouts',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant Reports`
  String get restaurantReports {
    return Intl.message(
      'Restaurant Reports',
      name: 'restaurantReports',
      desc: '',
      args: [],
    );
  }

  /// `RESTAURANT DETAILS`
  String get restaurantDetails {
    return Intl.message(
      'RESTAURANT DETAILS',
      name: 'restaurantDetails',
      desc: '',
      args: [],
    );
  }

  /// `BANK DETAILS`
  String get bankDetails {
    return Intl.message(
      'BANK DETAILS',
      name: 'bankDetails',
      desc: '',
      args: [],
    );
  }

  /// `ABOUT THE RESTAURANT`
  String get aboutTheRestaurant {
    return Intl.message(
      'ABOUT THE RESTAURANT',
      name: 'aboutTheRestaurant',
      desc: '',
      args: [],
    );
  }

  /// `REGISTRATION DETAILS`
  String get registrationDetails {
    return Intl.message(
      'REGISTRATION DETAILS',
      name: 'registrationDetails',
      desc: '',
      args: [],
    );
  }

  /// `PAYMENT DETAILS`
  String get paymentSummaryDetails {
    return Intl.message(
      'PAYMENT DETAILS',
      name: 'paymentSummaryDetails',
      desc: '',
      args: [],
    );
  }

  /// `OWNER IDENTITY PROOF`
  String get ownerIdentityProof {
    return Intl.message(
      'OWNER IDENTITY PROOF',
      name: 'ownerIdentityProof',
      desc: '',
      args: [],
    );
  }

  /// `CERTIFICATES`
  String get certificates {
    return Intl.message(
      'CERTIFICATES',
      name: 'certificates',
      desc: '',
      args: [],
    );
  }

  /// `Rating & Reviews`
  String get ratingReviews {
    return Intl.message(
      'Rating & Reviews',
      name: 'ratingReviews',
      desc: '',
      args: [],
    );
  }

  /// `Holder Name`
  String get holderName {
    return Intl.message('Holder Name', name: 'holderName', desc: '', args: []);
  }

  /// `IBAN Number`
  String get ibanNumber {
    return Intl.message('IBAN Number', name: 'ibanNumber', desc: '', args: []);
  }

  /// `SWIFT Code`
  String get swiftCode {
    return Intl.message('SWIFT Code', name: 'swiftCode', desc: '', args: []);
  }

  /// `Reg. Number`
  String get regNumber {
    return Intl.message('Reg. Number', name: 'regNumber', desc: '', args: []);
  }

  /// `Reg. Date`
  String get regDate {
    return Intl.message('Reg. Date', name: 'regDate', desc: '', args: []);
  }

  /// `GST Number`
  String get gstNumber {
    return Intl.message('GST Number', name: 'gstNumber', desc: '', args: []);
  }

  /// `Commission %`
  String get commissionPercentage {
    return Intl.message(
      'Commission %',
      name: 'commissionPercentage',
      desc: '',
      args: [],
    );
  }

  /// `Total Profit`
  String get totalProfit {
    return Intl.message(
      'Total Profit',
      name: 'totalProfit',
      desc: '',
      args: [],
    );
  }

  /// `Order: `
  String get orderColon {
    return Intl.message('Order: ', name: 'orderColon', desc: '', args: []);
  }

  /// `MARK LEAVE`
  String get markLeave {
    return Intl.message('MARK LEAVE', name: 'markLeave', desc: '', args: []);
  }

  /// `LEAVES HISTORY`
  String get leavesHistory {
    return Intl.message(
      'LEAVES HISTORY',
      name: 'leavesHistory',
      desc: '',
      args: [],
    );
  }

  /// `Upcoming Leaves`
  String get upcomingLeaves {
    return Intl.message(
      'Upcoming Leaves',
      name: 'upcomingLeaves',
      desc: '',
      args: [],
    );
  }

  /// `Completed Leaves`
  String get completedLeaves {
    return Intl.message(
      'Completed Leaves',
      name: 'completedLeaves',
      desc: '',
      args: [],
    );
  }

  /// `From Date`
  String get fromDate {
    return Intl.message('From Date', name: 'fromDate', desc: '', args: []);
  }

  /// `To Date`
  String get toDate {
    return Intl.message('To Date', name: 'toDate', desc: '', args: []);
  }

  /// `Reason For Leave`
  String get reasonForLeave {
    return Intl.message(
      'Reason For Leave',
      name: 'reasonForLeave',
      desc: '',
      args: [],
    );
  }

  /// `Mark Leave`
  String get markLeaveButton {
    return Intl.message(
      'Mark Leave',
      name: 'markLeaveButton',
      desc: '',
      args: [],
    );
  }

  /// `SCHEDULED`
  String get scheduled {
    return Intl.message('SCHEDULED', name: 'scheduled', desc: '', args: []);
  }

  /// `COMPLETED`
  String get completed {
    return Intl.message('COMPLETED', name: 'completed', desc: '', args: []);
  }

  /// `Pending`
  String get pending {
    return Intl.message('Pending', name: 'pending', desc: '', args: []);
  }

  /// `Accepted`
  String get accepted {
    return Intl.message('Accepted', name: 'accepted', desc: '', args: []);
  }

  /// `Preparing`
  String get preparing {
    return Intl.message('Preparing', name: 'preparing', desc: '', args: []);
  }

  /// `Ready`
  String get ready {
    return Intl.message('Ready', name: 'ready', desc: '', args: []);
  }

  /// `Delivered`
  String get delivered {
    return Intl.message('Delivered', name: 'delivered', desc: '', args: []);
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message('Cancelled', name: 'cancelled', desc: '', args: []);
  }

  /// `No orders found`
  String get noOrdersFound {
    return Intl.message(
      'No orders found',
      name: 'noOrdersFound',
      desc: '',
      args: [],
    );
  }

  /// `Search by ID, name`
  String get searchByIdName {
    return Intl.message(
      'Search by ID, name',
      name: 'searchByIdName',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `Membership`
  String get membership {
    return Intl.message('Membership', name: 'membership', desc: '', args: []);
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `Monday`
  String get monday {
    return Intl.message('Monday', name: 'monday', desc: '', args: []);
  }

  /// `Tuesday`
  String get tuesday {
    return Intl.message('Tuesday', name: 'tuesday', desc: '', args: []);
  }

  /// `Wednesday`
  String get wednesday {
    return Intl.message('Wednesday', name: 'wednesday', desc: '', args: []);
  }

  /// `Thursday`
  String get thursday {
    return Intl.message('Thursday', name: 'thursday', desc: '', args: []);
  }

  /// `Friday`
  String get friday {
    return Intl.message('Friday', name: 'friday', desc: '', args: []);
  }

  /// `Saturday`
  String get saturday {
    return Intl.message('Saturday', name: 'saturday', desc: '', args: []);
  }

  /// `Sunday`
  String get sunday {
    return Intl.message('Sunday', name: 'sunday', desc: '', args: []);
  }

  /// `24 Hr`
  String get hr24 {
    return Intl.message('24 Hr', name: 'hr24', desc: '', args: []);
  }

  /// `Today's Orders`
  String get todaysOrders {
    return Intl.message(
      'Today\'s Orders',
      name: 'todaysOrders',
      desc: '',
      args: [],
    );
  }

  /// `Total Orders`
  String get totalOrdersStat {
    return Intl.message(
      'Total Orders',
      name: 'totalOrdersStat',
      desc: '',
      args: [],
    );
  }

  /// `Products`
  String get products {
    return Intl.message('Products', name: 'products', desc: '', args: []);
  }

  /// `ORDERS`
  String get ordersHeader {
    return Intl.message('ORDERS', name: 'ordersHeader', desc: '', args: []);
  }

  /// `Joined on`
  String get joinedOn {
    return Intl.message('Joined on', name: 'joinedOn', desc: '', args: []);
  }

  /// `Vendor Type`
  String get vendorType {
    return Intl.message('Vendor Type', name: 'vendorType', desc: '', args: []);
  }

  /// `Zone`
  String get zone {
    return Intl.message('Zone', name: 'zone', desc: '', args: []);
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Coordinates`
  String get coordinates {
    return Intl.message('Coordinates', name: 'coordinates', desc: '', args: []);
  }

  /// `Owner Name`
  String get ownerName {
    return Intl.message('Owner Name', name: 'ownerName', desc: '', args: []);
  }

  /// `Owner Email`
  String get ownerEmail {
    return Intl.message('Owner Email', name: 'ownerEmail', desc: '', args: []);
  }

  /// `Owner Phone`
  String get ownerPhone {
    return Intl.message('Owner Phone', name: 'ownerPhone', desc: '', args: []);
  }

  /// `Bank Name`
  String get bankName {
    return Intl.message('Bank Name', name: 'bankName', desc: '', args: []);
  }

  /// `Account Name`
  String get accountName {
    return Intl.message(
      'Account Name',
      name: 'accountName',
      desc: '',
      args: [],
    );
  }

  /// `Account Number`
  String get accountNumber {
    return Intl.message(
      'Account Number',
      name: 'accountNumber',
      desc: '',
      args: [],
    );
  }

  /// `Trade License No`
  String get tradeLicenseNo {
    return Intl.message(
      'Trade License No',
      name: 'tradeLicenseNo',
      desc: '',
      args: [],
    );
  }

  /// `Vat/Gst Number`
  String get vatGstNumber {
    return Intl.message(
      'Vat/Gst Number',
      name: 'vatGstNumber',
      desc: '',
      args: [],
    );
  }

  /// `National Id Type`
  String get nationalIdType {
    return Intl.message(
      'National Id Type',
      name: 'nationalIdType',
      desc: '',
      args: [],
    );
  }

  /// `National Id Number`
  String get nationalIdNumber {
    return Intl.message(
      'National Id Number',
      name: 'nationalIdNumber',
      desc: '',
      args: [],
    );
  }

  /// `Service Delivery Charge`
  String get serviceDeliveryCharge {
    return Intl.message(
      'Service Delivery Charge',
      name: 'serviceDeliveryCharge',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant Commission Percentage per Order`
  String get restaurantCommission {
    return Intl.message(
      'Restaurant Commission Percentage per Order',
      name: 'restaurantCommission',
      desc: '',
      args: [],
    );
  }

  /// `Gst/Vat`
  String get gstVat {
    return Intl.message('Gst/Vat', name: 'gstVat', desc: '', args: []);
  }

  /// `Packaging Cost`
  String get packagingCost {
    return Intl.message(
      'Packaging Cost',
      name: 'packagingCost',
      desc: '',
      args: [],
    );
  }

  /// `ALL MENUS`
  String get allMenus {
    return Intl.message('ALL MENUS', name: 'allMenus', desc: '', args: []);
  }

  /// `ALL ITEMS`
  String get allItems {
    return Intl.message('ALL ITEMS', name: 'allItems', desc: '', args: []);
  }

  /// `Restaurant 1`
  String get restaurantOne {
    return Intl.message(
      'Restaurant 1',
      name: 'restaurantOne',
      desc: '',
      args: [],
    );
  }

  /// `Serving authentic flavors with fresh ingredients. Specializing in continental and oriental cuisines.`
  String get aboutDescription {
    return Intl.message(
      'Serving authentic flavors with fresh ingredients. Specializing in continental and oriental cuisines.',
      name: 'aboutDescription',
      desc: '',
      args: [],
    );
  }

  /// `Grilled Chicken`
  String get grilledChicken {
    return Intl.message(
      'Grilled Chicken',
      name: 'grilledChicken',
      desc: '',
      args: [],
    );
  }

  /// `Veg Burger`
  String get vegBurger {
    return Intl.message('Veg Burger', name: 'vegBurger', desc: '', args: []);
  }

  /// `Sushi Platter`
  String get sushiPlatter {
    return Intl.message(
      'Sushi Platter',
      name: 'sushiPlatter',
      desc: '',
      args: [],
    );
  }

  /// `Lunch Menu`
  String get lunchMenu {
    return Intl.message('Lunch Menu', name: 'lunchMenu', desc: '', args: []);
  }

  /// `Dinner Special`
  String get dinnerSpecial {
    return Intl.message(
      'Dinner Special',
      name: 'dinnerSpecial',
      desc: '',
      args: [],
    );
  }

  /// `Breakfast`
  String get breakfast {
    return Intl.message('Breakfast', name: 'breakfast', desc: '', args: []);
  }

  /// `Classic Basket`
  String get classicBasket {
    return Intl.message(
      'Classic Basket',
      name: 'classicBasket',
      desc: '',
      args: [],
    );
  }

  /// `Combo Offer`
  String get comboOffer {
    return Intl.message('Combo Offer', name: 'comboOffer', desc: '', args: []);
  }

  /// `Active`
  String get activeLabel {
    return Intl.message('Active', name: 'activeLabel', desc: '', args: []);
  }

  /// `Inactive`
  String get inactiveLabel {
    return Intl.message('Inactive', name: 'inactiveLabel', desc: '', args: []);
  }

  /// `Duration`
  String get durationLabel {
    return Intl.message('Duration', name: 'durationLabel', desc: '', args: []);
  }

  /// `Reason`
  String get reasonLabel {
    return Intl.message('Reason', name: 'reasonLabel', desc: '', args: []);
  }

  /// `Start date`
  String get startDate {
    return Intl.message('Start date', name: 'startDate', desc: '', args: []);
  }

  /// `End date`
  String get endDate {
    return Intl.message('End date', name: 'endDate', desc: '', args: []);
  }

  /// `Applied on`
  String get applyOn {
    return Intl.message('Applied on', name: 'applyOn', desc: '', args: []);
  }

  /// `SUBMIT LEAVE REQUEST`
  String get submitLeaveRequest {
    return Intl.message(
      'SUBMIT LEAVE REQUEST',
      name: 'submitLeaveRequest',
      desc: '',
      args: [],
    );
  }

  /// `ADD NEW MENU`
  String get addNewMenu {
    return Intl.message('ADD NEW MENU', name: 'addNewMenu', desc: '', args: []);
  }

  /// `ADD NEW ITEM`
  String get addNewItem {
    return Intl.message('ADD NEW ITEM', name: 'addNewItem', desc: '', args: []);
  }

  /// `CREATE NEW BASKET`
  String get createNewBasket {
    return Intl.message(
      'CREATE NEW BASKET',
      name: 'createNewBasket',
      desc: '',
      args: [],
    );
  }

  /// `ORDER #{id}`
  String orderIdLabel(String id) {
    return Intl.message(
      'ORDER #$id',
      name: 'orderIdLabel',
      desc: '',
      args: [id],
    );
  }

  /// `Pre-orders`
  String get preOrders {
    return Intl.message('Pre-orders', name: 'preOrders', desc: '', args: []);
  }

  /// `Upcoming pre-orders ({count})`
  String upcomingPreordersCount(String count) {
    return Intl.message(
      'Upcoming pre-orders ($count)',
      name: 'upcomingPreordersCount',
      desc: '',
      args: [count],
    );
  }

  /// `No upcoming pre-orders`
  String get noUpcomingPreorders {
    return Intl.message(
      'No upcoming pre-orders',
      name: 'noUpcomingPreorders',
      desc: '',
      args: [],
    );
  }

  /// `Pre-order`
  String get preorderBadge {
    return Intl.message('Pre-order', name: 'preorderBadge', desc: '', args: []);
  }

  /// `Scheduled for {time}`
  String scheduledForTime(String time) {
    return Intl.message(
      'Scheduled for $time',
      name: 'scheduledForTime',
      desc: '',
      args: [time],
    );
  }

  /// `In {hours} h {minutes} min`
  String dueInHoursMinutes(String hours, String minutes) {
    return Intl.message(
      'In $hours h $minutes min',
      name: 'dueInHoursMinutes',
      desc: '',
      args: [hours, minutes],
    );
  }

  /// `In {minutes} min`
  String dueInMinutes(String minutes) {
    return Intl.message(
      'In $minutes min',
      name: 'dueInMinutes',
      desc: '',
      args: [minutes],
    );
  }

  /// `Due now`
  String get preorderDueNow {
    return Intl.message('Due now', name: 'preorderDueNow', desc: '', args: []);
  }

  /// `Driver requested`
  String get driverRequested {
    return Intl.message(
      'Driver requested',
      name: 'driverRequested',
      desc: '',
      args: [],
    );
  }

  /// `Driver assigned`
  String get driverAssigned {
    return Intl.message(
      'Driver assigned',
      name: 'driverAssigned',
      desc: '',
      args: [],
    );
  }

  /// `Pre-order due soon`
  String get preorderReminderTitle {
    return Intl.message(
      'Pre-order due soon',
      name: 'preorderReminderTitle',
      desc: '',
      args: [],
    );
  }

  /// `Pre-order {code} is due at {time}. Please have it ready.`
  String preorderReminderBody(String code, String time) {
    return Intl.message(
      'Pre-order $code is due at $time. Please have it ready.',
      name: 'preorderReminderBody',
      desc: '',
      args: [code, time],
    );
  }

  /// `Assigned`
  String get assignedStatus {
    return Intl.message('Assigned', name: 'assignedStatus', desc: '', args: []);
  }

  /// `Cancelled On {date}`
  String cancelledOnLabel(String date) {
    return Intl.message(
      'Cancelled On $date',
      name: 'cancelledOnLabel',
      desc: '',
      args: [date],
    );
  }

  /// `Reason: {reason}`
  String reasonColonLabel(String reason) {
    return Intl.message(
      'Reason: $reason',
      name: 'reasonColonLabel',
      desc: '',
      args: [reason],
    );
  }

  /// `View Details`
  String get viewDetails {
    return Intl.message(
      'View Details',
      name: 'viewDetails',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get basketDetailsTitle {
    return Intl.message(
      'Details',
      name: 'basketDetailsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Basket ID: {id}`
  String basketIdLabel(String id) {
    return Intl.message(
      'Basket ID: $id',
      name: 'basketIdLabel',
      desc: '',
      args: [id],
    );
  }

  /// `Created {date}`
  String createdLabel(String date) {
    return Intl.message(
      'Created $date',
      name: 'createdLabel',
      desc: '',
      args: [date],
    );
  }

  /// `PRICE`
  String get priceLabel {
    return Intl.message('PRICE', name: 'priceLabel', desc: '', args: []);
  }

  /// `REDEEM POINTS`
  String get redeemPointsLabel {
    return Intl.message(
      'REDEEM POINTS',
      name: 'redeemPointsLabel',
      desc: '',
      args: [],
    );
  }

  /// `ITEMS COUNT`
  String get itemsCountLabel {
    return Intl.message(
      'ITEMS COUNT',
      name: 'itemsCountLabel',
      desc: '',
      args: [],
    );
  }

  /// `ORDERS COUNT`
  String get ordersCountLabel {
    return Intl.message(
      'ORDERS COUNT',
      name: 'ordersCountLabel',
      desc: '',
      args: [],
    );
  }

  /// `BASKET ITEMS`
  String get basketItemsHeader {
    return Intl.message(
      'BASKET ITEMS',
      name: 'basketItemsHeader',
      desc: '',
      args: [],
    );
  }

  /// `Qty: {qty}`
  String qtyLabel(String qty) {
    return Intl.message('Qty: $qty', name: 'qtyLabel', desc: '', args: [qty]);
  }

  /// `REDEEMED CUSTOMERS`
  String get redeemedCustomersHeader {
    return Intl.message(
      'REDEEMED CUSTOMERS',
      name: 'redeemedCustomersHeader',
      desc: '',
      args: [],
    );
  }

  /// `REDEEMED`
  String get redeemedStatus {
    return Intl.message('REDEEMED', name: 'redeemedStatus', desc: '', args: []);
  }

  /// `POINTS`
  String get pointsLabel {
    return Intl.message('POINTS', name: 'pointsLabel', desc: '', args: []);
  }

  /// `DATE`
  String get dateLabel {
    return Intl.message('DATE', name: 'dateLabel', desc: '', args: []);
  }

  /// `Available`
  String get availableStatus {
    return Intl.message(
      'Available',
      name: 'availableStatus',
      desc: '',
      args: [],
    );
  }

  /// `Item Id`
  String get itemIdLabel {
    return Intl.message('Item Id', name: 'itemIdLabel', desc: '', args: []);
  }

  /// `Serial No`
  String get serialNoLabel {
    return Intl.message('Serial No', name: 'serialNoLabel', desc: '', args: []);
  }

  /// `Preparation Time`
  String get preparationTimeLabel {
    return Intl.message(
      'Preparation Time',
      name: 'preparationTimeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get categoryLabel {
    return Intl.message('Category', name: 'categoryLabel', desc: '', args: []);
  }

  /// `Tags`
  String get tagsLabel {
    return Intl.message('Tags', name: 'tagsLabel', desc: '', args: []);
  }

  /// `AVAILABLE TIME`
  String get availableTimeHeader {
    return Intl.message(
      'AVAILABLE TIME',
      name: 'availableTimeHeader',
      desc: '',
      args: [],
    );
  }

  /// `SALES & PERFORMANCE`
  String get salesPerformanceHeader {
    return Intl.message(
      'SALES & PERFORMANCE',
      name: 'salesPerformanceHeader',
      desc: '',
      args: [],
    );
  }

  /// `ITEM ORDERS`
  String get itemOrdersHeader {
    return Intl.message(
      'ITEM ORDERS',
      name: 'itemOrdersHeader',
      desc: '',
      args: [],
    );
  }

  /// `Update Details`
  String get updateDetailsButton {
    return Intl.message(
      'Update Details',
      name: 'updateDetailsButton',
      desc: '',
      args: [],
    );
  }

  /// `[By Hotel]`
  String get byHotelLabel {
    return Intl.message('[By Hotel]', name: 'byHotelLabel', desc: '', args: []);
  }

  /// `Revenue`
  String get revenueLabel {
    return Intl.message('Revenue', name: 'revenueLabel', desc: '', args: []);
  }

  /// `Average Rating`
  String get averageRatingLabel {
    return Intl.message(
      'Average Rating',
      name: 'averageRatingLabel',
      desc: '',
      args: [],
    );
  }

  /// `Total Reviews`
  String get totalReviewsStat {
    return Intl.message(
      'Total Reviews',
      name: 'totalReviewsStat',
      desc: '',
      args: [],
    );
  }

  /// `Last Purchase`
  String get lastPurchaseLabel {
    return Intl.message(
      'Last Purchase',
      name: 'lastPurchaseLabel',
      desc: '',
      args: [],
    );
  }

  /// `ITEMS TOTAL`
  String get itemsTotalLabel {
    return Intl.message(
      'ITEMS TOTAL',
      name: 'itemsTotalLabel',
      desc: '',
      args: [],
    );
  }

  /// `DATE & TIME`
  String get dateTimeLabel {
    return Intl.message(
      'DATE & TIME',
      name: 'dateTimeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Add Items`
  String get addItemsTitle {
    return Intl.message('Add Items', name: 'addItemsTitle', desc: '', args: []);
  }

  /// `Item Type`
  String get itemTypeLabel {
    return Intl.message('Item Type', name: 'itemTypeLabel', desc: '', args: []);
  }

  /// `Select type`
  String get selectTypeHint {
    return Intl.message(
      'Select type',
      name: 'selectTypeHint',
      desc: '',
      args: [],
    );
  }

  /// `Preparation Time (minutes)`
  String get preparationTimeMinutesLabel {
    return Intl.message(
      'Preparation Time (minutes)',
      name: 'preparationTimeMinutesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter minutes`
  String get enterMinutesHint {
    return Intl.message(
      'Enter minutes',
      name: 'enterMinutesHint',
      desc: '',
      args: [],
    );
  }

  /// `Select tag`
  String get selectTagHint {
    return Intl.message(
      'Select tag',
      name: 'selectTagHint',
      desc: '',
      args: [],
    );
  }

  /// `Attribute`
  String get attributeLabel {
    return Intl.message(
      'Attribute',
      name: 'attributeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Select attribute`
  String get selectAttributeHint {
    return Intl.message(
      'Select attribute',
      name: 'selectAttributeHint',
      desc: '',
      args: [],
    );
  }

  /// `Enter serial number`
  String get enterSerialNumberHint {
    return Intl.message(
      'Enter serial number',
      name: 'enterSerialNumberHint',
      desc: '',
      args: [],
    );
  }

  /// `Maximum Allowed Quantity`
  String get maxAllowedQuantityLabel {
    return Intl.message(
      'Maximum Allowed Quantity',
      name: 'maxAllowedQuantityLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter maximum allowed quantity`
  String get enterMaxQuantityHint {
    return Intl.message(
      'Enter maximum allowed quantity',
      name: 'enterMaxQuantityHint',
      desc: '',
      args: [],
    );
  }

  /// `Enter Price`
  String get enterPriceHint {
    return Intl.message(
      'Enter Price',
      name: 'enterPriceHint',
      desc: '',
      args: [],
    );
  }

  /// `Discount Price`
  String get discountPriceLabel {
    return Intl.message(
      'Discount Price',
      name: 'discountPriceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter Discount Price`
  String get enterDiscountPriceHint {
    return Intl.message(
      'Enter Discount Price',
      name: 'enterDiscountPriceHint',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get resetButton {
    return Intl.message('Reset', name: 'resetButton', desc: '', args: []);
  }

  /// `Submit`
  String get submitButton {
    return Intl.message('Submit', name: 'submitButton', desc: '', args: []);
  }

  /// `Add Menu`
  String get addMenuTitle {
    return Intl.message('Add Menu', name: 'addMenuTitle', desc: '', args: []);
  }

  /// `Item Name (English)`
  String get itemNameEnglishLabel {
    return Intl.message(
      'Item Name (English)',
      name: 'itemNameEnglishLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter item name`
  String get enterItemNameHint {
    return Intl.message(
      'Enter item name',
      name: 'enterItemNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Select Category`
  String get selectCategoryHint {
    return Intl.message(
      'Select Category',
      name: 'selectCategoryHint',
      desc: '',
      args: [],
    );
  }

  /// `Is Veg`
  String get isVegLabel {
    return Intl.message('Is Veg', name: 'isVegLabel', desc: '', args: []);
  }

  /// `Description (English)`
  String get descriptionEnglishLabel {
    return Intl.message(
      'Description (English)',
      name: 'descriptionEnglishLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter description`
  String get enterDescriptionHint {
    return Intl.message(
      'Enter description',
      name: 'enterDescriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `Item Image`
  String get itemImageLabel {
    return Intl.message(
      'Item Image',
      name: 'itemImageLabel',
      desc: '',
      args: [],
    );
  }

  /// `Upload image here`
  String get uploadImageHint {
    return Intl.message(
      'Upload image here',
      name: 'uploadImageHint',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yesLabel {
    return Intl.message('Yes', name: 'yesLabel', desc: '', args: []);
  }

  /// `No`
  String get noLabel {
    return Intl.message('No', name: 'noLabel', desc: '', args: []);
  }

  /// `Click to View`
  String get clickToView {
    return Intl.message(
      'Click to View',
      name: 'clickToView',
      desc: '',
      args: [],
    );
  }

  /// `Identity Proof Document`
  String get identityProofDocument {
    return Intl.message(
      'Identity Proof Document',
      name: 'identityProofDocument',
      desc: '',
      args: [],
    );
  }

  /// `Trade License`
  String get tradeLicense {
    return Intl.message(
      'Trade License',
      name: 'tradeLicense',
      desc: '',
      args: [],
    );
  }

  /// `Food Permit`
  String get foodPermit {
    return Intl.message('Food Permit', name: 'foodPermit', desc: '', args: []);
  }

  /// `Preparing Food`
  String get preparingFood {
    return Intl.message(
      'Preparing Food',
      name: 'preparingFood',
      desc: '',
      args: [],
    );
  }

  /// `Ongoing`
  String get ongoing {
    return Intl.message('Ongoing', name: 'ongoing', desc: '', args: []);
  }

  /// `Welcome to Saimpex Vendor!`
  String get welcomeToSaimpexVendor {
    return Intl.message(
      'Welcome to Saimpex Vendor!',
      name: 'welcomeToSaimpexVendor',
      desc: '',
      args: [],
    );
  }

  /// `Please sign-in to your account and start the adventure`
  String get pleaseSigninToYourAccountAndStartTheAdventure {
    return Intl.message(
      'Please sign-in to your account and start the adventure',
      name: 'pleaseSigninToYourAccountAndStartTheAdventure',
      desc: '',
      args: [],
    );
  }

  /// `User Name`
  String get userName {
    return Intl.message('User Name', name: 'userName', desc: '', args: []);
  }

  /// `Enter your username`
  String get enterYourUsername {
    return Intl.message(
      'Enter your username',
      name: 'enterYourUsername',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Enter your password`
  String get enterYourPassword {
    return Intl.message(
      'Enter your password',
      name: 'enterYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `ASSIGNED`
  String get assigned {
    return Intl.message('ASSIGNED', name: 'assigned', desc: '', args: []);
  }

  /// `REACHED RESTAURANT`
  String get reachedRestaurant {
    return Intl.message(
      'REACHED RESTAURANT',
      name: 'reachedRestaurant',
      desc: '',
      args: [],
    );
  }

  /// `PICKED UP`
  String get pickedUp {
    return Intl.message('PICKED UP', name: 'pickedUp', desc: '', args: []);
  }

  /// `DELIVERING`
  String get delivering {
    return Intl.message('DELIVERING', name: 'delivering', desc: '', args: []);
  }

  /// `Order Placed`
  String get orderPlaced {
    return Intl.message(
      'Order Placed',
      name: 'orderPlaced',
      desc: '',
      args: [],
    );
  }

  /// `Order successfully placed by`
  String get orderSuccessfullyPlacedBy {
    return Intl.message(
      'Order successfully placed by',
      name: 'orderSuccessfullyPlacedBy',
      desc: '',
      args: [],
    );
  }

  /// `Order Accepted`
  String get orderAccepted {
    return Intl.message(
      'Order Accepted',
      name: 'orderAccepted',
      desc: '',
      args: [],
    );
  }

  /// `Order Preparation Started`
  String get orderPreparationStarted {
    return Intl.message(
      'Order Preparation Started',
      name: 'orderPreparationStarted',
      desc: '',
      args: [],
    );
  }

  /// `Order Ready`
  String get orderReady {
    return Intl.message('Order Ready', name: 'orderReady', desc: '', args: []);
  }

  /// `Order Picked Up`
  String get orderPickedUp {
    return Intl.message(
      'Order Picked Up',
      name: 'orderPickedUp',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Started`
  String get deliveryStarted {
    return Intl.message(
      'Delivery Started',
      name: 'deliveryStarted',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Completed`
  String get deliveryCompleted {
    return Intl.message(
      'Delivery Completed',
      name: 'deliveryCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Delivery`
  String get delivery {
    return Intl.message('Delivery', name: 'delivery', desc: '', args: []);
  }

  /// `Self Pickup`
  String get selfPickup {
    return Intl.message('Self Pickup', name: 'selfPickup', desc: '', args: []);
  }

  /// `Complete Pickup`
  String get markSelfPickupCompleted {
    return Intl.message(
      'Complete Pickup',
      name: 'markSelfPickupCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to`
  String get welcomeTo {
    return Intl.message('Welcome to', name: 'welcomeTo', desc: '', args: []);
  }

  /// `No reviews found`
  String get noReviewsFound {
    return Intl.message(
      'No reviews found',
      name: 'noReviewsFound',
      desc: '',
      args: [],
    );
  }

  /// `Anonymous`
  String get anonymous {
    return Intl.message('Anonymous', name: 'anonymous', desc: '', args: []);
  }

  /// `No comment provided.`
  String get noCommentProvided {
    return Intl.message(
      'No comment provided.',
      name: 'noCommentProvided',
      desc: '',
      args: [],
    );
  }

  /// `No comment`
  String get noComment {
    return Intl.message('No comment', name: 'noComment', desc: '', args: []);
  }

  /// `Leave`
  String get leave {
    return Intl.message('Leave', name: 'leave', desc: '', args: []);
  }

  /// `No upcoming leaves found`
  String get noUpcomingLeavesFound {
    return Intl.message(
      'No upcoming leaves found',
      name: 'noUpcomingLeavesFound',
      desc: '',
      args: [],
    );
  }

  /// `No completed leaves found`
  String get noCompletedLeavesFound {
    return Intl.message(
      'No completed leaves found',
      name: 'noCompletedLeavesFound',
      desc: '',
      args: [],
    );
  }

  /// `BASKETS`
  String get baskets {
    return Intl.message('BASKETS', name: 'baskets', desc: '', args: []);
  }

  /// `Check for update`
  String get checkForUpdate {
    return Intl.message(
      'Check for update',
      name: 'checkForUpdate',
      desc: '',
      args: [],
    );
  }

  /// `No payouts yet`
  String get noPayoutsYet {
    return Intl.message(
      'No payouts yet',
      name: 'noPayoutsYet',
      desc: '',
      args: [],
    );
  }

  /// `Total Payout Balance`
  String get totalPayoutBalance {
    return Intl.message(
      'Total Payout Balance',
      name: 'totalPayoutBalance',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message('History', name: 'history', desc: '', args: []);
  }

  /// `Search amount or Transaction ID`
  String get searchAmountOrTransactionId {
    return Intl.message(
      'Search amount or Transaction ID',
      name: 'searchAmountOrTransactionId',
      desc: '',
      args: [],
    );
  }

  /// `My Store`
  String get myStore {
    return Intl.message('My Store', name: 'myStore', desc: '', args: []);
  }

  /// `No reports in this date range.`
  String get noReportsInThisDateRange {
    return Intl.message(
      'No reports in this date range.',
      name: 'noReportsInThisDateRange',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message('Download', name: 'download', desc: '', args: []);
  }

  /// `Please select from date and to date`
  String get pleaseSelectFromDateAndToDate {
    return Intl.message(
      'Please select from date and to date',
      name: 'pleaseSelectFromDateAndToDate',
      desc: '',
      args: [],
    );
  }

  /// `Redeemed Customers`
  String get redeemedCustomers {
    return Intl.message(
      'Redeemed Customers',
      name: 'redeemedCustomers',
      desc: '',
      args: [],
    );
  }

  /// `Search Name`
  String get searchName {
    return Intl.message('Search Name', name: 'searchName', desc: '', args: []);
  }

  /// `Store Reports`
  String get storeReports {
    return Intl.message(
      'Store Reports',
      name: 'storeReports',
      desc: '',
      args: [],
    );
  }

  /// `Blocked`
  String get blocked {
    return Intl.message('Blocked', name: 'blocked', desc: '', args: []);
  }

  /// `No baskets found`
  String get noBasketsFound {
    return Intl.message(
      'No baskets found',
      name: 'noBasketsFound',
      desc: '',
      args: [],
    );
  }

  /// `Go to Dashboard`
  String get goToDashboard {
    return Intl.message(
      'Go to Dashboard',
      name: 'goToDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Member`
  String get member {
    return Intl.message('Member', name: 'member', desc: '', args: []);
  }

  /// `Order Accepted successfully`
  String get orderAcceptedSuccessfully {
    return Intl.message(
      'Order Accepted successfully',
      name: 'orderAcceptedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message('Dashboard', name: 'dashboard', desc: '', args: []);
  }

  /// `Total Orders`
  String get totalOrders {
    return Intl.message(
      'Total Orders',
      name: 'totalOrders',
      desc: '',
      args: [],
    );
  }

  /// `Total Revenue`
  String get totalRevenue {
    return Intl.message(
      'Total Revenue',
      name: 'totalRevenue',
      desc: '',
      args: [],
    );
  }

  /// `No popular items found`
  String get noPopularItemsFound {
    return Intl.message(
      'No popular items found',
      name: 'noPopularItemsFound',
      desc: '',
      args: [],
    );
  }

  /// `Orders`
  String get orders {
    return Intl.message('Orders', name: 'orders', desc: '', args: []);
  }

  /// `Guest Login`
  String get guestLogin {
    return Intl.message('Guest Login', name: 'guestLogin', desc: '', args: []);
  }

  /// `BALANCE AFTER PAYOUT`
  String get balanceAfterPayout {
    return Intl.message(
      'BALANCE AFTER PAYOUT',
      name: 'balanceAfterPayout',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get amount {
    return Intl.message('Amount', name: 'amount', desc: '', args: []);
  }

  /// `Discount`
  String get discount {
    return Intl.message('Discount', name: 'discount', desc: '', args: []);
  }

  /// `Earnings`
  String get earnings {
    return Intl.message('Earnings', name: 'earnings', desc: '', args: []);
  }

  /// `Commission`
  String get commission {
    return Intl.message('Commission', name: 'commission', desc: '', args: []);
  }

  /// `Payment Method`
  String get paymentMethod {
    return Intl.message(
      'Payment Method',
      name: 'paymentMethod',
      desc: '',
      args: [],
    );
  }

  /// `Cash`
  String get cash {
    return Intl.message('Cash', name: 'cash', desc: '', args: []);
  }

  /// `Sales Report`
  String get salesReport {
    return Intl.message(
      'Sales Report',
      name: 'salesReport',
      desc: '',
      args: [],
    );
  }

  /// `View Reports`
  String get viewReports {
    return Intl.message(
      'View Reports',
      name: 'viewReports',
      desc: '',
      args: [],
    );
  }

  /// `Edit Item`
  String get editItem {
    return Intl.message('Edit Item', name: 'editItem', desc: '', args: []);
  }

  /// `Item Type`
  String get itemType {
    return Intl.message('Item Type', name: 'itemType', desc: '', args: []);
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `Preparation Time (minutes)`
  String get preparationTimeMinutes {
    return Intl.message(
      'Preparation Time (minutes)',
      name: 'preparationTimeMinutes',
      desc: '',
      args: [],
    );
  }

  /// `Enter minutes`
  String get enterMinutes {
    return Intl.message(
      'Enter minutes',
      name: 'enterMinutes',
      desc: '',
      args: [],
    );
  }

  /// `Tags`
  String get tags {
    return Intl.message('Tags', name: 'tags', desc: '', args: []);
  }

  /// `Attribute`
  String get attribute {
    return Intl.message('Attribute', name: 'attribute', desc: '', args: []);
  }

  /// `Serial Number`
  String get serialNumber {
    return Intl.message(
      'Serial Number',
      name: 'serialNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter serial number`
  String get enterSerialNumber {
    return Intl.message(
      'Enter serial number',
      name: 'enterSerialNumber',
      desc: '',
      args: [],
    );
  }

  /// `Maximum Allowed Quantity`
  String get maximumAllowedQuantity {
    return Intl.message(
      'Maximum Allowed Quantity',
      name: 'maximumAllowedQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Enter maximum allowed quantity`
  String get enterMaximumAllowedQuantity {
    return Intl.message(
      'Enter maximum allowed quantity',
      name: 'enterMaximumAllowedQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get price {
    return Intl.message('Price', name: 'price', desc: '', args: []);
  }

  /// `Enter Price`
  String get enterPrice {
    return Intl.message('Enter Price', name: 'enterPrice', desc: '', args: []);
  }

  /// `Discount Price`
  String get discountPrice {
    return Intl.message(
      'Discount Price',
      name: 'discountPrice',
      desc: '',
      args: [],
    );
  }

  /// `Enter Discount Price`
  String get enterDiscountPrice {
    return Intl.message(
      'Enter Discount Price',
      name: 'enterDiscountPrice',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message('Reset', name: 'reset', desc: '', args: []);
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Edit Menu`
  String get editMenu {
    return Intl.message('Edit Menu', name: 'editMenu', desc: '', args: []);
  }

  /// `Item Name (English)`
  String get itemNameEnglish {
    return Intl.message(
      'Item Name (English)',
      name: 'itemNameEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Zesty Chicken Burger`
  String get zestyChickenBurger {
    return Intl.message(
      'Zesty Chicken Burger',
      name: 'zestyChickenBurger',
      desc: '',
      args: [],
    );
  }

  /// `Item Name (Arabic)`
  String get itemNameArabic {
    return Intl.message(
      'Item Name (Arabic)',
      name: 'itemNameArabic',
      desc: '',
      args: [],
    );
  }

  /// `Item Name (French)`
  String get itemNameFrench {
    return Intl.message(
      'Item Name (French)',
      name: 'itemNameFrench',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message('Category', name: 'category', desc: '', args: []);
  }

  /// `Is Veg`
  String get isVeg {
    return Intl.message('Is Veg', name: 'isVeg', desc: '', args: []);
  }

  /// `Description (English)`
  String get descriptionEnglish {
    return Intl.message(
      'Description (English)',
      name: 'descriptionEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Enter description in English...`
  String get enterDescriptionInEnglish {
    return Intl.message(
      'Enter description in English...',
      name: 'enterDescriptionInEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Description (Arabic)`
  String get descriptionArabic {
    return Intl.message(
      'Description (Arabic)',
      name: 'descriptionArabic',
      desc: '',
      args: [],
    );
  }

  /// `Description (French)`
  String get descriptionFrench {
    return Intl.message(
      'Description (French)',
      name: 'descriptionFrench',
      desc: '',
      args: [],
    );
  }

  /// `Item Image`
  String get itemImage {
    return Intl.message('Item Image', name: 'itemImage', desc: '', args: []);
  }

  /// `No leave history found.`
  String get noLeaveHistoryFound {
    return Intl.message(
      'No leave history found.',
      name: 'noLeaveHistoryFound',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Leave`
  String get cancelLeave {
    return Intl.message(
      'Cancel Leave',
      name: 'cancelLeave',
      desc: '',
      args: [],
    );
  }

  /// `Unavailable`
  String get unavailable {
    return Intl.message('Unavailable', name: 'unavailable', desc: '', args: []);
  }

  /// `Please select an .xlsx file only`
  String get pleaseSelectAnXlsxFileOnly {
    return Intl.message(
      'Please select an .xlsx file only',
      name: 'pleaseSelectAnXlsxFileOnly',
      desc: '',
      args: [],
    );
  }

  /// `Could not access the selected file`
  String get couldNotAccessTheSelectedFile {
    return Intl.message(
      'Could not access the selected file',
      name: 'couldNotAccessTheSelectedFile',
      desc: '',
      args: [],
    );
  }

  /// `Template preview`
  String get templatePreview {
    return Intl.message(
      'Template preview',
      name: 'templatePreview',
      desc: '',
      args: [],
    );
  }

  /// `Open with another app`
  String get openWithAnotherApp {
    return Intl.message(
      'Open with another app',
      name: 'openWithAnotherApp',
      desc: '',
      args: [],
    );
  }

  /// `Upload image here`
  String get uploadImageHere {
    return Intl.message(
      'Upload image here',
      name: 'uploadImageHere',
      desc: '',
      args: [],
    );
  }

  /// `All Categories`
  String get allCategories {
    return Intl.message(
      'All Categories',
      name: 'allCategories',
      desc: '',
      args: [],
    );
  }

  /// `Instructions`
  String get instructions {
    return Intl.message(
      'Instructions',
      name: 'instructions',
      desc: '',
      args: [],
    );
  }

  /// `Download Template`
  String get downloadTemplate {
    return Intl.message(
      'Download Template',
      name: 'downloadTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Download the template file and fill it with proper data.`
  String get downloadTheTemplateFileAndFillItWithProperData {
    return Intl.message(
      'Download the template file and fill it with proper data.',
      name: 'downloadTheTemplateFileAndFillItWithProperData',
      desc: '',
      args: [],
    );
  }

  /// `Select Category`
  String get selectCategory {
    return Intl.message(
      'Select Category',
      name: 'selectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Once you have downloaded and filled the template, select the corresponding category and upload the file.`
  String get onceYouHaveDownloadedAndFilledTheTemplateSelectThe {
    return Intl.message(
      'Once you have downloaded and filled the template, select the corresponding category and upload the file.',
      name: 'onceYouHaveDownloadedAndFilledTheTemplateSelectThe',
      desc: '',
      args: [],
    );
  }

  /// `Attributes Reference`
  String get attributesReference {
    return Intl.message(
      'Attributes Reference',
      name: 'attributesReference',
      desc: '',
      args: [],
    );
  }

  /// `After Attributes reference, you can edit the attributes list below and use the attribute ID in the attribute_id column along with its corresponding value.`
  String get afterAttributesReferenceYouCanEditTheAttributesListBelow {
    return Intl.message(
      'After Attributes reference, you can edit the attributes list below and use the attribute ID in the attribute_id column along with its corresponding value.',
      name: 'afterAttributesReferenceYouCanEditTheAttributesListBelow',
      desc: '',
      args: [],
    );
  }

  /// `Post-Upload Editing`
  String get postuploadEditing {
    return Intl.message(
      'Post-Upload Editing',
      name: 'postuploadEditing',
      desc: '',
      args: [],
    );
  }

  /// `After uploading, you need to edit the items individually to set images and variations.`
  String get afterUploadingYouNeedToEditTheItemsIndividuallyTo {
    return Intl.message(
      'After uploading, you need to edit the items individually to set images and variations.',
      name: 'afterUploadingYouNeedToEditTheItemsIndividuallyTo',
      desc: '',
      args: [],
    );
  }

  /// `Image File Naming`
  String get imageFileNaming {
    return Intl.message(
      'Image File Naming',
      name: 'imageFileNaming',
      desc: '',
      args: [],
    );
  }

  /// `Image file names must start with restaurant/menus/{filename.extension} (e.g., restaurant/menus/pizza.jpg).`
  String
  get imageFileNamesMustStartWithRestaurantmenusfilenameextensionEgRestaurantmenuspizzajpg {
    return Intl.message(
      'Image file names must start with restaurant/menus/{filename.extension} (e.g., restaurant/menus/pizza.jpg).',
      name: 'imageFileNamesMustStartWithRestaurantmenusfilenameextensionEgRestaurantmenuspizzajpg',
      desc: '',
      args: [],
    );
  }

  /// `Available Attributes`
  String get availableAttributes {
    return Intl.message(
      'Available Attributes',
      name: 'availableAttributes',
      desc: '',
      args: [],
    );
  }

  /// `e.g. Annual vacation, renovation...`
  String get egAnnualVacationRenovation {
    return Intl.message(
      'e.g. Annual vacation, renovation...',
      name: 'egAnnualVacationRenovation',
      desc: '',
      args: [],
    );
  }

  /// `Invalid itemId: ${widget.itemId}`
  String get invalidItemidWidgetitemid {
    return Intl.message(
      'Invalid itemId: \${widget.itemId}',
      name: 'invalidItemidWidgetitemid',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message('Details', name: 'details', desc: '', args: []);
  }

  /// `Upload Drive`
  String get uploadDrive {
    return Intl.message(
      'Upload Drive',
      name: 'uploadDrive',
      desc: '',
      args: [],
    );
  }

  /// `Menu Information`
  String get menuInformation {
    return Intl.message(
      'Menu Information',
      name: 'menuInformation',
      desc: '',
      args: [],
    );
  }

  /// `MENU NAME`
  String get menuName {
    return Intl.message('MENU NAME', name: 'menuName', desc: '', args: []);
  }

  /// `PREPARATION TIME`
  String get preparationTime {
    return Intl.message(
      'PREPARATION TIME',
      name: 'preparationTime',
      desc: '',
      args: [],
    );
  }

  /// `CREATED DATE`
  String get createdDate {
    return Intl.message(
      'CREATED DATE',
      name: 'createdDate',
      desc: '',
      args: [],
    );
  }

  /// `UPDATED DATE`
  String get updatedDate {
    return Intl.message(
      'UPDATED DATE',
      name: 'updatedDate',
      desc: '',
      args: [],
    );
  }

  /// `DESCRIPTION`
  String get description {
    return Intl.message('DESCRIPTION', name: 'description', desc: '', args: []);
  }

  /// `No description available`
  String get noDescriptionAvailable {
    return Intl.message(
      'No description available',
      name: 'noDescriptionAvailable',
      desc: '',
      args: [],
    );
  }

  /// `AVAILABLE THE`
  String get availableThe {
    return Intl.message(
      'AVAILABLE THE',
      name: 'availableThe',
      desc: '',
      args: [],
    );
  }

  /// `SALES & PERFORMANCE`
  String get salesPerformance {
    return Intl.message(
      'SALES & PERFORMANCE',
      name: 'salesPerformance',
      desc: '',
      args: [],
    );
  }

  /// `ITEM ORDERS`
  String get itemOrders {
    return Intl.message('ITEM ORDERS', name: 'itemOrders', desc: '', args: []);
  }

  /// `Revenue`
  String get revenue {
    return Intl.message('Revenue', name: 'revenue', desc: '', args: []);
  }

  /// `Average Rating`
  String get averageRating {
    return Intl.message(
      'Average Rating',
      name: 'averageRating',
      desc: '',
      args: [],
    );
  }

  /// `Total Reviews`
  String get totalReviews {
    return Intl.message(
      'Total Reviews',
      name: 'totalReviews',
      desc: '',
      args: [],
    );
  }

  /// `Last Purchase`
  String get lastPurchase {
    return Intl.message(
      'Last Purchase',
      name: 'lastPurchase',
      desc: '',
      args: [],
    );
  }

  /// `ITEMS TOTAL`
  String get itemsTotal {
    return Intl.message('ITEMS TOTAL', name: 'itemsTotal', desc: '', args: []);
  }

  /// `Statistics`
  String get statistics {
    return Intl.message('Statistics', name: 'statistics', desc: '', args: []);
  }

  /// `Total Ratings`
  String get totalRatings {
    return Intl.message(
      'Total Ratings',
      name: 'totalRatings',
      desc: '',
      args: [],
    );
  }

  /// `STORE DETAILS`
  String get storeDetails {
    return Intl.message(
      'STORE DETAILS',
      name: 'storeDetails',
      desc: '',
      args: [],
    );
  }

  /// `ABOUT THE STORE`
  String get aboutTheStore {
    return Intl.message(
      'ABOUT THE STORE',
      name: 'aboutTheStore',
      desc: '',
      args: [],
    );
  }

  /// `No Redeemed Customers Found`
  String get noRedeemedCustomersFound {
    return Intl.message(
      'No Redeemed Customers Found',
      name: 'noRedeemedCustomersFound',
      desc: '',
      args: [],
    );
  }

  /// `Coupons`
  String get coupons {
    return Intl.message('Coupons', name: 'coupons', desc: '', args: []);
  }

  /// `Add Coupon`
  String get addCoupon {
    return Intl.message('Add Coupon', name: 'addCoupon', desc: '', args: []);
  }

  /// `Update Coupon`
  String get updateCoupon {
    return Intl.message(
      'Update Coupon',
      name: 'updateCoupon',
      desc: '',
      args: [],
    );
  }

  /// `Search Coupon`
  String get searchCoupon {
    return Intl.message(
      'Search Coupon',
      name: 'searchCoupon',
      desc: '',
      args: [],
    );
  }

  /// `No Coupons Found`
  String get noCouponsFound {
    return Intl.message(
      'No Coupons Found',
      name: 'noCouponsFound',
      desc: '',
      args: [],
    );
  }

  /// `CODE`
  String get codeLabel {
    return Intl.message('CODE', name: 'codeLabel', desc: '', args: []);
  }

  /// `DISCOUNT`
  String get discountLabel {
    return Intl.message('DISCOUNT', name: 'discountLabel', desc: '', args: []);
  }

  /// `COUNT`
  String get countLabel {
    return Intl.message('COUNT', name: 'countLabel', desc: '', args: []);
  }

  /// `VALID UPTO`
  String get validUptoLabel {
    return Intl.message(
      'VALID UPTO',
      name: 'validUptoLabel',
      desc: '',
      args: [],
    );
  }

  /// `CREATED ON`
  String get createdOnLabel {
    return Intl.message(
      'CREATED ON',
      name: 'createdOnLabel',
      desc: '',
      args: [],
    );
  }

  /// `UPDATED ON`
  String get updatedOnLabel {
    return Intl.message(
      'UPDATED ON',
      name: 'updatedOnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Update Coupon Status`
  String get updateCouponStatus {
    return Intl.message(
      'Update Coupon Status',
      name: 'updateCouponStatus',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this Coupon?`
  String get areYouSureYouWantToDeleteThisCoupon {
    return Intl.message(
      'Are you sure you want to delete this Coupon?',
      name: 'areYouSureYouWantToDeleteThisCoupon',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to block this Coupon?`
  String get areYouSureYouWantToBlockThisCoupon {
    return Intl.message(
      'Are you sure you want to block this Coupon?',
      name: 'areYouSureYouWantToBlockThisCoupon',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to activate this Coupon?`
  String get areYouSureYouWantToActivateThisCoupon {
    return Intl.message(
      'Are you sure you want to activate this Coupon?',
      name: 'areYouSureYouWantToActivateThisCoupon',
      desc: '',
      args: [],
    );
  }

  /// `Coupon Name`
  String get couponName {
    return Intl.message('Coupon Name', name: 'couponName', desc: '', args: []);
  }

  /// `Enter coupon name`
  String get enterCouponName {
    return Intl.message(
      'Enter coupon name',
      name: 'enterCouponName',
      desc: '',
      args: [],
    );
  }

  /// `Coupon Code`
  String get couponCode {
    return Intl.message('Coupon Code', name: 'couponCode', desc: '', args: []);
  }

  /// `Enter coupon code`
  String get enterCouponCode {
    return Intl.message(
      'Enter coupon code',
      name: 'enterCouponCode',
      desc: '',
      args: [],
    );
  }

  /// `Coupon Type`
  String get couponType {
    return Intl.message('Coupon Type', name: 'couponType', desc: '', args: []);
  }

  /// `Select`
  String get select {
    return Intl.message('Select', name: 'select', desc: '', args: []);
  }

  /// `Percentage`
  String get percentage {
    return Intl.message('Percentage', name: 'percentage', desc: '', args: []);
  }

  /// `Enter discount`
  String get enterDiscount {
    return Intl.message(
      'Enter discount',
      name: 'enterDiscount',
      desc: '',
      args: [],
    );
  }

  /// `Enter count`
  String get enterCount {
    return Intl.message('Enter count', name: 'enterCount', desc: '', args: []);
  }

  /// `Please select coupon type`
  String get pleaseSelectCouponType {
    return Intl.message(
      'Please select coupon type',
      name: 'pleaseSelectCouponType',
      desc: '',
      args: [],
    );
  }

  /// `Order Amount`
  String get orderAmount {
    return Intl.message(
      'Order Amount',
      name: 'orderAmount',
      desc: '',
      args: [],
    );
  }

  /// `Payouts`
  String get payouts {
    return Intl.message('Payouts', name: 'payouts', desc: '', args: []);
  }

  /// `Credited`
  String get credited {
    return Intl.message('Credited', name: 'credited', desc: '', args: []);
  }

  /// `Pending Order Balance`
  String get pendingOrderBalance {
    return Intl.message(
      'Pending Order Balance',
      name: 'pendingOrderBalance',
      desc: '',
      args: [],
    );
  }

  /// `Total Sale Amount`
  String get totalSaleAmount {
    return Intl.message(
      'Total Sale Amount',
      name: 'totalSaleAmount',
      desc: '',
      args: [],
    );
  }

  /// `Available Order Balance`
  String get availableOrderBalance {
    return Intl.message(
      'Available Order Balance',
      name: 'availableOrderBalance',
      desc: '',
      args: [],
    );
  }

  /// `Available Payout Balance`
  String get availablePayoutBalance {
    return Intl.message(
      'Available Payout Balance',
      name: 'availablePayoutBalance',
      desc: '',
      args: [],
    );
  }

  /// `Total Payout Received`
  String get totalPayoutReceived {
    return Intl.message(
      'Total Payout Received',
      name: 'totalPayoutReceived',
      desc: '',
      args: [],
    );
  }

  /// `Payment ID`
  String get paymentId {
    return Intl.message('Payment ID', name: 'paymentId', desc: '', args: []);
  }

  /// `View Payment Proof`
  String get viewPaymentProof {
    return Intl.message(
      'View Payment Proof',
      name: 'viewPaymentProof',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get notes {
    return Intl.message('Notes', name: 'notes', desc: '', args: []);
  }

  /// `Available`
  String get available {
    return Intl.message('Available', name: 'available', desc: '', args: []);
  }

  /// `Working Hours`
  String get workHours {
    return Intl.message('Working Hours', name: 'workHours', desc: '', args: []);
  }

  /// `Restaurant Status`
  String get restaurantStatus {
    return Intl.message(
      'Restaurant Status',
      name: 'restaurantStatus',
      desc: '',
      args: [],
    );
  }

  /// `Busy`
  String get busy {
    return Intl.message('Busy', name: 'busy', desc: '', args: []);
  }

  /// `Store ID`
  String get storeId {
    return Intl.message('Store ID', name: 'storeId', desc: '', args: []);
  }

  /// `Veg`
  String get veg {
    return Intl.message('Veg', name: 'veg', desc: '', args: []);
  }

  /// `Non-Veg`
  String get nonVeg {
    return Intl.message('Non-Veg', name: 'nonVeg', desc: '', args: []);
  }

  /// `Item updated successfully`
  String get itemUpdatedSuccessfully {
    return Intl.message(
      'Item updated successfully',
      name: 'itemUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update item`
  String get failedToUpdateItem {
    return Intl.message(
      'Failed to update item',
      name: 'failedToUpdateItem',
      desc: '',
      args: [],
    );
  }

  /// `Accept Booking`
  String get cleaningAcceptBooking {
    return Intl.message(
      'Accept Booking',
      name: 'cleaningAcceptBooking',
      desc: '',
      args: [],
    );
  }

  /// `Accepting bookings`
  String get cleaningAcceptingBookings {
    return Intl.message(
      'Accepting bookings',
      name: 'cleaningAcceptingBookings',
      desc: '',
      args: [],
    );
  }

  /// `Add Add-on`
  String get cleaningAddAddon {
    return Intl.message(
      'Add Add-on',
      name: 'cleaningAddAddon',
      desc: '',
      args: [],
    );
  }

  /// `+ Add Add-on`
  String get cleaningAddAddonButton {
    return Intl.message(
      '+ Add Add-on',
      name: 'cleaningAddAddonButton',
      desc: '',
      args: [],
    );
  }

  /// `Add Service`
  String get cleaningAddService {
    return Intl.message(
      'Add Service',
      name: 'cleaningAddService',
      desc: '',
      args: [],
    );
  }

  /// `+ Add Service`
  String get cleaningAddServiceButton {
    return Intl.message(
      '+ Add Service',
      name: 'cleaningAddServiceButton',
      desc: '',
      args: [],
    );
  }

  /// `Add Space`
  String get cleaningAddSpace {
    return Intl.message(
      'Add Space',
      name: 'cleaningAddSpace',
      desc: '',
      args: [],
    );
  }

  /// `+ Add Space`
  String get cleaningAddSpaceButton {
    return Intl.message(
      '+ Add Space',
      name: 'cleaningAddSpaceButton',
      desc: '',
      args: [],
    );
  }

  /// `Add-on Name`
  String get cleaningAddonName {
    return Intl.message(
      'Add-on Name',
      name: 'cleaningAddonName',
      desc: '',
      args: [],
    );
  }

  /// `e.g. Fridge Cleaning, Oven Cleaning`
  String get cleaningAddonNameHint {
    return Intl.message(
      'e.g. Fridge Cleaning, Oven Cleaning',
      name: 'cleaningAddonNameHint',
      desc: '',
      args: [],
    );
  }

  /// `ADD-ON SERVICES`
  String get cleaningAddonServicesHeader {
    return Intl.message(
      'ADD-ON SERVICES',
      name: 'cleaningAddonServicesHeader',
      desc: '',
      args: [],
    );
  }

  /// `Apartment`
  String get cleaningApartment {
    return Intl.message(
      'Apartment',
      name: 'cleaningApartment',
      desc: '',
      args: [],
    );
  }

  /// `BASIC INFORMATION`
  String get cleaningBasicInformationHeader {
    return Intl.message(
      'BASIC INFORMATION',
      name: 'cleaningBasicInformationHeader',
      desc: '',
      args: [],
    );
  }

  /// `Booking Details`
  String get cleaningBookingDetails {
    return Intl.message(
      'Booking Details',
      name: 'cleaningBookingDetails',
      desc: '',
      args: [],
    );
  }

  /// `Bookings`
  String get cleaningBookings {
    return Intl.message(
      'Bookings',
      name: 'cleaningBookings',
      desc: '',
      args: [],
    );
  }

  /// `BOOKINGS`
  String get cleaningBookingsHeader {
    return Intl.message(
      'BOOKINGS',
      name: 'cleaningBookingsHeader',
      desc: '',
      args: [],
    );
  }

  /// `Business`
  String get cleaningBusinessSection {
    return Intl.message(
      'Business',
      name: 'cleaningBusinessSection',
      desc: '',
      args: [],
    );
  }

  /// `Business settings`
  String get cleaningBusinessSettings {
    return Intl.message(
      'Business settings',
      name: 'cleaningBusinessSettings',
      desc: '',
      args: [],
    );
  }

  /// `Change Image`
  String get cleaningChangeImage {
    return Intl.message(
      'Change Image',
      name: 'cleaningChangeImage',
      desc: '',
      args: [],
    );
  }

  /// `Cleaning Products`
  String get cleaningCleaningProducts {
    return Intl.message(
      'Cleaning Products',
      name: 'cleaningCleaningProducts',
      desc: '',
      args: [],
    );
  }

  /// `CLEANING PRODUCTS`
  String get cleaningCleaningProductsHeader {
    return Intl.message(
      'CLEANING PRODUCTS',
      name: 'cleaningCleaningProductsHeader',
      desc: '',
      args: [],
    );
  }

  /// `Closed`
  String get cleaningClosedStatus {
    return Intl.message(
      'Closed',
      name: 'cleaningClosedStatus',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get cleaningCompleted {
    return Intl.message(
      'Completed',
      name: 'cleaningCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Reject`
  String get cleaningConfirmReject {
    return Intl.message(
      'Confirm Reject',
      name: 'cleaningConfirmReject',
      desc: '',
      args: [],
    );
  }

  /// `CUSTOMER`
  String get cleaningCustomerHeader {
    return Intl.message(
      'CUSTOMER',
      name: 'cleaningCustomerHeader',
      desc: '',
      args: [],
    );
  }

  /// `Customer provides products`
  String get cleaningCustomerProvidesProducts {
    return Intl.message(
      'Customer provides products',
      name: 'cleaningCustomerProvidesProducts',
      desc: '',
      args: [],
    );
  }

  /// `Customer brings their own detergents, mop, and cleaning cloths.`
  String get cleaningCustomerProvidesProductsDesc {
    return Intl.message(
      'Customer brings their own detergents, mop, and cleaning cloths.',
      name: 'cleaningCustomerProvidesProductsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your account? This action cannot be undone.`
  String get cleaningDeleteAccountConfirm {
    return Intl.message(
      'Are you sure you want to delete your account? This action cannot be undone.',
      name: 'cleaningDeleteAccountConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Edit Add-on`
  String get cleaningEditAddon {
    return Intl.message(
      'Edit Add-on',
      name: 'cleaningEditAddon',
      desc: '',
      args: [],
    );
  }

  /// `Edit Service`
  String get cleaningEditService {
    return Intl.message(
      'Edit Service',
      name: 'cleaningEditService',
      desc: '',
      args: [],
    );
  }

  /// `Edit Space`
  String get cleaningEditSpace {
    return Intl.message(
      'Edit Space',
      name: 'cleaningEditSpace',
      desc: '',
      args: [],
    );
  }

  /// `Enter Description`
  String get cleaningEnterDescription {
    return Intl.message(
      'Enter Description',
      name: 'cleaningEnterDescription',
      desc: '',
      args: [],
    );
  }

  /// `Enter service type`
  String get cleaningEnterServiceType {
    return Intl.message(
      'Enter service type',
      name: 'cleaningEnterServiceType',
      desc: '',
      args: [],
    );
  }

  /// `Enter the Price`
  String get cleaningEnterThePrice {
    return Intl.message(
      'Enter the Price',
      name: 'cleaningEnterThePrice',
      desc: '',
      args: [],
    );
  }

  /// `I provide the products`
  String get cleaningIProvideProducts {
    return Intl.message(
      'I provide the products',
      name: 'cleaningIProvideProducts',
      desc: '',
      args: [],
    );
  }

  /// `Your team brings professional cleaning detergents, vacuums & cloths.`
  String get cleaningIProvideProductsDesc {
    return Intl.message(
      'Your team brings professional cleaning detergents, vacuums & cloths.',
      name: 'cleaningIProvideProductsDesc',
      desc: '',
      args: [],
    );
  }

  /// `PNG, JPG up to 5MB`
  String get cleaningImageFormatsHint {
    return Intl.message(
      'PNG, JPG up to 5MB',
      name: 'cleaningImageFormatsHint',
      desc: '',
      args: [],
    );
  }

  /// `In Progress`
  String get cleaningInProgress {
    return Intl.message(
      'In Progress',
      name: 'cleaningInProgress',
      desc: '',
      args: [],
    );
  }

  /// `ISSUES COVERED`
  String get cleaningIssuesCoveredHeader {
    return Intl.message(
      'ISSUES COVERED',
      name: 'cleaningIssuesCoveredHeader',
      desc: '',
      args: [],
    );
  }

  /// `Just now`
  String get cleaningJustNow {
    return Intl.message(
      'Just now',
      name: 'cleaningJustNow',
      desc: '',
      args: [],
    );
  }

  /// `Arabic`
  String get cleaningLanguageArabic {
    return Intl.message(
      'Arabic',
      name: 'cleaningLanguageArabic',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get cleaningLanguageEnglish {
    return Intl.message(
      'English',
      name: 'cleaningLanguageEnglish',
      desc: '',
      args: [],
    );
  }

  /// `French`
  String get cleaningLanguageFrench {
    return Intl.message(
      'French',
      name: 'cleaningLanguageFrench',
      desc: '',
      args: [],
    );
  }

  /// `MAKE IT EXTRA CLEAN`
  String get cleaningMakeItExtraCleanHeader {
    return Intl.message(
      'MAKE IT EXTRA CLEAN',
      name: 'cleaningMakeItExtraCleanHeader',
      desc: '',
      args: [],
    );
  }

  /// `Mark as Completed`
  String get cleaningMarkAsCompleted {
    return Intl.message(
      'Mark as Completed',
      name: 'cleaningMarkAsCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get cleaningMessages {
    return Intl.message(
      'Messages',
      name: 'cleaningMessages',
      desc: '',
      args: [],
    );
  }

  /// `My Services`
  String get cleaningMyServices {
    return Intl.message(
      'My Services',
      name: 'cleaningMyServices',
      desc: '',
      args: [],
    );
  }

  /// `New Bookings`
  String get cleaningNewBookings {
    return Intl.message(
      'New Bookings',
      name: 'cleaningNewBookings',
      desc: '',
      args: [],
    );
  }

  /// `No bookings here`
  String get cleaningNoBookingsHere {
    return Intl.message(
      'No bookings here',
      name: 'cleaningNoBookingsHere',
      desc: '',
      args: [],
    );
  }

  /// `No messages found`
  String get cleaningNoMessagesFound {
    return Intl.message(
      'No messages found',
      name: 'cleaningNoMessagesFound',
      desc: '',
      args: [],
    );
  }

  /// `No services found`
  String get cleaningNoServicesFound {
    return Intl.message(
      'No services found',
      name: 'cleaningNoServicesFound',
      desc: '',
      args: [],
    );
  }

  /// `Not accepting`
  String get cleaningNotAccepting {
    return Intl.message(
      'Not accepting',
      name: 'cleaningNotAccepting',
      desc: '',
      args: [],
    );
  }

  /// `Offline`
  String get cleaningOffline {
    return Intl.message('Offline', name: 'cleaningOffline', desc: '', args: []);
  }

  /// `Online`
  String get cleaningOnline {
    return Intl.message('Online', name: 'cleaningOnline', desc: '', args: []);
  }

  /// `Open`
  String get cleaningOpenStatus {
    return Intl.message('Open', name: 'cleaningOpenStatus', desc: '', args: []);
  }

  /// `Other Reason`
  String get cleaningOtherReason {
    return Intl.message(
      'Other Reason',
      name: 'cleaningOtherReason',
      desc: '',
      args: [],
    );
  }

  /// `Ants`
  String get cleaningPestAnts {
    return Intl.message('Ants', name: 'cleaningPestAnts', desc: '', args: []);
  }

  /// `Bed Bugs`
  String get cleaningPestBedBugs {
    return Intl.message(
      'Bed Bugs',
      name: 'cleaningPestBedBugs',
      desc: '',
      args: [],
    );
  }

  /// `Cockroaches`
  String get cleaningPestCockroaches {
    return Intl.message(
      'Cockroaches',
      name: 'cleaningPestCockroaches',
      desc: '',
      args: [],
    );
  }

  /// `Flies`
  String get cleaningPestFlies {
    return Intl.message('Flies', name: 'cleaningPestFlies', desc: '', args: []);
  }

  /// `General\nSanitization`
  String get cleaningPestGeneralSanitization {
    return Intl.message(
      'General\nSanitization',
      name: 'cleaningPestGeneralSanitization',
      desc: '',
      args: [],
    );
  }

  /// `Mosquitoes`
  String get cleaningPestMosquitoes {
    return Intl.message(
      'Mosquitoes',
      name: 'cleaningPestMosquitoes',
      desc: '',
      args: [],
    );
  }

  /// `Other Pests`
  String get cleaningPestOtherPests {
    return Intl.message(
      'Other Pests',
      name: 'cleaningPestOtherPests',
      desc: '',
      args: [],
    );
  }

  /// `Rodents`
  String get cleaningPestRodents {
    return Intl.message(
      'Rodents',
      name: 'cleaningPestRodents',
      desc: '',
      args: [],
    );
  }

  /// `Termites`
  String get cleaningPestTermites {
    return Intl.message(
      'Termites',
      name: 'cleaningPestTermites',
      desc: '',
      args: [],
    );
  }

  /// `Product Supply Fee`
  String get cleaningProductSupplyFee {
    return Intl.message(
      'Product Supply Fee',
      name: 'cleaningProductSupplyFee',
      desc: '',
      args: [],
    );
  }

  /// `Cleaning products will be provided by the service provider`
  String get cleaningProductsProvidedByProvider {
    return Intl.message(
      'Cleaning products will be provided by the service provider',
      name: 'cleaningProductsProvidedByProvider',
      desc: '',
      args: [],
    );
  }

  /// `PROPERTY TYPES`
  String get cleaningPropertyTypesHeader {
    return Intl.message(
      'PROPERTY TYPES',
      name: 'cleaningPropertyTypesHeader',
      desc: '',
      args: [],
    );
  }

  /// `Provided by SAIMPEX`
  String get cleaningProvidedBySaimpex {
    return Intl.message(
      'Provided by SAIMPEX',
      name: 'cleaningProvidedBySaimpex',
      desc: '',
      args: [],
    );
  }

  /// `Provider will provide products`
  String get cleaningProviderWillProvideProducts {
    return Intl.message(
      'Provider will provide products',
      name: 'cleaningProviderWillProvideProducts',
      desc: '',
      args: [],
    );
  }

  /// `Reason / Description`
  String get cleaningReasonDescription {
    return Intl.message(
      'Reason / Description',
      name: 'cleaningReasonDescription',
      desc: '',
      args: [],
    );
  }

  /// `Reject Booking`
  String get cleaningRejectBooking {
    return Intl.message(
      'Reject Booking',
      name: 'cleaningRejectBooking',
      desc: '',
      args: [],
    );
  }

  /// `No cleaner available`
  String get cleaningRejectReasonNoCleaner {
    return Intl.message(
      'No cleaner available',
      name: 'cleaningRejectReasonNoCleaner',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get cleaningRejectReasonOther {
    return Intl.message(
      'Other',
      name: 'cleaningRejectReasonOther',
      desc: '',
      args: [],
    );
  }

  /// `Outside our service area`
  String get cleaningRejectReasonOutsideArea {
    return Intl.message(
      'Outside our service area',
      name: 'cleaningRejectReasonOutsideArea',
      desc: '',
      args: [],
    );
  }

  /// `Service temporarily unavailable`
  String get cleaningRejectReasonServiceUnavailable {
    return Intl.message(
      'Service temporarily unavailable',
      name: 'cleaningRejectReasonServiceUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Please select a reason. The customer will be\nnotified accordingly`
  String get cleaningRejectSheetSubtitle {
    return Intl.message(
      'Please select a reason. The customer will be\nnotified accordingly',
      name: 'cleaningRejectSheetSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `REQUEST ID`
  String get cleaningRequestIdHeader {
    return Intl.message(
      'REQUEST ID',
      name: 'cleaningRequestIdHeader',
      desc: '',
      args: [],
    );
  }

  /// `Request New Service Type`
  String get cleaningRequestNewServiceType {
    return Intl.message(
      'Request New Service Type',
      name: 'cleaningRequestNewServiceType',
      desc: '',
      args: [],
    );
  }

  /// `+ Request New Service Type`
  String get cleaningRequestNewServiceTypeLink {
    return Intl.message(
      '+ Request New Service Type',
      name: 'cleaningRequestNewServiceTypeLink',
      desc: '',
      args: [],
    );
  }

  /// `REVENUE`
  String get cleaningRevenueHeader {
    return Intl.message(
      'REVENUE',
      name: 'cleaningRevenueHeader',
      desc: '',
      args: [],
    );
  }

  /// `Save Add-on`
  String get cleaningSaveAddon {
    return Intl.message(
      'Save Add-on',
      name: 'cleaningSaveAddon',
      desc: '',
      args: [],
    );
  }

  /// `Save Space`
  String get cleaningSaveSpace {
    return Intl.message(
      'Save Space',
      name: 'cleaningSaveSpace',
      desc: '',
      args: [],
    );
  }

  /// `Search customer name or order ID..`
  String get cleaningSearchCustomerOrOrderId {
    return Intl.message(
      'Search customer name or order ID..',
      name: 'cleaningSearchCustomerOrOrderId',
      desc: '',
      args: [],
    );
  }

  /// `Search Services`
  String get cleaningSearchServices {
    return Intl.message(
      'Search Services',
      name: 'cleaningSearchServices',
      desc: '',
      args: [],
    );
  }

  /// `Select Service`
  String get cleaningSelectService {
    return Intl.message(
      'Select Service',
      name: 'cleaningSelectService',
      desc: '',
      args: [],
    );
  }

  /// `Service Image`
  String get cleaningServiceImage {
    return Intl.message(
      'Service Image',
      name: 'cleaningServiceImage',
      desc: '',
      args: [],
    );
  }

  /// `Service Type`
  String get cleaningServiceType {
    return Intl.message(
      'Service Type',
      name: 'cleaningServiceType',
      desc: '',
      args: [],
    );
  }

  /// `Service Type Name`
  String get cleaningServiceTypeName {
    return Intl.message(
      'Service Type Name',
      name: 'cleaningServiceTypeName',
      desc: '',
      args: [],
    );
  }

  /// `Briefly describe why you need this service type`
  String get cleaningServiceTypeReasonHint {
    return Intl.message(
      'Briefly describe why you need this service type',
      name: 'cleaningServiceTypeReasonHint',
      desc: '',
      args: [],
    );
  }

  /// `Short Description`
  String get cleaningShortDescription {
    return Intl.message(
      'Short Description',
      name: 'cleaningShortDescription',
      desc: '',
      args: [],
    );
  }

  /// `Space Name`
  String get cleaningSpaceName {
    return Intl.message(
      'Space Name',
      name: 'cleaningSpaceName',
      desc: '',
      args: [],
    );
  }

  /// `e.g. Master Bedroom, Living Room, Corridor, Balcony`
  String get cleaningSpaceNameHint {
    return Intl.message(
      'e.g. Master Bedroom, Living Room, Corridor, Balcony',
      name: 'cleaningSpaceNameHint',
      desc: '',
      args: [],
    );
  }

  /// `SPACE PRICING`
  String get cleaningSpacePricingHeader {
    return Intl.message(
      'SPACE PRICING',
      name: 'cleaningSpacePricingHeader',
      desc: '',
      args: [],
    );
  }

  /// `SPACES`
  String get cleaningSpacesHeader {
    return Intl.message(
      'SPACES',
      name: 'cleaningSpacesHeader',
      desc: '',
      args: [],
    );
  }

  /// `SPECIAL NOTES`
  String get cleaningSpecialNotesHeader {
    return Intl.message(
      'SPECIAL NOTES',
      name: 'cleaningSpecialNotesHeader',
      desc: '',
      args: [],
    );
  }

  /// `Start Cleaning`
  String get cleaningStartCleaning {
    return Intl.message(
      'Start Cleaning',
      name: 'cleaningStartCleaning',
      desc: '',
      args: [],
    );
  }

  /// `STARTING RATE`
  String get cleaningStartingRateHeader {
    return Intl.message(
      'STARTING RATE',
      name: 'cleaningStartingRateHeader',
      desc: '',
      args: [],
    );
  }

  /// `ACCEPTED`
  String get cleaningStatusAccepted {
    return Intl.message(
      'ACCEPTED',
      name: 'cleaningStatusAccepted',
      desc: '',
      args: [],
    );
  }

  /// `IN PROGRESS`
  String get cleaningStatusInProgress {
    return Intl.message(
      'IN PROGRESS',
      name: 'cleaningStatusInProgress',
      desc: '',
      args: [],
    );
  }

  /// `NEW`
  String get cleaningStatusNew {
    return Intl.message('NEW', name: 'cleaningStatusNew', desc: '', args: []);
  }

  /// `Submit Request`
  String get cleaningSubmitRequest {
    return Intl.message(
      'Submit Request',
      name: 'cleaningSubmitRequest',
      desc: '',
      args: [],
    );
  }

  /// `Support & Legal`
  String get cleaningSupportLegal {
    return Intl.message(
      'Support & Legal',
      name: 'cleaningSupportLegal',
      desc: '',
      args: [],
    );
  }

  /// `Tap to upload image`
  String get cleaningTapToUploadImage {
    return Intl.message(
      'Tap to upload image',
      name: 'cleaningTapToUploadImage',
      desc: '',
      args: [],
    );
  }

  /// `Today: {hours}`
  String cleaningTodayHours(String hours) {
    return Intl.message(
      'Today: $hours',
      name: 'cleaningTodayHours',
      desc: '',
      args: [hours],
    );
  }

  /// `Today's Bookings`
  String get cleaningTodaysBookings {
    return Intl.message(
      'Today\'s Bookings',
      name: 'cleaningTodaysBookings',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get cleaningTotal {
    return Intl.message('Total', name: 'cleaningTotal', desc: '', args: []);
  }

  /// `Total paid`
  String get cleaningTotalPaid {
    return Intl.message(
      'Total paid',
      name: 'cleaningTotalPaid',
      desc: '',
      args: [],
    );
  }

  /// `Hour`
  String get cleaningUnitHour {
    return Intl.message('Hour', name: 'cleaningUnitHour', desc: '', args: []);
  }

  /// `Unit`
  String get cleaningUnitLabel {
    return Intl.message('Unit', name: 'cleaningUnitLabel', desc: '', args: []);
  }

  /// `Piece`
  String get cleaningUnitPiece {
    return Intl.message('Piece', name: 'cleaningUnitPiece', desc: '', args: []);
  }

  /// `Room`
  String get cleaningUnitRoom {
    return Intl.message('Room', name: 'cleaningUnitRoom', desc: '', args: []);
  }

  /// `Sq. Ft`
  String get cleaningUnitSqFt {
    return Intl.message('Sq. Ft', name: 'cleaningUnitSqFt', desc: '', args: []);
  }

  /// `Unit`
  String get cleaningUnitUnit {
    return Intl.message('Unit', name: 'cleaningUnitUnit', desc: '', args: []);
  }

  /// `Upcoming`
  String get cleaningUpcoming {
    return Intl.message(
      'Upcoming',
      name: 'cleaningUpcoming',
      desc: '',
      args: [],
    );
  }

  /// `Vendor Profile`
  String get cleaningVendorProfile {
    return Intl.message(
      'Vendor Profile',
      name: 'cleaningVendorProfile',
      desc: '',
      args: [],
    );
  }

  /// `Villa`
  String get cleaningVilla {
    return Intl.message('Villa', name: 'cleaningVilla', desc: '', args: []);
  }

  /// `Working hours & Booking Slots`
  String get cleaningWorkingHoursBookingSlots {
    return Intl.message(
      'Working hours & Booking Slots',
      name: 'cleaningWorkingHoursBookingSlots',
      desc: '',
      args: [],
    );
  }

  /// `YOUR SERVICES`
  String get cleaningYourServicesHeader {
    return Intl.message(
      'YOUR SERVICES',
      name: 'cleaningYourServicesHeader',
      desc: '',
      args: [],
    );
  }

  /// `Accepting orders`
  String get waterAcceptingOrders {
    return Intl.message(
      'Accepting orders',
      name: 'waterAcceptingOrders',
      desc: '',
      args: [],
    );
  }

  /// `Account deleted successfully`
  String get waterAccountDeletedSuccessfully {
    return Intl.message(
      'Account deleted successfully',
      name: 'waterAccountDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Add Delivery Boy`
  String get waterAddDeliveryBoy {
    return Intl.message(
      'Add Delivery Boy',
      name: 'waterAddDeliveryBoy',
      desc: '',
      args: [],
    );
  }

  /// `Add Distance Range`
  String get waterAddDistanceRange {
    return Intl.message(
      'Add Distance Range',
      name: 'waterAddDistanceRange',
      desc: '',
      args: [],
    );
  }

  /// `Add More`
  String get waterAddMore {
    return Intl.message('Add More', name: 'waterAddMore', desc: '', args: []);
  }

  /// `Add Product`
  String get waterAddProduct {
    return Intl.message(
      'Add Product',
      name: 'waterAddProduct',
      desc: '',
      args: [],
    );
  }

  /// `Added delivery boys will appear here`
  String get waterAddedDeliveryBoysAppearHere {
    return Intl.message(
      'Added delivery boys will appear here',
      name: 'waterAddedDeliveryBoysAppearHere',
      desc: '',
      args: [],
    );
  }

  /// `Added products will appear here`
  String get waterAddedProductsWillAppearHere {
    return Intl.message(
      'Added products will appear here',
      name: 'waterAddedProductsWillAppearHere',
      desc: '',
      args: [],
    );
  }

  /// `Afternoon`
  String get waterAfternoon {
    return Intl.message(
      'Afternoon',
      name: 'waterAfternoon',
      desc: '',
      args: [],
    );
  }

  /// `Available Stock`
  String get waterAvailableStock {
    return Intl.message(
      'Available Stock',
      name: 'waterAvailableStock',
      desc: '',
      args: [],
    );
  }

  /// `Bank Details`
  String get waterBankDetails {
    return Intl.message(
      'Bank Details',
      name: 'waterBankDetails',
      desc: '',
      args: [],
    );
  }

  /// `Barcode`
  String get waterBarcode {
    return Intl.message('Barcode', name: 'waterBarcode', desc: '', args: []);
  }

  /// `BASIC INFORMATION`
  String get waterBasicInformation {
    return Intl.message(
      'BASIC INFORMATION',
      name: 'waterBasicInformation',
      desc: '',
      args: [],
    );
  }

  /// `BOTTLE RETURN SETTINGS`
  String get waterBottleReturnSettings {
    return Intl.message(
      'BOTTLE RETURN SETTINGS',
      name: 'waterBottleReturnSettings',
      desc: '',
      args: [],
    );
  }

  /// `Bottle Size`
  String get waterBottleSize {
    return Intl.message(
      'Bottle Size',
      name: 'waterBottleSize',
      desc: '',
      args: [],
    );
  }

  /// `Bottles`
  String get waterBottles {
    return Intl.message('Bottles', name: 'waterBottles', desc: '', args: []);
  }

  /// `{count} Bottles`
  String waterBottlesCount(String count) {
    return Intl.message(
      '$count Bottles',
      name: 'waterBottlesCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count} Bottles Left`
  String waterBottlesLeft(String count) {
    return Intl.message(
      '$count Bottles Left',
      name: 'waterBottlesLeft',
      desc: '',
      args: [count],
    );
  }

  /// `Brand`
  String get waterBrand {
    return Intl.message('Brand', name: 'waterBrand', desc: '', args: []);
  }

  /// `Brand Name`
  String get waterBrandName {
    return Intl.message(
      'Brand Name',
      name: 'waterBrandName',
      desc: '',
      args: [],
    );
  }

  /// `Business`
  String get waterBusiness {
    return Intl.message('Business', name: 'waterBusiness', desc: '', args: []);
  }

  /// `Business settings`
  String get waterBusinessSettings {
    return Intl.message(
      'Business settings',
      name: 'waterBusinessSettings',
      desc: '',
      args: [],
    );
  }

  /// `Business settings updated successfully`
  String get waterBusinessSettingsUpdated {
    return Intl.message(
      'Business settings updated successfully',
      name: 'waterBusinessSettingsUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Call Now`
  String get waterCallNow {
    return Intl.message('Call Now', name: 'waterCallNow', desc: '', args: []);
  }

  /// `Are you sure you want to cancel this leave?`
  String get waterCancelLeaveConfirm {
    return Intl.message(
      'Are you sure you want to cancel this leave?',
      name: 'waterCancelLeaveConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Certificate`
  String get waterCertificate {
    return Intl.message(
      'Certificate',
      name: 'waterCertificate',
      desc: '',
      args: [],
    );
  }

  /// `Chat With Customer`
  String get waterChatWithCustomer {
    return Intl.message(
      'Chat With Customer',
      name: 'waterChatWithCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Closed`
  String get waterClosed {
    return Intl.message('Closed', name: 'waterClosed', desc: '', args: []);
  }

  /// `Are you sure you want to delete this item?`
  String get waterConfirmDeleteItem {
    return Intl.message(
      'Are you sure you want to delete this item?',
      name: 'waterConfirmDeleteItem',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete "{name}"?`
  String waterConfirmDeleteNamedItem(String name) {
    return Intl.message(
      'Are you sure you want to delete "$name"?',
      name: 'waterConfirmDeleteNamedItem',
      desc: '',
      args: [name],
    );
  }

  /// `Are you sure you want to mark this item as available?`
  String get waterConfirmMarkAvailable {
    return Intl.message(
      'Are you sure you want to mark this item as available?',
      name: 'waterConfirmMarkAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to mark this item as out of stock?`
  String get waterConfirmMarkOutOfStock {
    return Intl.message(
      'Are you sure you want to mark this item as out of stock?',
      name: 'waterConfirmMarkOutOfStock',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Reject`
  String get waterConfirmReject {
    return Intl.message(
      'Confirm Reject',
      name: 'waterConfirmReject',
      desc: '',
      args: [],
    );
  }

  /// `Count`
  String get waterCount {
    return Intl.message('Count', name: 'waterCount', desc: '', args: []);
  }

  /// `Created coupons will appear here`
  String get waterCreatedCouponsAppearHere {
    return Intl.message(
      'Created coupons will appear here',
      name: 'waterCreatedCouponsAppearHere',
      desc: '',
      args: [],
    );
  }

  /// `Current Status`
  String get waterCurrentStatus {
    return Intl.message(
      'Current Status',
      name: 'waterCurrentStatus',
      desc: '',
      args: [],
    );
  }

  /// `Currently Paused`
  String get waterCurrentlyPaused {
    return Intl.message(
      'Currently Paused',
      name: 'waterCurrentlyPaused',
      desc: '',
      args: [],
    );
  }

  /// `Customer`
  String get waterCustomer {
    return Intl.message('Customer', name: 'waterCustomer', desc: '', args: []);
  }

  /// `CUSTOMER`
  String get waterCustomerHeader {
    return Intl.message(
      'CUSTOMER',
      name: 'waterCustomerHeader',
      desc: '',
      args: [],
    );
  }

  /// `Customer messages will appear here`
  String get waterCustomerMessagesWillAppearHere {
    return Intl.message(
      'Customer messages will appear here',
      name: 'waterCustomerMessagesWillAppearHere',
      desc: '',
      args: [],
    );
  }

  /// `Customer Requested Pause`
  String get waterCustomerRequestedPause {
    return Intl.message(
      'Customer Requested Pause',
      name: 'waterCustomerRequestedPause',
      desc: '',
      args: [],
    );
  }

  /// `Daily`
  String get waterDaily {
    return Intl.message('Daily', name: 'waterDaily', desc: '', args: []);
  }

  /// `dd-mm-yyyy`
  String get waterDatePlaceholder {
    return Intl.message(
      'dd-mm-yyyy',
      name: 'waterDatePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Address`
  String get waterDeliveryAddressTitle {
    return Intl.message(
      'Delivery Address',
      name: 'waterDeliveryAddressTitle',
      desc: '',
      args: [],
    );
  }

  /// `DELIVERY HISTORY`
  String get waterDeliveryHistory {
    return Intl.message(
      'DELIVERY HISTORY',
      name: 'waterDeliveryHistory',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Partner Assigned`
  String get waterDeliveryPartnerAssigned {
    return Intl.message(
      'Delivery Partner Assigned',
      name: 'waterDeliveryPartnerAssigned',
      desc: '',
      args: [],
    );
  }

  /// `DELIVERY PARTNER`
  String get waterDeliveryPartnerHeader {
    return Intl.message(
      'DELIVERY PARTNER',
      name: 'waterDeliveryPartnerHeader',
      desc: '',
      args: [],
    );
  }

  /// `DELIVERY TYPE`
  String get waterDeliveryTypeHeader {
    return Intl.message(
      'DELIVERY TYPE',
      name: 'waterDeliveryTypeHeader',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get waterDescription {
    return Intl.message(
      'Description',
      name: 'waterDescription',
      desc: '',
      args: [],
    );
  }

  /// `{min} - {max} km`
  String waterDistanceRangeKm(String min, String max) {
    return Intl.message(
      '$min - $max km',
      name: 'waterDistanceRangeKm',
      desc: '',
      args: [min, max],
    );
  }

  /// `Edit Distance Range`
  String get waterEditDistanceRange {
    return Intl.message(
      'Edit Distance Range',
      name: 'waterEditDistanceRange',
      desc: '',
      args: [],
    );
  }

  /// `Edit Price`
  String get waterEditPrice {
    return Intl.message(
      'Edit Price',
      name: 'waterEditPrice',
      desc: '',
      args: [],
    );
  }

  /// `Edit Working Hour`
  String get waterEditWorkingHour {
    return Intl.message(
      'Edit Working Hour',
      name: 'waterEditWorkingHour',
      desc: '',
      args: [],
    );
  }

  /// `End`
  String get waterEnd {
    return Intl.message('End', name: 'waterEnd', desc: '', args: []);
  }

  /// `End Time`
  String get waterEndTime {
    return Intl.message('End Time', name: 'waterEndTime', desc: '', args: []);
  }

  /// `End time must be after start time`
  String get waterEndTimeAfterStartTime {
    return Intl.message(
      'End time must be after start time',
      name: 'waterEndTimeAfterStartTime',
      desc: '',
      args: [],
    );
  }

  /// `Enter minimum and maximum distance`
  String get waterEnterMinMaxDistance {
    return Intl.message(
      'Enter minimum and maximum distance',
      name: 'waterEnterMinMaxDistance',
      desc: '',
      args: [],
    );
  }

  /// `Enter a price`
  String get waterEnterPrice {
    return Intl.message(
      'Enter a price',
      name: 'waterEnterPrice',
      desc: '',
      args: [],
    );
  }

  /// `Enter Quantity`
  String get waterEnterQuantity {
    return Intl.message(
      'Enter Quantity',
      name: 'waterEnterQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Enter a reason`
  String get waterEnterReason {
    return Intl.message(
      'Enter a reason',
      name: 'waterEnterReason',
      desc: '',
      args: [],
    );
  }

  /// `Error accepting order: {error}`
  String waterErrorAcceptingOrder(String error) {
    return Intl.message(
      'Error accepting order: $error',
      name: 'waterErrorAcceptingOrder',
      desc: '',
      args: [error],
    );
  }

  /// `Error accepting subscription: {error}`
  String waterErrorAcceptingSubscription(String error) {
    return Intl.message(
      'Error accepting subscription: $error',
      name: 'waterErrorAcceptingSubscription',
      desc: '',
      args: [error],
    );
  }

  /// `Error adding product: {error}`
  String waterErrorAddingProduct(String error) {
    return Intl.message(
      'Error adding product: $error',
      name: 'waterErrorAddingProduct',
      desc: '',
      args: [error],
    );
  }

  /// `Error cancelling order: {error}`
  String waterErrorCancellingOrder(String error) {
    return Intl.message(
      'Error cancelling order: $error',
      name: 'waterErrorCancellingOrder',
      desc: '',
      args: [error],
    );
  }

  /// `Error deleting product: {error}`
  String waterErrorDeletingProduct(String error) {
    return Intl.message(
      'Error deleting product: $error',
      name: 'waterErrorDeletingProduct',
      desc: '',
      args: [error],
    );
  }

  /// `Error marking order as ready: {error}`
  String waterErrorMarkingOrderAsReady(String error) {
    return Intl.message(
      'Error marking order as ready: $error',
      name: 'waterErrorMarkingOrderAsReady',
      desc: '',
      args: [error],
    );
  }

  /// `Error pausing subscription: {error}`
  String waterErrorPausingSubscription(String error) {
    return Intl.message(
      'Error pausing subscription: $error',
      name: 'waterErrorPausingSubscription',
      desc: '',
      args: [error],
    );
  }

  /// `Error preparing order: {error}`
  String waterErrorPreparingOrder(String error) {
    return Intl.message(
      'Error preparing order: $error',
      name: 'waterErrorPreparingOrder',
      desc: '',
      args: [error],
    );
  }

  /// `Error rejecting subscription: {error}`
  String waterErrorRejectingSubscription(String error) {
    return Intl.message(
      'Error rejecting subscription: $error',
      name: 'waterErrorRejectingSubscription',
      desc: '',
      args: [error],
    );
  }

  /// `Error resuming subscription: {error}`
  String waterErrorResumingSubscription(String error) {
    return Intl.message(
      'Error resuming subscription: $error',
      name: 'waterErrorResumingSubscription',
      desc: '',
      args: [error],
    );
  }

  /// `Error updating item status: {error}`
  String waterErrorUpdatingItemStatus(String error) {
    return Intl.message(
      'Error updating item status: $error',
      name: 'waterErrorUpdatingItemStatus',
      desc: '',
      args: [error],
    );
  }

  /// `Error updating price: {error}`
  String waterErrorUpdatingPrice(String error) {
    return Intl.message(
      'Error updating price: $error',
      name: 'waterErrorUpdatingPrice',
      desc: '',
      args: [error],
    );
  }

  /// `Error updating stock: {error}`
  String waterErrorUpdatingStock(String error) {
    return Intl.message(
      'Error updating stock: $error',
      name: 'waterErrorUpdatingStock',
      desc: '',
      args: [error],
    );
  }

  /// `Est. value`
  String get waterEstValue {
    return Intl.message(
      'Est. value',
      name: 'waterEstValue',
      desc: '',
      args: [],
    );
  }

  /// `Estimated Delivery Fee`
  String get waterEstimatedDeliveryFee {
    return Intl.message(
      'Estimated Delivery Fee',
      name: 'waterEstimatedDeliveryFee',
      desc: '',
      args: [],
    );
  }

  /// `Evening`
  String get waterEvening {
    return Intl.message('Evening', name: 'waterEvening', desc: '', args: []);
  }

  /// `Express Delivery`
  String get waterExpressDelivery {
    return Intl.message(
      'Express Delivery',
      name: 'waterExpressDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Failed to accept order`
  String get waterFailedToAcceptOrder {
    return Intl.message(
      'Failed to accept order',
      name: 'waterFailedToAcceptOrder',
      desc: '',
      args: [],
    );
  }

  /// `Failed to accept subscription`
  String get waterFailedToAcceptSubscription {
    return Intl.message(
      'Failed to accept subscription',
      name: 'waterFailedToAcceptSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add product`
  String get waterFailedToAddProduct {
    return Intl.message(
      'Failed to add product',
      name: 'waterFailedToAddProduct',
      desc: '',
      args: [],
    );
  }

  /// `Failed to cancel leave`
  String get waterFailedToCancelLeave {
    return Intl.message(
      'Failed to cancel leave',
      name: 'waterFailedToCancelLeave',
      desc: '',
      args: [],
    );
  }

  /// `Failed to cancel order`
  String get waterFailedToCancelOrder {
    return Intl.message(
      'Failed to cancel order',
      name: 'waterFailedToCancelOrder',
      desc: '',
      args: [],
    );
  }

  /// `Failed to delete account`
  String get waterFailedToDeleteAccount {
    return Intl.message(
      'Failed to delete account',
      name: 'waterFailedToDeleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Failed to delete product`
  String get waterFailedToDeleteProduct {
    return Intl.message(
      'Failed to delete product',
      name: 'waterFailedToDeleteProduct',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load image`
  String get waterFailedToLoadImage {
    return Intl.message(
      'Failed to load image',
      name: 'waterFailedToLoadImage',
      desc: '',
      args: [],
    );
  }

  /// `Failed to mark leave`
  String get waterFailedToMarkLeave {
    return Intl.message(
      'Failed to mark leave',
      name: 'waterFailedToMarkLeave',
      desc: '',
      args: [],
    );
  }

  /// `Failed to mark order as ready`
  String get waterFailedToMarkOrderAsReady {
    return Intl.message(
      'Failed to mark order as ready',
      name: 'waterFailedToMarkOrderAsReady',
      desc: '',
      args: [],
    );
  }

  /// `Failed to pause subscription`
  String get waterFailedToPauseSubscription {
    return Intl.message(
      'Failed to pause subscription',
      name: 'waterFailedToPauseSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Failed to prepare order`
  String get waterFailedToPrepareOrder {
    return Intl.message(
      'Failed to prepare order',
      name: 'waterFailedToPrepareOrder',
      desc: '',
      args: [],
    );
  }

  /// `Failed to reject subscription`
  String get waterFailedToRejectSubscription {
    return Intl.message(
      'Failed to reject subscription',
      name: 'waterFailedToRejectSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Failed to resume subscription`
  String get waterFailedToResumeSubscription {
    return Intl.message(
      'Failed to resume subscription',
      name: 'waterFailedToResumeSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update business settings`
  String get waterFailedToUpdateBusinessSettings {
    return Intl.message(
      'Failed to update business settings',
      name: 'waterFailedToUpdateBusinessSettings',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update item status`
  String get waterFailedToUpdateItemStatus {
    return Intl.message(
      'Failed to update item status',
      name: 'waterFailedToUpdateItemStatus',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update price`
  String get waterFailedToUpdatePrice {
    return Intl.message(
      'Failed to update price',
      name: 'waterFailedToUpdatePrice',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update stock`
  String get waterFailedToUpdateStock {
    return Intl.message(
      'Failed to update stock',
      name: 'waterFailedToUpdateStock',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update working hours`
  String get waterFailedToUpdateWorkingHours {
    return Intl.message(
      'Failed to update working hours',
      name: 'waterFailedToUpdateWorkingHours',
      desc: '',
      args: [],
    );
  }

  /// `Fill in every field`
  String get waterFillInEveryField {
    return Intl.message(
      'Fill in every field',
      name: 'waterFillInEveryField',
      desc: '',
      args: [],
    );
  }

  /// `All {count}`
  String waterFilterAllCount(String count) {
    return Intl.message(
      'All $count',
      name: 'waterFilterAllCount',
      desc: '',
      args: [count],
    );
  }

  /// `Filter by category`
  String get waterFilterByCategory {
    return Intl.message(
      'Filter by category',
      name: 'waterFilterByCategory',
      desc: '',
      args: [],
    );
  }

  /// `In Stock {count}`
  String waterFilterInStockCount(String count) {
    return Intl.message(
      'In Stock $count',
      name: 'waterFilterInStockCount',
      desc: '',
      args: [count],
    );
  }

  /// `Low Stock {count}`
  String waterFilterLowStockCount(String count) {
    return Intl.message(
      'Low Stock $count',
      name: 'waterFilterLowStockCount',
      desc: '',
      args: [count],
    );
  }

  /// `Flat`
  String get waterFlat {
    return Intl.message('Flat', name: 'waterFlat', desc: '', args: []);
  }

  /// `Frequency`
  String get waterFrequency {
    return Intl.message(
      'Frequency',
      name: 'waterFrequency',
      desc: '',
      args: [],
    );
  }

  /// `ID: {id}`
  String waterIdLabel(String id) {
    return Intl.message('ID: $id', name: 'waterIdLabel', desc: '', args: [id]);
  }

  /// `Image`
  String get waterImage {
    return Intl.message('Image', name: 'waterImage', desc: '', args: []);
  }

  /// `PNG, JPG up to 5MB`
  String get waterImageFormatHint {
    return Intl.message(
      'PNG, JPG up to 5MB',
      name: 'waterImageFormatHint',
      desc: '',
      args: [],
    );
  }

  /// `{count} images selected`
  String waterImagesSelected(String count) {
    return Intl.message(
      '$count images selected',
      name: 'waterImagesSelected',
      desc: '',
      args: [count],
    );
  }

  /// `In Stock`
  String get waterInStock {
    return Intl.message('In Stock', name: 'waterInStock', desc: '', args: []);
  }

  /// `Inventory`
  String get waterInventory {
    return Intl.message(
      'Inventory',
      name: 'waterInventory',
      desc: '',
      args: [],
    );
  }

  /// `INVENTORY CONTROL`
  String get waterInventoryControl {
    return Intl.message(
      'INVENTORY CONTROL',
      name: 'waterInventoryControl',
      desc: '',
      args: [],
    );
  }

  /// `Water Item`
  String get waterItem {
    return Intl.message('Water Item', name: 'waterItem', desc: '', args: []);
  }

  /// `Item marked as available successfully`
  String get waterItemMarkedAvailable {
    return Intl.message(
      'Item marked as available successfully',
      name: 'waterItemMarkedAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Item marked as out of stock successfully`
  String get waterItemMarkedOutOfStock {
    return Intl.message(
      'Item marked as out of stock successfully',
      name: 'waterItemMarkedOutOfStock',
      desc: '',
      args: [],
    );
  }

  /// `Last Sold: {date}`
  String waterLastSold(String date) {
    return Intl.message(
      'Last Sold: $date',
      name: 'waterLastSold',
      desc: '',
      args: [date],
    );
  }

  /// `Leave cancelled successfully`
  String get waterLeaveCancelledSuccessfully {
    return Intl.message(
      'Leave cancelled successfully',
      name: 'waterLeaveCancelledSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Leave Management`
  String get waterLeaveManagement {
    return Intl.message(
      'Leave Management',
      name: 'waterLeaveManagement',
      desc: '',
      args: [],
    );
  }

  /// `Leave marked successfully`
  String get waterLeaveMarkedSuccessfully {
    return Intl.message(
      'Leave marked successfully',
      name: 'waterLeaveMarkedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Logout failed.`
  String get waterLogoutFailed {
    return Intl.message(
      'Logout failed.',
      name: 'waterLogoutFailed',
      desc: '',
      args: [],
    );
  }

  /// `Low Stock`
  String get waterLowStock {
    return Intl.message('Low Stock', name: 'waterLowStock', desc: '', args: []);
  }

  /// `Low Stock Alert`
  String get waterLowStockAlert {
    return Intl.message(
      'Low Stock Alert',
      name: 'waterLowStockAlert',
      desc: '',
      args: [],
    );
  }

  /// `Mark as Picked Up`
  String get waterMarkAsPickedUp {
    return Intl.message(
      'Mark as Picked Up',
      name: 'waterMarkAsPickedUp',
      desc: '',
      args: [],
    );
  }

  /// `Mark Available`
  String get waterMarkAvailable {
    return Intl.message(
      'Mark Available',
      name: 'waterMarkAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to mark leave for the selected dates?`
  String get waterMarkLeaveConfirm {
    return Intl.message(
      'Are you sure you want to mark leave for the selected dates?',
      name: 'waterMarkLeaveConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Mark Out Of Stock`
  String get waterMarkOutOfStock {
    return Intl.message(
      'Mark Out Of Stock',
      name: 'waterMarkOutOfStock',
      desc: '',
      args: [],
    );
  }

  /// `Mark Store Busy`
  String get waterMarkStoreBusy {
    return Intl.message(
      'Mark Store Busy',
      name: 'waterMarkStoreBusy',
      desc: '',
      args: [],
    );
  }

  /// `Marked leaves will appear here`
  String get waterMarkedLeavesAppearHere {
    return Intl.message(
      'Marked leaves will appear here',
      name: 'waterMarkedLeavesAppearHere',
      desc: '',
      args: [],
    );
  }

  /// `Maximum must be greater than minimum`
  String get waterMaxGreaterThanMin {
    return Intl.message(
      'Maximum must be greater than minimum',
      name: 'waterMaxGreaterThanMin',
      desc: '',
      args: [],
    );
  }

  /// `Maximum Distance`
  String get waterMaximumDistance {
    return Intl.message(
      'Maximum Distance',
      name: 'waterMaximumDistance',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get waterMessages {
    return Intl.message('Messages', name: 'waterMessages', desc: '', args: []);
  }

  /// `Minimum Distance`
  String get waterMinimumDistance {
    return Intl.message(
      'Minimum Distance',
      name: 'waterMinimumDistance',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get waterMonth {
    return Intl.message('Month', name: 'waterMonth', desc: '', args: []);
  }

  /// `More`
  String get waterMore {
    return Intl.message('More', name: 'waterMore', desc: '', args: []);
  }

  /// `+{count} More Products`
  String waterMoreProducts(String count) {
    return Intl.message(
      '+$count More Products',
      name: 'waterMoreProducts',
      desc: '',
      args: [count],
    );
  }

  /// `Morning`
  String get waterMorning {
    return Intl.message('Morning', name: 'waterMorning', desc: '', args: []);
  }

  /// `NEW`
  String get waterNewBadge {
    return Intl.message('NEW', name: 'waterNewBadge', desc: '', args: []);
  }

  /// `New Orders`
  String get waterNewOrders {
    return Intl.message(
      'New Orders',
      name: 'waterNewOrders',
      desc: '',
      args: [],
    );
  }

  /// `Next Delivery`
  String get waterNextDelivery {
    return Intl.message(
      'Next Delivery',
      name: 'waterNextDelivery',
      desc: '',
      args: [],
    );
  }

  /// `No contact details available`
  String get waterNoContactDetails {
    return Intl.message(
      'No contact details available',
      name: 'waterNoContactDetails',
      desc: '',
      args: [],
    );
  }

  /// `No Leaves Found`
  String get waterNoLeavesFound {
    return Intl.message(
      'No Leaves Found',
      name: 'waterNoLeavesFound',
      desc: '',
      args: [],
    );
  }

  /// `No orders here`
  String get waterNoOrdersHere {
    return Intl.message(
      'No orders here',
      name: 'waterNoOrdersHere',
      desc: '',
      args: [],
    );
  }

  /// `No Payouts Found`
  String get waterNoPayoutsFound {
    return Intl.message(
      'No Payouts Found',
      name: 'waterNoPayoutsFound',
      desc: '',
      args: [],
    );
  }

  /// `No privacy policy available`
  String get waterNoPrivacyPolicyAvailable {
    return Intl.message(
      'No privacy policy available',
      name: 'waterNoPrivacyPolicyAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No Products Found`
  String get waterNoProductsFound {
    return Intl.message(
      'No Products Found',
      name: 'waterNoProductsFound',
      desc: '',
      args: [],
    );
  }

  /// `No Stock History Found`
  String get waterNoStockHistoryFound {
    return Intl.message(
      'No Stock History Found',
      name: 'waterNoStockHistoryFound',
      desc: '',
      args: [],
    );
  }

  /// `No stock records recorded for this item yet`
  String get waterNoStockRecordsYet {
    return Intl.message(
      'No stock records recorded for this item yet',
      name: 'waterNoStockRecordsYet',
      desc: '',
      args: [],
    );
  }

  /// `No subscription orders here`
  String get waterNoSubscriptionOrdersHere {
    return Intl.message(
      'No subscription orders here',
      name: 'waterNoSubscriptionOrdersHere',
      desc: '',
      args: [],
    );
  }

  /// `No terms & conditions available`
  String get waterNoTermsAvailable {
    return Intl.message(
      'No terms & conditions available',
      name: 'waterNoTermsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Not accepting`
  String get waterNotAccepting {
    return Intl.message(
      'Not accepting',
      name: 'waterNotAccepting',
      desc: '',
      args: [],
    );
  }

  /// `N/A`
  String get waterNotAvailable {
    return Intl.message('N/A', name: 'waterNotAvailable', desc: '', args: []);
  }

  /// `Offer Price`
  String get waterOfferPrice {
    return Intl.message(
      'Offer Price',
      name: 'waterOfferPrice',
      desc: '',
      args: [],
    );
  }

  /// `Offline`
  String get waterOffline {
    return Intl.message('Offline', name: 'waterOffline', desc: '', args: []);
  }

  /// `1 image selected`
  String get waterOneImageSelected {
    return Intl.message(
      '1 image selected',
      name: 'waterOneImageSelected',
      desc: '',
      args: [],
    );
  }

  /// `One-Time Orders`
  String get waterOneTimeOrders {
    return Intl.message(
      'One-Time Orders',
      name: 'waterOneTimeOrders',
      desc: '',
      args: [],
    );
  }

  /// `Online`
  String get waterOnline {
    return Intl.message('Online', name: 'waterOnline', desc: '', args: []);
  }

  /// `Open`
  String get waterOpen {
    return Intl.message('Open', name: 'waterOpen', desc: '', args: []);
  }

  /// `24-Hour Open`
  String get waterOpen24Hours {
    return Intl.message(
      '24-Hour Open',
      name: 'waterOpen24Hours',
      desc: '',
      args: [],
    );
  }

  /// `Order cancelled successfully`
  String get waterOrderCancelledSuccessfully {
    return Intl.message(
      'Order cancelled successfully',
      name: 'waterOrderCancelledSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Order Delivered`
  String get waterOrderDelivered {
    return Intl.message(
      'Order Delivered',
      name: 'waterOrderDelivered',
      desc: '',
      args: [],
    );
  }

  /// `ORDER ITEMS ({count})`
  String waterOrderItemsCount(String count) {
    return Intl.message(
      'ORDER ITEMS ($count)',
      name: 'waterOrderItemsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Order marked as ready successfully`
  String get waterOrderMarkedAsReady {
    return Intl.message(
      'Order marked as ready successfully',
      name: 'waterOrderMarkedAsReady',
      desc: '',
      args: [],
    );
  }

  /// `Order moved to preparing successfully`
  String get waterOrderMovedToPreparing {
    return Intl.message(
      'Order moved to preparing successfully',
      name: 'waterOrderMovedToPreparing',
      desc: '',
      args: [],
    );
  }

  /// `Order Received`
  String get waterOrderReceived {
    return Intl.message(
      'Order Received',
      name: 'waterOrderReceived',
      desc: '',
      args: [],
    );
  }

  /// `Orders will appear here`
  String get waterOrdersAppearHere {
    return Intl.message(
      'Orders will appear here',
      name: 'waterOrdersAppearHere',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get waterOther {
    return Intl.message('Other', name: 'waterOther', desc: '', args: []);
  }

  /// `Other Reason`
  String get waterOtherReason {
    return Intl.message(
      'Other Reason',
      name: 'waterOtherReason',
      desc: '',
      args: [],
    );
  }

  /// `Owner Identity Proof`
  String get waterOwnerIdentityProof {
    return Intl.message(
      'Owner Identity Proof',
      name: 'waterOwnerIdentityProof',
      desc: '',
      args: [],
    );
  }

  /// `Pause`
  String get waterPause {
    return Intl.message('Pause', name: 'waterPause', desc: '', args: []);
  }

  /// `Pause Subscription`
  String get waterPauseSubscription {
    return Intl.message(
      'Pause Subscription',
      name: 'waterPauseSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Future deliveries will be paused. Today's active order won't be affected`
  String get waterPauseSubscriptionHint {
    return Intl.message(
      'Future deliveries will be paused. Today\'s active order won\'t be affected',
      name: 'waterPauseSubscriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `Paused`
  String get waterPaused {
    return Intl.message('Paused', name: 'waterPaused', desc: '', args: []);
  }

  /// `PAUSED BY:`
  String get waterPausedByLabel {
    return Intl.message(
      'PAUSED BY:',
      name: 'waterPausedByLabel',
      desc: '',
      args: [],
    );
  }

  /// `Paused on: {date}`
  String waterPausedOn(String date) {
    return Intl.message(
      'Paused on: $date',
      name: 'waterPausedOn',
      desc: '',
      args: [date],
    );
  }

  /// `PAUSED ON:`
  String get waterPausedOnLabel {
    return Intl.message(
      'PAUSED ON:',
      name: 'waterPausedOnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Payment Details`
  String get waterPaymentDetails {
    return Intl.message(
      'Payment Details',
      name: 'waterPaymentDetails',
      desc: '',
      args: [],
    );
  }

  /// `Payment Proof`
  String get waterPaymentProof {
    return Intl.message(
      'Payment Proof',
      name: 'waterPaymentProof',
      desc: '',
      args: [],
    );
  }

  /// `Payout Amount`
  String get waterPayoutAmount {
    return Intl.message(
      'Payout Amount',
      name: 'waterPayoutAmount',
      desc: '',
      args: [],
    );
  }

  /// `Payout history will appear here`
  String get waterPayoutHistoryAppearHere {
    return Intl.message(
      'Payout history will appear here',
      name: 'waterPayoutHistoryAppearHere',
      desc: '',
      args: [],
    );
  }

  /// `Orders related to this payout will appear here`
  String get waterPayoutOrdersAppearHere {
    return Intl.message(
      'Orders related to this payout will appear here',
      name: 'waterPayoutOrdersAppearHere',
      desc: '',
      args: [],
    );
  }

  /// `Pick one or more images from gallery`
  String get waterPickImagesFromGallery {
    return Intl.message(
      'Pick one or more images from gallery',
      name: 'waterPickImagesFromGallery',
      desc: '',
      args: [],
    );
  }

  /// `Picked Up by Customer`
  String get waterPickedUpByCustomer {
    return Intl.message(
      'Picked Up by Customer',
      name: 'waterPickedUpByCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Picked Up by Rider`
  String get waterPickedUpByRider {
    return Intl.message(
      'Picked Up by Rider',
      name: 'waterPickedUpByRider',
      desc: '',
      args: [],
    );
  }

  /// `Plan`
  String get waterPlan {
    return Intl.message('Plan', name: 'waterPlan', desc: '', args: []);
  }

  /// `Start {start}`
  String waterPlanRangeStart(String start) {
    return Intl.message(
      'Start $start',
      name: 'waterPlanRangeStart',
      desc: '',
      args: [start],
    );
  }

  /// `Start {start} - End {end}`
  String waterPlanRangeStartEnd(String start, String end) {
    return Intl.message(
      'Start $start - End $end',
      name: 'waterPlanRangeStartEnd',
      desc: '',
      args: [start, end],
    );
  }

  /// `PLAN SUMMARY`
  String get waterPlanSummary {
    return Intl.message(
      'PLAN SUMMARY',
      name: 'waterPlanSummary',
      desc: '',
      args: [],
    );
  }

  /// `Please enter available stock`
  String get waterPleaseEnterAvailableStock {
    return Intl.message(
      'Please enter available stock',
      name: 'waterPleaseEnterAvailableStock',
      desc: '',
      args: [],
    );
  }

  /// `Please enter price`
  String get waterPleaseEnterPrice {
    return Intl.message(
      'Please enter price',
      name: 'waterPleaseEnterPrice',
      desc: '',
      args: [],
    );
  }

  /// `Please enter product name`
  String get waterPleaseEnterProductName {
    return Intl.message(
      'Please enter product name',
      name: 'waterPleaseEnterProductName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter selling price`
  String get waterPleaseEnterSellingPrice {
    return Intl.message(
      'Please enter selling price',
      name: 'waterPleaseEnterSellingPrice',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid price`
  String get waterPleaseEnterValidPrice {
    return Intl.message(
      'Please enter a valid price',
      name: 'waterPleaseEnterValidPrice',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least one product image`
  String get waterPleaseSelectProductImage {
    return Intl.message(
      'Please select at least one product image',
      name: 'waterPleaseSelectProductImage',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 50`
  String get waterPriceExampleHint {
    return Intl.message(
      'e.g. 50',
      name: 'waterPriceExampleHint',
      desc: '',
      args: [],
    );
  }

  /// `Price updated successfully`
  String get waterPriceUpdatedSuccessfully {
    return Intl.message(
      'Price updated successfully',
      name: 'waterPriceUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Pricing`
  String get waterPricing {
    return Intl.message('Pricing', name: 'waterPricing', desc: '', args: []);
  }

  /// `PRICING (MRU)`
  String get waterPricingMru {
    return Intl.message(
      'PRICING (MRU)',
      name: 'waterPricingMru',
      desc: '',
      args: [],
    );
  }

  /// `Privacy & Security`
  String get waterPrivacySecurity {
    return Intl.message(
      'Privacy & Security',
      name: 'waterPrivacySecurity',
      desc: '',
      args: [],
    );
  }

  /// `Product added successfully`
  String get waterProductAddedSuccessfully {
    return Intl.message(
      'Product added successfully',
      name: 'waterProductAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Product deleted successfully`
  String get waterProductDeletedSuccessfully {
    return Intl.message(
      'Product deleted successfully',
      name: 'waterProductDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Product Description`
  String get waterProductDescription {
    return Intl.message(
      'Product Description',
      name: 'waterProductDescription',
      desc: '',
      args: [],
    );
  }

  /// `Describe the source, pH level, or benefits...`
  String get waterProductDescriptionHint {
    return Intl.message(
      'Describe the source, pH level, or benefits...',
      name: 'waterProductDescriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `Product Details`
  String get waterProductDetails {
    return Intl.message(
      'Product Details',
      name: 'waterProductDetails',
      desc: '',
      args: [],
    );
  }

  /// `Product Image`
  String get waterProductImage {
    return Intl.message(
      'Product Image',
      name: 'waterProductImage',
      desc: '',
      args: [],
    );
  }

  /// `Product Name (English)`
  String get waterProductNameEnglish {
    return Intl.message(
      'Product Name (English)',
      name: 'waterProductNameEnglish',
      desc: '',
      args: [],
    );
  }

  /// `e.g. Drinking Water`
  String get waterProductNameHint {
    return Intl.message(
      'e.g. Drinking Water',
      name: 'waterProductNameHint',
      desc: '',
      args: [],
    );
  }

  /// `QUANTITY: `
  String get waterQuantityLabel {
    return Intl.message(
      'QUANTITY: ',
      name: 'waterQuantityLabel',
      desc: '',
      args: [],
    );
  }

  /// `This range overlaps an existing range`
  String get waterRangeOverlaps {
    return Intl.message(
      'This range overlaps an existing range',
      name: 'waterRangeOverlaps',
      desc: '',
      args: [],
    );
  }

  /// `Ready for Dispatch`
  String get waterReadyForDispatch {
    return Intl.message(
      'Ready for Dispatch',
      name: 'waterReadyForDispatch',
      desc: '',
      args: [],
    );
  }

  /// `Ready for Pickup`
  String get waterReadyForPickup {
    return Intl.message(
      'Ready for Pickup',
      name: 'waterReadyForPickup',
      desc: '',
      args: [],
    );
  }

  /// `Reason For Pausing`
  String get waterReasonForPausing {
    return Intl.message(
      'Reason For Pausing',
      name: 'waterReasonForPausing',
      desc: '',
      args: [],
    );
  }

  /// `Reason For Rejecting`
  String get waterReasonForRejecting {
    return Intl.message(
      'Reason For Rejecting',
      name: 'waterReasonForRejecting',
      desc: '',
      args: [],
    );
  }

  /// `REASON:`
  String get waterReasonLabel {
    return Intl.message(
      'REASON:',
      name: 'waterReasonLabel',
      desc: '',
      args: [],
    );
  }

  /// `Registration Details`
  String get waterRegistrationDetails {
    return Intl.message(
      'Registration Details',
      name: 'waterRegistrationDetails',
      desc: '',
      args: [],
    );
  }

  /// `Reject Order`
  String get waterRejectOrder {
    return Intl.message(
      'Reject Order',
      name: 'waterRejectOrder',
      desc: '',
      args: [],
    );
  }

  /// `Please select a reason. The customer will be notified accordingly`
  String get waterRejectOrderHint {
    return Intl.message(
      'Please select a reason. The customer will be notified accordingly',
      name: 'waterRejectOrderHint',
      desc: '',
      args: [],
    );
  }

  /// `REMAINING: `
  String get waterRemainingLabel {
    return Intl.message(
      'REMAINING: ',
      name: 'waterRemainingLabel',
      desc: '',
      args: [],
    );
  }

  /// `REQUEST ID`
  String get waterRequestId {
    return Intl.message(
      'REQUEST ID',
      name: 'waterRequestId',
      desc: '',
      args: [],
    );
  }

  /// `Resume`
  String get waterResume {
    return Intl.message('Resume', name: 'waterResume', desc: '', args: []);
  }

  /// `Resume Subscription`
  String get waterResumeSubscription {
    return Intl.message(
      'Resume Subscription',
      name: 'waterResumeSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to resume this subscription order?`
  String get waterResumeSubscriptionConfirm {
    return Intl.message(
      'Are you sure you want to resume this subscription order?',
      name: 'waterResumeSubscriptionConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Returnable Bottle`
  String get waterReturnableBottle {
    return Intl.message(
      'Returnable Bottle',
      name: 'waterReturnableBottle',
      desc: '',
      args: [],
    );
  }

  /// `Enable this option if customers must return the empty bottle after delivery or self pickup`
  String get waterReturnableBottleHint {
    return Intl.message(
      'Enable this option if customers must return the empty bottle after delivery or self pickup',
      name: 'waterReturnableBottleHint',
      desc: '',
      args: [],
    );
  }

  /// `REVENUE`
  String get waterRevenueHeader {
    return Intl.message(
      'REVENUE',
      name: 'waterRevenueHeader',
      desc: '',
      args: [],
    );
  }

  /// `Revenue Summary`
  String get waterRevenueSummary {
    return Intl.message(
      'Revenue Summary',
      name: 'waterRevenueSummary',
      desc: '',
      args: [],
    );
  }

  /// `({count} reviews)`
  String waterReviewsCount(String count) {
    return Intl.message(
      '($count reviews)',
      name: 'waterReviewsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Sales Performance`
  String get waterSalesPerformance {
    return Intl.message(
      'Sales Performance',
      name: 'waterSalesPerformance',
      desc: '',
      args: [],
    );
  }

  /// `Save Product`
  String get waterSaveProduct {
    return Intl.message(
      'Save Product',
      name: 'waterSaveProduct',
      desc: '',
      args: [],
    );
  }

  /// `Scan or enter barcode`
  String get waterScanOrEnterBarcode {
    return Intl.message(
      'Scan or enter barcode',
      name: 'waterScanOrEnterBarcode',
      desc: '',
      args: [],
    );
  }

  /// `Search by subscription ID, name`
  String get waterSearchBySubscriptionIdName {
    return Intl.message(
      'Search by subscription ID, name',
      name: 'waterSearchBySubscriptionIdName',
      desc: '',
      args: [],
    );
  }

  /// `Search customer name or order ID...`
  String get waterSearchCustomerOrOrderHint {
    return Intl.message(
      'Search customer name or order ID...',
      name: 'waterSearchCustomerOrOrderHint',
      desc: '',
      args: [],
    );
  }

  /// `Search Delivery Boy`
  String get waterSearchDeliveryBoy {
    return Intl.message(
      'Search Delivery Boy',
      name: 'waterSearchDeliveryBoy',
      desc: '',
      args: [],
    );
  }

  /// `Search products, ID`
  String get waterSearchProductsHint {
    return Intl.message(
      'Search products, ID',
      name: 'waterSearchProductsHint',
      desc: '',
      args: [],
    );
  }

  /// `Select from and to dates`
  String get waterSelectFromAndToDates {
    return Intl.message(
      'Select from and to dates',
      name: 'waterSelectFromAndToDates',
      desc: '',
      args: [],
    );
  }

  /// `Select Image Source`
  String get waterSelectImageSource {
    return Intl.message(
      'Select Image Source',
      name: 'waterSelectImageSource',
      desc: '',
      args: [],
    );
  }

  /// `Selling Price`
  String get waterSellingPrice {
    return Intl.message(
      'Selling Price',
      name: 'waterSellingPrice',
      desc: '',
      args: [],
    );
  }

  /// `Send Mail`
  String get waterSendMail {
    return Intl.message('Send Mail', name: 'waterSendMail', desc: '', args: []);
  }

  /// `Size`
  String get waterSize {
    return Intl.message('Size', name: 'waterSize', desc: '', args: []);
  }

  /// `Start`
  String get waterStart {
    return Intl.message('Start', name: 'waterStart', desc: '', args: []);
  }

  /// `Start Time`
  String get waterStartTime {
    return Intl.message(
      'Start Time',
      name: 'waterStartTime',
      desc: '',
      args: [],
    );
  }

  /// `Stock Added`
  String get waterStockAdded {
    return Intl.message(
      'Stock Added',
      name: 'waterStockAdded',
      desc: '',
      args: [],
    );
  }

  /// `Stock History`
  String get waterStockHistory {
    return Intl.message(
      'Stock History',
      name: 'waterStockHistory',
      desc: '',
      args: [],
    );
  }

  /// `STOCK ID: {id}`
  String waterStockIdLabel(String id) {
    return Intl.message(
      'STOCK ID: $id',
      name: 'waterStockIdLabel',
      desc: '',
      args: [id],
    );
  }

  /// `Stock Removed`
  String get waterStockRemoved {
    return Intl.message(
      'Stock Removed',
      name: 'waterStockRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Stock updated successfully`
  String get waterStockUpdatedSuccessfully {
    return Intl.message(
      'Stock updated successfully',
      name: 'waterStockUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Storage`
  String get waterStorage {
    return Intl.message('Storage', name: 'waterStorage', desc: '', args: []);
  }

  /// `Store Availability`
  String get waterStoreAvailability {
    return Intl.message(
      'Store Availability',
      name: 'waterStoreAvailability',
      desc: '',
      args: [],
    );
  }

  /// `Store Details`
  String get waterStoreDetails {
    return Intl.message(
      'Store Details',
      name: 'waterStoreDetails',
      desc: '',
      args: [],
    );
  }

  /// `Store Profile`
  String get waterStoreProfile {
    return Intl.message(
      'Store Profile',
      name: 'waterStoreProfile',
      desc: '',
      args: [],
    );
  }

  /// `Store Status (Open)`
  String get waterStoreStatusOpen {
    return Intl.message(
      'Store Status (Open)',
      name: 'waterStoreStatusOpen',
      desc: '',
      args: [],
    );
  }

  /// `Subscription accepted successfully`
  String get waterSubscriptionAcceptedSuccessfully {
    return Intl.message(
      'Subscription accepted successfully',
      name: 'waterSubscriptionAcceptedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Subscription Amount`
  String get waterSubscriptionAmount {
    return Intl.message(
      'Subscription Amount',
      name: 'waterSubscriptionAmount',
      desc: '',
      args: [],
    );
  }

  /// `Subscription Calendar`
  String get waterSubscriptionCalendar {
    return Intl.message(
      'Subscription Calendar',
      name: 'waterSubscriptionCalendar',
      desc: '',
      args: [],
    );
  }

  /// `Subscription Details`
  String get waterSubscriptionDetails {
    return Intl.message(
      'Subscription Details',
      name: 'waterSubscriptionDetails',
      desc: '',
      args: [],
    );
  }

  /// `Subscription Orders`
  String get waterSubscriptionOrders {
    return Intl.message(
      'Subscription Orders',
      name: 'waterSubscriptionOrders',
      desc: '',
      args: [],
    );
  }

  /// `Subscription paused successfully`
  String get waterSubscriptionPausedSuccessfully {
    return Intl.message(
      'Subscription paused successfully',
      name: 'waterSubscriptionPausedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Subscription rejected successfully`
  String get waterSubscriptionRejectedSuccessfully {
    return Intl.message(
      'Subscription rejected successfully',
      name: 'waterSubscriptionRejectedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Subscription resumed successfully`
  String get waterSubscriptionResumedSuccessfully {
    return Intl.message(
      'Subscription resumed successfully',
      name: 'waterSubscriptionResumedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Subscription Savings`
  String get waterSubscriptionSavings {
    return Intl.message(
      'Subscription Savings',
      name: 'waterSubscriptionSavings',
      desc: '',
      args: [],
    );
  }

  /// `Support & Legal`
  String get waterSupportLegal {
    return Intl.message(
      'Support & Legal',
      name: 'waterSupportLegal',
      desc: '',
      args: [],
    );
  }

  /// `Take a photo`
  String get waterTakeAPhoto {
    return Intl.message(
      'Take a photo',
      name: 'waterTakeAPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Tap to upload image`
  String get waterTapToUploadImage {
    return Intl.message(
      'Tap to upload image',
      name: 'waterTapToUploadImage',
      desc: '',
      args: [],
    );
  }

  /// `Temporary Store Closure`
  String get waterTemporaryStoreClosure {
    return Intl.message(
      'Temporary Store Closure',
      name: 'waterTemporaryStoreClosure',
      desc: '',
      args: [],
    );
  }

  /// `Time Slot`
  String get waterTimeSlot {
    return Intl.message('Time Slot', name: 'waterTimeSlot', desc: '', args: []);
  }

  /// `TIN/NIF Number`
  String get waterTinNifNumber {
    return Intl.message(
      'TIN/NIF Number',
      name: 'waterTinNifNumber',
      desc: '',
      args: [],
    );
  }

  /// `To date must be after from date`
  String get waterToDateAfterFromDate {
    return Intl.message(
      'To date must be after from date',
      name: 'waterToDateAfterFromDate',
      desc: '',
      args: [],
    );
  }

  /// `Today: {open} - {close}`
  String waterTodayTimings(String open, String close) {
    return Intl.message(
      'Today: $open - $close',
      name: 'waterTodayTimings',
      desc: '',
      args: [open, close],
    );
  }

  /// `TOTAL`
  String get waterTotalHeader {
    return Intl.message('TOTAL', name: 'waterTotalHeader', desc: '', args: []);
  }

  /// `Total paid`
  String get waterTotalPaid {
    return Intl.message(
      'Total paid',
      name: 'waterTotalPaid',
      desc: '',
      args: [],
    );
  }

  /// `Total Sold (All Time)`
  String get waterTotalSoldAllTime {
    return Intl.message(
      'Total Sold (All Time)',
      name: 'waterTotalSoldAllTime',
      desc: '',
      args: [],
    );
  }

  /// `Try another status filter above`
  String get waterTryAnotherStatusFilter {
    return Intl.message(
      'Try another status filter above',
      name: 'waterTryAnotherStatusFilter',
      desc: '',
      args: [],
    );
  }

  /// `Unit Type`
  String get waterUnitType {
    return Intl.message('Unit Type', name: 'waterUnitType', desc: '', args: []);
  }

  /// `UPCOMING DELIVERIES`
  String get waterUpcomingDeliveries {
    return Intl.message(
      'UPCOMING DELIVERIES',
      name: 'waterUpcomingDeliveries',
      desc: '',
      args: [],
    );
  }

  /// `Update Stock`
  String get waterUpdateStock {
    return Intl.message(
      'Update Stock',
      name: 'waterUpdateStock',
      desc: '',
      args: [],
    );
  }

  /// `Valid Upto`
  String get waterValidUpto {
    return Intl.message(
      'Valid Upto',
      name: 'waterValidUpto',
      desc: '',
      args: [],
    );
  }

  /// `Voice message`
  String get waterVoiceMessage {
    return Intl.message(
      'Voice message',
      name: 'waterVoiceMessage',
      desc: '',
      args: [],
    );
  }

  /// `Water Supply Issue`
  String get waterWaterSupplyIssue {
    return Intl.message(
      'Water Supply Issue',
      name: 'waterWaterSupplyIssue',
      desc: '',
      args: [],
    );
  }

  /// `Week`
  String get waterWeek {
    return Intl.message('Week', name: 'waterWeek', desc: '', args: []);
  }

  /// `WEEKLY PLANNER`
  String get waterWeeklyPlanner {
    return Intl.message(
      'WEEKLY PLANNER',
      name: 'waterWeeklyPlanner',
      desc: '',
      args: [],
    );
  }

  /// `Weekly Schedule`
  String get waterWeeklySchedule {
    return Intl.message(
      'Weekly Schedule',
      name: 'waterWeeklySchedule',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to {name}!`
  String waterWelcomeToShop(String name) {
    return Intl.message(
      'Welcome to $name!',
      name: 'waterWelcomeToShop',
      desc: '',
      args: [name],
    );
  }

  /// `Working hours updated successfully`
  String get waterWorkingHoursUpdated {
    return Intl.message(
      'Working hours updated successfully',
      name: 'waterWorkingHoursUpdated',
      desc: '',
      args: [],
    );
  }

  /// `You`
  String get waterYou {
    return Intl.message('You', name: 'waterYou', desc: '', args: []);
  }

  /// `Couldn't update availability. Please try again.`
  String get cleaningBookingAvailabilityFailed {
    return Intl.message(
      'Couldn\'t update availability. Please try again.',
      name: 'cleaningBookingAvailabilityFailed',
      desc: '',
      args: [],
    );
  }

  /// `CANCELLATION REASON`
  String get cleaningBookingCancelReasonHeader {
    return Intl.message(
      'CANCELLATION REASON',
      name: 'cleaningBookingCancelReasonHeader',
      desc: '',
      args: [],
    );
  }

  /// `{count} d ago`
  String cleaningBookingDaysAgo(String count) {
    return Intl.message(
      '$count d ago',
      name: 'cleaningBookingDaysAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count} h ago`
  String cleaningBookingHoursAgo(String count) {
    return Intl.message(
      '$count h ago',
      name: 'cleaningBookingHoursAgo',
      desc: '',
      args: [count],
    );
  }

  /// `Couldn't load the data. Please try again.`
  String get cleaningBookingLoadFailed {
    return Intl.message(
      'Couldn\'t load the data. Please try again.',
      name: 'cleaningBookingLoadFailed',
      desc: '',
      args: [],
    );
  }

  /// `{count} min ago`
  String cleaningBookingMinutesAgo(String count) {
    return Intl.message(
      '$count min ago',
      name: 'cleaningBookingMinutesAgo',
      desc: '',
      args: [count],
    );
  }

  /// `CANCELLED`
  String get cleaningBookingStatusCancelled {
    return Intl.message(
      'CANCELLED',
      name: 'cleaningBookingStatusCancelled',
      desc: '',
      args: [],
    );
  }

  /// `ON THE WAY`
  String get cleaningBookingStatusOnTheWay {
    return Intl.message(
      'ON THE WAY',
      name: 'cleaningBookingStatusOnTheWay',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't update the booking. Please try again.`
  String get cleaningBookingUpdateFailed {
    return Intl.message(
      'Couldn\'t update the booking. Please try again.',
      name: 'cleaningBookingUpdateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Add at least one space with its price.`
  String get cleaningSvcAddOneSpace {
    return Intl.message(
      'Add at least one space with its price.',
      name: 'cleaningSvcAddOneSpace',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't load messages.`
  String get cleaningSvcChatLoadError {
    return Intl.message(
      'Couldn\'t load messages.',
      name: 'cleaningSvcChatLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Chat with this customer isn't available yet.`
  String get cleaningSvcChatUnavailable {
    return Intl.message(
      'Chat with this customer isn\'t available yet.',
      name: 'cleaningSvcChatUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong. Please try again.`
  String get cleaningSvcGenericError {
    return Intl.message(
      'Something went wrong. Please try again.',
      name: 'cleaningSvcGenericError',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't load your services.`
  String get cleaningSvcLoadError {
    return Intl.message(
      'Couldn\'t load your services.',
      name: 'cleaningSvcLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Please select a service type.`
  String get cleaningSvcSelectServiceType {
    return Intl.message(
      'Please select a service type.',
      name: 'cleaningSvcSelectServiceType',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't load service types.`
  String get cleaningSvcTypesLoadError {
    return Intl.message(
      'Couldn\'t load service types.',
      name: 'cleaningSvcTypesLoadError',
      desc: '',
      args: [],
    );
  }

  /// `Amount due`
  String get waterAmountDue {
    return Intl.message(
      'Amount due',
      name: 'waterAmountDue',
      desc: '',
      args: [],
    );
  }

  /// `Every 2 weeks`
  String get waterBiWeekly {
    return Intl.message(
      'Every 2 weeks',
      name: 'waterBiWeekly',
      desc: '',
      args: [],
    );
  }

  /// `Delivery calendar not available yet`
  String get waterCalendarNotAvailable {
    return Intl.message(
      'Delivery calendar not available yet',
      name: 'waterCalendarNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Scheduled subscription deliveries will appear here once this feature is ready. You can see each subscription's next delivery in its details.`
  String get waterCalendarNotAvailableHint {
    return Intl.message(
      'Scheduled subscription deliveries will appear here once this feature is ready. You can see each subscription\'s next delivery in its details.',
      name: 'waterCalendarNotAvailableHint',
      desc: '',
      args: [],
    );
  }

  /// `Every {days} days`
  String waterEveryNDays(String days) {
    return Intl.message(
      'Every $days days',
      name: 'waterEveryNDays',
      desc: '',
      args: [days],
    );
  }

  /// `Monthly`
  String get waterMonthly {
    return Intl.message('Monthly', name: 'waterMonthly', desc: '', args: []);
  }

  /// `Something went wrong. Please try again.`
  String get waterSomethingWentWrong {
    return Intl.message(
      'Something went wrong. Please try again.',
      name: 'waterSomethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `Tomorrow`
  String get waterTomorrow {
    return Intl.message('Tomorrow', name: 'waterTomorrow', desc: '', args: []);
  }

  /// `Wallet`
  String get waterWallet {
    return Intl.message('Wallet', name: 'waterWallet', desc: '', args: []);
  }

  /// `Weekly`
  String get waterWeekly {
    return Intl.message('Weekly', name: 'waterWeekly', desc: '', args: []);
  }

  /// `Printer`
  String get printer {
    return Intl.message('Printer', name: 'printer', desc: '', args: []);
  }

  /// `Automatic`
  String get automaticPrinter {
    return Intl.message(
      'Automatic',
      name: 'automaticPrinter',
      desc: '',
      args: [],
    );
  }

  /// `USB printer if connected, otherwise the first paired Bluetooth printer`
  String get automaticPrinterHint {
    return Intl.message(
      'USB printer if connected, otherwise the first paired Bluetooth printer',
      name: 'automaticPrinterHint',
      desc: '',
      args: [],
    );
  }

  /// `No paired Bluetooth devices. Pair the printer in the Android Bluetooth settings first.`
  String get noPairedPrinters {
    return Intl.message(
      'No paired Bluetooth devices. Pair the printer in the Android Bluetooth settings first.',
      name: 'noPairedPrinters',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth is off or not allowed. Turn it on and allow Nearby devices for this app.`
  String get bluetoothUnavailable {
    return Intl.message(
      'Bluetooth is off or not allowed. Turn it on and allow Nearby devices for this app.',
      name: 'bluetoothUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Print test page`
  String get printTestPage {
    return Intl.message(
      'Print test page',
      name: 'printTestPage',
      desc: '',
      args: [],
    );
  }

  /// `Printer test`
  String get printerTest {
    return Intl.message(
      'Printer test',
      name: 'printerTest',
      desc: '',
      args: [],
    );
  }

  /// `Test page sent to the printer`
  String get testPageSent {
    return Intl.message(
      'Test page sent to the printer',
      name: 'testPageSent',
      desc: '',
      args: [],
    );
  }

  /// `Printing failed. Check that the printer is on and paired.`
  String get printFailed {
    return Intl.message(
      'Printing failed. Check that the printer is on and paired.',
      name: 'printFailed',
      desc: '',
      args: [],
    );
  }

  /// `Printing is available on Android devices only.`
  String get printingAndroidOnly {
    return Intl.message(
      'Printing is available on Android devices only.',
      name: 'printingAndroidOnly',
      desc: '',
      args: [],
    );
  }

  /// `Print order`
  String get printOrder {
    return Intl.message('Print order', name: 'printOrder', desc: '', args: []);
  }

  /// `Sending to the printer…`
  String get sendingToPrinter {
    return Intl.message(
      'Sending to the printer…',
      name: 'sendingToPrinter',
      desc: '',
      args: [],
    );
  }

  /// `Ticket sent to the printer`
  String get ticketSentToPrinter {
    return Intl.message(
      'Ticket sent to the printer',
      name: 'ticketSentToPrinter',
      desc: '',
      args: [],
    );
  }

  /// `{count} empty cylinders to collect`
  String gasEmptyCylindersToCollect(String count) {
    return Intl.message(
      '$count empty cylinders to collect',
      name: 'gasEmptyCylindersToCollect',
      desc: '',
      args: [count],
    );
  }

  /// `SAIMPEX Support`
  String get saimpexSupport {
    return Intl.message(
      'SAIMPEX Support',
      name: 'saimpexSupport',
      desc: '',
      args: [],
    );
  }

  /// `Open order`
  String get openOrder {
    return Intl.message('Open order', name: 'openOrder', desc: '', args: []);
  }

  /// `Reply to SAIMPEX…`
  String get replyToSaimpex {
    return Intl.message(
      'Reply to SAIMPEX…',
      name: 'replyToSaimpex',
      desc: '',
      args: [],
    );
  }

  /// `Support messages`
  String get supportMessages {
    return Intl.message(
      'Support messages',
      name: 'supportMessages',
      desc: '',
      args: [],
    );
  }

  /// `No messages from SAIMPEX yet.`
  String get noSupportMessages {
    return Intl.message(
      'No messages from SAIMPEX yet.',
      name: 'noSupportMessages',
      desc: '',
      args: [],
    );
  }

  /// `Order #{code}`
  String supportOrderCode(String code) {
    return Intl.message(
      'Order #$code',
      name: 'supportOrderCode',
      desc: '',
      args: [code],
    );
  }

  /// `Generic name`
  String get pharmacyGenericName {
    return Intl.message(
      'Generic name',
      name: 'pharmacyGenericName',
      desc: '',
      args: [],
    );
  }

  /// `e.g. Paracetamol`
  String get pharmacyGenericNameHint {
    return Intl.message(
      'e.g. Paracetamol',
      name: 'pharmacyGenericNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Generic equivalent`
  String get pharmacyGenericEquivalent {
    return Intl.message(
      'Generic equivalent',
      name: 'pharmacyGenericEquivalent',
      desc: '',
      args: [],
    );
  }

  /// `The generic version customers can choose instead. It can be another pharmacy's product.`
  String get pharmacyGenericEquivalentHelp {
    return Intl.message(
      'The generic version customers can choose instead. It can be another pharmacy\'s product.',
      name: 'pharmacyGenericEquivalentHelp',
      desc: '',
      args: [],
    );
  }

  /// `Search by name or generic name`
  String get pharmacyGenericSearchHint {
    return Intl.message(
      'Search by name or generic name',
      name: 'pharmacyGenericSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `Remove link`
  String get pharmacyGenericRemoveLink {
    return Intl.message(
      'Remove link',
      name: 'pharmacyGenericRemoveLink',
      desc: '',
      args: [],
    );
  }

  /// `Type at least 2 letters`
  String get pharmacyGenericTypeTwo {
    return Intl.message(
      'Type at least 2 letters',
      name: 'pharmacyGenericTypeTwo',
      desc: '',
      args: [],
    );
  }

  /// `No product found`
  String get pharmacyGenericNoMatch {
    return Intl.message(
      'No product found',
      name: 'pharmacyGenericNoMatch',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get pharmacyGenericNone {
    return Intl.message(
      'None',
      name: 'pharmacyGenericNone',
      desc: '',
      args: [],
    );
  }

  /// `Visible to customers`
  String get productVisible {
    return Intl.message(
      'Visible to customers',
      name: 'productVisible',
      desc: '',
      args: [],
    );
  }

  /// `Hidden until you show it`
  String get productHiddenForever {
    return Intl.message(
      'Hidden until you show it',
      name: 'productHiddenForever',
      desc: '',
      args: [],
    );
  }

  /// `Hidden until {time}`
  String productHiddenUntil(String time) {
    return Intl.message(
      'Hidden until $time',
      name: 'productHiddenUntil',
      desc: '',
      args: [time],
    );
  }

  /// `Hide`
  String get hideProduct {
    return Intl.message('Hide', name: 'hideProduct', desc: '', args: []);
  }

  /// `Show now`
  String get showProductNow {
    return Intl.message('Show now', name: 'showProductNow', desc: '', args: []);
  }

  /// `Hide this product`
  String get hideProductTitle {
    return Intl.message(
      'Hide this product',
      name: 'hideProductTitle',
      desc: '',
      args: [],
    );
  }

  /// `Customers can't see or order it while it is hidden.`
  String get hideProductHelp {
    return Intl.message(
      'Customers can\'t see or order it while it is hidden.',
      name: 'hideProductHelp',
      desc: '',
      args: [],
    );
  }

  /// `For 1 hour`
  String get hideFor1Hour {
    return Intl.message('For 1 hour', name: 'hideFor1Hour', desc: '', args: []);
  }

  /// `For 4 hours`
  String get hideFor4Hours {
    return Intl.message(
      'For 4 hours',
      name: 'hideFor4Hours',
      desc: '',
      args: [],
    );
  }

  /// `Until the end of today`
  String get hideUntilEndOfToday {
    return Intl.message(
      'Until the end of today',
      name: 'hideUntilEndOfToday',
      desc: '',
      args: [],
    );
  }

  /// `Until I show it again`
  String get hideUntilShown {
    return Intl.message(
      'Until I show it again',
      name: 'hideUntilShown',
      desc: '',
      args: [],
    );
  }

  /// `Order rules`
  String get orderRules {
    return Intl.message('Order rules', name: 'orderRules', desc: '', args: []);
  }

  /// `Couldn't load the order rules.`
  String get orderRulesUnavailable {
    return Intl.message(
      'Couldn\'t load the order rules.',
      name: 'orderRulesUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Minimum order value`
  String get minimumOrderValue {
    return Intl.message(
      'Minimum order value',
      name: 'minimumOrderValue',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get noMinimum {
    return Intl.message('None', name: 'noMinimum', desc: '', args: []);
  }

  /// `Preparation time`
  String get defaultPreparationTime {
    return Intl.message(
      'Preparation time',
      name: 'defaultPreparationTime',
      desc: '',
      args: [],
    );
  }

  /// `{minutes} min`
  String minutesShort(String minutes) {
    return Intl.message(
      '$minutes min',
      name: 'minutesShort',
      desc: '',
      args: [minutes],
    );
  }

  /// `Delivery fee`
  String get deliveryFeeLabel {
    return Intl.message(
      'Delivery fee',
      name: 'deliveryFeeLabel',
      desc: '',
      args: [],
    );
  }

  /// `{value} MRU per km`
  String deliveryFeePerKm(String value) {
    return Intl.message(
      '$value MRU per km',
      name: 'deliveryFeePerKm',
      desc: '',
      args: [value],
    );
  }

  /// `{value} MRU`
  String deliveryFeeFixed(String value) {
    return Intl.message(
      '$value MRU',
      name: 'deliveryFeeFixed',
      desc: '',
      args: [value],
    );
  }

  /// `{value}% of the order`
  String deliveryFeePercent(String value) {
    return Intl.message(
      '$value% of the order',
      name: 'deliveryFeePercent',
      desc: '',
      args: [value],
    );
  }

  /// `Free`
  String get deliveryFeeFree {
    return Intl.message('Free', name: 'deliveryFeeFree', desc: '', args: []);
  }

  /// `Delivery fee paid by`
  String get deliveryFeePaidBy {
    return Intl.message(
      'Delivery fee paid by',
      name: 'deliveryFeePaidBy',
      desc: '',
      args: [],
    );
  }

  /// `Customer`
  String get feePaidByCustomer {
    return Intl.message(
      'Customer',
      name: 'feePaidByCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Your store`
  String get feePaidByStore {
    return Intl.message(
      'Your store',
      name: 'feePaidByStore',
      desc: '',
      args: [],
    );
  }

  /// `SAIMPEX`
  String get feePaidBySaimpex {
    return Intl.message(
      'SAIMPEX',
      name: 'feePaidBySaimpex',
      desc: '',
      args: [],
    );
  }

  /// `Split: your store {percent}%, the customer the rest`
  String feePaidSplit(String percent) {
    return Intl.message(
      'Split: your store $percent%, the customer the rest',
      name: 'feePaidSplit',
      desc: '',
      args: [percent],
    );
  }

  /// `Drivers`
  String get deliveryModel {
    return Intl.message('Drivers', name: 'deliveryModel', desc: '', args: []);
  }

  /// `Your drivers and SAIMPEX drivers`
  String get deliveryModelBoth {
    return Intl.message(
      'Your drivers and SAIMPEX drivers',
      name: 'deliveryModelBoth',
      desc: '',
      args: [],
    );
  }

  /// `Your drivers only`
  String get deliveryModelOwn {
    return Intl.message(
      'Your drivers only',
      name: 'deliveryModelOwn',
      desc: '',
      args: [],
    );
  }

  /// `SAIMPEX drivers only`
  String get deliveryModelSaimpex {
    return Intl.message(
      'SAIMPEX drivers only',
      name: 'deliveryModelSaimpex',
      desc: '',
      args: [],
    );
  }

  /// `SAIMPEX sets these rules. To change them, write to SAIMPEX from Support messages or Help & Support.`
  String get orderRulesSetBySaimpex {
    return Intl.message(
      'SAIMPEX sets these rules. To change them, write to SAIMPEX from Support messages or Help & Support.',
      name: 'orderRulesSetBySaimpex',
      desc: '',
      args: [],
    );
  }

  /// `Category requests`
  String get categoryRequests {
    return Intl.message(
      'Category requests',
      name: 'categoryRequests',
      desc: '',
      args: [],
    );
  }

  /// `Need a category that isn't in the list? Ask SAIMPEX to add it. You can use it once it is approved.`
  String get categoryRequestsHelp {
    return Intl.message(
      'Need a category that isn\'t in the list? Ask SAIMPEX to add it. You can use it once it is approved.',
      name: 'categoryRequestsHelp',
      desc: '',
      args: [],
    );
  }

  /// `No requests yet.`
  String get noCategoryRequests {
    return Intl.message(
      'No requests yet.',
      name: 'noCategoryRequests',
      desc: '',
      args: [],
    );
  }

  /// `Request a new category`
  String get requestNewCategory {
    return Intl.message(
      'Request a new category',
      name: 'requestNewCategory',
      desc: '',
      args: [],
    );
  }

  /// `Category name`
  String get categoryName {
    return Intl.message(
      'Category name',
      name: 'categoryName',
      desc: '',
      args: [],
    );
  }

  /// `Why do you need it?`
  String get requestReasonHint {
    return Intl.message(
      'Why do you need it?',
      name: 'requestReasonHint',
      desc: '',
      args: [],
    );
  }

  /// `Send for approval`
  String get sendForApproval {
    return Intl.message(
      'Send for approval',
      name: 'sendForApproval',
      desc: '',
      args: [],
    );
  }

  /// `Sent. SAIMPEX will review it.`
  String get requestSentForReview {
    return Intl.message(
      'Sent. SAIMPEX will review it.',
      name: 'requestSentForReview',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get requestPending {
    return Intl.message('Pending', name: 'requestPending', desc: '', args: []);
  }

  /// `Approved`
  String get requestApproved {
    return Intl.message(
      'Approved',
      name: 'requestApproved',
      desc: '',
      args: [],
    );
  }

  /// `Rejected`
  String get requestRejected {
    return Intl.message(
      'Rejected',
      name: 'requestRejected',
      desc: '',
      args: [],
    );
  }

  /// `SAIMPEX: {note}`
  String adminNote(String note) {
    return Intl.message(
      'SAIMPEX: $note',
      name: 'adminNote',
      desc: '',
      args: [note],
    );
  }

  /// `Enter a name and a reason.`
  String get requestNameAndReason {
    return Intl.message(
      'Enter a name and a reason.',
      name: 'requestNameAndReason',
      desc: '',
      args: [],
    );
  }

  /// `Laundry`
  String get serviceKindLaundry {
    return Intl.message(
      'Laundry',
      name: 'serviceKindLaundry',
      desc: '',
      args: [],
    );
  }

  /// `Car wash`
  String get serviceKindCarWash {
    return Intl.message(
      'Car wash',
      name: 'serviceKindCarWash',
      desc: '',
      args: [],
    );
  }

  /// `Home cleaning`
  String get serviceKindHomeCleaning {
    return Intl.message(
      'Home cleaning',
      name: 'serviceKindHomeCleaning',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for Pickup`
  String get laundryWaitingForPickup {
    return Intl.message(
      'Waiting for Pickup',
      name: 'laundryWaitingForPickup',
      desc: '',
      args: [],
    );
  }

  /// `Ready for Delivery`
  String get laundryReadyForDelivery {
    return Intl.message(
      'Ready for Delivery',
      name: 'laundryReadyForDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Delivered`
  String get laundryDelivered {
    return Intl.message(
      'Delivered',
      name: 'laundryDelivered',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for Vehicle`
  String get carWashWaitingForVehicle {
    return Intl.message(
      'Waiting for Vehicle',
      name: 'carWashWaitingForVehicle',
      desc: '',
      args: [],
    );
  }

  /// `Ready for Pickup`
  String get carWashReadyForPickup {
    return Intl.message(
      'Ready for Pickup',
      name: 'carWashReadyForPickup',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Pickup`
  String get laundryConfirmPickup {
    return Intl.message(
      'Confirm Pickup',
      name: 'laundryConfirmPickup',
      desc: '',
      args: [],
    );
  }

  /// `Mark Ready for Delivery`
  String get laundryMarkReadyForDelivery {
    return Intl.message(
      'Mark Ready for Delivery',
      name: 'laundryMarkReadyForDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Mark as Delivered`
  String get laundryMarkAsDelivered {
    return Intl.message(
      'Mark as Delivered',
      name: 'laundryMarkAsDelivered',
      desc: '',
      args: [],
    );
  }

  /// `Mark Vehicles Received`
  String get carWashMarkVehiclesReceived {
    return Intl.message(
      'Mark Vehicles Received',
      name: 'carWashMarkVehiclesReceived',
      desc: '',
      args: [],
    );
  }

  /// `Mark as Ready for Pickup`
  String get carWashMarkReadyForPickup {
    return Intl.message(
      'Mark as Ready for Pickup',
      name: 'carWashMarkReadyForPickup',
      desc: '',
      args: [],
    );
  }

  /// `Slot is fully booked`
  String get rejectReasonSlotFull {
    return Intl.message(
      'Slot is fully booked',
      name: 'rejectReasonSlotFull',
      desc: '',
      args: [],
    );
  }

  /// `Unable to accept at the selected time`
  String get rejectReasonTimeUnavailable {
    return Intl.message(
      'Unable to accept at the selected time',
      name: 'rejectReasonTimeUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Temporary operational issue`
  String get rejectReasonOperationalIssue {
    return Intl.message(
      'Temporary operational issue',
      name: 'rejectReasonOperationalIssue',
      desc: '',
      args: [],
    );
  }

  /// `Customer estimate ({kg} kg)`
  String laundryCustomerEstimate(String kg) {
    return Intl.message(
      'Customer estimate ($kg kg)',
      name: 'laundryCustomerEstimate',
      desc: '',
      args: [kg],
    );
  }

  /// `Actual weight ({kg} kg)`
  String laundryActualWeight(String kg) {
    return Intl.message(
      'Actual weight ($kg kg)',
      name: 'laundryActualWeight',
      desc: '',
      args: [kg],
    );
  }

  /// `Pickup slot`
  String get laundryPickupSlot {
    return Intl.message(
      'Pickup slot',
      name: 'laundryPickupSlot',
      desc: '',
      args: [],
    );
  }

  /// `Delivery turnaround`
  String get laundryDeliveryTurnaround {
    return Intl.message(
      'Delivery turnaround',
      name: 'laundryDeliveryTurnaround',
      desc: '',
      args: [],
    );
  }

  /// `Pickup & delivery`
  String get laundryPickupAndDelivery {
    return Intl.message(
      'Pickup & delivery',
      name: 'laundryPickupAndDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Pickup`
  String get laundryPickup {
    return Intl.message('Pickup', name: 'laundryPickup', desc: '', args: []);
  }

  /// `Delivery`
  String get laundryDelivery {
    return Intl.message(
      'Delivery',
      name: 'laundryDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Payment status`
  String get laundryPaymentStatus {
    return Intl.message(
      'Payment status',
      name: 'laundryPaymentStatus',
      desc: '',
      args: [],
    );
  }

  /// `ADDITIONAL PAYMENT PENDING`
  String get laundryAdditionalPaymentPending {
    return Intl.message(
      'ADDITIONAL PAYMENT PENDING',
      name: 'laundryAdditionalPaymentPending',
      desc: '',
      args: [],
    );
  }

  /// `Already paid`
  String get laundryAlreadyPaid {
    return Intl.message(
      'Already paid',
      name: 'laundryAlreadyPaid',
      desc: '',
      args: [],
    );
  }

  /// `Final amount`
  String get laundryFinalAmount {
    return Intl.message(
      'Final amount',
      name: 'laundryFinalAmount',
      desc: '',
      args: [],
    );
  }

  /// `Balance due`
  String get laundryBalanceDue {
    return Intl.message(
      'Balance due',
      name: 'laundryBalanceDue',
      desc: '',
      args: [],
    );
  }

  /// `Verify weight`
  String get laundryVerifyWeight {
    return Intl.message(
      'Verify weight',
      name: 'laundryVerifyWeight',
      desc: '',
      args: [],
    );
  }

  /// `Actual weight`
  String get laundryActualWeightLabel {
    return Intl.message(
      'Actual weight',
      name: 'laundryActualWeightLabel',
      desc: '',
      args: [],
    );
  }

  /// `Price breakdown`
  String get laundryPriceBreakdown {
    return Intl.message(
      'Price breakdown',
      name: 'laundryPriceBreakdown',
      desc: '',
      args: [],
    );
  }

  /// `{rate} MRU / kg`
  String laundryRatePerKg(String rate) {
    return Intl.message(
      '$rate MRU / kg',
      name: 'laundryRatePerKg',
      desc: '',
      args: [rate],
    );
  }

  /// `Invoice difference`
  String get laundryInvoiceDifference {
    return Intl.message(
      'Invoice difference',
      name: 'laundryInvoiceDifference',
      desc: '',
      args: [],
    );
  }

  /// `Send Payment Request`
  String get laundrySendPaymentRequest {
    return Intl.message(
      'Send Payment Request',
      name: 'laundrySendPaymentRequest',
      desc: '',
      args: [],
    );
  }

  /// `Vehicles`
  String get carWashVehicles {
    return Intl.message(
      'Vehicles',
      name: 'carWashVehicles',
      desc: '',
      args: [],
    );
  }

  /// `Service location`
  String get carWashServiceLocation {
    return Intl.message(
      'Service location',
      name: 'carWashServiceLocation',
      desc: '',
      args: [],
    );
  }

  /// `Add-ons`
  String get carWashAddOns {
    return Intl.message('Add-ons', name: 'carWashAddOns', desc: '', args: []);
  }

  /// `Add and edit these services on the SAIMPEX vendor web panel for now.`
  String get serviceEditOnWebPanel {
    return Intl.message(
      'Add and edit these services on the SAIMPEX vendor web panel for now.',
      name: 'serviceEditOnWebPanel',
      desc: '',
      args: [],
    );
  }

  /// `This vendor type isn't in the app yet. Please use the SAIMPEX vendor web panel.`
  String get vendorTypeUseWebPanel {
    return Intl.message(
      'This vendor type isn\'t in the app yet. Please use the SAIMPEX vendor web panel.',
      name: 'vendorTypeUseWebPanel',
      desc: '',
      args: [],
    );
  }

  /// `Request new service type`
  String get requestNewServiceType {
    return Intl.message(
      'Request new service type',
      name: 'requestNewServiceType',
      desc: '',
      args: [],
    );
  }

  /// `Service type name`
  String get serviceTypeName {
    return Intl.message(
      'Service type name',
      name: 'serviceTypeName',
      desc: '',
      args: [],
    );
  }

  /// `Choose a service type`
  String get serviceChooseType {
    return Intl.message(
      'Choose a service type',
      name: 'serviceChooseType',
      desc: '',
      args: [],
    );
  }

  /// `Enter the price per kg`
  String get serviceEnterPrice {
    return Intl.message(
      'Enter the price per kg',
      name: 'serviceEnterPrice',
      desc: '',
      args: [],
    );
  }

  /// `Add at least one item`
  String get serviceAddOneItem {
    return Intl.message(
      'Add at least one item',
      name: 'serviceAddOneItem',
      desc: '',
      args: [],
    );
  }

  /// `Add at least one vehicle type`
  String get serviceAddOneVehicleType {
    return Intl.message(
      'Add at least one vehicle type',
      name: 'serviceAddOneVehicleType',
      desc: '',
      args: [],
    );
  }

  /// `Add Service`
  String get addService {
    return Intl.message('Add Service', name: 'addService', desc: '', args: []);
  }

  /// `Edit Service`
  String get editService {
    return Intl.message(
      'Edit Service',
      name: 'editService',
      desc: '',
      args: [],
    );
  }

  /// `Service image`
  String get serviceImage {
    return Intl.message(
      'Service image',
      name: 'serviceImage',
      desc: '',
      args: [],
    );
  }

  /// `Basic information`
  String get basicInformation {
    return Intl.message(
      'Basic information',
      name: 'basicInformation',
      desc: '',
      args: [],
    );
  }

  /// `Service type`
  String get serviceTypeLabel {
    return Intl.message(
      'Service type',
      name: 'serviceTypeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Processing time`
  String get processingTime {
    return Intl.message(
      'Processing time',
      name: 'processingTime',
      desc: '',
      args: [],
    );
  }

  /// `Standard (24h)`
  String get processingStandard24h {
    return Intl.message(
      'Standard (24h)',
      name: 'processingStandard24h',
      desc: '',
      args: [],
    );
  }

  /// `Express`
  String get processingExpress {
    return Intl.message(
      'Express',
      name: 'processingExpress',
      desc: '',
      args: [],
    );
  }

  /// `Pricing unit`
  String get pricingUnit {
    return Intl.message(
      'Pricing unit',
      name: 'pricingUnit',
      desc: '',
      args: [],
    );
  }

  /// `Per kg`
  String get pricingPerKg {
    return Intl.message('Per kg', name: 'pricingPerKg', desc: '', args: []);
  }

  /// `Per item`
  String get pricingPerItem {
    return Intl.message('Per item', name: 'pricingPerItem', desc: '', args: []);
  }

  /// `MRU / kg`
  String get mruPerKg {
    return Intl.message('MRU / kg', name: 'mruPerKg', desc: '', args: []);
  }

  /// `Short description`
  String get shortDescription {
    return Intl.message(
      'Short description',
      name: 'shortDescription',
      desc: '',
      args: [],
    );
  }

  /// `Enter a description`
  String get enterDescription {
    return Intl.message(
      'Enter a description',
      name: 'enterDescription',
      desc: '',
      args: [],
    );
  }

  /// `Item pricing`
  String get itemPricing {
    return Intl.message(
      'Item pricing',
      name: 'itemPricing',
      desc: '',
      args: [],
    );
  }

  /// `Set a price for each garment type. Customers choose quantities when they book.`
  String get itemPricingHelp {
    return Intl.message(
      'Set a price for each garment type. Customers choose quantities when they book.',
      name: 'itemPricingHelp',
      desc: '',
      args: [],
    );
  }

  /// `MRU / {unit}`
  String mruPerUnit(String unit) {
    return Intl.message(
      'MRU / $unit',
      name: 'mruPerUnit',
      desc: '',
      args: [unit],
    );
  }

  /// `Add vehicle type`
  String get addVehicleType {
    return Intl.message(
      'Add vehicle type',
      name: 'addVehicleType',
      desc: '',
      args: [],
    );
  }

  /// `Add-on services`
  String get addOnServices {
    return Intl.message(
      'Add-on services',
      name: 'addOnServices',
      desc: '',
      args: [],
    );
  }

  /// `Add add-on`
  String get addAddOn {
    return Intl.message('Add add-on', name: 'addAddOn', desc: '', args: []);
  }

  /// `Home / workplace pricing`
  String get homeWorkplacePricing {
    return Intl.message(
      'Home / workplace pricing',
      name: 'homeWorkplacePricing',
      desc: '',
      args: [],
    );
  }

  /// `Extra charge when you go to the customer, by distance.`
  String get homeWorkplacePricingHelp {
    return Intl.message(
      'Extra charge when you go to the customer, by distance.',
      name: 'homeWorkplacePricingHelp',
      desc: '',
      args: [],
    );
  }

  /// `Add distance range`
  String get addDistanceRange {
    return Intl.message(
      'Add distance range',
      name: 'addDistanceRange',
      desc: '',
      args: [],
    );
  }

  /// `Save changes`
  String get saveChanges {
    return Intl.message(
      'Save changes',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `kg`
  String get unitKg {
    return Intl.message('kg', name: 'unitKg', desc: '', args: []);
  }

  /// `metre`
  String get unitMetre {
    return Intl.message('metre', name: 'unitMetre', desc: '', args: []);
  }

  /// `piece`
  String get unitPiece {
    return Intl.message('piece', name: 'unitPiece', desc: '', args: []);
  }

  /// `Tap to upload image`
  String get tapToUploadImage {
    return Intl.message(
      'Tap to upload image',
      name: 'tapToUploadImage',
      desc: '',
      args: [],
    );
  }

  /// `Item name, e.g. Shirt`
  String get itemNameHint {
    return Intl.message(
      'Item name, e.g. Shirt',
      name: 'itemNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle type, e.g. Sedan`
  String get vehicleTypeHint {
    return Intl.message(
      'Vehicle type, e.g. Sedan',
      name: 'vehicleTypeHint',
      desc: '',
      args: [],
    );
  }

  /// `Add-on name, e.g. Engine Wash`
  String get addOnNameHint {
    return Intl.message(
      'Add-on name, e.g. Engine Wash',
      name: 'addOnNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Short description`
  String get addOnDescriptionHint {
    return Intl.message(
      'Short description',
      name: 'addOnDescriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `Min`
  String get minKm {
    return Intl.message('Min', name: 'minKm', desc: '', args: []);
  }

  /// `Max`
  String get maxKm {
    return Intl.message('Max', name: 'maxKm', desc: '', args: []);
  }

  /// `Service`
  String get laundryService {
    return Intl.message('Service', name: 'laundryService', desc: '', args: []);
  }

  /// `Change`
  String get change {
    return Intl.message('Change', name: 'change', desc: '', args: []);
  }

  /// `Full name`
  String get fullName {
    return Intl.message('Full name', name: 'fullName', desc: '', args: []);
  }

  /// `Add photo`
  String get addPhoto {
    return Intl.message('Add photo', name: 'addPhoto', desc: '', args: []);
  }

  /// `Booking #{code}`
  String bookingHash(String code) {
    return Intl.message(
      'Booking #$code',
      name: 'bookingHash',
      desc: '',
      args: [code],
    );
  }

  /// `Mark On the Way`
  String get cleaningMarkOnTheWay {
    return Intl.message(
      'Mark On the Way',
      name: 'cleaningMarkOnTheWay',
      desc: '',
      args: [],
    );
  }

  /// `My Cleaners`
  String get myCleaners {
    return Intl.message('My Cleaners', name: 'myCleaners', desc: '', args: []);
  }

  /// `Add Cleaner`
  String get addCleaner {
    return Intl.message('Add Cleaner', name: 'addCleaner', desc: '', args: []);
  }

  /// `Edit Cleaner`
  String get editCleaner {
    return Intl.message(
      'Edit Cleaner',
      name: 'editCleaner',
      desc: '',
      args: [],
    );
  }

  /// `Save cleaner`
  String get saveCleaner {
    return Intl.message(
      'Save cleaner',
      name: 'saveCleaner',
      desc: '',
      args: [],
    );
  }

  /// `e.g. Fatou Ba`
  String get cleanerNameHint {
    return Intl.message(
      'e.g. Fatou Ba',
      name: 'cleanerNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get cleanerActive {
    return Intl.message('Active', name: 'cleanerActive', desc: '', args: []);
  }

  /// `Only active cleaners can be assigned`
  String get cleanerActiveHelp {
    return Intl.message(
      'Only active cleaners can be assigned',
      name: 'cleanerActiveHelp',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get cleanerFilterAll {
    return Intl.message('All', name: 'cleanerFilterAll', desc: '', args: []);
  }

  /// `Available`
  String get cleanerAvailable {
    return Intl.message(
      'Available',
      name: 'cleanerAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Busy`
  String get cleanerBusy {
    return Intl.message('Busy', name: 'cleanerBusy', desc: '', args: []);
  }

  /// `Inactive`
  String get cleanerInactive {
    return Intl.message(
      'Inactive',
      name: 'cleanerInactive',
      desc: '',
      args: [],
    );
  }

  /// `Deactivated`
  String get cleanerDeactivated {
    return Intl.message(
      'Deactivated',
      name: 'cleanerDeactivated',
      desc: '',
      args: [],
    );
  }

  /// `Deactivate`
  String get cleanerDeactivate {
    return Intl.message(
      'Deactivate',
      name: 'cleanerDeactivate',
      desc: '',
      args: [],
    );
  }

  /// `Activate`
  String get cleanerActivate {
    return Intl.message(
      'Activate',
      name: 'cleanerActivate',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get cleanerNew {
    return Intl.message('New', name: 'cleanerNew', desc: '', args: []);
  }

  /// `{count} reviews`
  String cleanerReviewsCount(String count) {
    return Intl.message(
      '$count reviews',
      name: 'cleanerReviewsCount',
      desc: '',
      args: [count],
    );
  }

  /// `No cleaners yet.`
  String get noCleanersYet {
    return Intl.message(
      'No cleaners yet.',
      name: 'noCleanersYet',
      desc: '',
      args: [],
    );
  }

  /// `Assign Cleaner`
  String get assignCleaner {
    return Intl.message(
      'Assign Cleaner',
      name: 'assignCleaner',
      desc: '',
      args: [],
    );
  }

  /// `Assign {name}`
  String assignCleanerNamed(String name) {
    return Intl.message(
      'Assign $name',
      name: 'assignCleanerNamed',
      desc: '',
      args: [name],
    );
  }

  /// `Search cleaner`
  String get searchCleaner {
    return Intl.message(
      'Search cleaner',
      name: 'searchCleaner',
      desc: '',
      args: [],
    );
  }

  /// `Assigned cleaner`
  String get assignedCleaner {
    return Intl.message(
      'Assigned cleaner',
      name: 'assignedCleaner',
      desc: '',
      args: [],
    );
  }

  /// `Cleaner review: {name}`
  String cleanerReviewOf(String name) {
    return Intl.message(
      'Cleaner review: $name',
      name: 'cleanerReviewOf',
      desc: '',
      args: [name],
    );
  }

  /// `Closed`
  String get closed {
    return Intl.message('Closed', name: 'closed', desc: '', args: []);
  }

  /// `Booking slots`
  String get bookingSlots {
    return Intl.message(
      'Booking slots',
      name: 'bookingSlots',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get slotAvailable {
    return Intl.message('Available', name: 'slotAvailable', desc: '', args: []);
  }

  /// `Unavailable`
  String get slotUnavailable {
    return Intl.message(
      'Unavailable',
      name: 'slotUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Maximum bookings per slot`
  String get maxBookingsPerSlot {
    return Intl.message(
      'Maximum bookings per slot',
      name: 'maxBookingsPerSlot',
      desc: '',
      args: [],
    );
  }

  /// `Open · accepting bookings`
  String get acceptingBookings {
    return Intl.message(
      'Open · accepting bookings',
      name: 'acceptingBookings',
      desc: '',
      args: [],
    );
  }

  /// `Turn off to stop new bookings.`
  String get acceptingBookingsHelp {
    return Intl.message(
      'Turn off to stop new bookings.',
      name: 'acceptingBookingsHelp',
      desc: '',
      args: [],
    );
  }

  /// `Mark as busy`
  String get markAsBusy {
    return Intl.message('Mark as busy', name: 'markAsBusy', desc: '', args: []);
  }

  /// `Customers see you as busy and can't book for now.`
  String get markAsBusyHelp {
    return Intl.message(
      'Customers see you as busy and can\'t book for now.',
      name: 'markAsBusyHelp',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get earningsAvailable {
    return Intl.message(
      'Available',
      name: 'earningsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get earningsPending {
    return Intl.message('Pending', name: 'earningsPending', desc: '', args: []);
  }

  /// `Payout received`
  String get payoutReceived {
    return Intl.message(
      'Payout received',
      name: 'payoutReceived',
      desc: '',
      args: [],
    );
  }

  /// `No earnings yet.`
  String get noEarningsYet {
    return Intl.message(
      'No earnings yet.',
      name: 'noEarningsYet',
      desc: '',
      args: [],
    );
  }

  /// `Delivered`
  String get waterDelivered {
    return Intl.message(
      'Delivered',
      name: 'waterDelivered',
      desc: '',
      args: [],
    );
  }

  /// `In progress`
  String get waterInProgress {
    return Intl.message(
      'In progress',
      name: 'waterInProgress',
      desc: '',
      args: [],
    );
  }

  /// `No deliveries yet.`
  String get waterNoDeliveriesYet {
    return Intl.message(
      'No deliveries yet.',
      name: 'waterNoDeliveriesYet',
      desc: '',
      args: [],
    );
  }

  /// `See all`
  String get seeAll {
    return Intl.message('See all', name: 'seeAll', desc: '', args: []);
  }

  /// `Delivery fee`
  String get waterDeliveryFee {
    return Intl.message(
      'Delivery fee',
      name: 'waterDeliveryFee',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get waterCalendarTotal {
    return Intl.message(
      'Total',
      name: 'waterCalendarTotal',
      desc: '',
      args: [],
    );
  }

  /// `Morning`
  String get waterCalendarMorning {
    return Intl.message(
      'Morning',
      name: 'waterCalendarMorning',
      desc: '',
      args: [],
    );
  }

  /// `Afternoon`
  String get waterCalendarAfternoon {
    return Intl.message(
      'Afternoon',
      name: 'waterCalendarAfternoon',
      desc: '',
      args: [],
    );
  }

  /// `Evening`
  String get waterCalendarEvening {
    return Intl.message(
      'Evening',
      name: 'waterCalendarEvening',
      desc: '',
      args: [],
    );
  }

  /// `Paused`
  String get waterCalendarPaused {
    return Intl.message(
      'Paused',
      name: 'waterCalendarPaused',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get waterCalendarAll {
    return Intl.message('All', name: 'waterCalendarAll', desc: '', args: []);
  }

  /// `Search by subscription ID or name`
  String get waterSearchSubscription {
    return Intl.message(
      'Search by subscription ID or name',
      name: 'waterSearchSubscription',
      desc: '',
      args: [],
    );
  }

  /// `{count} scheduled deliveries`
  String waterScheduledDeliveries(String count) {
    return Intl.message(
      '$count scheduled deliveries',
      name: 'waterScheduledDeliveries',
      desc: '',
      args: [count],
    );
  }

  /// `No deliveries on this day.`
  String get waterNoDeliveriesThisDay {
    return Intl.message(
      'No deliveries on this day.',
      name: 'waterNoDeliveriesThisDay',
      desc: '',
      args: [],
    );
  }

  /// `Self pickup`
  String get waterSelfPickup {
    return Intl.message(
      'Self pickup',
      name: 'waterSelfPickup',
      desc: '',
      args: [],
    );
  }

  /// `Delivery`
  String get waterDelivery {
    return Intl.message('Delivery', name: 'waterDelivery', desc: '', args: []);
  }

  /// `Active`
  String get waterActive {
    return Intl.message('Active', name: 'waterActive', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
