const pool = require('../config/database');

const DELIVERY_FEE = 5.00; // Configurable delivery fee for MVP

const findByUserId = async (userId) => {
  const [orders] = await pool.execute(
    `SELECT id, user_id, status, payment_method, payment_status, subtotal, delivery_fee, total, 
            customer_name, customer_phone, delivery_address, created_at, updated_at
     FROM orders 
     WHERE user_id = ? 
     ORDER BY created_at DESC`,
    [userId]
  );
  return orders;
};

const findById = async (id, userId) => {
  const [orders] = await pool.execute(
    `SELECT id, user_id, status, payment_method, payment_status, subtotal, delivery_fee, total, 
            customer_name, customer_phone, delivery_address, created_at, updated_at
     FROM orders 
     WHERE id = ? AND user_id = ?`,
    [id, userId]
  );
  
  if (orders.length === 0) return null;
  
  const order = orders[0];
  
  // Get order items
  const [items] = await pool.execute(
    `SELECT oi.id, oi.product_id, oi.variant_id, oi.product_name, oi.variant_name, 
            oi.variant_color, oi.variant_size, oi.quantity, oi.unit_price, oi.subtotal,
            p.name as store_name, p.address as store_address
     FROM order_items oi
     JOIN products p ON oi.product_id = p.id
     WHERE oi.order_id = ?
     ORDER BY oi.id ASC`,
    [id]
  );
  
  order.items = items;
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
              p.name as product_name
       FROM cart_items ci
       JOIN product_variants pv ON ci.variant_id = pv.id
       JOIN products p ON pv.product_id = p.id
       WHERE ci.cart_id = ?`,
      [cartId]
    );
    
    if (cartItems.length === 0) {
      throw new Error('Cart is empty');
    }
    
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
      `INSERT INTO orders (user_id, status, payment_method, payment_status, subtotal, delivery_fee, total, 
                             customer_name, customer_phone, delivery_address, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [
        userId,
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
      await connection.execute(
        `INSERT INTO order_items (order_id, product_id, variant_id, product_name, variant_name, 
                                variant_color, variant_size, quantity, unit_price, subtotal, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
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

module.exports = {
  findByUserId,
  findById,
  createOrder,
  cancelOrder,
  DELIVERY_FEE
};
