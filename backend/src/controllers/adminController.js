const adminService = require('../services/adminService');

// Admin Dashboard: platform-wide summary statistics. Mounted with
// authenticate + requireRole('admin') (see routes/adminRoutes.js) -- no
// store-owner or customer access.
const getDashboardStats = async (req, res) => {
  try {
    const stats = await adminService.getDashboardStats();

    res.status(200).json({
      success: true,
      message: 'Admin dashboard stats retrieved successfully',
      data: stats
    });
  } catch (error) {
    console.error('Get admin dashboard stats error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve admin dashboard stats'
    });
  }
};

// Admin Stores (read-only list): every store, any status, with resolved
// owner info. Mounted with authenticate + requireRole('admin') (see
// routes/adminRoutes.js) -- no store-owner or customer access.
const getStores = async (req, res) => {
  try {
    const { status } = req.query;
    const stores = await adminService.getStores(status);

    res.status(200).json({
      success: true,
      message: 'Admin stores retrieved successfully',
      data: stores
    });
  } catch (error) {
    if (error.code === 'INVALID_STATUS') {
      return res.status(400).json({
        success: false,
        message: error.message,
        code: error.code
      });
    }

    console.error('Get admin stores error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve admin stores'
    });
  }
};

// Admin Store Status Management: change a store's status (pending/active/
// inactive). Mounted with authenticate + requireRole('admin') (see
// routes/adminRoutes.js) -- no store-owner or customer access, and
// deliberately not requireStoreOwnership either: this is an admin-only
// platform action, not something the store's own owner can do to themselves.
const updateStoreStatus = async (req, res) => {
  try {
    const { storeId } = req.params;
    const { status } = req.body || {};

    const store = await adminService.updateStoreStatus(storeId, status);

    res.status(200).json({
      success: true,
      message: 'Store status updated successfully',
      data: store
    });
  } catch (error) {
    if (error.code === 'STORE_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Store not found'
      });
    }

    if (error.code === 'INVALID_STATUS' || error.code === 'INVALID_STORE_ID') {
      return res.status(400).json({
        success: false,
        message: error.message,
        code: error.code
      });
    }

    console.error('Update store status error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to update store status'
    });
  }
};

// Admin Store Owner Assignment: assign/reassign/remove a store's owner.
// Mounted with authenticate + requireRole('admin') (see routes/adminRoutes.js)
// -- no store-owner or customer access, and deliberately not
// requireStoreOwnership: a store's current owner must never be able to
// reassign their own store to someone else, only an admin can.
const updateStoreOwner = async (req, res) => {
  try {
    const { storeId } = req.params;
    const { ownerId } = req.body || {};

    const store = await adminService.updateStoreOwner(storeId, ownerId);

    res.status(200).json({
      success: true,
      message: 'Store owner updated successfully',
      data: store
    });
  } catch (error) {
    if (error.code === 'STORE_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Store not found'
      });
    }

    if (['INVALID_STORE_ID', 'INVALID_OWNER_ID', 'OWNER_NOT_FOUND', 'INVALID_OWNER_ROLE'].includes(error.code)) {
      return res.status(400).json({
        success: false,
        message: error.message,
        code: error.code
      });
    }

    console.error('Update store owner error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to update store owner'
    });
  }
};

module.exports = {
  getDashboardStats,
  getStores,
  updateStoreStatus,
  updateStoreOwner
};
