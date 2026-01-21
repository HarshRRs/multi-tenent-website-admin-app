const express = require('express');
const router = express.Router();
const emailService = require('../services/emailService');
const transporter = require('nodemailer').createTransport({
    host: process.env.EMAIL_HOST || 'smtp.gmail.com',
    port: parseInt(process.env.EMAIL_PORT) || 587,
    secure: process.env.EMAIL_SECURE === 'true',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

// Test Endpoint
router.get('/test-email', async (req, res) => {
    try {
        const testEmail = req.query.email || process.env.EMAIL_USER;
        if (!testEmail) return res.status(400).send('No recipient email provided (query param ?email=...)');

        console.log(`Testing email to: ${testEmail}`);
        console.log(`Config: User=${process.env.EMAIL_USER ? 'Set' : 'Missing'}, Pass=${process.env.EMAIL_PASS ? 'Set' : 'Missing'}`);

        await transporter.verify(); // Verify connection first
        console.log('SMTP Connection Verified');

        const info = await transporter.sendMail({
            from: process.env.EMAIL_USER,
            to: testEmail,
            subject: 'Test Email from Cosmos Admin',
            text: 'If you see this, your email configuration is working perfectly!'
        });

        res.json({
            message: 'Email sent successfully!',
            config: {
                user: process.env.EMAIL_USER ? `${process.env.EMAIL_USER.substring(0, 3)}...` : 'MISSING',
                pass: process.env.EMAIL_PASS ? 'SET' : 'MISSING',
                host: process.env.EMAIL_HOST
            },
            messageId: info.messageId,
            recipient: testEmail
        });
    } catch (error) {
        console.error('Email Test Failed:', error);
        res.status(500).json({
            message: 'Email failed',
            error: error.message,
            stack: error.stack
        });
    }
});

module.exports = router;
