const pool = require('../config/database');

const getAll = async () => {
  const [categories] = await pool.execute(
    `SELECT id, name, created_at
     FROM categories 
     ORDER BY name ASC`
  );
  return categories;
};

const findById = async (id) => {
  const [categories] = await pool.execute(
    `SELECT id, name, created_at
     FROM categories 
     WHERE id = ?`,
    [id]
  );
  return categories[0] || null;
};

// Store Owner Dashboard: added "AND p.is_active = 1" -- this is a public,
// customer-facing listing (same visibility rule as productRepository's
// findAll/findById), so a deactivated product must disappear from category
// browsing exactly the same way it already disappears from the main product
// list and product detail page. Additive filter, default value (1) means no
// behavior change for any pre-existing row.
const getProductsByCategory = async (categoryId) => {
  const [products] = await pool.execute(
    `SELECT p.id, p.name, p.description, p.store_id, p.category_id, p.created_at, p.updated_at,
            s.name as store_name, s.logo as store_logo
     FROM products p
     JOIN stores s ON p.store_id = s.id
     WHERE p.category_id = ? AND s.status = 'active' AND p.is_active = 1
     ORDER BY p.created_at DESC`,
    [categoryId]
  );
  return products;
};

module.exports = {
  getAll,
  findById,
  getProductsByCategory
};
