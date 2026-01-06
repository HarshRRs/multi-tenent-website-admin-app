const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

exports.getStats = async (req, res) => {
    try {
        const userId = req.user.id; // Tenant isolation

        // 1. Total Revenue (Sum of all completed orders for THIS user)
        const revenueAgg = await prisma.order.aggregate({
            _sum: { totalAmount: true },
            where: {
                userId,
                status: 'completed'
            }
        });
        const totalRevenue = revenueAgg._sum.totalAmount || 0;

        // 2. Active Orders
        const activeOrders = await prisma.order.count({
            where: {
                userId,
                status: {
                    notIn: ['completed', 'cancelled', 'served']
                }
            }
        });

        // 3. Reservations
        const reservations = await prisma.reservation.count({
            where: {
                userId,
                time: {
                    gte: new Date()
                }
            }
        });

        // 4. Active Menu Items
        const menuItemsActive = await prisma.product.count({
            where: {
                userId,
                isAvailable: true
            }
        });

        // 5. Rating (Static)
        const rating = 4.8;

        // 6. Revenue Trend (Static)
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
            where: {
                userId: req.user.id
            },
            take: 5,
            orderBy: { createdAt: 'desc' },
            include: { items: true }
        });

        const formatted = recentOrders.map(order => ({
            id: order.id,
            customerName: order.customerName,
            amount: order.totalAmount,
            status: order.status,
            timestamp: order.createdAt
        }));

        res.json({ orders: formatted });

    } catch (error) {
        res.status(500).json({ message: 'Error fetching recent orders', error: error.message });
    }
};
