const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const auth = require('../middleware/authMiddleware');

router.get('/config', paymentController.getStripeConfig);
router.post('/create-payment-intent', auth, paymentController.createPaymentIntent);
router.post('/create-connected-account', auth, paymentController.createConnectedAccount);

module.exports = router;
