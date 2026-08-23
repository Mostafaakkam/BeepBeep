const orderService = require('../services/orderService');

const getOrders = async (req, res) => {
  try {
    const userId = req.user.userId;
    const orders = await orderService.getOrders(userId);
    
    res.status(200).json({
      success: true,
      message: 'Orders retrieved successfully',
      data: orders
    });
  } catch (error) {
    console.error('Get orders error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve orders'
    });
  }
};

const getOrderById = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    
    const order = await orderService.getOrderById(parseInt(id), userId);
    
    res.status(200).json({
      success: true,
      message: 'Order retrieved successfully',
      data: order
    });
  } catch (error) {
    if (error.code === 'ORDER_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    console.error('Get order error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve order'
    });
  }
};

const createOrder = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { customer_name, customer_phone, delivery_address } = req.body;
    
    const result = await orderService.createOrder(userId, {
      customer_name,
      customer_phone,
      delivery_address
    });
    
    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      data: result
    });
  } catch (error) {
    if (error.code === 'MISSING_FIELDS') {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }
    
    if (error.code === 'INVALID_PHONE') {
      return res.status(400).json({
        success: false,
        message: 'Invalid phone number'
      });
    }
    
    if (error.code === 'INVALID_ADDRESS') {
      return res.status(400).json({
        success: false,
        message: 'Address is too short'
      });
    }

    // Single-Store Order Rule: checkout-time defensive validation tripped
    // (should not normally happen given cartService's add-time enforcement;
    // see orderRepository.createOrder for where this is derived).
    if (error.code === 'MULTI_STORE_CART') {
      return res.status(400).json({
        success: false,
        message: 'Cart contains products from multiple stores',
        code: 'MULTI_STORE_CART'
      });
    }

    if (error.message === 'Cart is empty') {
      return res.status(400).json({
        success: false,
        message: 'Cart is empty'
      });
    }
    
    if (error.message.startsWith('Insufficient stock')) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }

    console.error('Create order error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to create order'
    });
  }
};

const cancelOrder = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    
    await orderService.cancelOrder(parseInt(id), userId);
    
    res.status(200).json({
      success: true,
      message: 'Order cancelled successfully'
    });
  } catch (error) {
    if (error.code === 'ORDER_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }
    
    if (error.code === 'INVALID_STATUS') {
      return res.status(400).json({
        success: false,
        message: 'Order cannot be cancelled in current status'
      });
    }

    console.error('Cancel order error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to cancel order'
    });
  }
};

module.exports = {
  getOrders,
  getOrderById,
  createOrder,
  cancelOrder
};
