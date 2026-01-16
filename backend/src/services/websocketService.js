const WebSocket = require('ws');
const jwt = require('jsonwebtoken');

class WebSocketService {
    constructor() {
        this.wss = null;
        this.clients = new Map(); // userId -> Set of WebSockets
    }

    init(server) {
        this.wss = new WebSocket.Server({ server, path: '/ws' });

        this.wss.on('connection', (ws, req) => {
            console.log('New WebSocket connection attempting...');

            // Extract token from URL
            const url = new URL(req.url, 'http://localhost');
            const token = url.searchParams.get('token');

            if (!token) {
                console.log('WS Connection rejected: No token');
                ws.terminate();
                return;
            }

            try {
                const decoded = jwt.verify(token, process.env.JWT_SECRET);
                const userId = decoded.userId;

                // Add to client map
                if (!this.clients.has(userId)) {
                    this.clients.set(userId, new Set());
                }
                this.clients.get(userId).add(ws);

                console.log(`WS Authenticated: User ${userId}`);

                ws.on('message', (message) => {
                    try {
                        const data = JSON.parse(message);
                        if (data.type === 'ping') {
                            ws.send(JSON.stringify({ type: 'pong' }));
                        }
                    } catch (e) {
                        // Ignore malformed messages
                    }
                });

                ws.on('close', () => {
                    const userSockets = this.clients.get(userId);
                    if (userSockets) {
                        userSockets.delete(ws);
                        if (userSockets.size === 0) {
                            this.clients.delete(userId);
                        }
                    }
                    console.log(`WS Disconnected: User ${userId}`);
                });

            } catch (err) {
                console.log('WS Connection rejected: Invalid token');
                ws.terminate();
            }
        });

        console.log('WebSocket Server initialized on /ws');
    }

    /**
     * Send event to specifically one user's connected devices
     */
    sendToUser(userId, event) {
        const userSockets = this.clients.get(userId);
        if (userSockets) {
            const message = JSON.stringify(event);
            userSockets.forEach(ws => {
                if (ws.readyState === WebSocket.OPEN) {
                    ws.send(message);
                }
            });
        }
    }

    /**
     * Broadcast to all connected clients
     */
    broadcast(event) {
        if (!this.wss) return;
        const message = JSON.stringify(event);
        this.wss.clients.forEach(client => {
            if (client.readyState === WebSocket.OPEN) {
                client.send(message);
            }
        });
    }
}

module.exports = new WebSocketService();
