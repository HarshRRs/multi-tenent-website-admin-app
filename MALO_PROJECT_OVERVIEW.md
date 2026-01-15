# MALO - Project Complete Overview

## 🔥 Project Mission
Build Europe's first "Red Flag" dating platform - where transparency about personality warnings meets nightlife-driven hookup culture. Target launch: Q2 2026 in Berlin, London, and Paris.

## 📂 Project Structure

```
rockster/
├── malo-backend/                    # NestJS Backend API
│   ├── src/
│   │   ├── modules/                # Feature modules
│   │   ├── prisma/                 # Database client
│   │   ├── redis/                  # Cache layer
│   │   ├── mongo/                  # Chat storage
│   │   └── main.ts                 # Application entry
│   ├── prisma/
│   │   └── schema.prisma           # Complete database schema
│   ├── docker-compose.yml          # Local development stack
│   ├── Dockerfile                  # Production container
│   ├── package.json                # Dependencies
│   ├── README.md                   # Full documentation
│   ├── QUICKSTART.md               # 5-minute setup guide
│   └── IMPLEMENTATION_SUMMARY.md   # Architecture details
│
├── malo-mobile/                     # Flutter Frontend (TO BE CREATED)
│   ├── lib/
│   │   ├── features/
│   │   │   ├── onboarding/         # Vibe Check, Red Flag selection
│   │   │   ├── discovery/          # Swipe cards, matching
│   │   │   ├── heat_map/           # Live geolocation map
│   │   │   ├── chat/               # Confessional messaging
│   │   │   └── profile/            # Throne (user profile)
│   │   ├── core/
│   │   │   ├── api/                # HTTP client
│   │   │   ├── websocket/          # Real-time chat
│   │   │   └── state/              # BLoC state management
│   │   └── main.dart
│   └── pubspec.yaml
│
├── infrastructure/                  # DevOps & Cloud (TO BE CREATED)
│   ├── terraform/                  # AWS infrastructure as code
│   │   ├── vpc.tf                  # Network configuration
│   │   ├── rds.tf                  # PostgreSQL database
│   │   ├── elasticache.tf          # Redis cluster
│   │   ├── ecs.tf                  # Container orchestration
│   │   └── cloudfront.tf           # CDN distribution
│   ├── k8s/                        # Kubernetes manifests
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── hpa.yaml                # Auto-scaling
│   └── github-actions/             # CI/CD pipeline
│
├── load-tests/                     # Performance validation (TO BE CREATED)
│   ├── k6/
│   │   ├── discovery-feed.js       # 100k concurrent users
│   │   ├── match-creation.js       # Match throughput test
│   │   └── websocket-chat.js       # Real-time messaging
│   └── results/
│
└── .qoder/
    └── quests/
        └── red-flag-matching-system.md  # Complete design document
```

## ✅ Completed Work

### 1. Backend Foundation (COMPLETE)
- ✅ NestJS project structure with TypeScript
- ✅ Complete PostgreSQL schema (11 tables, all relationships)
- ✅ Prisma ORM configuration
- ✅ Environment configuration template
- ✅ Docker Compose for local development
- ✅ Production Dockerfile
- ✅ Comprehensive documentation (README, QUICKSTART, IMPLEMENTATION_SUMMARY)

### 2. Database Schema (COMPLETE)
- ✅ **users** - Profile, geolocation, reputation score
- ✅ **red_flags** - Personality attributes (identity + desires)
- ✅ **matches** - Bidirectional match records
- ✅ **subscriptions** - VIP tier management
- ✅ **consents** - GDPR compliance tracking
- ✅ **reports** - User moderation system
- ✅ **referrals** - Viral growth tracking
- ✅ **emergency_logs** - Safe Word activations
- ✅ **check_ins** - Heat Map venue tracking
- ✅ **blocked_devices** - Age verification enforcement
- ✅ **audit_logs** - Compliance audit trail

### 3. Design Documentation (COMPLETE)
- ✅ Full system architecture (1529 lines)
- ✅ Database schemas with relationships
- ✅ API endpoint specifications
- ✅ Performance targets and optimization strategies
- ✅ Security & GDPR compliance architecture
- ✅ Production launch checklist
- ✅ Monitoring & observability requirements

## 🚧 Remaining Implementation Tasks

### Phase 1: Core Backend Services (Week 1-2)

#### Infrastructure Services
- [ ] **Prisma Module** - Database connection with connection pooling
- [ ] **Redis Module** - Cache layer with geospatial support
- [ ] **MongoDB Module** - Chat storage with TTL indexes

#### Authentication System
- [ ] **JWT Strategy** - Token generation and validation
- [ ] **Phone Verification** - Twilio OTP integration
- [ ] **OAuth Providers** - Google and Apple Sign In
- [ ] **Age Verification** - EU Digital Identity Wallet + Yoti fallback
- [ ] **Auth Guards** - Route protection middleware

### Phase 2: Discovery & Matching (Week 3-4)

#### Discovery Service
- [ ] **Geo Filter** - Redis GEORADIUS proximity search
- [ ] **Red Flag Scorer** - Compatibility algorithm (33% per match)
- [ ] **VIP Boost** - Injection strategy (positions 1,3,5,7,9)
- [ ] **Anti-Duplicate** - Seen profile tracking
- [ ] **Discovery Feed API** - Generate swipe stack

#### Match Detection
- [ ] **Swipe Processing** - Like/Pass action handling
- [ ] **Mutual Interest Check** - Redis set intersection
- [ ] **Match Creation** - Database record + WebSocket event
- [ ] **Unmatch Logic** - Relationship dissolution

### Phase 3: Real-Time Communication (Week 5-6)

#### WebSocket Chat
- [ ] **Socket.io Gateway** - Connection management with JWT auth
- [ ] **Message Routing** - Redis pub/sub for horizontal scaling
- [ ] **Burner Mode** - MongoDB TTL index auto-deletion
- [ ] **Screenshot Detection** - Client event + notification
- [ ] **Typing Indicators** - Real-time presence
- [ ] **Read Receipts** - Message delivery confirmation

#### Safe Word Emergency
- [ ] **SOS Trigger Endpoint** - Emergency activation
- [ ] **Twilio SMS** - Emergency contact notifications
- [ ] **Location Capture** - GPS coordinates + Google Maps link
- [ ] **Audit Logging** - Emergency event tracking

### Phase 4: Heat Map & Geolocation (Week 7)

- [ ] **Check-in System** - Venue presence tracking
- [ ] **Grid Aggregation** - Geohash density calculation (250m cells)
- [ ] **Background Job** - 60-second update cycle
- [ ] **VIP Username Reveal** - Premium feature unlock
- [ ] **Heat Map API** - Density heatmap endpoint

### Phase 5: VIP Subscriptions (Week 8)

- [ ] **Stripe Integration** - Web payment processing
- [ ] **RevenueCat SDK** - Mobile subscription management
- [ ] **Webhook Handlers** - Payment event processing
- [ ] **Entitlement Check** - Feature access validation
- [ ] **Auto-Renewal** - Daily cron job sync
- [ ] **Refund System** - EU cooling-off period compliance

### Phase 6: Content Moderation (Week 9)

- [ ] **Amazon Rekognition** - Photo AI screening
- [ ] **Moderation Queue** - Human review dashboard
- [ ] **Reputation System** - Score calculation (-50 to +100)
- [ ] **Shadow Ban (Hell Queue)** - reputation < 50 isolation
- [ ] **Report System** - User flagging workflow
- [ ] **Appeal Process** - Moderation contest handling

### Phase 7: GDPR & Compliance (Week 10)

- [ ] **Consent Management** - Sinner's Contract UI
- [ ] **SDK Gating** - Conditional initialization
- [ ] **Data Deletion (Nuke Button)** - <5 second cascade delete
- [ ] **Audit Trail** - 3-year log retention
- [ ] **DPA Validation** - Third-party processor agreements
- [ ] **Privacy Policy API** - Version-tracked legal docs

### Phase 8: Viral Growth Features (Week 11)

- [ ] **Branch.io Integration** - Deep linking
- [ ] **Referral System** - Reward tier logic
- [ ] **Qualification Check** - 7-day activity + 3 photos
- [ ] **VIP Day Grants** - Automatic reward distribution
- [ ] **Social Sharing** - Profile tease links

### Phase 9: Flutter Frontend (Week 12-16)

#### Onboarding
- [ ] **Splash Screen** - Animated logo (red smoke effect)
- [ ] **Vibe Check** - Social auth + phone verification
- [ ] **Red Flag Selection** - 3 identity + 3 desire flags
- [ ] **Age Verification** - EU wallet + fallback UI
- [ ] **Desire Prompt** - AI-powered input field

#### Discovery
- [ ] **Swipe Cards** - Full-screen vertical media
- [ ] **Flame Animation** - Like action particle effect
- [ ] **Red Flag Badges** - Profile warning indicators
- [ ] **VIP Gold Badge** - Premium user marker
- [ ] **Rewind Button** - VIP undo feature

#### Heat Map
- [ ] **Google Maps Integration** - Dark theme satellite view
- [ ] **Pulse Zones** - Animated density visualization
- [ ] **Check-in UI** - Venue selection flow
- [ ] **VIP Username List** - Premium location reveal

#### Chat (Confessional)
- [ ] **Match Grid** - Partners in Crime view
- [ ] **Burner Mode Indicator** - 24h countdown timer
- [ ] **Safe Word Button** - Hidden SOS trigger (3x tap)
- [ ] **Screenshot Alert** - Warning banner
- [ ] **Priority Inbox** - VIP message pinning

#### Profile (Throne)
- [ ] **Reputation Score Display** - Community standing
- [ ] **The Vault** - Private photo folders
- [ ] **Settings UI** - Account management
- [ ] **VIP Upgrade** - Subscription upsell

### Phase 10: Infrastructure & DevOps (Week 17-18)

#### AWS Setup
- [ ] **Terraform IaC** - Complete infrastructure definition
- [ ] **VPC Configuration** - eu-central-1 (Frankfurt)
- [ ] **RDS PostgreSQL** - Multi-AZ with read replicas
- [ ] **ElastiCache Redis** - Cluster mode with failover
- [ ] **MongoDB Atlas** - EU region deployment
- [ ] **ECS/EKS** - Container orchestration
- [ ] **S3 + CloudFront** - Photo storage and CDN
- [ ] **Application Load Balancer** - Traffic distribution
- [ ] **Auto Scaling Groups** - CPU/memory triggers

#### CI/CD Pipeline
- [ ] **GitHub Actions Workflow** - Automated testing
- [ ] **Docker Build** - Multi-stage optimized images
- [ ] **Blue/Green Deployment** - Zero-downtime releases
- [ ] **Automated Rollback** - Error rate triggers
- [ ] **Staging Environment** - 25% production scale

### Phase 11: Testing & Quality Assurance (Week 19-20)

#### Load Testing
- [ ] **k6 Discovery Test** - 100k concurrent users
- [ ] **Match Creation Storm** - 50k swipes/minute
- [ ] **WebSocket Flood** - 200k concurrent connections
- [ ] **Heat Map Rush** - Weekend peak simulation
- [ ] **Soak Test** - 72 hours sustained load

#### E2E Testing
- [ ] **Onboarding Flow** - Complete signup journey
- [ ] **Swipe to Match** - End-to-end matching
- [ ] **Chat Message** - Real-time delivery
- [ ] **VIP Subscription** - Payment processing
- [ ] **Safe Word Trigger** - Emergency protocol

### Phase 12: Pre-Launch (Week 21-22)

#### App Store Submission
- [ ] **Content Rating Questionnaire** - 17+/Adults Only
- [ ] **Moderation Evidence** - 24/7 team documentation
- [ ] **Privacy Policy** - EU legal review
- [ ] **Terms of Service** - Code of Conduct section
- [ ] **App Store Optimization** - Screenshots, description

#### Localization
- [ ] **English Translation** - Base language
- [ ] **French Translation** - Paris market
- [ ] **German Translation** - Berlin market
- [ ] **Spanish Translation** - Barcelona expansion
- [ ] **Italian Translation** - Future markets
- [ ] **Currency Setup** - EUR, GBP, CHF pricing
- [ ] **VAT Calculation** - Tax compliance

#### Monitoring
- [ ] **Prometheus Metrics** - Custom application metrics
- [ ] **Grafana Dashboards** - Real-time visualization
- [ ] **ElasticSearch Logging** - Centralized log aggregation
- [ ] **PagerDuty Alerts** - On-call rotation
- [ ] **Sentry Error Tracking** - Exception monitoring

### Phase 13: Launch Week (Week 23)

- [ ] **Production Deployment** - AWS eu-central-1
- [ ] **Database Migration** - Schema deployment
- [ ] **CDN Warmup** - Cache preloading
- [ ] **Marketing Campaign** - Berlin/London/Paris
- [ ] **24/7 On-Call** - War room monitoring
- [ ] **Beta User Onboarding** - Invite-only launch
- [ ] **Performance Validation** - Real traffic testing
- [ ] **App Store Go-Live** - Public availability

## 📊 Success Metrics (Post-Launch)

### Technical KPIs
- API response time p95: < 200ms
- WebSocket connection success: > 99%
- Match rate: > 30% of right swipes
- Message delivery rate: > 99.5%
- App crash rate: < 0.5% of sessions

### Business KPIs
- Day 1 retention: > 40%
- Day 7 retention: > 25%
- Day 30 retention: > 15%
- Free to VIP conversion: > 5% within 30 days
- Daily active users: 10% MoM growth

### Safety KPIs
- Content moderation response: < 2 hours (100%)
- User reports per 1000 DAU: < 10
- False positive moderation: < 5%
- GDPR deletion requests: 100% within SLA

## 💰 Estimated Budget

### Development Team (6 months)
- 2 Backend Engineers: €180k
- 1 Flutter Developer: €90k
- 1 DevOps Engineer: €90k
- 1 QA Engineer: €60k
- 1 Product Manager: €75k
**Total: €495k**

### Infrastructure (Annual)
- AWS Hosting: €60k
- Third-party APIs: €36k (Twilio, AWS services)
- Monitoring Tools: €12k
- CDN & Storage: €24k
**Total: €132k**

### Legal & Compliance
- GDPR Legal Review: €15k
- Terms of Service: €10k
- App Store Compliance: €5k
**Total: €30k**

**Grand Total Year 1: €657k**

## 🎯 Next Immediate Steps

### For the Development Team

1. **Install Backend Dependencies**
```bash
cd malo-backend
npm install
```

2. **Start Local Development Stack**
```bash
docker-compose up -d
```

3. **Begin Core Service Implementation**
   - Start with Prisma module
   - Then Redis and MongoDB modules
   - Then authentication service
   - Follow task list sequentially

4. **Create Flutter Project**
```bash
flutter create malo_mobile
cd malo_mobile
```

5. **Setup Project Management**
   - Create GitHub repository
   - Setup project board (Kanban)
   - Configure branch protection
   - Enable CI/CD workflows

### For Product Management

1. **Finalize Wireframes** - High-fidelity mockups for all screens
2. **User Research** - Validate Red Flag concept in target cities
3. **Marketing Strategy** - Pre-launch campaign planning
4. **Legal Preparation** - Engage EU privacy counsel
5. **Beta Tester Recruitment** - 500-1000 initial users

## 📞 Contact & Support

- **Technical Lead**: backend-team@malo.app
- **Product Manager**: product@malo.app
- **Emergency Hotline**: +33 X XX XX XX XX (24/7 during launch)

## 🔐 Security Notice

This is a CONFIDENTIAL project. All code, designs, and documentation are proprietary. Do not share without authorization.

---

**Built with 🔥 for the Bad Boy/Bad Girl aesthetic**

**Target Launch**: Q2 2026
**Launch Cities**: Berlin, London, Paris
**Vision**: Europe's #1 nightlife dating platform
