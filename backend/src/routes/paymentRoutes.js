const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const auth = require('../middleware/authMiddleware');

router.get('/config', paymentController.getStripeConfig);
router.post('/create-payment-intent', auth, paymentController.createPaymentIntent);

module.exports = router;
