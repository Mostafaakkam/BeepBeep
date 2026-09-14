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

// Admin Dashboard: store counts grouped by status (pending/active/inactive),
// platform-wide. Same shape as orderRepository.countByStoreIdGroupedByStatus
// (Store Owner Dashboard), unscoped by owner.
const countGroupedByStatus = async () => {
  const [rows] = await pool.execute(
    'SELECT status, COUNT(*) as count FROM stores GROUP BY status'
  );
  const counts = {};
  for (const row of rows) {
    counts[row.status] = Number(row.count);
  }
  return counts;
};

// Admin Dashboard: every store, any status, with resolved owner info
// (name/email) via a single LEFT JOIN against users -- avoids N+1 queries,
// and correctly returns null owner fields for a store with no owner_id
// (LEFT JOIN, not INNER). Optionally filtered by status (validated by the
// caller before reaching here -- see adminService.getStores). Unlike every
// other store-reading function in this file, this deliberately DOES expose
// owner_id: this query is only ever reached via GET /api/admin/stores
// (requireRole('admin') -- see routes/adminRoutes.js), the one context in
// this codebase where surfacing ownership is the entire point rather than a
// spoofing risk (contrast findOwnerId()'s comment above).
const findAllForAdmin = async (status) => {
  let query = `
    SELECT s.id, s.name, s.status, s.owner_id,
           u.name as owner_name, u.email as owner_email,
           s.created_at
    FROM stores s
    LEFT JOIN users u ON s.owner_id = u.id
  `;
  const params = [];

  if (status) {
    query += ' WHERE s.status = ?';
    params.push(status);
  }

  query += ' ORDER BY s.created_at DESC';

  const [rows] = await pool.execute(query, params);
  return rows;
};

// Admin Store Status Management: a single store in the same admin shape as
// findAllForAdmin (id, name, status, owner_id, owner_name, owner_email,
// created_at). Used both to check a store exists before mutating it and to
// return the updated store afterward, so the mutation response matches
// GET /api/admin/stores's shape exactly instead of introducing a second,
// incompatible representation.
const findByIdForAdmin = async (storeId) => {
  const [rows] = await pool.execute(
    `SELECT s.id, s.name, s.status, s.owner_id,
            u.name as owner_name, u.email as owner_email,
            s.created_at
     FROM stores s
     LEFT JOIN users u ON s.owner_id = u.id
     WHERE s.id = ?`,
    [storeId]
  );
  return rows[0] || null;
};

// Admin Store Status Management: updates a store's status. storeId
// existence is already verified by the caller (adminService.updateStoreStatus
// via findByIdForAdmin) before this runs, and status is already validated
// against the real enum values -- this is purely the write.
const updateStatus = async (storeId, status) => {
  await pool.execute(
    'UPDATE stores SET status = ?, updated_at = NOW() WHERE id = ?',
    [status, storeId]
  );
};

// Admin Store Owner Assignment: updates a store's owner_id. ownerId may be
// null -- an explicit removal, not a special case: two of the seeded stores
// already start unowned (owner_id IS NULL) as an intentional, fully-supported
// business state (see seed.js's own "no owner yet" case, and
// findOwnerId/findAllForAdmin above, both of which already handle a null
// owner gracefully) -- this just lets an admin transition a store back into
// that same, already-real state. Deliberately touches ONLY stores.owner_id;
// never writes to users.role, so assigning a store never silently changes
// what role the target user holds.
const updateOwner = async (storeId, ownerId) => {
  await pool.execute(
    'UPDATE stores SET owner_id = ?, updated_at = NOW() WHERE id = ?',
    [ownerId, storeId]
  );
};

module.exports = {
  findAllActive,
  findById,
  findOwnerId,
  findByOwnerId,
  countGroupedByStatus,
  findAllForAdmin,
  findByIdForAdmin,
  updateStatus,
  updateOwner
};
