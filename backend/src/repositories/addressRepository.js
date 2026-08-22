const pool = require('../config/database');

const getAll = async (userId) => {
  const [addresses] = await pool.execute(
    `SELECT id, user_id, label, recipient_name, phone, address, is_default, created_at, updated_at
     FROM addresses 
     WHERE user_id = ? 
     ORDER BY is_default DESC, created_at DESC`,
    [userId]
  );
  return addresses;
};

const findById = async (id, userId) => {
  const [addresses] = await pool.execute(
    `SELECT id, user_id, label, recipient_name, phone, address, is_default, created_at, updated_at
     FROM addresses 
     WHERE id = ? AND user_id = ?`,
    [id, userId]
  );
  return addresses[0] || null;
};

const create = async (userId, addressData) => {
  const { label, recipient_name, phone, address, is_default } = addressData;
  
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
      `INSERT INTO addresses (user_id, label, recipient_name, phone, address, is_default, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [userId, label, recipient_name, phone, address, is_default ? 1 : 0]
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
  const { label, recipient_name, phone, address, is_default } = addressData;
  
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
       SET label = ?, recipient_name = ?, phone = ?, address = ?, is_default = ?, updated_at = NOW()
       WHERE id = ? AND user_id = ?`,
      [label, recipient_name, phone, address, is_default ? 1 : 0, id, userId]
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
      'UPDATE addresses SET is_default = 1, updated_at = NOW() WHERE id = ? AND user_id = ?',
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
    `SELECT id, user_id, label, recipient_name, phone, address, is_default, created_at, updated_at
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
