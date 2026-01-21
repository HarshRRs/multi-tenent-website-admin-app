const express = require('express');
const router = express.Router();
const emailService = require('../services/emailService');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Existing test email (simple text)
router.get('/test-email', async (req, res) => {
    try {
        const testEmail = req.query.email || process.env.EMAIL_USER;
        if (!testEmail) return res.status(400).send('No recipient email provided (query param ?email=...)');

        const mockRestaurant = { name: 'Test Restaurant' };
        // We'll just use a simple subject for this basic test
        await emailService.sendOrderConfirmation({
            id: 'TEST-BASIC',
            customerName: 'Basic Tester',
            totalAmount: 0,
            items: [],
            paymentMethod: 'cash'
        }, testEmail, mockRestaurant);

        res.json({ message: 'Basic test email sent!', recipient: testEmail });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Test Order Email
router.post('/test-order-email', async (req, res) => {
    try {
        const testEmail = req.body.email || process.env.EMAIL_USER;
        const mockOrder = {
            id: 'TEST-' + Math.random().toString(36).substring(2, 8).toUpperCase(),
            customerName: 'Test Customer',
            deliveryAddress: '123 Test Street, City',
            customerPhone: '+123456789',
            totalAmount: 45.99,
            paymentMethod: 'card',
            items: [
                { name: 'Pizza Margherita', quantity: 2, price: 15.00 },
                { name: 'Coca Cola', quantity: 2, price: 2.50 },
                { name: 'Garlic Bread', quantity: 1, price: 10.99 }
            ]
        };
        const mockRestaurant = { name: 'Test Restaurant' };

        await emailService.sendOrderConfirmation(mockOrder, testEmail, mockRestaurant);
        res.json({ message: 'Order confirmation test email sent!', recipient: testEmail });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Test Reservation Email
router.post('/test-reservation-email', async (req, res) => {
    try {
        const testEmail = req.body.email || process.env.EMAIL_USER;
        const mockReservation = {
            customerName: 'Test Customer',
            customerPhone: '+123456789',
            partySize: 4,
            time: new Date(Date.now() + 86400000).toISOString() // Tomorrow
        };
        const mockRestaurant = { name: 'Test Restaurant' };

        await emailService.sendReservationConfirmation(mockReservation, testEmail, mockRestaurant);
        res.json({ message: 'Reservation confirmation test email sent!', recipient: testEmail });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
