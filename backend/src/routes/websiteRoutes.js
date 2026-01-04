const express = require('express');
const router = express.Router();
const websiteController = require('../controllers/websiteController');
const auth = require('../middleware/authMiddleware');

router.get('/', auth, websiteController.getWebsiteConfig);
// Using PUT to update/create
router.put('/', auth, websiteController.updateWebsiteConfig);

module.exports = router;
