require('dotenv').config();
const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3000;
const path = require('path');

// Trust Proxy (Required for Railway/Heroku/Vercel)
app.set('trust proxy', 1);

// Middleware
const allowedOrigins = process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : ['*'];

app.use(cors({
    origin: function (origin, callback) {
        if (!origin) return callback(null, true);
        if (allowedOrigins.includes('*') || allowedOrigins.includes(origin)) {
            callback(null, true);
        } else {
            callback(new Error('Not allowed by CORS'));
        }
    },
    credentials: true
}));
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Rate Limiting
const rateLimit = require('express-rate-limit');

const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 10, // Limit each IP to 10 requests per windowMs
    message: 'Too many login attempts. Please try again later.',
    standardHeaders: true,
    legacyHeaders: false,
});

const generalLimiter = rateLimit({
    windowMs: 1 * 60 * 1000, // 1 minute
    max: 100, // Limit each IP to 100 requests per minute
    message: 'Too many requests. Please try again later.',
    standardHeaders: true,
    legacyHeaders: false,
});

app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);
app.use('/auth/login', authLimiter); // Old APK support
app.use('/auth/register', authLimiter); // Old APK support
app.use(generalLimiter); // Apply to all other routes

// Routes - Define controllers once
const authRoutes = require('./src/routes/authRoutes');
const menuRoutes = require('./src/routes/menuRoutes');
const tableRoutes = require('./src/routes/tableRoutes');
const uploadRoutes = require('./src/routes/uploadRoutes');
const paymentRoutes = require('./src/routes/paymentRoutes');
const orderRoutes = require('./src/routes/orderRoutes');
const dashboardRoutes = require('./src/routes/dashboardRoutes');
const reservationRoutes = require('./src/routes/reservationRoutes');
const notificationRoutes = require('./src/routes/notificationRoutes');
const websiteRoutes = require('./src/routes/websiteRoutes');
const publicRoutes = require('./src/routes/publicRoutes');

// API V2 (New Standard)
app.use('/api/auth', authRoutes);
app.use('/api/menu', menuRoutes);
app.use('/api/tables', tableRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/reservations', reservationRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/website', websiteRoutes);
app.use('/api/public', publicRoutes);
app.use('/api/test', require('./src/routes/testEmailRoute'));

// API V1 (Backward Compatibility for APK v6)
app.use('/auth', authRoutes);
app.use('/menu', menuRoutes);
app.use('/tables', tableRoutes);
app.use('/upload', uploadRoutes);
app.use('/payments', paymentRoutes);
app.use('/orders', orderRoutes);
app.use('/dashboard', dashboardRoutes);
app.use('/reservations', reservationRoutes);
app.use('/notifications', notificationRoutes);
app.use('/website', websiteRoutes);
app.use('/public', publicRoutes);

const websocketService = require('./src/services/websocketService');

// Health Check
app.get('/', (req, res) => {
    res.json({
        status: 'ok',
        service: 'Cosmos Admin Backend (Multi-Tenant)',
        version: '2.0.0',
        timestamp: new Date().toISOString()
    });
});

const server = app.listen(port, () => {
    console.log(`Cosmos Admin Backend listening on port ${port}`);
});

websocketService.init(server);
