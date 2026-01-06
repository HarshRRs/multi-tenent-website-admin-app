# 🚀 OmniFactur - Quick Deployment Reference

## 📊 APIs & Variables Summary

### **Total APIs: 5**

| # | API Name | Status | Cost | Purpose |
|---|----------|--------|------|---------|
| 1 | **Supabase** | ✅ Required | FREE | Database, Auth, Storage |
| 2 | **FNFE-MPE** | ⚠️ Critical | FREE | Invoice validation |
| 3 | **INSEE SIRENE** | 🟡 Optional | FREE | Company lookup |
| 4 | **OpenAI Whisper** | 🔵 Phase 3 | €12/mo | Voice input |
| 5 | **Chorus Pro** | 🔵 Phase 4 | FREE | Gov portal |

### **Total Environment Variables: 306**

**Breakdown:**
- ✅ **4 Required** (Must have for MVP)
- 🟡 **13 Recommended** (Production quality)
- 🔵 **289 Optional** (Advanced features)

---

## ⚡ Minimum Required Setup (5 Minutes)

### Step 1: Supabase (2 minutes)
```bash
1. Go to: https://supabase.com/dashboard
2. New Project → Frankfurt region
3. Copy 3 values:
   - Project URL
   - Anon Key
   - Service Role Key
```

### Step 2: Environment File (1 minute)
```bash
cp .env.example .env.local
```

Edit `.env.local`:
```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbG...
SUPABASE_SERVICE_ROLE_KEY=eyJhbG...
NEXT_PUBLIC_APP_URL=https://omnifactur.fr
```

### Step 3: Deploy (2 minutes)
```bash
vercel --prod
# Add same 4 variables in Vercel dashboard
```

✅ **Done! MVP is live.**

---

## 🎯 Production-Ready Setup (30 Minutes)

### Phase 1: Core APIs (15 minutes)

#### 1. FNFE-MPE Validation
```bash
1. Register: https://fnfe-mpe.org/
2. Request: API credentials (sandbox for beta)
3. Wait: 5-7 business days
4. Add to .env.local:
```
```env
FNFE_API_KEY=your-key-here
FNFE_API_ENDPOINT=https://validation.fnfe-mpe.fr/api/v1
```

#### 2. INSEE SIRENE
```bash
1. Register: https://api.insee.fr/
2. Subscribe: "API Sirene" (free)
3. Add to .env.local:
```
```env
INSEE_API_KEY=your-key-here
INSEE_API_ENDPOINT=https://api.insee.fr/entreprises/sirene/V3
```

### Phase 2: Production Email (15 minutes)

#### SendGrid Setup
```bash
1. Register: https://sendgrid.com/
2. Create API key
3. Configure in Supabase: Settings → Auth → SMTP
4. Add to .env.local:
```
```env
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=SG.your-api-key
SMTP_FROM_EMAIL=noreply@omnifactur.fr
```

✅ **Production quality achieved!**

---

## 🔵 Optional Features (As Needed)

### Voice Input (Phase 3)
**When**: First cabinet requests voice feature  
**Setup Time**: 5 minutes  
**Cost**: €0.006/minute (~€12/month per cabinet)

```bash
1. Register: https://platform.openai.com/
2. Add payment method
3. Generate API key
4. Add to .env.local:
```
```env
OPENAI_API_KEY=sk-proj-xxxxx
WHISPER_MODEL=whisper-1
WHISPER_LANGUAGE=fr
```

### Chorus Pro (Phase 4)
**When**: Cabinet has public sector clients  
**Setup Time**: 10-14 days (government approval)  
**Cost**: FREE

```bash
1. Register: https://chorus-pro.gouv.fr/
2. Apply as "Éditeur de logiciel"
3. Wait for approval (5-10 business days)
4. Get OAuth credentials
5. Add to .env.local:
```
```env
CHORUS_PRO_CLIENT_ID=your-id
CHORUS_PRO_CLIENT_SECRET=your-secret
CHORUS_PRO_API_ENDPOINT=https://api.chorus-pro.gouv.fr
```

---

## 📋 Deployment Checklist

### Before Beta Launch (First 2 Cabinets)
- [ ] Supabase database deployed (Frankfurt region)
- [ ] 4 required environment variables set
- [ ] FNFE-MPE sandbox credentials requested
- [ ] Domain configured: omnifactur.fr
- [ ] SSL certificate active (auto via Vercel)
- [ ] Test invoice generates PDF successfully
- [ ] FEC export downloads correctly
- [ ] Magic link emails sending
- [ ] RLS policies tested (no cross-cabinet access)

### Before Full Launch (€990/month Pricing)
- [ ] FNFE-MPE production credentials active
- [ ] INSEE SIRENE API registered
- [ ] SendGrid SMTP configured
- [ ] 3 case studies completed (10+ hours saved)
- [ ] Legal pages complete (Mentions Légales, CGV)
- [ ] Backup strategy enabled (daily at 2 AM)
- [ ] Monitoring active (Sentry + UptimeRobot)
- [ ] FEC imports tested with real Cegid/ACD

---

## 🆘 Troubleshooting

### Issue: Supabase connection fails
```bash
✅ Fix: Check Frankfurt region selected
✅ Verify: NEXT_PUBLIC_SUPABASE_URL matches project URL
✅ Test: Visit URL in browser (should load Supabase page)
```

### Issue: Magic link emails not sending
```bash
✅ Check: Supabase Auth settings → Email provider enabled
✅ Verify: Site URL and redirect URL configured
✅ Test: Check Supabase logs for email delivery status
```

### Issue: FNFE validation returns error
```bash
✅ MVP: Uses placeholder (returns PENDING_VALIDATION)
✅ Production: Requires actual FNFE-MPE credentials
✅ Timeline: Request credentials 2 weeks before launch
```

### Issue: FEC export fails in Cegid
```bash
✅ Check: Debits = Credits (balanced to cent)
✅ Verify: Decimal separator is comma (French format)
✅ Test: Character encoding UTF-8 or ISO-8859-15
```

---

## 💰 Cost Projection

### MVP Launch (Months 1-3)
```
Supabase Free Tier:     €0
Vercel Free Tier:       €0
FNFE-MPE:               €0
INSEE:                  €0
Domain (.fr):           €15/year
─────────────────────────────
TOTAL MONTHLY:          €0
ONE-TIME:               €15
```

### Production (5 Cabinets)
```
Supabase Pro:           €25/month
Vercel Pro:             €20/month
SendGrid:               €15/month (40k emails)
OpenAI Whisper:         €60/month (5 cabinets)
Monitoring:             €10/month
─────────────────────────────
TOTAL MONTHLY:          €130
REVENUE (5 × €990):     €4,950
NET MARGIN:             €4,820 (97.4%)
```

---

## 📞 Quick Links

| Resource | URL |
|----------|-----|
| **Deployment Guide** | `DEPLOYMENT_GUIDE.md` |
| **API Integration** | `API_INTEGRATION_GUIDE.md` |
| **Environment Template** | `.env.example` |
| **Supabase Dashboard** | https://supabase.com/dashboard |
| **Vercel Dashboard** | https://vercel.com/dashboard |
| **FNFE-MPE Registration** | https://fnfe-mpe.org/ |
| **INSEE API** | https://api.insee.fr/ |
| **OpenAI Platform** | https://platform.openai.com/ |
| **Chorus Pro** | https://chorus-pro.gouv.fr/ |

---

## 🎯 Next Steps

### Today (30 minutes):
1. ✅ Create Supabase project
2. ✅ Deploy to Vercel with 4 variables
3. ✅ Test authentication flow

### This Week (2 hours):
1. Register FNFE-MPE (sandbox)
2. Register INSEE SIRENE
3. Configure SendGrid
4. Test complete invoice workflow

### Before Beta Launch (1 week):
1. Wait for FNFE-MPE approval
2. Add production credentials
3. Test with 1 real accounting firm
4. Fix any issues

### LinkedIn Outreach (Week 2):
```
Subject: Conformité 2026 : Votre cabinet est-il prêt ?

Bonjour [Prénom],

Avec la mandate e-facture de janvier 2026, 
je propose une plateforme en marque blanche 
pour les cabinets comptables.

✅ Export FEC compatible Cegid (0 erreurs)
✅ Validation FNFE-MPE automatique
✅ Portail personnalisé avec votre logo

Tarif beta : 490€/mois (vs 990€ après lancement)
Places limitées à 2 cabinets.

Intéressé pour une démo de 15 min ?

Cordialement,
[Your Name]
OmniFactur
```

---

## ✅ You're Ready When:

- [x] `.env.example` copied to `.env.local`
- [x] 4 required variables configured
- [x] `npm run dev` works locally
- [x] `vercel --prod` deployed successfully
- [x] Test invoice created and downloaded
- [x] FNFE-MPE credentials requested
- [x] First beta cabinet lined up

**Status: 🚀 READY TO LAUNCH**
