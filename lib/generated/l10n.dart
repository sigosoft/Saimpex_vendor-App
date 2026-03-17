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
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
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
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `About Us`
  String get aboutUs {
    return Intl.message(
      'About Us',
      name: 'aboutUs',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Add Item',
      name: 'addItem',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'All Revenue',
      name: 'allRevenue',
      desc: '',
      args: [],
    );
  }

  /// `All Stores`
  String get allStores {
    return Intl.message(
      'All Stores',
      name: 'allStores',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Applied',
      name: 'applied',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message(
      'Apply',
      name: 'apply',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Beverages',
      name: 'beverages',
      desc: '',
      args: [],
    );
  }

  /// `Buy Now`
  String get buyNow {
    return Intl.message(
      'Buy Now',
      name: 'buyNow',
      desc: '',
      args: [],
    );
  }

  /// `Call us`
  String get callUs {
    return Intl.message(
      'Call us',
      name: 'callUs',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Cart',
      name: 'cart',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Chat',
      name: 'chat',
      desc: '',
      args: [],
    );
  }

  /// `Chat now`
  String get chatNow {
    return Intl.message(
      'Chat now',
      name: 'chatNow',
      desc: '',
      args: [],
    );
  }

  /// `Checkout`
  String get checkout {
    return Intl.message(
      'Checkout',
      name: 'checkout',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Clear All',
      name: 'clearAll',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Continue',
      name: 'continuee',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueText {
    return Intl.message(
      'Continue',
      name: 'continueText',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Credit',
      name: 'credit',
      desc: '',
      args: [],
    );
  }

  /// `Crop`
  String get crop {
    return Intl.message(
      'Crop',
      name: 'crop',
      desc: '',
      args: [],
    );
  }

  /// `Crop Image`
  String get cropImage {
    return Intl.message(
      'Crop Image',
      name: 'cropImage',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'd ago',
      name: 'dAgo',
      desc: '',
      args: [],
    );
  }

  /// `Debit`
  String get debit {
    return Intl.message(
      'Debit',
      name: 'debit',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Delete Cart',
      name: 'deleteCart',
      desc: '',
      args: [],
    );
  }

  /// `Delete Chat`
  String get deleteChat {
    return Intl.message(
      'Delete Chat',
      name: 'deleteChat',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Driver',
      name: 'driver',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Email us',
      name: 'emailUs',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Filters',
      name: 'filters',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Food',
      name: 'food',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gallery {
    return Intl.message(
      'Gallery',
      name: 'gallery',
      desc: '',
      args: [],
    );
  }

  /// `Got It`
  String get gotIt {
    return Intl.message(
      'Got It',
      name: 'gotIt',
      desc: '',
      args: [],
    );
  }

  /// `Grocery`
  String get grocery {
    return Intl.message(
      'Grocery',
      name: 'grocery',
      desc: '',
      args: [],
    );
  }

  /// `h ago`
  String get hAgo {
    return Intl.message(
      'h ago',
      name: 'hAgo',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Item',
      name: 'item',
      desc: '',
      args: [],
    );
  }

  /// `Items`
  String get items {
    return Intl.message(
      'Items',
      name: 'items',
      desc: '',
      args: [],
    );
  }

  /// `Item Total`
  String get itemTotal {
    return Intl.message(
      'Item Total',
      name: 'itemTotal',
      desc: '',
      args: [],
    );
  }

  /// `Km`
  String get km {
    return Intl.message(
      'Km',
      name: 'km',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `m ago`
  String get mAgo {
    return Intl.message(
      'm ago',
      name: 'mAgo',
      desc: '',
      args: [],
    );
  }

  /// `Mins`
  String get mins {
    return Intl.message(
      'Mins',
      name: 'mins',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'More Points',
      name: 'morePoints',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'My Orders',
      name: 'myOrders',
      desc: '',
      args: [],
    );
  }

  /// `My Points`
  String get myPoints {
    return Intl.message(
      'My Points',
      name: 'myPoints',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Need`
  String get need {
    return Intl.message(
      'Need',
      name: 'need',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'No messages',
      name: 'noMessages',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'No Orders',
      name: 'noOrders',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Now',
      name: 'now',
      desc: '',
      args: [],
    );
  }

  /// `OFF`
  String get off {
    return Intl.message(
      'OFF',
      name: 'off',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Ordered',
      name: 'ordered',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Out of Stock',
      name: 'outOfStock',
      desc: '',
      args: [],
    );
  }

  /// `Pay`
  String get pay {
    return Intl.message(
      'Pay',
      name: 'pay',
      desc: '',
      args: [],
    );
  }

  /// `Payment Details`
  String get paymentDetails {
    return Intl.message(
      'Payment Details',
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
    return Intl.message(
      'Place Order',
      name: 'placeOrder',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'points',
      name: 'points',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Proceed',
      name: 'proceed',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Quantity',
      name: 'quantity',
      desc: '',
      args: [],
    );
  }

  /// `Rate Order`
  String get rateOrder {
    return Intl.message(
      'Rate Order',
      name: 'rateOrder',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Redeemed',
      name: 'redeemed',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Redeem Now',
      name: 'redeemNow',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: '',
      args: [],
    );
  }

  /// `Replace`
  String get replace {
    return Intl.message(
      'Replace',
      name: 'replace',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Resend OTP',
      name: 'resendOtp',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant`
  String get restaurant {
    return Intl.message(
      'Restaurant',
      name: 'restaurant',
      desc: '',
      args: [],
    );
  }

  /// `reviews`
  String get reviews {
    return Intl.message(
      'reviews',
      name: 'reviews',
      desc: '',
      args: [],
    );
  }

  /// `SAIMPEX`
  String get saimpex {
    return Intl.message(
      'SAIMPEX',
      name: 'saimpex',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Send',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  /// `Server Down`
  String get serverDown {
    return Intl.message(
      'Server Down',
      name: 'serverDown',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Sort By',
      name: 'sortBy',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Tax',
      name: 'tax',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Today',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `To Pay`
  String get toPay {
    return Intl.message(
      'To Pay',
      name: 'toPay',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Total Bill',
      name: 'totalBill',
      desc: '',
      args: [],
    );
  }

  /// `Track Order`
  String get trackOrder {
    return Intl.message(
      'Track Order',
      name: 'trackOrder',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Try Again',
      name: 'tryAgain',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `Upto`
  String get upto {
    return Intl.message(
      'Upto',
      name: 'upto',
      desc: '',
      args: [],
    );
  }

  /// `Vendor`
  String get vendor {
    return Intl.message(
      'Vendor',
      name: 'vendor',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'View Orders',
      name: 'viewOrders',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `Yesterday`
  String get yesterday {
    return Intl.message(
      'Yesterday',
      name: 'yesterday',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Your Orders',
      name: 'yourOrders',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'You saved',
      name: 'youSaved',
      desc: '',
      args: [],
    );
  }

  /// `ORDER`
  String get order {
    return Intl.message(
      'ORDER',
      name: 'order',
      desc: '',
      args: [],
    );
  }

  /// `DATE & TIME`
  String get dateTime {
    return Intl.message(
      'DATE & TIME',
      name: 'dateTime',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'ORDER ITEMS',
      name: 'orderItems',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Subtotal',
      name: 'subtotal',
      desc: '',
      args: [],
    );
  }

  /// `Payment On`
  String get paymentOn {
    return Intl.message(
      'Payment On',
      name: 'paymentOn',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Qty',
      name: 'qty',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Reject',
      name: 'reject',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Owner',
      name: 'owner',
      desc: '',
      args: [],
    );
  }

  /// `ID`
  String get idNumber {
    return Intl.message(
      'ID',
      name: 'idNumber',
      desc: '',
      args: [],
    );
  }

  /// `Contact`
  String get contact {
    return Intl.message(
      'Contact',
      name: 'contact',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message(
      'Status',
      name: 'status',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'ACTIVE',
      name: 'active',
      desc: '',
      args: [],
    );
  }

  /// `INACTIVE`
  String get inactive {
    return Intl.message(
      'INACTIVE',
      name: 'inactive',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get viewAll {
    return Intl.message(
      'View All',
      name: 'viewAll',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Leaves',
      name: 'leaves',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get menu {
    return Intl.message(
      'Menu',
      name: 'menu',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Basket',
      name: 'basket',
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

  /// `RATING & REVIEWS`
  String get ratingReviews {
    return Intl.message(
      'RATING & REVIEWS',
      name: 'ratingReviews',
      desc: '',
      args: [],
    );
  }

  /// `Holder Name`
  String get holderName {
    return Intl.message(
      'Holder Name',
      name: 'holderName',
      desc: '',
      args: [],
    );
  }

  /// `IBAN Number`
  String get ibanNumber {
    return Intl.message(
      'IBAN Number',
      name: 'ibanNumber',
      desc: '',
      args: [],
    );
  }

  /// `SWIFT Code`
  String get swiftCode {
    return Intl.message(
      'SWIFT Code',
      name: 'swiftCode',
      desc: '',
      args: [],
    );
  }

  /// `Reg. Number`
  String get regNumber {
    return Intl.message(
      'Reg. Number',
      name: 'regNumber',
      desc: '',
      args: [],
    );
  }

  /// `Reg. Date`
  String get regDate {
    return Intl.message(
      'Reg. Date',
      name: 'regDate',
      desc: '',
      args: [],
    );
  }

  /// `GST Number`
  String get gstNumber {
    return Intl.message(
      'GST Number',
      name: 'gstNumber',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Order: ',
      name: 'orderColon',
      desc: '',
      args: [],
    );
  }

  /// `MARK LEAVE`
  String get markLeave {
    return Intl.message(
      'MARK LEAVE',
      name: 'markLeave',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'From Date',
      name: 'fromDate',
      desc: '',
      args: [],
    );
  }

  /// `To Date`
  String get toDate {
    return Intl.message(
      'To Date',
      name: 'toDate',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'SCHEDULED',
      name: 'scheduled',
      desc: '',
      args: [],
    );
  }

  /// `COMPLETED`
  String get completed {
    return Intl.message(
      'COMPLETED',
      name: 'completed',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get pending {
    return Intl.message(
      'Pending',
      name: 'pending',
      desc: '',
      args: [],
    );
  }

  /// `Accepted`
  String get accepted {
    return Intl.message(
      'Accepted',
      name: 'accepted',
      desc: '',
      args: [],
    );
  }

  /// `Preparing`
  String get preparing {
    return Intl.message(
      'Preparing',
      name: 'preparing',
      desc: '',
      args: [],
    );
  }

  /// `Ready`
  String get ready {
    return Intl.message(
      'Ready',
      name: 'ready',
      desc: '',
      args: [],
    );
  }

  /// `Delivered`
  String get delivered {
    return Intl.message(
      'Delivered',
      name: 'delivered',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message(
      'Cancelled',
      name: 'cancelled',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: '',
      args: [],
    );
  }

  /// `Membership`
  String get membership {
    return Intl.message(
      'Membership',
      name: 'membership',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `Monday`
  String get monday {
    return Intl.message(
      'Monday',
      name: 'monday',
      desc: '',
      args: [],
    );
  }

  /// `Tuesday`
  String get tuesday {
    return Intl.message(
      'Tuesday',
      name: 'tuesday',
      desc: '',
      args: [],
    );
  }

  /// `Wednesday`
  String get wednesday {
    return Intl.message(
      'Wednesday',
      name: 'wednesday',
      desc: '',
      args: [],
    );
  }

  /// `Thursday`
  String get thursday {
    return Intl.message(
      'Thursday',
      name: 'thursday',
      desc: '',
      args: [],
    );
  }

  /// `Friday`
  String get friday {
    return Intl.message(
      'Friday',
      name: 'friday',
      desc: '',
      args: [],
    );
  }

  /// `Saturday`
  String get saturday {
    return Intl.message(
      'Saturday',
      name: 'saturday',
      desc: '',
      args: [],
    );
  }

  /// `Sunday`
  String get sunday {
    return Intl.message(
      'Sunday',
      name: 'sunday',
      desc: '',
      args: [],
    );
  }

  /// `24 Hr`
  String get hr24 {
    return Intl.message(
      '24 Hr',
      name: 'hr24',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Products',
      name: 'products',
      desc: '',
      args: [],
    );
  }

  /// `ORDERS`
  String get ordersHeader {
    return Intl.message(
      'ORDERS',
      name: 'ordersHeader',
      desc: '',
      args: [],
    );
  }

  /// `Joined on`
  String get joinedOn {
    return Intl.message(
      'Joined on',
      name: 'joinedOn',
      desc: '',
      args: [],
    );
  }

  /// `Vendor Type`
  String get vendorType {
    return Intl.message(
      'Vendor Type',
      name: 'vendorType',
      desc: '',
      args: [],
    );
  }

  /// `Zone`
  String get zone {
    return Intl.message(
      'Zone',
      name: 'zone',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message(
      'Username',
      name: 'username',
      desc: '',
      args: [],
    );
  }

  /// `Coordinates`
  String get coordinates {
    return Intl.message(
      'Coordinates',
      name: 'coordinates',
      desc: '',
      args: [],
    );
  }

  /// `Owner Name`
  String get ownerName {
    return Intl.message(
      'Owner Name',
      name: 'ownerName',
      desc: '',
      args: [],
    );
  }

  /// `Owner Email`
  String get ownerEmail {
    return Intl.message(
      'Owner Email',
      name: 'ownerEmail',
      desc: '',
      args: [],
    );
  }

  /// `Owner Phone`
  String get ownerPhone {
    return Intl.message(
      'Owner Phone',
      name: 'ownerPhone',
      desc: '',
      args: [],
    );
  }

  /// `Bank Name`
  String get bankName {
    return Intl.message(
      'Bank Name',
      name: 'bankName',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Gst/Vat',
      name: 'gstVat',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'ALL MENUS',
      name: 'allMenus',
      desc: '',
      args: [],
    );
  }

  /// `ALL ITEMS`
  String get allItems {
    return Intl.message(
      'ALL ITEMS',
      name: 'allItems',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Veg Burger',
      name: 'vegBurger',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Lunch Menu',
      name: 'lunchMenu',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Breakfast',
      name: 'breakfast',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Combo Offer',
      name: 'comboOffer',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get activeLabel {
    return Intl.message(
      'Active',
      name: 'activeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Inactive`
  String get inactiveLabel {
    return Intl.message(
      'Inactive',
      name: 'inactiveLabel',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get durationLabel {
    return Intl.message(
      'Duration',
      name: 'durationLabel',
      desc: '',
      args: [],
    );
  }

  /// `Reason`
  String get reasonLabel {
    return Intl.message(
      'Reason',
      name: 'reasonLabel',
      desc: '',
      args: [],
    );
  }

  /// `Start date`
  String get startDate {
    return Intl.message(
      'Start date',
      name: 'startDate',
      desc: '',
      args: [],
    );
  }

  /// `End date`
  String get endDate {
    return Intl.message(
      'End date',
      name: 'endDate',
      desc: '',
      args: [],
    );
  }

  /// `Applied on`
  String get applyOn {
    return Intl.message(
      'Applied on',
      name: 'applyOn',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'ADD NEW MENU',
      name: 'addNewMenu',
      desc: '',
      args: [],
    );
  }

  /// `ADD NEW ITEM`
  String get addNewItem {
    return Intl.message(
      'ADD NEW ITEM',
      name: 'addNewItem',
      desc: '',
      args: [],
    );
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

  /// `Assigned`
  String get assignedStatus {
    return Intl.message(
      'Assigned',
      name: 'assignedStatus',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'PRICE',
      name: 'priceLabel',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Qty: $qty',
      name: 'qtyLabel',
      desc: '',
      args: [qty],
    );
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
    return Intl.message(
      'REDEEMED',
      name: 'redeemedStatus',
      desc: '',
      args: [],
    );
  }

  /// `POINTS`
  String get pointsLabel {
    return Intl.message(
      'POINTS',
      name: 'pointsLabel',
      desc: '',
      args: [],
    );
  }

  /// `DATE`
  String get dateLabel {
    return Intl.message(
      'DATE',
      name: 'dateLabel',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Item Id',
      name: 'itemIdLabel',
      desc: '',
      args: [],
    );
  }

  /// `Serial No`
  String get serialNoLabel {
    return Intl.message(
      'Serial No',
      name: 'serialNoLabel',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Category',
      name: 'categoryLabel',
      desc: '',
      args: [],
    );
  }

  /// `Tags`
  String get tagsLabel {
    return Intl.message(
      'Tags',
      name: 'tagsLabel',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      '[By Hotel]',
      name: 'byHotelLabel',
      desc: '',
      args: [],
    );
  }

  /// `Revenue`
  String get revenueLabel {
    return Intl.message(
      'Revenue',
      name: 'revenueLabel',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Add Items',
      name: 'addItemsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Item Type`
  String get itemTypeLabel {
    return Intl.message(
      'Item Type',
      name: 'itemTypeLabel',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Reset',
      name: 'resetButton',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submitButton {
    return Intl.message(
      'Submit',
      name: 'submitButton',
      desc: '',
      args: [],
    );
  }

  /// `Add Menu`
  String get addMenuTitle {
    return Intl.message(
      'Add Menu',
      name: 'addMenuTitle',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Is Veg',
      name: 'isVegLabel',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Yes',
      name: 'yesLabel',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get noLabel {
    return Intl.message(
      'No',
      name: 'noLabel',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Food Permit',
      name: 'foodPermit',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Ongoing',
      name: 'ongoing',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'User Name',
      name: 'userName',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'ASSIGNED',
      name: 'assigned',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'PICKED UP',
      name: 'pickedUp',
      desc: '',
      args: [],
    );
  }

  /// `DELIVERING`
  String get delivering {
    return Intl.message(
      'DELIVERING',
      name: 'delivering',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Order Ready',
      name: 'orderReady',
      desc: '',
      args: [],
    );
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

  /// `Welcome to`
  String get welcomeTo {
    return Intl.message(
      'Welcome to',
      name: 'welcomeTo',
      desc: '',
      args: [],
    );
  }

  /// `No reviews found.`
  String get noReviewsFound {
    return Intl.message(
      'No reviews found.',
      name: 'noReviewsFound',
      desc: '',
      args: [],
    );
  }

  /// `Anonymous`
  String get anonymous {
    return Intl.message(
      'Anonymous',
      name: 'anonymous',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'No comment',
      name: 'noComment',
      desc: '',
      args: [],
    );
  }

  /// `Leave`
  String get leave {
    return Intl.message(
      'Leave',
      name: 'leave',
      desc: '',
      args: [],
    );
  }

  /// `No upcoming leaves found.`
  String get noUpcomingLeavesFound {
    return Intl.message(
      'No upcoming leaves found.',
      name: 'noUpcomingLeavesFound',
      desc: '',
      args: [],
    );
  }

  /// `No completed leaves found.`
  String get noCompletedLeavesFound {
    return Intl.message(
      'No completed leaves found.',
      name: 'noCompletedLeavesFound',
      desc: '',
      args: [],
    );
  }

  /// `BASKETS`
  String get baskets {
    return Intl.message(
      'BASKETS',
      name: 'baskets',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'History',
      name: 'history',
      desc: '',
      args: [],
    );
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
