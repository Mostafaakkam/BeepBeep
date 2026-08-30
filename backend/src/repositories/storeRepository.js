const pool = require('../config/database');

const findAllActive = async () => {
  const [rows] = await pool.execute(
    'SELECT id, name, description, logo, cover_image, address, phone, created_at, updated_at FROM stores WHERE status = ? ORDER BY created_at DESC',
    ['active']
  );
  return rows;
};

const findById = async (id) => {
  const [rows] = await pool.execute(
    'SELECT id, name, description, logo, cover_image, address, phone, status, created_at, updated_at FROM stores WHERE id = ?',
    [id]
  );
  return rows[0] || null;
};

// Added for Store Ownership Authorization. Deliberately NOT part of
// findById()'s public-facing column list: owner_id is only ever resolved
// server-side for authorization checks (see
// middlewares/authorizationMiddleware.js#requireStoreOwnership) and is never
// exposed to API responses today, so it can't be trusted or spoofed from the
// client either way.
const findOwnerId = async (storeId) => {
  const [rows] = await pool.execute(
    'SELECT owner_id FROM stores WHERE id = ?',
    [storeId]
  );
  if (rows.length === 0) return undefined; // store does not exist
  return rows[0].owner_id; // may be null (store not yet assigned an owner)
};

// Store Owner Dashboard: the owner's own stores, for the "my stores" list /
// switcher. Deliberately NOT filtered by status = 'active' (unlike
// findAllActive) -- an owner must be able to see and manage a pending/
// inactive store of their own, not just active ones. owner_id itself is
// still never included in the SELECT, same reasoning as findOwnerId below:
// this endpoint is reached only after requireRole('store_owner') has
// verified req.user.userId server-side, so there is no need to echo the
// owner id back, and doing so would be one more place a client could try to
// read/spoof it from.
const findByOwnerId = async (ownerId) => {
  const [rows] = await pool.execute(
    'SELECT id, name, description, logo, cover_image, address, phone, status, created_at, updated_at FROM stores WHERE owner_id = ? ORDER BY created_at DESC',
    [ownerId]
  );
  return rows;
};

module.exports = {
  findAllActive,
  findById,
  findOwnerId,
  findByOwnerId
};
