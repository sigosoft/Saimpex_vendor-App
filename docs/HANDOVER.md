# SAIMPEX V2 Vendor App: Developer Handover

> **Read first:** the complete V2 scope, [`praveensigo/saimpex-backend-new` → `docs/V2_COMPLETE_SCOPE.md`](https://github.com/praveensigo/saimpex-backend-new/blob/integration/v2/docs/V2_COMPLETE_SCOPE.md). Then this handover, then the API change log.
> **Owner:** **Sharvin** from 31 Oct night (also owns the customer, delivery and kitchen apps). Built until then by Stephy. Week-by-week task list to the 1 Dec launch: [`docs/TEAM_ASSIGNMENTS.md`](https://github.com/praveensigo/saimpex-backend-new/blob/integration/v2/docs/TEAM_ASSIGNMENTS.md).

Last updated: 31 Oct 2026. Branch at time of writing: `fix/save-item-variants-options` (HEAD `706c74e`).
Repo: `sigosoft/Saimpex_vendor-App`. Flutter, for **Android and iOS**; **Android first** (decided 31 Oct). iOS builds but is not set up for release yet.

Binding product decisions live in the backend repo:
**`praveensigo/saimpex-backend-new/docs/V2_DECISIONS_AND_PLAN.md`**.
Where that file differs from the V2 scope PDF, the FRD or V1 behaviour, that file wins.

Status words used in this document:

- **Done**: screen exists and calls a real API end to end (read in code; not always tested on a device).
- **Partial**: screen exists, but some actions are missing, mocked or not sent to the API.
- **Not started**: no screen or no code.
- **Unverified**: code was not read closely enough, or depends on server behaviour that was not checked.

---


## Team communication (read first)

Five computers build SAIMPEX V2 in parallel: backend API (Praveen's Mac), customer app, vendor app, delivery + kitchen apps, admin panel. They stay in sync through two shared files in the backend repo:

| What | Where | When to read it |
|---|---|---|
| **Complete final scope — read first** | [`docs/V2_COMPLETE_SCOPE.md`](https://github.com/praveensigo/saimpex-backend-new/blob/integration/v2/docs/V2_COMPLETE_SCOPE.md) | Before you start building anything; it describes every app and rule |
| **API change log** — every API change, which apps must act, where it's documented | [`praveensigo/saimpex-backend-new` → `docs/API_CHANGELOG.md`](https://github.com/praveensigo/saimpex-backend-new/blob/integration/v2/docs/API_CHANGELOG.md) (branch `integration/v2`) | Every day before you start; look for `[vendor]` |
| **Client decisions + build plan** | [`docs/V2_DECISIONS_AND_PLAN.md`](https://github.com/praveensigo/saimpex-backend-new/blob/integration/v2/docs/V2_DECISIONS_AND_PLAN.md) | Before building any feature; it overrides the scope PDF |
| **API contracts** | [`docs/SAIMPEX_V2_CUSTOMER_API.md`](https://github.com/praveensigo/saimpex-backend-new/blob/integration/v2/docs/SAIMPEX_V2_CUSTOMER_API.md) | When wiring an endpoint |

This file's **"Backend updates since this handover"** table (at the end) repeats the entries that concern this app.

**Need something from the backend?** Open a GitHub issue in `praveensigo/saimpex-backend-new` titled `[vendor-app] <short description>`: the screen, the endpoint, what you sent, what you got, what you need. Don't build against a guessed contract. Product questions go to Praveen; answers are recorded in the decisions doc.

**Changing something other teams depend on** (e.g. a push payload this app sends or expects, a shared asset)? Add a line to the change log via the backend owner, or mention it in an issue, so every team sees it.

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
| 11 | Local store | Grocery/Restaurant screens on the `localStore*` endpoints (`feature/vendor-routing`) | same |
| 3 | Pharmacy | Pharmacy | `lib/pharmacy/` |
| 4 | Water | Water | `lib/water/` |
| 10 | Gas | Water design on the `water*` endpoints (backend #84, on dev). One-time orders + refills: subscription tabs, stock controls and the returnable toggle are hidden for gas; orders show "N empty cylinders to collect" (`feature/gas-on-water`) | `lib/water/` (`WaterApi.isGas`) |
| 9 | Home cleaning | Home Cleaning (UI only, mock data) | `lib/home_cleaning/` |
| 7 | Laundry | **To build (V14)**: app section per Figma "Vendor Apps" → Laundry Vendor App (every vendor type has this app and the web panel, final) | `service*` |
| 8 | Car wash | **To build (V14)**: app section per Figma "Vendor Apps" → Car Wash Vendor App (every vendor type has this app and the web panel, final) | `service*` |

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
| **Balance adjustments visible in Earnings** | Show admin add/deduct entries with note, amount, balance after, date. | **Done (V4, branch `feature/earnings-adjustments`). Empty state checked on the emulator against dev in EN and AR (restaurant Majlis has no adjustments yet); a list with real entries not yet seen.** `lib/utils/widgets/balance_adjustments_section.dart` on the Payouts tab of all three earnings screens. Built without a Figma screen. |
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

The backend for V2 is `praveensigo/saimpex-backend-new`, branch **`integration/v2`**. Vendor app routes are in `routes/vendorapp.php` (prefix `vendorapp/`, Sanctum auth).
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

`test/esc_pos_receipt_builder_test.dart` tests the receipt builder (updated to the async `buildReceipt` and the V7 ticket layout). The Flutter template counter test was removed (`fix/small-cleanups`). There is no CI.

**Imports must match the file names' case.** Many imports used `Utils/Utils.dart`, `Home/Home.dart`, `Login/Login.dart`… while the files are `utils/utils.dart`, `home/home.dart`, … That works on macOS and Windows but not on Linux (or CI), where `flutter analyze` showed ~436 errors. All 68 were fixed (`fix/small-cleanups`); on Linux the analyzer now shows 0 errors. The splash screen no longer prints the login token.

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
2. The login screen still shows an "app type" dropdown (`lib/view/login/widgets/login_form_card.dart`), but since commit `fb08465` the app **ignores the pick** and uses the server `vendor_type` (`VendorAppTypeX.fromVendorType`). Unsupported types (7, 8 and any unknown type) still get a toast telling them to use the web panel (`lib/controller/login_controller.dart`). **This is temporary:** every vendor type has both this app and the web panel (final, 1 Nov); V14 removes the block when the laundry and car wash sections land.
3. The section is saved as `selectedAppType` and opened with `VendorAppRouter.goToSelectedApp`. On next start `lib/view/splash/splash.dart` routes the same way.
4. Inside Grocery/Restaurant, screens branch on the saved `vendorType`: `"1"` means restaurant, anything else is treated as grocery (for example `lib/view/home/vendor_home_screen.dart`, `lib/view/home/vendor_order_details.dart`, `lib/controller/item_controller.dart`).
5. Pharmacy and Water screens read `vendorType` (fallback: `selectedAppType`) and send it as the `vendor_type` query parameter.

Dead code: the OTP login path (`LoginController.sendOtp` → `lib/view/otp/otp.dart` → `OtpController.verifyOtp`) saves a fake `mock_token`. No login widget calls it. Do not revive it; delete it when convenient.

### 3.5 Localisation and RTL

- Strings: `lib/l10n/intl_en.arb` (~711 keys), `intl_fr.arb` (~706), `intl_ar.arb` (~703). Accessed with `S.of(context).key` / `S.current.key`.
- Language switch: `lib/utils/localization_service.dart` (`localeNotifier`) plus `flutter_localization`. Saved under `selected_locale`.
- RTL: `lib/main.dart` wraps the whole app in `Directionality` (RTL when language is `ar`).
- Font: Arabic text uses **Cairo** (Rubik, Inter and Baloo 2 have no Arabic letters). Use `appFont('Rubik', ...)` / `appFont('Inter', ...)` from `lib/resources/fonts.dart` instead of `GoogleFonts.rubik/inter(...)`; the `builder` in `main.dart` swaps the Baloo 2 theme to Cairo in Arabic. Brand orange is **#FF5216** only (`colorPrimary`); `git grep -i -E "FF5E00|FF5722|FF6B00|F97316" lib` must stay empty (V19).
- Coverage: Grocery/Restaurant screens mostly use `S`. Water (`lib/water/`) and Home Cleaning (`lib/home_cleaning/`) use `S` since V5 (keys prefixed `water…` / `cleaning…`); mock sample data in those screens is still English until V6 replaces it. Pharmacy uses `S` in a few screens only. The forced `TextDirection.ltr` on the Water bottom nav and language picker was removed in V5; phone numbers, time ranges and +/- quantities are kept LTR on purpose.
- FR and AR have a few fewer keys than EN: some strings fall back to English.

### 3.5b Laundry and car wash (V14, part A ✅ `feature/v14-laundry-carwash`)

- Laundry (7) and car wash (8) vendors can log in now (the login block is gone) and get the **service section** shared with home cleaning (same `service*` endpoints). `lib/home_cleaning/model/service_kind.dart` (`ServiceKinds.current`, loaded from the saved `vendorType` by the router) gives each kind its tabs, second home counter, status pill, action labels and reject reasons; the backend flow is `VendorScreenData` (`nextStep`, `labelsFor`).
- **Laundry:** tabs New / Waiting for Pickup / In Progress / Ready for Delivery / Delivered / Cancelled; actions Accept → Confirm Pickup → Mark Ready for Delivery → Mark as Delivered. Details add the service speed, customer estimate vs actual kg (MRU), pickup slot, delivery turnaround, pickup & delivery addresses, and "Additional payment pending" (already paid / final / balance due). **Confirm Pickup on a per-kg service opens Verify Weight** (Figma 9714:86314): actual kg, price breakdown, invoice difference; heavier → **Send Payment Request** (`updateServiceBookingStatus` `payment_request=1`, `actual_weight`), otherwise or once requested → confirm pickup (`status=3`, `actual_weight`).
- **Car wash:** tabs New / Waiting for Vehicle / In Progress / Ready for Pickup / Completed / Cancelled; actions Accept → Mark Vehicles Received → Mark as Ready for Pickup → Mark as Completed. Details add the vehicles (plate, type, wash, price, add-ons) and the service location.
- Reject reasons per kind (laundry uses the car wash list, as the backend does).
- **Part B ✅ (`feature/v14b-service-forms`):** `lib/home_cleaning/view/service_form_view.dart`, opened from My Services for laundry and car wash (home cleaning keeps its own form). **Laundry** (Figma 9714:86553 / 86733 / 86867): image, service type (+ Request new service type), processing time (Standard (24h) / Express), pricing unit (per kg → price per kg; per item → Item pricing list with an Add Item sheet: image, name, unit piece / kg / metre, price). **Car wash** (Figma 9714:82201): image, service type, description, vehicle types (image, type, price; at least one), add-on services (image, name, description, price), home / workplace pricing (distance ranges min–max km, price). Saved with `addServiceItem` / `updateServiceItem`: rows as JSON (`garments`, `vehicles`, `addons`, `distances`), row images as `<rows>[i][image]`. The "Main / Extra" switch and "What's included" tasks from the September PDF are not in the latest Figma, so they are not built. Tests `test/service_form_view_test.dart`.
- `lib/home_cleaning/view/service_kind_blocks.dart`, tests `test/service_kind_blocks_test.dart`.

### 3.5c Home cleaning cleaners (V16 ✅ `feature/v16-cleaners`, API §6.39)

Figma "V2 Additions (1 Nov)": My Cleaners 10868:11391, Add Cleaner 10868:11643, Assign Cleaner 10868:11841, Booking with Cleaner 10868:12059. `lib/home_cleaning/model/cleaner.dart`, `lib/home_cleaning/view/cleaners/`.
- **My Cleaners** (Account → My Cleaners, home cleaning only): All / Available / Busy / Inactive with counts, rating and reviews, Available / Busy · time / Deactivated, Edit, Deactivate / Activate (`updateServiceCleaner` status 1/2; 422 while busy is shown), Add Cleaner.
- **Add / edit cleaner:** photo, full name, phone (+222), Active.
- **Assign Cleaner:** opened by the booking's button when `needs_cleaner` (next step after Accept), or by **Change** on the assigned cleaner card in Booking Details. Lists cleaners with availability **for that booking** (`serviceCleaners?order_id=`); busy ones can't be picked. `assignServiceCleaner`.
- Action labels now follow the backend: Accepted → **Assign Cleaner** → **Mark On the Way** → Start Cleaning → Mark as Completed (the Accepted button used to say Start Cleaning).
- **Cleaner review** under each review on the Vendor Profile (`vendorapp/profile` `reviews[].cleaner_review`).
- The design's "126 jobs" shows the cleaner's review count: the API has no jobs count.

### 3.5d Water design gaps (V18a ✅ `feature/v18-design-gaps`, API §6.41)

- **Subscription calendar** (`lib/water/view/subscription_calendar/subscription_calendar_view.dart`, Figma 8360:37494; was a "not available" placeholder): totals (total, morning, afternoon, paused), weekly planner with per-day counts and week arrows, search, All / Morning / Afternoon / Evening / Paused, the day's deliveries grouped by slot (customer, delivery or self pickup, plan, product × bottles, Chat with customer). `GET waterDeliveryCalendar`.
- **Subscription details** (Figma 8360:40537): **Delivery history** (latest 5, "See all" → `DeliveryHistoryView`, `GET waterSubscriptionDeliveries`, paginated) and the payment summary's savings, delivery fee and tax (`subscription.payment_summary`).

### 3.5e Home cleaning extras (V18b ✅ `feature/v18b-cleaning-extras`, API §6.40)

- Add / Edit Service shows only the sections the service type uses (`kind`, `has_product_supply`, `has_addons`, `has_issues`; older types without flags show all, as before).
- Add-ons have a price unit: flat, per unit / hour / room / piece (`addons[].unit`).
- Booking details: the service image (`service_image`), the saved address title above the address (`address_label`), and "Customer brings their own products" when `product_supply` is `customer`.
- The home membership badge comes from `serviceDashboard.membership` (falls back to `GET home` on older servers).
- Reject reasons already use the backend's values per kind (V14).

### 3.5f Notifications (V18c ✅ `feature/v18c-notifications-chat`, API §6.42, §6.44)

- **Push on/off** is saved on the server (`GET` / `POST notification/preference`, `lib/utils/notification_preference.dart`): water and pharmacy switches used to be local only; home cleaning (and laundry / car wash) now has the switch back. A failed save puts the switch back.
- **"Needs your attention"** (`lib/utils/widgets/activity_notifications_section.dart`, `GET activityNotifications`, marked read on open) above the notifications list in the restaurant / grocery, water and pharmacy screens: orders waiting for acceptance, water subscriptions to review, low stock. Restaurant rows open the order. Built without a Figma screen.

### 3.6 Realtime and push

- Push: Firebase Messaging handlers and local notifications in `lib/view/notifications/notification.dart` (foreground, background, opened-from-tap).
- Chat realtime: Pusher in `lib/controller/chat_controller.dart`, config in `lib/configs/PusherConfig.dart`.
- **Hide / unhide products (V10, ✅ `feature/v10-hide-min-order`, API §6.21):** `lib/utils/widgets/product_visibility.dart` — a bar under each product card ("Visible to customers · Hide" / "Hidden until 18:00 · Show now"); Hide offers 1 h, 4 h, until end of today, until shown again. On the grocery / local store items list (row `id` = menu_id, vertical `grocery` or `local_store`), pharmacy inventory (row `menu_id`) and water inventory (row `menu_id`; not for gas, which has no hide vertical). **Restaurant (food) items wait on backend #132** (the restaurant lists don't return `is_hidden`). Built without a Figma screen.
- **Order rules (V10, API §6.22):** `lib/view/settings/order_rules_screen.dart`, read-only (`GET vendorapp/orderRules`): minimum order, preparation time, delivery fee and who pays it, drivers. SAIMPEX sets them in Admin. Menu item "Order rules" in all four account menus.
- **New category / service type requests (V8, ✅ `feature/v8-category-requests`, scope §3):** `lib/view/settings/category_requests_screen.dart` — the vendor's requests with Pending / Approved / Rejected and Admin's note, plus "Request a new category" (name + reason). Pharmacy (`pharmacyCategoryRequests`, `requestPharmacyCategory`) and water (`waterCategoryRequests`, `requestWaterCategory`; not for gas) from their account menus. Home cleaning's "Request a new service type" sheet on Add Service now sends `requestServiceType` (the type stays pending, so it is not added to the list until approved). Restaurants and groceries manage their own categories, so they need no request. Built without a Figma screen.
- **Support messages from SAIMPEX (V17, ✅ `feature/support-messages`):** API §6.37. `lib/controller/support_messages_controller.dart`, `lib/view/support/support_messages.dart` (order threads with unread badge) and `support_chat.dart` (one order's messages, reply). Menu tile "Support messages" in all four account menus (restaurant/grocery profile, water, pharmacy, home cleaning). The `admin_message` push opens that order's chat and **no longer triggers the new-order alert** (it carries an `order_id`). "Open order" shows only in the grocery/restaurant section. Built without a vendor Figma screen, in the delivery app's Support Messages layout (Figma `10885:12518`). Pharmacy part (§6.36, ✅ `feature/pharmacy-generic-dosage`): **Generic name** field on Add/Edit Product (`pharmacy_add_product_screen.dart`), loaded from `pharmacyMenuDetails` and saved with `POST pharmacyProductFields` (after an add, the new `menu_id` comes from `pharmacyMenuItemDetail`). Dosage per variant was already on the form. **Generic equivalent** (✅ `feature/generic-picker`, API §6.55, backend #130): field under Generic name showing the linked product (`pharmacyMenuDetails` → `generic_equivalent`); tapping opens a search sheet over every pharmacy (`pharmacyGenericSearch`, 2+ letters, the edited product excluded) with "Remove link"; saved as `generic_menu_id` with `pharmacyProductFields`, only when changed. Built without a Figma screen.

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
| Local store (11) | **Done (`feature/vendor-routing`), not yet tested on a device** | Same grocery screens, but every grocery call is switched to its `localStore*` twin (27 endpoints, `lib/configs/store_endpoints.dart`, applied in the `DioClient` interceptor when the saved `vendorType` is 11). Same parameters and response shape, checked against `integration/v2`. |
| Pharmacy (3) | **Partial** | Orders, prescriptions, quotations, inventory, stock, add product, coupons, drivers, earnings, chat, notifications on API. Mostly English. No printing. |
| Water (4) | **Partial** | Orders, subscriptions (accept/reject/pause/resume), inventory, stock, earnings, chat on API. Notifications, received payouts, coupons (add/edit/status/delete) and subscription details on API since V6; delivery calendar and delivery history hidden (no endpoint, see `docs/V6_BACKEND_ISSUES.md`). EN/FR/AR since V5. |
| Gas (10) | **Unverified / likely broken** | Opens the Water section and calls `water*` endpoints. Backend treats type 10 as a service vertical (`HomeController`: `isService` for 7, 8, 9, 10). Must be confirmed with backend. |
| Laundry (7) | **Not started** in app (V14) | Still blocked at login; build per Figma on `service*`, then remove the block. Every vendor type has this app and the web panel (final). |
| Car wash (8) | **Not started** in app (V14) | Still blocked at login; build per Figma on `service*`, then remove the block. Every vendor type has this app and the web panel (final). |
| Home cleaning (9) | **Partial (UI only)** | Screens from Figma with hard-coded bookings (`lib/home_cleaning/view/home_cleaning_home.dart`). Only profile, logout and delete account call the API (`lib/home_cleaning/view/home_cleaning_account_view.dart`). Backend `service*` endpoints exist but are not used. |

### 4.2 By feature, Grocery / Restaurant / Local store section

| Feature | Status | Main files | Notes |
|---|---|---|---|
| Home / orders list | Done | `lib/view/home/vendor_home_screen.dart`, `lib/view/home/orders_view_all.dart`, `lib/controller/home_controller.dart` | `vendorapp/home`. Auto-accept toggle (`updateAutoAcceptMode`). |
| Order details and actions | Done | `lib/view/home/vendor_order_details.dart`, `lib/controller/order_details_controller.dart` | accept / cancel (reject reasons) / prepare / ready / self-pickup complete, restaurant vs grocery endpoints. |
| Dashboard | Done (unverified on device) | `lib/view/home/dashboard.dart`, `lib/controller/dashboard_controller.dart` | |
| Menus / sections, categories, tags | Done | `lib/controller/menucontroller.dart`, `lib/view/restaurant/add_menu_screen.dart`, `lib/view/restaurant/edit_menu_screen.dart`, `lib/view/restaurant/restaurant_management_screen.dart` | Menu images via `uploadRestaurantMenuImages` / `uploadGroceryMenuImages` (`lib/controller/profile_controller.dart`). |
| Items: add | Done | `lib/view/restaurant/add_items_screen.dart`, `lib/controller/item_controller.dart` (`addItem`) | Restaurant uses `addRestaurantCatalogItem`; grocery uses `addGroceryMenuItem`. |
| Items: edit | Done (tested on the Android emulator against dev, 31 Oct) | `lib/view/restaurant/edit_items_screen.dart`, `ItemController.loadItemForEdit` / `updateCatalogItem` | Restaurant (V1, branch `feature/edit-item-variants`): loads `restaurantCatalogItemDetail` (variants, option groups, extras with ids) and saves with `updateRestaurantCatalogItem` (same body as add + `item_id`, ids sent so rows update in place, `serial_no`, `images[]`, `remove_image_ids`). A new photo replaces the one shown. The Category dropdown (add and edit) now lists `getRestaurantCategories`; it used to list `getRestaurantMenus`, which on V2 returns the items themselves, so an item id was sent as `category_ids`. Grocery still uses `updateGroceryMenuItem`. |
| Variants and option groups | Done for restaurant add + edit (edit tested on emulator) | `lib/controller/item_controller.dart` (`CatalogVariant`, `CatalogOptionGroup`, now with `id`), `lib/view/restaurant/item_customization_bottom_sheet.dart` | Add and edit send `has_variants`, `variant_group_name`, `variants`, `option_groups`, `extras` (JSON) plus images. Edit sends ids: variants and extras update in place, but the backend deletes and recreates option groups and options on every save, so option ids change (carts holding an old option id may break). Grocery: not supported. |
| Catalogue import / export | Partial | `lib/controller/profile_controller.dart`, `lib/controller/menucontroller.dart` | Template download and `importRestaurantCatalogItems` exist. `exportMenuItems` and `importRestaurantMenuItems` have **no backend route** (see API map). |
| AI image enhance | Done (unverified) | `lib/view/restaurant/restaurant_management_screen.dart`, `ApiEndPoints.imageEnhance` | Calls `openai-image-enhance`. |
| Stock | Done | `lib/view/restaurant/Widgets/view_stock_history_screen.dart`, `ItemController` | Stock logs + update for restaurant and grocery. |
| Availability | Done | `ItemController.updateItemStatus` | Falls back to `vendor/...` paths that do not exist on the backend (harmless, but remove). |
| Baskets (grocery) | Done (unverified) | `lib/view/basket/basketlisting.dart`, `lib/controller/basket_controller.dart`, `lib/controller/redeemed_customers_controller.dart` | |
| Coupons | Done | `lib/view/settings/coupons_screen.dart`, `lib/view/settings/add_coupon_screen.dart`, `lib/controller/coupon_controller.dart` | |
| Drivers (delivery boys) | Done | `lib/view/settings/delivery_boys.dart`, `lib/view/settings/add_delivery_boy_screen.dart`, `lib/controller/delivery_boys_controller.dart` | List, add, edit, detail, delete. |
| Earnings / payouts | Partial | `lib/view/settings/earnings.dart`, `lib/view/settings/earnings_all_orders.dart`, `lib/view/settings/payout_details.dart`, `lib/controller/payout_controller.dart` | Summary, orders, payout history/detail done. Balance adjustments listed on the Payouts tab (V4, `lib/utils/widgets/balance_adjustments_section.dart`). |
| Sales reports | Done (unverified) | `lib/view/reports/sales_reports.dart`, `lib/controller/sales_report_controller.dart` | |
| Working hours, leave, busy mode | Done (unverified) | `lib/controller/profile_controller.dart`, `lib/view/restaurant/leave_history_screen.dart` | |
| Profile edit | Done | `lib/view/profile/edit_profile.dart`, `lib/controller/profile_controller.dart` | Name/photo via `profile/update`; phone change needs WhatsApp OTP via `profile/sendOtp` (commit `706c74e`). |
| Ratings and reviews | Done (unverified) | `lib/view/restaurant/rating_reviews_screen.dart` | |
| Chat (text + voice) | Done | `lib/view/chat/ChatListing.dart`, `lib/view/chat/ChatDetails.dart`, `lib/controller/chat_controller.dart` | Pusher realtime, voice via `record` / `audioplayers`. |
| Notifications | Done | `lib/view/notifications/notifications.dart`, `lib/controller/notification_controller.dart`, `lib/view/notifications/notification.dart` | |
| Printing | Done (Android), `feature/bluetooth-printing` | `lib/utils/printing/`, `lib/view/settings/widgets/printer_picker_dialog.dart` | Settings → **Printer**: paired Bluetooth devices + "Automatic" (USB first, then the first paired printer), saved as `printerAddress`, **Print test page**. Ticket text is Latin-1 safe (curly quotes / Arabic no longer fail the print). No Figma screen. No iOS. **Not yet tested on a real printer.** |
| Pre-orders | Not started | - | Contract pending from backend. |
| Grocery substitution | Not started | - | Contract pending from backend. |
| Local store endpoints | Done (`feature/vendor-routing`) | `lib/configs/store_endpoints.dart` | Grocery endpoint → `localStore*` twin for vendor type 11. |
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
| Earnings / payouts | Partial | `lib/pharmacy/view/pharmacy_earnings_screen.dart`, `lib/pharmacy/view/pharmacy_payout_details_screen.dart`, `lib/pharmacy/view/pharmacy_received_payouts_screen.dart` | Balance adjustments listed on the Payouts tab (V4). |
| Profile, hours, leave, business settings | Done (unverified) | `lib/pharmacy/view/pharmacy_profile_screen.dart`, `lib/pharmacy/view/pharmacy_working_hours_screen.dart`, `lib/pharmacy/view/pharmacy_leave_management_screen.dart`, `lib/pharmacy/view/pharmacy_business_settings_screen.dart` | Profile edit through OTP endpoints: not wired here. |
| Chat | Done | `lib/pharmacy/view/pharmacy_chat_screen.dart`, `lib/pharmacy/controller/pharmacy_chat_controller.dart` | |
| Notifications | Done | `lib/pharmacy/view/pharmacy_notifications_screen.dart` | |
| Printing | Done (Android), `feature/bluetooth-printing` | `lib/pharmacy/view/otc_order_details_screen.dart`, `lib/utils/printing/vertical_order_ticket.dart` | Print button in the OTC order header (hidden until the order loads); `pharmacyOrderDetail` {order, items} is mapped onto the same ticket. Printer picker in Account. Prescription requests (not orders yet) have no ticket. **Not yet tested on a real printer.** |
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
| Earnings | Partial | `lib/water/view/account/earnings_view.dart`, `lib/water/view/account/payout_details_view.dart` | `lib/water/view/account/received_payouts_view.dart` is static. Balance adjustments listed on the Payouts tab (V4). |
| Profile, hours, leave, business settings | Done (unverified) | `lib/water/view/account/store_profile_view.dart`, `lib/water/view/account/working_hours_view.dart`, `lib/water/view/account/leave_management_view.dart`, `lib/water/view/account/business_settings_view.dart` | |
| Chat | Done | `lib/water/view/chat/messages_list_view.dart`, `lib/water/view/chat/chat_view.dart` | Reuses `ChatController`. |
| Notifications | Partial (mock) | `lib/water/view/notifications/notifications_view.dart` | Hard-coded list. |
| Printing | Done (Android), `feature/bluetooth-printing` | `lib/water/view/order_details/order_details_view.dart`, `lib/utils/printing/vertical_order_ticket.dart` | Print button in the order header (hidden until the order loads); `waterOrderDetail` mapped onto the same ticket. Printer picker in Account. Gas not covered. **Not yet tested on a real printer.** |
| Localisation | Not started | - | English literals only. |

### 4.5 Home Cleaning

| Feature | Status | Files |
|---|---|---|
| Home / bookings | Done (V6, not run against a real account) — `serviceDashboard`, `serviceBookings`, `serviceBookingDetail`, `updateServiceBookingStatus`, `serviceAvailability`; flow 1→2→8→3→9, 10 cancelled | `lib/home_cleaning/view/home_cleaning_home.dart`, `lib/home_cleaning/view/booking_details_view.dart`, `lib/home_cleaning/view/reject_booking_sheet.dart` |
| Services | Done (V6, not run against a real account) — `serviceItems`, `serviceTypes`, `addServiceItem`/`updateServiceItem` (multipart, lists as JSON strings), `deleteServiceItem` | `lib/home_cleaning/view/my_services_view.dart`, `lib/home_cleaning/view/add_service_view.dart` |
| Chat | Done (V6, not run against a real account) — shared `ChatController` (`chat/allConversations`, `getConversation`, `sendMessage`) | `lib/home_cleaning/view/chat/home_cleaning_messages_view.dart`, `lib/home_cleaning/view/chat/home_cleaning_conversation_view.dart` |
| Account | Done (V15, `feature/v15-service-account`) | `lib/home_cleaning/view/home_cleaning_account_view.dart`, `lib/home_cleaning/view/service_account_screens.dart`. **Working hours & booking slots** (`serviceHours` / `saveServiceHours`: days with open/closed and times, slots available/unavailable, maximum bookings per slot), **Business settings** (`serviceAvailability`: open · accepting bookings, mark as busy), **Earnings** (`serviceEarnings`: pending / available / payout received, All / Available / Pending / Cancelled, Payouts tab) now use the service endpoints, for home cleaning, laundry and car wash. Received payouts and coupons stay on the shared vendor screens. Built in the section's style (no Figma frames for these service screens). My Cleaners: §3.5c. |

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

**P1. Show balance adjustments in Earnings (all sections).** ✅ Done in V4 (`feature/earnings-adjustments`): shared `lib/utils/widgets/balance_adjustments_section.dart`, built without a Figma screen (payout-card style); +/- amount, note (or "Admin adjustment"), balance after, date DD/MM/YYYY; empty state; EN/FR/AR. Pull to refresh reloads it.
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

**P5. Pre-orders.** ✅ Built in V3 (`feature/preorders`), not yet seen with a real pre-order (dev had none for the test restaurant). `PreordersController` loads `GET vendorapp/preorders`; home shows an "Upcoming pre-orders (N)" tile (hidden when none) opening `lib/view/home/preorders_screen.dart` (delivery time, time left, status, total, self pickup, driver requested/assigned); home order cards get a "Pre-order · DD/MM HH:mm" badge and order details a "Scheduled for …" line. The home list and order details don't return `is_preorder`/`scheduled_for`, so screens match order ids against the pre-orders list. Push `preorder_reminder` is no longer treated as a new order: no "A new order!" text or accept dialog; when the app is open it shows the reminder in the app language; tapping opens the order. Built without checking Figma (Figma MCP call limit reached); compare with Figma before release.
AC: scheduled orders show the scheduled date/time and a badge; the vendor gets a push 30 minutes before; tapping it opens the order.

**P6. Grocery substitution (after backend phase 2 contract).**
AC: vendor can pick a replacement for an order line; the order shows "waiting for customer" with a 10-minute countdown; after 10 minutes without reply it shows auto-accepted; totals update.

**P7. Easy vs advanced menu editing (restaurant).**
AC: a quick-edit path (name, price, availability, photo) in one screen; advanced path for variants, option groups with min/max, extras and images; menu images upload and show in the customer app.

**P8. Localisation of Water, Pharmacy and Home Cleaning.** ✅ Water and Home Cleaning done in V5 (`feature/water-cleaning-l10n`): ~400 new keys in EN/FR/AR, sliding tab/nav highlights and back buttons mirror in Arabic. Checked on the emulator: Water home and account in Arabic and French. Home Cleaning not seen on a device (no test account). French/Arabic wording is machine-written: include it in the SAIMPEX Arabic review. Pharmacy is still mostly English (not part of V5).
Move literals to the ARB files.
AC: switching to French or Arabic translates every visible string in these sections; Arabic layout is right-to-left with no clipped or mirrored-wrong icons.

**P9. Replace mock screens in Water.** ✅ V6 (`feature/water-cleaning-api`), except the delivery calendar and history (no endpoint; hidden).
Notifications, received payouts, add/edit coupon, subscription details and calendar must use the API.
AC: no hard-coded sample data remains in `lib/water/view/`.

**P10. Home Cleaning on `service*` endpoints.** ✅ V6 for bookings, services and chat; account hours/earnings still on the Water screens (follow-up). 18 backend gaps in `docs/V6_BACKEND_ISSUES.md`.
AC: bookings, booking detail/status changes, services CRUD and hours use the backend; no hard-coded bookings.

**P11. Laundry and car wash sections.** ✅ **Confirmed by Praveen (31 Oct): build them (task V14).** Designs: Drive "Vendor App" folder, *Saimpex Laundry Vendor UI 08-09-2026* and *Saimpex Car Wash Vendor UI 03-09-2026*. **Final (1 Nov): every vendor type has both logins, this app and the web panel.** Build on the `service*` endpoints per Figma, then remove the login block.
AC: login no longer blocks types 7 and 8; bookings flow works.

**P12. Printing beyond Android restaurant/grocery.** ✅ **Code done (`feature/bluetooth-printing`, V7); needs a real 58 mm and 80 mm printer to verify.**
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
5. **Mock data**: removed in V6. Where the backend has no data (Water delivery calendar/history, some Home Cleaning fields) the block is hidden; gaps in `docs/V6_BACKEND_ISSUES.md`.
6. **Dead OTP login path** saves a fake `mock_token` (`lib/controller/otp_controller.dart`). Not reachable now; remove.
7. **Release signed with the debug key**; iOS not configured (template bundle id, no Firebase plist).
8. **Localisation gaps**: Pharmacy mostly English; FR/AR missing a few older keys; Water/Home Cleaning mock data still English (V6). Reject/pause reasons are sent to the API in English while shown translated.
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
- Relation to this app: same vendors, same database, different API prefix. Every vendor type logs in to both the web panel and this app (final, 1 Nov); the app's login toast for laundry and car wash is temporary until V14. When you add a feature to the app, check whether the web panel already has it; the matching `routes/vendor.php` controller often shows the business rules. Keep behaviour the same in both.

---

## 10. Useful references

- Decisions and API phases: `praveensigo/saimpex-backend-new/docs/V2_DECISIONS_AND_PLAN.md`
- Backend vendor app routes: `praveensigo/saimpex-backend-new/routes/vendorapp.php` (branch `integration/v2`)
- Figma: file `gcPrdiT2s5VbO51zOdwT36`, page "Vendor Apps & Driver App", node `5:4744` (view only)
- Older vendor design reference: ourworks.co.in/saimpex-vendor-design
- Team scope: `docs-scope/V2_TEAM_SCOPE.txt`, `docs-scope/FUNCTIONAL_REQUIREMENTS.txt` (on Praveen's Mac; ask for a copy)

## Backend updates since this handover

| Date | Change | What the app must do |
|---|---|---|
| 31 Oct 2026 | Orders can have `payment_type` 3 = Wallet and 4 = Pay After Delivery. | Label them "Wallet" and "Pay After Delivery". Neither is cash; vendor earnings follow the existing paid/unpaid rules. ✅ V4: `lib/utils/payment_type.dart` (`paymentTypeLabel`, `isCashPayment`) used in restaurant/grocery order details, sales report details, pharmacy cards + OTC detail, water order list + detail, and the printed receipt (English). Also fixes water detail showing the raw code and pharmacy pending orders treating `1` as online. Mapping covered by `test/payment_type_test.dart`; no Wallet / Pay After Delivery order on dev yet to see on screen. |
| 31 Oct 2026 | Pre-orders: `GET vendorapp/preorders` (upcoming, soonest first); push `type: preorder_reminder` 30 min before. Accepting a pre-order does not call a driver; marking it Ready does. | Show a Pre-orders list/badge with the delivery time; handle the reminder push. ✅ V3 (`feature/preorders`). |
| 31 Oct 2026 | Grocery substitution: on a grocery order before Ready, pick a line → choose a substitute from own items (or "unavailable") → `POST vendorapp/orders/{id}/substitutions`; list with `GET` same path. Customer has 10 min, then auto-accept. | Add a "Suggest substitute" action per line and a status chip (pending / accepted / rejected / auto). |
| 31 Oct 2026 | Substitution rule change: customers pay the extra for pricier substitutes (wallet, then cash/online). An unanswered pricier substitute is removed, not auto-accepted. | Show the result status; no app change needed beyond that. |
| 31 Oct 2026 | **Token logging removed** (merged). **V1 (edit item saves variants/option groups) is not done**: the edit screen never loads the item's variants/options from the server, saves through the legacy `updateRestaurantMenuItem`, and uses the legacy menu-item id. Proper fix: load `restaurantCatalogItemDetail` (variants with ids, option groups, extras) into the screen models and save with `updateRestaurantCatalogItem` (same body as add + `item_id`; variants with `id` update in place). Needs device testing — Stephy's first task when back. | Known limitation in the 31 Oct review build. |
| 31 Oct 2026 | Pharmacy quote lines take `availability`, `requested_quantity`, `alternative_for`; the server computes the total (§6.15). Water subscriptions can be `pending_payment` (hide until paid). Gas bookings show `empty_cylinders_to_collect`. | V11 unblocked for the quote part. |
| 31 Oct 2026 | Hide / unhide a product: `POST vendorapp/products/visibility` {`product_type`, `id` (catalog item id for restaurants), `hidden`}. Response `status` 1 visible / 2 blocked by Admin / 3 hidden. | Add a Hide/Show toggle and a "Hidden" chip on the product list (§6.21). |
| 31 Oct 2026 | `GET vendorapp/orderRules`: minimum order value and default preparation time (set by Admin, read-only). | Show both on the store settings/profile screen (§6.22). |
| 31 Oct 2026 | **Routing answered (V12, P3/P4):** login returns `app_section` (`restaurant`, `grocery`, `pharmacy`, `water`, `local_store`, `service`). Local store (11) → `localStore*` endpoints (grocery ones filter order_type 2, so its orders never show there). Gas (10) → `service*` endpoints, **not** `water*`; bookings include `empty_cylinders_to_collect`. | Route by `app_section` instead of mapping types in the app (§6.23). ✅ Local store done (`feature/vendor-routing`). **Gas (10): decided (Abhinav, 31 Oct) to use the Water UI** (no gas design; water's bottles + returnable bottle match cylinders + empty-cylinder exchange). It already opens the Water section, but gas bookings are service bookings, so the water endpoints return nothing for gas: **waits for backend praveensigo/saimpex-backend-new#84**. |
| 31 Oct 2026 | **Change:** hide product is now `POST vendorapp/updateProductVisibility` {`vertical`: food/grocery/local_store/pharmacy/water, `menu_id`, `hide_for`: 1h/4h/today/forever/until/show}. The `products/visibility` endpoint from this morning is removed. | Build V10 against this one (§6.21). |
| 31 Oct 2026 | `GET vendorapp/orderRules` also returns `delivery_fee_type`, `delivery_fee_value`, `delivery_fee_paid_by`, `delivery_model` (Admin-set). If the vendor pays delivery, the fee is deducted from its earnings. | Show them read-only on the store settings screen (§6.22). |
| 31 Oct 2026 | `GET vendorapp/commissionRules`: the store's commission rules (read-only) and `fallback_percent`. | Optional: show on earnings/settings (§6.24). |
| 31 Oct 2026 | **Vendor app decisions (Praveen):** laundry (7) and car wash (8) get app sections (V14) and keep the web panel; grocery and local store use the restaurant design; gas uses the water design with one-time orders + refills only (no subscriptions; backend #84); home cleaning matches its design (V15); Android + iOS, Android first. | Backend `V2_DECISIONS_AND_PLAN.md` §14 |
| 31 Oct 2026 | **Gas on the water endpoints (#84, on dev):** water order and product endpoints serve gas vendors (type 10); `app_section` = `water`; rows carry `empty_cylinders_to_collect`, detail lines `is_returnable`; gas has no stock (`updateWaterItemStock` → 422). | ✅ `feature/gas-on-water`: gas hides subscriptions / stock / returnable toggle and shows empty cylinders to collect. |
| 31 Oct 2026 | **Gas (10) → Water section (#84):** login `app_section` for gas is now `water`. The water order and product endpoints return the gas vendor's bookings (with `empty_cylinders_to_collect`; lines say "Cylinder") and gas items (no stock; `updateWaterItemStock` → 422). | Send gas vendors to the water section; hide stock controls for gas (§6.23). |
| 1 Nov 2026 | **Final (Praveen): every vendor type has both logins, this app and the web panel**, including laundry and car wash. The app gets a section for every type (laundry + car wash: V14, which removes the login block). | Backend `V2_DECISIONS_AND_PLAN.md` §18 |
