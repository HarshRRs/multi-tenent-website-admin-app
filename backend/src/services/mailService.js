const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST || 'smtp.gmail.com',
    port: process.env.EMAIL_PORT || 587,
    secure: process.env.EMAIL_SECURE === 'true', // true for 465, false for other ports
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
    },
});

exports.sendResetCode = async (email, code) => {
    // If no email config, log it and return (to prevent crash in dev)
    if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS) {
        console.warn('WARNING: Email credentials missing. Check your .env file.');
        console.log(`[MAIL MOCK] To: ${email}, Code: ${code}`);
        return;
    }

    const mailOptions = {
        from: `"Cosmos Admin Support" <${process.env.EMAIL_USER}>`,
        to: email,
        subject: 'Password Reset Code - Cosmos Admin',
        html: `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 10px;">
                <h2 style="color: #ff5e3a; text-align: center;">Cosmos Admin Password Reset</h2>
                <p>Hello,</p>
                <p>You requested a password reset for your Cosmos Admin account. Use the code below to proceed:</p>
                <div style="background-color: #f9f9f9; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;">
                    <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #1a1a1a;">${code}</span>
                </div>
                <p>This code will expire in 15 minutes.</p>
                <p>If you didn't request this, you can safely ignore this email.</p>
                <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
                <p style="font-size: 12px; color: #888; text-align: center;">Cosmos Admin Inc. | Powered by Advanced Agentic Coding</p>
            </div>
        `,
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log(`Email sent successfully to ${email}`);
    } catch (error) {
        console.error('Email Error:', error);
        throw new Error('Failed to send reset email');
    }
};
