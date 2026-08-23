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

module.exports = {
  findAllActive,
  findById,
  findOwnerId
};
