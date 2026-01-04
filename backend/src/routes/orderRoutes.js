const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const auth = require('../middleware/authMiddleware');

// Protected Routes (Waiter/Manager)
router.get('/', auth, orderController.getOrders);
router.get('/:id', auth, orderController.getOrder);
router.post('/', auth, orderController.createOrder); // Waiters must be logged in
router.patch('/:id/status', auth, orderController.updateOrderStatus);

module.exports = router;
