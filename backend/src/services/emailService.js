const nodemailer = require('nodemailer');

/**
 * Production-ready Email Service
 * Sends order and reservation confirmations
 */

// Create reusable transporter
// Create reusable transporter
const transporter = nodemailer.createTransport({
    service: 'gmail', // Auto-configures host, port, etc.
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

/**
 * Send order confirmation email
 * @param {object} order - Order object with items
 * @param {string} customerEmail - Customer's email address
 * @param {object} restaurant - Restaurant details
 */
exports.sendOrderConfirmation = async (order, customerEmail, restaurant) => {
    try {
        const itemsHtml = order.items.map(item => `
            <tr>
                <td style="padding: 12px; border-bottom: 1px solid #eee;">${item.name}</td>
                <td style="padding: 12px; border-bottom: 1px solid #eee; text-align: center;">${item.quantity}</td>
                <td style="padding: 12px; border-bottom: 1px solid #eee; text-align: right;">$${item.price.toFixed(2)}</td>
                <td style="padding: 12px; border-bottom: 1px solid #eee; text-align: right; font-weight: 600;">$${(item.price * item.quantity).toFixed(2)}</td>
            </tr>
        `).join('');

        const paymentMethodText = order.paymentMethod === 'card' ?
            '<span style="color: #10b981;">Card Payment (Paid)</span>' :
            '<span style="color: #f59e0b;">Cash on Delivery</span>';

        const htmlContent = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmation</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f9fafb;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f9fafb; padding: 40px 20px;">
        <tr>
            <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
                    <!-- Header -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px; text-align: center;">
                            <h1 style="margin: 0; color: #ffffff; font-size: 32px; font-weight: 800;">Order Confirmed!</h1>
                            <p style="margin: 8px 0 0 0; color: #e0e7ff; font-size: 16px;">Thank you for your order</p>
                        </td>
                    </tr>
                    
                    <!-- Order Details -->
                    <tr>
                        <td style="padding: 40px;">
                            <h2 style="margin: 0 0 24px 0; font-size: 20px; color: #111827;">Order #${order.id.slice(0, 8).toUpperCase()}</h2>
                            
                            <div style="background-color: #f3f4f6; padding: 20px; border-radius: 12px; margin-bottom: 24px;">
                                <p style="margin: 0 0 8px 0; color: #6b7280; font-size: 14px; text-transform: uppercase; font-weight: 600; letter-spacing: 0.5px;">Delivery To</p>
                                <p style="margin: 0; font-size: 16px; color: #111827; font-weight: 500;">${order.customerName}</p>
                                ${order.deliveryAddress ? `<p style="margin: 8px 0 0 0; color: #4b5563; font-size: 14px;">${order.deliveryAddress}</p>` : ''}
                                ${order.customerPhone ? `<p style="margin: 4px 0 0 0; color: #4b5563; font-size: 14px;">${order.customerPhone}</p>` : ''}
                            </div>
                            
                            <!-- Items Table -->
                            <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom: 24px;">
                                <thead>
                                    <tr style="background-color: #f9fafb;">
                                        <th style="padding: 12px; text-align: left; font-size: 12px; color: #6b7280; text-transform: uppercase; font-weight: 600;">Item</th>
                                        <th style="padding: 12px; text-align: center; font-size: 12px; color: #6b7280; text-transform: uppercase; font-weight: 600;">Qty</th>
                                        <th style="padding: 12px; text-align: right; font-size: 12px; color: #6b7280; text-transform: uppercase; font-weight: 600;">Price</th>
                                        <th style="padding: 12px; text-align: right; font-size: 12px; color: #6b7280; text-transform: uppercase; font-weight: 600;">Total</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    ${itemsHtml}
                                </tbody>
                            </table>
                            
                            <!-- Total -->
                            <div style="border-top: 2px solid #e5e7eb; padding-top: 20px; margin-top: 20px;">
                                <table width="100%">
                                    <tr>
                                        <td style="padding: 8px 0; font-size: 14px; color: #6b7280;">Payment Method</td>
                                        <td style="padding: 8px 0; text-align: right; font-size: 14px;">${paymentMethodText}</td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 12px 0; font-size: 20px; font-weight: 800; color: #111827;">Total</td>
                                        <td style="padding: 12px 0; text-align: right; font-size: 24px; font-weight: 800; color: #667eea;">$${order.totalAmount.toFixed(2)}</td>
                                    </tr>
                                </table>
                            </div>
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #f9fafb; padding: 32px; text-align: center; border-top: 1px solid #e5e7eb;">
                            <p style="margin: 0 0 12px 0; color: #6b7280; font-size: 14px;">Questions about your order?</p>
                            <p style="margin: 0; color: #4b5563; font-size: 14px;">Contact <strong>${restaurant?.name || 'us'}</strong></p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
        `;

        await transporter.sendMail({
            from: `"${restaurant?.name || 'Restaurant'}" <${process.env.EMAIL_USER}>`,
            to: customerEmail,
            subject: `Order Confirmation #${order.id.slice(0, 8).toUpperCase()}`,
            html: htmlContent
        });

        console.log(`✅ Order confirmation email sent to ${customerEmail}`);
    } catch (error) {
        console.error('Email sending error:', error);
        // Don't throw - email failure shouldn't break order creation
    }
};

/**
 * Send reservation confirmation email
 * @param {object} reservation - Reservation object
 * @param {string} customerEmail - Customer's email address
 * @param {object} restaurant - Restaurant details
 */
exports.sendReservationConfirmation = async (reservation, customerEmail, restaurant) => {
    try {
        const reservationDate = new Date(reservation.time);
        const formattedDate = reservationDate.toLocaleDateString('en-US', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
        const formattedTime = reservationDate.toLocaleTimeString('en-US', {
            hour: '2-digit',
            minute: '2-digit'
        });

        const htmlContent = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservation Confirmation</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f9fafb;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f9fafb; padding: 40px 20px;">
        <tr>
            <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
                    <!-- Header -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); padding: 40px; text-align: center;">
                            <h1 style="margin: 0; color: #ffffff; font-size: 32px; font-weight: 800;">Reservation Confirmed!</h1>
                            <p style="margin: 8px 0 0 0; color: #d1fae5; font-size: 16px;">We look forward to serving you</p>
                        </td>
                    </tr>
                    
                    <!-- Reservation Details -->
                    <tr>
                        <td style="padding: 40px;">
                            <h2 style="margin: 0 0 24px 0; font-size: 20px; color: #111827;">Reservation Details</h2>
                            
                            <div style="background-color: #f0fdf4; border-left: 4px solid #10b981; padding: 24px; border-radius: 8px; margin-bottom: 24px;">
                                <table width="100%">
                                    <tr>
                                        <td style="padding: 12px 0; color: #6b7280; font-size: 14px; text-transform: uppercase; font-weight: 600;">Name</td>
                                        <td style="padding: 12px 0; text-align: right; font-size: 16px; color: #111827; font-weight: 600;">${reservation.customerName}</td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 12px 0; color: #6b7280; font-size: 14px; text-transform: uppercase; font-weight: 600;">Date</td>
                                        <td style="padding: 12px 0; text-align: right; font-size: 16px; color: #111827; font-weight: 600;">${formattedDate}</td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 12px 0; color: #6b7280; font-size: 14px; text-transform: uppercase; font-weight: 600;">Time</td>
                                        <td style="padding: 12px 0; text-align: right; font-size: 16px; color: #111827; font-weight: 600;">${formattedTime}</td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 12px 0; color: #6b7280; font-size: 14px; text-transform: uppercase; font-weight: 600;">Party Size</td>
                                        <td style="padding: 12px 0; text-align: right; font-size: 16px; color: #111827; font-weight: 600;">${reservation.partySize} ${reservation.partySize === 1 ? 'Guest' : 'Guests'}</td>
                                    </tr>
                                </table>
                            </div>
                            
                            <div style="background-color: #fef3c7; border-radius: 8px; padding: 16px; margin-top: 24px;">
                                <p style="margin: 0; color: #92400e; font-size: 14px; line-height: 1.6;">
                                    <strong>Important:</strong> Please arrive 10 minutes early. If you need to cancel or modify your reservation, please contact us as soon as possible.
                                </p>
                            </div>
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #f9fafb; padding: 32px; text-align: center; border-top: 1px solid #e5e7eb;">
                            <p style="margin: 0 0 12px 0; color: #6b7280; font-size: 14px;">See you soon at</p>
                            <p style="margin: 0; color: #111827; font-size: 18px; font-weight: 700;">${restaurant?.name || 'Our Restaurant'}</p>
                            ${reservation.customerPhone ? `<p style="margin: 12px 0 0 0; color: #6b7280; font-size: 14px;">Contact: ${reservation.customerPhone}</p>` : ''}
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
        `;

        await transporter.sendMail({
            from: `"${restaurant?.name || 'Restaurant'}" <${process.env.EMAIL_USER}>`,
            to: customerEmail,
            subject: `Reservation Confirmed - ${formattedDate} at ${formattedTime}`,
            html: htmlContent
        });

        console.log(`✅ Reservation confirmation email sent to ${customerEmail}`);
    } catch (error) {
        console.error('Email sending error:', error);
        // Don't throw - email failure shouldn't break reservation creation
    }
};
