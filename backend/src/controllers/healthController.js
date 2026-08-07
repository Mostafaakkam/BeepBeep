const pool = require('../config/database');

const getHealth = async (req, res) => {
  try {
    // Test database connection
    const connection = await pool.getConnection();
    await connection.ping();
    connection.release();

    res.json({
      success: true,
      message: 'Beep Beep API is running',
      database: 'connected'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Beep Beep API is running but database connection failed',
      database: 'disconnected',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

module.exports = {
  getHealth
};
