const pool = require('../config/database');

const findByEmail = async (email) => {
  const [rows] = await pool.execute(
    'SELECT id, name, phone, email, role, created_at, updated_at FROM users WHERE email = ?',
    [email]
  );
  return rows[0] || null;
};

const findByEmailWithPassword = async (email) => {
  const [rows] = await pool.execute(
    'SELECT id, name, phone, email, password, role, created_at, updated_at FROM users WHERE email = ?',
    [email]
  );
  return rows[0] || null;
};

const findByPhone = async (phone) => {
  const [rows] = await pool.execute(
    'SELECT id, name, phone, email, role, created_at, updated_at FROM users WHERE phone = ?',
    [phone]
  );
  return rows[0] || null;
};

// Added for Role-Based Authorization: lets authorization middleware re-fetch
// a user's CURRENT role from the database rather than trusting the role
// claim embedded in a (possibly stale, up to 7 days old) JWT. See
// middlewares/authorizationMiddleware.js#requireRole.
const findById = async (id) => {
  const [rows] = await pool.execute(
    'SELECT id, name, phone, email, role, created_at, updated_at FROM users WHERE id = ?',
    [id]
  );
  return rows[0] || null;
};

const create = async (userData) => {
  const { name, phone, email, password, role } = userData;
  const [result] = await pool.execute(
    'INSERT INTO users (name, phone, email, password, role, created_at, updated_at) VALUES (?, ?, ?, ?, ?, NOW(), NOW())',
    [name, phone, email, password, role]
  );
  
  const [newUser] = await pool.execute(
    'SELECT id, name, phone, email, role, created_at, updated_at FROM users WHERE id = ?',
    [result.insertId]
  );
  
  return newUser[0];
};

// Admin Dashboard: user counts grouped by role, for the platform-wide
// dashboard stats endpoint. Same one-query-then-reduce shape as
// orderRepository.countByStoreIdGroupedByStatus (Store Owner Dashboard), just
// unscoped -- there is no ownership/store concept for users to filter by.
const countGroupedByRole = async () => {
  const [rows] = await pool.execute(
    'SELECT role, COUNT(*) as count FROM users GROUP BY role'
  );
  const counts = {};
  for (const row of rows) {
    counts[row.role] = Number(row.count);
  }
  return counts;
};

module.exports = {
  findByEmail,
  findByEmailWithPassword,
  findByPhone,
  findById,
  create,
  countGroupedByRole
};
