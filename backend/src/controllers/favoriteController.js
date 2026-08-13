const favoriteService = require('../services/favoriteService');

const getFavorites = async (req, res) => {
  try {
    const userId = req.user.userId;
    const favorites = await favoriteService.getFavorites(userId);
    
    res.status(200).json({
      success: true,
      message: 'Favorites retrieved successfully',
      data: favorites
    });
  } catch (error) {
    console.error('Get favorites error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve favorites'
    });
  }
};

const addFavorite = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { product_id } = req.body;
    
    await favoriteService.addFavorite(userId, product_id);
    
    res.status(201).json({
      success: true,
      message: 'Product added to favorites'
    });
  } catch (error) {
    if (error.code === 'PRODUCT_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }
    
    if (error.code === 'ALREADY_FAVORITED') {
      return res.status(409).json({
        success: false,
        message: 'Product already in favorites'
      });
    }

    console.error('Add favorite error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to add favorite'
    });
  }
};

const removeFavorite = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { productId } = req.params;
    
    await favoriteService.removeFavorite(userId, parseInt(productId));
    
    res.status(200).json({
      success: true,
      message: 'Product removed from favorites'
    });
  } catch (error) {
    if (error.code === 'FAVORITE_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Favorite not found'
      });
    }

    console.error('Remove favorite error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to remove favorite'
    });
  }
};

const checkFavorite = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { productId } = req.params;
    
    const result = await favoriteService.checkFavorite(userId, parseInt(productId));
    
    res.status(200).json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Check favorite error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to check favorite'
    });
  }
};

module.exports = {
  getFavorites,
  addFavorite,
  removeFavorite,
  checkFavorite
};
