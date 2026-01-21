const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');

class ReceiptService {
    async generateOrderReceipt(order, restaurant) {
        return new Promise((resolve, reject) => {
            try {
                // Standard thermal printer width is roughly 80mm (226 points)
                const doc = new PDFDocument({
                    size: [226, 600], // Height can be dynamic, but 600 is a safe start
                    margins: { top: 10, bottom: 10, left: 10, right: 10 }
                });

                const fileName = `receipt_${order.id}.pdf`;
                const filePath = path.join(__dirname, '../../uploads/receipts', fileName);

                // Ensure directory exists
                const dir = path.dirname(filePath);
                if (!fs.existsSync(dir)) {
                    fs.mkdirSync(dir, { recursive: true });
                }

                const stream = fs.createWriteStream(filePath);
                doc.pipe(stream);

                // --- Header ---
                doc.fontSize(14).text(restaurant.name.toUpperCase(), { align: 'center' });
                doc.fontSize(8).text(restaurant.address || '', { align: 'center' });
                doc.moveDown();

                doc.fontSize(10).text('ORDER RECEIPT', { align: 'center', underline: true });
                doc.moveDown(0.5);

                doc.fontSize(8).text(`Date: ${new Date(order.createdAt).toLocaleString()}`);
                doc.text(`Order ID: #${order.id.substring(0, 8).toUpperCase()}`);
                doc.text(`Customer: ${order.customerName}`);
                doc.moveDown();

                // --- Items Table ---
                doc.text('------------------------------------------');
                doc.text('ITEM          QTY    PRICE    TOTAL');
                doc.text('------------------------------------------');

                order.items.forEach(item => {
                    const itemName = item.name.length > 12 ? item.name.substring(0, 10) + '..' : item.name;
                    doc.text(
                        `${itemName.padEnd(14)} ${item.quantity.toString().padEnd(6)} ${item.price.toFixed(2).padEnd(8)} ${(item.price * item.quantity).toFixed(2)}`
                    );
                });

                doc.text('------------------------------------------');
                doc.moveDown(0.5);

                // --- Totals ---
                doc.fontSize(10).text(`TOTAL: $${order.totalAmount.toFixed(2)}`, { align: 'right' });
                doc.fontSize(8).text(`Payment: ${order.paymentMethod.toUpperCase()} (${order.paymentStatus})`, { align: 'right' });
                doc.moveDown();

                // --- Footer ---
                doc.text('Thank you for ordering!', { align: 'center' });
                doc.text('Powered by Rockster', { align: 'center', oblique: true });

                doc.end();

                stream.on('finish', () => resolve({ fileName, filePath }));
            } catch (error) {
                reject(error);
            }
        });
    }
}

module.exports = new ReceiptService();
