const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

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

module.exports = router;
