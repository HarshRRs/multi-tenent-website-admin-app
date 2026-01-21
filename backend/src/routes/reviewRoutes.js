const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');
const authenticate = require('../middleware/authMiddleware');

// Public routes
router.post('/submit', reviewController.submitReview);
router.get('/product/:productId', reviewController.getProductReviews);

// Protected routes (Manager)
router.get('/manager', authenticate, reviewController.getManagerReviews);
router.patch('/:id/approve', authenticate, reviewController.approveReview);
router.delete('/:id', authenticate, reviewController.deleteReview);

module.exports = router;
