const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

exports.getNotifications = async (req, res) => {
    try {
        const notifications = await prisma.notification.findMany({
            where: {
                userId: req.user.id
            },
            orderBy: { createdAt: 'desc' },
            take: 50 // Limit to last 50 notifications
        });
        res.json(notifications);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching notifications', error: error.message });
    }
};

exports.markAsRead = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await prisma.notification.updateMany({
            where: {
                id,
                userId: req.user.id
            },
            data: { isRead: true }
        });

        if (result.count === 0) {
            return res.status(404).json({ message: 'Notification not found or access denied' });
        }

        res.json({ message: 'Notification marked as read' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating notification', error: error.message });
    }
};

exports.markAllAsRead = async (req, res) => {
    try {
        await prisma.notification.updateMany({
            where: {
                userId: req.user.id,
                isRead: false
            },
            data: { isRead: true }
        });

        res.json({ message: 'All notifications marked as read' });
    } catch (error) {
        res.status(500).json({ message: 'Error updating notifications', error: error.message });
    }
};

// Helper function to create notifications
exports.createNotification = async (userId, title, body, type = 'system') => {
    try {
        const notification = await prisma.notification.create({
            data: {
                userId,
                title,
                body,
                type
            }
        });

        // Emit WebSocket event
        const websocketService = require('../services/websocketService');
        websocketService.sendToUser(userId, {
            type: 'new_notification',
            notification
        });

        // Send FCM Push Notification
        const fcmService = require('../services/fcmService');
        fcmService.sendPush(userId, title, body, {
            type: type,
            notificationId: notification.id
        });

    } catch (error) {
        console.error('Error creating notification:', error);
    }
};
