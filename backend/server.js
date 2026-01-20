require('dotenv').config();
const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3000;
const path = require('path');

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

app.use('/auth/login', authLimiter);
app.use('/auth/register', authLimiter);
app.use(generalLimiter); // Apply to all other routes

// Routes
app.use('/api/auth', require('./src/routes/authRoutes'));
app.use('/api/menu', require('./src/routes/menuRoutes'));
app.use('/api/tables', require('./src/routes/tableRoutes'));
app.use('/api/upload', require('./src/routes/uploadRoutes'));
app.use('/api/payments', require('./src/routes/paymentRoutes'));
app.use('/api/orders', require('./src/routes/orderRoutes'));
app.use('/api/dashboard', require('./src/routes/dashboardRoutes'));
app.use('/api/reservations', require('./src/routes/reservationRoutes'));
app.use('/api/notifications', require('./src/routes/notificationRoutes'));
app.use('/api/website', require('./src/routes/websiteRoutes')); // Multi-Tenant Config
app.use('/api/public', require('./src/routes/publicRoutes')); // Consumer Website API

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
