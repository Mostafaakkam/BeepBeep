const productRepository = require('../repositories/productRepository');
const categoryRepository = require('../repositories/categoryRepository');

const MAX_NAME_LENGTH = 200;
const MAX_DESCRIPTION_LENGTH = 2000;

// Store Owner Dashboard: shared validation for create/update, mirroring the
// .code-tagged error convention used throughout this backend (see
// reviewService.js). Thrown errors are read by productController and mapped
// to HTTP status codes there -- this function never touches req/res.
const validateProductData = async (data) => {
  const name = typeof data.name === 'string' ? data.name.trim() : '';
  if (!name || name.length > MAX_NAME_LENGTH) {
    const error = new Error(`Name is required and must be at most ${MAX_NAME_LENGTH} characters`);
    error.code = 'INVALID_NAME';
    throw error;
  }

  if (data.description !== undefined && data.description !== null) {
    if (typeof data.description !== 'string' || data.description.length > MAX_DESCRIPTION_LENGTH) {
      const error = new Error(`Description must be at most ${MAX_DESCRIPTION_LENGTH} characters`);
      error.code = 'INVALID_DESCRIPTION';
      throw error;
    }
  }

  const categoryId = Number(data.categoryId);
  if (!Number.isInteger(categoryId) || categoryId <= 0) {
    const error = new Error('A valid category is required');
    error.code = 'INVALID_CATEGORY';
    throw error;
  }
  const category = await categoryRepository.findById(categoryId);
  if (!category) {
    const error = new Error('Category not found');
    error.code = 'CATEGORY_NOT_FOUND';
    throw error;
  }

  if (!Array.isArray(data.variants) || data.variants.length === 0) {
    const error = new Error('At least one variant is required');
    error.code = 'INVALID_VARIANTS';
    throw error;
  }
  for (const variant of data.variants) {
    const price = Number(variant.price);
    const stock = Number(variant.stock);
    if (!Number.isFinite(price) || price <= 0) {
      const error = new Error('Each variant needs a valid price greater than 0');
      error.code = 'INVALID_VARIANTS';
      throw error;
    }
    if (!Number.isInteger(stock) || stock < 0) {
      const error = new Error('Each variant needs a valid, non-negative stock quantity');
      error.code = 'INVALID_VARIANTS';
      throw error;
    }
  }

  if (data.images !== undefined && !Array.isArray(data.images)) {
    const error = new Error('Images must be a list of image paths/URLs');
    error.code = 'INVALID_IMAGES';
    throw error;
  }

  return {
    name,
    description: data.description ? String(data.description).trim() : null,
    categoryId,
    variants: data.variants.map((v) => ({
      id: v.id ? Number(v.id) : undefined,
      color: v.color ? String(v.color).trim() : null,
      size: v.size ? String(v.size).trim() : null,
      price: Number(v.price),
      stock: Number(v.stock)
    })),
    images: Array.isArray(data.images) ? data.images.map((path) => String(path).trim()) : []
  };
};

// Store Owner Dashboard: full product list (including inactive) for one
// store. storeId is always pre-verified by requireStoreOwnership -- see
// storeController.getStoreProducts.
const getProductsForStore = async (storeId) => {
  try {
    const products = await productRepository.findByStoreIdForOwner(storeId);
    return products;
  } catch (error) {
    console.error('Error fetching store products:', error);
    throw new Error('Failed to fetch store products');
  }
};

// Store Owner Dashboard: create a product for the given store. storeId is
// always req.store.id, resolved and verified server-side by
// requireStoreOwnership before this ever runs -- see
// productController.createProduct / routes/storeRoutes.js. Never taken from
// the request body.
const createProduct = async (storeId, data) => {
  try {
    const validated = await validateProductData(data);
    const productId = await productRepository.create(storeId, validated);
    return { id: productId };
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error creating product:', error);
    throw new Error('Failed to create product');
  }
};

// Store Owner Dashboard: update a product already verified (by
// requireProductOwnership) to belong to the authenticated owner's store.
const updateProduct = async (productId, data) => {
  try {
    const validated = await validateProductData(data);
    await productRepository.update(productId, validated);
    return { success: true };
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error updating product:', error);
    throw new Error('Failed to update product');
  }
};

// Store Owner Dashboard: soft-delete (never a hard DELETE -- see migration
// 003's notes). productId here is always pre-verified by
// requireProductOwnership.
const deactivateProduct = async (productId) => {
  try {
    await productRepository.setActive(productId, false);
    return { success: true };
  } catch (error) {
    console.error('Error deactivating product:', error);
    throw new Error('Failed to deactivate product');
  }
};

const getAllProducts = async (filters = {}) => {
  try {
    const products = await productRepository.findAll(filters);
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
    // Store Owner Dashboard: previously this catch block re-threw a plain
    // Error, discarding error.code -- so productController.getProductById's
    // `if (error.code === 'PRODUCT_NOT_FOUND') return 404` branch could never
    // match, and ANY missing product (nonexistent id, or now a deactivated
    // one via the new is_active filter) fell through to a 500. Preserving
    // .code here (same convention used in reviewService.js and the other
    // service functions added for this feature) fixes that for both cases.
    if (error.code) {
      throw error;
    }
    console.error('Error fetching product:', error);
    throw new Error('Failed to fetch product');
  }
};

module.exports = {
  getAllProducts,
  getProductById,
  getProductsForStore,
  createProduct,
  updateProduct,
  deactivateProduct
};
