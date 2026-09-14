# Beep Beep - Database Documentation

## Overview

This document describes the database structure of the Beep Beep project.

The first version (MVP) is designed for Aleppo city and supports local stores. The database is designed to be scalable so that new categories, cities, and features can be added in the future without rebuilding the system.

**Schema history:** the tables below reflect the live schema after all five migrations in `database/migrations/` (`001`–`005`) have been applied — see that directory and `development_status.md`'s "Database / Migration History" section for exactly what each migration added and why. Columns added by a migration are marked accordingly.

---

# Database Design Principles

- Use integer primary keys.
- Use foreign keys to maintain data integrity.
- Avoid duplicated data.
- Separate entities into independent tables.
- Keep the database scalable and maintainable.
- Store image paths instead of image files.
- Preserve order history even if products change later.

---

# Tables

## users

### Purpose

Stores all application users.

### Columns

- id
- name
- phone
- email
- password
- role — `customer` (default), `store_owner`, or `admin` (added by migration 002). Always re-verified server-side from this table on every authorization check; never trusted from a JWT claim alone.
- created_at
- updated_at

### Relations

- One user can have multiple addresses.
- One user has one shopping cart.
- One user can create many orders.
- One user can have many favorite products.
- A `store_owner` may own zero or more stores (see `stores.owner_id`).

---

## stores

### Purpose

Stores all shops available in the application.

### Columns

- id
- owner_id — nullable, added by migration 002. A store can exist with no owner yet; at most one owner per store.
- name
- description
- phone
- address
- logo
- cover_image
- status
- created_at
- updated_at

### Relations

- One store contains many products.
- Belongs to at most one `store_owner` (never more).

---

## categories

### Purpose

Stores product categories.

### Columns

- id
- name
- created_at

### Relations

- One category contains many products.

**Note:** parent-child category hierarchy (e.g. Clothes → Men/Women/Kids) is a long-term design intent only. There is no `parent_id` column on this table, and no backend or Flutter code reads or writes one. Category browsing is currently a flat list.

---

## products

### Purpose

Stores the main information of each product.

Products do not store colors, sizes or stock. Those are stored inside `product_variants`.

### Columns

- id
- name
- description
- store_id
- category_id
- is_active — `TINYINT(1)`, `DEFAULT 1`, added by migration 003. Soft-delete flag: a store owner "deleting" a product sets this to 0 instead of a hard `DELETE` (protects `order_items`/`cart_items`/`reviews`/`favorites` foreign keys and preserves order history). Every public product-visibility surface (main product list/detail, category browsing, search) filters `is_active = 1`; the store owner's own product list does not, so an owner can see and reactivate their own deactivated products.
- created_at
- updated_at

### Relations

- Belongs to one store.
- Belongs to one category.
- Has many images.
- Has many variants.

---

## product_images

### Purpose

Stores all product images. Only image paths are stored.

### Columns

- id
- product_id
- image_path — added by migration 005 (the application code had already been written against this column name; the live table previously only had an older `image_url`/`is_main` pair, backfilled into `image_path`/`is_primary` by the migration)
- is_primary — added by migration 005 (backfilled from the older `is_main`)
- created_at

### Relations

- Belongs to one product.

---

## product_variants

### Purpose

Stores product variations. Each variant has its own:

- Color
- Size
- Price
- Stock

### Columns

- id
- product_id
- color
- size
- price
- stock
- created_at
- updated_at — added by migration 005

### Relations

- Belongs to one product.

---

## carts

### Purpose

Stores each user's shopping cart.

### Columns

- id
- user_id
- store_id — nullable, added by migration 002. `NULL` while the cart is empty; set to the store of the first item added. A cart holds items from exactly one store at a time (Single-Store Cart Rule) — adding a different store's product is rejected (`STORE_MISMATCH`) unless the customer explicitly confirms clearing and switching. Reset to `NULL` whenever the cart becomes empty.
- created_at
- updated_at

### Relations

- Belongs to one user.
- Contains many cart items.

---

## cart_items

### Purpose

Stores products inside the shopping cart. References product variants instead of products.

### Columns

- id
- cart_id
- variant_id
- quantity
- price — added by migration 005 (snapshot of the variant's price at add-time)
- created_at — added by migration 005
- updated_at — added by migration 005

### Relations

- Belongs to one cart.
- Belongs to one product variant.

---

## orders

### Purpose

Stores customer orders. Each order has its own status and totals.

### Columns

- id
- user_id
- store_id — nullable (NULL only on legacy orders predating migration 002), added by migration 002. Derived and validated **server-side only** from the cart's actual items at checkout — never accepted from the client. An order belongs to exactly one store (Single-Store Order Rule).
- customer_name — added by migration 005
- customer_phone — added by migration 005
- delivery_address — added by migration 005
- status (see "Status / Order Lifecycle" below)
- subtotal — added by migration 005
- delivery_fee — added by migration 005
- total — added by migration 005
- payment_method — added by migration 005 (`cash_on_delivery` only in the current MVP)
- payment_status — added by migration 005 (`pending` only — no real payment gateway wired up yet)
- created_at
- updated_at — added by migration 005
- address, total_price — older columns predating migration 005, relaxed to nullable rather than dropped; the application no longer writes to them.

### Status / Order Lifecycle

**The application uses exactly five states, one step at a time, no skipping, no going backward:**

```
pending → confirmed → preparing → shipped → delivered
```

Plus a separate terminal `cancelled`, reachable only from `pending` and only by the customer (never by a store owner). This is enforced in code by `orderService.js`'s `VALID_TRANSITIONS` map — the single source of truth.

The live database column is a MySQL `ENUM` that also still contains a legacy `shipping` value (`enum('pending','confirmed','preparing','shipping','shipped','delivered','cancelled')`, widened by migration 004 from an even older enum that was missing `preparing`/`shipped` entirely). **`shipping` is not an application state** — it predates the current lifecycle, no code path anywhere reads or writes it, and it is kept in the enum purely for backward compatibility with any pre-existing data. Do not treat it as a valid status when working on this project.

### Relations

- Belongs to one user.
- Belongs to exactly one store (Single-Store Order Rule).
- Contains many order items.

---

## order_items

### Purpose

Stores a snapshot of purchased products. Product name, variant details and price are copied to preserve purchase history even if the product/variant changes later.

### Columns

- id
- order_id
- product_id — added by migration 005
- variant_id — added by migration 005
- product_name
- variant_name — added by migration 005
- variant_color — added by migration 005
- variant_size — added by migration 005
- quantity
- unit_price — added by migration 005
- subtotal — added by migration 005
- created_at — added by migration 005
- price, variant_details — older columns predating migration 005, relaxed to nullable rather than dropped.

### Relations

- Belongs to one order.

---

## addresses

### Purpose

Stores customer delivery addresses. Users may have multiple addresses.

### Columns

- id
- user_id
- city
- area (nullable)
- details (nullable)
- is_default

**Note:** this table's actual shape is simpler than the `label`/`recipient_name`/`phone`/`address` fields that earlier iterations of the application code assumed — those columns never existed on the live table. The Flutter `AddressModel` and every address-related screen were corrected to match the columns above; see `development_status.md`'s "Important Fixes" for details. No migration was written for this because no column needed to be added — it was a code-vs-live-schema mismatch, not a schema gap. Checkout does not read a saved address's fields directly into the order — it collects `customer_name`/`customer_phone`/`delivery_address` at checkout time (optionally pre-filled from a selected address's `city`/`details`), which is what gets snapshotted onto the order.

### Relations

- Belongs to one user.

---

## favorites

### Purpose

Stores favorite products for each user.

### Columns

- id
- user_id
- product_id
- created_at

### Relations

- Belongs to one user.
- Belongs to one product.

---

## reviews

### Purpose

Stores product ratings and optional text reviews. Added by migration 001.

### Columns

- id
- product_id
- user_id
- rating — `TINYINT`, 1–5 (`CHECK` constraint)
- comment — nullable, free text
- created_at
- updated_at

### Constraints

- `UNIQUE(user_id, product_id)` — one review per user per product.
- A review may only be created by a user with a `delivered` order containing the reviewed product (enforced in the service layer, not by a DB constraint).

### Relations

- Belongs to one product.
- Belongs to one user.

Average rating and review count are **not** stored as columns anywhere — both are computed on read (`AVG(rating)`/`COUNT(*)`) and exposed on `GET /api/products/:id` and the dedicated review endpoints.

---

# Notes

This database represents the current state of Beep Beep's MVP, after the Role System/Store Ownership, Store Owner Dashboard, and schema-alignment (migrations 004–005) work.

**Implemented since the original MVP design:** store owner accounts and store ownership, product soft-delete/reactivation, product reviews, role-based authorization, single-store cart/order enforcement.

**Still not implemented (see `development_status.md` for the full, current breakdown):**

- Admin accounts / admin dashboard
- Delivery drivers
- Coupons
- Notifications
- Online payments
- Multi-city support
- Category parent-child hierarchy (see the `categories` table note above)
