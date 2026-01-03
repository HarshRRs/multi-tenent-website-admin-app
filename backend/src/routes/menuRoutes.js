const express = require('express');
const router = express.Router();
const menuController = require('../controllers/menuController');
const auth = require('../middleware/authMiddleware'); // Optional: Protect writes

// Public Routes (Read)
router.get('/categories', menuController.getCategories);
router.get('/products', menuController.getProducts);

// Protected Routes (Write)
// Ensure user is logged in to modify menu
router.post('/categories', auth, menuController.createCategory);
router.post('/products', auth, menuController.createProduct);
router.patch('/products/:id/availability', auth, menuController.updateAvailability);

module.exports = router;
