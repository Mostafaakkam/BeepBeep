const express = require('express');
const router = express.Router();
const { getAllStores, getStoreById, getStoreOrders } = require('../controllers/storeController');
const { authenticate } = require('../middlewares/authMiddleware');
const { requireRole, requireStoreOwnership } = require('../middlewares/authorizationMiddleware');

router.get('/', getAllStores);
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

module.exports = router;
