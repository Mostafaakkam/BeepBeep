const pool = require('../config/database');

const findAll = async (storeId = null) => {
  let query;
  let params;
  
  if (storeId) {
    query = `
      SELECT p.id, p.name, p.description, p.store_id, p.category_id, p.created_at, p.updated_at,
             s.name as store_name, s.logo as store_logo
      FROM products p
      JOIN stores s ON p.store_id = s.id
      WHERE p.store_id = ? AND s.status = 'active'
      ORDER BY p.created_at DESC
    `;
    params = [storeId];
  } else {
    query = `
      SELECT p.id, p.name, p.description, p.store_id, p.category_id, p.created_at, p.updated_at,
             s.name as store_name, s.logo as store_logo
      FROM products p
      JOIN stores s ON p.store_id = s.id
      WHERE s.status = 'active'
      ORDER BY p.created_at DESC
    `;
    params = [];
  }
  
  const [rows] = await pool.execute(query, params);
  return rows;
};

const findById = async (id) => {
  const [products] = await pool.execute(
    `SELECT p.id, p.name, p.description, p.store_id, p.category_id, p.created_at, p.updated_at,
            s.name as store_name, s.logo as store_logo, s.address as store_address
     FROM products p
     JOIN stores s ON p.store_id = s.id
     WHERE p.id = ? AND s.status = 'active'`,
    [id]
  );
  
  if (products.length === 0) return null;
  
  const product = products[0];
  
  // Get images
  const [images] = await pool.execute(
    'SELECT id, image_path FROM product_images WHERE product_id = ? ORDER BY id ASC',
    [id]
  );
  product.images = images;
  
  // Get variants
  const [variants] = await pool.execute(
    'SELECT id, color, size, price, stock FROM product_variants WHERE product_id = ? ORDER BY id ASC',
    [id]
  );
  product.variants = variants;
  
  return product;
};

module.exports = {
  findAll,
  findById
};
