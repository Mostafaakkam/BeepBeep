const storeRepository = require('../repositories/storeRepository');
const productRepository = require('../repositories/productRepository');
const orderRepository = require('../repositories/orderRepository');

// Store Owner Dashboard: statuses summarized on the dashboard's cards. This
// list is the same set orderService.updateOrderStatus's transition map
// walks through (plus 'pending', which every order starts in and needs its
// own count even though it's never a *target* status for the owner).
const DASHBOARD_ORDER_STATUSES = ['pending', 'confirmed', 'preparing', 'shipped', 'delivered'];

// Store Owner Dashboard: the authenticated owner's own stores. ownerId here
// is always req.user.userId, verified by requireRole('store_owner') --
// never a client-supplied id (there is no id to supply; this endpoint takes
// none). See storeController.getMyStores / routes/storeRoutes.js.
const getMyStores = async (ownerId) => {
  try {
    const stores = await storeRepository.findByOwnerId(ownerId);
    return stores;
  } catch (error) {
    console.error('Error fetching owner stores:', error);
    throw new Error('Failed to fetch your stores');
  }
};

// Store Owner Dashboard: summary stats for one store's dashboard home.
// storeId is only ever the value requireStoreOwnership already verified --
// see storeController.getDashboardStats.
const getDashboardStats = async (storeId) => {
  try {
    const orderCounts = await orderRepository.countByStoreIdGroupedByStatus(storeId);
    const productCount = await productRepository.countByStoreId(storeId);

    const ordersByStatus = {};
    for (const status of DASHBOARD_ORDER_STATUSES) {
      ordersByStatus[status] = orderCounts[status] || 0;
    }

    return {
      ordersByStatus,
      productCount
    };
  } catch (error) {
    console.error('Error fetching dashboard stats:', error);
    throw new Error('Failed to fetch dashboard stats');
  }
};

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
  getStoreById,
  getMyStores,
  getDashboardStats
};
