const productService = require('../services/productService');

const getAllProducts = async (req, res) => {
  try {
    const {
      store_id,
      category_id,
      min_price,
      max_price,
      in_stock,
      sort
    } = req.query;
    
    const filters = {
      storeId: store_id ? parseInt(store_id) : null,
      categoryId: category_id ? parseInt(category_id) : null,
      minPrice: min_price ? parseFloat(min_price) : null,
      maxPrice: max_price ? parseFloat(max_price) : null,
      inStock: in_stock === 'true',
      sortBy: sort || 'newest'
    };
    
    const products = await productService.getAllProducts(filters);
    
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
