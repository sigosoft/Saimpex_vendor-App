# SAIMPEX V2 vendor app: handover, 7 Nov 2026 (afternoon)

For the next person continuing the vendor app. **Read this file first.**

It continues `HANDOVER-vendor-app-2026-11-06-final.md`; that file's section 00 still holds the 7 Nov morning notes and the full PR merge order. Team rules: `CLAUDE.md`.

- Repo: https://github.com/sigosoft/Saimpex_vendor-App
- Backend: https://github.com/praveensigo/saimpex-backend-new, branch `integration/v2`
- Figma (view only, **never edit**): https://www.figma.com/design/ZCYkkdqmKm6Hn5Hcm12Mxg/Saimpex?node-id=3308-1865
- Launch: **1 December 2026**

---

## 0e. All PRs merged into `main` (10 Nov afternoon), replaces 0d's APK line

- **Praveen merged all 98 PRs (#39–#142) on 10 Nov.** `main` (`a7f7d7d`) now has the same app code as `test/retest-2026-11-06`. From now on branch new work from `main`.
- **Open PRs (base `main`), all merged into `test/retest-2026-11-06`:**
  - **#143** service Vendor Profile title matches the Account menu; Working hours "Weekly Schedule" list with an "Edit Working Hour" dialog per day (Figma). Was based on #137; retargeted to `main`. This replaces the "known difference" in 0d (inline time chips).
  - **#144** pharmacy OTC: cards show "3 Items • 305.00 MRU" (the list sends `item_count`, the app didn't read it; labels now in the app language); Prescription / OTC switch puts the selected type on a white pill (Figma). Phone ✅.
  - **#145** pharmacy OTC details: Delivery Partner card shows the real rider (name, phone; `pharmacyOrderDetail` now sends `delivery_boy_name` / `delivery_boy_phone`) while the order is out, and the call button dials. Delivered order still shows no rider card (Figma) ✅. **Not seen on the phone:** no OTC order with a rider on the way exists on dev.
  - **#146** restaurant / grocery / local store order details: delivered and cancelled orders had an empty white bar at the bottom (action bar with no buttons), now only shown when there is an action; header "ITEMS" in capitals like "DATE & TIME" (Figma); restaurant and pharmacy Home showed a red "Expires in 0 days" while loading, now no chip until the membership arrives. Phone ✅ (food.01, ORD-001514).
  - **#147** water / gas order details: payment summary gets **Tax** (also 0.00) and **Payment on** (the detail sends `payment_on` as English UTC text; shown in phone time and app language), as in Figma. Phone ✅ (water.19, ORD-001531: Payment on 11:55 = Order received).
- **Backend issue opened, #181:** `waterOrders` list has no `payment_type` and its `summary` is English only, so the Figma card pills ("1 Bottle (19L) • 50 MRU", Online Payment / Cash on Delivery) can't be shown; the card shows the total only until then.
- **Phone checks 10 Nov evening ✅:** #143 on laundry.24 (Vendor Profile title, Weekly Schedule list, Edit Working Hour dialog in English and Arabic, Cancel leaves data unchanged); Figma full-size pass of restaurant (list card, delivered order details) and water (Home, list, delivered order details) done; differences fixed in #146 / #147 or raised in #181.
- **Note:** food.01 uses a different password from the other demo logins (Stephy has it; not written here).
- **APK:** `client-build/SaimpexVendor-v1.0.6-7-dev-2026-11-10-2d593ff.apk` from `test/retest-2026-11-06` at `2d593ff` (pushed). Dev server, debug-key signed. = `main` + #143–#147. Analyzer 0 errors. Older APKs are superseded.
- **Figma, pharmacy OTC (full size):** Home and Orders list ✅ after #144; Delivered order details (customer, request ID, delivery type, address, items with photos, dark payment summary, timeline) ✅.
- **Backend issues still open on GitHub** (fixed on dev, waiting for Praveen to close): #168–#175, #176 (duplicate), #179, #180.

## 0d. Latest client build (9 Nov), replaces 0b

- **APK:** `client-build/SaimpexVendor-v1.0.6-7-dev-2026-11-10-79027b3.apk` from `test/retest-2026-11-06` at `79027b3` (pushed). Dev server, debug-key signed. Includes #118–#142. Analyzer 0 errors, `flutter test` **68 / 68**. Older APKs in `client-build/` are superseded.
- **10 Nov morning:** backend changelog checked (no new `[vendor]` entries after 9 Nov). **English pass done for every type** (laundry, restaurant, pharmacy, gas; grocery / local store share the restaurant screens; water done earlier). "Chat with Customer" opens the chat ✅. **Coupon card vs Figma ✅** (test coupon TEST10 created on laundry.24, then deleted). Fixes, phone ✅:
  - **#138 (new, base main):** coupon created / updated on showed UTC ("03:50 AM" at 09:20); now phone time in the app language (3 coupon screens). Add / Edit coupon: after the date picker or type menu the keyboard opened over the form; fixed.
  - **#133 follow-up:** order details header said "1 Items".
- **Test data added on dev through the API, 10 Nov** (no new backend commits after 9 Nov; nothing pending for the app):
  - **Restaurant (food.01):** item **289 "Test Burger"** (EN / FR / AR names, category 55): variants Single 200 / Double 280, required "Side" group (Fries, Salad, Rice +20, pick 1), optional extras (Cheese +30, Egg +25, Spicy sauce +10, up to 3). Use it for the Item Details variants / sides / extras Figma check; delete it from Items when done. Note: `updateRestaurantCatalogItem` clears option groups when `option_groups` is left out (extras are kept); the app always sends them.
  - **Pharmacy (pharmacy.15, vendor 63), customer Aminata Sow:** prescriptions **#21 New**, **#24 Under review**, **#22 and #23 Quoted 245 MRU** (Amoxicillin × 2, Paracetamol × 1) awaiting payment. The image is a generated "TEST PRESCRIPTION". Paying #23 needs online or wallet; not done (no payments made by Claude). Paid prescription orders from earlier test days (e.g. ORD-001536) cover the paid states.
  - **Phone checks with this data (10 Nov), all ✅:** Test Burger Item Details shows Size (Required · Select 1), Side options with prices, Add Extras (Optional · up to 3), Item Orders; prescription states New → Under review → Review completed → Awaiting payment (quotation 245 MRU, expiry, item availability, quotation summary). **Fixed:** Item Details price showed "- MRU" for an item with sizes, now "200 – 280 MRU" (#121 branch); a new prescription's details showed REVIEWING, now NEW (**#139**, base main).
  - **Branch audit (10 Nov):** three pushed branches had work in the test branch but no PR. Opened **#140** `fix/services-fallbacks` (base of #137), **#141** `fix/water-gas-fallbacks`, **#142** `fix/local-store-screens`, all base main. Merge #140 before #137. Every other pushed branch has a PR; nothing unpushed. Local-only `test/retest-2026-11-04` is old and already covered.
  - **Arabic check of today's changes (10 Nov afternoon), phone ✅ after fixes:** item tags on images, Test Burger Item Details (Arabic name, price range, sections, Item Orders), service Earnings, Working hours, Coupons, login type list. Fixed: option / extra prices "MRU 20+" → "MRU +20" (#121 branch, `signedMru`); service account back arrow pointed the wrong way in RTL and Earnings codes read "LNUNGLAC#" (#137); Working hours "today" line put closing time first in Arabic (#137).
  - **Dev data note:** laundry bookings LNUNGLAC / LNUQZC4R now show Cancelled (not done by Claude; probably cancelled by someone on dev). food.01 shows 10 products (8 demo + Test Burger + one more, not added by Claude).
  - **Still Admin only:** grocery.08 address (vendor `profile/update` takes only name, image, phone) and a test payout with a proof (#101).
- **Figma comparison, 9 Nov evening** (Figma file opens view-only without a login in the browser; open a frame with `?node-id=…` to zoom to it):
  - **Fixed, #137 (new, base fix/services-fallbacks):** service (laundry / car wash / home cleaning) **Earnings** rebuilt to the Figma frame (orange Earnings/Payouts pill, orange summary card, one row of chips, orange order codes, dates in the app language); **back arrow** on all service account screens was white on a light background (now the white rounded button); **Working hours** gets the Figma "Current status · Today" card; language picker shows English / Français / العربية. Phone ✅.
  - **Match ✅:** Business settings (water, restaurant, service), service Account menu, Vendor Profile (details, bank, registration, documents, reviews), Received Payouts, Coupons list header and empty state; earlier today: item tags on the image, Item Details tags + Item Orders.
  - **Known differences kept:** Working hours edits each day inline (time chips + switch) where Figma opens an edit sheet per day; same data, not rewritten. Vendor Profile title "Profil du magasin" vs menu "Profil du prestataire".
  - **Could not compare (no data on dev):** coupon card (no coupons), Item Details variants / sides / extras, pharmacy prescription timelines in every state, Express tag (food / grocery never express in V2).
- **Backend fixes rechecked, 9 Nov evening (backend f80296d, dd2aa02, c7f46d9 on dev), all phone ✅:**
  - **#180** local store order ORD-001566: 2 lines, 330 + 50 = 380 MRU, cash; vendor card "2 Articles · 380.00 MRU", details, Accept.
  - **#179** Item Details tags (Popular, New arrival). The app's first endpoint `vendor/restaurantCatalogItemDetail` now 404s on dev and the app falls back to `restaurantCatalogItemDetail`, which has the flags. **#121 new commit:** Item Orders section from `orders_count` / `recent_orders` (was never shown; app read `total_orders`).
  - **#135 (new, base main):** gas / water order lines in the app language ("Recharge butane 12 kg").
  - **#136 (new, base #118):** "Needs your attention" rows open their booking or order on water, gas and service screens (booking rows: calendar icon, "Voir la réservation").
  - Service names: backend translated the service types; car wash shows "Nettoyage intérieur".
  - **Express (#119):** backend says V2 has express for courier only; food / grocery orders are never express, so the tag can't appear there. #119 stays harmless; no test possible.
  - Commented on backend #179 / #180 asking Praveen to close them (and #168–#175, #176).
- **9 Nov afternoon, frontend clean-up (all phone ✅ unless noted):**
  - **#121 follow-up:** item tags moved onto the item image as in the Figma Items frame (bottom corner; the ⋮ menu is on top), instead of a row under the card.
  - **#128 (new, base main):** removed the unused No internet / Server down screens (handover B4). No behaviour change.
  - **#129 (new, base main):** water low-stock alert showed "L Jug with Bottle 19" in Arabic; now "Jug with Bottle 19 L".
  - **#102:** with 3 low-stock products the alert shows "+1 more" and View all, which selects the Low stock chip. Stock was set to 3 for the test and restored (300 / 288 / 291).
  - **#100:** water Business settings › Express switch saves (on, reopen, off again).
- **French / English pass, 9 Nov (water.19, food.01): bugs found and fixed (all merged into the test branch; phone ✅):**
  - **#130** dates used the English order everywhere: French "nov. 06, 2026 10:47 AM" → "06 nov. 2026 10:47"; Arabic now day first too. Central fix in `appDateFormat` (`localizeDatePattern`, tested) + 23 formatters that bypassed it. Merge note on the PR (a `DateFormat('EEEE')` in the restaurant localisation branch).
  - **#131** French wording: statuses agree with *commande* (Acceptée / Prête / Livrée), no English capitals, "Durées par étape" (tab label wrapped), "Modifier le stock" (button was cut off).
  - **#132** restaurant auto-accept card said "orders will be accepted automatically" with a green check while the switch was off; now follows the switch (new key EN/FR/AR).
  - **#133** "1 Articles / 1 Items" → "1 Article / 1 Item" on order cards, basket and item stats.
  - Checked OK: water Home / Orders / order details / Account / Inventory (FR + EN); restaurant Home, orders, details, timeline, Settings, Edit Profile, Business settings (Express saves), Items, Item Details, stock history (FR); login errors in French (empty username, wrong password).
  - **Second round (same day):** pharmacy, grocery, local store, laundry, home cleaning checked in French. More fixes on the same PRs: #130 service-booking times were still 12-hour in French (own helper) → "10 nov. 2026, 15:30 - 17:30"; #131 pharmacy status map "Prêt / Livré" → "Prête / Livrée", "Assistance et mentions légales". Phone ✅.
  - **Admin data:** grocery.08 store address has a line break inside "Nouakchott" ("Nouak⏎chott"), so it wraps mid-word on My Store; fix the address text.
  - **Car wash (carwash.27), French ✅:** Home, bookings, details (slot, vehicles, location, payment). **#134 (new):** completed booking badge said "TERMINÉ" (shared with leave status); now "TERMINÉE" on service bookings (new key EN/FR/AR). Phone ✅. "Interior" in English is the known Admin service-type name issue.
  - Not yet: item variants / sides / extras (no demo item has them). The phone was left in French; switch back to Arabic in Account › Language if needed.
- **Login:** the tester gave Claude the demo accounts on 9 Nov, so phone checks can switch vendor without help. Passwords are not stored in any file.
- **Vendor types tested on the phone, all in Arabic:** restaurant, grocery, pharmacy, water, car wash, laundry (7 Nov); **home cleaning, local store, gas (9 Nov)**. Every type has now been run end to end.
- **food.01, 9 Nov:** #122 notifications "View details" ✅ (opens ORD-001548); #126 contact "+222 95100001" ✅; #121 Items list tags ✅. **Item Details shows no tags: dev's `restaurantCatalogItemDetail` doesn't send `is_popular` / `is_new_arrival` / `is_veg` / `orders_count` yet** (checked with a debug build; commented on backend #179). No app change needed; recheck after the backend deploy. Design note: the tag row sits under the card, above the visibility bar.
- **pharmacy.15, 9 Nov:** #122 order notification rows open the order (ORD-001550) ✅. **#127 (new, base main):** order details header "ORD-001550#" → "#ORD-001550" (prescription + OTC details) and the notifications title (hard-coded English "Notifications") translated. Phone ✅.
- **laundry.24, 9 Nov:** #120 ✅ booking LNUNGLAC (placed with `delivery_scheduled_for` / `delivery_slot_end`) shows the delivery slot date and time chips. LNUQZC4R (no delivery slot) and LNUNGLAC are New on dev.
- **Backend recheck, 9 Nov afternoon:** no backend commit since 7 Nov 09:41; **#180 still fails on dev** (`checkoutSummaryV2` → `item_total 0`); root cause and #119 question posted on #180. A Fast Charger (vendor 60) is left in the demo customer's cart.
- **#179 recheck, 9 Nov 11:19 (food.01, logged in on the phone by Claude with the tester's demo account):** Garden Salad Item Details still shows no tags; dev still doesn't send the detail flags.
- **Still to check on the phone:** #121 Item Details tags after backend #179 is deployed; #119 Express tag (no checkout can create an express food / grocery order; waiting on backend / Admin); local store items once backend #180 is fixed.

## 0c. 9 Nov: home cleaning, local store, gas tested; PRs #123–#126

**New PRs** (pushed, merged into `test/retest-2026-11-06`, analyzer 0 errors):

| PR | Base | What |
|---|---|---|
| #123 | main | My Services: the keyboard no longer opens on the search box after saving a service (phone ✅) |
| #124 | main | Home cleaning booking details: cancel reason in the app language; "500 MRU x 2" and the cleaner's "+222 …" phone kept left-to-right in Arabic (phone ✅) |
| #125 | #118 | New-booking popup shows the booking code ("#HCR3VO2O"), not "ORD-001557" (the push has no `order_code`; the code is read from the push text). Test added (phone ✅ code; the "#" side fix is in the next build) |

**Home cleaning, homecleaning.30 (Clean Home Nouakchott, id 78), Arabic: ✅ all**
- HCVRQZLW (Regular Clean Apartment, 1500 MRU): popup "حجز جديد!" + "عرض الحجز" (#118 ✅) → details (customer, code, service, slot in phone time, notes, map, cash 1500 / paid 0) → Accept (VA-30 dialog) → **Assign cleaner** (3 cleaners, rating, "available"; button off until one is picked) → Fatou Ba shown with "Change" → On the way → Start cleaning (dialog warns "scheduled 10 Nov, not today") → Mark completed → paid 1500 with paid time; "Change" hidden once started.
- **Pest control:** set Disinfection (service 55) up in the app (Issues Covered: Cockroaches, Ants; space Kitchen 500 MRU / room) → card shows "500 MRU / room" and pest chips. Booking HC2ONUZF (2 × Kitchen + 2 issues): **Areas** block (Kitchen, 2 × 500 = 1000) and **Issues** tiles with icons ✅ → Reject: 4 reasons in Arabic, Confirm off until one is picked → rejected; reason now shown in Arabic (#124).
- HCR3VO2O (Regular Clean Villa) left **New** for the next tester.

**Admin (data, not the app):** the 3 home cleaning service types (Regular clean 9, Deep clean 10, Disinfection 11) have the English name in `name_ar` / `name_fr`. Saving a service takes its name from its type, so service 55 is now "Disinfection" in Arabic (it was "تعقيم"). Give the types real AR/FR names and restore service 55 (same problem as the car wash types).

**Local store, Ksar Phone Center (vendor 60, localstore.12), Arabic:** order ORD-001560 placed by API (Fast Charger + 2 × Spiral Notebook) → popup "طلب جديد!" + "عرض الطلب" → details → Accept (Pending badge clears) → Prepare (success popup) → Mark ready (success popup) → Ready card "waiting for a delivery partner" (#117) ✅. My Store › Account: name, owner, id, contact, email, status, address, busy switch ✅. **Backend bug [#180](https://github.com/praveensigo/saimpex-backend-new/issues/180):** `checkoutV2` saved the local store order with **no items** (0.00 MRU, "basket order", payment "Online"), so the items list and totals could not be checked; recheck once #180 is fixed. ORD-001560 is Ready on dev.

**Gas, Gaz Butane Dar Naim (vendor 70), water design, Arabic: ✅** booking GSLKRQKD (`service/book` `vertical=gas`, service 14, `quantity=2`, `return_empty_cylinder=1`; `true` as text is refused) → popup "حجز جديد! الحجز #GSLKRQKD" (#125 ✅) → "View booking" opens the water order details: code, delivery, address, line "12 kg Butane Refill" × 2 @ 280, **"2 empty cylinders to collect"**, 560 MRU cash → Accept → Prepare → Mark ready (no vendor button after Ready: the driver delivers) ✅. **Open:** the line name is English on the Arabic screen (the server builds "12 kg Butane Refill"; the service's AR name is "تعبئة غاز البوتان 12 كغ") and the water details card reads only `order_item.name_en`. Ask backend to send `name_ar` / `name_fr` on gas lines (backend list 2.02), then read them with `pickLang` in `_OrderItemCard` (`lib/water/view/order_details/order_details_view.dart`). GSLKRQKD is Ready on dev.

**#126 (new, base main):** Arabic "طلب ORD-001560#" → "طلب #ORD-001560" (the AR `orderIdLabel` string, used on 7 screens) and store contact "95100012 222+" → "+222 95100012" (My Store, Settings). Phone ✅.

**Dev accounts found** (public `GET customer/search`): local store **Test Local Store** (id 48); gas **Test Gas** (47) and **Gaz Butane Dar Naim** (70). Their usernames are not in the docs. Local store order: `cart/localStore/add` {`local_store_id`=48, `product_id`=29 (Spiral Notebook, 40 MRU), `quantity`} then `checkoutV2`. Gas: `service/book` `vertical=gas`, `vendor_id`=70, `service_item_id`=14 (Butane 12 kg, 280 MRU), `quantity`, `return_empty_cylinder=true` (§6.17).

## 0b. Latest client build (7 Nov, ~19:00), replaces 0a

- **APK for the client:** `client-build/SaimpexVendor-v1.0.6-7-dev-2026-11-07-4821b28.apk` (164 MB), from `test/retest-2026-11-06` at `4821b28` (pushed). Dev server, debug-key signed (as 0a). The `6c17701` APK below is older: don't send it.
- **Adds since 0a:** #118 popup now says "New booking / View booking" for service bookings (EN/FR/AR); #121 item tags (Popular, Veg, New arrival); **#122 (new)** notification "View details" button on rows with `link_type`/`link_id` (restaurant, water/gas/service and pharmacy screens), routed like a push tap.
- **Checks:** analyzer 0 errors; `flutter test` 63 / 63; installed on the Samsung.
- **Phone ✅ #122:** laundry.24 (Arabic): button only on booking rows, RTL fine, opens Booking Details LNMR4R1P. Result posted on #122.
- **Not phone-checked yet (needs a tester login):** #121 tags (food.01 → Items, Item Details), #122 on restaurant and pharmacy, #118 popup wording (place a new laundry booking), #119 Express tag (needs an express order), #120 (laundry booking with `delivery_window`).
- **Backend, new (wording only):** the "Needs your attention" row (`GET activityNotifications`) shows "New order / View order" (طلب جديد / عرض الطلب) for a laundry **booking**; the text comes from the server's `title_*` / `action_*`. Ask backend to send booking wording when the row is a service booking. Added to `backend-issues-vendor-app-2026-11-07.md`.
- PR #122 base is #118 (`fix/service-booking-push`); merge after it.

## 0a. Client build (7 Nov, 18:18)

- **APK for the client (superseded by 0b):** `client-build/SaimpexVendor-v1.0.6-7-dev-2026-11-07-6c17701.apk` (164 MB), built from `test/retest-2026-11-06` at `6c17701` (pushed). **Dev server** (default; a live build needs `--dart-define=SAIMPEX_LIVE=true` and the real upload key, see #113). Signed with the debug key (no `key.properties` on this PC): fine for testing, not for the Play Store.
- **Checks:** `flutter analyze --no-pub` 0 errors; `flutter test` **63 / 63 pass** (fixed the laundry slot-chips test on #84: dates now carry direction marks); installed on the Samsung, opens and loads (laundry.24, Arabic; store name now in Arabic thanks to backend #170).
- **Phone ✅ #118:** laundry booking LNMR4R1P (placed by API) → push + popup within ~12 s → "View" opens the booking.
- **Small, not fixed:** the new-booking popup says "New order · ORD-001556" instead of "New booking · LNMR4R1P" (`showInAppNewOrderAlert` in `lib/view/notifications/notification.dart`; add a "New booking" string in EN/FR/AR and use `order_code` when `is_booking` = 1).
- **Test data on dev:** LNMR4R1P is New (cancel it from Admin, or use it for the laundry flow).

## 0. Latest (7 Nov evening): backend fixes checked, app side done

**Backend.** `integration/v2` commits `578cd1c` and `01b526613` (both 7 Nov, **deployed on dev**: `updated_at_iso` is live) fix every open `[vendor-app]` issue: #168 booking push, #169 laundry windows, #170 AR/FR names, #171 pharmacy rider, #172, #173, #174 push + vendor check, #175 express / popular, #179 veg / new arrival / notification links, plus status-log ISO times and `serviceDashboard.accepting_bookings`. The GitHub issues are **still open**: ask Praveen to close them (#176 is a duplicate). Full list: `backend-issues-vendor-app-2026-11-07.md`.

**New PRs (pushed, merged into `test/retest-2026-11-06`, analyzer 0 errors):**

| PR | Base | What | Backend |
|---|---|---|---|
| #118 | #75 | Service booking pushes: "View" / tap opens the booking (laundry, car wash, home cleaning); a `service_booking_cancelled` push no longer rings as a new order | #168 |
| #119 | #90 | Express tag on restaurant / grocery / local store order cards and details (`is_express`, or raw `type` "express" on lists) | #175 |
| #120 | #84 | Laundry details: DELIVERY TURNAROUND date/time chips from `delivery_window` (text fallback) | #169 |

**No app change needed:** #171 rider (the pharmacy model already reads `delivery_boy_name`); #170 names (server-side); #174 (server-side); status-log times (#114 already reads the text; `updated_at_iso` also works); #172 / #173 (done earlier).

**Still to do (app), in order:**
1. **Phone checks** of #118 (place a laundry booking by API, tap the push / popup "View"), #119 (needs an express order: `checkoutV2` with an express delivery option), #120 (open a laundry booking that has `delivery_window`).
2. **#175 / #179 item tags (P3):** Items list "Veg" / "New arrival" chips (`restaurantCatalogItems` rows `is_veg`, `is_new_arrival`; card in `lib/view/restaurant/vendor_restaurant_screen.dart` near the category chip, ~line 1369); Item Details "Popular" tag + orders count / recent orders (`restaurantCatalogItemDetail` `is_popular`, `orders_count`, `recent_orders[]`; `lib/view/restaurant/Widgets/view_item_details.dart`, branch on #88/#109). Strings exist: `veg`, `nonVeg`; add `newArrival`, `popular` in EN/FR/AR.
3. **#179 notification action buttons:** `vendorapp/notifications` rows now have `link_type` (order / booking), `link_id`, `order_code`: add a "View order" / "View booking" button per row (water `lib/water/view/notifications/notifications_view.dart`, restaurant `lib/view/notifications/notifications.dart`, pharmacy screen).
4. **Home endpoint** sends no `is_express` (only lists / detail do): ask backend to add it so Home cards show the Express tag.
5. Existing test `test/service_kind_blocks_test.dart` "laundry block: slot chips…" fails on an IST PC (expects UTC dates): make it time-zone safe.
6. Then §5 below (home cleaning test, PR results, message to Praveen, Admin requests).

---

## 1. Where things are now

| What | State |
|---|---|
| `main` | `4c604a6`. It has the P1 merges #44, #45, #64 and #65. Nothing else is merged; Praveen approves every merge. |
| Test branch | `test/retest-2026-11-06`, **pushed**, head `957d3aa`. It is `main` plus every open PR. Analyzer: 0 errors. |
| Phone build | `build/app/outputs/flutter-apk/vendor-957d3aa.apk`, installed on the Samsung M11 (wireless adb). |
| Uncommitted work | None. Every branch is pushed. |
| GitHub CLI | `gh` is installed at `C:\Program Files\GitHub CLI\gh.exe` and signed in as `sigosoft`. |

**Build and install:**

```bash
git fetch origin && git checkout test/retest-2026-11-06
flutter pub get
flutter analyze --no-pub
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## 2. New PRs today (7 Nov, afternoon)

They are all merged into the test branch and phone-tested (✅).

| PR | Base | What | Phone |
|---|---|---|---|
| #114 | main | Order timeline times. The server sends status-log times already formatted in English and UTC ("07 Nov 2026 07:39 AM"); they are now read as UTC and shown in phone time and the app's language. Test added; 54 tests pass. | ✅ 02:09 م / 02:11 م on ORD-001548 |
| #115 | #73 | Tab badges reload after Accept. "Pending 01" stayed after Accept, on the home card and from the order details screen (2 commits). | ✅ food.01, grocery.08, pharmacy.15 |
| #116 | main | An empty chat says "No messages yet" (it said "no contacts found"). | ✅ |
| #117 | #70 | A Ready order with no driver says "Waiting for a delivery partner" (it said "Assigned" with no name). New key `waitingForDeliveryPartner`. | ✅ |

**Merge order:** add them to the end of the list in the 6 Nov file's §3:
- #115 after #73;
- #117 after #70;
- #114 and #116 any time (they are on `main`).

Expect the usual `.arb` conflicts: keep both sets of keys, then regenerate.

---

## 3. Live order testing done today

**Method.** Orders and bookings were placed by API on the **dev** server as the demo customer **Aminata Sow (+222 95200020)**. This was approved by Stephy. Each one was then followed on the phone, in Arabic.
- Log in: `POST /api/customer/sendOtp`, then `verifyOtp` with the dev test code 123456.
  - `country_code` must be URL-encoded: `--data-urlencode "country_code=+222"`.
  - Keep the token out of chat and logs.
- Orders:
  - add to cart with `cart/{restaurant|grocery|pharmacy|water}/add` (`restaurant_id` / `grocery_id` / `pharmacy_id` / `water_vendor_id`, `product_id` = item id, `quantity`);
  - then `checkoutV2` with `is_self_pickup=0, lat, long, location, payment_type=1` (cash).
- Service bookings: `service/book` with:
  - `vertical`, `vendor_id`, `service_item_id`, `latitude`, `longitude`, `payment_type=1`, `scheduled_for`, `slot_end` (UTC "Y-m-d H:i:s");
  - car wash: `place=station` plus `vehicles=[{"name":"Sedan","plate":"…"}]`;
  - laundry: `quantity` (kg estimate), `address`, `delivery_address`.
- Customer side of a rejected order: `GET orderDetails?order_id=` returns `cancel_reason` and `cancel_message`.

| Vendor | Order | What was checked | Result |
|---|---|---|---|
| Restaurant food.01 | ORD-001548 (2 × Garden Salad, 300 MRU) | new-order popup within ~20 s; Pending card with Accept & Print; Accept + success popup; badges; Prepare; Mark ready; Ready card driver line; no Print on Ready; Chat with Customer (empty chat text); timeline times | ✅ all |
| Grocery grocery.08 | ORD-001549 (Bananas × 1, Tomatoes × 2, 190 MRU) | popup → "View order" opens it (VA-15); Edit Items above the list, opens, order stays Pending (VA-14); Change quantity on a quantity-1 line explains why, in Arabic (VA-18); Accepted list layout in Arabic (VA-17); Accept from details | ✅ (fixed a badge bug, #115 second commit) |
| Pharmacy pharmacy.15 | ORD-001550 and ORD-001551 (OTC, Cough Syrup × 2, 220 MRU each) | one popup for two orders; hours line "اليوم: 00:00 - 23:59"; home-card Reject reason sheet (#98): Confirm stays off until a reason is picked, "Out of Stock" sent, and **the customer sees "The store could not accept your order: Out of Stock"**; Accept, Prepare and Mark Ready **from the detail screen** | ✅ all |
| Water water.19 | ORD-001552 (2 × 1.5 L, 230 MRU) | popup → View order; details; Accept → Prepare → Ready from details; timeline times; **Ready card "جاهز: بانتظار مندوب التوصيل لاستلامه" (W-14, #66)**; Revenue 3315 | ✅ all |
| Car wash carwash.27 | CWICUIIR (Interior + Sedan 1234 AB 01, 300 MRU, at the station) | My Services › Edit: added vehicle type "Sedan · 300 MRU" (saved); card "Vehicle 1 · Interior · Sedan"; **Vehicles block** (car tile, plate, wash type, price); location "في محطة الغسيل"; **a confirmation dialog before every step (VA-30)**; Completed, paid 300 | ✅ all |
| Laundry laundry.24 | LNHCFL01 (Wash & Fold, 3 kg estimate = 180 MRU) | **new booking popup within 30 s with no refresh (VA-28)**; card with estimate, slot, "Standard (24h)"; step dialogs (VA-30); **Verify Weight** 3 → 4 kg = 240, difference +60, Send payment request; "Additional payment pending" with Paid 0 / Final 240 / Balance 240; Delivered → green **"Paid"**, Balance 0 | ✅ all |

**Test data left on dev:**
- ORD-001546, ORD-001548 (restaurant), ORD-001550 (pharmacy) and ORD-001552 (water) are **Ready**.
- ORD-001549 (grocery) is **Accepted**.
- ORD-001551 is **cancelled** (Out of Stock).
- CWICUIIR is **Completed**; LNHCFL01 is **Delivered**.
- Cancel the open ones from Admin if they get in the way.

---

## 4. Found today and still open

1. **The car wash service name changed after Edit (data, not the app).**
   - What happened: saving "Interior Cleaning" (id 36) in the app renamed it "Interior" in EN, AR and FR.
   - Why: as in Figma, a service takes its name from its **service type**, and on dev the car wash types are named "Interior" / "Exterior" in all three languages.
   - What Admin should do: give the service types real AR/FR names, and restore the name of service 36 (it was "Interior Cleaning" / "تنظيف داخلي").
2. **Small:** after saving a service, the keyboard pops up on the My Services search box. Not fixed.
3. **Home cleaning is not tested yet.**
   - The phone was about to be logged in as homecleaning.30.
   - Its 4 services (Deep Clean 54, Disinfection 55, Regular Clean Apartment 52 / Villa 53) have **no spaces, add-ons or issues**.
   - A booking can test the card, details, step dialogs (VA-30) and **assign cleaner**.
   - The **pest control Areas and Issues tiles** need a service with issues covered first. Add them in the app (My Services › Add Service › Issues Covered) or ask Admin.
4. **Still needs an Admin action:** a test **payout** with a payment proof, to test "View payment proof" (#101) on restaurant and water.
5. **Still not tested:**
   - water "Low stock › View all" (#102; no low-stock product);
   - a gas account;
   - scanning a real barcode in the inventory search (#106);
   - the Express tag (waits for backend #175).

---

## 5. What to do next, in order

1. **Home cleaning test (homecleaning.30):**
   - book service 52 by API: `vertical=home_cleaning`, `vendor_id=78`, `service_item_id=52`, `property_type=Apartment`, `address`, `latitude` / `longitude`, `scheduled_for` / `slot_end`;
   - check the card, details, step dialogs, assign cleaner, then complete it;
   - then set up a pest-control service with issues covered and book it to see Areas and Issues.
2. Post the "Phone ✅" results on the PRs: #114–#117, #98, #66 and #115 are already done. Add the car wash (#96 / #111), laundry (#97 / #83–#86) and VA-30 PRs.
3. **Send Praveen** the review request, adding #114–#117 and today's results. Start from `message-to-praveen-2026-11-06-followup.md`.
4. Ask Admin for: a test payout with a proof; real AR/FR names for the car wash service types; restoring service 36's name.
5. Then follow the open list in `HANDOVER-vendor-app-2026-11-06-final.md`:
   - §4.2 backend-dependent work;
   - §4.3 decisions (V8, login type list, water call vs chat, restaurant Busy card);
   - launch keys (§00).

---

## 6. Rules recap

- Figma is reference only; never edit it.
- UI changes only: every value comes from the API, with no sample data.
- EN/FR/AR for every string; then run `flutter pub run intl_utils:generate`.
- `flutter analyze --no-pub`: 0 errors.
- One task = one branch = one PR into `main`.
- Praveen approves merges.
- Dev server only.
- **Never put passwords or tokens in chat, commits or logs.** The tester logs in on the phone.
