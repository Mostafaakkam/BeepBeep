const express = require('express');
const router = express.Router();
const { authenticate } = require('../middlewares/authMiddleware');
const { getOrders, getOrderById, createOrder, cancelOrder } = require('../controllers/orderController');

// All order routes require authentication
router.get('/', authenticate, getOrders);
router.get('/:id', authenticate, getOrderById);
router.post('/', authenticate, createOrder);
router.patch('/:id/cancel', authenticate, cancelOrder);

module.exports = router;
