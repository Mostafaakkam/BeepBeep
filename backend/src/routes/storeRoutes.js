const express = require('express');
const router = express.Router();
const { getAllStores, getStoreById } = require('../controllers/storeController');

router.get('/', getAllStores);
router.get('/:id', getStoreById);

module.exports = router;
