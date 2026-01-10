const { S3Client, PutObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const path = require('path');

// Initialize S3 Client
const s3Client = new S3Client({
    region: process.env.AWS_REGION || 'eu-north-1',
    credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
    },
});

const BUCKET_NAME = process.env.AWS_S3_BUCKET || 'rockster-uploads';

/**
 * Upload file to S3
 * @param {Buffer} fileBuffer - File buffer
 * @param {string} fileName - Original filename
 * @param {string} mimeType - File MIME type
 * @returns {Promise<string>} - Public URL of uploaded file
 */
async function uploadToS3(fileBuffer, fileName, mimeType) {
    // Generate unique filename
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const fileExtension = path.extname(fileName);
    const key = `uploads/${uniqueSuffix}${fileExtension}`;

    const command = new PutObjectCommand({
        Bucket: BUCKET_NAME,
        Key: key,
        Body: fileBuffer,
        ContentType: mimeType,
        // ACL: 'public-read', // Not needed with bucket policy
    });

    try {
        await s3Client.send(command);

        // Return public URL
        const publicUrl = `https://${BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/${key}`;
        return publicUrl;
    } catch (error) {
        console.error('S3 Upload Error:', error);
        throw new Error('Failed to upload file to S3');
    }
}

/**
 * Delete file from S3
 * @param {string} fileUrl - Full S3 URL of the file
 * @returns {Promise<void>}
 */
async function deleteFromS3(fileUrl) {
    try {
        // Extract key from URL
        const urlParts = fileUrl.split('.amazonaws.com/');
        if (urlParts.length < 2) {
            throw new Error('Invalid S3 URL');
        }
        const key = urlParts[1];

        const command = new DeleteObjectCommand({
            Bucket: BUCKET_NAME,
            Key: key,
        });

        await s3Client.send(command);
        console.log(`Deleted file from S3: ${key}`);
    } catch (error) {
        console.error('S3 Delete Error:', error);
        throw new Error('Failed to delete file from S3');
    }
}

module.exports = {
    uploadToS3,
    deleteFromS3,
    s3Client,
};
