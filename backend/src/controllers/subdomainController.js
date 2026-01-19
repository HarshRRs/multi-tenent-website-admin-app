const prisma = require('../config/database');

/**
 * Resolve subdomain to restaurant ID
 * GET /api/public/resolve/:subdomain
 */
exports.resolveSubdomain = async (req, res) => {
    try {
        const { subdomain } = req.params;

        if (!subdomain || subdomain === 'www' || subdomain === 'cosmosadmin') {
            return res.status(404).json({
                message: 'No restaurant found',
                isMainDomain: true
            });
        }

        // Find user by slug
        const restaurant = await prisma.user.findUnique({
            where: { slug: subdomain.toLowerCase() },
            select: {
                id: true,
                name: true,
                slug: true,
                email: true
            }
        });

        if (!restaurant) {
            return res.status(404).json({
                message: 'Restaurant not found',
                subdomain
            });
        }

        res.json({
            restaurantId: restaurant.id,
            name: restaurant.name,
            slug: restaurant.slug
        });
    } catch (error) {
        console.error('Subdomain resolution error:', error);
        res.status(500).json({ message: 'Error resolving subdomain', error: error.message });
    }
};

/**
 * Check if slug is available
 * GET /api/public/check-slug/:slug
 */
exports.checkSlugAvailability = async (req, res) => {
    try {
        const { slug } = req.params;

        // Validate slug format (alphanumeric and hyphens only)
        const slugRegex = /^[a-z0-9-]+$/;
        if (!slugRegex.test(slug)) {
            return res.json({
                available: false,
                reason: 'Slug must contain only lowercase letters, numbers, and hyphens'
            });
        }

        // Reserved slugs
        const reserved = ['www', 'api', 'admin', 'app', 'mail', 'blog', 'help', 'support', 'cosmosadmin'];
        if (reserved.includes(slug.toLowerCase())) {
            return res.json({
                available: false,
                reason: 'This slug is reserved'
            });
        }

        const existing = await prisma.user.findUnique({
            where: { slug: slug.toLowerCase() }
        });

        res.json({
            available: !existing,
            slug: slug.toLowerCase()
        });
    } catch (error) {
        console.error('Slug check error:', error);
        res.status(500).json({ message: 'Error checking slug', error: error.message });
    }
};
