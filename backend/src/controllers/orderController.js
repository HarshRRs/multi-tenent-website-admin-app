const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const websocketService = require('../services/websocketService');

exports.getOrders = async (req, res) => {
    try {
        const { status } = req.query;
        // Ensure filtering by userId
        const where = {
            userId: req.user.id,
            ...(status ? { status } : {})
        };

        const orders = await prisma.order.findMany({
            where,
            include: { items: true },
            orderBy: { createdAt: 'desc' }
        });
        res.json({
            orders: orders,
            total: orders.length
        });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching orders', error: error.message });
    }
};

exports.getOrder = async (req, res) => {
    try {
        const { id } = req.params;
        // Use findFirst to ensure ownership check (userId)
        const order = await prisma.order.findFirst({
            where: {
                id,
                userId: req.user.id
            },
            include: { items: true }
        });

        if (!order) {
            return res.status(404).json({ message: 'Order not found' });
        }
        res.json(order);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching order', error: error.message });
    }
};

exports.createOrder = async (req, res) => {
    try {
        const { customerName, items, totalAmount } = req.body;

        if (!items || !Array.isArray(items) || items.length === 0) {
            return res.status(400).json({ message: 'Order must contain items' });
        }

        // Validate customer name (don't silently default to "Guest")
        if (!customerName || customerName.trim() === '') {
            return res.status(400).json({
                message: 'Customer name is required. Use "Guest" explicitly for walk-in customers.'
            });
        }

        const order = await prisma.order.create({
            data: {
                customerName: customerName.trim(),
                totalAmount: parseFloat(totalAmount) || 0,
                status: 'pending',
                userId: req.user.id, // Assign to current user
                items: {
                    create: items.map(item => ({
                        name: item.name,
                        quantity: parseInt(item.quantity),
                        price: parseFloat(item.price)
                    }))
                }
            },
            include: { items: true }
        });

        // Create notification for new order
        try {
            const notificationController = require('./notificationController');
            await notificationController.createNotification(
                req.user.id,
                `New Order #${order.id.substring(0, 8)}`,
                `New order from ${customerName} for $${totalAmount.toFixed(2)}`,
                'order'
            );
        } catch (notifError) {
            console.error('Failed to create notification:', notifError);
            // Don't fail the order if notification fails
        }

        // Emit WebSocket event for new order
        websocketService.sendToUser(req.user.id, {
            type: 'new_order',
            orderId: order.id,
            totalAmount: order.totalAmount,
            customerName: order.customerName
        });

        res.status(201).json(order);
    } catch (error) {
        console.error('Create Order Error:', error);
        res.status(500).json({ message: 'Error creating order', error: error.message });
    }
};

exports.updateOrderStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        if (!status) {
            return res.status(400).json({ message: 'Status is required' });
        }

        // Security: Ensure ownership
        const result = await prisma.order.updateMany({
            where: {
                id,
                userId: req.user.id
            },
            data: { status }
        });

        if (result.count === 0) {
            return res.status(404).json({ message: 'Order not found or access denied' });
        }

        // Return updated order
        const updatedOrder = await prisma.order.findFirst({
            where: { id },
            include: { items: true }
        });

        // Emit WebSocket event for order update
        websocketService.sendToUser(req.user.id, {
            type: 'order_update',
            orderId: id,
            status: status,
            order: updatedOrder
        });

        res.json(updatedOrder);
    } catch (error) {
        res.status(500).json({ message: 'Error updating order status', error: error.message });
    }
};

exports.createPublicOrder = async (req, res) => {
    try {
        const { restaurantId, customerName, items, totalAmount } = req.body;

        if (!restaurantId || !items || !Array.isArray(items) || items.length === 0) {
            return res.status(400).json({ message: 'Restaurant ID and items are required' });
        }

        const order = await prisma.order.create({
            data: {
                customerName: customerName || 'Web Guest',
                totalAmount: parseFloat(totalAmount) || 0,
                status: 'pending',
                userId: restaurantId, // Scoped to the restaurant (userId in our system)
                items: {
                    create: items.map(item => ({
                        name: item.name,
                        quantity: parseInt(item.quantity),
                        price: parseFloat(item.price)
                    }))
                }
            },
            include: { items: true }
        });

        // Emit WebSocket event for new order
        websocketService.sendToUser(restaurantId, {
            type: 'new_order',
            orderId: order.id,
            totalAmount: order.totalAmount,
            customerName: order.customerName
        });

        res.status(201).json(order);
    } catch (error) {
        console.error('Create Public Order Error:', error);
        res.status(500).json({ message: 'Error creating order', error: error.message });
    }
};
