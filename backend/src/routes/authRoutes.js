const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const auth = require('../middleware/authMiddleware');

// @route   POST /auth/register
// @desc    Register a new user
// @access  Public
router.post('/register', authController.register);

// @route   POST /auth/login
// @desc    Login user & get token
// @access  Public
router.post('/login', authController.login);

// @route   POST /auth/refresh
// @desc    Refresh access token
// @access  Public
router.post('/refresh', authController.refresh);

// @route   GET /auth/me
// @desc    Get current user
// @access  Private
router.get('/me', auth, authController.getCurrentUser);

// @route   PUT /auth/profile
// @desc    Update user profile
// @access  Private
router.put('/profile', auth, authController.updateProfile);

// @route   POST /auth/forgot-password
// @desc    Request password reset (sends reset code)
// @access  Public
router.post('/forgot-password', authController.forgotPassword);

// @route   POST /auth/reset-password
// @desc    Reset password with code
// @access  Public
router.post('/reset-password', authController.resetPassword);

// @route   PUT /auth/update-slug
// @desc    Update restaurant subdomain slug
// @access  Private
router.put('/update-slug', auth, authController.updateSlug);

// @route   POST /auth/fcm-token
// @desc    Register FCM token for push notifications
// @access  Private
router.post('/fcm-token', auth, authController.registerFCMToken);

module.exports = router;

