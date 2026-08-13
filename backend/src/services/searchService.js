const searchRepository = require('../repositories/searchRepository');

const search = async (query) => {
  try {
    if (!query || typeof query !== 'string') {
      return { products: [], stores: [] };
    }
    
    const trimmedQuery = query.trim();
    
    if (trimmedQuery.length < 2) {
      return { products: [], stores: [] };
    }
    
    const results = await searchRepository.search(trimmedQuery);
    return results;
  } catch (error) {
    console.error('Search error:', error);
    throw new Error('Search failed');
  }
};

module.exports = {
  search
};
