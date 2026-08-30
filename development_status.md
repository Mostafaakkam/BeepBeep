\# Development Status



\*\*Last Updated:\*\* 2026-08-29 (Store Owner Dashboard implemented — Flutter UI now exists for store owners)



\## Project Overview

\*\*Beep Beep\*\* is a mobile marketplace app for local commerce in Syria. The core MVP features for a customer-facing marketplace are complete.



\### Completed Features

\- ✅ \*\*Infrastructure:\*\* Backend (Node.js/Express), Database (MySQL), Flutter project.

\- ✅ \*\*Authentication:\*\* Register, Login, JWT, Splash Screen, Logout.

\- ✅ \*\*Design System:\*\* Complete reusable components (Colors, Typography, Buttons, Cards).

\- ✅ \*\*Home Screen:\*\* Dynamic greeting, integrated categories, featured stores.

\- ✅ \*\*Stores:\*\* Listing and browsing of active stores.

\- ✅ \*\*Products:\*\* Listing, details (images, variants), filtering \& sorting (price, stock, category, store), "Add to Cart".

\- ✅ \*\*Shopping Cart:\*\* Add items, update quantities, remove items, clear cart.

\- ✅ \*\*Orders:\*\* Checkout, order placement (Cash on Delivery), order history, order details, and cancellation.

\- ✅ \*\*Search:\*\* Unified product/store search with debouncing.

\- ✅ \*\*Favorites:\*\* Bookmark/un-bookmark products.

\- ✅ \*\*Addresses:\*\* Manage delivery addresses, set default.

\- ✅ \*\*Categories:\*\* Browse and filter products by category.

\- ✅ \*\*Seed / Demo Data:\*\* Realistic dummy data (5 users, 5 stores, 7 categories, 15 products with images and variants, addresses, favorites, cart items) available for local testing and demos via `backend/src/seeders/seed.js`. Run `node src/seeders/seed.js` from the backend directory. See `backend/README.md` for full instructions. All seeded users share the password "password123".

\- ✅ \*\*Localization (English/Arabic):\*\* App-wide localization using Flutter's standard `flutter\_localizations` + ARB/gen\_l10n toolchain. English is the default language; Arabic is fully supported with RTL layout. Language selector added under Profile, persisted via `SharedPreferences` across restarts. All existing screens (Auth, Splash, Home, Stores, Categories, Products, Search, Favorites, Cart, Checkout, Orders, Addresses, Profile) translated; no backend/API/database changes. \*\*Note:\*\* implemented and statically verified (key parity between `app\_en.arb`/`app\_ar.arb`, no leftover hardcoded strings, consistent import paths); `flutter analyze` / `flutter pub get` / on-device build could not be run from the cloud sandbox (Flutter/Dart SDK download blocked by network policy, no local device shell available this session) — run these locally to confirm before considering it fully verified. While implementing Reviews \& Ratings, `product\_details\_page.dart` was found to still contain hardcoded English strings and an auth-state bug despite being listed as translated — both were fixed as part of this update (see below).

\- ✅ \*\*Product Reviews \& Ratings:\*\* Authenticated users who purchased a product through a delivered order can leave a 1–5 star rating with an optional text comment; users can edit or delete their own review. One review per user per product (enforced in the service layer and by a database UNIQUE constraint). Product average rating and review count are computed on read from the new `reviews` table and exposed on `GET /api/products/:id` and on the dedicated review endpoints. Product Details now shows a rating summary, the review list, and a "Write a Review" flow (or the user's own review with edit/delete, or a purchase-required/login message, depending on state). New table: `reviews` (migration at `database/migrations/001\_create\_reviews\_table.sql`). Fully localized (English/Arabic) and RTL-safe. Backend verified end-to-end in a local sandbox MySQL instance (see Tests below); \*\*Flutter side statically verified only\*\* — `flutter analyze`/build could not run in this cloud sandbox (same network restriction as Localization, see below).

\- ✅ \*\*Role System, Store Ownership \& Single-Store Order Rule (backend foundation):\*\* Users now have one of three roles — `customer`, `store\_owner`, `admin` — verified server-side on every authorization check (re-fetched from the database, never trusted from the JWT claim alone, closing a stale-token privilege window). New reusable middleware `requireRole(...)`, `requireStoreOwnership(paramName)`, `requireProductOwnership(paramName)`. Stores now optionally belong to one `store\_owner` (`stores.owner\_id`, nullable — a store can have no owner yet); admins bypass ownership checks. \*\*Single-Store Cart Rule:\*\* a cart is tied to one store from its first item (`carts.store\_id`); adding a product from a different store is rejected with a machine-readable `STORE\_MISMATCH` error (HTTP 409) instead of silently mixing stores; a new atomic "clear \& switch store" endpoint (`POST /api/cart/switch-store`) lets the customer confirm a store change in one transaction. \*\*Single-Store Order Rule:\*\* orders now carry `orders.store\_id`, derived and re-validated server-side from the cart's actual items at checkout (never trusted from the client) — a cart that somehow mixes stores is rejected at checkout with `MULTI\_STORE\_CART` (HTTP 400) as a second, independent defensive check. New migration: `database/migrations/002\_add\_roles\_ownership\_single\_store.sql` (additive, nullable-first — see Technical Debt below). Seed data updated so `ahmad` and `sara` are demo store owners (ahmad owns two stores, demonstrating one owner/multiple stores; the electronics and gifts stores are deliberately left unowned, demonstrating the "no owner yet" case). \*\*Two pre-existing, previously-undiscovered bugs were found and fixed while implementing and testing this feature\*\* (both are checkout/cart-affecting, not something this feature introduced): `cartRepository.createCart()` was missing `store\_id` in its post-insert query, causing a crash on the very first add-to-cart for a brand-new cart; the `order\_items` INSERT in `orderRepository.createOrder()` had one fewer `?` placeholder than values, so `POST /api/orders` (checkout) failed with a SQL error on every call — meaning checkout could not have worked before this fix. Also fixed, as explicitly requested: the documented `orderRepository.findById()` bug (`products.address` does not exist) now resolves the store correctly via the order's own `store\_id`. Also fixed, found during testing: `cartRepository.findByUserId()`'s cart-item query returned duplicate rows for any product with more than one image (an unrelated pre-existing `LEFT JOIN` fan-out bug). On the Flutter side (deliberately minimal at the time — no Store Owner Dashboard UI existed yet, since built by the following feature below): the cart flow now detects `STORE\_MISMATCH` and shows a confirmation dialog ("Clear the cart and switch to this store?"); confirming calls the new switch-store endpoint, cancelling leaves the cart untouched. Fully localized (English/Arabic). Backend verified end-to-end (47/47 checks) in a local sandbox MariaDB instance, including role-authorization, store-ownership (including cross-owner and unowned-store rejection), admin bypass, anti-stale-JWT role checks, atomic switch-store, checkout single- and multi-store validation, and no client-supplied `owner\_id`/`store\_id` can bypass authorization; \*\*Flutter side statically verified only\*\* — `flutter analyze`/`flutter pub get` could not run in this cloud sandbox (same network restriction as Localization, see below).

\- ✅ \*\*Store Owner Dashboard:\*\* Role-gated Flutter dashboard (reached via a new button on Profile, shown only for `store\_owner` users — role re-verified fresh from the backend, never trusted from a client-cached value) integrated into the existing app: a 4-tab shell (Dashboard/Products/Orders/Stores) built on the prior feature's role/ownership foundation, reusing its authorization middleware completely unmodified. \*\*Dashboard Home:\*\* welcome header, store switcher (for owners of more than one store), order-count-by-status summary cards, quick-action buttons. \*\*Store Management:\*\* list and switch between owned stores only — v1 deliberately has no store-creation flow. \*\*Product Management:\*\* add/edit products (name, description, category, variants); "delete" is a soft `is\_active` deactivation, never a hard delete, so order history and FKs stay intact — new additive column `products.is\_active` (`database/migrations/003\_add\_product\_is\_active.sql`, `DEFAULT 1`), filtered out of every public product-visibility surface (`GET /api/products`, `GET /api/products/:id`, category browsing, search). Existing variants can be edited but never removed through this UI (an owner retires one by zeroing its stock); new variants can be appended; product images are set once at creation only (no image-editing endpoint, so no image editor is shown when editing — showing one that silently did nothing would be misleading). \*\*Order Management:\*\* list orders for the selected store, view detail, and advance status one step at a time along `pending → confirmed → preparing → shipped → delivered` (enforced server-side by a single-source-of-truth transition map — a store owner can never skip a step, go backward, or set `cancelled`, which remains customer-only). Orders can now reach `delivered` through the app itself for the first time — previously only possible via direct SQL (see the Reviews feature's purchase-eligibility note below, now resolved). \*\*Three pre-existing bugs found and fixed while implementing/testing this feature\*\* (all directly block correct soft-delete/visibility behavior, not something this feature intentionally set out to fix): `productService.getProductById()` discarded the `PRODUCT\_NOT\_FOUND` error code in its catch block, so `GET /api/products/:id` returned 500 instead of 404 for any missing product — confirmed pre-existing via a nonexistent id, not something the `is\_active` filter introduced; `categoryRepository.getProductsByCategory()` and `searchRepository.search()` were both missing the `is\_active = 1` filter that already existed on the main product list/detail queries, so a deactivated product still showed up when browsing by category or searching (both fixed, verified via curl with a deactivated seeded product). Fully localized (English/Arabic, 44 new keys) — also found and fixed while patching these in: the three generated `app\_localizations\*.dart` files (hand-maintained, since `flutter gen-l10n` cannot run in this sandbox) were missing all 20 keys the Reviews feature had added to the `.arb` source files, meaning the app as it stood would not have compiled; fixed alongside this feature's own keys. Backend verified end-to-end in a local sandbox MariaDB instance: \*\*47/47\*\* pre-existing regression checks plus a new \*\*54/54\*\*-check suite covering cross-owner/non-owner rejection, admin bypass, every valid and invalid status transition, deactivation visibility across all surfaces, and no client-supplied id can substitute for server-resolved ownership; \*\*Flutter side statically verified only\*\* (every model/repository/widget API referenced by the new UI was cross-checked against its actual current definition, not assumed) — `flutter analyze`/`flutter pub get`/on-device build could not run in this cloud sandbox (same network restriction as Localization, see below).



\### Pending / Not Implemented

\- ❌ \*\*Admin Dashboard:\*\* Full platform administration panel.

\- ❌ \*\*Store Creation Flow:\*\* A store owner cannot create a new store through the app — Store Owner Dashboard v1 is list/switch/manage only.

\- ❌ \*\*Product Image Upload:\*\* Product images remain URL-based only; no file upload UI.

\- ❌ \*\*Payment Gateways:\*\* No integration for online payments (e.g., Stripe, PayPal).

\- ❌ \*\*User Profile Management:\*\* Limited to viewing name, addresses, and orders.

\- ❌ \*\*Advanced Features:\*\* Coupons, discounts, notifications, delivery tracking.



\## Roadmap



\### Phase 1: Core Marketplace (Complete)

\- \[x] Auth, Home, Stores, Products, Cart, Orders, Search, Favorites, Addresses, Categories, Product Filters.

\- \[x] Localization (English default / Arabic, RTL/LTR) — infrastructure step ahead of Phase 2.



\### Phase 2: Community \& Engagement (In Progress)

\- \[x] \*\*Product Reviews \& Ratings:\*\* Users can leave feedback and see ratings (purchase-verified, one review per user per product).

\- \[ ] \*\*Product Recommendations:\*\* Simple "you might also like" based on browsing history.



\### Phase 3: Business \& Operations (In Progress)

\- \[x] \*\*Store Owner Dashboard:\*\* Product management, order fulfillment.

\- \[ ] \*\*Admin Dashboard:\*\* User management, order oversight, content moderation.

\- \[ ] \*\*Payments:\*\* Integrate a secure payment gateway.

\- \[ ] \*\*User Profiles:\*\* Full profile editing, order history enhancements.



\### Phase 4: Scaling \& Growth (Future)

\- \[ ] \*\*Multi-City Support:\*\* Expand beyond Aleppo.

\- \[ ] \*\*Multi-Category Support:\*\* Add shoes, cosmetics, electronics, etc. (Architecture is ready).

\- \[ ] \*\*Delivery Driver App/Integration:\*\* For order logistics.

\- \[ ] \*\*Marketing Tools:\*\* Coupons, discounts, email campaigns.



\## Technical Debt \& Notes

\- \*\*Database Migrations:\*\* No system for version-controlled schema changes (use manual SQL updates). Three manual migration files now live in `database/migrations/`: `001\_create\_reviews\_table.sql` (creates the `reviews` table), `002\_add\_roles\_ownership\_single\_store.sql` (adds `stores.owner\_id`, `carts.store\_id`, `orders.store\_id`, all nullable, plus indexes and FKs; includes SQL-comment guidance for later tightening `orders.store\_id` to `NOT NULL` once existing data is confirmed safe — do \*\*not\*\* apply that tightening blindly), and `003\_add\_product\_is\_active.sql` (adds `products.is\_active`, `DEFAULT 1`, plus an index — Store Owner Dashboard soft-delete). Run migrations by hand, in order, against your local `beep\_beep` database; all three are purely additive and do not touch existing tables' existing columns or data.

\- \*\*Order Status:\*\* Resolved by the Store Owner Dashboard — a store owner can now progress an order `pending → confirmed → preparing → shipped → delivered` through the app itself (one step at a time, enforced server-side; see the Store Owner Dashboard entry above). Only `pending → cancelled` remains customer-only, unchanged. Before this feature, no code path could reach `delivered` at all outside a direct SQL update.

\- \*\*Testing:\*\* No automated test framework configured (no Jest/Mocha/etc.), but backend features since Product Reviews \& Ratings have each been verified end-to-end against a real local sandbox MySQL/MariaDB instance with real HTTP requests (`curl`) — see each feature's own entry above and `docs/AI_PROJECT_BRIEF.md` for the check counts and scenarios covered. No automated Flutter tests exist beyond the default `test/widget_test.dart` scaffold.

\- \*\*Logging:\*\* Only `console.log` is used; a structured logging system is recommended.

\- \*\*Rate Limiting:\*\* Not implemented on API endpoints.

\- \*\*Documentation:\*\* `docs/project\_context.md` and `docs/AI\_PROJECT\_BRIEF.md` are the source of truth for current implementation state.

\- \*\*Seed Data Script:\*\* `backend/src/seeders/seed.js` populates the database with safe, fully-fake demo data and is re-runnable (it truncates and re-inserts the relevant tables). It does not touch `orders`/`order\_items`. See `backend/README.md`.



