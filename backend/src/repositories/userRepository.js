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

module.exports = {
  findByEmail,
  findByEmailWithPassword,
  findByPhone,
  findById,
  create
};
