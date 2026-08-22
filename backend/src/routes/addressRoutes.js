const express = require('express');
const router = express.Router();
const { authenticate } = require('../middlewares/authMiddleware');
const { getAddresses, getAddress, createAddress, updateAddress, deleteAddress, setDefaultAddress, getDefaultAddress } = require('../controllers/addressController');

// All address routes require authentication
router.get('/', authenticate, getAddresses);
router.get('/default', authenticate, getDefaultAddress);
router.get('/:id', authenticate, getAddress);
router.post('/', authenticate, createAddress);
router.patch('/:id', authenticate, updateAddress);
router.delete('/:id', authenticate, deleteAddress);
router.patch('/:id/default', authenticate, setDefaultAddress);

module.exports = router;
