const multer = require('multer');
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');

// Ensure upload directory exists
const uploadDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Use Memory Storage to process file before saving
const storage = multer.memoryStorage();

const upload = multer({
    storage: storage,
    limits: { fileSize: 10 * 1024 * 1024 }, // Allow 10MB upload (we will compress it)
    fileFilter: (req, file, cb) => {
        if (file.mimetype.startsWith('image/')) {
            cb(null, true);
        } else {
            cb(new Error('Only images are allowed'));
        }
    }
});

exports.uploadMiddleware = upload.single('image');

exports.uploadImage = async (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: 'No file uploaded' });
    }

    try {
        // Generate unique filename
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        const filename = uniqueSuffix + '.jpg'; // Convert everything to JPG
        const filepath = path.join(uploadDir, filename);

        // Process image with Sharp
        await sharp(req.file.buffer)
            .resize(800, 800, { // Max dims 800x800
                fit: 'inside',
                withoutEnlargement: true
            })
            .jpeg({ quality: 80 }) // Compress to 80% quality JPG
            .toFile(filepath);

        // Return URL
        const protocol = req.protocol;
        const host = req.get('host');
        const fileUrl = `${protocol}://${host}/uploads/${filename}`;

        res.json({
            message: 'File uploaded and optimized successfully',
            url: fileUrl
        });
    } catch (error) {
        console.error('Image Optimization Error:', error);
        res.status(500).json({ message: 'Error processing image', error: error.message });
    }
};
