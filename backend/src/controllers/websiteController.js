const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Get config for logged-in user (Editor)
exports.getWebsiteConfig = async (req, res) => {
    try {
        const config = await prisma.websiteConfig.findUnique({
            where: { userId: req.user.id }
        });
        // Return empty object structure if null, or null is fine.
        // Frontend likely expects defaults if null.
        res.json(config || {});
    } catch (error) {
        res.status(500).json({ message: 'Error fetching website config', error: error.message });
    }
};

// Update config
exports.updateWebsiteConfig = async (req, res) => {
    try {
        const { headline, subheadline, primaryColor, heroImageUrl, startButtonText, deliveryRadiusKm } = req.body;

        // Upsert ensures creation if not exists
        const config = await prisma.websiteConfig.upsert({
            where: { userId: req.user.id },
            update: {
                headline,
                subheadline,
                primaryColor,
                heroImageUrl,
                startButtonText,
                deliveryRadiusKm: deliveryRadiusKm ? parseFloat(deliveryRadiusKm) : undefined
            },
            create: {
                userId: req.user.id,
                headline,
                subheadline,
                primaryColor,
                heroImageUrl,
                startButtonText,
                deliveryRadiusKm: deliveryRadiusKm ? parseFloat(deliveryRadiusKm) : 10.0
            }
        });
        res.json(config);
    } catch (error) {
        res.status(500).json({ message: 'Error updating website config', error: error.message });
    }
};

// Public Access (by Restaurant ID)
exports.getPublicConfig = async (req, res) => {
    try {
        const { restaurantId } = req.params;

        if (!restaurantId) return res.status(400).json({ message: 'Restaurant ID required' });

        const config = await prisma.websiteConfig.findUnique({
            where: { userId: restaurantId }
        });

        if (!config) return res.status(404).json({ message: 'Config not found' });

        res.json(config);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching public config', error: error.message });
    }
};

// Public Menu Access
exports.getPublicMenu = async (req, res) => {
    try {
        const { restaurantId } = req.params;

        if (!restaurantId) return res.status(400).json({ message: 'Restaurant ID required' });

        // Fetch categories with products for public display
        const categories = await prisma.category.findMany({
            where: { userId: restaurantId },
            include: {
                products: {
                    where: { isAvailable: true },
                    include: {
                        modifierGroups: {
                            include: { modifiers: true }
                        },
                        reviews: {
                            where: { isApproved: true },
                            select: {
                                id: true,
                                rating: true,
                                comment: true,
                                customerName: true,
                                createdAt: true
                            }
                        }
                    }
                }
            }
        });

        res.json(categories);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching public menu', error: error.message });
    }
}
