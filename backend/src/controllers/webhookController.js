const Stripe = require('stripe');
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const websocketService = require('../services/websocketService');
const emailService = require('../services/emailService');

exports.handleStripeWebhook = async (req, res) => {
    const sig = req.headers['stripe-signature'];
    let event;

    try {
        event = stripe.webhooks.constructEvent(
            req.body,
            sig,
            process.env.STRIPE_WEBHOOK_SECRET
        );
    } catch (err) {
        console.error(`Webhook Error: ${err.message}`);
        return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    // Handle the event
    switch (event.type) {
        case 'payment_intent.succeeded':
            const paymentIntent = event.data.object;
            await handlePaymentSuccess(paymentIntent);
            break;
        case 'payment_intent.payment_failed':
            const failedIntent = event.data.object;
            await handlePaymentFailure(failedIntent);
            break;
        default:
            console.log(`Unhandled event type ${event.type}`);
    }

    res.json({ received: true });
};

async function handlePaymentSuccess(paymentIntent) {
    console.log(`Payment SUCCESS: ${paymentIntent.id}`);

    try {
        // Find the order with this payment intent ID
        const order = await prisma.order.findFirst({
            where: { stripePaymentIntentId: paymentIntent.id },
            include: { items: true, user: true }
        });

        if (order) {
            // Update order status
            await prisma.order.update({
                where: { id: order.id },
                data: { paymentStatus: 'paid' }
            });

            console.log(`Order ${order.id} marked as PAID`);

            // Notify admin via WebSocket
            websocketService.sendToUser(order.userId, {
                type: 'payment_update',
                orderId: order.id,
                paymentStatus: 'paid'
            });

            // Send confirmation email (if not already sent)
            if (order.customerEmail) {
                await emailService.sendOrderConfirmation(order, order.customerEmail, order.user)
                    .catch(err => console.error('Email error in webhook:', err));
            }
        }
    } catch (error) {
        console.error('Error processing payment success webhook:', error);
    }
}

async function handlePaymentFailure(paymentIntent) {
    console.log(`Payment FAILED: ${paymentIntent.id}`);

    try {
        const order = await prisma.order.findFirst({
            where: { stripePaymentIntentId: paymentIntent.id }
        });

        if (order) {
            await prisma.order.update({
                where: { id: order.id },
                data: { paymentStatus: 'failed' }
            });

            websocketService.sendToUser(order.userId, {
                type: 'payment_update',
                orderId: order.id,
                paymentStatus: 'failed'
            });
        }
    } catch (error) {
        console.error('Error processing payment failure webhook:', error);
    }
}
