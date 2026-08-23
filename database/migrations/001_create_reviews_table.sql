-- Migration: Create reviews table
-- Feature: Product Reviews & Ratings
-- Date: 2026-08-22
--
-- Run this manually against the `beep_beep` MySQL database
-- (this project has no automated migration runner; see docs/database.md).
--
-- Design notes:
--   * A user may leave at most one review per product (UNIQUE(user_id, product_id)),
--     enforced at the database level as a second line of defense on top of the
--     application-level duplicate check in reviewService.js.
--   * Purchase eligibility (the user must have a 'delivered' order containing the
--     product) is NOT modeled as a schema constraint -- it is enforced in
--     reviewService.js at write time by querying orders/order_items directly.
--     This keeps the schema minimal and avoids tying a review to one specific
--     order when a user could have purchased the same product more than once.
--   * average_rating / review_count are NOT stored as columns on `products`.
--     They are computed on read (AVG/COUNT over `reviews`) to avoid keeping a
--     denormalized value in sync. See reviewRepository.getRatingSummary() and
--     the extended productRepository.findById().
--   * Column types follow the existing schema's convention observed in
--     orders/order_items/favorites/addresses: plain INT primary/foreign keys
--     (no UNSIGNED/BIGINT), DATETIME timestamps.

CREATE TABLE IF NOT EXISTS reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  user_id INT NOT NULL,
  rating TINYINT NOT NULL,
  comment TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT uq_reviews_user_product UNIQUE (user_id, product_id),
  CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5),
  CONSTRAINT fk_reviews_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Speeds up the two most common access patterns: fetching a product's reviews
-- (and rating summary) and, separately, a user's own reviews.
CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);

-- Notes for the developer running this manually:
--   * CHECK constraints are enforced by MySQL 8.0.16+. If running an older
--     MySQL version, the CHECK clause above is silently ignored by the server;
--     the application layer (reviewService.js) still validates rating is an
--     integer 1-5 on every create/update, so data integrity is preserved either way.
--   * This migration is purely additive: it creates one new table and two
--     indexes, and does not alter any existing table. No existing data,
--     endpoints, or app functionality are affected.
