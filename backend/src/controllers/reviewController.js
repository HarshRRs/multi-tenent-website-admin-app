const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Submit a review (Public)
exports.submitReview = async (req, res) => {
    try {
        const { rating, comment, customerName, productId, restaurantId } = req.body;

        if (!rating || !customerName || !productId || !restaurantId) {
            return res.status(400).json({ message: 'Missing required fields' });
        }

        const review = await prisma.review.create({
            data: {
                rating: parseInt(rating),
                comment,
                customerName: customerName.trim(),
                productId,
                userId: restaurantId,
                isApproved: false // Requires moderation by default
            }
        });

        res.status(201).json({
            message: 'Review submitted successfully. It will be visible after approval.',
            review
        });
    } catch (error) {
        res.status(500).json({ message: 'Error submitting review', error: error.message });
    }
};

// Get reviews for a product (Public - only approved)
exports.getProductReviews = async (req, res) => {
    try {
        const { productId } = req.params;

        const reviews = await prisma.review.findMany({
            where: {
                productId,
                isApproved: true
            },
            orderBy: { createdAt: 'desc' }
        });

        res.json(reviews);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching reviews', error: error.message });
    }
};

// Manager: List all reviews (Pending/Approved)
exports.getManagerReviews = async (req, res) => {
    try {
        const reviews = await prisma.review.findMany({
            where: { userId: req.user.id },
            include: {
                product: {
                    select: { name: true }
                }
            },
            orderBy: { createdAt: 'desc' }
        });
        res.json(reviews);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching reviews', error: error.message });
    }
};

// Manager: Approve review
exports.approveReview = async (req, res) => {
    try {
        const { id } = req.params;
        const review = await prisma.review.update({
            where: { id, userId: req.user.id },
            data: { isApproved: true }
        });
        res.json(review);
    } catch (error) {
        res.status(500).json({ message: 'Error approving review', error: error.message });
    }
};

// Manager: Delete review
exports.deleteReview = async (req, res) => {
    try {
        const { id } = req.params;
        await prisma.review.delete({
            where: { id, userId: req.user.id }
        });
        res.json({ message: 'Review deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting review', error: error.message });
    }
};
