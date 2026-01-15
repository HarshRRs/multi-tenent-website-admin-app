const Stripe = require('stripe');
const stripe = process.env.STRIPE_SECRET_KEY ? new Stripe(process.env.STRIPE_SECRET_KEY) : null;

if (!stripe) {
    console.warn('Warning: Stripe Secret Key is missing. Payment features will be disabled.');
}

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

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

exports.createConnectedAccount = async (req, res) => {
    if (!stripe) {
        console.error('Stripe Secret Key is missing');
        return res.status(503).json({ message: 'Payment service unavailable (Configuration Error)' });
    }

    try {
        const userId = req.user.id;
        const { email, country } = req.body;

        // Find user to check if they already have a connected account
        const user = await prisma.user.findUnique({
            where: { id: userId }
        });

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        let accountId = user.stripeAccountId;

        if (!accountId) {
            const account = await stripe.accounts.create({
                type: 'express',
                country: country || 'US',
                email: email || user.email,
                capabilities: {
                    card_payments: { requested: true },
                    transfers: { requested: true },
                },
            });
            accountId = account.id;

            // Save stripeAccountId to user
            await prisma.user.update({
                where: { id: userId },
                data: { stripeAccountId: accountId }
            });
        }

        const refreshUrl = process.env.STRIPE_CONNECT_REFRESH_URL || 'https://rockster.com/connect/refresh';
        const returnUrl = process.env.STRIPE_CONNECT_RETURN_URL || 'https://rockster.com/connect/return';

        const accountLink = await stripe.accountLinks.create({
            account: accountId,
            refresh_url: refreshUrl,
            return_url: returnUrl,
            type: 'account_onboarding',
        });

        res.json({
            url: accountLink.url,
        });
    } catch (error) {
        console.error('Stripe Connect Error:', error);
        res.status(500).json({ message: 'Failed to create connected account', error: error.message });
    }
};

exports.getStripeAccount = async (req, res) => {
    if (!stripe) return res.status(503).json({ message: 'Stripe disabled' });

    try {
        const user = await prisma.user.findUnique({
            where: { id: req.user.id }
        });

        if (!user || !user.stripeAccountId) {
            return res.json({
                isConnected: false,
                accountId: '',
                availableBalance: 0,
                pendingBalance: 0
            });
        }

        const account = await stripe.accounts.retrieve(user.stripeAccountId);
        const balance = await stripe.balance.retrieve({
            stripeAccount: user.stripeAccountId
        });

        res.json({
            isConnected: account.details_submitted,
            accountId: user.stripeAccountId,
            availableBalance: balance.available[0]?.amount / 100 || 0,
            pendingBalance: balance.pending[0]?.amount / 100 || 0,
            currency: balance.available[0]?.currency || 'eur'
        });

    } catch (error) {
        console.error('Stripe Account Error:', error);
        res.status(500).json({ message: 'Failed to fetch account', error: error.message });
    }
};

exports.getTransactions = async (req, res) => {
    if (!stripe) return res.json([]);

    try {
        const user = await prisma.user.findUnique({
            where: { id: req.user.id }
        });

        if (!user || !user.stripeAccountId) {
            return res.json([]);
        }

        const charges = await stripe.charges.list({
            limit: 20,
        }, {
            stripeAccount: user.stripeAccountId
        });

        const transactions = charges.data.map(charge => ({
            id: charge.id,
            amount: charge.amount / 100,
            currency: charge.currency,
            status: charge.refunded ? 'refunded' : (charge.status === 'succeeded' ? 'completed' : 'failed'),
            date: new Date(charge.created * 1000).toISOString(),
            customerName: charge.billing_details?.name || 'Unknown Customer',
            paymentMethod: charge.payment_method_details?.card?.brand || 'card',
        }));

        res.json(transactions);

    } catch (error) {
        console.error('Stripe Transactions Error:', error);
        res.status(500).json({ message: 'Failed to fetch transactions', error: error.message });
    }
};
