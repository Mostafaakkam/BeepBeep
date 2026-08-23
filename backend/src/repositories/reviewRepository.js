const pool = require('../config/database');

const findByProductId = async (productId) => {
  const [reviews] = await pool.execute(
    `SELECT r.id, r.product_id, r.user_id, r.rating, r.comment, r.created_at, r.updated_at,
            u.name as user_name
     FROM reviews r
     JOIN users u ON r.user_id = u.id
     WHERE r.product_id = ?
     ORDER BY r.created_at DESC`,
    [productId]
  );
  return reviews;
};

const findById = async (id) => {
  const [reviews] = await pool.execute(
    `SELECT r.id, r.product_id, r.user_id, r.rating, r.comment, r.created_at, r.updated_at,
            u.name as user_name
     FROM reviews r
     JOIN users u ON r.user_id = u.id
     WHERE r.id = ?`,
    [id]
  );
  return reviews[0] || null;
};

const findByUserAndProduct = async (userId, productId) => {
  const [reviews] = await pool.execute(
    `SELECT id, product_id, user_id, rating, comment, created_at, updated_at
     FROM reviews
     WHERE user_id = ? AND product_id = ?`,
    [userId, productId]
  );
  return reviews[0] || null;
};

const create = async (userId, productId, rating, comment) => {
  const [result] = await pool.execute(
    `INSERT INTO reviews (product_id, user_id, rating, comment, created_at, updated_at)
     VALUES (?, ?, ?, ?, NOW(), NOW())`,
    [productId, userId, rating, comment]
  );
  return result.insertId;
};

const update = async (id, userId, rating, comment) => {
  const [result] = await pool.execute(
    `UPDATE reviews
     SET rating = ?, comment = ?, updated_at = NOW()
     WHERE id = ? AND user_id = ?`,
    [rating, comment, id, userId]
  );
  return result.affectedRows > 0;
};

const remove = async (id, userId) => {
  const [result] = await pool.execute(
    'DELETE FROM reviews WHERE id = ? AND user_id = ?',
    [id, userId]
  );
  return result.affectedRows > 0;
};

const getRatingSummary = async (productId) => {
  const [rows] = await pool.execute(
    `SELECT COUNT(*) as review_count, AVG(rating) as average_rating
     FROM reviews
     WHERE product_id = ?`,
    [productId]
  );
  const row = rows[0];
  return {
    reviewCount: row.review_count || 0,
    averageRating: row.average_rating !== null ? parseFloat(row.average_rating) : 0
  };
};

// Purchase eligibility: user must have at least one 'delivered' order
// containing this product. Joins orders -> order_items (see orderRepository.js
// for the authoritative column list this query relies on).
const hasPurchased = async (userId, productId) => {
  const [rows] = await pool.execute(
    `SELECT o.id
     FROM orders o
     JOIN order_items oi ON oi.order_id = o.id
     WHERE o.user_id = ? AND oi.product_id = ? AND o.status = 'delivered'
     LIMIT 1`,
    [userId, productId]
  );
  return rows.length > 0;
};

module.exports = {
  findByProductId,
  findById,
  findByUserAndProduct,
  create,
  update,
  remove,
  getRatingSummary,
  hasPurchased
};
