const pool = require('../config/database');

const search = async (query) => {
  if (!query || query.trim().length < 2) {
    return { products: [], stores: [] };
  }
  
  const searchTerm = `%${query.trim()}%`;
  
  // Search products
  const [products] = await pool.execute(
    `SELECT p.id, p.name, p.description, p.store_id, p.created_at,
            s.name as store_name, s.logo as store_logo, s.address as store_address
     FROM products p
     JOIN stores s ON p.store_id = s.id
     WHERE s.status = 'active' 
       AND (p.name LIKE ? OR p.description LIKE ?)
     ORDER BY p.created_at DESC
     LIMIT 20`,
    [searchTerm, searchTerm]
  );
  
  // Search stores
  const [stores] = await pool.execute(
    `SELECT id, name, description, logo, cover_image, address, phone, created_at
     FROM stores 
     WHERE status = 'active' 
       AND (name LIKE ? OR description LIKE ?)
     ORDER BY created_at DESC
     LIMIT 20`,
    [searchTerm, searchTerm]
  );
  
  return { products, stores };
};

module.exports = {
  search
};
