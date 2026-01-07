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

// Routes
app.use('/auth', require('./src/routes/authRoutes'));
app.use('/menu', require('./src/routes/menuRoutes'));
app.use('/tables', require('./src/routes/tableRoutes'));
app.use('/upload', require('./src/routes/uploadRoutes'));
app.use('/payments', require('./src/routes/paymentRoutes'));
app.use('/orders', require('./src/routes/orderRoutes'));
app.use('/dashboard', require('./src/routes/dashboardRoutes'));
app.use('/reservations', require('./src/routes/reservationRoutes'));
app.use('/notifications', require('./src/routes/notificationRoutes'));
app.use('/website', require('./src/routes/websiteRoutes')); // Multi-Tenant Config
app.use('/public', require('./src/routes/publicRoutes')); // Consumer Website API

// Health Check
app.get('/', (req, res) => {
    res.json({
        status: 'ok',
        service: 'Rockster Backend (Multi-Tenant)',
        version: '2.0.0',
        timestamp: new Date().toISOString()
    });
});

app.listen(port, () => {
    console.log(`Rockster Backend listening on port ${port}`);
});
