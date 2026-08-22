const addressRepository = require('../repositories/addressRepository');

const getAddresses = async (userId) => {
  try {
    const addresses = await addressRepository.getAll(userId);
    return addresses;
  } catch (error) {
    console.error('Error fetching addresses:', error);
    throw new Error('Failed to fetch addresses');
  }
};

const getAddress = async (id, userId) => {
  try {
    const address = await addressRepository.findById(id, userId);
    if (!address) {
      const error = new Error('Address not found');
      error.code = 'ADDRESS_NOT_FOUND';
      throw error;
    }
    return address;
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error fetching address:', error);
    throw new Error('Failed to fetch address');
  }
};

const createAddress = async (userId, addressData) => {
  try {
    // Validate required fields
    if (!addressData.label || !addressData.recipient_name || !addressData.phone || !addressData.address) {
      const error = new Error('Missing required fields');
      error.code = 'VALIDATION_ERROR';
      throw error;
    }
    
    // If this is the first address, make it default automatically
    const existingAddresses = await addressRepository.getAll(userId);
    if (existingAddresses.length === 0) {
      addressData.is_default = true;
    }
    
    const addressId = await addressRepository.create(userId, addressData);
    return { id: addressId };
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error creating address:', error);
    throw new Error('Failed to create address');
  }
};

const updateAddress = async (id, userId, addressData) => {
  try {
    // Validate required fields
    if (!addressData.label || !addressData.recipient_name || !addressData.phone || !addressData.address) {
      const error = new Error('Missing required fields');
      error.code = 'VALIDATION_ERROR';
      throw error;
    }
    
    // Check if address exists and belongs to user
    const existing = await addressRepository.findById(id, userId);
    if (!existing) {
      const error = new Error('Address not found');
      error.code = 'ADDRESS_NOT_FOUND';
      throw error;
    }
    
    const updated = await addressRepository.update(id, userId, addressData);
    if (!updated) {
      const error = new Error('Failed to update address');
      error.code = 'UPDATE_FAILED';
      throw error;
    }
    
    return { success: true };
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error updating address:', error);
    throw new Error('Failed to update address');
  }
};

const deleteAddress = async (id, userId) => {
  try {
    // Check if address exists and belongs to user
    const existing = await addressRepository.findById(id, userId);
    if (!existing) {
      const error = new Error('Address not found');
      error.code = 'ADDRESS_NOT_FOUND';
      throw error;
    }
    
    const deleted = await addressRepository.remove(id, userId);
    if (!deleted) {
      const error = new Error('Failed to delete address');
      error.code = 'DELETE_FAILED';
      throw error;
    }
    
    // If the deleted address was default, try to set another as default
    if (existing.is_default) {
      const remainingAddresses = await addressRepository.getAll(userId);
      if (remainingAddresses.length > 0) {
        await addressRepository.setDefault(remainingAddresses[0].id, userId);
      }
    }
    
    return { success: true };
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error deleting address:', error);
    throw new Error('Failed to delete address');
  }
};

const setDefaultAddress = async (id, userId) => {
  try {
    // Check if address exists and belongs to user
    const existing = await addressRepository.findById(id, userId);
    if (!existing) {
      const error = new Error('Address not found');
      error.code = 'ADDRESS_NOT_FOUND';
      throw error;
    }
    
    await addressRepository.setDefault(id, userId);
    return { success: true };
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error setting default address:', error);
    throw new Error('Failed to set default address');
  }
};

const getDefaultAddress = async (userId) => {
  try {
    const address = await addressRepository.getDefault(userId);
    return address;
  } catch (error) {
    console.error('Error fetching default address:', error);
    throw new Error('Failed to fetch default address');
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
