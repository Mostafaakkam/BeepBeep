const orderRepository = require('../repositories/orderRepository');

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
  createOrder,
  cancelOrder
};
