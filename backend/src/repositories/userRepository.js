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
  create
};
