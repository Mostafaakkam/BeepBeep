const express = require('express');
const router = express.Router();
const { getDashboardStats, getStores, updateStoreStatus, updateStoreOwner } = require('../controllers/adminController');
const { authenticate } = require('../middlewares/authMiddleware');
const { requireRole } = require('../middlewares/authorizationMiddleware');

// Admin Dashboard: platform-wide summary statistics. admin-only -- unlike the
// Store Owner Dashboard's requireRole('store_owner', 'admin') pattern, there
// is no per-store ownership scope to bypass into here; this is inherently
// platform-wide, so store_owner is deliberately not in the allowed roles.
router.get('/dashboard', authenticate, requireRole('admin'), getDashboardStats);

// Admin Stores (read-only list): every store, any status, with resolved
// owner info -- same admin-only reasoning as /dashboard above.
router.get('/stores', authenticate, requireRole('admin'), getStores);

// Admin Store Status Management: admin-only, deliberately NOT gated with
// requireStoreOwnership -- a store's own owner must never be able to change
// their own store's approval/active status, only an admin can.
router.patch('/stores/:storeId/status', authenticate, requireRole('admin'), updateStoreStatus);

// Admin Store Owner Assignment: admin-only, deliberately NOT gated with
// requireStoreOwnership -- a store's current owner must never be able to
// reassign their own store to someone else, only an admin can.
router.patch('/stores/:storeId/owner', authenticate, requireRole('admin'), updateStoreOwner);

module.exports = router;
