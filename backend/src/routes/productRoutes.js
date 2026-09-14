const express = require('express');
const router = express.Router();
const { getAllProducts, getProductById, updateProduct, deactivateProduct, reactivateProduct } = require('../controllers/productController');
const { authenticate } = require('../middlewares/authMiddleware');
const { requireRole, requireProductOwnership } = require('../middlewares/authorizationMiddleware');

router.get('/', getAllProducts);
router.get('/:id', getProductById);

// Store Owner Dashboard: requireProductOwnership resolves the product's
// store and verifies the caller owns it (or is admin) before update/
// deactivate ever runs -- never trusts a store_id/owner_id from the client.
router.put(
  '/:id',
  authenticate,
  requireRole('store_owner', 'admin'),
  requireProductOwnership('id'),
  updateProduct
);

router.patch(
  '/:id/deactivate',
  authenticate,
  requireRole('store_owner', 'admin'),
  requireProductOwnership('id'),
  deactivateProduct
);

// Stabilization fix: mirror image of /:id/deactivate above, same ownership
// chain. Lets an owner undo an accidental deactivation -- previously
// productRepository.setActive(id, true) existed but nothing ever called it.
router.patch(
  '/:id/reactivate',
  authenticate,
  requireRole('store_owner', 'admin'),
  requireProductOwnership('id'),
  reactivateProduct
);

module.exports = router;
