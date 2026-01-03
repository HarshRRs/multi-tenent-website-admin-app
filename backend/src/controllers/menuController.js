const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// --- Categories ---
exports.getCategories = async (req, res) => {
    try {
        const categories = await prisma.category.findMany();
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
            data: { name }
        });
        res.status(201).json(category);
    } catch (error) {
        res.status(500).json({ message: 'Error creating category', error: error.message });
    }
};

// --- Products ---
exports.getProducts = async (req, res) => {
    try {
        const products = await prisma.product.findMany();
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

        const product = await prisma.product.create({
            data: {
                name,
                description,
                price: parseFloat(price),
                categoryId,
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

        const product = await prisma.product.update({
            where: { id },
            data: { isAvailable }
        });
        res.json(product);
    } catch (error) {
        if (error.code === 'P2025') {
            return res.status(404).json({ message: 'Product not found' });
        }
        res.status(500).json({ message: 'Error updating product', error: error.message });
    }
};
