const cartRepository = require('../repositories/cartRepository');

const getCart = async (userId) => {
  try {
    const cart = await cartRepository.findByUserId(userId);
    if (!cart) {
      return {
        items: [],
        items_count: 0,
        subtotal: 0,
        total: 0
      };
    }
    
    let subtotal = 0;
    const processedItems = cart.items.map(item => {
      const itemSubtotal = item.quantity * item.price;
      subtotal += itemSubtotal;
      
      return {
        id: item.id,
        product: {
          id: item.product_id,
          name: item.product_name,
          description: item.product_description,
          image: item.image_path,
          store_name: item.store_name,
          store_address: item.store_address
        },
        variant: {
          id: item.variant_id,
          color: item.color,
          size: item.size,
          price: item.variant_price,
          stock: item.stock
        },
        quantity: item.quantity,
        unit_price: item.price,
        subtotal: itemSubtotal
      };
    });
    
    return {
      items: processedItems,
      items_count: processedItems.length,
      subtotal: subtotal,
      total: subtotal
    };
  } catch (error) {
    console.error('Error fetching cart:', error);
    throw new Error('Failed to fetch cart');
  }
};

const addItem = async (userId, productId, variantId, quantity) => {
  try {
    // Validate inputs
    if (!productId || !variantId || !quantity || quantity <= 0) {
      const error = new Error('Invalid input data');
      error.code = 'INVALID_INPUT';
      throw error;
    }
    
    // Check if product exists
    const product = await cartRepository.getProductInfo(productId);
    if (!product) {
      const error = new Error('Product not found');
      error.code = 'PRODUCT_NOT_FOUND';
      throw error;
    }
    
    // Check if variant exists and belongs to the product
    const variant = await cartRepository.getVariantWithStock(variantId);
    if (!variant) {
      const error = new Error('Variant not found');
      error.code = 'VARIANT_NOT_FOUND';
      throw error;
    }
    
    if (variant.product_id !== productId) {
      const error = new Error('Variant does not belong to this product');
      error.code = 'INVALID_VARIANT';
      throw error;
    }
    
    // Check stock availability
    if (variant.stock < quantity) {
      const error = new Error('Insufficient stock');
      error.code = 'INSUFFICIENT_STOCK';
      throw error;
    }
    
    // Get or create user's cart
    const cart = await cartRepository.findOrCreateCart(userId);
    
    // Add item to cart
    const cartItemId = await cartRepository.addItem(
      cart.id,
      variantId,
      quantity,
      variant.price
    );
    
    return { cartItemId };
  } catch (error) {
    console.error('Error adding item to cart:', error);
    throw error;
  }
};

const updateItemQuantity = async (userId, cartItemId, quantity) => {
  try {
    if (!cartItemId || quantity === undefined || quantity === null) {
      const error = new Error('Invalid input data');
      error.code = 'INVALID_INPUT';
      throw error;
    }
    
    if (quantity < 0) {
      const error = new Error('Quantity cannot be negative');
      error.code = 'INVALID_QUANTITY';
      throw error;
    }
    
    await cartRepository.updateItemQuantity(cartItemId, userId, quantity);
  } catch (error) {
    console.error('Error updating cart item:', error);
    throw error;
  }
};

const removeItem = async (userId, cartItemId) => {
  try {
    if (!cartItemId) {
      const error = new Error('Invalid cart item ID');
      error.code = 'INVALID_INPUT';
      throw error;
    }
    
    await cartRepository.removeItem(cartItemId, userId);
  } catch (error) {
    console.error('Error removing cart item:', error);
    throw error;
  }
};

const clearCart = async (userId) => {
  try {
    await cartRepository.clearCart(userId);
  } catch (error) {
    console.error('Error clearing cart:', error);
    throw new Error('Failed to clear cart');
  }
};

module.exports = {
  getCart,
  addItem,
  updateItemQuantity,
  removeItem,
  clearCart
};
