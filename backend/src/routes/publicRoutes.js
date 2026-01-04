const express = require('express');
const router = express.Router();
const websiteController = require('../controllers/websiteController');

// Public Access (No Auth)
// Prefix in server.js will be /public
router.get('/config/:restaurantId', websiteController.getPublicConfig);
router.get('/menu/:restaurantId', websiteController.getPublicMenu);

module.exports = router;
