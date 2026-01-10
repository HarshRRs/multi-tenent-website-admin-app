const multer = require('multer');
const { uploadToS3 } = require('../services/s3Service');

// Use memory storage instead of disk storage
const storage = multer.memoryStorage();

const upload = multer({
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
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
    try {
        if (!req.file) {
            return res.status(400).json({ message: 'No file uploaded' });
        }

        // Upload to S3
        const fileUrl = await uploadToS3(
            req.file.buffer,
            req.file.originalname,
            req.file.mimetype
        );

        res.json({
            message: 'File uploaded successfully to S3',
            url: fileUrl
        });
    } catch (error) {
        console.error('Upload Error:', error);
        res.status(500).json({
            message: 'Failed to upload file',
            error: error.message
        });
    }
};
