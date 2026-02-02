# Cosmos Admin Backend Features

This document provides a detailed overview of the features implemented in the Cosmos Admin backend.

## 1. Authentication & User Management
**Endpoints:** `/api/auth/*`
- **Registration:** Allows new restaurant managers to register (`/register`). Checks for existing emails.
- **Login:** secure login using Email/Password (`/login`). Returns JWT Access (1h) and Refresh (7d) tokens.
- **Token Management:**
    - Refresh Token endpoint (`/refresh`) to obtain new access tokens.
    - JWT-based protection for private routes.
- **Profile Management:**
    - Update profile details (Name, Address, Store Open/Closed status) (`/profile`).
    - View current user details (`/me`).
- **Password Recovery:**
    - Forgot Password flow (`/forgot-password`) sends a 6-digit code via email.
    - Reset Password flow (`/reset-password`) validates the code and updates the password.
    - *Security Note:* Uses a `PasswordReset` model with expiration times.
- **Slug Management:**
    - Unique URL slug for each restaurant (`/update-slug`).
    - Validation against reserved keywords (e.g., 'admin', 'api').
- **Push Notifications:**
    - Registration of FCM (Firebase Cloud Messaging) tokens (`/register-push-token`).

## 2. Order Management
**Endpoints:** `/api/orders/*`
- **Order Creation:**
    - **Private (Staff):** Create orders internally (`/`) with explicit customer names.
    - **Public (Web):** Public endpoint (`/public`) for customers.
        - Supports "Cash" and "Card" payment methods.
        - Applies logic for Coupons (validation, expiration, min amount).
        - Automatically creates Stripe Payment Intents for card orders.
- **Real-Time Updates:**
    - Uses WebSockets (`websocketService.js`) to push `new_order` and `order_update` events to the restaurant dashboard immediately.
- **Order Processing:**
    - Update order status (`/status/:id`).
    - Retrieve single order (`/:id`) or list all orders (`/`).
- **Receipts:**
    - PDF Receipt generation (`/receipt/:id`) using `pdfkit`.
    - Generates a thermal-printer friendly PDF (80mm width).

## 3. Payments & Payouts (Stripe Connect)
**Endpoints:** `/api/payments/*`
- **Platform Architecture:** Uses Stripe Connect with **Express** accounts.
- **Onboarding:**
    - Create Connected Account (`/create-connected-account`): Generates an onboarding link for the restaurant manager to verify their identity with Stripe.
    - Idempotency check: Prevents duplicate account creation for the same user.
- **Payment Processing:**
    - Create Payment Intent (`/create-payment-intent`): Generates a client secret for frontend payment sheets.
- **Dashboard & Reporting:**
    - Fetch Stripe Account status (Balance, Currency, Connectivity) (`/account`).
    - List recent Transactions/Charges (`/transactions`).
    - Generate one-time login link to the Stripe Dashboard (`/dashboard-link`).
- **Webhooks:** Handler for Stripe webhooks (implied by routes).

## 4. Product & Menu Management
**Endpoints:** `/api/menu/*`, `/api/products/*`
- **Core Models:** `Category`, `Product`, `ModifierGroup`, `Modifier`.
- **Functionality:**
    - CRUD operations for Categories and Products.
    - **Modifiers:** Complex modifier system supporting:
        - Minimum/Maximum selection limits (e.g., "Choose at least 1, max 2").
        - Extra prices for specific modifiers.
    - Product availability toggles (`isAvailable`).
    - Image associations (linked via URL).

## 5. Marketing & Engagement
- **Coupons (`/api/coupons/*`):**
    - Create unique codes (e.g., "SUMMER20").
    - Discount types: `PERCENT` or `FIXED`.
    - Expiration dates and Minimum Order Amount constraints.
- **Reviews (`/api/reviews/*`):**
    - Customer submission of ratings and comments.
    - Approval workflow (`isApproved` flag) before public display.
- **Notifications (`/api/notifications/*`):**
    - Internal system notifications for orders and system events.
    - Push notifications via Firebase (FCM).

## 6. Reservations & Table Management
**Endpoints:** `/api/reservations/*`, `/api/tables/*`
- **Table Layout:**
    - Manage physical tables with coordinates (`x`, `y`), name, and seat capacity.
    - Track table status (`available`, etc.).
- **Reservations:**
    - Booking system linking customers to tables.
    - Tracks party size, time, and contact info.

## 7. Website Configuration
**Endpoints:** `/api/website/*`
- **Customization:**
    - Restaurants can configure their public page:
        - Headline & Subheadline.
        - Hero Image.
        - Primary Brand Color.
        - Start Button Text ("Order Now").
    - **Delivery Settings:** Configure delivery radius (Km).

## 8. Infrastructure & Utilities
- **File Uploads (`/api/upload/*`):**
    - Handles image uploads (JPEG).
    - **Optimization:** Uses `sharp` to resize (max 800x800) and compress images before storage.
    - **Storage:** Local file system storage (`backend/uploads/`), served via static middleware.
- **Email Service (`services/mailService.js`):**
    - Uses `nodemailer` for transactional emails (Reset Password, Order Confirmations).
- **Database:**
    - **Prisma ORM** for type-safe database access.
    - Schema supports relational data (User -> Orders -> Items).
    - Currently configured for PostgreSQL (production) with SQLite fallback dev capability.
- **Security:**
    - `bcryptjs` for password hashing.
    - `express-rate-limit` for API rate limiting.
    - CORS configuration.
