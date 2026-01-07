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

        // 5. Revenue Trend (Calculate week-over-week change)
        const now = new Date();
        const lastWeekStart = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        const twoWeeksAgoStart = new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000);

        const lastWeekRevenue = await prisma.order.aggregate({
            _sum: { totalAmount: true },
            where: {
                userId,
                status: 'completed',
                createdAt: {
                    gte: lastWeekStart,
                    lte: now
                }
            }
        });

        const twoWeeksAgoRevenue = await prisma.order.aggregate({
            _sum: { totalAmount: true },
            where: {
                userId,
                status: 'completed',
                createdAt: {
                    gte: twoWeeksAgoStart,
                    lte: lastWeekStart
                }
            }
        });

        const lastWeekTotal = lastWeekRevenue._sum.totalAmount || 0;
        const twoWeeksTotal = twoWeeksAgoRevenue._sum.totalAmount || 0;

        let revenueTrend = '0%';
        let isRevenueTrendPositive = true;

        if (twoWeeksTotal > 0) {
            const percentChange = ((lastWeekTotal - twoWeeksTotal) / twoWeeksTotal) * 100;
            isRevenueTrendPositive = percentChange >= 0;
            revenueTrend = `${isRevenueTrendPositive ? '+' : ''}${percentChange.toFixed(1)}%`;
        } else if (lastWeekTotal > 0) {
            revenueTrend = '+100%'; // If no previous week revenue but current week has revenue
        }

        // 6. Rating - Remove or set to null if no review system exists
        // For now, returning null to indicate "no rating system"
        const rating = null;

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
