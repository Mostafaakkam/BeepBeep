-- Migration: Align live schema (orders, order_items, cart_items,
-- product_images, product_variants) with the application code's actual
-- column expectations
-- Feature: Order Lifecycle E2E Verification -- stabilization fix
-- Date: 2026-08-30
--
-- Run this manually against the `beep_beep` MySQL database, after
-- 004_widen_order_status_enum.sql (this project has no automated migration
-- runner; see docs/database.md and prior migration files for the same
-- convention).
--
-- CONFIRMED ROOT CAUSE (verified this session by running the real backend
-- against the real live database for the first time -- previous sessions
-- either had no reachable backend or only reviewed code/docs statically):
-- five tables are still on an older, simpler schema that predates the
-- Checkout/Orders, Reviews, Favorites, and Store Owner Dashboard features'
-- current code. That code was written against a richer schema which was,
-- apparently, never actually applied to this specific database. Confirmed
-- both by direct INFORMATION_SCHEMA inspection and by exercising the real
-- API end-to-end and observing real 500 errors:
--   * orders is missing customer_name, customer_phone, delivery_address,
--     subtotal, delivery_fee, total, payment_method, payment_status,
--     updated_at -- breaks checkout (POST /api/orders -> 500), order
--     history (GET /api/orders -> 500), order details (customer + store
--     owner), and the store owner's order list / status-update endpoints.
--   * order_items is missing product_id, variant_id, variant_name,
--     variant_color, variant_size, unit_price, subtotal, created_at --
--     breaks checkout and review purchase-eligibility (reviewRepository
--     .hasPurchased joins on oi.product_id, which does not exist).
--   * cart_items is missing price, created_at, updated_at -- breaks
--     "add to cart" (POST /api/cart/items -> 500, confirmed live) and
--     viewing a cart that has items in it.
--   * product_images has image_url/is_main where the code reads/writes
--     image_path/is_primary -- breaks product detail (GET /api/products/:id
--     -> 500, confirmed live), adding a favorite (which looks the product up
--     first), and the store owner's product list.
--   * product_variants is missing updated_at -- breaks the store owner's
--     product-update endpoint whenever it edits an existing variant.
--
-- Design notes:
--   * Additive only: every change is either a new column, or relaxing an
--     obsolete NOT NULL constraint on a legacy column the application no
--     longer writes (orders.address/total_price, order_items.price). No
--     column is dropped, renamed, or has its data destroyed.
--   * orders and order_items hold 0 rows on the live database as of this
--     audit (verified), so their new columns need no backfill.
--   * product_images and product_variants DO hold existing seeded rows.
--     This migration backfills image_path/is_primary from the existing
--     image_url/is_main values so seeded product images keep working, and
--     lets product_variants.updated_at's own DEFAULT CURRENT_TIMESTAMP
--     backfill itself on ADD COLUMN.
--   * cart_items also holds a few existing seeded rows; their price is
--     backfilled from the linked product_variants.price so those seeded
--     carts stay valid instead of showing price = NULL.
--   * addresses (live: city/area/details -- code: label/recipient_name/
--     phone/address) is DELIBERATELY NOT included here. Unlike the tables
--     above, this is not a missing-column gap -- it is a different way of
--     decomposing the same information, and reconciling them is a product
--     decision (e.g. does "address" concatenate city+area+details, or does
--     the UI need to change to collect label/recipient_name?), not a
--     mechanical schema fix. See the stabilization audit report. A
--     follow-up migration should come only after that decision is made.

-- ---------------------------------------------------------------------
-- orders
-- ---------------------------------------------------------------------
ALTER TABLE orders
  MODIFY COLUMN address TEXT NULL,
  MODIFY COLUMN total_price DECIMAL(10,2) NULL,
  ADD COLUMN customer_name VARCHAR(150) NULL AFTER user_id,
  ADD COLUMN customer_phone VARCHAR(30) NULL AFTER customer_name,
  ADD COLUMN delivery_address TEXT NULL AFTER customer_phone,
  ADD COLUMN subtotal DECIMAL(10,2) NULL AFTER status,
  ADD COLUMN delivery_fee DECIMAL(10,2) NULL AFTER subtotal,
  ADD COLUMN total DECIMAL(10,2) NULL AFTER delivery_fee,
  ADD COLUMN payment_method VARCHAR(30) NULL DEFAULT 'cash_on_delivery' AFTER total,
  ADD COLUMN payment_status VARCHAR(30) NULL DEFAULT 'pending' AFTER payment_method,
  ADD COLUMN updated_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at;

-- ---------------------------------------------------------------------
-- order_items
-- ---------------------------------------------------------------------
ALTER TABLE order_items
  MODIFY COLUMN price DECIMAL(10,2) NULL,
  ADD COLUMN product_id INT NULL AFTER order_id,
  ADD COLUMN variant_id INT NULL AFTER product_id,
  ADD COLUMN variant_name VARCHAR(255) NULL AFTER variant_details,
  ADD COLUMN variant_color VARCHAR(100) NULL AFTER variant_name,
  ADD COLUMN variant_size VARCHAR(50) NULL AFTER variant_color,
  ADD COLUMN unit_price DECIMAL(10,2) NULL AFTER price,
  ADD COLUMN subtotal DECIMAL(10,2) NULL AFTER unit_price,
  ADD COLUMN created_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP AFTER subtotal;

-- ---------------------------------------------------------------------
-- cart_items
-- ---------------------------------------------------------------------
ALTER TABLE cart_items
  ADD COLUMN price DECIMAL(10,2) NULL AFTER quantity,
  ADD COLUMN created_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP AFTER price,
  ADD COLUMN updated_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at;

-- Backfill price for existing seeded cart_items rows from their variant's
-- current price, so seeded carts remain valid instead of price = NULL.
UPDATE cart_items ci
  JOIN product_variants pv ON ci.variant_id = pv.id
  SET ci.price = pv.price
  WHERE ci.price IS NULL;

-- ---------------------------------------------------------------------
-- product_images
-- ---------------------------------------------------------------------
ALTER TABLE product_images
  ADD COLUMN image_path VARCHAR(255) NULL AFTER image_url,
  ADD COLUMN is_primary TINYINT(1) NULL DEFAULT 0 AFTER image_path;

UPDATE product_images SET image_path = image_url;
UPDATE product_images SET is_primary = is_main;

-- ---------------------------------------------------------------------
-- product_variants
-- ---------------------------------------------------------------------
ALTER TABLE product_variants
  ADD COLUMN updated_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at;
