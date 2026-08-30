const storeService = require('../services/storeService');
const orderService = require('../services/orderService');
const productService = require('../services/productService');

const getAllStores = async (req, res) => {
  try {
    const stores = await storeService.getAllActiveStores();
    
    res.status(200).json({
      success: true,
      message: 'Stores retrieved successfully',
      data: stores
    });
  } catch (error) {
    console.error('Get stores error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve stores'
    });
  }
};

const getStoreById = async (req, res) => {
  try {
    const { id } = req.params;
    const store = await storeService.getStoreById(parseInt(id));
    
    res.status(200).json({
      success: true,
      message: 'Store retrieved successfully',
      data: store
    });
  } catch (error) {
    if (error.code === 'STORE_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Store not found'
      });
    }

    console.error('Get store error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve store'
    });
  }
};

// Store Owner order visibility. Mounted with authenticate + requireRole +
// requireStoreOwnership (see routes/storeRoutes.js) -- by the time this
// runs, the authorization middleware has already verified the authenticated
// user owns this store (or is an admin) and rejected the request otherwise.
// req.params.storeId is only ever used here after that verification: it is
// never trusted as-is to decide what data to return.
const getStoreOrders = async (req, res) => {
  try {
    const storeId = parseInt(req.params.storeId, 10);
    const { status } = req.query;

    const orders = await orderService.getOrdersForStore(storeId, status);

    res.status(200).json({
      success: true,
      message: 'Store orders retrieved successfully',
      data: orders
    });
  } catch (error) {
    console.error('Get store orders error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve store orders'
    });
  }
};

// Store Owner Dashboard: the authenticated owner's own stores. Mounted with
// authenticate + requireRole('store_owner') (see routes/storeRoutes.js) --
// no ownership middleware needed here since this endpoint takes no :storeId
// param to check; it inherently only ever returns the caller's own stores.
const getMyStores = async (req, res) => {
  try {
    const stores = await storeService.getMyStores(req.user.userId);

    res.status(200).json({
      success: true,
      message: 'Your stores retrieved successfully',
      data: stores
    });
  } catch (error) {
    console.error('Get my stores error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve your stores'
    });
  }
};

// Store Owner Dashboard: summary stats for the dashboard home. Mounted with
// requireStoreOwnership('storeId') -- req.params.storeId is only ever used
// after that verification.
const getDashboardStats = async (req, res) => {
  try {
    const storeId = parseInt(req.params.storeId, 10);
    const stats = await storeService.getDashboardStats(storeId);

    res.status(200).json({
      success: true,
      message: 'Dashboard stats retrieved successfully',
      data: stats
    });
  } catch (error) {
    console.error('Get dashboard stats error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve dashboard stats'
    });
  }
};

// Store Owner Dashboard: full product list (including inactive) for the
// selected, ownership-verified store.
const getStoreProducts = async (req, res) => {
  try {
    const storeId = parseInt(req.params.storeId, 10);
    const products = await productService.getProductsForStore(storeId);

    res.status(200).json({
      success: true,
      message: 'Store products retrieved successfully',
      data: products
    });
  } catch (error) {
    console.error('Get store products error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve store products'
    });
  }
};

// Store Owner Dashboard: create a product for the selected,
// ownership-verified store. storeId comes from req.params (already verified
// by requireStoreOwnership), never from req.body.
const createStoreProduct = async (req, res) => {
  try {
    const storeId = parseInt(req.params.storeId, 10);
    const result = await productService.createProduct(storeId, req.body || {});

    res.status(201).json({
      success: true,
      message: 'Product created successfully',
      data: result
    });
  } catch (error) {
    if (
      ['INVALID_NAME', 'INVALID_DESCRIPTION', 'INVALID_CATEGORY', 'CATEGORY_NOT_FOUND', 'INVALID_VARIANTS', 'INVALID_IMAGES'].includes(
        error.code
      )
    ) {
      return res.status(400).json({
        success: false,
        message: error.message,
        code: error.code
      });
    }

    console.error('Create store product error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to create product'
    });
  }
};

// Store Owner Dashboard: order detail scoped to the selected,
// ownership-verified store.
const getStoreOrderDetail = async (req, res) => {
  try {
    const storeId = parseInt(req.params.storeId, 10);
    const orderId = parseInt(req.params.orderId, 10);
    const order = await orderService.getOrderForStore(orderId, storeId);

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

    console.error('Get store order detail error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve order'
    });
  }
};

// Store Owner Dashboard: validated order-status update, scoped to the
// selected, ownership-verified store. orderService.updateOrderStatus is the
// single source of truth for which transitions are legal.
const updateStoreOrderStatus = async (req, res) => {
  try {
    const storeId = parseInt(req.params.storeId, 10);
    const orderId = parseInt(req.params.orderId, 10);
    const { status } = req.body || {};

    const result = await orderService.updateOrderStatus(orderId, storeId, status);

    res.status(200).json({
      success: true,
      message: 'Order status updated successfully',
      data: result
    });
  } catch (error) {
    if (error.code === 'ORDER_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    if (error.code === 'INVALID_STATUS' || error.code === 'INVALID_STATUS_TRANSITION') {
      return res.status(400).json({
        success: false,
        message: error.message,
        code: error.code
      });
    }

    console.error('Update store order status error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to update order status'
    });
  }
};

module.exports = {
  getAllStores,
  getStoreById,
  getStoreOrders,
  getMyStores,
  getDashboardStats,
  getStoreProducts,
  createStoreProduct,
  getStoreOrderDetail,
  updateStoreOrderStatus
};
