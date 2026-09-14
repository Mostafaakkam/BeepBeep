const favoriteRepository = require('../repositories/favoriteRepository');
const productRepository = require('../repositories/productRepository');

const getFavorites = async (userId) => {
  try {
    const favorites = await favoriteRepository.findByUserId(userId);
    // Same root cause as the earlier Product Details and Cart fixes:
    // pv.price (product_variants.price, a DECIMAL column) is returned by
    // mysql2 as a JS string, and Flutter's favorites_page.dart does
    // `(favorite['lowest_price'] as num).toDouble()` when rendering each
    // card. Unlike the other two bugs, loadFavorites() itself succeeds here
    // (the raw rows are valid JSON either way), so nothing was ever caught
    // as a load error -- the cast exception is instead thrown later, during
    // Flutter's widget build for each list item, which is why the page
    // renders as empty/blank rather than showing a distinct error screen.
    // Confirmed live: GET /api/favorites returned lowest_price as a quoted
    // string ("25.00") for every favorited product. Normalized here, at the
    // one place this value enters the response.
    return favorites.map((favorite) => ({
      ...favorite,
      lowest_price: favorite.lowest_price !== null && favorite.lowest_price !== undefined
        ? parseFloat(favorite.lowest_price)
        : null,
    }));
  } catch (error) {
    console.error('Error fetching favorites:', error);
    throw new Error('Failed to fetch favorites');
  }
};

const addFavorite = async (userId, productId) => {
  try {
    // Check if product exists
    const product = await productRepository.findById(productId);
    if (!product) {
      const error = new Error('Product not found');
      error.code = 'PRODUCT_NOT_FOUND';
      throw error;
    }
    
    // Check if already favorited
    const existing = await favoriteRepository.findByUserAndProduct(userId, productId);
    if (existing) {
      const error = new Error('Product already in favorites');
      error.code = 'ALREADY_FAVORITED';
      throw error;
    }
    
    await favoriteRepository.addFavorite(userId, productId);
    return { success: true };
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error adding favorite:', error);
    throw new Error('Failed to add favorite');
  }
};

const removeFavorite = async (userId, productId) => {
  try {
    const removed = await favoriteRepository.removeFavorite(userId, productId);
    if (!removed) {
      const error = new Error('Favorite not found');
      error.code = 'FAVORITE_NOT_FOUND';
      throw error;
    }
    return { success: true };
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error removing favorite:', error);
    throw new Error('Failed to remove favorite');
  }
};

const checkFavorite = async (userId, productId) => {
  try {
    const isFavorited = await favoriteRepository.checkFavorite(userId, productId);
    return { isFavorited };
  } catch (error) {
    console.error('Error checking favorite:', error);
    throw new Error('Failed to check favorite');
  }
};

module.exports = {
  getFavorites,
  addFavorite,
  removeFavorite,
  checkFavorite
};
