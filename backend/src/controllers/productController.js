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

// Store Owner Dashboard: update a product. Mounted with
// requireProductOwnership('id') (see routes/productRoutes.js) -- by the
// time this runs, ownership of :id has already been verified server-side.
const updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    await productService.updateProduct(parseInt(id), req.body || {});

    res.status(200).json({
      success: true,
      message: 'Product updated successfully'
    });
  } catch (error) {
    if (
      ['INVALID_NAME', 'INVALID_DESCRIPTION', 'INVALID_CATEGORY', 'CATEGORY_NOT_FOUND', 'INVALID_VARIANTS', 'INVALID_IMAGES'].includes(
        error.code
      )
    ) {
      return res.status(400).json({
        success: false,
        message: error.message,
        code: error.code
      });
    }

    console.error('Update product error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to update product'
    });
  }
};

// Store Owner Dashboard: soft-delete (deactivate) a product. Mounted with
// requireProductOwnership('id') -- ownership already verified server-side.
const deactivateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    await productService.deactivateProduct(parseInt(id));

    res.status(200).json({
      success: true,
      message: 'Product deactivated successfully'
    });
  } catch (error) {
    console.error('Deactivate product error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to deactivate product'
    });
  }
};

module.exports = {
  getAllProducts,
  getProductById,
  updateProduct,
  deactivateProduct
};
