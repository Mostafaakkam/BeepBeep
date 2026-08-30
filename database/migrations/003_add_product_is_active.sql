-- Migration: Product soft-delete flag
-- Feature: Store Owner Dashboard (Product Management)
-- Date: 2026-08-29
--
-- Run this manually against the `beep_beep` MySQL database, after
-- 002_add_roles_ownership_single_store.sql (this project has no automated
-- migration runner; see docs/database.md and prior migration files for the
-- same convention).
--
-- Design notes:
--   * Purely additive, single column, safe default. No existing column is
--     renamed, retyped, or dropped, and no existing row's visible behavior
--     changes: DEFAULT 1 means every existing product is immediately
--     "active" (identical to today's implicit behavior, where every product
--     was always visible with no such flag at all).
--   * The `products` table has no delete/active-status column today. The
--     Store Owner Dashboard needs a way for an owner to remove a product
--     from sale without a hard SQL DELETE, because products are referenced
--     by order_items (snapshotted, but still FK'd), reviews, favorites, and
--     cart_items -- a hard delete would either fail on the FK or cascade
--     into deleting real order/review history. Soft-deactivation avoids
--     that entirely: is_active = 0 just means "no longer offered for sale",
--     while every historical reference to the product stays intact.
--   * TINYINT(1) matches this project's convention for boolean-like flags
--     seen elsewhere (e.g. product_images.is_primary in seed.js).
ALTER TABLE products
  ADD COLUMN is_active TINYINT(1) NOT NULL DEFAULT 1 AFTER category_id,
  ADD INDEX idx_products_is_active (is_active);

-- Not part of this migration: no changes to product_variants, product_images,
-- orders, order_items, carts, cart_items, stores, users, reviews, favorites,
-- addresses, categories -- all remain structurally sufficient for this
-- feature (see docs/AI_PROJECT_BRIEF.md, "Store Owner Dashboard
-- Implementation" section, for the full architecture rationale).
