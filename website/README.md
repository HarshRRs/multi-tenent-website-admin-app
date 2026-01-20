# Restaurant Website (Next.js)

## Overview
Dynamic customer-facing website for restaurants, fully controlled by the Cosmos Admin App. Changes to branding, menu, and settings in the Admin App are instantly reflected on this website.

## Features
- **Dynamic Branding**: Colors, headlines, and hero images sync from Admin App
- **Live Menu**: Real-time menu updates via Public API
- **Responsive Design**: Mobile-first, works on all devices
- **Fast & SEO-Optimized**: Built with Next.js 14 (App Router)

## Getting Started

### 1. Environment Setup
Create a `.env.local` file:
```env
NEXT_PUBLIC_API_URL=http://localhost:3001/api
NEXT_PUBLIC_RESTAURANT_ID=your-actual-user-id
```

> **Note**: Get your `RESTAURANT_ID` from the Admin App (it's the userId)

### 2. Install Dependencies
```bash
npm install
```

### 3. Run Development Server
```bash
npm run dev
```

Visit [http://localhost:3000](http://localhost:3000)

### 4. Build for Production
```bash
npm run build
npm start
```

## How It Works

### Dynamic Config Fetching
The website fetches configuration from:
```
GET /api/public/config/:restaurantId
```

This returns:
- `headline` - Hero title
- `subheadline` - Hero subtitle
- `primaryColor` - Brand color (buttons, accents)
- `heroImageUrl` - Background image
- `startButtonText` - CTA button text
- `deliveryRadiusKm` - Delivery coverage

### Menu Integration
Menu data is fetched from:
```
GET /api/public/menu/:restaurantId
```

Returns categories with products (only `isAvailable: true` items shown).

## Customization

### Change Backend URL
Edit `.env.local`:
```env
NEXT_PUBLIC_API_URL=https://your-production-api.com/api
```

### Restaurant Branding
All branding is controlled via the Admin App:
1. Open Admin App → Website Customizer
2. Change colors, text, or images
3. Click "Publish"
4. Refresh the website to see changes

## Deployment

### Vercel (Recommended)
1. Push to GitHub
2. Import to Vercel
3. Set Environment Variables:
   - `NEXT_PUBLIC_API_URL`
   - `NEXT_PUBLIC_RESTAURANT_ID`
4. Deploy

### Netlify
```bash
npm run build
```
Deploy the `.next` folder

## Stack
- **Next.js 14** - React framework
- **Tailwind CSS** - Styling
- **Zustand** - State management
- **Axios** - API client
- **Lucide React** - Icons
