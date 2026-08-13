const express = require('express');
const router = express.Router();
const { authenticate } = require('../middlewares/authMiddleware');
const { getCart, addItem, updateItemQuantity, removeItem, clearCart } = require('../controllers/cartController');

// All cart routes require authentication
router.get('/', authenticate, getCart);
router.post('/items', authenticate, addItem);
router.patch('/items/:id', authenticate, updateItemQuantity);
router.delete('/items/:id', authenticate, removeItem);
router.delete('/', authenticate, clearCart);

module.exports = router;
