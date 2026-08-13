const searchService = require('../services/searchService');

const search = async (req, res) => {
  try {
    const { q } = req.query;
    
    const results = await searchService.search(q);
    
    res.status(200).json({
      success: true,
      message: 'Search completed successfully',
      data: results
    });
  } catch (error) {
    console.error('Search error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Search failed'
    });
  }
};

module.exports = {
  search
};
