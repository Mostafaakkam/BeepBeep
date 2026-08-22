const categoryRepository = require('../repositories/categoryRepository');

const getCategories = async () => {
  try {
    const categories = await categoryRepository.getAll();
    return categories;
  } catch (error) {
    console.error('Error fetching categories:', error);
    throw new Error('Failed to fetch categories');
  }
};

const getCategory = async (id) => {
  try {
    const category = await categoryRepository.findById(id);
    if (!category) {
      const error = new Error('Category not found');
      error.code = 'CATEGORY_NOT_FOUND';
      throw error;
    }
    return category;
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error fetching category:', error);
    throw new Error('Failed to fetch category');
  }
};

const getProductsByCategory = async (categoryId) => {
  try {
    const category = await categoryRepository.findById(categoryId);
    if (!category) {
      const error = new Error('Category not found');
      error.code = 'CATEGORY_NOT_FOUND';
      throw error;
    }
    
    const products = await categoryRepository.getProductsByCategory(categoryId);
    return products;
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error fetching products by category:', error);
    throw new Error('Failed to fetch products by category');
  }
};

module.exports = {
  getCategories,
  getCategory,
  getProductsByCategory
};
