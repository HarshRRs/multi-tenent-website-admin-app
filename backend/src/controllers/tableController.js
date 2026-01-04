const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Get all tables
exports.getTables = async (req, res) => {
    try {
        const tables = await prisma.table.findMany({
            where: { userId: req.user.id },
            include: { reservations: true } // Include reservations for status checks if needed
        });
        res.json(tables);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching tables', error: error.message });
    }
};

// Create a new table
exports.createTable = async (req, res) => {
    try {
        const { name, seats, x, y, status } = req.body;

        // Basic validation
        if (!name || !seats) {
            return res.status(400).json({ message: 'Name and seats are required' });
        }

        const table = await prisma.table.create({
            data: {
                name,
                seats: parseInt(seats),
                x: x || 0.0,
                y: y || 0.0,
                status: status || 'available',
                userId: req.user.id
            }
        });
        res.status(201).json(table);
    } catch (error) {
        res.status(500).json({ message: 'Error creating table', error: error.message });
    }
};

// Update table (e.g., move it or change seats)
exports.updateTable = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, seats, x, y, status } = req.body;

        // Security: Update only if owned
        const result = await prisma.table.updateMany({
            where: { id, userId: req.user.id },
            data: {
                name,
                seats: seats ? parseInt(seats) : undefined,
                x,
                y,
                status
            }
        });

        if (result.count === 0) {
            return res.status(404).json({ message: 'Table not found or access denied' });
        }

        const table = await prisma.table.findFirst({ where: { id } });
        res.json(table);
    } catch (error) {
        res.status(500).json({ message: 'Error updating table', error: error.message });
    }
};

// Delete table
exports.deleteTable = async (req, res) => {
    try {
        const { id } = req.params;
        const result = await prisma.table.deleteMany({
            where: { id, userId: req.user.id }
        });

        if (result.count === 0) {
            return res.status(404).json({ message: 'Table not found or access denied' });
        }
        res.json({ message: 'Table deleted' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting table', error: error.message });
    }
};
