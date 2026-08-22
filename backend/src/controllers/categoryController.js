const categoryService = require('../services/categoryService');

const getCategories = async (req, res) => {
  try {
    const categories = await categoryService.getCategories();
    
    res.status(200).json({
      success: true,
      message: 'Categories retrieved successfully',
      data: categories
    });
  } catch (error) {
    console.error('Get categories error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve categories'
    });
  }
};

const getCategory = async (req, res) => {
  try {
    const { id } = req.params;
    const category = await categoryService.getCategory(parseInt(id));
    
    res.status(200).json({
      success: true,
      message: 'Category retrieved successfully',
      data: category
    });
  } catch (error) {
    if (error.code === 'CATEGORY_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Category not found'
      });
    }

    console.error('Get category error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve category'
    });
  }
};

const getProductsByCategory = async (req, res) => {
  try {
    const { id } = req.params;
    const products = await categoryService.getProductsByCategory(parseInt(id));
    
    res.status(200).json({
      success: true,
      message: 'Products retrieved successfully',
      data: products
    });
  } catch (error) {
    if (error.code === 'CATEGORY_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Category not found'
      });
    }

    console.error('Get products by category error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve products by category'
    });
  }
};

module.exports = {
  getCategories,
  getCategory,
  getProductsByCategory
};
