const express = require('express');
const router = express.Router();
const {
  getAllStores,
  getStoreById,
  getStoreOrders,
  getMyStores,
  getDashboardStats,
  getStoreProducts,
  createStoreProduct,
  getStoreOrderDetail,
  updateStoreOrderStatus
} = require('../controllers/storeController');
const { authenticate } = require('../middlewares/authMiddleware');
const { requireRole, requireStoreOwnership } = require('../middlewares/authorizationMiddleware');

router.get('/', getAllStores);

// Store Owner Dashboard: "my stores" list. Registered BEFORE '/:id' below --
// Express matches routes in order, and '/:id' would otherwise swallow the
// literal path "/mine" as if "mine" were a store id. No requireStoreOwnership
// here: this endpoint takes no :storeId param, it inherently only returns
// stores owned by req.user.userId.
router.get('/mine', authenticate, requireRole('store_owner'), getMyStores);

router.get('/:id', getStoreById);

// Store Owner order visibility (Store Ownership + Role-Based Authorization
// feature). requireStoreOwnership resolves/verifies ownership of :storeId
// server-side (with an admin bypass) before getStoreOrders ever runs.
router.get(
  '/:storeId/orders',
  authenticate,
  requireRole('store_owner', 'admin'),
  requireStoreOwnership('storeId'),
  getStoreOrders
);

// Store Owner Dashboard: everything below is scoped to one store and
// authorized the same way -- authenticate, then requireRole (DB-verified,
// admin bypass built into requireStoreOwnership), then requireStoreOwnership
// resolves/verifies :storeId belongs to the caller (or the caller is admin)
// before any of these controllers run.
router.get(
  '/:storeId/dashboard',
  authenticate,
  requireRole('store_owner', 'admin'),
  requireStoreOwnership('storeId'),
  getDashboardStats
);

router.get(
  '/:storeId/products',
  authenticate,
  requireRole('store_owner', 'admin'),
  requireStoreOwnership('storeId'),
  getStoreProducts
);

router.post(
  '/:storeId/products',
  authenticate,
  requireRole('store_owner', 'admin'),
  requireStoreOwnership('storeId'),
  createStoreProduct
);

router.get(
  '/:storeId/orders/:orderId',
  authenticate,
  requireRole('store_owner', 'admin'),
  requireStoreOwnership('storeId'),
  getStoreOrderDetail
);

router.patch(
  '/:storeId/orders/:orderId/status',
  authenticate,
  requireRole('store_owner', 'admin'),
  requireStoreOwnership('storeId'),
  updateStoreOrderStatus
);

module.exports = router;
