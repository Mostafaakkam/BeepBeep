const userRepository = require('../repositories/userRepository');
const storeRepository = require('../repositories/storeRepository');
const productRepository = require('../repositories/productRepository');
const orderRepository = require('../repositories/orderRepository');
const categoryRepository = require('../repositories/categoryRepository');

// Admin Dashboard: the full set of valid values for each grouped stat, so the
// response always reports every key (0 if a table currently has no rows in
// it) instead of omitting one. Mirrors storeService's
// DASHBOARD_ORDER_STATUSES convention from the Store Owner Dashboard.
const USER_ROLES = ['customer', 'store_owner', 'admin'];
const STORE_STATUSES = ['pending', 'active', 'inactive'];
const ORDER_STATUSES = ['pending', 'confirmed', 'preparing', 'shipped', 'delivered', 'cancelled'];

// Admin Dashboard: platform-wide summary statistics (GET /api/admin/dashboard).
// Every count comes from a SQL aggregate query (COUNT(*) ... GROUP BY) via the
// repository layer -- no row is fetched just to be counted in JavaScript.
// "total" for each section is derived by summing that section's own
// already-aggregated group counts, not a second COUNT(*) query.
const getDashboardStats = async () => {
  try {
    const [
      usersByRole,
      storesByStatus,
      productsByActive,
      ordersByStatus,
      categoryCount
    ] = await Promise.all([
      userRepository.countGroupedByRole(),
      storeRepository.countGroupedByStatus(),
      productRepository.countAllGroupedByActive(),
      orderRepository.countAllGroupedByStatus(),
      categoryRepository.countAll()
    ]);

    const byRole = {};
    let usersTotal = 0;
    for (const role of USER_ROLES) {
      const count = usersByRole[role] || 0;
      byRole[role] = count;
      usersTotal += count;
    }

    const byStoreStatus = {};
    let storesTotal = 0;
    for (const status of STORE_STATUSES) {
      const count = storesByStatus[status] || 0;
      byStoreStatus[status] = count;
      storesTotal += count;
    }

    const byOrderStatus = {};
    let ordersTotal = 0;
    for (const status of ORDER_STATUSES) {
      const count = ordersByStatus[status] || 0;
      byOrderStatus[status] = count;
      ordersTotal += count;
    }

    return {
      users: {
        total: usersTotal,
        byRole
      },
      stores: {
        total: storesTotal,
        byStatus: byStoreStatus
      },
      products: {
        total: productsByActive.active + productsByActive.inactive,
        active: productsByActive.active,
        inactive: productsByActive.inactive
      },
      orders: {
        total: ordersTotal,
        byStatus: byOrderStatus
      },
      categories: {
        total: categoryCount
      }
    };
  } catch (error) {
    console.error('Error fetching admin dashboard stats:', error);
    throw new Error('Failed to fetch admin dashboard stats');
  }
};

// Admin Stores (read-only list): every store, any status, with resolved
// owner info. `status`, if given, must be one of the real stores.status enum
// values -- validated here (service layer), not the controller, matching
// this codebase's existing .code-tagged validation-error convention (see
// productService.validateProductData / reviewService). storeRepository
// returns rows already shaped exactly as the response needs them (id, name,
// status, owner_id, owner_name, owner_email, created_at), so nothing is
// remapped here -- same "service just passes repository rows through"
// pattern as storeService.getAllActiveStores.
const getStores = async (status) => {
  try {
    if (status !== undefined && !STORE_STATUSES.includes(status)) {
      const error = new Error(`Invalid status. Must be one of: ${STORE_STATUSES.join(', ')}`);
      error.code = 'INVALID_STATUS';
      throw error;
    }

    return await storeRepository.findAllForAdmin(status);
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error fetching admin stores:', error);
    throw new Error('Failed to fetch admin stores');
  }
};

// Admin Store Status Management: change a store's status to one of the real
// stores.status enum values. storeId/status are both fully validated here
// (service layer) before anything touches the database, matching this
// codebase's existing .code-tagged validation-error convention. Returns the
// updated store in the exact same shape as GET /api/admin/stores (via
// findByIdForAdmin), so callers never see two different store
// representations depending on which admin endpoint they used.
const updateStoreStatus = async (storeId, status) => {
  try {
    const id = Number(storeId);
    if (!Number.isInteger(id) || id <= 0) {
      const error = new Error('Invalid store id');
      error.code = 'INVALID_STORE_ID';
      throw error;
    }

    if (!status) {
      const error = new Error('Status is required');
      error.code = 'INVALID_STATUS';
      throw error;
    }

    if (!STORE_STATUSES.includes(status)) {
      const error = new Error(`Invalid status. Must be one of: ${STORE_STATUSES.join(', ')}`);
      error.code = 'INVALID_STATUS';
      throw error;
    }

    const existing = await storeRepository.findByIdForAdmin(id);
    if (!existing) {
      const error = new Error('Store not found');
      error.code = 'STORE_NOT_FOUND';
      throw error;
    }

    await storeRepository.updateStatus(id, status);

    return await storeRepository.findByIdForAdmin(id);
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error updating store status:', error);
    throw new Error('Failed to update store status');
  }
};

// Admin Store Owner Assignment: the only role eligible to be assigned as a
// store's owner_id. Deliberately excludes 'admin' -- nothing in the existing
// ownership model (requireStoreOwnership's admin bypass is a permission
// shortcut, not a record of admin-owned stores; seed.js's owner/store
// relationships are always store_owner-to-store) supports an admin literally
// owning a store, so this slice does not invent that. Also excludes
// 'customer', as required.
const ELIGIBLE_OWNER_ROLE = 'store_owner';

// Admin Store Owner Assignment: assign/reassign/remove a store's owner.
// `ownerId` is `null` to remove the owner (see storeRepository.updateOwner's
// comment -- this mirrors the schema's own pre-existing "unowned store"
// state, not a newly-invented one), or a user id to assign/reassign. The
// target user, when given, must actually exist and currently hold the
// 'store_owner' role -- verified fresh from the database via
// userRepository.findById (the same re-verification principle requireRole
// already applies to the caller's own role), never trusted from the
// request body. This never writes to users.role: assigning ownership does
// not promote/demote anyone, matching the existing register() behavior of
// never letting a role change happen as a side effect of something else.
const updateStoreOwner = async (storeId, ownerIdInput) => {
  try {
    const id = Number(storeId);
    if (!Number.isInteger(id) || id <= 0) {
      const error = new Error('Invalid store id');
      error.code = 'INVALID_STORE_ID';
      throw error;
    }

    if (ownerIdInput === undefined) {
      const error = new Error('ownerId is required');
      error.code = 'INVALID_OWNER_ID';
      throw error;
    }

    let ownerId = null;
    if (ownerIdInput !== null) {
      ownerId = Number(ownerIdInput);
      if (!Number.isInteger(ownerId) || ownerId <= 0) {
        const error = new Error('Invalid owner id');
        error.code = 'INVALID_OWNER_ID';
        throw error;
      }
    }

    const existing = await storeRepository.findByIdForAdmin(id);
    if (!existing) {
      const error = new Error('Store not found');
      error.code = 'STORE_NOT_FOUND';
      throw error;
    }

    if (ownerId !== null) {
      // Foreign reference supplied in the request body, not the route's
      // primary resource -- mirrors productService.validateProductData's
      // categoryId check (a missing/invalid categoryId is a 400
      // CATEGORY_NOT_FOUND, not a 404), not the STORE_NOT_FOUND/404 case
      // above, which is about the route param's own resource.
      const targetUser = await userRepository.findById(ownerId);
      if (!targetUser) {
        const error = new Error('Owner not found');
        error.code = 'OWNER_NOT_FOUND';
        throw error;
      }
      if (targetUser.role !== ELIGIBLE_OWNER_ROLE) {
        const error = new Error(
          `User ${ownerId} has role '${targetUser.role}', not '${ELIGIBLE_OWNER_ROLE}' -- only a store_owner can be assigned as a store's owner`
        );
        error.code = 'INVALID_OWNER_ROLE';
        throw error;
      }
    }

    // Same owner already -- skip the write entirely rather than performing
    // an unnecessary UPDATE.
    if (existing.owner_id === ownerId) {
      return existing;
    }

    await storeRepository.updateOwner(id, ownerId);

    return await storeRepository.findByIdForAdmin(id);
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error updating store owner:', error);
    throw new Error('Failed to update store owner');
  }
};

module.exports = {
  getDashboardStats,
  getStores,
  updateStoreStatus,
  updateStoreOwner
};
