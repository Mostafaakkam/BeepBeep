const cartService = require('../services/cartService');

const getCart = async (req, res) => {
  try {
    const userId = req.user.userId;
    const cart = await cartService.getCart(userId);
    
    res.status(200).json({
      success: true,
      message: 'Cart retrieved successfully',
      data: cart
    });
  } catch (error) {
    console.error('Get cart error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve cart'
    });
  }
};

const addItem = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { product_id, variant_id, quantity } = req.body;
    
    const result = await cartService.addItem(userId, product_id, variant_id, quantity);
    
    res.status(201).json({
      success: true,
      message: 'Item added to cart successfully',
      data: result
    });
  } catch (error) {
    if (error.code === 'INVALID_INPUT') {
      return res.status(400).json({
        success: false,
        message: 'Invalid input data'
      });
    }
    
    if (error.code === 'PRODUCT_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }
    
    if (error.code === 'VARIANT_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Variant not found'
      });
    }
    
    if (error.code === 'INVALID_VARIANT') {
      return res.status(400).json({
        success: false,
        message: 'Variant does not belong to this product'
      });
    }
    
    if (error.code === 'INSUFFICIENT_STOCK') {
      return res.status(400).json({
        success: false,
        message: 'Insufficient stock available'
      });
    }

    // Single-Store Cart Rule: machine-readable conflict response so the
    // Flutter client can show a "clear cart and switch stores?" confirmation
    // instead of a generic error. `code` and `data` are additive fields on
    // top of the existing success/message response shape.
    if (error.code === 'STORE_MISMATCH') {
      return res.status(409).json({
        success: false,
        message: 'Your cart contains items from another store',
        code: 'STORE_MISMATCH',
        data: error.data
      });
    }

    console.error('Add item error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to add item to cart'
    });
  }
};

const switchStore = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { product_id, variant_id, quantity } = req.body;

    const result = await cartService.switchStore(userId, product_id, variant_id, quantity);

    res.status(200).json({
      success: true,
      message: 'Cart switched to the new store successfully',
      data: result
    });
  } catch (error) {
    if (error.code === 'INVALID_INPUT') {
      return res.status(400).json({
        success: false,
        message: 'Invalid input data'
      });
    }

    if (error.code === 'PRODUCT_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    if (error.code === 'VARIANT_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Variant not found'
      });
    }

    if (error.code === 'INVALID_VARIANT') {
      return res.status(400).json({
        success: false,
        message: 'Variant does not belong to this product'
      });
    }

    if (error.code === 'INSUFFICIENT_STOCK') {
      return res.status(400).json({
        success: false,
        message: 'Insufficient stock available'
      });
    }

    console.error('Switch cart store error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to switch cart store'
    });
  }
};

const updateItemQuantity = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    const { quantity } = req.body;
    
    await cartService.updateItemQuantity(userId, parseInt(id), quantity);
    
    res.status(200).json({
      success: true,
      message: 'Cart item updated successfully'
    });
  } catch (error) {
    if (error.code === 'INVALID_INPUT') {
      return res.status(400).json({
        success: false,
        message: 'Invalid input data'
      });
    }
    
    if (error.code === 'INVALID_QUANTITY') {
      return res.status(400).json({
        success: false,
        message: 'Quantity cannot be negative'
      });
    }
    
    if (error.message === 'Cart item not found or access denied') {
      return res.status(404).json({
        success: false,
        message: 'Cart item not found'
      });
    }

    console.error('Update item error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to update cart item'
    });
  }
};

const removeItem = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    
    await cartService.removeItem(userId, parseInt(id));
    
    res.status(200).json({
      success: true,
      message: 'Cart item removed successfully'
    });
  } catch (error) {
    if (error.code === 'INVALID_INPUT') {
      return res.status(400).json({
        success: false,
        message: 'Invalid cart item ID'
      });
    }
    
    if (error.message === 'Cart item not found or access denied') {
      return res.status(404).json({
        success: false,
        message: 'Cart item not found'
      });
    }

    console.error('Remove item error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to remove cart item'
    });
  }
};

const clearCart = async (req, res) => {
  try {
    const userId = req.user.userId;
    await cartService.clearCart(userId);
    
    res.status(200).json({
      success: true,
      message: 'Cart cleared successfully'
    });
  } catch (error) {
    console.error('Clear cart error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to clear cart'
    });
  }
};

module.exports = {
  getCart,
  addItem,
  switchStore,
  updateItemQuantity,
  removeItem,
  clearCart
};
