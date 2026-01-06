# OmniFactur Implementation Guide

## 🎯 Setup Instructions

### 1. Prerequisites
- Node.js 18+ installed
- Supabase account (free tier works for MVP)
- Code editor (VS Code recommended)

### 2. Supabase Configuration

#### A. Create Supabase Project
1. Go to https://supabase.com
2. Create new project
3. Select **Frankfurt** region (EU data residency)
4. Wait for project initialization (~2 minutes)

#### B. Run Database Migration
1. Navigate to SQL Editor in Supabase dashboard
2. Copy contents of `supabase/migrations/001_initial_schema.sql`
3. Execute the SQL script
4. Verify tables created: cabinets, accountants, clients, invoices, line_items, white_label_configs

#### C. Enable Storage
1. Go to Storage section
2. Create bucket named `logos`
3. Set bucket to **public**
4. Configure RLS policies (allow authenticated uploads)

### 3. Environment Setup

Update `.env.local` with your Supabase credentials:

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
OPENAI_API_KEY=sk-your-openai-key (optional for Phase 3)
INSEE_API_KEY=your-insee-key (optional for Phase 3)
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### 4. Install & Run

```bash
cd omnifactur
npm install
npm run dev
```

Visit http://localhost:3000

## 📋 Testing the Application

### Test Scenario 1: Create Accounting Cabinet

1. **Manual Database Setup** (via Supabase SQL Editor):
```sql
-- Insert test cabinet
INSERT INTO cabinets (name, subscription_tier, is_active) 
VALUES ('Cabinet Test', 'beta', true);

-- Insert accountant (get cabinet_id from previous insert)
INSERT INTO accountants (cabinet_id, email, role) 
VALUES ('cabinet-id-here', 'accountant@test.fr', 'accountant');
```

2. **Test Magic Link Auth**:
- Go to http://localhost:3000/auth
- Enter: accountant@test.fr
- Check Supabase Auth > Users > Copy UUID
- Update accountants table: `UPDATE accountants SET auth_user_id = 'uuid-here' WHERE email = 'accountant@test.fr'`

3. **Send Magic Link**:
- Request magic link
- Check terminal/Supabase logs for magic link URL
- Click link to authenticate
- Should redirect to /cabinet

### Test Scenario 2: Create Invoice

1. **Add Test Client**:
```sql
INSERT INTO clients (cabinet_id, siren, company_name, industry_type) 
VALUES ('cabinet-id-here', '123456789', 'Plomberie Dupont', 'plumber');
```

2. **Create Invoice**:
- Navigate to Cabinet Portal
- Click client name
- Create new invoice
- Add line items with different TVA rates
- Verify automatic calculations

3. **Test FEC Export**:
- Select multiple clients (checkboxes)
- Click "Export FEC"
- Verify file downloads
- Open in text editor: Check pipe-delimited format

### Test Scenario 3: White-Label Configuration

1. Go to Cabinet Portal > Settings
2. Upload logo (PNG/SVG < 2MB)
3. Change primary color
4. Enter custom welcome message
5. Save configuration
6. Verify logo appears in navigation

## 🔒 Security Testing Checklist

### RLS Policy Validation

**Test 1: Cross-Cabinet Isolation**
```sql
-- Create second cabinet
INSERT INTO cabinets (name) VALUES ('Cabinet B');
INSERT INTO accountants (cabinet_id, email) VALUES ('cabinet-b-id', 'accountant-b@test.fr');

-- Attempt to query Cabinet A's clients as Cabinet B accountant
-- Should return ZERO results
SELECT * FROM clients WHERE cabinet_id = 'cabinet-a-id';
```

**Test 2: Client Data Access**
- Create client user with auth_user_id
- Login as client
- Attempt to access /cabinet route (should fail)
- Verify client can only see their own invoices

**Test 3: JWT Manipulation**
- Use browser DevTools > Application > Cookies
- Copy Supabase auth token
- Modify token payload (change user_id)
- Make API request
- Should return 401 Unauthorized

## 📊 Phase 1 Completion Checklist

### Core Features
- [x] Next.js 15 project initialized
- [x] Supabase client configured
- [x] Multi-tenant database schema
- [x] Bulletproof RLS policies
- [x] Magic link authentication
- [x] Role-based routing
- [x] Landing page with countdown
- [x] Cabinet Portal with client list
- [x] Omni-Editor with TVA calculation
- [x] FEC export API
- [x] White-label settings page
- [x] Factur-X PDF generation

### Security
- [x] RLS policies on all tables
- [x] Cabinet boundary triggers
- [x] Audit log table structure
- [ ] Penetration testing (manual verification required)
- [ ] Cross-cabinet access test (manual verification required)

### Validation
- [ ] Test FEC import in Cegid Quadra (requires actual software)
- [ ] FNFE-MPE validation (requires government API access)
- [ ] Load testing (100+ concurrent users)

## 🚀 Phase 2 Roadmap

### Priority Features
1. **SIRENE API Integration**
   - Auto-fill company data from SIREN
   - Validate company existence
   - Cache results (90 days)

2. **Whisper Voice Input**
   - Record audio in browser (WebRTC)
   - Upload to backend
   - Send to OpenAI Whisper API
   - Parse French transcript
   - Map to invoice fields

3. **Compliance Monitor Dashboard**
   - Calculate compliance score (0-100)
   - Traffic light indicators
   - Generate PDF reports
   - Track historical progress

4. **Factur-X 1.0.08 Validation**
   - Integrate FNFE-MPE API
   - Pre-submission validation
   - Store validation certificates
   - Display status in UI

5. **Chorus Pro Integration**
   - OAuth 2.0 authentication
   - Submit invoices to government portal
   - Track submission status
   - Handle acknowledgments

## 📈 Business Metrics to Track

### Technical Metrics
- Average invoice creation time (Target: < 3 min)
- FEC export error rate (Target: 0%)
- System uptime (Target: > 99.5%)
- API response time p95 (Target: < 500ms)

### User Adoption
- Accountant weekly active rate (Target: > 80%)
- Clients per cabinet (Target: 20+ in month 1)
- White-label activation (Target: > 60%)
- Voice feature usage (Target: > 30%)

### Business
- Monthly churn rate (Target: < 5%)
- Net Promoter Score (Target: > 50)
- Time to first invoice (Target: < 7 days)
- Customer acquisition cost (Target: < 2 months MRR)

## 🔧 Troubleshooting

### Issue: Magic Link Not Working
**Solution**: Check Supabase email settings
1. Go to Authentication > Email Templates
2. Verify SMTP configured or use Supabase default
3. Check spam folder
4. Test with personal email first

### Issue: RLS Policy Blocking Queries
**Solution**: Verify user has auth_user_id
```sql
-- Check accountant record
SELECT * FROM accountants WHERE email = 'your-email@test.fr';

-- Update auth_user_id
UPDATE accountants 
SET auth_user_id = (SELECT id FROM auth.users WHERE email = 'your-email@test.fr')
WHERE email = 'your-email@test.fr';
```

### Issue: FEC Export Shows 0 Invoices
**Solution**: Ensure cabinet_id matches
```sql
-- Verify invoice has correct cabinet_id
SELECT i.*, c.cabinet_id 
FROM invoices i 
JOIN clients c ON i.client_id = c.id
WHERE i.invoice_number = 'FAC-001';

-- Fix mismatched cabinet_id
UPDATE invoices 
SET cabinet_id = (SELECT cabinet_id FROM clients WHERE id = invoices.client_id);
```

### Issue: TypeScript Errors in Development
**Solution**: Restart Next.js dev server
```bash
# Stop server (Ctrl+C)
# Clear Next.js cache
rm -rf .next
# Restart
npm run dev
```

## 📞 Support Resources

- **Supabase Docs**: https://supabase.com/docs
- **Next.js 15 Docs**: https://nextjs.org/docs
- **Factur-X Standard**: https://fnfe-mpe.org/factur-x/
- **French Tax Bulletins**: https://bofip.impots.gouv.fr

---

**Ready for Beta Launch**: 2 cabinets at €490/month
**Target**: €10k MRR at 10 cabinets (€990/month)
**Launch Timeline**: 4-6 weeks for Phase 1 + Phase 2
