const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const prisma = require('../config/database');

/**
 * Production-ready Stripe Payment Service
 * Handles payment intent creation and confirmation
 */

/**
 * Create a Stripe Payment Intent for an order
 * @param {number} amount - Amount in dollars (will be converted to cents)
 * @param {string} restaurantId - Restaurant user ID
 * @param {object} metadata - Additional order metadata
 * @returns {Promise<object>} Payment Intent with client secret
 */
exports.createPaymentIntent = async (amount, restaurantId, metadata = {}) => {
    try {
        // Get restaurant's Stripe account (if using Connect)
        const restaurant = await prisma.user.findUnique({
            where: { id: restaurantId },
            select: { stripeAccountId: true, name: true }
        });

        // Convert amount to cents (Stripe requires smallest currency unit)
        const amountInCents = Math.round(amount * 100);

        const paymentIntentParams = {
            amount: amountInCents,
            currency: 'usd',
            metadata: {
                restaurantId,
                restaurantName: restaurant?.name || 'Restaurant',
                ...metadata
            },
            description: `Order from ${restaurant?.name || 'Restaurant'}`,
            automatic_payment_methods: {
                enabled: true,
            }
        };

        // If restaurant has Stripe Connect account, use it
        if (restaurant?.stripeAccountId) {
            paymentIntentParams.application_fee_amount = Math.round(amountInCents * 0.03); // 3% platform fee
            paymentIntentParams.transfer_data = {
                destination: restaurant.stripeAccountId
            };
        }

        const paymentIntent = await stripe.paymentIntents.create(paymentIntentParams);

        return {
            clientSecret: paymentIntent.client_secret,
            paymentIntentId: paymentIntent.id,
            amount: paymentIntent.amount,
            status: paymentIntent.status
        };
    } catch (error) {
        console.error('Stripe Payment Intent Creation Error:', error);
        throw new Error(`Payment processing failed: ${error.message}`);
    }
};

/**
 * Confirm a payment has been completed
 * @param {string} paymentIntentId - Stripe Payment Intent ID
 * @returns {Promise<boolean>} True if payment succeeded
 */
exports.confirmPayment = async (paymentIntentId) => {
    try {
        const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
        return paymentIntent.status === 'succeeded';
    } catch (error) {
        console.error('Payment Confirmation Error:', error);
        return false;
    }
};

/**
 * Refund a payment
 * @param {string} paymentIntentId - Stripe Payment Intent ID
 * @param {number} amount - Amount to refund in dollars (optional, full refund if not provided)
 * @returns {Promise<object>} Refund object
 */
exports.refundPayment = async (paymentIntentId, amount = null) => {
    try {
        const refundParams = {
            payment_intent: paymentIntentId
        };

        if (amount) {
            refundParams.amount = Math.round(amount * 100);
        }

        const refund = await stripe.refunds.create(refundParams);
        return refund;
    } catch (error) {
        console.error('Payment Refund Error:', error);
        throw new Error(`Refund failed: ${error.message}`);
    }
};
