-- Migration: Multi-role users, store ownership, single-store cart/order rule
-- Feature: Store Ownership + Role-Based Authorization + Single-Store Orders
-- Date: 2026-08-23
--
-- Run this manually against the `beep_beep` MySQL database (this project has
-- no automated migration runner; see docs/database.md and
-- database/migrations/001_create_reviews_table.sql for the same convention).
--
-- Design notes:
--   * Purely additive. No existing column is renamed, retyped, or dropped.
--   * Every new column is added NULLABLE first, even orders.store_id, so this
--     migration is safe to run against a database that already has real
--     users/stores/carts/orders. Tightening orders.store_id to NOT NULL is a
--     deliberate, separate follow-up step (see the bottom of this file) that
--     must only be run after the pre-flight checks below confirm it's safe.
--   * Column types follow the existing schema's convention (plain INT
--     primary/foreign keys, DATETIME timestamps) — same as
--     001_create_reviews_table.sql.
--
-- IMPORTANT — verify before running:
--   This project has no committed schema/migration history for `users`,
--   `stores`, `carts`, or `orders` (only 001_create_reviews_table.sql exists
--   as a prior migration). Every column referenced below is confirmed by the
--   application code that reads/writes it, but this migration cannot
--   independently verify your live column *types*. In particular:
--     Run this first:  SHOW COLUMNS FROM users LIKE 'role';
--   If `role` is a plain VARCHAR/TEXT column (expected — nothing elsewhere in
--   this schema uses ENUM, and the application never declares one), no
--   change is needed for it at all: 'store_owner' and 'admin' are just new
--   string values the application will start writing. If it turns out to be
--   an ENUM that does NOT already include 'store_owner'/'admin', run this
--   first (adjust the existing value list to match reality):
--     ALTER TABLE users MODIFY role ENUM('customer','store_owner','admin') NOT NULL DEFAULT 'customer';

-- =============================================================================
-- 1) Store ownership: stores.owner_id
-- =============================================================================
-- Nullable: existing stores (including all current seed data) have no owner
-- yet. A store with owner_id IS NULL is simply "not yet claimed/assigned" —
-- the application must treat that as "no one may manage this store" rather
-- than defaulting it to any particular user. Backfill real owners, then
-- optionally tighten to NOT NULL once every row has one (not required for
-- this feature to function).
--
-- "At most one owner per store" is enforced by this being a single nullable
-- column (not a join table) — one store row can only ever reference one
-- owner_id. The reverse (one owner, many stores) is intentionally NOT
-- restricted: no UNIQUE constraint on owner_id, so one store_owner user can
-- own multiple stores if the business ever needs that; nothing here forces
-- it either way for a single-store owner.
ALTER TABLE stores
  ADD COLUMN owner_id INT NULL AFTER id,
  ADD CONSTRAINT fk_stores_owner FOREIGN KEY (owner_id) REFERENCES users(id),
  ADD INDEX idx_stores_owner_id (owner_id);

-- =============================================================================
-- 2) Single-store cart: carts.store_id
-- =============================================================================
-- Nullable by design, not just for migration safety: a freshly created or
-- emptied cart legitimately has no store yet. Set by the application when
-- the first item is added to an empty cart; reset to NULL when the cart
-- becomes empty again (last item removed, or cleared).
ALTER TABLE carts
  ADD COLUMN store_id INT NULL AFTER user_id,
  ADD CONSTRAINT fk_carts_store FOREIGN KEY (store_id) REFERENCES stores(id),
  ADD INDEX idx_carts_store_id (store_id);

-- =============================================================================
-- 3) Single-store orders: orders.store_id
-- =============================================================================
-- Added NULLABLE here. This is the one column in this migration where a
-- NOT NULL constraint is the eventual goal (every order should belong to
-- exactly one store going forward) but must NOT be applied blindly — see the
-- pre-flight checks below. The backend enforces "exactly one store per new
-- order" at the application layer (checkout validation) regardless of
-- whether this column is nullable or not; the NOT NULL constraint is
-- defense-in-depth for new rows, not the primary enforcement mechanism.
ALTER TABLE orders
  ADD COLUMN store_id INT NULL AFTER user_id,
  ADD CONSTRAINT fk_orders_store FOREIGN KEY (store_id) REFERENCES stores(id),
  ADD INDEX idx_orders_store_id (store_id);

-- =============================================================================
-- Pre-flight checks — run BEFORE ever tightening orders.store_id to NOT NULL
-- =============================================================================
-- This project's own docs (development_status.md) confirm no order has ever
-- reached `delivered` through the app itself, and that reaching it required
-- a direct SQL update — so real historical order data is expected to be
-- minimal or nonexistent. Still, do not assume that; check first.
--
-- (a) Does any EXISTING order already span more than one store? (possible
--     under the old schema, since nothing prevented it before this migration)
--     If this returns any rows, those specific orders cannot be safely
--     auto-assigned a single store_id — resolve them manually (e.g. leave
--     store_id NULL for that legacy order as a documented exception) before
--     proceeding to (c).
--
--   SELECT oi.order_id, COUNT(DISTINCT p.store_id) AS distinct_stores
--   FROM order_items oi
--   JOIN products p ON oi.product_id = p.id
--   GROUP BY oi.order_id
--   HAVING COUNT(DISTINCT p.store_id) > 1;
--
-- (b) Backfill store_id for existing single-store orders from their items:
--
--   UPDATE orders o
--   JOIN (
--     SELECT oi.order_id, MIN(p.store_id) AS store_id
--     FROM order_items oi
--     JOIN products p ON oi.product_id = p.id
--     GROUP BY oi.order_id
--     HAVING COUNT(DISTINCT p.store_id) = 1
--   ) resolved ON resolved.order_id = o.id
--   SET o.store_id = resolved.store_id
--   WHERE o.store_id IS NULL;
--
-- (c) Only after (a) returns no rows needing manual handling and (b) has been
--     run, tighten the column (skip this indefinitely if you'd rather leave
--     legacy orders with a NULL store_id permanently — the application does
--     not require this step to function correctly for new orders):
--
--   ALTER TABLE orders MODIFY store_id INT NOT NULL;
--
-- Orders with no items yet (should not normally happen given the existing
-- checkout flow, but is not schema-impossible) would also fail a NOT NULL
-- tightening — check for those too if step (c) is ever run.

-- =============================================================================
-- 4) Optional: formalize the role value set (skip if users.role is ENUM and
--    was already handled in the "IMPORTANT" note above)
-- =============================================================================
-- Mirrors the CHECK-constraint pattern already used in
-- 001_create_reviews_table.sql. Enforced by MySQL 8.0.16+ / MariaDB 10.2.1+;
-- silently ignored on older servers, in which case the application layer's
-- own validation remains the source of truth for valid role values, same as
-- the existing rating-range precedent.
ALTER TABLE users
  ADD CONSTRAINT chk_users_role CHECK (role IN ('customer', 'store_owner', 'admin'));

-- Not part of this migration: no changes to products, product_variants,
-- product_images, order_items, reviews, favorites, addresses, categories,
-- cart_items — all remain structurally sufficient for this feature.
