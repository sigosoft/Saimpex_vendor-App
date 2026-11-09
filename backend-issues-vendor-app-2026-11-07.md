# SAIMPEX V2 vendor app: backend issues to resolve

> **Update 7 Nov evening:** backend commits `578cd1c` and `01b526613` (deployed on dev) fix every item below. Please **close #168–#175, #179 and the duplicate #176**. One small follow-up: the vendor `home` endpoint's order rows have no `is_express` (lists and detail do), so Home cards can't show the Express tag yet. The vendor app side is in PRs #118 (booking push), #119 (Express tag) and #120 (laundry delivery window).

**To:** Praveen (backend, `praveensigo/saimpex-backend-new`, branch `integration/v2`)
**From:** vendor app team · 7 Nov 2026 · Launch: 1 Dec 2026
**Source:** vendor app test report (6 Nov) and phone checks on dev (7 Nov). Each item is a GitHub issue in the backend repo.

> **Summary.** 9 open `[vendor-app]` issues. Backend commit `5d83569df` (6 Nov) already fixed #172 and #173 completely and parts of #169, #170 and #171, so those can be closed or reduced. Still needed: **2 P1** (#168 booking push, #174 order push + vendor check) and the remaining parts below. #176 is a duplicate of #168 and can be closed. The vendor app side of every fixed part is already built and phone-checked.

## 1. Status at a glance

| Issue | Priority | Subject | Status after `5d83569df` | Action |
|---|---|---|---|---|
| #168 | **P1** | No vendor push when a service booking is created | Open | Build (§2.1) |
| #174 | **P1** | Restaurant new-order push skipped when Pusher fails; prepare / ready don't check the vendor | Open | Build (§2.2) |
| #169 | P2 | Laundry pickup slot not stored; "10–12 PM" default | Partly fixed (slot applied, label fixed) | Return `slot_label` (§2.3) |
| #170 | P2 | Laundry "piece" unit gives 0 MRU; garments have no FR/AR names | Partly fixed (price) | FR/AR names (§2.4) |
| #171 | P2 | Pharmacy lists: payment type, self pickup, rider; wallet status log | Partly fixed (payment type, labels, log) | Rider name (§2.5) |
| #172 | P2 | Pharmacy action messages English only | ✅ Fixed | Close |
| #173 | P2 | Earnings: per-order commission and net | ✅ Fixed (phone-checked on dev) | Close |
| #175 | P3 | Restaurant: order Express flag and item Popular tag | Open | Build (§2.6) |
| #179 | P3 | Restaurant item veg / new-arrival flags; notification type and link | Open | Build (§2.7) |
| #176 | — | Duplicate of #168 (filed twice) | — | Close |

## 2. What is still needed

### 2.00 · #180 (P1, new 9 Nov) · Local store checkoutV2 creates an order with no items
- **Seen:** `cart/localStore/add` (vendor 60, 2 lines) then `checkoutV2` (cash) → ORD-001560 created with `items: []`, `item_total: 0`, payment "Online Payment"; the vendor app shows a basket order with 0 items.
- **Needed:** checkoutV2 / checkoutSummaryV2 read local store cart lines (or say which checkout the customer app must use). Vendor app unaffected.

### 2.01 · Admin data (9 Nov) · Home cleaning service type names
- Service types 9 (Regular clean), 10 (Deep clean), 11 (Disinfection) have the English name in `name_ar` / `name_fr`. Saving a service takes its name from its type, so service 55 became "Disinfection" in Arabic (was "تعقيم"). Give the types AR/FR names and restore service 55.

### 2.02 · New 9 Nov (P3) · Gas order lines have only an English name
- **Seen:** `waterOrderDetail` for gas booking GSLKRQKD shows the line "12 kg Butane Refill" on the Arabic screen; the service has `name_ar` "تعبئة غاز البوتان 12 كغ".
- **Needed:** send `name_en` / `name_fr` / `name_ar` on each gas line (`order_item`), from the service's names. Confirm the field names in `API_CHANGELOG.md`; the app will then show the line in the app language.

### 2.0 · New (7 Nov evening, P3) · "Needs your attention" says "order" for a service booking
- **Screen:** laundry / car wash / home cleaning Notifications, "Needs your attention" row (`GET activityNotifications`).
- **Now:** a new laundry booking (LNMR4R1P) shows title "New order #LNMR4R1P" / action "View order" (AR: طلب جديد / عرض الطلب). The app shows the server's `title_*` / `action_*` text as is.
- **Needed:** for a service booking row, send booking wording in EN/FR/AR (e.g. "New booking" / "View booking"; FR "Nouvelle réservation" / "Voir la réservation"; AR حجز جديد / عرض الحجز), and `kind` = `new_booking` (or `link_type` = `booking`) with the booking id, so the app can open it from this row too.
- **Also:** `GET vendor home` sends no `is_express` (lists and order detail do), so Home order cards can't show the Express tag.

### 2.1 · #168 (P1) · Vendor push when a laundry / car wash / home cleaning booking is created
- **Screen:** service vendor Home and Bookings (test report VA-28).
- **Now:** `ServiceBookingService` / customer `ServiceController` create the booking but send no vendor push. The vendor only sees it after a refresh; the app polls every 30 s and on resume as a stop-gap.
- **Needed:**
  - Vendor push on booking creation (and on customer cancel), with `data.type` (e.g. `new_service_booking`) and `data.booking_id`.
  - An `API_CHANGELOG.md` entry with the exact payload.
- **App after the fix:** recognise the type in `notification.dart`, refresh the bookings list, open the booking on tap.

### 2.2 · #174 (P1) · Restaurant new-order push; vendor check on order actions
- **Screen:** restaurant / grocery Home (VA-01) and order actions (VA-05).
- **Now:**
  - In customer `OrderController`, `broadcast(new OrderPlaced…)` runs before the vendor push inside one `try`. If Pusher fails, no push is sent.
  - `markAsReady*Order` and `prepare*Order` don't filter by `vendor_id`: a vendor can change another vendor's order by id.
- **Needed:** send the push in its own `try` (or before the broadcast); add the `vendor_id` check to every order action. Also check that food.01's `users.fcm` is current.
- **App after the fix:** nothing to change; retest VA-01. (7 Nov: with the app open, the new-order popup appeared within ~25 s through the app's own polling.)

### 2.3 · #169 (P2) · Laundry: return the chosen slot label
- **Fixed in `5d83569df`:** a date-only booking takes its start/end from the chosen slot; the default label is "10 AM–12 PM"; the en-dash slot parser.
- **Still needed:** return the stored `slot_label` (pickup and delivery) in `serviceBookings` and `serviceBookingDetail`. Also send the **delivery turnaround** as data (date + time window), not only the formatted `delivery_turnaround` string; the Figma "Delivery turnaround" block is hidden until then.

### 2.4 · #170 (P2) · Laundry: garment and service names in French and Arabic
- **Fixed in `5d83569df`:** per-piece services start at the cheapest garment; numeric `starting_price` (phone-checked).
- **Still needed:** `name_fr` / `name_ar` for garments and service items (or the name in the request language). Seen on dev: "Household Linen" stays English in the Arabic app. The demo seed also uses one photo for every service item.

### 2.5 · #171 (P2) · Pharmacy order lists: rider name
- **Fixed in `5d83569df`:** `payment_type` + `payment_type_label(_en/fr/ar)` on list and detail; wallet orders saved as wallet; status log text. `is_self_pickup` is already in the list.
- **Still needed:** `delivery_boy_name` (assigned rider) on each `pharmacyOrders` row, so the Ready / Out-for-delivery cards can show the partner as in Figma.

### 2.6 · #175 (P3) · Restaurant: order Express flag, item Popular tag
- **Needed:** `is_express` on order list and detail (restaurant, grocery, local store); `is_popular` and a per-item orders list on `restaurantCatalogItemDetail`, or confirm they are out of scope.
- **App after the fix:** Express tag on order cards and details; Popular tag on Item Details (both in Figma, hidden now).

### 2.7 · #179 (P3) · Item veg / new-arrival flags; notification type and link
- `restaurantCatalogItems` rows: `is_veg` (Add Item sends it, the list does not return it) and `is_new_arrival` (or the rule, e.g. created in the last N days).
- `notifications` rows (all vendor types): `type` and the linked id (`order_id`; `subscription_id` for water), for the Figma action buttons.

### 2.8 · New (7 Nov), no issue yet · order status-log times
- Vendor order details `status_logs[].updated_at` and customer `trackOrder` `timeline[].updated_at` come pre-formatted in English and UTC ("07 Nov 2026 07:39 AM"). Please also send the raw ISO time (e.g. `updated_at_iso`) so apps can show phone time in their language. (The vendor app is adding a parser for the current text meanwhile.)

### 2.9 · New (7 Nov), no issue yet · `serviceDashboard` has no `accepting_bookings`
- The old service Business settings read `accepting_bookings` from `serviceDashboard`, which sends only `is_busy`. The app now uses the generic `businessSettings` endpoints (works). Optional: add `accepting_bookings` and `store_open` to `serviceDashboard`.

## 3. Already resolved: please close
- **#172** pharmacy action messages: EN/FR/AR since `5d83569df`.
- **#173** earnings commission / net: confirmed on the phone (e.g. 135 MRU → commission 13.50, net 121.50).
- **#176** duplicate of #168.

## 4. Not code: owner actions before launch (launch keys checklist)
- **Play Store upload key:** `playstore_key` was committed to the public vendor repo (commit `218d66e`). The repo stays public (decision 7 Nov), so if it is the live upload key, reset it in Play Console (Setup › App signing › Request upload key reset). Vendor PR #113 untracks it and adds `key.properties` signing.
- **Google Maps key:** restrict it in Google Cloud to Maps SDK / Places and packages `saimpex.vendor`, `app.saimpex` + iOS bundle IDs.
- **iOS (vendor):** `GoogleService-Info.plist`, APNs key in Firebase, release SHA-1/256 in Firebase, distribution certificate and profiles.

## 5. Decisions needed (product)
- **V8 (laundry):** a booking can be Delivered with money still owed (dev: LNKKNMD1, 240 MRU due). Block it, or ask to confirm?
- **Login type list:** Figma has none, the app shows one. Keep or remove?
- **Water:** call button or chat button on the order?
- **Restaurant:** keep the Busy card (no Figma frame) and the Product Customizations tab?

---
Vendor app PRs waiting for review: #39–#113 (merge order in the vendor repo's `docs/HANDOVER.md` §4.6, PR #99). Questions: reply on the GitHub issue or to the vendor app team.
