const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const auth = require('../middleware/authMiddleware');

// Public routes (or arguably protected, keeping consistent with mock)
// Assuming waiter/kitchen needs access, they should be authenticated.
// Mock didn't use auth for orders, but let's add auth for write ops at least,
// or maybe all if we follow `menuRoutes` pattern.
// Given the complexity, I'll leave read open or follow user pattern?
// `menuRoutes` had public read, protected write.
// `tableRoutes` has public read, protected write.
// I will stick to that pattern.

router.get('/', orderController.getOrders);
router.get('/:id', orderController.getOrder);

// Write operations
router.post('/', auth, orderController.createOrder); // Only auth users can create orders? Or guests?
// Usually waiters create orders.
router.patch('/:id/status', auth, orderController.updateOrderStatus);

module.exports = router;
