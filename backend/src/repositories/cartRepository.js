const pool = require('../config/database');

const findByUserId = async (userId) => {
  const [carts] = await pool.execute(
    'SELECT id, user_id, created_at, updated_at FROM carts WHERE user_id = ?',
    [userId]
  );
  
  if (carts.length === 0) return null;
  
  const cart = carts[0];
  
  // Get cart items with product and variant information
  const [items] = await pool.execute(
    `SELECT ci.id, ci.quantity, ci.price, ci.created_at,
            pv.id as variant_id, pv.color, pv.size, pv.price as variant_price, pv.stock,
            p.id as product_id, p.name as product_name, p.description as product_description,
            pi.image_path,
            s.name as store_name, s.address as store_address
     FROM cart_items ci
     JOIN product_variants pv ON ci.variant_id = pv.id
     JOIN products p ON pv.product_id = p.id
     LEFT JOIN product_images pi ON p.id = pi.product_id
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
  
  const [newCart] = await pool.execute(
    'SELECT id, user_id, created_at, updated_at FROM carts WHERE id = ?',
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

const updateItemQuantity = async (cartItemId, userId, quantity) => {
  // Verify user owns this cart item
  const [verify] = await pool.execute(
    `SELECT ci.id FROM cart_items ci
     JOIN carts c ON ci.cart_id = c.id
     WHERE ci.id = ? AND c.user_id = ?`,
    [cartItemId, userId]
  );
  
  if (verify.length === 0) {
    throw new Error('Cart item not found or access denied');
  }
  
  if (quantity <= 0) {
    await pool.execute('DELETE FROM cart_items WHERE id = ?', [cartItemId]);
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
    `SELECT ci.id FROM cart_items ci
     JOIN carts c ON ci.cart_id = c.id
     WHERE ci.id = ? AND c.user_id = ?`,
    [cartItemId, userId]
  );
  
  if (verify.length === 0) {
    throw new Error('Cart item not found or access denied');
  }
  
  await pool.execute('DELETE FROM cart_items WHERE id = ?', [cartItemId]);
};

const clearCart = async (userId) => {
  const [cart] = await pool.execute(
    'SELECT id FROM carts WHERE user_id = ?',
    [userId]
  );
  
  if (cart.length > 0) {
    await pool.execute('DELETE FROM cart_items WHERE cart_id = ?', [cart[0].id]);
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
  getProductInfo
};
