const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Create a new coupon
exports.createCoupon = async (req, res) => {
    try {
        const { code, discountType, discountValue, minOrderAmount, expiresAt } = req.body;
        const userId = req.user.id;

        const coupon = await prisma.coupon.create({
            data: {
                code: code.toUpperCase(),
                discountType,
                discountValue,
                minOrderAmount: minOrderAmount || 0,
                expiresAt: expiresAt ? new Date(expiresAt) : null,
                userId
            }
        });

        res.status(201).json(coupon);
    } catch (error) {
        if (error.code === 'P2002') {
            return res.status(400).json({ message: 'Coupon code already exists' });
        }
        res.status(500).json({ message: 'Error creating coupon', error: error.message });
    }
};

// Get all coupons for the manager
exports.getCoupons = async (req, res) => {
    try {
        const coupons = await prisma.coupon.findMany({
            where: { userId: req.user.id },
            orderBy: { createdAt: 'desc' }
        });
        res.json(coupons);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching coupons', error: error.message });
    }
};

// Toggle coupon active status
exports.toggleCoupon = async (req, res) => {
    try {
        const { id } = req.params;
        const { isActive } = req.body;

        const coupon = await prisma.coupon.update({
            where: { id, userId: req.user.id },
            data: { isActive }
        });

        res.json(coupon);
    } catch (error) {
        res.status(500).json({ message: 'Error updating coupon', error: error.message });
    }
};

// Delete coupon
exports.deleteCoupon = async (req, res) => {
    try {
        const { id } = req.params;
        await prisma.coupon.delete({
            where: { id, userId: req.user.id }
        });
        res.json({ message: 'Coupon deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting coupon', error: error.message });
    }
};

// Public: Validate coupon
exports.validateCoupon = async (req, res) => {
    try {
        const { code, cartTotal, restaurantId } = req.body;

        const coupon = await prisma.coupon.findFirst({
            where: {
                code: code.toUpperCase(),
                userId: restaurantId,
                isActive: true
            }
        });

        if (!coupon) {
            return res.status(404).json({ valid: false, message: 'Invalid or inactive coupon code' });
        }

        // Check expiry
        if (coupon.expiresAt && new Date(coupon.expiresAt) < new Date()) {
            return res.status(400).json({ valid: false, message: 'Coupon has expired' });
        }

        // Check min amount
        if (cartTotal < coupon.minOrderAmount) {
            return res.status(400).json({
                valid: false,
                message: `Minimum order amount for this coupon is $${coupon.minOrderAmount.toFixed(2)}`
            });
        }

        // Calculate discount
        let discountAmount = 0;
        if (coupon.discountType === 'PERCENT') {
            discountAmount = (cartTotal * coupon.discountValue) / 100;
        } else {
            discountAmount = coupon.discountValue;
        }

        res.json({
            valid: true,
            couponId: coupon.id,
            discountType: coupon.discountType,
            discountValue: coupon.discountValue,
            discountAmount: Math.min(discountAmount, cartTotal)
        });

    } catch (error) {
        res.status(500).json({ message: 'Error validating coupon', error: error.message });
    }
};
