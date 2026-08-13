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

module.exports = {
  findAllActive,
  findById
};
