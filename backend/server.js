const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// --- MOCK DATA ---

// Auth
app.post('/auth/login', (req, res) => {
    const { email, password } = req.body;
    if (email && password) {
        res.json({
            token: 'mock-jwt-token-12345',
            user: {
                id: 'u1',
                name: 'John Doe',
                email: email,
                role: 'manager'
            }
        });
    } else {
        res.status(401).json({ message: 'Invalid credentials' });
    }
});

app.post('/auth/register', (req, res) => {
    res.json({
        token: 'mock-jwt-token-registered',
        user: { id: 'u2', name: req.body.name, email: req.body.email, role: 'owner' }
    });
});

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

// Menu
let products = [
    { id: 'p1', name: 'Classic Burger', description: 'Juicy beef patty', price: 12.50, imageUrl: 'https://placehold.co/200', isAvailable: true, categoryId: '1' },
    { id: 'p2', name: 'Cheese Pizza', description: 'Mozzarella goodness', price: 14.00, imageUrl: 'https://placehold.co/200', isAvailable: true, categoryId: '2' }
];

app.get('/menu/categories', (req, res) => {
    res.json([
        { id: '1', name: 'Burgers' },
        { id: '2', name: 'Pizza' },
        { id: '3', name: 'Drinks' }
    ]);
});

app.get('/menu/products', (req, res) => {
    res.json(products);
});

app.patch('/menu/products/:id/availability', (req, res) => {
    const { isAvailable } = req.body;
    const product = products.find(p => p.id === req.params.id);
    if (product) {
        product.isAvailable = isAvailable;
        res.json(product);
    } else {
        res.status(404).json({ message: 'Product not found' });
    }
});

// Reservations
app.get('/reservations/tables', (req, res) => {
    res.json([
        { id: 't1', name: 'Table 1', seats: 4, x: 0.2, y: 0.2, status: 'available' },
        { id: 't2', name: 'Table 2', seats: 2, x: 0.5, y: 0.5, status: 'occupied' },
        { id: 't3', name: 'Table 3', seats: 6, x: 0.8, y: 0.2, status: 'reserved' }
    ]);
});

app.get('/reservations', (req, res) => {
    res.json([
        { id: 'r1', customerName: 'John Smith', partySize: 4, time: new Date().toISOString(), tableId: 't3' }
    ]);
});

// Payments
app.get('/payments/stripe/status', (req, res) => {
    res.json({
        isConnected: true,
        accountId: 'acct_123456789',
        availableBalance: 1250.00,
        pendingBalance: 450.00
    });
});

app.get('/payments/transactions', (req, res) => {
    res.json([
        { id: 'tx1', customerName: 'Alice', amount: 45.50, date: new Date().toISOString(), status: 'completed', paymentMethod: 'Visa 4242' },
        { id: 'tx2', customerName: 'Bob', amount: 22.00, date: new Date().toISOString(), status: 'pending', paymentMethod: 'Mastercard 8888' }
    ]);
});

app.post('/payments/stripe/connect', (req, res) => {
    res.json({ url: 'https://connect.stripe.com/express/oauth/authorize' });
});

app.listen(port, () => {
    console.log(`Rockster Backend listening on port ${port}`);
});
