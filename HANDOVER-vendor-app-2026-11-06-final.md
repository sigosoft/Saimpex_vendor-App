# SAIMPEX V2 vendor app: handover (6 Nov 2026, end of day)

From Stephy. This one file covers everything left to do: **bug fixes, Figma design checks and phone testing**. It replaces the earlier 5 Nov and 6 Nov handover files (they're still in the repo root if you need more detail).

- Repo: https://github.com/sigosoft/Saimpex_vendor-App (Flutter, Android first, then iOS)
- Backend: https://github.com/praveensigo/saimpex-backend-new, branch `integration/v2`
- Launch: **1 December 2026**
- Figma (view and comment only, **never edit**): https://www.figma.com/design/ZCYkkdqmKm6Hn5Hcm12Mxg/Saimpex?node-id=3308-1865
- Figma screenshots per section: the `figma/` folder next to this file (not in git, so copy it with this file). `HANDOVER-vendor-app-2026-11-05-figma.md` describes each frame.

---

## 00. Latest, 7 Nov afternoon (read this first)

**Backend document for Praveen:** `backend-issues-vendor-app-2026-11-07.md` (also `.pdf` / `.html`): status of every open `[vendor-app]` issue, what to close, what is still needed, owner actions, decisions. Send it to Praveen.

**Live order test (dev, demo customer +222 95200020 "Aminata Sow", OTP 123456 from the backend dev test list; the user allowed using dev on 7 Nov):**
- Order **ORD-001546** placed for food.01 by API (`POST /api/customer/checkoutV2`, cash delivery, 2 × Garden Salad, 300 MRU). Notes: self pickup needs online payment; food.01 minimum order is 150 MRU; send `country_code` URL-encoded (`%2B222`).
- ✅ **VA-01** new-order popup with the app open within ~25 s · ✅ **VA-15** "View order" opens it · ✅ **VA-04** Accept at once + success popup · ✅ **#91** Prepare success popup · ✅ Mark as ready (server status 4) · ✅ **#89** Chat with Customer opens · ✅ **#90** no Print on Ready cards · ✅ VA-06 counters (Today 1, Total 37).
- The order is now **Ready** on dev (status 4). Leave it or cancel it from Admin.

**Bugs found in that run (not fixed yet):**
1. **Order timeline times in UTC, English, scrambled in Arabic** (order details "Order placed 07:39 AM" for 1:09 PM). Cause: the server sends status-log times pre-formatted ("07 Nov 2026 07:39 AM", UTC); `parseServerTime` only reads ISO, so the text was shown as is. **Work in progress, NOT committed:** worktree `.claude/worktrees/times`, branch `fix/server-formatted-times` (from `main`): `lib/utils/utils.dart` adds `_parseServerFormatted` (patterns `dd MMM yyyy hh:mm a`, `dd MMM yyyy, hh:mm a`, `MMM dd, yyyy hh:mm a`, read as UTC); new test in `test/server_time_test.dart` passes, **but the existing test "date-only, empty and non-date values" now fails**: one of its "not a date" examples is now parsed. Next step: read that test, keep server-formatted text that is meant to stay as is (or narrow the patterns), get all tests green, commit, PR, merge into the test branch, rebuild, recheck ORD-001546 details. Backend side asked in the doc (§2.8).
2. **Pending badge stays "01" right after Accept** until another tab is tapped (counts not reloaded after the action). Small; look at the reload after `acceptOrder` in `lib/view/home/vendor_home_screen.dart` / `HomeController`.
3. **Chat empty state** says "Currently no contacts found, try later" inside a conversation; should be "No messages yet".
4. **Ready card "Driver: Assigned" with no name** for ORD-001546 (older orders show the name). Check what the API sends (`delivery_boy_*`) before changing anything.

**Still to test with the same method (place by API, watch on the phone):** pharmacy OTC order (Reject sheet #98, detail buttons, popup), grocery.08 (Edit Items, change qty, VA-17), water.19 order flow + Express, a laundry / car wash / home cleaning booking (VA-30 step dialogs, Verify Weight, car wash Vehicles, pest control, assign cleaner), payment proof (#101, needs an Admin payout). Customer endpoints: `cart/pharmacy/add`, `cart/water/add`, `cart/grocery/add`, `checkoutV2`; service bookings: see `SAIMPEX_V2_CUSTOMER_API.md` §6.12–6.13 in the backend repo.

**Today's other PRs (all pushed, merged into `test/retest-2026-11-06`):** #103–#113 (see §0 below); #112 also removes the unused service settings screen; #113 launch keys (the repo stays public: reset the Play upload key).

---

## 0. Update, 7 Nov (read this first)

**Backend:** `integration/v2` `5d83569df` (on dev) fixes the backend side of VA-03, VA-10, VA-12, VA-22, VA-25, VA-29 and VA-31. Issues #169–#173 are covered by it but not closed on GitHub yet. New issue **#179** (restaurant item veg / new-arrival flags; notification type and order link).

**New PRs (all on `main`, merged into `test/retest-2026-11-06`, analyzer 0 errors):**

| PR | What | Phone |
|---|---|---|
| #103 | Earnings: "Commission −X MRU · Net Y MRU" per order (VA-12; restaurant, pharmacy, water / gas). Hidden on 0 MRU (cancelled) orders. | ✅ water.19 |
| #104 | Removes the unused No Internet / Server Down screens (B4 done) | n/a |
| #105 | Home cleaning / laundry / car wash: the home bell opens Notifications | ✅ homecleaning.30 |
| #106 | Pharmacy and water inventory: scan button → barcode into the search (B1 done; the search already matches `serial_number`) | Camera opens ✅; real barcode not tried |

**Phone results, 7 Nov (build `e107e22` + #103 fix, Arabic, dev):**
- ✅ #100 water Business Settings: Express on/off, add range, edit range: all saved (reopened to check). Test data left on water.19: an Express range 0–5 km, 60 MRU (the water screen has no delete); Express is back off.
- ✅ #103 water Earnings (fixed the "−0" line on cancelled orders, `68f0d93`).
- ✅ #105 home cleaning bell.
- ✅ Water home Revenue 3315 (not 0, #67); water inventory loads (5 products).
- Not testable with the current data: #101 (no payouts on water.19), #102 (no low-stock products), VA-30 step dialogs and pest control tiles (no open bookings on homecleaning.30), water order cards (no active orders). These need orders placed from the customer app, or Admin payouts.

**Pharmacy phone check, 7 Nov (pharmacy.15, Arabic) — 2 bugs found and fixed:**

| PR | What | Phone |
|---|---|---|
| #107 | Pharmacy home: tapping the Prescription tab's To Prepare / Preparing / Ready chips turned every dashboard figure into 0 (the app sent `order_status` 5–7, the server answered 422, the app cleared its figures). Chips now send 2 / 3 / 4 / 9; a failed reload keeps the last figures. | ✅ |
| #108 | Pharmacy Business settings and Earnings were all English in Arabic; the Earnings "Order Amount" tab was invisible in Arabic (highlight not mirrored). Now EN/FR/AR (water keys) and directional. | ✅ |

Also ✅ on pharmacy.15: #100 save (Express on/off), #103 commission / net, #106 scanner opens. Not testable: #98 Reject reason (no new prescription or OTC order), payouts.

**Restaurant phone check, 7 Nov (food.01, Arabic):**
- ✅ #87 Business settings (Arabic, Express save), #103 commission / net, #78 busy card + logo (VA-09, VA-13), #79 item names + Update Stock (VA-10, VA-11), #92 Edit Profile opens.
- Bug found and fixed: **#109** (stacked on #88): Item Details showed Category "-" (the API sends only `category_ids`); names now come from `getRestaurantCategories`. ✅ rechecked.
- Not testable: order flow (VA-01/04/05/14/15, #89 chat, #90 Print) — no pending or active orders; #101 — no payouts; item variants / sides / extras — Garden Salad has none.
- **#110** (fixed, ✅ phone): Settings back arrow and "Language" label sat on the left in Arabic and the arrow floated over the menu when scrolled; Edit Profile "+222" was clipped at the right edge. May conflict with #71 / #92 in `settings.dart` (other lines; keep both).

**Car wash Figma + phone check, 7 Nov (carwash.27, Arabic) — design check done:**
- Matches Figma: home (membership, open card, 4 counters, Bookings / Completed / Revenue, search, chips), booking cards, booking details (customer, request ID, slot chips, location, notes, payment summary), My Services, Account menu.
- **#111** (stacked on #97, ✅): a booking without a date had an empty card footer and an empty "Booking slot" heading; wash-station bookings showed "At Wash Station" in English as an address with a map. Fixed.
- **#112** (stacked on #100, ✅): service Business settings (home cleaning, laundry, car wash) had two switches and "accepting" stayed off/disabled (`serviceDashboard` has no `accepting_bookings`); it now opens the Figma screen (Store availability + Express Delivery pricing) on the `businessSettings` endpoints.
- Not an app bug: no VEHICLES block on the 3 bookings checked — their details send no vehicle lines (older test bookings). Check with a new booking.

**Laundry Figma + phone check, 7 Nov (laundry.24, Arabic) — design check done, nothing new to fix:**
- Matches Figma: home counters (Today's / Waiting for Pickup / In Progress / Completed), Delivered cards (turnaround tag, estimate vs actual weight, slot), details (service card, pickup slot, pickup & delivery, Payment Status), My Services (starting price from garments, VA-31 ✅). Business settings now uses the Figma screen via #112.
- Gaps (backend / decision, not app): Delivery turnaround block hidden (`delivery_turnaround` is only a string); garment / service names without Arabic (#170); LNKKNMD1 Delivered with 240 MRU due (decision V8).

**All Figma design checks are now done** (restaurant, water, pharmacy, home cleaning, car wash, laundry). What is left needs data: an order placed from the customer app (restaurant / grocery order flow, pharmacy Reject sheet #98, step dialogs VA-30, pest control tiles, car wash vehicles), and an Admin payout (payment proof #101).

**Launch keys checklist (vendor app), 7 Nov:** PR **#113** untracks `playstore_key` (it was committed in `218d66e` and is in the public repo history), signs release builds from an untracked `android/key.properties`, and picks the live API with `--dart-define=SAIMPEX_LIVE=true`. **Decision 7 Nov: the repo stays public.** So the keystore remains readable in git history: if it is the live upload key, **reset the upload key in Play Console** before launch. Still for the account owners: restrict the Maps key in Google Cloud; iOS `GoogleService-Info.plist`, APNs key, release SHA-1/256 in Firebase; iOS signing on a Mac. Merging #113 deletes the local `playstore_key`; restore it with `git show 218d66e:playstore_key > playstore_key`.

**Changes to the lists below:** B1 and B4 are done; W6 (commission / net) is done. B2 and B3 wait for backend #179. Merge conflicts for the new PRs: `lib/l10n/intl_*.arb` (keep both keys, regenerate), `lib/configs/Dioclient.dart` (#104 vs #76: keep the translated `S.current.somethingWentWrong`, drop the commented `ServerDown` line), `home_cleaning_home.dart` imports (#105 vs #95: keep both), `docs/HANDOVER.md` rows (keep both).

---

## 1. Rules (read first)

1. **Read `CLAUDE.md`** in the repo. Its links: the complete scope, `docs/HANDOVER.md`, the API changelog (check the `[vendor]` entries every day).
2. **Figma is the design.** Match the layout, labels, order, badges and buttons. Don't change business logic for a design task.
3. **No sample data.** Every value comes from the API. Never copy Figma sample text ("Ahmed", "Restaurant 1", "Feb 07 2026", prices). If the API has no field for a block, hide the block and file a backend issue.
4. **Never build against a guessed API.** If an endpoint is missing or differs from the docs, open an issue in `praveensigo/saimpex-backend-new` titled `[vendor-app] <short description>` (screen, endpoint, request, response, what's needed) and move on.
5. **EN / FR / AR for every string** (`lib/l10n/intl_*.arb`, Arabic right-to-left). After editing the ARB files run `flutter pub run intl_utils:generate`.
6. **`flutter analyze --no-pub` must show 0 errors.**
7. **One task = one branch = one PR into `main`.** Praveen approves every merge. Tick the item in `docs/HANDOVER.md` in the same PR.
8. **Test on the dev server** (`integration/v2`), never production. The tester logs in on the phone; **never put passwords in chat, commits or logs.**

---

## 2. Where things are

| What | Where |
|---|---|
| `main` | `4c604a6` (P1 merges #44, #45, #64, #65) |
| **Test branch** | `test/retest-2026-11-06` (**pushed**, head after 7 Nov merges; see `git log`) = `main` + every open PR below, merged together, analyzer 0 errors. Build from this branch for phone testing. |
| Phone build | Release APK of `2d74151`, installed on the Samsung M11 (6 Nov evening). Copy: `build/app/outputs/flutter-apk/vendor-2d74151.apk` on Stephy's PC. |
| Open PRs | **68** (#39–#112). List and merge order in §3. |
| Backend issues | #168–#175 filed 6 Nov (§7). |
| Message to Praveen | Sent 6 Nov. Follow-up with all numbers: `message-to-praveen-2026-11-06-followup.md` (send it if not sent yet). |

**Build and install:**

```bash
git fetch origin && git checkout test/retest-2026-11-06
flutter pub get
flutter analyze --no-pub
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

You need `android/app/google-services.json` (not in git; ask Praveen). The GitHub CLI (`gh`) is installed on Stephy's PC and signed in as `sigosoft`.

---

## 3. Open PRs and merge order

Stacked PRs use their parent branch as base, so each PR shows only its own change. When the parent is merged, GitHub moves the base to `main`.

**Merge conflicts you will see:**
- `lib/l10n/intl_*.arb` and `lib/generated/*`: keep both sets of keys (valid JSON), then regenerate.
- #53 vs #93 in `lib/water/controller/home_controller.dart` and `working_hours_view.dart`: keep both, block by block.
- #55 / #57 vs #96 / #97 in `service_kind_blocks.dart`: keep #57's `carWashPlaceLabel`; take the Verify Weight header plus #55's `estimateKg` check; no address on car wash and laundry cards.
- `view_item_details.dart`: #71 vs #88 translate the same labels with different keys; keep #88.
- `docs/HANDOVER.md`: #100 and #101 edit neighbouring rows; keep both.

| Order | PRs | What |
|---|---|---|
| 1 | #39, #53, #54, #62, #66, #67, #68, #69 | Water / gas fixes (5 Nov) |
| 2 | #93 (on #62) | Water vs Figma |
| 3 | #42, then #94 (on #42) | Pharmacy real data, then pharmacy vs Figma |
| 4 | #49, #50, #51, #52 | Pharmacy fixes (5 Nov) |
| 5 | #80, #81, #82, then #98 (on #80) | Pharmacy test-report fixes; home-card Reject reason |
| 6 | #70, #71, #41, #46, #47, #48, #58 | Restaurant / grocery / local store (5 Nov) |
| 7 | #72 → #73 → #74 → #75 | Restaurant orders, stacked on #70 (#75 also needs #80) |
| 8 | #76 → #77; #78; #79 | Login messages, server messages, store card, items / stock (on #70) |
| 9 | #87–#92 (on #74) | Restaurant Figma batch 2 |
| 10 | #55, #56, #57 | Laundry / car wash fixes (5 Nov) |
| 11 | #95 → #96 → #97 | Home cleaning → car wash → laundry vs Figma |
| 12 | #83, #84, #85, #86 (on #97) | Laundry test-report fixes |
| 13 | #100, #101, #102 | Business Settings save, payment proof, low-stock View all |
| 14 | #59, #60, #63 | Login type list (decision pending), clean-ups |
| last | #61, #99 | Docs (`docs/HANDOVER.md`) |

What each test-report PR fixes (VA ids): `docs/HANDOVER.md` §4.6 on PR #99.

---

## 4. Bug fixes still to do

### 4.1 App work you can do now

| # | Task | Where | Notes |
|---|---|---|---|
| B1 | Barcode icon on inventory does nothing | `lib/pharmacy/view/pharmacy_inventory_screen.dart` (`_HeaderButton` with `qr_code_scanner`), `lib/water/view/inventory/inventory_view.dart` (`_HeaderIconButton`) | The inventory search doesn't match barcodes (backend gap). Either file `[vendor-app] inventory search by barcode` and wire it once it exists (the scanner page is in `pharmacy_add_product_screen.dart`, `_BarcodeScanPage`), or ask Praveen whether to hide the icon. |
| B2 | Restaurant Notifications: action buttons | `lib/view/notifications/` | Optional Figma item from batch 2; not started. |
| B3 | Restaurant Items tab: New Arrival and veg tags | restaurant Items tab | Optional Figma item; check that the API sends the flags first. |
| B4 | Unused screens | `lib/view/settings/no_internet.dart`, `server_down.dart` | Buttons do nothing, but nothing opens these screens. Delete them in a clean-up PR (#60 style). |

### 4.2 Waiting on the backend (do these when the issue is fixed)

| # | When | Do |
|---|---|---|
| W1 | #168 (booking push) is done | In `lib/view/notifications/notification.dart`, recognise the new push type and call `Get.find<HomeCleaningController>().refreshQuietly()`; a tap opens the booking. |
| W2 | #175 (Express flag / Popular tag) | Show the Express tag on restaurant order cards and details (Figma), and the Popular tag on Item Details. |
| W3 | #171 (pharmacy list fields) | Payment pill, self-pickup and rider name on pharmacy Home cards (now hidden when missing). |
| W4 | #169 (laundry slot) | Show the stored `slot_label` on laundry cards and details. |
| W5 | #170 (garment names) | Use the FR/AR garment names in the laundry booking summary. |
| W6 | #173 (commission / net) | Commission and net per order in Earnings (VA-12). |
| W7 | Older gaps (blocks hidden) | Water partner rating / photo, today's deliveries count, notification links; pharmacy sales and stock history; car wash vehicle image; laundry `delivery_turnaround` as data; home cleaning service-type field. |

### 4.3 Decisions waiting on Praveen

1. V8: laundry booking marked Delivered while money is still owed: block it or ask to confirm?
2. Login type list: Figma has none; keep or remove (#59)?
3. Water: call button or chat button on the order?
4. Restaurant: keep the Busy card (built in the water style, no Figma frame) and the Product Customizations tab?

---

## 5. Figma design checks

Compare each screen on the phone (Arabic and English) with the Figma frame and the images in `figma/<section>/`. Check the layout, labels, order, badges, buttons per status, and that no sample data appears. Log any difference as a bug (screen, Figma frame, screenshot).

| Section | Images | PR | Status | Still to check |
|---|---|---|---|---|
| Restaurant / grocery / local store | `figma/restaurant/` (17) | #70, #87–#92 | Batch 1 ✅ (food.01) | Batch 2 on the phone: Business Settings, Item Details (variants, sides, extras), Chat with Customer, Edit Profile, no Print on Ready / Delivered cards, success popups |
| Water (+ gas) | `figma/water/` (9) | #93 | ✅ water.19 | Express tag (no express order on the demo account yet) |
| Pharmacy | `figma/pharmacy/` (12) | #94 | ✅ pharmacy.15 | OTC Express tag, prescription timelines (no matching orders yet) |
| Home cleaning | `figma/home-cleaning/` (7) | #95 | ✅ homecleaning.30 | Pest control Areas and Issues tiles (needs a pest control booking) |
| Car wash | `figma/carwash/` (6) | #96 | ✅ 7 Nov (see §0) | Everything: Upcoming card, one line per vehicle, slot chips, vehicle cards with add-ons, location card with map, Tax row, Add Service (carwash.27) |
| Laundry | `figma/laundry/` (6) | #97 | ✅ 7 Nov (see §0) | Everything: estimate vs actual, slot and turnaround tag, Payment Status, Tax, Verify Weight header, "MRU / kg" and Starting rate (laundry.24) |

Screens with no Figma frame (built in the section's style; don't flag them): restaurant Busy card, Support messages, Order rules, category requests, balance adjustments, printer picker, Quick Edit.

---

## 6. Phone testing checklist

Install the `test/retest-2026-11-06` build (§2). The tester logs in to each account; test in **Arabic** first, then English. Mark each line ✅ or ❌ with a screenshot, and put ✅ results in the PR as "Phone ✅".

### Restaurant: food.01
- [ ] With the app open, place an order from the customer app; within 30 s the new-order popup rings (VA-01). It never rings twice for one order.
- [ ] Popup "View order" opens that order (VA-15).
- [ ] Accept: accepted at once, success popup, no second dialog (VA-04).
- [ ] Accept & Print on the Pending card.
- [ ] Prepare, then Mark as ready: the server shows status 4; lists reload after each action (VA-05).
- [ ] Tab badges match the server after every action (VA-06 / VA-16); no keyboard pops up after actions; no jump to the top (VA-07).
- [ ] Reject with a reason: the customer sees the reason.
- [ ] Store busy card: the label matches the switch (VA-09); store logo loads (VA-13).
- [ ] Item names show in FR / AR, with a fallback (VA-10). Update Stock shows the current stock; the error shows under the field (VA-11).
- [ ] Login with an empty field, then with a wrong password: message in Arabic (VA-02 / VA-03).
- [ ] Batch 2: Settings › Business settings: every switch and each Express distance range saves (leave and reopen). Item Details: variants, sides, extras. Chat with Customer opens the chat. Edit Profile Details opens Edit Profile. No Print on Ready / Delivered cards.
- [ ] Earnings › payout: "View payment proof" opens the image, shown only when Admin attached one (#101).

### Grocery: grocery.08
- [ ] Edit Items is above the item list and opens the edit screen; the order stays Pending (VA-14).
- [ ] Popup "View order" opens the order.
- [ ] Accepted list: header and buttons aligned in Arabic (VA-17); status chip colour (VA-08).
- [ ] Change quantity on a line with quantity 1: explains why (VA-18).

### Pharmacy: pharmacy.15
- [ ] ORD-001536 details: items, total 100, address, no driver, prescription image (VA-19).
- [ ] Detail buttons: Accept, Start Preparing, Ready for Dispatch, OTC Accept / Prepare / Mark Ready, Reject with a reason.
- [ ] **Home card Reject** (prescription and OTC): the reason sheet opens and the reason is sent; closing the sheet does nothing (#98).
- [ ] Chip and switch counters match the server (VA-23). After Send quote, the list opens on Awaiting Payment (VA-24).
- [ ] Popup "View order" opens the pharmacy order (VA-21).
- [ ] Medicine search in the quote form stays above the keyboard (VA-27).
- [ ] No "Online payment" pill when the server sends no payment type (VA-22).
- [ ] Account › Business settings: each switch and range saves (leave and reopen) (#100).

### Water / gas: water.19 (and a gas account)
- [ ] Account › Business settings: Store open, Accepting orders, Busy, Express and each distance range save; reopen to confirm (#100).
- [ ] Inventory: the Low stock card's "View all" selects the Low stock chip (#102).
- [ ] Earnings › payout: "View payment proof" loads the image (#101).
- [ ] Revenue tile is not 0 when there are orders (#67); ready card shows items, amount and driver (#66).

### Laundry: laundry.25 and laundry.24
- [ ] Booking card date: a date-only booking shows its date, not 05:30 / 12:00 AM; Arabic dates in order (VA-29).
- [ ] A confirmation dialog before every step, with a warning when the booked day is later (VA-30).
- [ ] My Services: starting price = the lowest garment price; "MRU / metre" (VA-31). Texts in Arabic (VA-32).
- [ ] A new booking appears within 30 s while the app is open (VA-28).
- [ ] Figma check (§5).

### Car wash: carwash.27
- [ ] Step confirmation dialogs (VA-30).
- [ ] Figma check (§5).

### Home cleaning: homecleaning.30
- [ ] Step confirmation dialogs (VA-30).
- [ ] Pest control booking: Areas and Issues tiles.

---

## 7. Backend issues (praveensigo/saimpex-backend-new)

| Issue | Subject | App work after it's fixed |
|---|---|---|
| #168 (P1) | No vendor push when a service booking is created (VA-28) | W1 |
| #169 | Laundry slot label not stored; "10–12 PM" default | W4 |
| #170 | Laundry "piece" unit gives 0 MRU; garments have no FR/AR names | W5 |
| #171 | Pharmacy lists without payment type / self pickup / rider; wallet status log | W3 |
| #172 | Pharmacy action messages English only (VA-25) | none (the app already shows `message_<lang>`) |
| #173 | Earnings per-order commission and net (VA-12) | W6 |
| #174 (P1) | Restaurant new-order push skipped when Pusher fails; prepare / ready don't check `vendor_id` | none; retest VA-01 |
| #175 | Restaurant order Express flag and item Popular tag | W2 |
| #176 | Duplicate of #168: **close it** | none |

Check the API changelog for `[vendor]` entries every day; when one of these is fixed, do the app work and retest.

---

## 8. What changed on 6 Nov (summary)

- Test report (34 issues, 4 P1): all app-side issues fixed on PRs #72–#92 and #80–#86; backend parts filed (§7).
- Figma design PRs for water, pharmacy, home cleaning, car wash and laundry: #93–#97.
- #98: pharmacy home-card Reject now asks for a reason and sends it.
- #100: water, gas and pharmacy **Business Settings never saved** (the save sent a GET with no body); now posts to `updateStoreAvailability`, `updateExpressDelivery`, `addDeliveryDistance` / `updateDeliveryDistance`.
- #101: payout "View payment proof" did nothing (restaurant) or couldn't load (water); now opens `payment_proof_url`.
- #102: water Low stock "View all" did nothing.
- #99: `docs/HANDOVER.md` §4.6 records all of the above.

## 9. Files in the repo root (not in git)

| File | What |
|---|---|
| `HANDOVER-vendor-app-2026-11-06-final.md` | This file |
| `figma/` | Figma screenshots per section (§5) |
| `HANDOVER-vendor-app-2026-11-05*.md`, `HANDOVER-vendor-app-2026-11-06*.md` | Older handovers (more detail) |
| `pr-links-2026-11-05.md`, `pr-links-2026-11-06.md` | PR lists |
| `issue-drafts-vendorapp-backend-2026-11-06.md` | Text of issues #168–#175 |
| `message-to-praveen-2026-11-06.md`, `…-followup.md` | Messages to Praveen |
| `test-day-screenshots/` | Screenshots from earlier test days |






