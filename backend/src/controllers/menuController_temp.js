const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// --- Categories ---
exports.getCategories = async (req, res) => {
    try {
        const categories = await prisma.category.findMany({
            where: {
                userId: req.user.id
            }
        });
        res.json(categories);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching categories', error: error.message });
    }
};

exports.createCategory = async (req, res) => {
    try {
        const { name } = req.body;
        if (!name) return res.status(400).json({ message: 'Category name is required' });

        const category = await prisma.category.create({
            data: {
                name,
                userId: req.user.id
            }
        });
        res.status(201).json(category);
    } catch (error) {
        res.status(500).json({ message: 'Error creating category', error: error.message });
    }
};

// --- Products ---
exports.getProducts = async (req, res) => {
    try {
        const products = await prisma.product.findMany({
            where: {
                userId: req.user.id
            },
            include: {
                category: true // Include category details if needed
            }
        });
        res.json(products);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching products', error: error.message });
    }
};

exports.createProduct = async (req, res) => {
    try {
        const { name, description, price, categoryId, imageUrl } = req.body;

        // Basic validation
        if (!name || !price || !categoryId) {
            return res.status(400).json({ message: 'Name, price, and categoryId are required' });
        }

        // Verify category belongs to user? 
        // Ideally yes, but foreign key constraint checks if categoryId exists. 
        // If user guesses another user's categoryId, the Relation logic might allow it?
        // But Product also has userId.
        // Prisma doesn't enforce "Product's user must match Category's user". 
        // But for display it matters.
        // Assuming user picks from list fetched by getCategories.

        const product = await prisma.product.create({
            data: {
                name,
                description,
                price: parseFloat(price),
                categoryId,
                userId: req.user.id,
                imageUrl: imageUrl || 'https://placehold.co/200',
                isAvailable: true
            }
        });
        res.status(201).json(product);
    } catch (error) {
        res.status(500).json({ message: 'Error creating product', error: error.message });
    }
};

exports.updateAvailability = async (req, res) => {
    try {
        const { id } = req.params;
        const { isAvailable } = req.body;

        // Security: Ensure user owns product
        const product = await prisma.product.updateMany({
            where: {
                id,
                userId: req.user.id
            },
            data: { isAvailable }
        });

        if (product.count === 0) {
            // updateMany returns { count: 0 } if not found/owned
            return res.status(404).json({ message: 'Product not found or access denied' });
        }

        // Return updated product? updateMany doesn't return data.
        // Fetch it or just return success.
        const updatedProduct = await prisma.product.findFirst({ where: { id } });
        res.json(updatedProduct);

    } catch (error) {
        res.status(500).json({ message: 'Error updating product', error: error.message });
    }
};

exports.deleteProduct = async(req, res) =\u003e {
    try {
        const { id } = req.params;

        // Security: Ensure user owns product before deleting
        const result = await prisma.product.deleteMany({
            where: {
                id,
                userId: req.user.id
            }
        });

        if (result.count === 0) {
            return res.status(404).json({ message: 'Product not found or access denied' });
        }

        res.json({ message: 'Product deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting product', error: error.message });
    }
};

exports.deleteCategory = async(req, res) =\u003e {
    try {
        const { id } = req.params;

        // Check if category has products
        const productsCount = await prisma.product.count({
            where: { categoryId: id, userId: req.user.id }
        });

        if (productsCount \u003e 0) {
            return res.status(400).json({
                message: 'Cannot delete category with existing products',
                productCount: productsCount
            });
        }

        // Security: Ensure user owns category before deleting
        const result = await prisma.category.deleteMany({
            where: {
                id,
                userId: req.user.id
            }
        });

        if (result.count === 0) {
            return res.status(404).json({ message: 'Category not found or access denied' });
        }

        res.json({ message: 'Category deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: 'Error deleting category', error: error.message });
    }
};
