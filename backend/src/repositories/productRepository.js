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
    WHERE s.status = 'active' AND p.is_active = 1
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
     WHERE p.id = ? AND s.status = 'active' AND p.is_active = 1`,
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

// Store Owner Dashboard: the owner's full product list for one store,
// unfiltered by p.is_active or s.status (unlike findAll/findById above) --
// an owner must see and manage their deactivated products too, not just the
// ones currently visible to customers. storeId here is never client-trusted
// on its own; callers only reach this after requireStoreOwnership has
// verified it (see routes/storeRoutes.js). Includes the same store_id/
// store_name/images/variants shape as the public endpoints so the existing
// Flutter Product model can be reused as-is for the dashboard.
const findByStoreIdForOwner = async (storeId) => {
  const [products] = await pool.execute(
    `SELECT p.id, p.name, p.description, p.store_id, p.category_id, p.is_active, p.created_at, p.updated_at,
            s.name as store_name, s.logo as store_logo, s.address as store_address
     FROM products p
     JOIN stores s ON p.store_id = s.id
     WHERE p.store_id = ?
     ORDER BY p.created_at DESC`,
    [storeId]
  );

  if (products.length === 0) return [];

  const ids = products.map((p) => p.id);
  const placeholders = ids.map(() => '?').join(',');

  const [variants] = await pool.execute(
    `SELECT id, product_id, color, size, price, stock FROM product_variants WHERE product_id IN (${placeholders}) ORDER BY id ASC`,
    ids
  );
  const [images] = await pool.execute(
    `SELECT id, product_id, image_path FROM product_images WHERE product_id IN (${placeholders}) ORDER BY id ASC`,
    ids
  );

  return products.map((p) => ({
    ...p,
    variants: variants
      .filter((v) => v.product_id === p.id)
      .map(({ product_id, ...rest }) => rest),
    images: images
      .filter((i) => i.product_id === p.id)
      .map(({ product_id, ...rest }) => rest)
  }));
};

// Store Owner Dashboard: create a product for a store. storeId is supplied
// by the controller from req.store.id (resolved/verified server-side by
// requireStoreOwnership), never from the request body -- see
// productController.createProduct. New products default to is_active = 1.
const create = async (storeId, data) => {
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const [result] = await connection.execute(
      `INSERT INTO products (name, description, store_id, category_id, is_active, created_at, updated_at)
       VALUES (?, ?, ?, ?, 1, NOW(), NOW())`,
      [data.name, data.description || null, storeId, data.categoryId]
    );
    const productId = result.insertId;

    for (const variant of data.variants) {
      await connection.execute(
        `INSERT INTO product_variants (product_id, color, size, price, stock, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, NOW(), NOW())`,
        [productId, variant.color || null, variant.size || null, variant.price, variant.stock]
      );
    }

    for (const imagePath of data.images) {
      // product_images has no updated_at column (confirmed by seed.js's own
      // "ignoring unknown column" warning for it) -- created_at only.
      await connection.execute(
        'INSERT INTO product_images (product_id, image_path, created_at) VALUES (?, ?, NOW())',
        [productId, imagePath]
      );
    }

    await connection.commit();
    return productId;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};

// Store Owner Dashboard: update a product's own fields and its variants.
// Deliberately conservative about variants: existing variants (identified by
// id) are updated IN PLACE (price/stock/color/size), never deleted, and new
// variants (no id) are appended. Variant rows are never removed here because
// product_variants.id is referenced by cart_items/order_items via FK --
// deleting a variant that's sitting in someone's cart or in a past order's
// snapshot would either violate that FK or destroy real order history. This
// is the deliberately narrower, safer scope described in the plan: an owner
// can retire a variant by setting its stock to 0, not by deleting the row.
// productId here is always the value requireProductOwnership already
// verified -- see productController.updateProduct.
const update = async (productId, data) => {
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    await connection.execute(
      `UPDATE products SET name = ?, description = ?, category_id = ?, updated_at = NOW() WHERE id = ?`,
      [data.name, data.description || null, data.categoryId, productId]
    );

    for (const variant of data.variants) {
      if (variant.id) {
        // Defense in depth: the WHERE also re-checks product_id, so even a
        // malformed request naming a variant id that belongs to a different
        // product can't cross-update it.
        await connection.execute(
          `UPDATE product_variants SET color = ?, size = ?, price = ?, stock = ?, updated_at = NOW()
           WHERE id = ? AND product_id = ?`,
          [variant.color || null, variant.size || null, variant.price, variant.stock, variant.id, productId]
        );
      } else {
        await connection.execute(
          `INSERT INTO product_variants (product_id, color, size, price, stock, created_at, updated_at)
           VALUES (?, ?, ?, ?, ?, NOW(), NOW())`,
          [productId, variant.color || null, variant.size || null, variant.price, variant.stock]
        );
      }
    }

    await connection.commit();
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};

// Store Owner Dashboard: soft-delete/reactivate. Never a hard DELETE -- see
// database/migrations/003_add_product_is_active.sql for why.
const setActive = async (productId, isActive) => {
  await pool.execute(
    'UPDATE products SET is_active = ?, updated_at = NOW() WHERE id = ?',
    [isActive ? 1 : 0, productId]
  );
};

// Store Owner Dashboard: product-count summary card. Counts all of the
// store's products regardless of is_active, since "how many products do I
// have" reasonably includes deactivated ones from the owner's own point of
// view (they still own/manage them) -- unlike the public-facing endpoints,
// which hide inactive products from customers entirely.
const countByStoreId = async (storeId) => {
  const [rows] = await pool.execute(
    'SELECT COUNT(*) as count FROM products WHERE store_id = ?',
    [storeId]
  );
  return rows[0].count;
};

module.exports = {
  findAll,
  findById,
  findStoreIdById,
  findByStoreIdForOwner,
  create,
  update,
  setActive,
  countByStoreId
};
