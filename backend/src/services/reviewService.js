const reviewRepository = require('../repositories/reviewRepository');
const productRepository = require('../repositories/productRepository');

const MIN_RATING = 1;
const MAX_RATING = 5;
const MAX_COMMENT_LENGTH = 1000;

const isValidRating = (rating) => {
  const numRating = Number(rating);
  return Number.isInteger(numRating) && numRating >= MIN_RATING && numRating <= MAX_RATING;
};

const normalizeComment = (comment) => {
  if (comment === undefined || comment === null) return null;
  const trimmed = String(comment).trim();
  return trimmed.length > 0 ? trimmed : null;
};

const getProductReviews = async (productId) => {
  try {
    const reviews = await reviewRepository.findByProductId(productId);
    const summary = await reviewRepository.getRatingSummary(productId);
    return { reviews, summary };
  } catch (error) {
    console.error('Error fetching product reviews:', error);
    throw new Error('Failed to fetch reviews');
  }
};

const checkEligibility = async (userId, productId) => {
  try {
    const product = await productRepository.findById(productId);
    if (!product) {
      const error = new Error('Product not found');
      error.code = 'PRODUCT_NOT_FOUND';
      throw error;
    }

    const existingReview = await reviewRepository.findByUserAndProduct(userId, productId);
    const purchased = await reviewRepository.hasPurchased(userId, productId);

    return {
      hasPurchased: purchased,
      hasReviewed: !!existingReview,
      canReview: purchased && !existingReview,
      existingReview
    };
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error checking review eligibility:', error);
    throw new Error('Failed to check review eligibility');
  }
};

const createReview = async (userId, productId, reviewData) => {
  try {
    const { rating, comment } = reviewData;

    if (!isValidRating(rating)) {
      const error = new Error('Rating must be an integer between 1 and 5');
      error.code = 'INVALID_RATING';
      throw error;
    }

    if (comment !== undefined && comment !== null && String(comment).length > MAX_COMMENT_LENGTH) {
      const error = new Error('Comment is too long');
      error.code = 'COMMENT_TOO_LONG';
      throw error;
    }

    // Product must exist
    const product = await productRepository.findById(productId);
    if (!product) {
      const error = new Error('Product not found');
      error.code = 'PRODUCT_NOT_FOUND';
      throw error;
    }

    // Prevent duplicate reviews from the same user for the same product
    const existingReview = await reviewRepository.findByUserAndProduct(userId, productId);
    if (existingReview) {
      const error = new Error('You have already reviewed this product');
      error.code = 'ALREADY_REVIEWED';
      throw error;
    }

    // Only allow reviews from users who purchased the product via a delivered order
    const purchased = await reviewRepository.hasPurchased(userId, productId);
    if (!purchased) {
      const error = new Error('You can only review products from delivered orders');
      error.code = 'PURCHASE_REQUIRED';
      throw error;
    }

    const reviewId = await reviewRepository.create(
      userId,
      productId,
      Math.round(Number(rating)),
      normalizeComment(comment)
    );
    return { id: reviewId };
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error creating review:', error);
    throw new Error('Failed to create review');
  }
};

const updateReview = async (id, userId, reviewData) => {
  try {
    const { rating, comment } = reviewData;

    if (!isValidRating(rating)) {
      const error = new Error('Rating must be an integer between 1 and 5');
      error.code = 'INVALID_RATING';
      throw error;
    }

    if (comment !== undefined && comment !== null && String(comment).length > MAX_COMMENT_LENGTH) {
      const error = new Error('Comment is too long');
      error.code = 'COMMENT_TOO_LONG';
      throw error;
    }

    // Ownership check: the review must exist and belong to this user
    const existing = await reviewRepository.findById(id);
    if (!existing || existing.user_id !== userId) {
      const error = new Error('Review not found');
      error.code = 'REVIEW_NOT_FOUND';
      throw error;
    }

    const updated = await reviewRepository.update(
      id,
      userId,
      Math.round(Number(rating)),
      normalizeComment(comment)
    );
    if (!updated) {
      const error = new Error('Review not found');
      error.code = 'REVIEW_NOT_FOUND';
      throw error;
    }

    return { success: true };
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error updating review:', error);
    throw new Error('Failed to update review');
  }
};

const deleteReview = async (id, userId) => {
  try {
    // Ownership check: the review must exist and belong to this user
    const existing = await reviewRepository.findById(id);
    if (!existing || existing.user_id !== userId) {
      const error = new Error('Review not found');
      error.code = 'REVIEW_NOT_FOUND';
      throw error;
    }

    const deleted = await reviewRepository.remove(id, userId);
    if (!deleted) {
      const error = new Error('Review not found');
      error.code = 'REVIEW_NOT_FOUND';
      throw error;
    }

    return { success: true };
  } catch (error) {
    if (error.code) {
      throw error;
    }
    console.error('Error deleting review:', error);
    throw new Error('Failed to delete review');
  }
};

module.exports = {
  getProductReviews,
  checkEligibility,
  createReview,
  updateReview,
  deleteReview
};
