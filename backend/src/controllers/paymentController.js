const Stripe = require('stripe');
const stripe = process.env.STRIPE_SECRET_KEY ? new Stripe(process.env.STRIPE_SECRET_KEY) : null;

exports.createPaymentIntent = async (req, res) => {
    if (!stripe) {
        console.error('Stripe Secret Key is missing');
        return res.status(503).json({ message: 'Payment service unavailable (Configuration Error)' });
    }

    try {
        const { amount, currency } = req.body;

        if (!amount || !currency) {
            return res.status(400).json({ message: 'Amount and currency are required' });
        }

        const paymentIntent = await stripe.paymentIntents.create({
            amount: Math.round(amount * 100), // Convert to cents
            currency: currency,
            automatic_payment_methods: {
                enabled: true,
            },
        });

        res.json({
            clientSecret: paymentIntent.client_secret,
        });
    } catch (error) {
        console.error('Stripe Error:', error);
        res.status(500).json({ message: 'Payment initiation failed', error: error.message });
    }
};

exports.getStripeConfig = (req, res) => {
    res.json({
        publishableKey: process.env.STRIPE_PUBLISHABLE_KEY
    });
};
