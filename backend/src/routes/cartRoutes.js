const express = require('express');
const router = express.Router();
const { authenticate } = require('../middlewares/authMiddleware');
const { getCart, addItem, switchStore, updateItemQuantity, removeItem, clearCart } = require('../controllers/cartController');

// All cart routes require authentication
router.get('/', authenticate, getCart);
router.post('/items', authenticate, addItem);
// Single-Store Cart Rule: atomic "clear cart + add this item" for the
// confirmed "switch stores" flow (see cartService.switchStore).
router.post('/switch-store', authenticate, switchStore);
router.patch('/items/:id', authenticate, updateItemQuantity);
router.delete('/items/:id', authenticate, removeItem);
router.delete('/', authenticate, clearCart);

module.exports = router;
