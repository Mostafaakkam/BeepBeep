const pool = require('../config/database');

const findByUserId = async (userId) => {
  const [carts] = await pool.execute(
    'SELECT id, user_id, store_id, created_at, updated_at FROM carts WHERE user_id = ?',
    [userId]
  );
  
  if (carts.length === 0) return null;
  
  const cart = carts[0];
  
  // Get cart items with product and variant information.
  //
  // Fixed bug (found while testing this feature, pre-existing and unrelated
  // to the single-store work): this query used to LEFT JOIN product_images
  // directly, a one-to-many relationship (a product can have 2-3 images --
  // see seed.js) with no GROUP BY/aggregation, so a cart item for a product
  // with N images fanned out into N duplicate rows here, corrupting
  // items_count and the item list itself. Replaced the join with a
  // correlated subquery that picks a single representative image per
  // product (lowest id = first image inserted, matching the seed's
  // "first image is primary" convention and the same ORDER BY id ASC used
  // in productRepository.js for product images) -- one row per cart item
  // again, same column name (image_path), so no response-shape change.
  const [items] = await pool.execute(
    `SELECT ci.id, ci.quantity, ci.price, ci.created_at,
            pv.id as variant_id, pv.color, pv.size, pv.price as variant_price, pv.stock,
            p.id as product_id, p.name as product_name, p.description as product_description,
            (SELECT pi.image_path FROM product_images pi
             WHERE pi.product_id = p.id ORDER BY pi.id ASC LIMIT 1) as image_path,
            s.name as store_name, s.address as store_address
     FROM cart_items ci
     JOIN product_variants pv ON ci.variant_id = pv.id
     JOIN products p ON pv.product_id = p.id
     LEFT JOIN stores s ON p.store_id = s.id
     WHERE ci.cart_id = ?
     ORDER BY ci.created_at DESC`,
    [cart.id]
  );
  
  cart.items = items;
  return cart;
};

const createCart = async (userId) => {
  const [result] = await pool.execute(
    'INSERT INTO carts (user_id, created_at, updated_at) VALUES (?, NOW(), NOW())',
    [userId]
  );

  // store_id included so a freshly created cart's store_id is `null`
  // (matching findByUserId's shape and the DB default), not `undefined` --
  // cartService's single-store check relies on that column being present
  // and normalized to null on an empty cart.
  const [newCart] = await pool.execute(
    'SELECT id, user_id, store_id, created_at, updated_at FROM carts WHERE id = ?',
    [result.insertId]
  );

  return newCart[0];
};

const findOrCreateCart = async (userId) => {
  let cart = await findByUserId(userId);
  if (!cart) {
    cart = await createCart(userId);
  }
  return cart;
};

const addItem = async (cartId, variantId, quantity, price) => {
  // Check if item already exists
  const [existing] = await pool.execute(
    'SELECT id, quantity FROM cart_items WHERE cart_id = ? AND variant_id = ?',
    [cartId, variantId]
  );
  
  if (existing.length > 0) {
    // Update existing item quantity
    const newQuantity = existing[0].quantity + quantity;
    await pool.execute(
      'UPDATE cart_items SET quantity = ?, updated_at = NOW() WHERE id = ?',
      [newQuantity, existing[0].id]
    );
    return existing[0].id;
  } else {
    // Create new cart item
    const [result] = await pool.execute(
      'INSERT INTO cart_items (cart_id, variant_id, quantity, price, created_at, updated_at) VALUES (?, ?, ?, ?, NOW(), NOW())',
      [cartId, variantId, quantity, price]
    );
    return result.insertId;
  }
};

// Single-Store Cart Rule: once a cart has no items left, it is no longer
// "for" any particular store, so its store_id must be reset to NULL --
// otherwise a later add-to-cart on an empty-but-still-store-tagged cart
// would be incorrectly rejected as a store mismatch against a store the
// cart no longer actually contains anything from.
const resetStoreIdIfEmpty = async (cartId) => {
  const [rows] = await pool.execute(
    'SELECT COUNT(*) as itemCount FROM cart_items WHERE cart_id = ?',
    [cartId]
  );
  if (rows[0].itemCount === 0) {
    await pool.execute(
      'UPDATE carts SET store_id = NULL, updated_at = NOW() WHERE id = ?',
      [cartId]
    );
  }
};

const updateItemQuantity = async (cartItemId, userId, quantity) => {
  // Verify user owns this cart item
  const [verify] = await pool.execute(
    `SELECT ci.id, ci.cart_id FROM cart_items ci
     JOIN carts c ON ci.cart_id = c.id
     WHERE ci.id = ? AND c.user_id = ?`,
    [cartItemId, userId]
  );

  if (verify.length === 0) {
    throw new Error('Cart item not found or access denied');
  }

  if (quantity <= 0) {
    await pool.execute('DELETE FROM cart_items WHERE id = ?', [cartItemId]);
    await resetStoreIdIfEmpty(verify[0].cart_id);
  } else {
    await pool.execute(
      'UPDATE cart_items SET quantity = ?, updated_at = NOW() WHERE id = ?',
      [quantity, cartItemId]
    );
  }
};

const removeItem = async (cartItemId, userId) => {
  // Verify user owns this cart item
  const [verify] = await pool.execute(
    `SELECT ci.id, ci.cart_id FROM cart_items ci
     JOIN carts c ON ci.cart_id = c.id
     WHERE ci.id = ? AND c.user_id = ?`,
    [cartItemId, userId]
  );

  if (verify.length === 0) {
    throw new Error('Cart item not found or access denied');
  }

  await pool.execute('DELETE FROM cart_items WHERE id = ?', [cartItemId]);
  await resetStoreIdIfEmpty(verify[0].cart_id);
};

const clearCart = async (userId) => {
  const [cart] = await pool.execute(
    'SELECT id FROM carts WHERE user_id = ?',
    [userId]
  );

  if (cart.length > 0) {
    await pool.execute('DELETE FROM cart_items WHERE cart_id = ?', [cart[0].id]);
    await pool.execute(
      'UPDATE carts SET store_id = NULL, updated_at = NOW() WHERE id = ?',
      [cart[0].id]
    );
  }
};

// Single-Store Cart Rule: assigns a store to a cart that doesn't have one
// yet (first item being added to an empty cart).
const setCartStoreId = async (cartId, storeId) => {
  await pool.execute(
    'UPDATE carts SET store_id = ?, updated_at = NOW() WHERE id = ?',
    [storeId, cartId]
  );
};

// Single-Store Cart Rule: atomic "clear current cart, then add this item
// from the new store" operation, backing POST /api/cart/switch-store. Runs
// as a single transaction so a customer confirming "clear and switch
// stores" can never end up with a half-cleared cart (e.g. clear succeeds,
// add fails) from a partial failure.
const switchStore = async (cartId, variantId, quantity, price, storeId) => {
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    await connection.execute('DELETE FROM cart_items WHERE cart_id = ?', [cartId]);

    const [result] = await connection.execute(
      'INSERT INTO cart_items (cart_id, variant_id, quantity, price, created_at, updated_at) VALUES (?, ?, ?, ?, NOW(), NOW())',
      [cartId, variantId, quantity, price]
    );

    await connection.execute(
      'UPDATE carts SET store_id = ?, updated_at = NOW() WHERE id = ?',
      [storeId, cartId]
    );

    await connection.commit();

    return result.insertId;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};

const getVariantWithStock = async (variantId) => {
  const [variants] = await pool.execute(
    'SELECT id, product_id, color, size, price, stock FROM product_variants WHERE id = ?',
    [variantId]
  );
  return variants[0] || null;
};

const getProductInfo = async (productId) => {
  const [products] = await pool.execute(
    'SELECT id, name, store_id FROM products WHERE id = ?',
    [productId]
  );
  return products[0] || null;
};

module.exports = {
  findByUserId,
  createCart,
  findOrCreateCart,
  addItem,
  updateItemQuantity,
  removeItem,
  clearCart,
  getVariantWithStock,
  getProductInfo,
  setCartStoreId,
  switchStore
};
