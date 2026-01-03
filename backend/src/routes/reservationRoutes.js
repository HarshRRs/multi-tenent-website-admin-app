const express = require('express');
const router = express.Router();
const reservationController = require('../controllers/reservationController');
const auth = require('../middleware/authMiddleware');

router.get('/', reservationController.getReservations);
router.post('/', auth, reservationController.createReservation);

module.exports = router;
