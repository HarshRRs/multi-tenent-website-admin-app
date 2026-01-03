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

// --- MOCK DATA ---

// Auth - REPLACED WITH REAL ROUTES
// See ./src/routes/authRoutes.js

// Dashboard
app.get('/dashboard/stats', (req, res) => {
    res.json({
        totalRevenue: 15430.50,
        activeOrders: 12,
        reservations: 8,
        menuItemsActive: 45,
        rating: 4.8,
        revenueTrend: '+12%',
        isRevenueTrendPositive: true
    });
});

app.get('/dashboard/recent-orders', (req, res) => {
    res.json([
        { id: '1024', customerName: 'Alice Johnson', amount: 45.50, status: 'Preparing', timestamp: new Date().toISOString() },
        { id: '1023', customerName: 'Bob Smith', amount: 22.00, status: 'Completed', timestamp: new Date().toISOString() },
        { id: '1022', customerName: 'Charlie', amount: 15.00, status: 'Pending', timestamp: new Date().toISOString() }
    ]);
});

// Orders
let orders = [
    { id: '1025', customerName: 'David Lee', status: 'pending', items: [], totalAmount: 32.50, createdAt: new Date().toISOString() },
    { id: '1024', customerName: 'Alice Johnson', status: 'preparing', items: [], totalAmount: 45.50, createdAt: new Date().toISOString() }
];

app.get('/orders', (req, res) => {
    res.json(orders);
});

app.patch('/orders/:id/status', (req, res) => {
    const { status } = req.body;
    const order = orders.find(o => o.id === req.params.id);
    if (order) {
        order.status = status;
        res.json(order);
    } else {
        res.status(404).json({ message: 'Order not found' });
    }
});

// Menu - REPLACED WITH REAL ROUTES
// See ./src/routes/menuRoutes.js

// Reservations
// Tables endpoint moved to /tables (see tableRoutes.js)
app.get('/reservations', (req, res) => {
    res.json([
        { id: 'r1', customerName: 'John Smith', partySize: 4, time: new Date().toISOString(), tableId: 't3' }
    ]);
});

// Payments
// Endpoints moved to /payments (see paymentRoutes.js)

app.listen(port, () => {
    console.log(`Rockster Backend listening on port ${port}`);
});
