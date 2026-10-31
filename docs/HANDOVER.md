# SAIMPEX V2 Vendor App: Developer Handover

Last updated: 31 Oct 2026. Branch at time of writing: `fix/save-item-variants-options` (HEAD `706c74e`).
Repo: `sigosoft/Saimpex_vendor-App`. Flutter, Android first (iOS builds but is not set up for release).

Binding product decisions live in the backend repo:
**`sigosoft/saimpex-backend-new/docs/V2_DECISIONS_AND_PLAN.md`**.
Where that file differs from the V2 scope PDF, the FRD or V1 behaviour, that file wins.

Status words used in this document:

- **Done**: screen exists and calls a real API end to end (read in code; not always tested on a device).
- **Partial**: screen exists, but some actions are missing, mocked or not sent to the API.
- **Not started**: no screen or no code.
- **Unverified**: code was not read closely enough, or depends on server behaviour that was not checked.

---

## 1. Purpose and overview

The vendor app is used by SAIMPEX merchants to run their store from a phone:

- receive and process orders (accept, reject, prepare, mark ready, self-pickup complete);
- manage the catalogue (menus/sections, items, variants and option groups, stock, availability);
- manage their own delivery boys (drivers);
- see earnings, payouts and reports;
- chat with customers (text and voice);
- receive push notifications;
- print order receipts on a Bluetooth thermal printer (Android only).

One app serves all vendor types. After login the app opens a section based on the `vendor_type` the server returns.

| Server `vendor_type` | Meaning | App section | Section code |
|---|---|---|---|
| 1 | Food / restaurant | Grocery/Restaurant | `lib/view/`, `lib/controller/` |
| 2 | Grocery | Grocery/Restaurant | same |
| 11 | Local store | Grocery/Restaurant (uses grocery endpoints, see Risks) | same |
| 3 | Pharmacy | Pharmacy | `lib/pharmacy/` |
| 4 | Water | Water | `lib/water/` |
| 10 | Gas | Water (see Risks: backend treats gas as a service vertical) | `lib/water/` |
| 9 | Home cleaning | Home Cleaning (UI only, mock data) | `lib/home_cleaning/` |
| 7 | Laundry | none: login shows "use the vendor web panel" | - |
| 8 | Car wash | none: login shows "use the vendor web panel" | - |

Mapping code: `lib/utils/vendor_app_type.dart` (`VendorAppTypeX.fromVendorType`). Navigation: `lib/utils/vendor_app_router.dart`.

### What V2 decisions mean for this app

From `V2_DECISIONS_AND_PLAN.md` (sections 3, 5, 7, 9, 11):

| Decision | What the vendor app must do | Current state |
|---|---|---|
| **Local Store = any local shop** (bakery, fish, meat, stationery...) | Local store vendors get a working catalogue and orders. Backend has dedicated `localStore*` endpoints. | Not wired. App sends local store vendors to the grocery screens and grocery endpoints. |
| **Restaurant menu editing: easy and advanced, with menu images** | Simple add/edit for quick changes; advanced mode for variants, option groups (min/max), extras, images per menu/variant/option. | Add item sends variants/options/images (commit `bdb7b23`). Edit item does **not** send them yet. |
| **Pharmacy stock and price come from the APIs** | Inventory screens read and write stock/price through the API only; no local or hard-coded values. | Inventory list/detail/stock use the API. A "stock/price sync" API (backend phase 2) is not defined yet. |
| **Vendors manage their own drivers** | Keep Delivery Boys screens (list, add, edit, delete). Note: the FRD says the opposite; the decisions file wins. | Done for grocery/restaurant and pharmacy. Water: list and add screen exist; flows unverified. |
| **Pre-order reminder 30 min before** scheduled time; driver requested when Ready or 15 min before | Show scheduled orders, show the scheduled time on cards, handle the reminder push. | Not started. Contract pending from backend (phase 2). |
| **Grocery substitution, auto-accepted after 10 min** | Vendor proposes a replacement item per order line; show pending/accepted/auto-accepted state. | Not started. Contract pending from backend (phase 2). |
| **Balance adjustments visible in Earnings** | Show admin add/deduct entries with note, amount, balance after, date. | API exists (`GET vendorapp/earnings/balanceAdjustments`). Not used in the app. |
| **EN / FR / AR, Arabic right-to-left** | All strings translated; RTL layout correct. | Grocery/restaurant mostly translated. Water and Home Cleaning are English only. Pharmacy partly. |
| **Printing: generic** (no specific device) | Receipt printing should work with common ESC/POS printers. | Android Bluetooth ESC/POS works for grocery/restaurant orders. No iOS. Not in pharmacy/water. |
| **API responses carry `message_en/fr/ar`** | Show the message in the current app language. | Done in login and profile; other screens vary (unverified per screen). |
| **Figma is the design source** | Build screens as designed. Anything without a Figma screen: same style, and list it as "built without a Figma screen". | Figma page "Vendor Apps & Driver App" (node `5:4744`) in file `gcPrdiT2s5VbO51zOdwT36`. Developers must not edit Figma. |

---

## 2. Setup on a new machine

### 2.1 Tools

| Tool | Version |
|---|---|
| Flutter | `>= 3.44.0` required by `pubspec.lock`. Last built with **Flutter 3.47.9 stable, Dart 3.13.7**. |
| Dart SDK constraint | `^3.10.4` (`pubspec.yaml`) |
| Java (Android) | 17 (`android/app/build.gradle.kts`, `jvmTarget = 17`) |
| Android | `minSdk`/`targetSdk` follow Flutter defaults |
| Xcode | Only for iOS runs (see 2.5) |

No FVM or `.tool-versions` file is committed.

### 2.2 Clone and run

```bash
git clone https://github.com/sigosoft/Saimpex_vendor-App.git
cd Saimpex_vendor-App
git checkout fix/save-item-variants-options   # until it is merged to main
flutter pub get
# Add android/app/google-services.json first (see 2.4)
flutter run            # Android device or emulator
```

Localisation files are generated by `flutter_intl` / `intl_utils` into `lib/generated/`. After editing `lib/l10n/intl_*.arb`, regenerate with:

```bash
dart run intl_utils:generate
```

(or the Flutter Intl IDE plugin). Generated files are committed.

### 2.3 Server / base URL

There are no build flavours and no `.env`. The server is set in code:

- `lib/configs/ApiConfigs.dart`
  - `ApiConfigs.BASE_URL` = `https://dev.saimpexenterprise.com/api/vendorapp/` (DEV/test, active)
  - `ApiConfigs.IMAGE_URL` = `https://dev.saimpexenterprise.com/storage/`
  - The live URLs (`https://api.saimpexenterprise.com/...`) are present as comments.
- To point at a local Laravel server, change both values (for an Android emulator use `http://10.0.2.2:8000/api/vendorapp/`). Do not commit that change.
- Pusher (chat realtime) app key and cluster are hard-coded in `lib/configs/PusherConfig.dart`. Channel names there must match the backend broadcast channels.

The backend for V2 is `sigosoft/saimpex-backend-new`, branch **`integration/v2`**. Vendor app routes are in `routes/vendorapp.php` (prefix `vendorapp/`, Sanctum auth).
Some app commits need a backend branch that may not be deployed to DEV yet (for example the profile OTP commit says "Needs backend branch feat/vendor-profile-otp"; that work is now in `integration/v2`). Check that DEV runs `integration/v2` before you report a bug.

### 2.4 Firebase

The app calls `Firebase.initializeApp()` at start (`lib/main.dart`) and uses Messaging, Crashlytics and Analytics.

- Android: `android/app/google-services.json` is **gitignored**. Get it from the SAIMPEX Firebase project (ask Praveen) and put it in `android/app/`. Without it the Android build fails.
- iOS: there is **no** `ios/Runner/GoogleService-Info.plist`. iOS will crash at start until one is added.

### 2.5 Signing and release

- Android `applicationId` is `saimpex.vendor`. Version is in `pubspec.yaml` (`1.0.6+7` now).
- **Release builds are signed with the debug key** (`android/app/build.gradle.kts`, `signingConfig = signingConfigs.getByName("debug")`). A Play Store upload needs a real release `signingConfig` that reads a `key.properties` file (not committed).
- A file named `playstore_key` sits in the repo root on Praveen's Mac. It is **gitignored** and is not in GitHub. It is binary keystore data. Ask Praveen for the upload keystore and its passwords through a private channel. Never commit the keystore, its passwords, or `key.properties`.
- iOS bundle id is still the template value `com.example.saimpexVendor` (`ios/Runner.xcodeproj/project.pbxproj`). Not set up for App Store.
- `ApiConfigs.iosAppStoreId` is a placeholder (`123456789`).

### 2.6 Tests

`test/esc_pos_receipt_builder_test.dart` tests the receipt builder. `test/widget_test.dart` is the Flutter template counter test and will fail (the app has no counter). There is no CI.

---

## 3. Architecture

### 3.1 Folder map

```
lib/
  main.dart                 App start: Firebase, locale, GetMaterialApp, RTL wrapper
  configs/                  ApiConfigs (URLs + all endpoint names), Dioclient, RetryInterceptor,
                            PusherConfig, secure_credentials
  controller/               GetX controllers for the Grocery/Restaurant section (and shared ones)
  model/                    JSON models (hand-written, fromJson/toJson)
  view/                     Grocery/Restaurant screens: home, restaurant (menu/items), basket,
                            chat, settings (earnings, coupons, delivery boys...), profile, reports,
                            payout, notifications, login, otp, splash
  pharmacy/                 Pharmacy section: controller/, model/, view/
  water/                    Water section (also used for gas): bindings/, controller/, model/,
                            core/ (colours, assets, routes), view/, water_app_shell.dart
  home_cleaning/view/       Home Cleaning section (UI only)
  utils/                    utils.dart (storage, toasts, dialogs), vendor_app_type.dart,
                            vendor_app_router.dart, localization_service.dart, order_fulfillment.dart,
                            printing/, widgets/
  resources/colors.dart     Shared colours
  l10n/                     intl_en.arb, intl_fr.arb, intl_ar.arb (source strings)
  generated/                Generated S class (do not edit by hand)
  assets/                   Images and fonts (plus per-section asset folders under water/,
                            pharmacy/, home_cleaning/)
```

The three sections were built by different people at different times, so style differs:

- Grocery/Restaurant: classic `controller/` + `view/` + `model/` at the top of `lib/`.
- Pharmacy: own `controller/` and `model/`, but many screens call `DioClient` directly from the `State` class.
- Water: GetX with a binding (`lib/water/bindings/home_binding.dart`) and its own route constants (`lib/water/core/routes/app_routes.dart`).
- Home Cleaning: plain `StatefulWidget`s with hard-coded lists.

Follow the pattern of the section you are working in. Do not refactor across sections without agreement.

### 3.2 State management

GetX (`get: ^4.7.2`). Controllers extend `GetxController` and call `update()`; views use `GetBuilder` / `Get.put` / `Get.find`. Navigation uses `Get.to`, `Get.off`, `Get.offAll` and sometimes `Navigator.push`.

### 3.3 Networking

- `lib/configs/Dioclient.dart`: singleton `DioClient` around Dio. 20 s timeouts. Adds `Authorization: Bearer <token>` from storage on every non-login request. Has a logging interceptor (logs requests, headers and bodies in debug). Also compresses images before upload.
- `lib/configs/RetryInterceptor.dart`: retries and silent re-login. On a 401 it logs in again with the saved username and the password from secure storage.
- `lib/configs/secure_credentials.dart`: password kept in `flutter_secure_storage` (Keychain/Keystore). Older plain-text copies are migrated and deleted.
- Endpoint names: all in `ApiEndPoints` in `lib/configs/ApiConfigs.dart`. Add new endpoints there, never inline.
- Response format: `{ status, data, message: { message_en: [..], message_fr: [..], message_ar: [..] } }`. Some endpoints return `status` as the string `"true"`; code checks both.
- Storage: `getSavedObject` / `savename` in `lib/utils/utils.dart` (SharedPreferences, JSON-encoded). Keys used after login: `token`, `username`, `loginStatus`, `name`, `roleId`, `vendorType`, `vendorId`, `userId`, `selectedAppType`, `selected_locale`.
- Note: `shared_preferences` is imported directly but is not listed in `pubspec.yaml` (it comes in transitively). Add it to `pubspec.yaml` when you next touch dependencies.

### 3.4 Login and vendor-type routing

1. `lib/view/login/login.dart` → `LoginController.Login` (`lib/controller/login_controller.dart`) posts `vendorapp/login` with username, password and FCM token.
2. The login screen still shows an "app type" dropdown (`lib/view/login/widgets/login_form_card.dart`), but since commit `fb08465` the app **ignores the pick** and uses the server `vendor_type` (`VendorAppTypeX.fromVendorType`). Unsupported types (7, 8 and any unknown type) get a toast telling them to use the web panel.
3. The section is saved as `selectedAppType` and opened with `VendorAppRouter.goToSelectedApp`. On next start `lib/view/splash/splash.dart` routes the same way.
4. Inside Grocery/Restaurant, screens branch on the saved `vendorType`: `"1"` means restaurant, anything else is treated as grocery (for example `lib/view/home/vendor_home_screen.dart`, `lib/view/home/vendor_order_details.dart`, `lib/controller/item_controller.dart`).
5. Pharmacy and Water screens read `vendorType` (fallback: `selectedAppType`) and send it as the `vendor_type` query parameter.

Dead code: the OTP login path (`LoginController.sendOtp` → `lib/view/otp/otp.dart` → `OtpController.verifyOtp`) saves a fake `mock_token`. No login widget calls it. Do not revive it; delete it when convenient.

### 3.5 Localisation and RTL

- Strings: `lib/l10n/intl_en.arb` (~711 keys), `intl_fr.arb` (~706), `intl_ar.arb` (~703). Accessed with `S.of(context).key` / `S.current.key`.
- Language switch: `lib/utils/localization_service.dart` (`localeNotifier`) plus `flutter_localization`. Saved under `selected_locale`.
- RTL: `lib/main.dart` wraps the whole app in `Directionality` (RTL when language is `ar`).
- Coverage: Grocery/Restaurant screens mostly use `S`. Water (`lib/water/`) and Home Cleaning (`lib/home_cleaning/`) do not use `S` at all (English literals). Pharmacy uses `S` in a few screens only. Several widgets force `TextDirection.ltr` (for example in `lib/water/view/home/home_view.dart`), which needs checking in Arabic.
- FR and AR have a few fewer keys than EN: some strings fall back to English.

### 3.6 Realtime and push

- Push: Firebase Messaging handlers and local notifications in `lib/view/notifications/notification.dart` (foreground, background, opened-from-tap).
- Chat realtime: Pusher in `lib/controller/chat_controller.dart`, config in `lib/configs/PusherConfig.dart`.

### 3.7 Printing

- `lib/utils/printing/esc_pos_receipt_builder.dart` builds ESC/POS bytes (tested).
- `lib/utils/printing/bluetooth_escpos_printer.dart` sends bytes through the method channel `saimpex.vendor/escpos_printer`.
- Native side: `android/app/src/main/kotlin/saimpex/vendor/MainActivity.kt` (Bluetooth SPP). No iOS implementation.
- `lib/utils/printing/order_print_service.dart` fetches order details and prints. Used from `lib/controller/order_details_controller.dart`, `lib/view/home/vendor_home_screen.dart`, `lib/view/home/orders_view_all.dart`, `lib/view/home/vendor_order_details.dart` (Grocery/Restaurant only).

---

## 4. Feature status

### 4.1 By vendor type (overview)

| Vendor type | Overall | Notes |
|---|---|---|
| Restaurant (1) | **Partial**, most complete | Orders, menu, items, catalogue, stock, coupons, drivers, earnings, reports, chat, printing all on API. Gaps: edit item drops variants/options; no pre-orders; no advanced/easy split. |
| Grocery (2) | **Partial** | Same screens as restaurant with grocery endpoints, plus baskets. No substitution. |
| Local store (11) | **Partial / likely broken** | Opens grocery screens and calls grocery endpoints. Backend `groceryOrders` filters `order_type = 2`, so local store orders probably do not show. Backend `localStore*` endpoints are not used. Needs testing with a real local store account. |
| Pharmacy (3) | **Partial** | Orders, prescriptions, quotations, inventory, stock, add product, coupons, drivers, earnings, chat, notifications on API. Mostly English. No printing. |
| Water (4) | **Partial** | Orders, subscriptions (accept/reject/pause/resume), inventory, stock, earnings, chat on API. Notifications, received payouts, add coupon, subscription details/calendar are static mock UI. English only. |
| Gas (10) | **Unverified / likely broken** | Opens the Water section and calls `water*` endpoints. Backend treats type 10 as a service vertical (`HomeController`: `isService` for 7, 8, 9, 10). Must be confirmed with backend. |
| Laundry (7) | **Not started** in app | Blocked at login; use web panel. |
| Car wash (8) | **Not started** in app | Blocked at login; use web panel. |
| Home cleaning (9) | **Partial (UI only)** | Screens from Figma with hard-coded bookings (`lib/home_cleaning/view/home_cleaning_home.dart`). Only profile, logout and delete account call the API (`lib/home_cleaning/view/home_cleaning_account_view.dart`). Backend `service*` endpoints exist but are not used. |

### 4.2 By feature, Grocery / Restaurant / Local store section

| Feature | Status | Main files | Notes |
|---|---|---|---|
| Home / orders list | Done | `lib/view/home/vendor_home_screen.dart`, `lib/view/home/orders_view_all.dart`, `lib/controller/home_controller.dart` | `vendorapp/home`. Auto-accept toggle (`updateAutoAcceptMode`). |
| Order details and actions | Done | `lib/view/home/vendor_order_details.dart`, `lib/controller/order_details_controller.dart` | accept / cancel (reject reasons) / prepare / ready / self-pickup complete, restaurant vs grocery endpoints. |
| Dashboard | Done (unverified on device) | `lib/view/home/dashboard.dart`, `lib/controller/dashboard_controller.dart` | |
| Menus / sections, categories, tags | Done | `lib/controller/menucontroller.dart`, `lib/view/restaurant/add_menu_screen.dart`, `lib/view/restaurant/edit_menu_screen.dart`, `lib/view/restaurant/restaurant_management_screen.dart` | Menu images via `uploadRestaurantMenuImages` / `uploadGroceryMenuImages` (`lib/controller/profile_controller.dart`). |
| Items: add | Done | `lib/view/restaurant/add_items_screen.dart`, `lib/controller/item_controller.dart` (`addItem`) | Restaurant uses `addRestaurantCatalogItem`; grocery uses `addGroceryMenuItem`. |
| Items: edit | Partial | `lib/view/restaurant/edit_items_screen.dart`, `ItemController.updateItemAfterEdit` | Sends price, attribute, prep time, tags, one image only, to `updateRestaurantMenuItem` / `updateGroceryMenuItem`. Variants and option groups shown in the UI are **not sent**. Still sends `serial_number` and `image`, which the catalogue API does not read (add was fixed to `serial_no` / `images[]`). |
| Variants and option groups | Partial | `lib/controller/item_controller.dart` (`CatalogVariant`, `CatalogOptionGroup`), `lib/view/restaurant/item_customization_bottom_sheet.dart` | Add: sends `has_variants`, `variant_group_name`, `variants`, `option_groups` (JSON) plus `variant_images[i]` and option images; validates min/max. Edit: not sent. Grocery: not supported. |
| Catalogue import / export | Partial | `lib/controller/profile_controller.dart`, `lib/controller/menucontroller.dart` | Template download and `importRestaurantCatalogItems` exist. `exportMenuItems` and `importRestaurantMenuItems` have **no backend route** (see API map). |
| AI image enhance | Done (unverified) | `lib/view/restaurant/restaurant_management_screen.dart`, `ApiEndPoints.imageEnhance` | Calls `openai-image-enhance`. |
| Stock | Done | `lib/view/restaurant/Widgets/view_stock_history_screen.dart`, `ItemController` | Stock logs + update for restaurant and grocery. |
| Availability | Done | `ItemController.updateItemStatus` | Falls back to `vendor/...` paths that do not exist on the backend (harmless, but remove). |
| Baskets (grocery) | Done (unverified) | `lib/view/basket/basketlisting.dart`, `lib/controller/basket_controller.dart`, `lib/controller/redeemed_customers_controller.dart` | |
| Coupons | Done | `lib/view/settings/coupons_screen.dart`, `lib/view/settings/add_coupon_screen.dart`, `lib/controller/coupon_controller.dart` | |
| Drivers (delivery boys) | Done | `lib/view/settings/delivery_boys.dart`, `lib/view/settings/add_delivery_boy_screen.dart`, `lib/controller/delivery_boys_controller.dart` | List, add, edit, detail, delete. |
| Earnings / payouts | Partial | `lib/view/settings/earnings.dart`, `lib/view/settings/earnings_all_orders.dart`, `lib/view/settings/payout_details.dart`, `lib/controller/payout_controller.dart` | Summary, orders, payout history/detail done. **Balance adjustments not shown.** |
| Sales reports | Done (unverified) | `lib/view/reports/sales_reports.dart`, `lib/controller/sales_report_controller.dart` | |
| Working hours, leave, busy mode | Done (unverified) | `lib/controller/profile_controller.dart`, `lib/view/restaurant/leave_history_screen.dart` | |
| Profile edit | Done | `lib/view/profile/edit_profile.dart`, `lib/controller/profile_controller.dart` | Name/photo via `profile/update`; phone change needs WhatsApp OTP via `profile/sendOtp` (commit `706c74e`). |
| Ratings and reviews | Done (unverified) | `lib/view/restaurant/rating_reviews_screen.dart` | |
| Chat (text + voice) | Done | `lib/view/chat/ChatListing.dart`, `lib/view/chat/ChatDetails.dart`, `lib/controller/chat_controller.dart` | Pusher realtime, voice via `record` / `audioplayers`. |
| Notifications | Done | `lib/view/notifications/notifications.dart`, `lib/controller/notification_controller.dart`, `lib/view/notifications/notification.dart` | |
| Printing | Done (Android) | `lib/utils/printing/` | No iOS. Printer selection UI: unverified. |
| Pre-orders | Not started | - | Contract pending from backend. |
| Grocery substitution | Not started | - | Contract pending from backend. |
| Local store endpoints | Not started | - | Backend `localStore*` routes exist. |
| Kitchen board | Out of scope here | - | Separate app `sigosoft/Saimpex-Kitchen-App`. |

### 4.3 By feature, Pharmacy section

| Feature | Status | Main files | Notes |
|---|---|---|---|
| Orders + prescriptions | Done | `lib/pharmacy/view/pharmacy_home.dart`, `lib/pharmacy/controller/pharmacy_home_controller.dart`, `lib/pharmacy/view/order_details_screen.dart`, `lib/pharmacy/view/otc_order_details_screen.dart`, `lib/pharmacy/controller/pharmacy_order_details_controller.dart` | accept / cancel / prepare / ready; review, mark reviewed, reject prescription. |
| Quotation (per item) | Done (unverified against V2 per-item quote) | `lib/pharmacy/view/create_quotation_screen.dart`, `lib/pharmacy/controller/create_quotation_controller.dart` | `submitPharmacyPrescriptionQuote`. Backend phase 1 plans a "pharmacy per-item quote"; recheck the contract. |
| Inventory, stock, availability | Done | `lib/pharmacy/view/pharmacy_inventory_screen.dart`, `lib/pharmacy/view/pharmacy_inventory_details_screen.dart` | Stock and price from API. |
| Add / edit product | Done | `lib/pharmacy/view/pharmacy_add_product_screen.dart` | Has barcode scanner (`mobile_scanner`). |
| Category request | Not started | - | Backend has `requestPharmacyCategory`. Scope: categories are admin-managed; vendor may request one. |
| Coupons | Done | `lib/pharmacy/view/pharmacy_coupons_screen.dart`, `lib/pharmacy/view/pharmacy_add_coupon_screen.dart` | |
| Drivers | Done | `lib/pharmacy/view/pharmacy_delivery_boys_screen.dart` (uses shared add screen) | |
| Earnings / payouts | Partial | `lib/pharmacy/view/pharmacy_earnings_screen.dart`, `lib/pharmacy/view/pharmacy_payout_details_screen.dart`, `lib/pharmacy/view/pharmacy_received_payouts_screen.dart` | No balance adjustments. |
| Profile, hours, leave, business settings | Done (unverified) | `lib/pharmacy/view/pharmacy_profile_screen.dart`, `lib/pharmacy/view/pharmacy_working_hours_screen.dart`, `lib/pharmacy/view/pharmacy_leave_management_screen.dart`, `lib/pharmacy/view/pharmacy_business_settings_screen.dart` | Profile edit through OTP endpoints: not wired here. |
| Chat | Done | `lib/pharmacy/view/pharmacy_chat_screen.dart`, `lib/pharmacy/controller/pharmacy_chat_controller.dart` | |
| Notifications | Done | `lib/pharmacy/view/pharmacy_notifications_screen.dart` | |
| Printing | Not started | - | |
| Localisation | Partial | - | Most pharmacy screens are English literals. |

### 4.4 By feature, Water / Gas section

| Feature | Status | Main files | Notes |
|---|---|---|---|
| Orders | Done | `lib/water/view/home/home_view.dart`, `lib/water/controller/home_controller.dart`, `lib/water/view/order_details/order_details_view.dart` | accept / prepare / ready / cancel. Backend also has `markAsDeliveredWaterOrder` (not used). |
| Subscriptions | Partial | `lib/water/controller/home_controller.dart`, `lib/water/view/home/pause_subscription_sheet.dart`, `lib/water/view/subscription_details/subscription_details_view.dart`, `lib/water/view/subscription_calendar/subscription_calendar_view.dart` | List, accept, reject, pause, resume on API. Details and calendar screens use static data. Backend `waterSubscriptionDetails` not used. |
| Subscription plans | Not started | - | Backend `waterPlans`, `addWaterPlan`, `updateWaterPlan` exist. |
| Inventory, stock, price | Done | `lib/water/view/inventory/inventory_view.dart`, `lib/water/controller/inventory_controller.dart`, `lib/water/controller/inventory_details_controller.dart`, `lib/water/view/inventory/add_product_view.dart` | |
| Coupons | Partial | `lib/water/view/account/coupons_view.dart`, `lib/water/view/account/add_coupon_view.dart` | List on API; add/edit screen does not call the API. |
| Drivers | Partial (unverified) | `lib/water/view/account/delivery_boys_view.dart` | List on API; opens shared add screen. |
| Earnings | Partial | `lib/water/view/account/earnings_view.dart`, `lib/water/view/account/payout_details_view.dart` | `lib/water/view/account/received_payouts_view.dart` is static. No balance adjustments. |
| Profile, hours, leave, business settings | Done (unverified) | `lib/water/view/account/store_profile_view.dart`, `lib/water/view/account/working_hours_view.dart`, `lib/water/view/account/leave_management_view.dart`, `lib/water/view/account/business_settings_view.dart` | |
| Chat | Done | `lib/water/view/chat/messages_list_view.dart`, `lib/water/view/chat/chat_view.dart` | Reuses `ChatController`. |
| Notifications | Partial (mock) | `lib/water/view/notifications/notifications_view.dart` | Hard-coded list. |
| Printing | Not started | - | |
| Localisation | Not started | - | English literals only. |

### 4.5 Home Cleaning

| Feature | Status | Files |
|---|---|---|
| Home / bookings | Partial (mock) | `lib/home_cleaning/view/home_cleaning_home.dart`, `lib/home_cleaning/view/booking_details_view.dart`, `lib/home_cleaning/view/reject_booking_sheet.dart` |
| Services | Partial (mock) | `lib/home_cleaning/view/my_services_view.dart`, `lib/home_cleaning/view/add_service_view.dart` |
| Chat | Partial (mock) | `lib/home_cleaning/view/chat/home_cleaning_messages_view.dart`, `lib/home_cleaning/view/chat/home_cleaning_conversation_view.dart` |
| Account | Partial | `lib/home_cleaning/view/home_cleaning_account_view.dart` (profile, logout, delete on API) |

---

## 5. API map

Base: `{BASE_URL}` = `https://<host>/api/vendorapp/`. All routes except `login` need `Authorization: Bearer <token>`. Source of truth: `saimpex-backend-new/routes/vendorapp.php` on `integration/v2`.

### 5.1 Used now (grouped)

| Area | Endpoints (method) |
|---|---|
| Auth / app | `login` (POST), `logout` (POST), `settings`, `vendorappSettings`, `deleteAccount` (GET) |
| Profile | `profile` (GET), `profile/sendOtp` (POST `country_code`, `mobile`), `profile/update` (POST `name`, photo, optional `country_code` + `mobile` + `otp`), `updateWorkingHours`, `markLeave`, `unmarkLeave`, `updateBusyMode`, `updateAutoAcceptMode`, `businessSettings` (GET), `ratingsReviews` |
| Home / dashboard | `home`, `dashboard`, `notifications` |
| Restaurant orders | `restaurantOrderDetail`, `acceptRestaurantOrder`, `cancelRestaurantOrder`, `prepareRestaurantOrder`, `markAsReadyRestaurantOrder`, `markSelfPickupCompleted` (POST) |
| Grocery orders | `groceryOrderDetail`, `acceptGroceryOrder`, `cancelGroceryOrder`, `prepareGroceryOrder`, `markAsReadyGroceryOrder` |
| Restaurant menu / items | `restaurantMenus`, `restaurantMenuDetails`, `addRestaurantMenu`, `updateRestaurantMenu`, `deleteRestaurantMenu`, `uploadRestaurantMenuImages`, `restaurantMenuItems`, `restaurantMenuItemDetail`, `addRestaurantMenuItem`, `updateRestaurantMenuItem`, `deleteRestaurantMenuItem`, `addRestaurantCatalogItem`, `restaurantCatalogItems`, `restaurantCatalogItemDetail`, `updateRestaurantCatalogItemStatus`, `updateItemAvailabilityStatus`, `restaurantMenuItemStockLogs`, `updateRestaurantItemStock`, `getRestaurantMenus`, `getRestaurantCategories`, `getRestaurantTags`, `getRestaurantAttributes`, `downloadRestaurantCatalogTemplate`, `importRestaurantCatalogItems` |
| Menu categories / tags | `menuCategories`, `addMenuCategory`, `updateMenuCategory`, `updateMenuCategoryStatus`, `deleteMenuCategory`, `menuTags`, `addMenuTag`, `updateMenuTag`, `updateMenuTagStatus`, `deleteMenuTag` |
| Grocery menu / items | `groceryMenus`, `groceryMenuDetails`, `addGroceryMenu`, `updateGroceryMenu`, `deleteGroceryMenu`, `uploadGroceryMenuImages`, `groceryMenuItems`, `groceryMenuItemDetail`, `addGroceryMenuItem`, `updateGroceryMenuItem`, `deleteGroceryMenuItem`, `updateGroceryItemAvailabilityStatus`, `groceryMenuItemStockLogs`, `updateGrocerytItemStock`, `getAllGroceryMenus`, `getGroceryCategories`, `getGroceryTags`, `getGroceryAttributes`, `uploadGroceryBulkMenu` |
| Baskets | `baskets`, `basketDetail`, `basketRedeemedCustomers` |
| Reports | `resturantReport` (sic), `restaurantReportDownload`, `groceryReport`, `groceryReportDownload` |
| Coupons | `coupons`, `addCoupon`, `updateCoupon`, `updateCouponStatus` (GET), `deleteCoupon` |
| Drivers | `deliveryBoys`, `deliveryBoyDetail`, `addDeliveryBoy`, `updateDeliveryBoy`, `deleteDeliveryBoy` |
| Earnings | `earnings/summary`, `earnings/orders`, `earnings/pendingOrderPayments`, `earnings/payoutHistory`, `earnings/payoutDetail`, `receivedPayouts` |
| Pharmacy | `pharmacyOrders`, `pharmacyOrderDetail`, `pharmacyPrescriptions`, `pharmacyPrescriptionDetails`, `acceptPharmacyOrder`, `cancelPharmacyOrder`, `preparePharmacyOrder`, `markAsReadyPharmacyOrder`, `reviewPharmacyPrescription`, `markPharmacyPrescriptionReviewed`, `rejectPharmacyPrescription`, `submitPharmacyPrescriptionQuote`, `pharmacyMenuItems`, `pharmacyMenuItemDetail`, `addPharmacyMenuItem`, `updatePharmacyMenuItem`, `deletePharmacyMenuItem`, `updatePharmacyItemStock`, `updatePharmacyItemAvailabilityStatus` |
| Water | `waterOrders`, `waterOrderDetail`, `acceptWaterOrder`, `prepareWaterOrder`, `markAsReadyWaterOrder`, `cancelWaterOrder`, `waterMenuItems`, `waterMenuItemDetail`, `addWaterMenuItem`, `updateWaterMenuItem`, `deleteWaterMenuItem`, `updateWaterItemStock`, `waterSubscriptions`, `acceptWaterSubscription`, `rejectWaterSubscription`, `pauseWaterSubscription`, `resumeWaterSubscription` |
| Chat | `chat/allConversations`, `chat/getConversation`, `chat/sendMessage`, `chat/markAsRead`, `chat/totalUnreadMessagesCount`, `customers/search` |
| CMS | `getTermsandConditions`, `getPrivacyPolicy`, `getContact`, `getAbout` |
| Images | `openai-image-enhance` (POST) |

### 5.2 Called by the app but missing on the backend

| App constant (`lib/configs/ApiConfigs.dart`) | Path | Used in | Action |
|---|---|---|---|
| `exportMenuItems` | `exportMenuItems` | `lib/controller/menucontroller.dart` | No route. Ask backend or remove the button. |
| `uploadMenuItems` / `importRestaurantMenuItems` | `importRestaurantMenuItems` | `lib/controller/menucontroller.dart`, `lib/controller/profile_controller.dart` | No route. Use `importRestaurantCatalogItems` / `uploadRestaurantBulkMenu`. |
| `restaurantCatalogItemDetail` | `vendor/restaurantCatalogItemDetail` | `lib/view/restaurant/Widgets/view_item_details.dart` | No route; the `...Alt` path without `vendor/` exists. |
| `updateRestaurantCatalogItemStatusAlt` | `vendor/updateRestaurantCatalogItemStatus` | `lib/controller/item_controller.dart` | No route; fallback only. |
| `importGroceryMenuItems` | `importGroceryMenuItems` | not used | Delete constant. |

### 5.3 Exists on backend, not used by the app yet

| Endpoint | Purpose |
|---|---|
| `GET earnings/balanceAdjustments` | Admin add/deduct entries. Returns `data.adjustments[]` with `id`, `type` (`add`/`deduct`), `amount`, `balance_after`, `note`, `added_by`, `date` (latest 100). |
| `localStore*` (orders, menus, items, stock, reports, bulk import, `acceptLocalStoreOrder`...) | Local store vendor type 11. |
| `service*` (`serviceDashboard`, `serviceBookings`, `serviceBookingDetail`, `updateServiceBookingStatus`, `serviceItems`, `addServiceItem`, `serviceHours`, `serviceEarnings`, ...) | Home cleaning, laundry, car wash (and gas per backend). |
| `catalogOrders`, `catalogOrderDetail`, `acceptCatalogOrder`, `prepareCatalogOrder`, `markAsReadyCatalogOrder`, `markAsPickUpCatalogOrder`, `cancelCatalogOrder` | Generic catalogue order flow (unverified which vendor types use it). |
| `markAsPickUpRestaurantOrder`, `markAsPickUpGroceryOrder`, `markOrderAsRead`, `unreadOrdersCount` | Order pickup and unread badge. |
| `waterPlans`, `addWaterPlan`, `updateWaterPlan`, `waterSubscriptionDetails`, `markAsDeliveredWaterOrder`, `waterCategories`, `requestWaterCategory` | Water plans/subscriptions/categories. |
| `pharmacyCategories`, `requestPharmacyCategory`, `pharmacyCategoryRequests` | Pharmacy category requests. |
| `menuSubCategories` and related | Menu sub-categories. |
| `updateRestaurantCatalogItem`, `deleteRestaurantCatalogItem`, `updateRestaurantMenuStock`, `restaurantMenuStockLogs` | Catalogue item edit (needed for variants on edit). |
| `updateDeliveryDistance`, `addDeliveryDistance`, `updateExpressDelivery`, `updateStoreAvailability`, `updatePassword` | Store settings. |

### 5.4 Planned (contract pending from backend)

Do not build against guessed contracts. Ask the backend owner for the request/response first (decisions file, section 1).

| Feature | Backend phase | Expected need | Status |
|---|---|---|---|
| Pre-order list + reminder push 30 min before | 2 | `scheduled_at` on order list/detail; FCM type for reminder | contract pending from backend |
| Grocery substitution proposal (10-min auto-accept) | 2 | propose replacement per line; status of proposal | contract pending from backend |
| Menu images / advanced editing | 2 | item update that accepts variants, option groups, images | contract pending from backend (check `updateRestaurantCatalogItem`) |
| Pharmacy stock/price sync | 2 | bulk stock/price update | contract pending from backend |
| Local store categories | 2 | category list/request for type 11 | contract pending from backend |
| Drivers (V2 rules) | 2 | any change to `deliveryBoys` contract | contract pending from backend |
| Pharmacy per-item quote (V2) | 1 | per-item availability/substitute in quote | contract pending from backend |

---

## 6. Prioritised pending work

Each item: what to do, then acceptance criteria (AC).

**P1. Show balance adjustments in Earnings (all sections).**
Add `ApiEndPoints.earningsBalanceAdjustments = "earnings/balanceAdjustments"`; show a list in `lib/view/settings/earnings.dart`, `lib/pharmacy/view/pharmacy_earnings_screen.dart`, `lib/water/view/account/earnings_view.dart`. No Figma screen: build in the same card style and note it as "built without a Figma screen".
AC: an admin adjustment made in the admin panel appears with +/- amount, note, balance after and date; empty state shown when none; labels in EN/FR/AR.

**P2. Edit item saves variants, option groups and images.**
`ItemController.updateItemAfterEdit` must send the same fields as `addItem` (and `serial_no`, `images[]`). Confirm with backend whether to call `updateRestaurantCatalogItem` instead of `updateRestaurantMenuItem`.
AC: open an item with variants, change a variant price and an option group min/max, save, reopen: changes are there; customer app shows them.

**P3. Local store vendors (type 11) use `localStore*` endpoints.**
Branch on `vendorType == "11"` in orders, order actions, menus, items, stock, reports, bulk import.
AC: a local store test account sees its orders, can accept → prepare → ready, can add/edit an item and update stock.

**P4. Confirm and fix gas (type 10).**
Ask backend whether gas uses `water*` or `service*` endpoints, then route accordingly.
AC: a gas test account sees its orders and can process them end to end.

**P5. Pre-orders (after backend phase 2 contract).**
AC: scheduled orders show the scheduled date/time and a badge; the vendor gets a push 30 minutes before; tapping it opens the order.

**P6. Grocery substitution (after backend phase 2 contract).**
AC: vendor can pick a replacement for an order line; the order shows "waiting for customer" with a 10-minute countdown; after 10 minutes without reply it shows auto-accepted; totals update.

**P7. Easy vs advanced menu editing (restaurant).**
AC: a quick-edit path (name, price, availability, photo) in one screen; advanced path for variants, option groups with min/max, extras and images; menu images upload and show in the customer app.

**P8. Localisation of Water, Pharmacy and Home Cleaning.**
Move literals to the ARB files.
AC: switching to French or Arabic translates every visible string in these sections; Arabic layout is right-to-left with no clipped or mirrored-wrong icons.

**P9. Replace mock screens in Water.**
Notifications, received payouts, add/edit coupon, subscription details and calendar must use the API.
AC: no hard-coded sample data remains in `lib/water/view/`.

**P10. Home Cleaning on `service*` endpoints.**
AC: bookings, booking detail/status changes, services CRUD and hours use the backend; no hard-coded bookings.

**P11. Laundry and car wash sections (if confirmed for the app).**
Today these vendors use the web panel. Only build when Praveen confirms; then use `service*` endpoints and Figma.
AC: login no longer blocks types 7 and 8; bookings flow works.

**P12. Printing beyond Android restaurant/grocery.**
AC: print button on pharmacy and water order details; works with a generic 58/80 mm ESC/POS Bluetooth printer; printer choice remembered.

**P13. Release readiness.**
Real release signing (`key.properties`, not committed); iOS bundle id + `GoogleService-Info.plist`; fix or delete `test/widget_test.dart`; remove dead OTP login, `vendor/` fallbacks, unused deps (`tflite_flutter`, `camera`); add `shared_preferences` to `pubspec.yaml`; disable request/header logging in release.
AC: `flutter analyze` clean of errors; `flutter test` passes; signed release AAB builds on a clean machine.

---

## 7. Conventions

- **Branches**: `main` is the default. Work on a `fix/...` or `feat/...` branch and open a PR. Nothing is merged to `main` or released without Praveen's go-ahead.
- **Commits**: older history uses "commit after api integration on DD/MM/YYYY". From `bdb7b23` onwards: imperative subject line in plain English ("Save variants, option groups and images when adding restaurant items"), blank line, body that explains why and which API fields changed, and the backend branch it needs. Use the new style.
- **Endpoints**: add to `ApiEndPoints` in `lib/configs/ApiConfigs.dart`; never inline strings.
- **Server messages**: show `message_en` / `message_fr` / `message_ar` for the current language.
- **Strings**: add to all three ARB files, regenerate, use `S.of(context)`.
- **Design**: follow Figma; do not edit Figma. Note any screen built without a Figma design in this file.
- **No secrets in git**: no keystores, passwords, `key.properties`, `google-services.json`, API keys or tokens. Do not log tokens or passwords (commit `fb08465` removed token logs; keep it that way).
- **Base URL**: do not commit a local URL in `ApiConfigs.dart`.

---

## 8. Known issues and risks

1. **Local store routed to grocery endpoints.** Backend `groceryOrders` filters `order_type = 2`; local store orders likely never appear. Unverified with a real account.
2. **Gas routed to Water section**, but backend `HomeController` treats type 10 as a service vertical. Needs a backend decision.
3. **Edit item loses variants/options** (UI shows them, save does not send them).
4. **Endpoints with no backend route**: `exportMenuItems`, `importRestaurantMenuItems`, `vendor/...` fallbacks (see 5.2). These buttons fail.
5. **Mock data** in Water notifications, received payouts, add coupon, subscription details/calendar, and all of Home Cleaning bookings/services/chat.
6. **Dead OTP login path** saves a fake `mock_token` (`lib/controller/otp_controller.dart`). Not reachable now; remove.
7. **Release signed with the debug key**; iOS not configured (template bundle id, no Firebase plist).
8. **Localisation gaps**: Water and Home Cleaning English only; FR/AR missing a few keys; some widgets force LTR.
9. **Logging**: `DioClient` logs headers and bodies (includes the Bearer token) in all builds. Guard with `kDebugMode`.
10. **Pusher key hard-coded** in `lib/configs/PusherConfig.dart` (a public key, but it should come from config so DEV and LIVE can differ).
11. **No automated tests** beyond the receipt builder; template widget test fails.
12. **Scope conflict**: the FRD says vendors must not manage drivers; the V2 decisions file says they can. Follow the decisions file.
13. **Login dropdown** for app type is still shown but ignored. Consider hiding it to avoid confusion.
14. Unused heavy dependencies (`tflite_flutter`, `camera`) increase app size.

---

## 9. Vendor web panel (related project)

- Repo: `praveensigo/saimpex-vendor-phase2` (GitHub), branch `fix/v2-dev-server` (latest commit "Build against the V2 dev server").
- Stack: Vue 3 + Vite, Vuexy template, Pinia, vue-i18n, axios/ofetch, pusher-js.
- API: the **vendor web API** `https://<host>/api/vendor` (`routes/vendor.php` in the backend), not `vendorapp`. Config in `.env` (`VITE_VENDOR_API_BASE_URL`, `VITE_STORAGE_BASE_URL`, `VITE_PUSHER_APP_KEY`, `VITE_PUSHER_APP_CLUSTER`; see `.env.example`). `.env.production` points at the DEV server.
- Run: `npm install` (or `pnpm install`), `npm run dev`, `npm run build`.
- Coverage: pages for restaurant, grocery, local store, pharmacy, water, laundry, car wash, services (bookings, types), courier, express, baskets, coupons, delivery boys, earnings, reports, chat, notifications, settings, staff. Integration notes in its `docs/` folder (`CARWASH_INTEGRATION.md`, `LAUNDRY_INTEGRATION.md`, `PHARMACY_INTEGRATION.md`, `WATER_INTEGRATION.md`).
- Relation to this app: same vendors, same database, different API prefix. It covers the vendor types this app blocks (laundry, car wash) and is where the login toast sends them. When you add a feature to the app, check whether the web panel already has it; the matching `routes/vendor.php` controller often shows the business rules. Keep behaviour the same in both.

---

## 10. Useful references

- Decisions and API phases: `sigosoft/saimpex-backend-new/docs/V2_DECISIONS_AND_PLAN.md`
- Backend vendor app routes: `sigosoft/saimpex-backend-new/routes/vendorapp.php` (branch `integration/v2`)
- Figma: file `gcPrdiT2s5VbO51zOdwT36`, page "Vendor Apps & Driver App", node `5:4744` (view only)
- Older vendor design reference: ourworks.co.in/saimpex-vendor-design
- Team scope: `docs-scope/V2_TEAM_SCOPE.txt`, `docs-scope/FUNCTIONAL_REQUIREMENTS.txt` (on Praveen's Mac; ask for a copy)

## Backend updates since this handover

| Date | Change | What the app must do |
|---|---|---|
| 31 Oct 2026 | Orders can have `payment_type` 3 = Wallet and 4 = Pay After Delivery. | Label them "Wallet" and "Pay After Delivery". Neither is cash; vendor earnings follow the existing paid/unpaid rules. |
