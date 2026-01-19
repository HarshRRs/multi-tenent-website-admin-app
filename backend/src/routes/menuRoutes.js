const express = require('express');
const router = express.Router();
const menuController = require('../controllers/menuController');
const auth = require('../middleware/authMiddleware');

// All Menu routes are protected (Admin)
router.get('/categories', auth, menuController.getCategories);
router.post('/categories', auth, menuController.createCategory);
router.delete('/categories/:id', auth, menuController.deleteCategory);
router.get('/products', auth, menuController.getProducts);
router.post('/products', auth, menuController.createProduct);
router.put('/products/:id', auth, menuController.updateProduct);
router.patch('/products/:id/availability', auth, menuController.updateAvailability);
router.delete('/products/:id', auth, menuController.deleteProduct);

module.exports = router;
