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
        // Allow requests with no origin (like mobile apps or curl requests)
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

// Routes
app.use('/auth', require('./src/routes/authRoutes'));
app.use('/menu', require('./src/routes/menuRoutes'));
app.use('/tables', require('./src/routes/tableRoutes'));
app.use('/upload', require('./src/routes/uploadRoutes'));
app.use('/payments', require('./src/routes/paymentRoutes'));
app.use('/orders', require('./src/routes/orderRoutes'));
app.use('/dashboard', require('./src/routes/dashboardRoutes'));
app.use('/reservations', require('./src/routes/reservationRoutes'));

// Health Check (Root endpoint)
app.get('/', (req, res) => {
    res.json({
        status: 'ok',
        service: 'Rockster Backend',
        version: '1.0.0',
        timestamp: new Date().toISOString()
    });
});

app.listen(port, () => {
    console.log(`Rockster Backend listening on port ${port}`);
});
