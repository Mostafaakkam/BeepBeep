const express = require('express');
const router = express.Router();
const { getCategories, getCategory, getProductsByCategory } = require('../controllers/categoryController');

// Category routes are public (no authentication required for browsing)
router.get('/', getCategories);
router.get('/:id', getCategory);
router.get('/:id/products', getProductsByCategory);

module.exports = router;
