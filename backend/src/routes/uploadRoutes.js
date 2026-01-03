const express = require('express');
const router = express.Router();
const uploadController = require('../controllers/uploadController');
const auth = require('../middleware/authMiddleware');

// Protected Route (Authenticated users only)
router.post('/', auth, uploadController.uploadMiddleware, uploadController.uploadImage);

module.exports = router;
