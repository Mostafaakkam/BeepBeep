const express = require('express');
const router = express.Router();
const { authenticate } = require('../middlewares/authMiddleware');
const { getFavorites, addFavorite, removeFavorite, checkFavorite } = require('../controllers/favoriteController');

// All favorite routes require authentication
router.get('/', authenticate, getFavorites);
router.post('/', authenticate, addFavorite);
router.delete('/:productId', authenticate, removeFavorite);
router.get('/check/:productId', authenticate, checkFavorite);

module.exports = router;
