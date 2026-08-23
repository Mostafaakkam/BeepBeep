const storeService = require('../services/storeService');
const orderService = require('../services/orderService');

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

module.exports = {
  getAllStores,
  getStoreById,
  getStoreOrders
};
