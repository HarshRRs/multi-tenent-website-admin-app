const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

exports.getStats = async (req, res) => {
    try {
        // Mock data was:
        // totalRevenue: 15430.50,
        // activeOrders: 12,
        // reservations: 8,
        // menuItemsActive: 45,
        // rating: 4.8,
        // revenueTrend: '+12%',
        // isRevenueTrendPositive: true

        // 1. Total Revenue (Sum of all completed orders? Or all?)
        // Let's sum 'completed' orders.
        const revenueAgg = await prisma.order.aggregate({
            _sum: { totalAmount: true },
            where: { status: 'completed' } // Assuming 'completed' is the final status
        });
        const totalRevenue = revenueAgg._sum.totalAmount || 0;

        // 2. Active Orders (Not completed or cancelled)
        const activeOrders = await prisma.order.count({
            where: {
                status: {
                    notIn: ['completed', 'cancelled', 'served'] // Adjust based on statuses
                }
            }
        });

        // 3. Reservations (Total future reservations?)
        // Let's count reservations for today or future.
        const reservations = await prisma.reservation.count({
             where: {
                 time: {
                     gte: new Date()
                 }
             }
        });

        // 4. Active Menu Items
        const menuItemsActive = await prisma.product.count({
            where: { isAvailable: true }
        });

        // 5. Rating (Hard to calculate without a Review model. Keep mock or 0)
        const rating = 4.8; // Static for now

        // 6. Revenue Trend (Need historical data. Static for now)
        const revenueTrend = '+12%';
        const isRevenueTrendPositive = true;

        res.json({
            totalRevenue,
            activeOrders,
            reservations,
            menuItemsActive,
            rating,
            revenueTrend,
            isRevenueTrendPositive
        });

    } catch (error) {
        console.error('Dashboard Stats Error:', error);
        res.status(500).json({ message: 'Error fetching dashboard stats', error: error.message });
    }
};

exports.getRecentOrders = async (req, res) => {
    try {
        const recentOrders = await prisma.order.findMany({
            take: 5,
            orderBy: { createdAt: 'desc' },
            include: { items: true } // Optional: include items
        });

        // Map to format if needed, but Prisma result is usually fine.
        // Mock format: { id, customerName, amount, status, timestamp }
        // Prisma: { id, customerName, totalAmount, status, createdAt, ... }

        const formatted = recentOrders.map(order => ({
            id: order.id,
            customerName: order.customerName,
            amount: order.totalAmount,
            status: order.status,
            timestamp: order.createdAt
        }));

        res.json(formatted);

    } catch (error) {
        res.status(500).json({ message: 'Error fetching recent orders', error: error.message });
    }
};
