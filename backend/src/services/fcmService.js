const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

class FCMService {
    constructor() {
        this.initialized = false;
        this.init();
    }

    init() {
        try {
            const serviceAccountPath = path.join(__dirname, '../../firebase-service-account.json');

            if (fs.existsSync(serviceAccountPath)) {
                const serviceAccount = require(serviceAccountPath);
                admin.initializeApp({
                    credential: admin.credential.cert(serviceAccount)
                });
                this.initialized = true;
                console.log('Firebase Admin initialized successfully');
            } else {
                console.warn('Firebase Service Account file NOT FOUND at:', serviceAccountPath);
                console.warn('Push notifications will be disabled until the file is added.');
            }
        } catch (error) {
            console.error('Error initializing Firebase Admin:', error);
        }
    }

    async sendPush(userId, title, body, data = {}) {
        if (!this.initialized) return;

        try {
            const { PrismaClient } = require('@prisma/client');
            const prisma = new PrismaClient();

            const user = await prisma.user.findUnique({
                where: { id: userId },
                select: { fcmTokens: true }
            });

            if (!user || !user.fcmTokens || user.fcmTokens.length === 0) {
                return;
            }

            const message = {
                notification: {
                    title,
                    body,
                },
                data: {
                    ...data,
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                },
                tokens: user.fcmTokens,
            };

            const response = await admin.messaging().sendMulticast(message);
            console.log(`${response.successCount} push messages were sent successfully`);

            // Clean up invalid tokens
            if (response.failureCount > 0) {
                const failedTokens = [];
                response.responses.forEach((resp, idx) => {
                    if (!resp.success) {
                        failedTokens.push(user.fcmTokens[idx]);
                    }
                });

                if (failedTokens.length > 0) {
                    await prisma.user.update({
                        where: { id: userId },
                        data: {
                            fcmTokens: {
                                set: user.fcmTokens.filter(t => !failedTokens.includes(t))
                            }
                        }
                    });
                }
            }
        } catch (error) {
            console.error('Error sending push notification:', error);
        }
    }
}

module.exports = new FCMService();
