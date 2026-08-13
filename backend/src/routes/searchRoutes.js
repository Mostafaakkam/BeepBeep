const express = require('express');
const router = express.Router();
const { search } = require('../controllers/searchController');

// Search endpoint - public access (no authentication required)
router.get('/', search);

module.exports = router;
