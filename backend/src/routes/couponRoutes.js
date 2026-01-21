const express = require('express');
const router = express.Router();
const couponController = require('../controllers/couponController');
const authenticate = require('../middleware/authMiddleware');

// Public route for validation
router.post('/validate', couponController.validateCoupon);

// Protected routes for management
router.post('/', authenticate, couponController.createCoupon);
router.get('/', authenticate, couponController.getCoupons);
router.patch('/:id/toggle', authenticate, couponController.toggleCoupon);
router.delete('/:id', authenticate, couponController.deleteCoupon);

module.exports = router;
