const productService = require('../services/productService');

const getAllProducts = async (req, res) => {
  try {
    const { store_id } = req.query;
    const storeId = store_id ? parseInt(store_id) : null;
    
    const products = await productService.getAllProducts(storeId);
    
    res.status(200).json({
      success: true,
      message: 'Products retrieved successfully',
      data: products
    });
  } catch (error) {
    console.error('Get products error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve products'
    });
  }
};

const getProductById = async (req, res) => {
  try {
    const { id } = req.params;
    const product = await productService.getProductById(parseInt(id));
    
    res.status(200).json({
      success: true,
      message: 'Product retrieved successfully',
      data: product
    });
  } catch (error) {
    if (error.code === 'PRODUCT_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    console.error('Get product error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve product'
    });
  }
};

module.exports = {
  getAllProducts,
  getProductById
};
