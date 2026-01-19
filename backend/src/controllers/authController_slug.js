const prisma = require('../config/database');

/**
 * Update user's slug
 * PUT /api/auth/update-slug
 */
exports.updateSlug = async (req, res) => {
    try {
        const { slug } = req.body;

        if (!slug) {
            return res.status(400).json({ message: 'Slug is required' });
        }

        // Validate slug format
        const slugRegex = /^[a-z0-9-]+$/;
        if (!slugRegex.test(slug)) {
            return res.status(400).json({
                message: 'Slug must contain only lowercase letters, numbers, and hyphens'
            });
        }

        // Reserved slugs
        const reserved = ['www', 'api', 'admin', 'app', 'mail', 'blog', 'help', 'support', 'cosmosadmin'];
        if (reserved.includes(slug.toLowerCase())) {
            return res.status(400).json({ message: 'This slug is reserved' });
        }

        // Check if slug is already taken
        const existing = await prisma.user.findUnique({
            where: { slug: slug.toLowerCase() }
        });

        if (existing && existing.id !== req.user.id) {
            return res.status(409).json({ message: ' Slug is already taken' });
        }

        // Update user
        const updatedUser = await prisma.user.update({
            where: { id: req.user.id },
            data: { slug: slug.toLowerCase() },
            select: {
                id: true,
                email: true,
                name: true,
                slug: true,
                createdAt: true
            }
        });

        res.json(updatedUser);
    } catch (error) {
        console.error('Update slug error:', error);
        res.status(500).json({ message: 'Error updating slug', error: error.message });
    }
};
