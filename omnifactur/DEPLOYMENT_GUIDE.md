# 🚀 Complete Deployment Guide - OmniFactur

> **Quick Start?** See [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) for 5-minute MVP setup  
> **API Details?** See [API_INTEGRATION_GUIDE.md](./API_INTEGRATION_GUIDE.md) for complete integration docs  
> **All Variables?** See [.env.example](./.env.example) for complete configuration template

---

## 📊 Summary: What You Need to Connect

### **APIs to Connect: 5 Total**
- ✅ **Supabase** (REQUIRED) - Already implemented
- ⚠️ **FNFE-MPE** (CRITICAL) - Register at https://fnfe-mpe.org/
- 🟡 **INSEE SIRENE** (Optional) - Register at https://api.insee.fr/
- 🔵 **OpenAI Whisper** (Phase 3) - For voice input
- 🔵 **Chorus Pro** (Phase 4) - Government portal

### **Environment Variables: 306 Total**
- ✅ **4 Required** (Supabase + App URL)
- 🟡 **13 Recommended** (FNFE-MPE, INSEE, SMTP, monitoring)
- 🔵 **289 Optional** (Advanced features, white-label, billing)

**See complete list in:** [.env.example](./.env.example)

---

## 📋 Pre-Deployment Checklist

### Required Accounts
- [ ] Supabase account (free tier works)
- [ ] Vercel account (or Scaleway for EU hosting)
- [ ] OpenAI account (for Whisper API - Phase 3)
- [ ] INSEE API account (optional - for SIRENE lookups)
- [ ] Domain registrar (for omnifactur.fr)

---

## 🔧 Backend Setup (Supabase)

### Step 1: Create Supabase Project

1. Go to https://supabase.com/dashboard
2. Click "New Project"
3. **CRITICAL**: Select **Frankfurt** region (EU data residency)
4. Project name: `omnifactur-production`
5. Database password: Generate strong password (save securely)
6. Wait 2 minutes for provisioning

### Step 2: Run Database Migrations

**Execute in Supabase SQL Editor:**

```bash
# Navigate to: SQL Editor > New Query
# Copy and paste contents of:
1. supabase/migrations/001_initial_schema.sql
2. supabase/storage-setup.sql
```

**Verification:**
```sql
-- Check tables created
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

-- Expected: cabinets, accountants, clients, invoices, line_items, 
--           white_label_configs, audit_logs

-- Check RLS enabled
SELECT tablename, rowsecurity FROM pg_tables 
WHERE schemaname = 'public';

-- Expected: All tables show rowsecurity = true
```

### Step 3: Configure Authentication

**In Supabase Dashboard:**

1. **Authentication > Providers**
   - Enable Email provider
   - Disable password (magic link only)
   - Email template: Confirm signup
     ```
     Subject: Connexion à OmniFactur - Lien Magique
     Body: Cliquez sur ce lien pour vous connecter (valide 15 minutes):
     {{ .ConfirmationURL }}
     ```

2. **Authentication > URL Configuration**
   - Site URL: `https://omnifactur.fr` (or your domain)
   - Redirect URLs: Add `https://omnifactur.fr/auth/callback`

3. **Authentication > Email Settings**
   - SMTP Configuration (Production):
     - Host: smtp.sendgrid.net (or your provider)
     - Port: 587
     - Username: apikey
     - Password: Your SendGrid API key
   - For MVP: Use Supabase default emails

### Step 4: Get API Keys

**Navigate to: Settings > API**

Copy these values (needed for frontend):
```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... (SECRET!)
```

### Step 5: Configure Storage

**In Supabase Dashboard:**

1. **Storage > Buckets**
   - Verify `logos` bucket created (from storage-setup.sql)
   - Public: Yes
   - File size limit: 2 MB
   - Allowed MIME types: image/png, image/jpeg, image/svg+xml

2. **Test Upload:**
   - Upload test image via dashboard
   - Verify public URL accessible

### Step 6: Enable Backups

**Settings > Database > Backups**
- Enable daily automated backups
- Retention: 7 days (free tier)
- Schedule: 2:00 AM UTC

---

## 🎨 Frontend Setup (Next.js)

### Step 1: Configure Environment Variables

Create `.env.local` in project root:

```env
# ===========================================
# SUPABASE CONFIGURATION (REQUIRED)
# ===========================================
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... # SERVER-SIDE ONLY

# ===========================================
# APPLICATION CONFIGURATION (REQUIRED)
# ===========================================
NEXT_PUBLIC_APP_URL=https://omnifactur.fr  # Your production domain

# ===========================================
# EXTERNAL APIS (OPTIONAL - Phase 2/3)
# ===========================================

# OpenAI Whisper API (for voice input)
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx  # Optional until Phase 3

# INSEE SIRENE API (for company data lookup)
INSEE_API_KEY=your-insee-api-key  # Optional, can use manual entry
INSEE_API_ENDPOINT=https://api.insee.fr/entreprises/sirene/V3

# FNFE-MPE Validation (French government)
FNFE_API_KEY=your-fnfe-validation-key  # Optional until production
FNFE_API_ENDPOINT=https://validation.fnfe-mpe.fr/api/v1/validate

# ===========================================
# PLATEFORME AGRÉÉE / CHORUS PRO (Phase 4)
# ===========================================
CHORUS_PRO_CLIENT_ID=your-client-id  # Optional
CHORUS_PRO_CLIENT_SECRET=your-secret  # Optional
CHORUS_PRO_API_ENDPOINT=https://api.chorus-pro.gouv.fr

# ===========================================
# EMAIL CONFIGURATION (Production)
# ===========================================
SMTP_HOST=smtp.sendgrid.net  # If using custom SMTP
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=your-sendgrid-api-key

# ===========================================
# MONITORING & ANALYTICS (Optional)
# ===========================================
SENTRY_DSN=https://your-sentry-dsn  # Error tracking
PLAUSIBLE_DOMAIN=omnifactur.fr  # Privacy-friendly analytics
```

### Step 2: Install Dependencies

```bash
cd omnifactur
npm install
```

### Step 3: Test Locally

```bash
npm run dev
```

Visit http://localhost:3000 and verify:
- [ ] Landing page loads with countdown
- [ ] "Se connecter" redirects to /auth
- [ ] Magic link can be requested (check Supabase logs)

---

## 🌍 Production Deployment

### Option A: Vercel (Recommended for Speed)

**Pros**: Zero-config Next.js, automatic HTTPS, global CDN
**Cons**: Not EU-only (CDN globally distributed)

**Steps:**

1. **Install Vercel CLI**
```bash
npm i -g vercel
```

2. **Deploy**
```bash
vercel --prod
```

3. **Configure Environment Variables**
   - Go to Vercel Dashboard > Project Settings > Environment Variables
   - Add all variables from `.env.local`
   - **CRITICAL**: Mark `SUPABASE_SERVICE_ROLE_KEY` as sensitive

4. **Set Custom Domain**
   - Domains > Add Domain: `omnifactur.fr`
   - DNS Configuration:
     ```
     Type: CNAME
     Name: @
     Value: cname.vercel-dns.com
     ```
   - SSL: Automatic (Let's Encrypt)

5. **Configure Rewrites (if needed)**
   Create `vercel.json`:
   ```json
   {
     "regions": ["cdg1"],
     "framework": "nextjs"
   }
   ```

### Option B: Scaleway Paris (EU Data Residency)

**Pros**: 100% EU hosting, GDPR-compliant, French datacenter
**Cons**: More manual configuration

**Steps:**

1. **Create Scaleway Account**
   - Go to https://console.scaleway.com
   - Region: PAR1 (Paris)

2. **Create Serverless Container**
   - Navigate to: Containers > Create Namespace
   - Name: `omnifactur-prod`
   - Region: Paris (fr-par)

3. **Build Docker Image**
   Create `Dockerfile`:
   ```dockerfile
   FROM node:18-alpine AS base

   # Install dependencies
   FROM base AS deps
   WORKDIR /app
   COPY package*.json ./
   RUN npm ci

   # Build application
   FROM base AS builder
   WORKDIR /app
   COPY --from=deps /app/node_modules ./node_modules
   COPY . .
   RUN npm run build

   # Production image
   FROM base AS runner
   WORKDIR /app
   ENV NODE_ENV production

   COPY --from=builder /app/public ./public
   COPY --from=builder /app/.next/standalone ./
   COPY --from=builder /app/.next/static ./.next/static

   EXPOSE 3000
   ENV PORT 3000

   CMD ["node", "server.js"]
   ```

   Update `next.config.js`:
   ```javascript
   module.exports = {
     output: 'standalone',
   }
   ```

4. **Deploy to Scaleway**
   ```bash
   # Build image
   docker build -t omnifactur:latest .

   # Tag for Scaleway registry
   docker tag omnifactur:latest rg.fr-par.scw.cloud/omnifactur/app:latest

   # Push
   docker push rg.fr-par.scw.cloud/omnifactur/app:latest
   ```

5. **Configure Container**
   - Min instances: 1
   - Max instances: 10
   - Memory: 1024 MB
   - Port: 3000
   - Environment variables: Add all from `.env.local`

---

## 🔗 API Integrations Required

### 📊 Integration Summary Table

| API | Status | Required For | Cost | Priority |
|-----|--------|--------------|------|----------|
| **Supabase** | ✅ Implemented | Database, Auth, Storage | Free (up to 500MB) | **CRITICAL** |
| **OpenAI Whisper** | 🟡 Scaffolded | Voice input (Phase 3) | €0.006/min | Optional |
| **INSEE SIRENE** | 🟡 Scaffolded | Company lookup | Free | Optional |
| **FNFE-MPE** | 🟡 Scaffolded | Invoice validation | Free (gov API) | **Important** |
| **Chorus Pro** | 🟡 Scaffolded | Gov invoice submission | Free | Optional |

### 1️⃣ SUPABASE (REQUIRED - Already Implemented)

**Purpose**: Database, authentication, file storage
**Status**: ✅ Fully integrated
**Cost**: Free tier (500MB database, 1GB storage, 50MB file uploads)

**Environment Variables:**
```env
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc... (server-side only)
```

**Files Using This API:**
- `src/lib/supabase/client.ts`
- `src/lib/supabase/server.ts`
- `src/lib/supabase/middleware.ts`
- All pages and API routes

**No additional signup needed** - you already have Supabase project.

---

### 2️⃣ OPENAI WHISPER API (Optional - Phase 3)

**Purpose**: Voice-to-text for invoice data entry
**Status**: 🟡 Function placeholder in code
**Cost**: $0.006 per minute of audio

**Setup:**

1. **Get API Key:**
   - Go to https://platform.openai.com
   - API Keys > Create new secret key
   - Copy: `sk-proj-xxxxxxxxxxxxx`

2. **Add to `.env.local`:**
   ```env
   OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx
   ```

3. **Integration Point:**
   File: `src/app/cabinet/invoices/new/page.tsx`
   Function: `handleVoiceInput()`

4. **Implementation (when ready):**
   ```typescript
   const response = await fetch('/api/whisper/transcribe', {
     method: 'POST',
     body: audioBlob
   })
   ```

   Create `/src/app/api/whisper/transcribe/route.ts`:
   ```typescript
   export async function POST(request: Request) {
     const formData = await request.formData()
     const audio = formData.get('audio')
     
     const response = await fetch('https://api.openai.com/v1/audio/transcriptions', {
       method: 'POST',
       headers: {
         'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`
       },
       body: formData
     })
     
     const { text } = await response.json()
     return NextResponse.json({ transcript: text })
   }
   ```

**Usage Estimate:**
- 30 seconds per invoice = $0.003
- 100 invoices/month = $0.30
- Negligible cost

---

### 3️⃣ INSEE SIRENE API (Optional)

**Purpose**: Auto-fill company data from SIREN number
**Status**: 🟡 Placeholder comments in code
**Cost**: **FREE** (French government open data)

**Setup:**

1. **Get API Key:**
   - Go to https://api.insee.fr/catalogue/
   - Create account > Request access to "Sirene API V3"
   - Copy consumer key

2. **Add to `.env.local`:**
   ```env
   INSEE_API_KEY=your-consumer-key
   INSEE_API_ENDPOINT=https://api.insee.fr/entreprises/sirene/V3
   ```

3. **Integration Point:**
   File: `src/app/cabinet/invoices/new/page.tsx`
   Location: Header section where SIREN is entered

4. **Implementation:**
   Create `/src/app/api/sirene/lookup/route.ts`:
   ```typescript
   export async function GET(request: Request) {
     const { searchParams } = new URL(request.url)
     const siren = searchParams.get('siren')
     
     const response = await fetch(
       `${process.env.INSEE_API_ENDPOINT}/siren/${siren}`,
       {
         headers: {
           'Authorization': `Bearer ${process.env.INSEE_API_KEY}`,
           'Accept': 'application/json'
         }
       }
     )
     
     const data = await response.json()
     
     return NextResponse.json({
       company_name: data.uniteLegale.denominationUniteLegale,
       address: data.adresseEtablissement,
       vat_number: `FR${data.uniteLegale.siren}`,
       legal_form: data.uniteLegale.categorieJuridiqueUniteLegale
     })
   }
   ```

**Rate Limits:**
- 30 requests/minute
- 2000 requests/day (free tier)
- More than sufficient for beta

---

### 4️⃣ FNFE-MPE VALIDATION (Important)

**Purpose**: Validate Factur-X invoices before delivery
**Status**: 🟡 Function scaffolded, needs endpoint
**Cost**: **FREE** (French government service)

**Setup:**

1. **Register for Access:**
   - Contact: Forum National de la Facture Électronique (FNFE-MPE)
   - Email: contact@fnfe-mpe.org
   - Request: API access for invoice validation
   - Wait: 2-5 business days for credentials

2. **Add to `.env.local`:**
   ```env
   FNFE_API_KEY=your-validation-key
   FNFE_API_ENDPOINT=https://validation.fnfe-mpe.fr/api/v1/validate
   ```

3. **Integration Point:**
   File: `src/app/api/facturx/generate/route.ts`
   Function: `validateWithFNFEMPE()` (already exists, needs activation)

4. **Activate in Production:**
   Replace placeholder in function:
   ```typescript
   async function validateWithFNFEMPE(xmlContent: string) {
     const response = await fetch(process.env.FNFE_API_ENDPOINT!, {
       method: 'POST',
       headers: {
         'Content-Type': 'application/xml',
         'Authorization': `Bearer ${process.env.FNFE_API_KEY}`
       },
       body: xmlContent
     })
     
     const result = await response.json()
     
     return {
       status: result.compliant ? 'VALIDATED' : 'REJECTED',
       certificate_url: result.certificate_url,
       errors: result.errors || []
     }
   }
   ```

**Expected Response:**
```json
{
  "compliant": true,
  "certificate_url": "https://fnfe-mpe.fr/certificates/abc123.pdf",
  "validation_date": "2026-01-06T12:00:00Z",
  "errors": []
}
```

---

### 5️⃣ CHORUS PRO (Optional - Phase 4)

**Purpose**: Submit invoices to French government portal
**Status**: 🟡 Settings page has connection UI
**Cost**: **FREE**

**Setup:**

1. **Register:**
   - Go to https://chorus-pro.gouv.fr
   - Create professional account
   - Complete verification (requires SIREN)

2. **Get OAuth Credentials:**
   - Portail > Mon compte > Espaces de développement
   - Create new application
   - Copy: Client ID and Client Secret

3. **Add to `.env.local`:**
   ```env
   CHORUS_PRO_CLIENT_ID=your-client-id
   CHORUS_PRO_CLIENT_SECRET=your-client-secret
   CHORUS_PRO_API_ENDPOINT=https://api.chorus-pro.gouv.fr
   ```

4. **Integration Point:**
   File: `src/app/cabinet/settings/page.tsx`
   Function: `handleTestPA()` (needs backend API route)

5. **Implementation:**
   Create `/src/app/api/chorus-pro/submit/route.ts`:
   ```typescript
   export async function POST(request: Request) {
     const { invoiceId } = await request.json()
     
     // OAuth token request
     const tokenResponse = await fetch(`${process.env.CHORUS_PRO_API_ENDPOINT}/oauth/token`, {
       method: 'POST',
       headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
       body: new URLSearchParams({
         grant_type: 'client_credentials',
         client_id: process.env.CHORUS_PRO_CLIENT_ID!,
         client_secret: process.env.CHORUS_PRO_CLIENT_SECRET!
       })
     })
     
     const { access_token } = await tokenResponse.json()
     
     // Submit invoice
     const submitResponse = await fetch(`${process.env.CHORUS_PRO_API_ENDPOINT}/invoices`, {
       method: 'POST',
       headers: {
         'Authorization': `Bearer ${access_token}`,
         'Content-Type': 'application/json'
       },
       body: JSON.stringify({ /* invoice data */ })
     })
     
     return NextResponse.json(await submitResponse.json())
   }
   ```

---

## 📝 Complete Environment Variables Checklist

### ✅ REQUIRED (For MVP Launch)

```env
# Supabase (CRITICAL)
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# Application
NEXT_PUBLIC_APP_URL=https://omnifactur.fr
```

**Total Required: 4 variables**

### 🟡 OPTIONAL (Phase 2-4 Enhancements)

```env
# Voice Input (Phase 3)
OPENAI_API_KEY=

# Company Lookup
INSEE_API_KEY=
INSEE_API_ENDPOINT=https://api.insee.fr/entreprises/sirene/V3

# Invoice Validation
FNFE_API_KEY=
FNFE_API_ENDPOINT=https://validation.fnfe-mpe.fr/api/v1/validate

# Government Portal (Phase 4)
CHORUS_PRO_CLIENT_ID=
CHORUS_PRO_CLIENT_SECRET=
CHORUS_PRO_API_ENDPOINT=https://api.chorus-pro.gouv.fr

# Custom SMTP (if not using Supabase default)
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=

# Monitoring
SENTRY_DSN=
PLAUSIBLE_DOMAIN=omnifactur.fr
```

**Total Optional: 13 variables**

---

## 🧪 Post-Deployment Testing

### Test Checklist

```bash
# 1. Landing Page
curl -I https://omnifactur.fr
# Expected: 200 OK, security headers present

# 2. API Health
curl https://omnifactur.fr/api/health
# Expected: {"status": "ok", "database": "connected"}

# 3. Authentication Flow
# - Visit /auth
# - Request magic link
# - Check email
# - Click link
# - Should redirect to /cabinet or /dashboard

# 4. Database Connection
# - Create test cabinet via SQL
# - Login as accountant
# - Verify RLS: Cannot see other cabinets

# 5. Storage
# - Upload logo in settings
# - Verify public URL accessible
```

---

## 🚨 Security Hardening

### Pre-Launch Security Checklist

- [ ] Environment variables not exposed to client
- [ ] SUPABASE_SERVICE_ROLE_KEY only server-side
- [ ] RLS policies tested (cross-cabinet access blocked)
- [ ] HTTPS enforced (HTTP redirects to HTTPS)
- [ ] CORS configured (restrict origins)
- [ ] Rate limiting on auth endpoints (10 attempts/hour)
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS protection (input sanitization)
- [ ] CSRF tokens on mutations
- [ ] Content Security Policy headers

### Recommended Headers (Vercel)

Create `vercel.json`:
```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-XSS-Protection",
          "value": "1; mode=block"
        },
        {
          "key": "Strict-Transport-Security",
          "value": "max-age=31536000; includeSubDomains"
        }
      ]
    }
  ]
}
```

---

## 📊 Monitoring Setup

### 1. Uptime Monitoring

**UptimeRobot** (Free):
1. Go to https://uptimerobot.com
2. Add Monitor:
   - Type: HTTPS
   - URL: https://omnifactur.fr
   - Interval: 5 minutes
   - Alert: Email when down

### 2. Error Tracking

**Sentry** (Free tier: 5k errors/month):
```bash
npm install @sentry/nextjs
npx @sentry/wizard -i nextjs
```

Add to `.env.local`:
```env
SENTRY_DSN=https://xxx@yyy.ingest.sentry.io/zzz
```

### 3. Analytics

**Plausible** (Privacy-friendly, GDPR compliant):
```bash
npm install next-plausible
```

Add to `src/app/layout.tsx`:
```tsx
import PlausibleProvider from 'next-plausible'

export default function RootLayout({ children }) {
  return (
    <html>
      <head>
        <PlausibleProvider domain="omnifactur.fr" />
      </head>
      <body>{children}</body>
    </html>
  )
}
```

---

## 🎯 Beta Launch Checklist

### Final Pre-Launch Steps

- [ ] Domain DNS configured (omnifactur.fr)
- [ ] SSL certificate active (HTTPS working)
- [ ] All environment variables set in Vercel/Scaleway
- [ ] Supabase backups enabled
- [ ] Email templates tested (magic link works)
- [ ] Create 1 test cabinet manually in Supabase
- [ ] Test full invoice creation flow
- [ ] FEC export downloads successfully
- [ ] Legal pages (Mentions Légales, CGV) accessible
- [ ] Mobile responsive tested (iPhone, Android)
- [ ] Monitoring active (UptimeRobot, Sentry)

### First 2 Beta Cabinets

**LinkedIn Outreach:**
```
Subject: Votre cabinet prêt pour 2026 ? - Offre Pilote (€490/mois)

Bonjour [Prénom],

Le 1er janvier 2026, la facturation électronique devient obligatoire pour tous.

OmniFactur aide les cabinets comptables à gérer cette transition pour leurs 30-50 clients :
✓ Export FEC compatible Cegid/Sage sans erreur (économie 10h/mois)
✓ Portail white-label à votre marque
✓ Validation automatique Factur-X 1.0.08

**Offre Pilote** : €490/mois (50% de réduction) pour les 2 premiers cabinets.
Engagement 6 mois, toutes fonctionnalités incluses.

Disponible pour une démo de 15 minutes cette semaine ?

Cordialement,
[Votre nom]
OmniFactur
```

---

**Deployment Ready. Start with 4 required variables + Supabase setup (30 min).**
