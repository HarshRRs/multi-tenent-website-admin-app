const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const mailService = require('../services/mailService');

exports.register = async (req, res) => {
    try {
        const { name, email, password, role, businessType } = req.body;

        if (!email || !password || !name) {
            return res.status(400).json({ message: 'Please provide name, email and password' });
        }

        // Check existing
        const existing = await prisma.user.findUnique({ where: { email } });
        if (existing) return res.status(400).json({ message: 'Email already exists' });

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create user
        const user = await prisma.user.create({
            data: {
                name,
                email,
                password: hashedPassword,
                role: role || 'manager',
                businessType: businessType || 'restaurant'
            }
        });

        // Generate tokens
        const accessToken = jwt.sign(
            { id: user.id, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN || '1h' }
        );

        const refreshToken = jwt.sign(
            { id: user.id },
            process.env.JWT_SECRET, // Using same secret for simplicity in this project
            { expiresIn: '7d' }
        );

        res.status(201).json({
            access_token: accessToken,
            refresh_token: refreshToken,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role,
                address: user.address,
                businessType: user.businessType,
                isStoreOpen: user.isStoreOpen
            }
        });
    } catch (error) {
        console.error('Register Error:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ message: 'Please provide email and password' });
        }

        // Find user
        const user = await prisma.user.findUnique({ where: { email } });
        if (!user) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        // Check password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        // Generate tokens
        const accessToken = jwt.sign(
            { id: user.id, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN || '1h' }
        );

        const refreshToken = jwt.sign(
            { id: user.id },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.json({
            access_token: accessToken,
            refresh_token: refreshToken,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role,
                businessType: user.businessType,
                isStoreOpen: user.isStoreOpen
            }
        });
    } catch (error) {
        console.error('Login Error:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

exports.refresh = async (req, res) => {
    try {
        const { refresh_token } = req.body;
        if (!refresh_token) return res.status(400).json({ message: 'Refresh token is required' });

        const decoded = jwt.verify(refresh_token, process.env.JWT_SECRET);
        const user = await prisma.user.findUnique({ where: { id: decoded.id } });

        if (!user) return res.status(401).json({ message: 'User not found' });

        const newAccessToken = jwt.sign(
            { id: user.id, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN || '1h' }
        );

        res.json({
            access_token: newAccessToken,
            refresh_token: refresh_token
        });
    } catch (error) {
        res.status(401).json({ message: 'Invalid refresh token' });
    }
};
exports.getCurrentUser = async (req, res) => {
    try {
        const user = await prisma.user.findUnique({
            where: { id: req.user.id },
            select: { id: true, name: true, email: true, role: true, address: true, businessType: true, isStoreOpen: true }
        });
        if (!user) return res.status(404).json({ message: 'User not found' });
        res.json(user);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

exports.updateProfile = async (req, res) => {
    try {
        const { name, address, isStoreOpen } = req.body;

        // Basic validation
        if (!name) {
            return res.status(400).json({ message: 'Name is required' });
        }

        const user = await prisma.user.update({
            where: { id: req.user.id },
            data: { name, address, isStoreOpen },
            select: { id: true, name: true, email: true, role: true, address: true, businessType: true, isStoreOpen: true }
        });

        res.json(user);
    } catch (error) {
        console.error('Update Profile Error:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Persistent store for reset codes
// const resetCodes = new Map(); -> Replaced by Prisma PasswordReset model

exports.forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({ message: 'Email is required' });
        }

        const user = await prisma.user.findUnique({ where: { email } });

        // Always return success to prevent email enumeration attacks
        if (!user) {
            return res.json({ message: 'If an account exists with this email, you will receive a reset code.' });
        }

        // Generate 6-digit code
        const resetCode = Math.floor(100000 + Math.random() * 900000).toString();

        // Store code with 15-minute expiry
        // Clean up old codes
        await prisma.passwordReset.deleteMany({ where: { email } });

        await prisma.passwordReset.create({
            data: {
                email,
                code: resetCode,
                expiresAt: new Date(Date.now() + 15 * 60 * 1000)
            }
        });

        // Send email
        await mailService.sendResetCode(email, resetCode);

        res.json({
            message: 'If an account exists with this email, you will receive a reset code.'
        });
    } catch (error) {
        console.error('Forgot Password Error:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

exports.resetPassword = async (req, res) => {
    try {
        const { email, code, newPassword } = req.body;

        if (!email || !code || !newPassword) {
            return res.status(400).json({ message: 'Email, code, and new password are required' });
        }

        if (newPassword.length < 6) {
            return res.status(400).json({ message: 'Password must be at least 6 characters' });
        }

        // Find valid reset code
        const storedReset = await prisma.passwordReset.findFirst({
            where: { email, code }
        });

        if (!storedReset) {
            return res.status(400).json({ message: 'Invalid or expired reset code' });
        }

        if (new Date() > storedReset.expiresAt) {
            // Cleanup expired
            await prisma.passwordReset.deleteMany({ where: { email } });
            return res.status(400).json({ message: 'Reset code has expired' });
        }

        // Hash new password
        const hashedPassword = await bcrypt.hash(newPassword, 10);

        // Update user password
        await prisma.user.update({
            where: { email },
            data: { password: hashedPassword }
        });

        // Clear reset code
        await prisma.passwordReset.deleteMany({ where: { email } });

        res.json({ message: 'Password reset successfully. You can now login with your new password.' });
    } catch (error) {
        console.error('Reset Password Error:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};
