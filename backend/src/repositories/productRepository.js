const pool = require('../config/database');

const findAll = async (filters = {}) => {
  const {
    storeId = null,
    categoryId = null,
    minPrice = null,
    maxPrice = null,
    inStock = false,
    sortBy = 'newest'
  } = filters;
  
  let query = `
    SELECT p.id, p.name, p.description, p.store_id, p.category_id, p.created_at, p.updated_at,
           s.name as store_name, s.logo as store_logo
    FROM products p
    JOIN stores s ON p.store_id = s.id
    LEFT JOIN product_variants pv ON p.id = pv.product_id
    WHERE s.status = 'active'
  `;
  
  const params = [];
  
  if (storeId) {
    query += ' AND p.store_id = ?';
    params.push(storeId);
  }
  
  if (categoryId) {
    query += ' AND p.category_id = ?';
    params.push(categoryId);
  }
  
  if (inStock) {
    query += ' AND pv.stock > 0';
  }
  
  if (minPrice !== null && maxPrice !== null) {
    query += ' AND pv.price >= ? AND pv.price <= ?';
    params.push(minPrice, maxPrice);
  } else if (minPrice !== null) {
    query += ' AND pv.price >= ?';
    params.push(minPrice);
  } else if (maxPrice !== null) {
    query += ' AND pv.price <= ?';
    params.push(maxPrice);
  }
  
  query += ' GROUP BY p.id';
  
  // Sorting
  const allowedSorts = ['newest', 'price_asc', 'price_desc', 'name_asc', 'name_desc'];
  const sortOption = allowedSorts.includes(sortBy) ? sortBy : 'newest';
  
  switch (sortOption) {
    case 'price_asc':
      query += ' ORDER BY MIN(pv.price) ASC';
      break;
    case 'price_desc':
      query += ' ORDER BY MIN(pv.price) DESC';
      break;
    case 'name_asc':
      query += ' ORDER BY p.name ASC';
      break;
    case 'name_desc':
      query += ' ORDER BY p.name DESC';
      break;
    case 'newest':
    default:
      query += ' ORDER BY p.created_at DESC';
      break;
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

  // Get rating summary (average rating + review count), computed on read
  // from the reviews table rather than stored as denormalized columns.
  const [ratingRows] = await pool.execute(
    'SELECT COUNT(*) as review_count, AVG(rating) as average_rating FROM reviews WHERE product_id = ?',
    [id]
  );
  product.review_count = ratingRows[0].review_count || 0;
  product.average_rating = ratingRows[0].average_rating !== null
    ? parseFloat(ratingRows[0].average_rating)
    : 0;

  return product;
};

// Added for Store/Product Ownership Authorization. Unlike findById() above,
// this intentionally does NOT filter on stores.status = 'active' — a store
// owner must still be able to resolve ownership of products belonging to
// their own inactive/pending store (e.g. to manage it), not just active
// ones. Used by middlewares/authorizationMiddleware.js#requireProductOwnership.
const findStoreIdById = async (productId) => {
  const [rows] = await pool.execute(
    'SELECT store_id FROM products WHERE id = ?',
    [productId]
  );
  if (rows.length === 0) return undefined; // product does not exist
  return rows[0].store_id;
};

module.exports = {
  findAll,
  findById,
  findStoreIdById
};
