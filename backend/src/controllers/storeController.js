const storeService = require('../services/storeService');

const getAllStores = async (req, res) => {
  try {
    const stores = await storeService.getAllActiveStores();
    
    res.status(200).json({
      success: true,
      message: 'Stores retrieved successfully',
      data: stores
    });
  } catch (error) {
    console.error('Get stores error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve stores'
    });
  }
};

const getStoreById = async (req, res) => {
  try {
    const { id } = req.params;
    const store = await storeService.getStoreById(parseInt(id));
    
    res.status(200).json({
      success: true,
      message: 'Store retrieved successfully',
      data: store
    });
  } catch (error) {
    if (error.code === 'STORE_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Store not found'
      });
    }

    console.error('Get store error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve store'
    });
  }
};

module.exports = {
  getAllStores,
  getStoreById
};
