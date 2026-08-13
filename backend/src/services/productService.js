const productRepository = require('../repositories/productRepository');

const getAllProducts = async (storeId = null) => {
  try {
    const products = await productRepository.findAll(storeId);
    return products;
  } catch (error) {
    console.error('Error fetching products:', error);
    throw new Error('Failed to fetch products');
  }
};

const getProductById = async (id) => {
  try {
    const product = await productRepository.findById(id);
    if (!product) {
      const error = new Error('Product not found');
      error.code = 'PRODUCT_NOT_FOUND';
      throw error;
    }
    return product;
  } catch (error) {
    console.error('Error fetching product:', error);
    throw new Error('Failed to fetch product');
  }
};

module.exports = {
  getAllProducts,
  getProductById
};
