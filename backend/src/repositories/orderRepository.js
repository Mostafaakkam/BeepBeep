const pool = require('../config/database');

const DELIVERY_FEE = 5.00; // Configurable delivery fee for MVP

const findByUserId = async (userId) => {
  const [orders] = await pool.execute(
    `SELECT id, user_id, store_id, status, payment_method, payment_status, subtotal, delivery_fee, total,
            customer_name, customer_phone, delivery_address, created_at, updated_at
     FROM orders
     WHERE user_id = ?
     ORDER BY created_at DESC`,
    [userId]
  );
  return orders;
};

// Fixed bug (previously found by audit): this query used to join order_items
// to `products` and select `p.name AS store_name, p.address AS store_address`
// -- `products` has no `address` column, and `p.name` is the product's name,
// not the store's, so this threw "Unknown column 'p.address'" on every call.
// Now resolves the store once via the order's own store_id (Single-Store
// Order Rule guarantees every item in the order shares that one store),
// instead of per item -- both correct and cheaper than the old per-item join
// would have been even if it had used the right table. Response shape is
// unchanged: every item still carries store_name/store_address, so no
// Flutter changes are required for this fix.
const findById = async (id, userId) => {
  const [orders] = await pool.execute(
    `SELECT id, user_id, store_id, status, payment_method, payment_status, subtotal, delivery_fee, total,
            customer_name, customer_phone, delivery_address, created_at, updated_at
     FROM orders
     WHERE id = ? AND user_id = ?`,
    [id, userId]
  );

  if (orders.length === 0) return null;

  const order = orders[0];

  // Resolve store info once via orders.store_id, not per item.
  let storeName = null;
  let storeAddress = null;
  if (order.store_id) {
    const [stores] = await pool.execute(
      'SELECT name, address FROM stores WHERE id = ?',
      [order.store_id]
    );
    if (stores.length > 0) {
      storeName = stores[0].name;
      storeAddress = stores[0].address;
    }
  }
  // order.store_id is NULL for legacy orders created before this migration
  // (see database/migrations/002_add_roles_ownership_single_store.sql) --
  // those simply come back with store_name/store_address = null instead of
  // erroring, which is strictly better than the previous hard SQL error.

  // Get order items
  const [items] = await pool.execute(
    `SELECT oi.id, oi.product_id, oi.variant_id, oi.product_name, oi.variant_name,
            oi.variant_color, oi.variant_size, oi.quantity, oi.unit_price, oi.subtotal
     FROM order_items oi
     WHERE oi.order_id = ?
     ORDER BY oi.id ASC`,
    [id]
  );

  order.items = items.map((item) => ({
    ...item,
    store_name: storeName,
    store_address: storeAddress
  }));

  return order;
};

const createOrder = async (orderData, userId) => {
  const connection = await pool.getConnection();
  
  try {
    await connection.beginTransaction();
    
    // Get user's cart
    const [carts] = await connection.execute(
      'SELECT id FROM carts WHERE user_id = ?',
      [userId]
    );
    
    if (carts.length === 0) {
      throw new Error('Cart is empty');
    }
    
    const cartId = carts[0].id;
    
    // Get cart items with product and variant information
    const [cartItems] = await connection.execute(
      `SELECT ci.id, ci.variant_id, ci.quantity, ci.price,
              pv.product_id, pv.color, pv.size, pv.price as variant_price, pv.stock,
              p.name as product_name, p.store_id
       FROM cart_items ci
       JOIN product_variants pv ON ci.variant_id = pv.id
       JOIN products p ON pv.product_id = p.id
       WHERE ci.cart_id = ?`,
      [cartId]
    );

    if (cartItems.length === 0) {
      throw new Error('Cart is empty');
    }

    // Single-Store Order Rule: final defensive validation before the order
    // becomes permanent. cartService.addItem already prevents a cart from
    // mixing stores at add-time, and carts.store_id records the cart's one
    // store -- but this check derives the store directly from the cart's
    // actual items (the source of truth) rather than trusting that column,
    // so checkout stays safe even against an edge case that slipped past
    // add-time enforcement. The resulting store_id is never taken from the
    // client -- orderData carries no store_id at all (see orderService.js /
    // orderController.js), it is derived here, server-side, from the cart.
    const distinctStoreIds = [...new Set(cartItems.map((item) => item.store_id))];
    if (distinctStoreIds.length > 1) {
      const error = new Error('Cart contains products from multiple stores');
      error.code = 'MULTI_STORE_CART';
      throw error;
    }
    const storeId = distinctStoreIds[0];

    // Validate stock and calculate subtotal
    let subtotal = 0;
    for (const item of cartItems) {
      if (item.stock < item.quantity) {
        throw new Error(`Insufficient stock for ${item.product_name}`);
      }
      subtotal += item.quantity * item.variant_price;
    }

    const deliveryFee = DELIVERY_FEE;
    const total = subtotal + deliveryFee;

    // Create order
    const [orderResult] = await connection.execute(
      `INSERT INTO orders (user_id, store_id, status, payment_method, payment_status, subtotal, delivery_fee, total,
                             customer_name, customer_phone, delivery_address, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [
        userId,
        storeId,
        'pending',
        'cash_on_delivery',
        'pending',
        subtotal,
        deliveryFee,
        total,
        orderData.customer_name,
        orderData.customer_phone,
        orderData.delivery_address
      ]
    );
    
    const orderId = orderResult.insertId;
    
    // Create order items with snapshot data
    for (const item of cartItems) {
      const itemSubtotal = item.quantity * item.variant_price;
      // NOTE: fixed a separate, pre-existing bug found while implementing
      // this feature (distinct from the documented findById() products.address
      // bug) -- this INSERT declared 11 columns but its VALUES clause only
      // had 10 placeholders (9 `?` + NOW()), one short of the 10 dynamic
      // values actually being passed below. MySQL/MariaDB rejects this with
      // ER_WRONG_VALUE_COUNT_ON_ROW on every call, meaning checkout
      // (POST /api/orders) could never have succeeded even before this
      // feature. Left unfixed, no order could ever be created, which would
      // make the single-store-order work in this same function untestable
      // and non-functional. Fix is the single missing `?` below; the values
      // array was already correct.
      await connection.execute(
        `INSERT INTO order_items (order_id, product_id, variant_id, product_name, variant_name,
                                variant_color, variant_size, quantity, unit_price, subtotal, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
        [
          orderId,
          item.product_id,
          item.variant_id,
          item.product_name,
          `${item.color || ''} ${item.size || ''}`.trim(),
          item.color,
          item.size,
          item.quantity,
          item.variant_price,
          itemSubtotal
        ]
      );
      
      // Decrease stock
      await connection.execute(
        'UPDATE product_variants SET stock = stock - ? WHERE id = ?',
        [item.quantity, item.variant_id]
      );
    }
    
    // Clear cart
    await connection.execute('DELETE FROM cart_items WHERE cart_id = ?', [cartId]);
    
    await connection.commit();
    
    return { orderId, total };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};

const cancelOrder = async (orderId, userId) => {
  const connection = await pool.getConnection();
  
  try {
    await connection.beginTransaction();
    
    // Get order
    const [orders] = await connection.execute(
      'SELECT id, status FROM orders WHERE id = ? AND user_id = ?',
      [orderId, userId]
    );
    
    if (orders.length === 0) {
      throw new Error('Order not found');
    }
    
    const order = orders[0];
    
    // Only allow cancellation for pending orders
    if (order.status !== 'pending') {
      throw new Error('Order cannot be cancelled in current status');
    }
    
    // Update order status
    await connection.execute(
      'UPDATE orders SET status = ?, updated_at = NOW() WHERE id = ?',
      ['cancelled', orderId]
    );
    
    // Restore stock for cancelled order items
    const [orderItems] = await connection.execute(
      'SELECT variant_id, quantity FROM order_items WHERE order_id = ?',
      [orderId]
    );
    
    for (const item of orderItems) {
      await connection.execute(
        'UPDATE product_variants SET stock = stock + ? WHERE id = ?',
        [item.quantity, item.variant_id]
      );
    }
    
    await connection.commit();
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};

// Added for Store Owner order visibility (exercises requireStoreOwnership --
// see routes/storeRoutes.js). Deliberately does NOT accept/trust a store_id
// from the caller beyond what the authorization middleware has already
// resolved and verified server-side; the controller passes through only the
// store id the ownership middleware attached to req.store.
const findByStoreId = async (storeId, status) => {
  const params = [storeId];
  let query = `SELECT id, user_id, store_id, status, payment_method, payment_status, subtotal, delivery_fee, total,
                      customer_name, customer_phone, delivery_address, created_at, updated_at
               FROM orders
               WHERE store_id = ?`;
  if (status) {
    query += ' AND status = ?';
    params.push(status);
  }
  query += ' ORDER BY created_at DESC';

  const [orders] = await pool.execute(query, params);
  return orders;
};

module.exports = {
  findByUserId,
  findById,
  findByStoreId,
  createOrder,
  cancelOrder,
  DELIVERY_FEE
};
