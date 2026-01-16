const express = require('express');
const router = express.Router();
const websiteController = require('../controllers/websiteController');

const orderController = require('../controllers/orderController');
const reservationController = require('../controllers/reservationController');

// Public Access (No Auth)
// Prefix in server.js will be /public
router.get('/config/:restaurantId', websiteController.getPublicConfig);
router.get('/menu/:restaurantId', websiteController.getPublicMenu);
router.post('/order', orderController.createPublicOrder);
router.post('/reservation', reservationController.createPublicReservation);

module.exports = router;
