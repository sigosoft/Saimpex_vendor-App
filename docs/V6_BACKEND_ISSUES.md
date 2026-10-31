# V6: backend gaps found while replacing mock data

Drafts for GitHub issues in `praveensigo/saimpex-backend-new` (one `##` section = one issue). Written 31 Oct 2026 against `integration/v2`. The app hides or shows an empty state for each gap; nothing is built against a guessed API.


Each section is a draft GitHub issue for `praveensigo/saimpex-backend-new`. Read from branch `integration/v2`.

---

## [vendor-app] Water: no delivery calendar endpoint (Subscription Calendar screen)

- **Screen:** Water → Home → Subscription Calendar (`lib/water/view/subscription_calendar/subscription_calendar_view.dart`).
- **Endpoint:** none. The only subscription endpoints are `GET vendorapp/waterSubscriptions` (paginated list) and `GET vendorapp/waterSubscriptionDetails` (one subscription, with 3 `upcoming` rows).
- **What we get:** per subscription, `next_delivery_at`, `frequency_days`, `delivery_slot`, `starts_at`, `ends_at`, `status`. Nothing grouped by day.
- **What the design needs:** for a week (e.g. `GET vendorapp/waterDeliveryCalendar?from=YYYY-MM-DD&to=YYYY-MM-DD`):
  - per day: `date`, `count` of scheduled deliveries;
  - for the selected day: deliveries grouped by slot (`slot` label + time range), each with `subscription_id`, `customer_name`, `customer_id`, `frequency` (or `frequency_days`), product name + bottle count, `status`, delivery/self-pickup;
  - stats for the day: total, morning, afternoon, paused;
  - optional filters: `slot` (morning/afternoon/evening), `status`, `keyword` (customer name / subscription id).
  - Hide `pending_payment` subscriptions.
- **App now:** the screen shows "Delivery calendar not available yet" instead of the fake week/slots/customers.

---

## [vendor-app] Water: subscription details has no delivery history

- **Screen:** Water → Subscription Details (`lib/water/view/subscription_details/subscription_details_view.dart`), "DELIVERY HISTORY" block.
- **Endpoint:** `GET vendorapp/waterSubscriptionDetails?subscription_id=` (WaterPlanController@waterSubscriptionDetails).
- **What we get:** `data.subscription` + `data.logs` (`customer_water_subscription_logs`: `action` = accept / reject / pause / resume, `meta`, `created_at`). These are status changes, not deliveries. No orders created for the subscription are returned.
- **What we need:** `data.deliveries` (latest first, paginated or last N): `order_id`, `order_code`, `status` (delivered / in progress / cancelled), `delivered_at` or `scheduled_for`. A "view all" list endpoint would be needed for the "View all" link.
- **App now:** the block (and the "View all" links) are hidden.

---

## [vendor-app] Water: subscription details lacks savings / delivery fee / tax and a structured address

- **Screen:** Water → Subscription Details, "PAYMENT SUMMARY" and "DELIVERY ADDRESS".
- **Endpoint:** `GET vendorapp/waterSubscriptionDetails`.
- **What we get:** `amount` (plan price × quantity, §6.14), `payment_type` (1 cash / 2 online / 3 wallet), `payment_status` (1 pending / 2 paid), `paid_at`, `plan_price`; address only as `address_line1` (+ lat/lng).
- **What the design shows:** subscription amount, subscription savings, estimated delivery fee, tax, payment date, total paid; address title (e.g. home name) + address line.
- **What we need:** if these exist for subscriptions: `savings`, `delivery_fee`, `tax`, `total` (what the customer pays), and the address `title`/`label` + full address (join `address_id`). Also please confirm whether `quantity` multiplies `bottles_per_delivery` (the app shows bottles per delivery × quantity).
- **App now:** shows amount, payment method, payment date (when paid) and "Total paid" / "Amount due"; savings / delivery fee / tax rows are hidden; address shows `address_line1` only.

---

## [vendor-app] Water: subscription text fields come back in English only

- **Screen:** Water → Home (subscription cards) and Subscription Details.
- **Endpoint:** `GET vendorapp/waterSubscriptions`, `GET vendorapp/waterSubscriptionDetails` (`presentSubscription`).
- **What we get:** English-only presentation strings: `frequency` ("Daily", "Every 3 days"), `next` ("Tomorrow"), `status_label`, `schedule` ("Next: … · Daily"), `upcoming[].label` ("Tomorrow"/"Monday"), dates as `M-d-Y` / `d M Y`. Action messages (`Subscription paused`, etc.) are plain English strings, not `{message_en, message_fr, message_ar}`.
- **What we need:** raw values are enough (the details screen now builds frequency/dates from `frequency_days`, `next_delivery_at`, `starts_at`, `ends_at`, `paused_at`). Please translate the action messages (en/fr/ar) like other vendor endpoints, and consider dropping or localising the preformatted strings.

---

## [vendor-app] Water: vendor notifications have no type or link to an order/subscription

- **Screen:** Water → Notifications (`lib/water/view/notifications/notifications_view.dart`).
- **Endpoint:** `GET vendorapp/notifications?vendor_type=4&limit=&page=` (NotificationController@index).
- **What we get:** admin broadcast rows (`type` 1 all / 3 user) with `title_en|fr|ar`, `content_en|fr|ar`, `created_at`. For `vendor_type` 4 only types 1 and 3 are returned (no water-specific type).
- **What the design shows:** per notification a kind (new order / new subscription / low stock) with its own icon/colour and an action button (View Order, Review Subscription, Update Stock).
- **What we need:** event notifications for water vendors (new order, new subscription, low stock) with `kind` and a target id (`order_id` / `subscription_id` / `item_id`), plus read/unread if available.
- **App now:** shows title, content and time with one neutral style and no action button.


Source checked: `integration/v2`. Files: `app/Http/Controllers/vendor/ServiceVerticalController.php`, `app/Services/ServiceBookingService.php`, `app/Services/VendorScreenData.php`, `app/Http/Controllers/android/vendorapp/HomeController.php`.

---

## [vendor-app] Home cleaning booking: product supply choice is not in the booking payload

- **Screen:** Home Cleaning > Booking details, "Cleaning products" block
- **Endpoint:** `GET vendorapp/serviceBookingDetail?order_id=` (and `serviceBookings`)
- **What we get:** a `lines[]` row with `kind: "supply"` (name "Cleaning products", price = supply fee). It only exists when the customer picked `product_supply=vendor` **and** the service has a `supply_fee > 0`. Nothing is stored or returned when the customer brings their own products, or when the vendor supplies them for free.
- **What we need:** an explicit `product_supply` (`vendor` | `customer`) on the booking (and the fee, 0 allowed), so the screen can show "Provider will provide products" or "Customer provides products" in every case.
- **App now:** the block is shown only when a `supply` line exists; otherwise it is hidden.

## [vendor-app] Home cleaning: no reject reasons from the API

- **Screen:** Home Cleaning > Reject booking sheet
- **Endpoint:** `GET vendorapp/serviceBookings` / `serviceBookingDetail` -> `reject_reasons`
- **What we get:** `reject_reasons: []` for home cleaning (vendor_type 9). The list is only filled for car wash and laundry, and only in English.
- **What we need:** the home cleaning reasons (e.g. no cleaner available, outside service area, service temporarily unavailable, other) with `en`/`fr`/`ar` labels and a stable key to send back.
- **App now:** uses its own list; sends `status=10`, `reason=<English reason>` and, for "Other", `reason=Other` + `note=<typed text>` (max 100), which the backend splits back into `reject_reason` / `reject_note`.

## [vendor-app] Membership for service vendors only available from GET home

- **Screen:** Home Cleaning > Home header, membership card ("Silver Member", "Expires in N days")
- **Endpoint:** `GET vendorapp/serviceDashboard`
- **What we get:** `screen.welcome.subscription_days_left` only, no plan name. The plan (`membership.name_en/fr/ar`, `expires_in_days`) is only in `GET vendorapp/home` (which needs `limit` and also builds the order list).
- **What we need:** a `membership` block (`name_en`, `name_fr`, `name_ar`, `expires_in_days`, `subscription_end_date`) in `serviceDashboard`, so the service home makes one call.
- **App now:** calls `GET home?limit=1` just for `membership`; the card is hidden when it is null.

## [vendor-app] Home cleaning booking: no service image, no place label

- **Screen:** Home Cleaning > Booking details (service card, location card) and list card
- **Endpoint:** `GET vendorapp/serviceBookingDetail?order_id=`
- **What we get:** service name (`service_name_en/fr/ar`) but no image; `address`, `latitude`, `longitude`, `place` (service_place, null for cleaning) but no place title (the design shows "Sahara View Home" above the street address).
- **What we need:** `service_image` (service item image URL) and an address label/title if the customer saved one.
- **App now:** neutral icon tile instead of the image; the location card shows only the address (map only when lat/lng are present).

## [vendor-app] serviceBookings: filter by several statuses

- **Screen:** Home Cleaning > Bookings list, "Accepted" chip
- **Endpoint:** `GET vendorapp/serviceBookings?status=`
- **What we get:** one status per call. Home cleaning "accepted" covers status 2 (accepted) and 8 (on the way).
- **What we need:** `status=2,8` (comma list) or a named group (e.g. `accepted` -> [2, 8] for vendor_type 9).
- **App now:** two calls (status 2 and 8) merged and sorted by id; paging is per status.

## [vendor-app] Home cleaning status flow: "Start Cleaning" used for two steps

- **Screen:** Home Cleaning > booking card / details action button
- **Endpoint:** `VendorScreenData::nextStep` (sent as `next_action` / `next_status`)
- **What we get:** status 2 -> 8 action "Start Cleaning" (key `on_the_way`) and 8 -> 3 action "Start Cleaning" (key `in_progress`). The vendor taps "Start Cleaning" twice to reach In progress.
- **What we need:** confirm the intended flow: either 2 -> 8 is "On the way" (and 8 -> 3 "Start Cleaning"), or 2 -> 3 directly (already allowed by `updateBookingStatus`).
- **App now:** follows the server's `next_status`; status 8 shows an "ON THE WAY" pill under the Accepted chip with the "Start Cleaning" button.


Backend read from `origin/integration/v2` (vendor `ServiceVerticalController`, `android/vendorapp/ChatController`, `ProfileController`).

---

## [vendor-app] Home cleaning service types: no way to tell "cleaning" types from "pest control" types

- **Screen:** Add / Edit Service (`lib/home_cleaning/view/add_service_view.dart`)
- **Endpoint:** `GET vendorapp/serviceTypes`
- **What we get:** `service_types[]` rows with `id, vendor_type, vendor_id, name_en, name_ar, name_fr, status, approval_status, …`. Seeded home cleaning types are `Regular clean`, `Deep clean`, `Disinfection`.
- **What we need:** The design shows "Cleaning products" + "Add-on services" for cleaning types and "Issues covered" (pests) for pest control / disinfection types. The app used to decide this from hard-coded English names. We need a field on each type, for example `kind: "cleaning" | "pest_control"` or flags `has_addons`, `has_issues`, `has_product_supply`.
- **Interim in the app:** every optional section is shown for every type (the backend accepts all of them for any item).

## [vendor-app] Home cleaning add-ons have no unit

- **Screen:** Add / Edit Service, "Add-on services" sheet
- **Endpoint:** `POST vendorapp/addServiceItem`, `POST vendorapp/updateServiceItem` (`addons[]`), `GET vendorapp/serviceItems` (`addons[]`)
- **What we get:** `service_item_addons` stores `name`, `price` (and `detail`, `image` when those columns exist). No `unit`.
- **What we need:** The design lets the vendor pick a unit per add-on (Unit / Hour / Room / Piece, shown as "100 MRU/Unit"). Either add `unit` to `service_item_addons` (read and write it like `service_item_spaces.unit`) or confirm add-ons are always a flat price.
- **Interim in the app:** the unit picker is removed from the add-on sheet; add-ons show "100 MRU".

## [vendor-app] Confirm stored values for property types, product supply and issues covered

- **Screen:** Add / Edit Service, My Services
- **Endpoint:** `POST vendorapp/addServiceItem`, `POST vendorapp/updateServiceItem`
- **What we get:** `property_types`, `product_supply` and `issues` are free string lists. The customer booking API (`android/customer/ServiceController`) validates `product_supply` as `customer|vendor` and takes a free `property_type` string.
- **What the app sends now:** `property_types` = `["Apartment","Villa"]`, `product_supply` = `["customer","vendor"]`, `issues` = English ids from the app's catalogue (`Cockroaches`, `Ants`, `Bed Bugs`, `Mosquitoes`, `Rodents`, `Termites`, `General Sanitization`, `Flies`, `Other Pests`).
- **What we need:** confirmation that these are the values the customer app and the admin expect (or a list endpoint for them, with translations). Issue names and property types are stored in English only, so the customer app cannot translate them unless both sides use the same ids.

## [vendor-app] Vendor notification on/off preference

- **Screen:** Home Cleaning Account (`lib/home_cleaning/view/home_cleaning_account_view.dart`), "Notification" switch
- **Endpoint:** none. `routes/vendorapp.php` only has `GET notifications` (the list).
- **What we get:** nothing; the switch only changed a local variable.
- **What we need:** `GET`/`POST` for the vendor's push notification preference (for example a `notifications_enabled` field on `profile` plus an update endpoint).
- **Interim in the app:** the switch row is hidden.

## [vendor-app] Delete a chat conversation (vendor side)

- **Screen:** Home Cleaning Messages (`lib/home_cleaning/view/chat/home_cleaning_messages_view.dart`), trash icon on each thread
- **Endpoint:** none. Vendor chat routes are `chat/allConversations`, `chat/getConversation`, `chat/sendMessage`, `chat/markAsRead`, `chat/totalUnreadMessagesCount`.
- **What we get:** no delete or archive endpoint.
- **What we need:** `POST vendorapp/chat/deleteConversation {conversation_id}` (hide for the vendor only) if the design keeps the trash icon.
- **Interim in the app:** the trash icon is hidden.

## [vendor-app] Customer online status in chat

- **Screen:** Home Cleaning Messages (green dot on avatar) and Conversation header ("Online" / "Offline")
- **Endpoint:** `chat/allConversations`, `chat/getConversation`
- **What we get:** `customer {id, name, mobile, image, country_code}`, no presence data.
- **What we need:** a presence field (for example `customer.is_online` or `last_seen_at`), or drop it from the design.
- **Interim in the app:** the dot and the Online/Offline line are hidden; the header shows the order code when the screen was opened from a booking.

## [vendor-app] Chat conversations are not linked to bookings

- **Screen:** Home Cleaning Messages (search "customer name or order ID"), Conversation opened from Booking Details
- **Endpoint:** `chat/allConversations`, `chat/sendMessage`
- **What we get:** conversations are keyed on `customer_id + vendor_id` (`firstOrCreate`), and `sendMessage` takes no `order_id`; the list rows carry `order_id` only if the column is filled elsewhere.
- **What we need:** if a thread should belong to a booking (the old mock showed "Booking #22789007: …"), `sendMessage` should accept `order_id` and `allConversations` should return it. Otherwise searching by order ID only matches when `order_id` happens to be set.
- **Note for the booking screen:** `HomeCleaningConversationView` now takes `customerId` (and `conversationId`). Booking Details should pass the booking's customer id so the vendor can start a chat; without it the screen falls back to matching the customer's name in existing conversations, and cannot start a new one.

