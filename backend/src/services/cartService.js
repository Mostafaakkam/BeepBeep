const cartRepository = require('../repositories/cartRepository');
const storeRepository = require('../repositories/storeRepository');

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
      // Same root cause as the earlier Product Details fix: cart_items.price
      // and product_variants.price are DECIMAL columns, which mysql2 returns
      // as JS strings (no decimalNumbers: true on the pool -- see
      // config/database.js). `item.quantity * item.price` below happened to
      // look fine because JS's `*` operator coerces a numeric string, so
      // itemSubtotal/subtotal/total were always real numbers -- but
      // unit_price and variant.price were passed straight through as the
      // raw string, and Flutter's CartItem.fromJson/ProductVariant.fromJson
      // both do `(json[...] as num).toDouble()`, which throws on a String.
      // That is the actual, confirmed (live-tested) cause of the Cart page's
      // generic error screen. Normalizing both values here, at the one place
      // they enter the cart response, fixes it at the exact point of failure
      // without touching the DB schema.
      const price = parseFloat(item.price);
      const variantPrice = parseFloat(item.variant_price);
      const itemSubtotal = item.quantity * price;
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
          price: variantPrice,
          stock: item.stock
        },
        quantity: item.quantity,
        unit_price: price,
        subtotal: itemSubtotal
      };
    });
    
    return {
      items: processedItems,
      items_count: processedItems.length,
      subtotal: subtotal,
      total: subtotal,
      store_id: cart.store_id // additive field (Single-Store Cart Rule); existing clients ignore unknown fields
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
    
    // Check stock availability. If this variant is already in the cart, the
    // existing quantity and the newly requested quantity must together fit
    // within current_stock -- checking only the requested quantity in
    // isolation would let repeated adds of the same variant exceed stock.
    const existingQuantity = await cartRepository.getExistingQuantityForVariant(userId, variantId);
    if (existingQuantity + quantity > variant.stock) {
      const error = new Error('Insufficient stock');
      error.code = 'INSUFFICIENT_STOCK';
      throw error;
    }

    // Get or create user's cart
    const cart = await cartRepository.findOrCreateCart(userId);

    // Single-Store Cart Rule: a cart may only contain products from one
    // store at a time. An empty cart (store_id IS NULL) adopts this
    // product's store; a cart already tied to a different store rejects the
    // add with a machine-readable STORE_MISMATCH error instead of silently
    // mixing stores. This check is authoritative here (server-side) --
    // Flutter's confirmation dialog is a UX convenience, not the enforcement
    // point; the API must reject a cross-store add even if a client bypasses
    // that dialog entirely.
    if (cart.store_id !== null && cart.store_id !== product.store_id) {
      const [currentStore, requestedStore] = await Promise.all([
        storeRepository.findById(cart.store_id),
        storeRepository.findById(product.store_id)
      ]);

      const error = new Error('Cart contains items from a different store');
      error.code = 'STORE_MISMATCH';
      error.data = {
        currentStore: currentStore
          ? { id: currentStore.id, name: currentStore.name }
          : { id: cart.store_id, name: null },
        requestedStore: requestedStore
          ? { id: requestedStore.id, name: requestedStore.name }
          : { id: product.store_id, name: null }
      };
      throw error;
    }

    if (cart.store_id === null) {
      await cartRepository.setCartStoreId(cart.id, product.store_id);
    }

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

// Single-Store Cart Rule: atomically clears the customer's current cart and
// adds the requested product/variant from the new store, backing the
// "clear my cart and switch stores" confirmation flow. Re-validates the
// product/variant exactly like addItem() -- this is a distinct entry point
// reachable directly via the API, so it cannot assume the client already
// did those checks.
const switchStore = async (userId, productId, variantId, quantity) => {
  try {
    if (!productId || !variantId || !quantity || quantity <= 0) {
      const error = new Error('Invalid input data');
      error.code = 'INVALID_INPUT';
      throw error;
    }

    const product = await cartRepository.getProductInfo(productId);
    if (!product) {
      const error = new Error('Product not found');
      error.code = 'PRODUCT_NOT_FOUND';
      throw error;
    }

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

    if (variant.stock < quantity) {
      const error = new Error('Insufficient stock');
      error.code = 'INSUFFICIENT_STOCK';
      throw error;
    }

    const cart = await cartRepository.findOrCreateCart(userId);

    const cartItemId = await cartRepository.switchStore(
      cart.id,
      variantId,
      quantity,
      variant.price,
      product.store_id
    );

    return { cartItemId };
  } catch (error) {
    console.error('Error switching cart store:', error);
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

    // Stock validation: the cart page's "+" control goes through this path
    // (not addItem), so it needs the same enforcement -- a quantity of 0 is
    // a removal (handled by the repository) and never exceeds stock.
    if (quantity > 0) {
      const item = await cartRepository.getItemWithStock(cartItemId, userId);
      if (!item) {
        throw new Error('Cart item not found or access denied');
      }
      if (quantity > item.stock) {
        const error = new Error('Insufficient stock');
        error.code = 'INSUFFICIENT_STOCK';
        throw error;
      }
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
  switchStore,
  updateItemQuantity,
  removeItem,
  clearCart
};
