const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

exports.getReservations = async (req, res) => {
    try {
        const reservations = await prisma.reservation.findMany({
            where: {
                userId: req.user.id
            },
            include: { table: true },
            orderBy: { time: 'asc' }
        });
        res.json(reservations);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching reservations', error: error.message });
    }
};

exports.createReservation = async (req, res) => {
    try {
        const { customerName, customerPhone, partySize, time, tableId } = req.body;

        if (!customerName || !partySize || !time) {
            return res.status(400).json({ message: 'Customer name, party size, and time are required' });
        }

        // Check for overbooking if tableId is provided
        if (tableId) {
            const reservationTime = new Date(time);
            // Check for reservations within 2 hours before and after (typical dining duration)
            const bufferHours = 2;
            const startWindow = new Date(reservationTime.getTime() - bufferHours * 60 * 60 * 1000);
            const endWindow = new Date(reservationTime.getTime() + bufferHours * 60 * 60 * 1000);

            const conflictingReservation = await prisma.reservation.findFirst({
                where: {
                    tableId: tableId,
                    userId: req.user.id,
                    time: {
                        gte: startWindow,
                        lte: endWindow
                    }
                }
            });

            if (conflictingReservation) {
                return res.status(409).json({
                    message: 'Table is already reserved for this time slot',
                    conflict: {
                        customerName: conflictingReservation.customerName,
                        time: conflictingReservation.time
                    }
                });
            }
        }

        const reservation = await prisma.reservation.create({
            data: {
                customerName,
                customerPhone: customerPhone || null,
                partySize: parseInt(partySize),
                time: new Date(time),
                tableId: tableId || null,
                userId: req.user.id
            },
            include: { table: true }
        });

        res.status(201).json(reservation);
    } catch (error) {
        res.status(500).json({ message: 'Error creating reservation', error: error.message });
    }
};
exports.deleteReservation = async (req, res) => {
    try {
        const { id } = req.params;
        await prisma.reservation.delete({
            where: {
                id,
                userId: req.user.id
            }
        });
        res.json({ message: 'Reservation deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting reservation', error: error.message });
    }
};

exports.createPublicReservation = async (req, res) => {
    try {
        const { restaurantId, customerName, partySize, time, phone } = req.body;

        if (!restaurantId || !customerName || !partySize || !time) {
            return res.status(400).json({ message: 'Missing required reservation fields' });
        }

        const reservation = await prisma.reservation.create({
            data: {
                customerName,
                customerPhone: phone,
                partySize: parseInt(partySize),
                time: new Date(time),
                userId: restaurantId
            }
        });

        // Notify admin via WebSocket (just to refresh list)
        const websocketService = require('../services/websocketService');
        websocketService.sendToUser(restaurantId, {
            type: 'order_update', // Re-use for refreshing
            message: 'New reservation received'
        });

        res.status(201).json(reservation);
    } catch (error) {
        res.status(500).json({ message: 'Error creating reservation', error: error.message });
    }
};
