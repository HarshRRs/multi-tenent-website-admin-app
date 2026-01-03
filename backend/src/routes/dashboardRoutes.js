const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');
// Dashboard is likely internal/manager only, so protected.
const auth = require('../middleware/authMiddleware');

router.get('/stats', auth, dashboardController.getStats);
router.get('/recent-orders', auth, dashboardController.getRecentOrders);

module.exports = router;
