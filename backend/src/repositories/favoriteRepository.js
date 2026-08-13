const pool = require('../config/database');

const findByUserId = async (userId) => {
  const [favorites] = await pool.execute(
    `SELECT f.id, f.product_id, f.created_at,
            p.id as product_id, p.name as product_name, p.description as product_description,
            p.store_id, p.created_at as product_created_at,
            s.name as store_name, s.logo as store_logo, s.address as store_address,
            pv.price as lowest_price
     FROM favorites f
     JOIN products p ON f.product_id = p.id
     JOIN stores s ON p.store_id = s.id
     LEFT JOIN product_variants pv ON p.id = pv.product_id
     WHERE f.user_id = ? AND s.status = 'active'
     GROUP BY p.id
     ORDER BY f.created_at DESC`,
    [userId]
  );
  return favorites;
};

const findByUserAndProduct = async (userId, productId) => {
  const [favorites] = await pool.execute(
    'SELECT id FROM favorites WHERE user_id = ? AND product_id = ?',
    [userId, productId]
  );
  return favorites[0] || null;
};

const addFavorite = async (userId, productId) => {
  const [result] = await pool.execute(
    'INSERT INTO favorites (user_id, product_id, created_at) VALUES (?, ?, NOW())',
    [userId, productId]
  );
  return result.insertId;
};

const removeFavorite = async (userId, productId) => {
  const [result] = await pool.execute(
    'DELETE FROM favorites WHERE user_id = ? AND product_id = ?',
    [userId, productId]
  );
  return result.affectedRows > 0;
};

const checkFavorite = async (userId, productId) => {
  const [favorites] = await pool.execute(
    'SELECT id FROM favorites WHERE user_id = ? AND product_id = ?',
    [userId, productId]
  );
  return favorites.length > 0;
};

module.exports = {
  findByUserId,
  findByUserAndProduct,
  addFavorite,
  removeFavorite,
  checkFavorite
};
