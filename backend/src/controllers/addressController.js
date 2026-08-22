const addressService = require('../services/addressService');

const getAddresses = async (req, res) => {
  try {
    const userId = req.user.userId;
    const addresses = await addressService.getAddresses(userId);
    
    res.status(200).json({
      success: true,
      message: 'Addresses retrieved successfully',
      data: addresses
    });
  } catch (error) {
    console.error('Get addresses error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve addresses'
    });
  }
};

const getAddress = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    
    const address = await addressService.getAddress(parseInt(id), userId);
    
    res.status(200).json({
      success: true,
      message: 'Address retrieved successfully',
      data: address
    });
  } catch (error) {
    if (error.code === 'ADDRESS_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Address not found'
      });
    }

    console.error('Get address error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve address'
    });
  }
};

const createAddress = async (req, res) => {
  try {
    const userId = req.user.userId;
    const addressData = req.body;
    
    const result = await addressService.createAddress(userId, addressData);
    
    res.status(201).json({
      success: true,
      message: 'Address created successfully',
      data: result
    });
  } catch (error) {
    if (error.code === 'VALIDATION_ERROR') {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }

    console.error('Create address error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to create address'
    });
  }
};

const updateAddress = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    const addressData = req.body;
    
    await addressService.updateAddress(parseInt(id), userId, addressData);
    
    res.status(200).json({
      success: true,
      message: 'Address updated successfully'
    });
  } catch (error) {
    if (error.code === 'ADDRESS_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Address not found'
      });
    }
    
    if (error.code === 'VALIDATION_ERROR') {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }

    console.error('Update address error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to update address'
    });
  }
};

const deleteAddress = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    
    await addressService.deleteAddress(parseInt(id), userId);
    
    res.status(200).json({
      success: true,
      message: 'Address deleted successfully'
    });
  } catch (error) {
    if (error.code === 'ADDRESS_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Address not found'
      });
    }

    console.error('Delete address error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to delete address'
    });
  }
};

const setDefaultAddress = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    
    await addressService.setDefaultAddress(parseInt(id), userId);
    
    res.status(200).json({
      success: true,
      message: 'Default address set successfully'
    });
  } catch (error) {
    if (error.code === 'ADDRESS_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Address not found'
      });
    }

    console.error('Set default address error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to set default address'
    });
  }
};

const getDefaultAddress = async (req, res) => {
  try {
    const userId = req.user.userId;
    const address = await addressService.getDefaultAddress(userId);
    
    res.status(200).json({
      success: true,
      data: address
    });
  } catch (error) {
    console.error('Get default address error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve default address'
    });
  }
};

module.exports = {
  getAddresses,
  getAddress,
  createAddress,
  updateAddress,
  deleteAddress,
  setDefaultAddress,
  getDefaultAddress
};
