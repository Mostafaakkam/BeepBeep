const express = require('express');
const router = express.Router();
const { authenticate } = require('../middlewares/authMiddleware');
const {
  getProductReviews,
  checkEligibility,
  createReview,
  updateReview,
  deleteReview
} = require('../controllers/reviewController');

// Public: view a product's reviews and rating summary
router.get('/product/:productId', getProductReviews);

// Authenticated: check whether the current user can review this product
// (purchased via a delivered order, and hasn't already reviewed it)
router.get('/product/:productId/eligibility', authenticate, checkEligibility);

// Authenticated: submit a new review for a product
router.post('/product/:productId', authenticate, createReview);

// Authenticated: edit or delete a review the user owns (ownership enforced in service/repository)
router.patch('/:id', authenticate, updateReview);
router.delete('/:id', authenticate, deleteReview);

module.exports = router;
