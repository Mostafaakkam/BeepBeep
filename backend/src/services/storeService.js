const storeRepository = require('../repositories/storeRepository');

const getAllActiveStores = async () => {
  try {
    const stores = await storeRepository.findAllActive();
    return stores;
  } catch (error) {
    console.error('Error fetching stores:', error);
    throw new Error('Failed to fetch stores');
  }
};

const getStoreById = async (id) => {
  try {
    const store = await storeRepository.findById(id);
    if (!store) {
      const error = new Error('Store not found');
      error.code = 'STORE_NOT_FOUND';
      throw error;
    }
    return store;
  } catch (error) {
    console.error('Error fetching store:', error);
    throw new Error('Failed to fetch store');
  }
};

module.exports = {
  getAllActiveStores,
  getStoreById
};
