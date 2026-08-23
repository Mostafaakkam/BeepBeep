const reviewService = require('../services/reviewService');

const getProductReviews = async (req, res) => {
  try {
    const { productId } = req.params;
    const result = await reviewService.getProductReviews(parseInt(productId));

    res.status(200).json({
      success: true,
      message: 'Reviews retrieved successfully',
      data: result
    });
  } catch (error) {
    console.error('Get product reviews error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve reviews'
    });
  }
};

const checkEligibility = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { productId } = req.params;

    const result = await reviewService.checkEligibility(userId, parseInt(productId));

    res.status(200).json({
      success: true,
      data: result
    });
  } catch (error) {
    if (error.code === 'PRODUCT_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    console.error('Check review eligibility error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to check review eligibility'
    });
  }
};

const createReview = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { productId } = req.params;
    const { rating, comment } = req.body;

    const result = await reviewService.createReview(userId, parseInt(productId), { rating, comment });

    res.status(201).json({
      success: true,
      message: 'Review submitted successfully',
      data: result
    });
  } catch (error) {
    if (error.code === 'PRODUCT_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    if (error.code === 'INVALID_RATING') {
      return res.status(400).json({
        success: false,
        message: 'Rating must be an integer between 1 and 5'
      });
    }

    if (error.code === 'COMMENT_TOO_LONG') {
      return res.status(400).json({
        success: false,
        message: 'Comment is too long'
      });
    }

    if (error.code === 'ALREADY_REVIEWED') {
      return res.status(409).json({
        success: false,
        message: 'You have already reviewed this product'
      });
    }

    if (error.code === 'PURCHASE_REQUIRED') {
      return res.status(403).json({
        success: false,
        message: 'You can only review products from delivered orders'
      });
    }

    console.error('Create review error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to submit review'
    });
  }
};

const updateReview = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    const { rating, comment } = req.body;

    await reviewService.updateReview(parseInt(id), userId, { rating, comment });

    res.status(200).json({
      success: true,
      message: 'Review updated successfully'
    });
  } catch (error) {
    if (error.code === 'REVIEW_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }

    if (error.code === 'INVALID_RATING') {
      return res.status(400).json({
        success: false,
        message: 'Rating must be an integer between 1 and 5'
      });
    }

    if (error.code === 'COMMENT_TOO_LONG') {
      return res.status(400).json({
        success: false,
        message: 'Comment is too long'
      });
    }

    console.error('Update review error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to update review'
    });
  }
};

const deleteReview = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    await reviewService.deleteReview(parseInt(id), userId);

    res.status(200).json({
      success: true,
      message: 'Review deleted successfully'
    });
  } catch (error) {
    if (error.code === 'REVIEW_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }

    console.error('Delete review error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to delete review'
    });
  }
};

module.exports = {
  getProductReviews,
  checkEligibility,
  createReview,
  updateReview,
  deleteReview
};
