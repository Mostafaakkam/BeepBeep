const pool = require('../config/database');

// Stabilization fix (2026-08-30): the live `addresses` table only ever had
// (id, user_id, city, area, details, is_default) -- it never had label,
// recipient_name, phone, address, created_at, or updated_at, which this
// repository used to assume. Every query below now selects/writes only the
// columns that actually exist on the live table. See the stabilization
// audit report for how this was discovered (every address endpoint was
// returning 500 against the real database).

const getAll = async (userId) => {
  const [addresses] = await pool.execute(
    `SELECT id, user_id, city, area, details, is_default
     FROM addresses
     WHERE user_id = ?
     ORDER BY is_default DESC, id DESC`,
    [userId]
  );
  return addresses;
};

const findById = async (id, userId) => {
  const [addresses] = await pool.execute(
    `SELECT id, user_id, city, area, details, is_default
     FROM addresses
     WHERE id = ? AND user_id = ?`,
    [id, userId]
  );
  return addresses[0] || null;
};

const create = async (userId, addressData) => {
  const { city, area, details, is_default } = addressData;

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    // If setting as default, unset previous default
    if (is_default) {
      await connection.execute(
        'UPDATE addresses SET is_default = 0 WHERE user_id = ?',
        [userId]
      );
    }

    const [result] = await connection.execute(
      `INSERT INTO addresses (user_id, city, area, details, is_default)
       VALUES (?, ?, ?, ?, ?)`,
      [userId, city, area || null, details || null, is_default ? 1 : 0]
    );

    await connection.commit();
    return result.insertId;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};

const update = async (id, userId, addressData) => {
  const { city, area, details, is_default } = addressData;

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    // If setting as default, unset previous default
    if (is_default) {
      await connection.execute(
        'UPDATE addresses SET is_default = 0 WHERE user_id = ? AND id != ?',
        [userId, id]
      );
    }

    const [result] = await connection.execute(
      `UPDATE addresses
       SET city = ?, area = ?, details = ?, is_default = ?
       WHERE id = ? AND user_id = ?`,
      [city, area || null, details || null, is_default ? 1 : 0, id, userId]
    );

    await connection.commit();
    return result.affectedRows > 0;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};

const remove = async (id, userId) => {
  const [result] = await pool.execute(
    'DELETE FROM addresses WHERE id = ? AND user_id = ?',
    [id, userId]
  );
  return result.affectedRows > 0;
};

const setDefault = async (id, userId) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    // Unset previous default
    await connection.execute(
      'UPDATE addresses SET is_default = 0 WHERE user_id = ?',
      [userId]
    );

    // Set new default
    await connection.execute(
      'UPDATE addresses SET is_default = 1 WHERE id = ? AND user_id = ?',
      [id, userId]
    );

    await connection.commit();
    return true;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};

const getDefault = async (userId) => {
  const [addresses] = await pool.execute(
    `SELECT id, user_id, city, area, details, is_default
     FROM addresses
     WHERE user_id = ? AND is_default = 1`,
    [userId]
  );
  return addresses[0] || null;
};

module.exports = {
  getAll,
  findById,
  create,
  update,
  remove,
  setDefault,
  getDefault
};
