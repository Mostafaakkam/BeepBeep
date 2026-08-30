const orderRepository = require('../repositories/orderRepository');

// Store Owner Dashboard: the single source of truth for valid order-status
// transitions. Forward-only, one step at a time -- no skipping ('pending'
// straight to 'shipped'), no going backward ('delivered' back to
// 'preparing'). 'pending' -> 'cancelled' is deliberately NOT here: that
// remains exclusively on the existing customer-only
// PATCH /api/orders/:id/cancel path (orderRepository.cancelOrder) and is
// never a target status the store owner can set through this map. Both
// 'delivered' and 'cancelled' are terminal (no further transitions).
const VALID_TRANSITIONS = {
  pending: ['confirmed'],
  confirmed: ['preparing'],
  preparing: ['shipped'],
  shipped: ['delivered'],
  delivered: [],
  cancelled: []
};

const getOrders = async (userId) => {
  try {
    const orders = await orderRepository.findByUserId(userId);
    return orders;
  } catch (error) {
    console.error('Error fetching orders:', error);
    throw new Error('Failed to fetch orders');
  }
};

const getOrderById = async (orderId, userId) => {
  try {
    const order = await orderRepository.findById(orderId, userId);
    if (!order) {
      const error = new Error('Order not found');
      error.code = 'ORDER_NOT_FOUND';
      throw error;
    }
    return order;
  } catch (error) {
    console.error('Error fetching order:', error);
    throw error;
  }
};

const createOrder = async (userId, orderData) => {
  try {
    // Validate required fields
    if (!orderData.customer_name || !orderData.customer_phone || !orderData.delivery_address) {
      const error = new Error('Missing required fields');
      error.code = 'MISSING_FIELDS';
      throw error;
    }
    
    // Validate phone number format (basic validation)
    const phoneRegex = /^\+?[\d\s-]{10,}$/;
    if (!phoneRegex.test(orderData.customer_phone)) {
      const error = new Error('Invalid phone number');
      error.code = 'INVALID_PHONE';
      throw error;
    }
    
    // Validate address length
    if (orderData.delivery_address.length < 10) {
      const error = new Error('Address is too short');
      error.code = 'INVALID_ADDRESS';
      throw error;
    }
    
    const result = await orderRepository.createOrder(orderData, userId);
    return result;
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error creating order:', error);
    throw new Error('Failed to create order');
  }
};

// Added for Store Owner order visibility. `storeId` here is not
// client-supplied -- it's the value the requireStoreOwnership middleware
// already resolved and verified against req.user before this is ever
// called (see storeController.getStoreOrders / routes/storeRoutes.js).
const getOrdersForStore = async (storeId, status) => {
  try {
    const orders = await orderRepository.findByStoreId(storeId, status);
    return orders;
  } catch (error) {
    console.error('Error fetching store orders:', error);
    throw new Error('Failed to fetch store orders');
  }
};

// Store Owner Dashboard: order detail scoped to a store. storeId is always
// pre-verified by requireStoreOwnership -- see
// storeController.getStoreOrderDetail.
const getOrderForStore = async (orderId, storeId) => {
  try {
    const order = await orderRepository.findByIdForStore(orderId, storeId);
    if (!order) {
      const error = new Error('Order not found');
      error.code = 'ORDER_NOT_FOUND';
      throw error;
    }
    return order;
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error fetching store order:', error);
    throw new Error('Failed to fetch order');
  }
};

// Store Owner Dashboard: validated order-status update. storeId is always
// pre-verified by requireStoreOwnership -- an owner can only ever reach this
// for an order that already belongs to their own store (or as admin). This
// function -- not the repository, not the controller -- is the one place
// that decides whether a transition is legal, using VALID_TRANSITIONS above.
const updateOrderStatus = async (orderId, storeId, newStatus) => {
  try {
    if (!Object.prototype.hasOwnProperty.call(VALID_TRANSITIONS, newStatus)) {
      const error = new Error('Invalid status value');
      error.code = 'INVALID_STATUS';
      throw error;
    }

    // The store owner may only ever move an order forward through the
    // fulfillment flow. Cancellation is customer-only (see VALID_TRANSITIONS
    // above) and is rejected here just like any other disallowed target.
    if (!['confirmed', 'preparing', 'shipped', 'delivered'].includes(newStatus)) {
      const error = new Error('Store owners cannot set this status');
      error.code = 'INVALID_STATUS_TRANSITION';
      throw error;
    }

    const order = await orderRepository.findByIdForStore(orderId, storeId);
    if (!order) {
      const error = new Error('Order not found');
      error.code = 'ORDER_NOT_FOUND';
      throw error;
    }

    const allowedNextStatuses = VALID_TRANSITIONS[order.status] || [];
    if (!allowedNextStatuses.includes(newStatus)) {
      const error = new Error(
        `Cannot transition order from '${order.status}' to '${newStatus}'`
      );
      error.code = 'INVALID_STATUS_TRANSITION';
      throw error;
    }

    // updateStatus's own WHERE status = ? guards against a race where the
    // order's status changed between the read above and this write.
    const updated = await orderRepository.updateStatus(orderId, storeId, newStatus, order.status);
    if (!updated) {
      const error = new Error('Order status changed before this update could be applied');
      error.code = 'INVALID_STATUS_TRANSITION';
      throw error;
    }

    return { success: true, status: newStatus };
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error updating order status:', error);
    throw new Error('Failed to update order status');
  }
};

const cancelOrder = async (orderId, userId) => {
  try {
    await orderRepository.cancelOrder(orderId, userId);
  } catch (error) {
    if (error.message === 'Order not found') {
      const notFoundError = new Error('Order not found');
      notFoundError.code = 'ORDER_NOT_FOUND';
      throw notFoundError;
    }
    if (error.message === 'Order cannot be cancelled in current status') {
      const statusError = new Error('Order cannot be cancelled in current status');
      statusError.code = 'INVALID_STATUS';
      throw statusError;
    }
    console.error('Error cancelling order:', error);
    throw new Error('Failed to cancel order');
  }
};

module.exports = {
  getOrders,
  getOrderById,
  getOrdersForStore,
  getOrderForStore,
  updateOrderStatus,
  createOrder,
  cancelOrder
};
