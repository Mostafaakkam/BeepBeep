# Development Status

**Last Updated:** 2026-09-14 (Customer + Store Owner flow verification and stabilization — full live API/database testing of both flows, complete order lifecycle test, authorization matrix, several DECIMAL/string and UI bugs found and fixed. Work committed and pushed: `34b5d7b "Complete customer and store owner flows"`.)

## Project Overview

**Beep Beep** is a mobile marketplace app for local commerce in Syria. The core MVP customer-facing marketplace and the Store Owner Dashboard are both complete and have been verified against the real backend and a live MySQL database (not just a disposable sandbox).

## Completed Features — Customer Flow

- ✅ **Infrastructure:** Backend (Node.js/Express), Database (MySQL), Flutter project.
- ✅ **Authentication:** Register, Login, JWT (7-day expiry) + bcrypt, Splash Screen, Logout, DB-fresh role checks (`GET /api/auth/me` re-fetches role, never trusts a stale JWT claim).
- ✅ **Design System:** Reusable components (`AppColors`, `AppSpacing`, `AppBorderRadius`, `AppButton`, `AppTextField`, `AppCard`, typography).
- ✅ **Home / Stores / Categories:** Home screen (greeting, categories, featured stores), store browsing, category browsing and filtering. Categories are a **flat list only** — the `categories` table has no `parent_id`/hierarchy column and none of the backend or Flutter code reads or exposes one, despite category hierarchy being mentioned as a long-term design intent elsewhere in these docs.
- ✅ **Products & Product Details:** Listing, filtering & sorting (price, stock, category, store), images, variants, "Add to Cart".
- ✅ **Product Reviews & Ratings:** Purchase-verified (must have a `delivered` order containing the product), one review per user per product, edit/delete own review, average rating + review count computed on read.
- ✅ **Search:** Unified product/store search, debounced, public endpoint.
- ✅ **Favorites:** Bookmark/un-bookmark products, authenticated.
- ✅ **Addresses:** Manage delivery addresses, set default. **Live schema is `(id, user_id, city, area, details, is_default)`** — see "Important Fixes" below; the address selector UI works off `city`/`details` only.
- ✅ **Cart:** Add/update/remove/clear items.
  - **Single-Store Cart Rule:** a cart is tied to one store from its first item (`carts.store_id`); adding a different store's product is rejected with `STORE_MISMATCH` (409); `POST /api/cart/switch-store` atomically clears and switches.
  - **Stock enforcement (server-side, both add and quantity-increase paths):** `POST /api/cart/items` checks `existing_cart_quantity + requested_quantity <= current_stock`; `PATCH /api/cart/items/:id` (the quantity "+"/"-" control) independently checks the new quantity against current stock — previously this second path had **no** stock check at all. Both reject with `400 INSUFFICIENT_STOCK`. The Flutter cart page disables the "+" control once the cart already holds the available stock and shows a small localized explanatory message next to it.
- ✅ **Checkout & Orders:** Delivery info form (with saved-address selection), Cash on Delivery, order creation (stock re-validated server-side inside the same DB transaction that creates the order, independent of the cart-time check), order history ("My Orders"), order details, **Single-Store Order Rule** (`orders.store_id` derived server-side from the cart's actual items, never client-supplied; a cart that somehow mixes stores is rejected at checkout with `MULTI_STORE_CART`).
- ✅ **Customer order cancellation:** `PATCH /api/orders/:id/cancel` — allowed only while `status = 'pending'`; stock is restored on cancellation; re-cancelling or cancelling another customer's order is correctly rejected (400 / 404).
- ✅ **Localization (English/Arabic):** Full `flutter_localizations` + ARB/gen_l10n toolchain, RTL layout for Arabic, persisted language selector under Profile, every screen translated.

## Completed Features — Store Owner Flow

- ✅ **Store Owner Dashboard shell:** Role-gated entry point on Profile (shown only for `store_owner`, role re-verified from the DB), 4-tab shell (Dashboard/Products/Orders/Stores), store switcher for owners of more than one store.
- ✅ **Dashboard statistics:** `GET /api/stores/:storeId/dashboard` — order counts by status (`pending/confirmed/preparing/shipped/delivered`) plus total product count.
- ✅ **Store products:** `GET /api/stores/:storeId/products` — the owner's full product list **including deactivated products** (unlike the public product endpoints).
- ✅ **Product CRUD:** create (`POST /api/stores/:storeId/products`) and update (`PUT /api/products/:id`, variants updated in place by `id` or appended if new — a variant row is never deleted, to protect `order_items`/`cart_items` foreign keys).
- ✅ **Soft delete / reactivate:** `PATCH /api/products/:id/deactivate` and `PATCH /api/products/:id/reactivate` — never a hard `DELETE`; deactivated products are filtered out of every public product-visibility surface (`GET /api/products`, `GET /api/products/:id`, category browsing, search) but remain visible (with `is_active: false`) on the owner's own product list.
- ✅ **Store orders & order details:** `GET /api/stores/:storeId/orders` (optionally filtered by `status`), `GET /api/stores/:storeId/orders/:orderId`.
- ✅ **Order status updates:** `PATCH /api/stores/:storeId/orders/:orderId/status` — advances one step at a time along the fixed forward lifecycle (see below); a store owner can never skip a step, go backward, or set `cancelled` (customer-only).
- ✅ **Ownership authorization:** `requireRole('store_owner', 'admin')` + `requireStoreOwnership`/`requireProductOwnership` on every dashboard/product-management endpoint — ownership is always resolved server-side from the route param + database, never trusted from the request body; `admin` bypasses ownership (no admin account exists yet to exercise this, see Testing Status).

## Order Status Lifecycle (as implemented)

```
pending → confirmed → preparing → shipped → delivered
```

- One step at a time, no skipping, no going backward. Enforced by `orderService.js`'s `VALID_TRANSITIONS` map, which is the single source of truth (`backend/src/services/orderService.js`).
- `pending → cancelled` is exclusively customer-initiated (`PATCH /api/orders/:id/cancel`); a store owner can never set `cancelled` through `PATCH /api/stores/:storeId/orders/:orderId/status`.
- `delivered` and `cancelled` are terminal — no further transitions from either.
- **The database's `orders.status` column still contains the legacy `shipping` enum value for backward compatibility** (see migration 004 below), but **the application never reads or writes it** — confirmed by inspection (zero references to `"shipping"` anywhere in `backend/src/` or `mobail/lib/`) and by live testing (a store owner attempting to set `status: "shipping"` gets `400 INVALID_STATUS`, same as any other invalid value). Documentation and code should continue to treat the lifecycle as the five states above only.

## Database / Migration History

Five manual SQL migration files exist under `database/migrations/` (no automated migration runner — see Technical Debt). All five are confirmed applied to the live `beep_beep` database as of the 2026-09-14 verification (checked directly via live queries, not assumed).

1. **`001_create_reviews_table.sql`** — adds the `reviews` table (`product_id`, `user_id`, `rating` 1–5, `comment`, `UNIQUE(user_id, product_id)`).
2. **`002_add_roles_ownership_single_store.sql`** — adds `users.role`, `stores.owner_id` (nullable), `carts.store_id` (nullable), `orders.store_id` (nullable), plus indexes/FKs. Backs the role system, store ownership, and the single-store cart/order rules.
3. **`003_add_product_is_active.sql`** — adds `products.is_active` (`TINYINT(1)`, `DEFAULT 1`) for soft-delete, plus an index.
4. **`004_widen_order_status_enum.sql`** — widens the live `orders.status` enum from `('pending','confirmed','shipping','delivered','cancelled')` to `('pending','confirmed','preparing','shipping','shipped','delivered','cancelled')`, so the application's real 5-step lifecycle (which needs `preparing`/`shipped`) can actually be written to the database. Keeps `shipping` for backward compatibility rather than removing it (purely additive, no data at risk). **Confirmed applied and working** — the full `pending → confirmed → preparing → shipped → delivered` lifecycle has been exercised live end-to-end (see Testing Status).
5. **`005_align_orders_cart_schema.sql`** — the largest of the five: aligns several tables' live schema with what the application code had already been written against (this schema drift predated migration 005 and had been silently breaking checkout/orders/cart until it was found and fixed). Adds to `orders`: `customer_name`, `customer_phone`, `delivery_address`, `subtotal`, `delivery_fee`, `total`, `payment_method`, `payment_status`, `updated_at` (and relaxes the old `address`/`total_price` columns to nullable rather than dropping them). Adds to `order_items`: `product_id`, `variant_id`, `variant_name`, `variant_color`, `variant_size`, `unit_price`, `subtotal`, `created_at`. Adds to `cart_items`: `price`, `created_at`, `updated_at` (backfilled from `product_variants.price` for any pre-existing rows). Adds to `product_images`: `image_path`, `is_primary` (backfilled from the older `image_url`/`is_main` columns). Adds `product_variants.updated_at`. All changes are additive/backfilled — no column dropped, no data destroyed.

**Addresses schema note:** the live `addresses` table was never migrated to the richer shape (`label`, `recipient_name`, `phone`, `address`) that earlier documentation and Flutter code assumed — it only ever had `(id, user_id, city, area, details, is_default)`. This was found and fixed by rewriting `AddressModel` and the address-selection UI in Checkout to use `city`/`details` instead of the non-existent columns (no migration was needed or written for this — it was a code-vs-live-schema mismatch, not a missing column). See "Important Fixes" below.

## Important Fixes

Concise list of the significant, confirmed (live-tested) bugs found and fixed since the Store Owner Dashboard feature was first built:

- **Checkout address-selector UI overflow:** `DropdownButtonFormField`'s closed-field display doesn't size to a multi-line item widget, causing a `RenderFlex` overflow when a two-line saved address (city + details) was selected. Fixed with `selectedItemBuilder` (single-line closed display; the multi-line dropdown menu itself is unchanged).
- **Cart stock validation gap:** stock was only checked against the newly-requested quantity on add, and **not checked at all** on the quantity "+"/"-" control (`PATCH /api/cart/items/:id`) — a customer could exceed available stock by incrementing an already-in-cart item. Fixed server-side on both endpoints; the Flutter "+" control is now also disabled once the limit is reached, with an explanatory localized message.
- **Orders DECIMAL-as-string bug:** `orders.subtotal/delivery_fee/total` and `order_items.unit_price/subtotal` are `DECIMAL` columns; `mysql2` returns `DECIMAL` as JS strings (the connection pool is not configured with `decimalNumbers: true`). Flutter's `Order.fromJson`/`OrderItem.fromJson` do `(json[...] as num)`, which throws on a string — this was the confirmed root cause of "My Orders" showing a generic error screen after a successful checkout. Fixed by normalizing these fields to real numbers in `orderRepository.js`, applied to **all four** order-reading functions (customer `findByUserId`/`findById` and the store-owner-scoped `findByStoreId`/`findByIdForStore`, which shared the identical bug via the same Flutter `Order` model).
- **Store-owner product variant price DECIMAL-as-string bug:** the same class of bug, found independently in `productRepository.findByStoreIdForOwner` (the Store Owner Products tab) — `product_variants.price` came back as a string, which would crash `ProductVariant.fromJson`. The customer-facing `findById` already normalized this; the owner-facing list had not. Fixed the same way.
- **Addresses schema mismatch (earlier stabilization fix, historical):** `AddressModel` and every address-related Flutter screen originally assumed columns (`label`, `recipient_name`, `phone`, `address`) that never existed on the live `addresses` table, causing every address endpoint to fail. Fixed by rewriting the model and UI to match the table's actual columns (`city`, `area`, `details`, `is_default`).

This list is intentionally a fix log, not a full changelog — see git history for complete detail.

## Current Project Status

### Fully Completed
- Everything listed under "Completed Features — Customer Flow" and "Completed Features — Store Owner Flow" above.

### Partially Completed / Known Gaps
- **Categories hierarchy:** schema/design-intent only — no `parent_id` column, no parent-child logic anywhere in the backend or Flutter code. Category browsing is a flat list.
- **Store creation:** a store owner cannot create a new store through the app — the dashboard is list/switch/manage-existing-stores only (no `POST /api/stores`, no Flutter creation form).
- **Product image upload:** product images remain URL-string only; no file/multipart upload endpoint or UI exists anywhere in the stack.
- **User profile management:** Profile screen is view-only (name, role, language selector, logout, navigation to Orders/Favorites/Addresses/Dashboard). No edit name/phone/email, no password change, no avatar — `authService.js`/`authController.js` have no update-profile endpoint.

### Not Started
- **Admin Dashboard** — no admin routes/controllers/Flutter screens exist. The authorization middleware's `admin`-bypass branches (`requireRole`, `requireStoreOwnership`, `requireProductOwnership`) already exist and were built for this, but are currently unused (no admin account exists in the seed data).
- **Payment Gateways** — `orders.payment_method`/`payment_status` columns exist and are populated, but only ever as `cash_on_delivery`/`pending`; no real gateway integration (Stripe, PayPal, etc.).
- **Product Recommendations** — no browsing-history capture or recommendation logic anywhere.
- **Coupons / Discounts** — no schema, no endpoints, no UI.
- **Notifications** — no push/in-app notification system.
- **Delivery-driver integration** — no driver role, no delivery-tracking schema or UI.
- **Multi-city support** — the app is Aleppo-only; no city dimension in the schema or UI.
- **Refresh tokens / password reset / email or phone verification / account lockout / MFA** — none implemented; JWT is a flat 7-day token with no revocation mechanism.
- **Automated test suite** — no Jest/Mocha/etc. on the backend (`package.json` has no `test` script); no Flutter widget tests beyond the default `test/widget_test.dart` scaffold.
- **Migration runner** — the five migrations above are hand-run `.sql` files in dependency order; there is no migration-tracking table or runner tool.

## Testing Status

Precise, so the distinction between "verified" and "not verified" stays clear:

- ✅ **Backend live API + real database testing performed** for the major customer flow (products → favorites → addresses → cart → checkout → orders → order details → cancellation, including stock-limit edge cases) and the major store-owner flow (dashboard stats → store products → product update → store orders → order details → status transitions), all against the real running backend and the real `beep_beep` MySQL database — not a mocked or disposable sandbox.
- ✅ **Authorization matrix tested live:** unauthenticated (401), authenticated customer (403 on store-owner endpoints), correct store owner (200, and mutations persist), wrong store owner (403, and mutations do **not** apply) — verified on `GET`/`PATCH` store-order and `PUT` product-update endpoints.
- ✅ **Full order lifecycle tested end-to-end live:** a real order was walked through `pending → confirmed → preparing → shipped → delivered` via the real `PATCH /api/stores/:storeId/orders/:orderId/status` endpoint, with every invalid transition probed and rejected along the way (skip-ahead, backward, store-owner setting `cancelled`, the legacy `shipping` value) and status/numeric-field consistency verified across all four read surfaces (customer My Orders, customer Order Details, store owner order list, store owner order detail) after every step.
- ✅ `flutter pub get` — passed.
- ✅ `flutter analyze` — passed with only pre-existing issues (unused imports/local variable in `store_owner_*` pages, a few `use_build_context_synchronously` infos, minor lint notes in the generated l10n files) — none introduced by the verification/fix work.
- ❌ **Flutter UI/device runtime testing has NOT been performed.** No emulator or physical device was available during the latest verification session — all Flutter-side verification is static (`analyze`/`pub get`) plus reasoning from live backend API responses against the Dart model parsing code, not an actual running app. This applies to every screen, including the newly-fixed checkout dropdown and the new cart stock-limit message. Treat Flutter runtime behavior as unverified until run on a real device/emulator.
- **Admin bypass path** in `requireRole`/`requireStoreOwnership`/`requireProductOwnership` — not verified live (no admin account exists in seed data); confirmed only by code inspection.

## Git / Project Health

All of the above work is **committed and pushed**. Current `master`:
```
34b5d7b Complete customer and store owner flows   (customer + store-owner verification & fixes)
d847bfa feat: complete store owner dashboard and role system
9c24c56 feat: implement reviews system and localization support
```
Working tree is clean as of this update. (Earlier revisions of this document incorrectly described recent work as uncommitted — that is no longer the case.)

## Next Planned Feature

**Admin Dashboard.** This is the explicit next step (see `CLAUDE.md`'s "Immediate Next Step"). It is also the best architectural fit available: the `admin`-role bypass in `requireStoreOwnership`/`requireProductOwnership`/`requireRole` already exists and is unused, so an admin dashboard is largely new routes/controllers/Flutter screens layered on authorization plumbing that's already built. Not implemented as part of this documentation update.

## Roadmap

### Phase 1: Core Marketplace — Complete
- [x] Auth, Home, Stores, Products, Cart, Orders, Search, Favorites, Addresses, Categories, Product Filters.
- [x] Localization (English default / Arabic, RTL/LTR).

### Phase 2: Community & Engagement — Partially Complete
- [x] **Product Reviews & Ratings.**
- [ ] Product Recommendations.

### Phase 3: Business & Operations — Partially Complete
- [x] **Store Owner Dashboard** (product management, order fulfillment) — verified live end-to-end.
- [ ] **Admin Dashboard** — next planned feature (see above).
- [ ] Payments (real gateway integration).
- [ ] User Profiles (edit beyond logout/addresses).
- [ ] Store creation flow, product image upload (currently gaps in the otherwise-complete Store Owner Dashboard).

### Phase 4: Scaling & Growth — Future
- [ ] Multi-City Support.
- [ ] Multi-Category Support (architecture is ready — products already belong to a category and a store).
- [ ] Delivery Driver App/Integration.
- [ ] Marketing Tools (coupons, discounts, notifications).

## Technical Debt & Notes

- **Database Migrations:** No migration runner or tracking table — five manual `.sql` files in `database/migrations/`, all confirmed applied to the live database (see above). Run any future migration by hand, in numeric order.
- **Testing:** No automated test framework (backend or Flutter, beyond the default widget-test scaffold). All verification to date has been manual: live `curl`/API testing against a real database for the backend, `flutter analyze`/`pub get` (static) for Flutter. No Flutter runtime/device testing has ever been performed in any session.
- **Logging:** Only `console.log`/`console.error`; no structured logging system.
- **Rate Limiting:** Not implemented on any endpoint.
- **Documentation:** `docs/project_context.md`, `docs/AI_PROJECT_BRIEF.md`, and `docs/database.md` are the detailed references; this file is the concise living status summary. All were refreshed together as of the date at the top of this file.
- **Seed Data Script:** `backend/src/seeders/seed.js` remains the source of demo data (5 users, 5 stores, 7 categories, 15 products, addresses, favorites, cart items — password `password123` for all seeded users). It does not touch `orders`/`order_items`. No admin user is seeded.
