# Red Flag Matching System Design

## Strategic Intent

Design a high-performance matchmaking algorithm and supporting infrastructure for MALO, a European nightlife-focused dating platform, that prioritizes real-time geolocation-based matching, "Red Flag" personality transparency, and instant connection capabilities while maintaining GDPR compliance and sub-100ms response times under high concurrent load.

## Core Matching System Architecture

### Matching Engine Components

The matching system consists of four integrated subsystems working in sequence to deliver relevant profiles:

| Component | Strategic Purpose | Performance Target |
|-----------|------------------|-------------------|
| Geographic Filter | Reduce search space to proximate users within adjustable radius | < 20ms query time |
| Red Flag Compatibility Matcher | Apply personality preference logic based on user-selected attributes | < 30ms computation |
| VIP Prioritization Layer | Inject premium users into discovery queue top positions | < 5ms injection overhead |
| Mutual Interest Detector | Identify and trigger match events when reciprocal interest exists | < 10ms validation |

### Geographic Discovery Strategy

The system employs spatial indexing to enable instant local discovery:

**Proximity Search Mechanism**
- User location stored as latitude/longitude coordinates in high-speed geospatial index
- Discovery radius configurable per user preference (default: 5km for nightlife mode, 25km for day mode)
- Query returns user identifiers ranked by physical distance ascending

**Heat Map Live Discovery**
- Aggregates active user density into geographic grid cells (250m x 250m resolution)
- Updates cell occupancy counters every 60 seconds
- Free tier: Shows anonymized density heatmap with color intensity zones
- VIP tier: Reveals specific usernames and profile previews within hot zones

**Check-in System**
- Users manually mark presence at venues (bars, clubs, events)
- Creates temporary high-priority discovery pool for that venue
- Expires check-in after 6 hours of inactivity or manual checkout

### Red Flag Compatibility Logic

Users define their identity through selecting warning attributes and also express preferences for desired attributes in potential matches.

**Red Flag Data Model**

| Attribute | Relationship | Business Logic |
|-----------|-------------|----------------|
| User Identity Flags | User selects 3 primary flags describing themselves | Displayed prominently on profile |
| Desired Flags | User selects flags they find attractive in others | Drives matching algorithm scoring |
| Verified Count | Number of matches who confirmed this flag applies to user | Increases trust score visibility |

**Compatibility Scoring Algorithm**

The system calculates a compatibility percentage between two users:

- Base score starts at 0%
- For each of User A's "desired flags" that appears in User B's "identity flags": add 33%
- For each of User B's "desired flags" that appears in User A's "identity flags": add 33%
- Maximum theoretical compatibility: 99% (requires 3/3 mutual flag alignment)
- Minimum threshold for profile inclusion in discovery feed: 33% (at least one mutual interest)

**Anti-Repetition Logic**
- Track every profile user has viewed in session-scoped seen list
- Exclude previously seen profiles from current session discovery queue
- Reset seen list after 24 hours or manual "reset queue" action
- Exception: Allow re-appearance of profiles after 7 days if not swiped

### VIP Boost Mechanism

Premium subscribers receive algorithmic advantages:

**Discovery Queue Injection Strategy**
- Standard algorithm generates baseline ranked queue of 50 profiles
- VIP profiles injected into positions 1, 3, 5, 7, 9 (alternating pattern)
- Non-VIP profiles fill remaining positions
- VIP users viewing queue: 40% VIP density in their feed
- Free users viewing queue: 20% VIP density in their feed

**Permanent Local Boost**
- VIP profiles receive 5x weight multiplier in geographic ranking
- Appears in discovery feed for users within 3x normal radius
- Profile marked with burnished gold badge indicator

### Match Detection & Event System

**Mutual Interest Detection Flow**

When User A swipes right (indicates interest) on User B:

1. System checks if User B has previously swiped right on User A
2. If yes: Match event triggered
3. If no: Store User A's interest in pending interest cache

**Match Event Trigger Actions**
- Create bidirectional match record with unique match identifier
- Send real-time WebSocket notification to both users simultaneously
- Animate "IT'S A MATCH" overlay with flame particle effects
- Unlock "Confessional" chat channel between matched users
- Record match timestamp for analytics and reputation scoring

**Unmatch Capability**
- Either user can dissolve match at any time
- Removes match record and chat history immediately
- Adds counterpart to hidden exclusion list (never appear in future discovery)

## Data Architecture

### PostgreSQL Schema Design

**Core User Profile Table**

Stores persistent identity and authentication data.

| Field | Type | Constraints | Purpose |
|-------|------|-------------|---------|
| id | UUID | Primary Key | Unique user identifier |
| phone_number | VARCHAR(20) | Unique, Indexed | Verified contact method |
| email | VARCHAR(255) | Unique, Indexed | Alternative authentication |
| full_name | VARCHAR(100) | Not Null | Display name |
| birth_date | DATE | Not Null, CHECK >= 18 years | Age verification |
| gender | ENUM | Values: male, female, non-binary | Identity disclosure |
| bio | TEXT | Max 500 chars | Optional description |
| reputation_score | INTEGER | Default 100, Range 0-100 | Community standing metric |
| is_vip | BOOLEAN | Default false | Subscription status flag |
| is_verified_over_18 | BOOLEAN | Default false | Age gate compliance |
| verification_token_id | VARCHAR(255) | Nullable | External ID verification reference |
| emergency_contacts | JSONB | Array of contact objects | Safe Word feature data |
| created_at | TIMESTAMP | Default NOW() | Account creation tracking |
| last_active_at | TIMESTAMP | Updated on activity | Inactivity management |

**Red Flags Association Table**

Represents many-to-many relationship between users and personality warning attributes.

| Field | Type | Constraints | Purpose |
|-------|------|-------------|---------|
| id | SERIAL | Primary Key | Unique flag assignment |
| user_id | UUID | Foreign Key → users.id | Flag owner |
| flag_type | ENUM | 15 predefined types | Specific warning attribute |
| is_identity_flag | BOOLEAN | Not Null | True = describes user, False = user desires this |
| verified_count | INTEGER | Default 0 | Peer confirmation counter |
| created_at | TIMESTAMP | Default NOW() | Assignment tracking |

**Flag Type Enumeration**

Available personality warning categories: ghoster, night_owl, heartbreaker, toxic, reckless, jealous_type, commitment_phobic, emotionally_unavailable, adrenaline_junkie, party_animal, brutally_honest, mysterious, dominant, submissive, hopeless_romantic

**Matches Table**

Records all successful mutual interest pairings.

| Field | Type | Constraints | Purpose |
|-------|------|-------------|---------|
| id | UUID | Primary Key | Unique match identifier |
| user_a_id | UUID | Foreign Key → users.id | First matched user |
| user_b_id | UUID | Foreign Key → users.id | Second matched user |
| matched_at | TIMESTAMP | Default NOW() | Connection timestamp |
| unmatched_at | TIMESTAMP | Nullable | Dissolution timestamp if applicable |
| meetup_confirmed | BOOLEAN | Default false | Influences reputation score |

**Subscriptions Table**

Tracks VIP payment and entitlement lifecycle.

| Field | Type | Constraints | Purpose |
|-------|------|-------------|---------|
| id | UUID | Primary Key | Transaction identifier |
| user_id | UUID | Foreign Key → users.id | Subscriber |
| tier | ENUM | Values: standard, golden_devil | Subscription level |
| status | ENUM | Values: active, expired, cancelled | Current state |
| started_at | TIMESTAMP | Default NOW() | Subscription activation |
| expiry_date | TIMESTAMP | Not Null | Access termination date |
| payment_provider_id | VARCHAR(255) | Nullable | Stripe/RevenueCat reference |

**Blocked Devices Table**

Prevents age verification abuse through device fingerprinting.

| Field | Type | Constraints | Purpose |
|-------|------|-------------|---------|
| device_id_hash | VARCHAR(64) | Primary Key | SHA-256 of device identifier |
| blocked_reason | ENUM | Values: age_verification_failure, abuse | Block justification |
| blocked_at | TIMESTAMP | Default NOW() | Enforcement timestamp |

### Redis Cache Strategy

High-speed in-memory data structures for real-time operations.

**Geospatial User Location Index**

Structure Type: Sorted Set with geospatial capabilities

Purpose: Enable sub-20ms proximity queries for discovery feed generation

Data Pattern:
- Key naming: `user_locations`
- Members: User UUID
- Scores: Encoded latitude/longitude coordinates

Operations:
- Add/Update location: When user opens app or moves significantly
- Query nearby: Retrieve all users within N kilometer radius of coordinates
- Remove: On logout or after 30 minutes inactivity

**Online Status Tracking**

Structure Type: String with expiration

Purpose: Display "Active Now" badges and prioritize recently active users

Data Pattern:
- Key naming: `user:status:{user_id}`
- Value: Enum (online, away, offline)
- TTL: 300 seconds (5 minutes)

Logic: Application must refresh this key every 2 minutes while user active. Automatic expiration indicates offline state.

**Swipe Session Memory**

Structure Type: Set

Purpose: Prevent duplicate profile appearances in single discovery session

Data Pattern:
- Key naming: `user:seen:{user_id}`
- Members: UUID of every viewed profile
- TTL: 86400 seconds (24 hours)

Operations:
- Add to set: After profile displayed to user
- Check membership: Before adding profile to discovery queue
- Flush: On user-initiated "reset queue" action

**Pending Interest Cache**

Structure Type: Set

Purpose: Instant mutual interest detection without database query

Data Pattern:
- Key naming: `user:likes:{user_id}`
- Members: UUID of every user who swiped right on this user
- Persistence: No TTL (permanent until match or unlike)

Logic: When User A swipes right on User B, check if User A's UUID exists in `user:likes:{User B's UUID}`. If yes, match detected.

**Heat Map Grid Aggregation**

Structure Type: Geo-hash counters

Purpose: Real-time density visualization for discovery map

Data Pattern:
- Key naming: `heatmap:grid:{geohash_precision_5}`
- Value: Integer counter of active users in cell
- TTL: 120 seconds (2 minutes)

Update Frequency: Rebuild all grid counters every 60 seconds via background job

### MongoDB Document Store

Optimized for horizontal scaling of high-volume chat data.

**Messages Collection Schema**

```
{
  chat_id: UUID (indexed),
  sender_id: UUID (indexed),
  receiver_id: UUID (indexed),
  content: String (encrypted AES-256),
  message_type: Enum (text, image, voice_note),
  is_burner_mode: Boolean,
  expires_at: ISODate (TTL index),
  screenshot_taken: Boolean (default false),
  created_at: ISODate (indexed),
  delivered_at: ISODate (nullable),
  read_at: ISODate (nullable)
}
```

**Burner Mode Implementation**

Purpose: Auto-delete messages after 24 hours to maintain privacy mystique

Mechanism: MongoDB TTL index on `expires_at` field
- On message creation: Set `expires_at = created_at + 24 hours`
- MongoDB background process automatically deletes expired documents
- No application logic required for deletion

**Screenshot Detection**

Purpose: Notify user when chat partner attempts to capture conversation

Implementation Strategy:
- Mobile OS provides screenshot event detection
- Application sends WebSocket event to backend on screenshot
- Backend updates `screenshot_taken` flag and sends push notification to counterpart
- UI displays warning banner: "Your partner screenshotted this conversation"

## Performance Optimization Strategy

### Response Time Targets

| Operation | Maximum Latency | Strategy |
|-----------|----------------|----------|
| Discovery feed generation | 100ms | Redis geospatial query + PostgreSQL batch fetch |
| Swipe action processing | 50ms | Redis cache update + async database write |
| Match detection | 75ms | Redis set intersection check |
| Heat map data retrieval | 150ms | Pre-computed grid cache |
| Chat message delivery | 200ms | WebSocket direct transmission |

### Caching Hierarchy

**Layer 1: Application-Level Cache**
- Profile data cached in memory for 60 seconds after fetch
- Reduces repeated database queries for same user in discovery feed

**Layer 2: Redis Distributed Cache**
- User profile summaries cached for 5 minutes
- Invalidated on profile update actions

**Layer 3: PostgreSQL Query Optimization**
- Composite indexes on (reputation_score, last_active_at, is_vip)
- Read replicas for discovery feed queries
- Write master for match creation and profile updates

### Horizontal Scaling Strategy

**Backend Services Architecture**

Decompose into independently scalable microservices:

| Service | Responsibility | Scaling Trigger |
|---------|---------------|-----------------|
| Discovery Service | Generate swipe feeds, process swipes | CPU > 70% sustained |
| Matching Service | Detect mutual interest, create matches | Queue depth > 1000 |
| Chat Service | WebSocket management, message routing | Active connection count > 10,000 |
| Geo Service | Location updates, heat map computation | Redis operations/sec > 50,000 |

**Auto-Scaling Rules**

Peak Load Scenario: Saturday night 22:00-02:00 in major European cities
- Expected concurrent users: 500,000
- Discovery service: Scale from 10 to 40 container instances
- Chat service: Scale from 5 to 25 WebSocket server instances
- Geo service: Scale from 3 to 15 instances

Metric-Based Triggers:
- CPU utilization sustained above 70% for 3 minutes: Add 50% more instances
- Request queue latency exceeds 500ms: Add 100% more instances
- CPU utilization below 30% for 10 minutes: Remove 25% of instances

### CDN & Media Strategy

**Profile Photo Delivery**

Storage: AWS S3 with versioning enabled
Distribution: CloudFront CDN with edge locations across EU

Processing Pipeline:
1. User uploads original photo
2. Backend validates content via AI moderation API
3. Generate 4 size variants: thumbnail (200x200), card (600x800), full (1200x1600), original
4. Upload all variants to S3 with public-read ACL
5. Return CloudFront URLs to application

Cache Headers:
- Immutable photos: Cache-Control: public, max-age=31536000
- Profile updates: Append version query parameter to bust cache

**Expected Performance**
- European users: 50ms average load time
- 99th percentile: < 150ms load time

## Safety & Compliance Architecture

### Age Verification Multi-Layer System

**Primary Verification: EU Digital Identity Wallet**

Integration Flow:
1. User initiates signup
2. Application triggers OAuth2 authorization request to EU Digital Identity provider
3. User authenticates with national eID or approved wallet
4. Provider returns JWT containing age_over_18 claim (boolean) and verification_token_id
5. Application validates JWT signature and stores only boolean flag and token reference
6. Age verification status displayed as verified badge on profile

**Secondary Verification: AI Face Estimation**

Fallback Provider: Yoti or Onfido API

Process:
1. User uploads government-issued ID photo
2. Third-party service performs OCR and face biometric analysis
3. Returns estimated age range and confidence score
4. Application approves if confidence > 95% and estimated age >= 18
5. Manual review queue for confidence 80-95%

**Enforcement Logic**

Failed Verification Handling:
- First failure: Allow retry after 24 hours
- Second failure: Generate SHA-256 hash of device identifier (Android: ANDROID_ID, iOS: identifierForVendor)
- Store hash in blocked_devices table with reason code
- All future registration attempts from device rejected with error: "Account creation unavailable"

### GDPR Consent Management

**The Sinner's Contract Interface**

Presented on first app launch as full-screen modal overlay with dark background and crimson accent buttons.

Required Consent Categories:

| Category | Purpose | Consequence of Denial |
|----------|---------|---------------------|
| Essential Services | Account creation, matching, messaging | Cannot use app if denied |
| Geolocation Tracking | Discovery feed, heat map, check-ins | App functional but discovery limited to 25km radius |
| Analytics & Performance | Firebase Analytics, crash reporting | No functional impact |
| Marketing Communications | Push notifications for promotions, VIP offers | No functional impact |

**Consent Storage Model**

Each consent decision stored as granular record:

```
{
  user_id: UUID,
  consent_category: Enum,
  consent_granted: Boolean,
  consent_timestamp: ISO8601,
  ip_address_at_consent: String,
  user_agent: String,
  revoked_at: ISO8601 (nullable)
}
```

**SDK Initialization Gating**

Technical Implementation Rule:
- All third-party SDKs (Firebase, Meta Pixel, Amplitude) must remain uninitialized until user completes consent flow
- Conditional initialization triggered only for granted categories
- Consent status checked on every app launch

**Consent Modification**

Users can revoke consent categories at any time via Settings interface. Changes take effect immediately with SDK shutdown for revoked categories.

### Safe Word Emergency Protocol

**Trigger Mechanism**

UI Component: Hidden SOS button in chat interface header (triple-tap activation or 3-second hold)

Activation Flow:
1. User triggers SOS action
2. Application captures current GPS coordinates
3. Retrieves match partner's profile name and last 3 message previews
4. Sends emergency payload to backend via prioritized WebSocket channel

**Backend Emergency Response**

Payload Structure:

```
{
  emergency_id: UUID,
  triggered_by_user_id: UUID,
  concerning_match_id: UUID,
  current_location: {lat: Number, lng: Number},
  match_partner_name: String,
  message_context: Array[String],
  triggered_at: ISO8601
}
```

Notification Dispatch:
- Retrieve user's emergency_contacts array from profile (configured in settings, max 3 contacts)
- Send SMS via Twilio API to all contacts simultaneously
- Message template: "MALO EMERGENCY: [User Name] activated Safe Word. Location: [Google Maps Link]. They were meeting [Match Name]. Message context: [Preview]. Triggered at [Time]."
- Log emergency event in audit table for legal compliance

**Privacy Consideration**

Match partner is NOT notified of SOS activation to prevent escalation or retaliation risk.

### Reputation System & Shadow Banning

**Reputation Score Mechanics**

Starting Score: 100 (all new users)

Score Modification Events:

| Event | Score Change | Trigger Condition |
|-------|-------------|------------------|
| Successful meetup confirmation | +5 | Both users confirm meetup occurred |
| Report received: Harassment | -15 | Single report validated |
| Report received: Fake profile | -10 | Single report validated |
| Report received: Underage suspicion | -50 | Triggers immediate manual review |
| Match unmatch within 5 minutes | -2 | Indicates poor profile quality |
| 30 days no reports | +1 | Gradual reputation recovery |

**Shadow Ban Implementation (Hell Queue)**

Activation Threshold: reputation_score < 50

Behavioral Change:
- User's profile removed from discovery feed for users with reputation >= 50
- User's discovery feed contains ONLY profiles with reputation < 50
- No notification or indication provided to shadow-banned user
- Matching and chat functionality remains operational

Purpose: Quarantine toxic users into isolated pool without explicit ban (reduces ban evasion attempts)

**Reinstatement Path**

Users in Hell Queue can recover by:
- Filing appeal via in-app support (manual review by moderation team)
- Waiting 30 days without new reports (automatic +1 daily reputation gain)
- Threshold to exit Hell Queue: reputation_score >= 55

### Data Deletion (The Nuke Button)

**User Interface**

Location: Settings → Account Management → Delete Account

Confirmation Flow:
1. User taps "Delete Account"
2. Display warning modal: "This action is permanent. All matches, chats, and profile data will be erased immediately."
3. Require password re-authentication
4. Final confirmation button: "Delete Forever"

**Backend Deletion Orchestration**

API Endpoint: DELETE /account/nuke

Execution Sequence (must complete in < 5 seconds):

1. Delete all user photos from AWS S3 bucket (batch delete API call)
2. Delete user record from PostgreSQL users table (cascade delete configured for red_flags, matches, subscriptions)
3. Delete all messages from MongoDB where sender_id OR receiver_id matches user
4. Remove user from Redis geolocation index and all cache keys
5. Revoke authentication tokens and sessions
6. Send confirmation email to user's registered email
7. Return HTTP 204 No Content

**GDPR Compliance**

Timeline: Immediate deletion with zero retention period
Audit Logging: Record deletion event with timestamp and user_id for legal audit trail (retained separately for 3 years per GDPR Article 17 exception)

### Content Moderation System

**AI-Powered Photo Screening**

Provider: Amazon Rekognition or Google Cloud Vision API

Validation Pipeline:
1. User uploads photo
2. Backend sends image to moderation API
3. API returns detected content labels with confidence scores

**Content Policy Enforcement Rules**

| Detected Content | Confidence Threshold | Action |
|-----------------|---------------------|--------|
| Explicit Nudity | > 80% | Reject upload, notify user |
| Suggestive Content | > 90% | Allow (aligns with app brand) |
| Violence/Gore | > 70% | Reject upload, flag for review |
| Weapons | > 85% | Allow (edgy aesthetic permitted) |
| Minors Detected | > 60% | Reject upload, trigger account review |
| Text/QR Codes | > 80% | Reject (prevents external contact info sharing) |

**Brand-Aligned Permissiveness**

Explicitly Allowed Content:
- Tattoos, piercings, alternative fashion
- Leather, BDSM aesthetic elements
- Provocative poses (if no explicit nudity)
- Nightlife/club photography with alcohol

Purpose: Maintain "Bad Boy/Bad Girl" brand identity while preventing illegal or non-consensual content.

**Human Review Queue**

Photos with confidence scores in ambiguous ranges (60-85% for sensitive categories) route to moderation dashboard for manual review within 2 hours. VIP users receive priority review (< 30 minutes).

## Real-Time Communication Infrastructure

### WebSocket Architecture

**Connection Management**

Protocol: WebSocket over TLS (WSS)
Framework: Socket.io with Redis adapter for horizontal scaling

Connection Flow:
1. User authenticates via JWT token in initial handshake
2. Backend validates token and maps connection to user_id
3. Connection added to user's active session pool
4. Heartbeat ping every 30 seconds to detect disconnections

**Message Routing Strategy**

When User A sends message to User B:
1. Message received at WebSocket server handling User A's connection
2. Encrypt message content with AES-256
3. Store in MongoDB messages collection
4. Check if User B has active WebSocket connection via Redis pub/sub
5. If connected: Route message directly to User B's WebSocket server
6. If offline: Store message as undelivered, send push notification

**Horizontal Scaling Pattern**

Challenge: User A and User B may connect to different WebSocket server instances

Solution: Redis Pub/Sub as message broker
- Each WebSocket server instance subscribes to Redis channel: `messages:{user_id}`
- When server receives message for offline user, publishes to their Redis channel
- If user connected to different server, that server receives pub/sub event and delivers message

### Push Notification Strategy

**Trigger Events**

| Event Type | Notification Content | Delivery Condition |
|-----------|---------------------|-------------------|
| New Match | "IT'S A MATCH with [Name]! 🔥" | Immediate |
| Incoming Message | Message preview (first 50 chars) | If user offline for > 2 minutes |
| VIP Boost Active | "You're being boosted for the next hour!" | On VIP feature activation |
| Heat Zone Alert | "15 singles are nearby at [Location]" | If user within 500m of hot zone |
| Safe Word Triggered | Emergency contact notification | Immediate critical priority |

**Provider Integration**

iOS: Apple Push Notification Service (APNs)
Android: Firebase Cloud Messaging (FCM)

Token Management:
- Store device push token in users table on app install
- Refresh token on every app launch
- Remove token on logout or account deletion

### Chat Feature Specification

**Message Types**

Supported Media Formats:

| Type | Technical Specification | Size Limit |
|------|------------------------|-----------|
| Text | UTF-8 encoded string | 1000 characters |
| Image | JPEG/PNG, uploaded to S3, URL stored in message | 10 MB |
| Voice Note | MP3/AAC, uploaded to S3, URL stored in message | 60 seconds / 5 MB |

**Encryption Strategy**

End-to-End Encryption: Not implemented (allows content moderation for safety)

Transport Encryption: TLS 1.3 for all WebSocket connections

Storage Encryption: AES-256 encryption of message content field in MongoDB

**Read Receipts & Typing Indicators**

Typing Indicator:
- Triggered when user types for > 2 seconds
- WebSocket event sent to match partner
- Displayed as "[Name] is typing..." for 5 seconds

Read Receipts:
- Message marked as read when user views chat window containing message
- Backend updates read_at timestamp
- Sender sees "Read" status with timestamp

User Privacy Control: Option to disable read receipts in settings (typing indicators remain active)

## VIP Subscription System

### Tier Comparison Matrix

| Feature | Free Tier | Golden Devil VIP |
|---------|-----------|-----------------|
| Daily Swipe Limit | 50 profiles | Unlimited |
| Discovery Visibility | Standard algorithm ranking | Permanent 5x boost in local area |
| Heat Map Access | View density heatmap only | See specific usernames at locations |
| Rewind Swipes | Not available | Unlimited undo on left swipes |
| Incognito Mode | Not available | Browse without appearing in others' feeds |
| Who Liked Me | Blurred grid, must match to reveal | Full list with profile previews |
| Priority Inbox | Not available | Your messages always top of match's list |
| Profile Badge | None | Burnished gold "VIP" indicator |
| Advanced Filters | Gender only | Age range, distance, specific red flags |

### Payment Integration

**Provider Strategy**

Mobile Payments: RevenueCat SDK (abstracts Apple/Google billing)
Web Payments: Stripe Checkout

**Subscription Plans**

| Duration | Price | Discount | Target Use Case |
|----------|-------|----------|----------------|
| 1 Month | €19.99 | - | Trial users |
| 3 Months | €44.99 | 25% | Regular users |
| 12 Months | €119.99 | 50% | Power users |

**Entitlement Management**

Flow:
1. User selects VIP tier and duration in app
2. RevenueCat SDK triggers platform-native payment flow
3. On successful payment, webhook sent to backend
4. Backend creates record in subscriptions table with expiry_date
5. Backend sets is_vip = true in users table
6. WebSocket event sent to user's active session to unlock VIP UI features

**Auto-Renewal Handling**

Platform handles auto-renewal (Apple/Google subscription management)

Backend Sync:
- Daily cron job queries RevenueCat API for subscription status of all VIP users
- Updates expiry_date for renewed subscriptions
- Sets is_vip = false and subscription status = expired for lapsed subscriptions

**Cancellation & Refund Policy**

User-Initiated Cancellation: Managed through platform (App Store/Google Play settings)
- Subscription remains active until current period ends
- No partial refunds

Grace Period: If payment fails on renewal, 3-day grace period before VIP access revoked

## Geographic Deployment Architecture

### Infrastructure Region Strategy

**Primary Hosting Region**

Provider: AWS EU (Frankfurt) or Scaleway Paris
Rationale: GDPR compliance requires data residency within EU jurisdiction to prevent extraterritorial access under US Cloud Act

**Service Distribution**

| Service | Hosting Strategy | Rationale |
|---------|-----------------|-----------|
| PostgreSQL Database | AWS RDS Multi-AZ in eu-central-1 | High availability with sub-10ms replication lag |
| Redis Cache Cluster | AWS ElastiCache in eu-central-1 | Co-located with database for minimum latency |
| MongoDB Cluster | MongoDB Atlas EU region | Managed horizontal scaling for chat data |
| Backend Services | AWS ECS/EKS in eu-central-1 | Container orchestration with auto-scaling |
| Media Storage (S3) | AWS S3 in eu-central-1 | GDPR-compliant object storage |
| CDN | CloudFront with EU edge locations | Sub-50ms photo delivery across Europe |

### Launch Market Prioritization

**Phase 1: Tier 1 Cities (Months 1-3)**

Target Markets:
- Berlin, Germany
- London, United Kingdom
- Paris, France

Rationale: High nightlife density, young demographics, English/German language support

**Phase 2: Tier 2 Cities (Months 4-6)**

Target Markets:
- Amsterdam, Netherlands
- Barcelona, Spain
- Prague, Czech Republic
- Stockholm, Sweden

**Phase 3: Broad European Expansion (Months 7-12)**

Target Markets: 20+ additional European cities

### Localization Requirements

**Language Support**

Launch Languages: English, German, French

Translation Scope:
- All UI strings
- Error messages
- Push notification templates
- Legal documents (Terms of Service, Privacy Policy)

Implementation: i18n framework with JSON language files, user language preference stored in profile

**Cultural Adaptation**

Regional Red Flag Variations: Allow certain flag types to have different labels per market (e.g., "Brutally Honest" may translate differently in German vs. French cultural contexts)

## System Monitoring & Observability

### Key Performance Indicators (KPIs)

**Technical Metrics**

| Metric | Target | Alert Threshold |
|--------|--------|----------------|
| API Response Time (p99) | < 200ms | > 500ms sustained 5 min |
| WebSocket Connection Success Rate | > 99% | < 97% |
| Database Query Time (p95) | < 50ms | > 100ms sustained 5 min |
| Redis Cache Hit Rate | > 85% | < 70% |
| CDN Cache Hit Rate | > 95% | < 90% |
| Message Delivery Rate | > 99.5% | < 98% |

**Business Metrics**

| Metric | Target | Monitoring Frequency |
|--------|--------|---------------------|
| Daily Active Users (DAU) | Growth 10% MoM | Daily dashboard |
| Match Rate | > 30% of swipes | Daily dashboard |
| Message Response Rate | > 60% within 1 hour | Weekly analysis |
| VIP Conversion Rate | > 5% of free users | Weekly analysis |
| Reputation Score Distribution | < 5% in Hell Queue | Daily dashboard |

### Incident Response Protocol

**Severity Levels**

| Severity | Definition | Response Time SLA |
|----------|-----------|------------------|
| P0 - Critical | Complete service outage, data breach | Immediate (24/7 on-call) |
| P1 - High | Core feature failure (matching, chat) | < 30 minutes |
| P2 - Medium | Degraded performance, non-core feature failure | < 2 hours |
| P3 - Low | Minor bugs, cosmetic issues | Next business day |

**On-Call Rotation**

Team Structure:
- Backend Engineer (primary)
- DevOps Engineer (secondary)
- Product Manager (escalation point)

Escalation Path: Automated alerts → Primary on-call → Secondary on-call (if no response in 15 min) → Product Manager (if no resolution in 1 hour)

### Logging & Audit Trail

**Structured Logging Requirements**

All backend services must emit JSON-formatted logs with standard fields:

```
{
  timestamp: ISO8601,
  service_name: String,
  log_level: Enum (DEBUG, INFO, WARN, ERROR),
  user_id: UUID (if applicable),
  request_id: UUID,
  event_type: String,
  event_data: Object,
  duration_ms: Number (for request logs)
}
```

**Audit Events Requiring Logging**

- User account creation and deletion
- VIP subscription activation and cancellation
- Match creation and dissolution
- Report submission and moderation actions
- Safe Word emergency triggers
- GDPR consent changes
- Age verification attempts (success and failure)
- Admin actions on user accounts

**Log Retention Policy**

Hot Storage (ElasticSearch): 30 days for real-time search and debugging
Cold Storage (S3): 3 years for GDPR compliance and legal audit requirements
Deletion: Automated after 3 years except for legally mandated incident records

## Risk Mitigation Strategy

### Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Database performance degradation under high load | Medium | High | Implement read replicas, connection pooling, query optimization |
| Redis cache failure causing discovery outage | Low | High | Multi-AZ Redis cluster with automatic failover |
| WebSocket server overload during peak hours | Medium | Medium | Auto-scaling based on connection count, load balancer distribution |
| CDN cache poisoning | Low | Medium | Signed URLs for sensitive content, cache invalidation API |
| Third-party API failure (age verification) | Medium | High | Fallback verification method, graceful degradation |

### Security Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|

## Production Launch Readiness

### Performance Validation & Stress Testing

**Load Testing Strategy**

Purpose: Validate system behavior under sustained high traffic and identify breaking points before production launch.

**Testing Framework**

Tooling: k6 or Apache JMeter for load generation

Test Environment:
- Dedicated staging environment mirroring production infrastructure
- Full-scale database with synthetic data (1 million user profiles, 10 million matches)
- All third-party integrations configured with test accounts

**Load Test Scenarios**

| Scenario | Concurrent Users | Duration | Target Endpoints | Success Criteria |
|----------|-----------------|----------|------------------|------------------|
| Discovery Feed Peak | 100,000 | 30 minutes | GET /discovery/feed | p95 latency < 150ms, 0% errors |
| Match Creation Storm | 50,000 | 15 minutes | POST /discovery/swipe | Queue processing < 5s lag |
| Heat Map Weekend Rush | 75,000 | 60 minutes | GET /map/heat-zones | p99 latency < 200ms |
| WebSocket Connection Flood | 200,000 | 45 minutes | WSS connection handshake | 99.5% connection success |
| Chat Message Burst | 40,000 | 20 minutes | POST /chat/send | Message delivery < 500ms |

**Soak Testing**

Purpose: Detect memory leaks and performance degradation over extended periods

Configuration:
- 30,000 concurrent users sustained for 72 hours
- Monitor memory consumption, connection pool saturation, database query performance
- Success criteria: No memory growth > 10% over 24-hour period, zero resource exhaustion errors

**Database Sharding Trigger**

Threshold: 1 million users in single geographic region

Sharding Strategy:
- Partition users table by region identifier (shard key: region_id)
- Shard boundaries: Western Europe, Central Europe, Northern Europe, Southern Europe, UK/Ireland
- Cross-shard queries handled by application-level routing layer
- Read replicas per shard for discovery feed queries

Performance Target Post-Sharding: Maintain < 50ms query latency at 5 million total users

**Auto-Scaling Configuration**

Infrastructure: AWS ECS/EKS with Application Auto Scaling

Trigger Rules:

| Metric | Threshold | Scaling Action | Cooldown Period |
|--------|-----------|----------------|----------------|
| CPU Utilization | > 60% for 3 min | Add 50% instances | 5 minutes |
| Request Queue Depth | > 1000 messages | Add 100% instances | 3 minutes |
| Memory Utilization | > 75% for 5 min | Add 25% instances | 10 minutes |
| CPU Utilization | < 30% for 15 min | Remove 25% instances | 10 minutes |

Minimum Instance Count: 10 (baseline capacity)
Maximum Instance Count: 200 (cost protection limit)

### App Store Compliance Strategy

**Platform Submission Requirements**

**Apple App Store**

Age Rating: 17+ (Mature)

Rating Justification:
- Frequent/Intense Mature/Suggestive Themes
- Infrequent/Mild Sexual Content or Nudity
- User-Generated Content with moderation

App Store Description Positioning:
"MALO: Social Discovery for Alternative Lifestyles. Connect with authentic individuals who embrace transparency about personality traits. For mature audiences seeking genuine nightlife connections in European cities."

**Google Play Store**

Content Rating: Adults Only 18+

Rating Justification: Dating app with user-generated content and mature themes

Play Store Description Positioning: Same as Apple with additional emphasis on "Community-driven safety features and AI content moderation"

**Content Moderation Evidence Requirements**

To satisfy platform review teams:

**Moderation Infrastructure Documentation**

| Component | Specification | Purpose |
|-----------|--------------|----------|
| AI Screening Layer | Amazon Rekognition or Google Vision API | Instant photo validation on upload |
| Human Review Queue | 24/7 moderation team (3 shifts covering EU timezones) | Manual review of flagged content |
| Response Time SLA | 100% of illegal content removed within 2 hours | Platform compliance requirement |
| Escalation Protocol | Critical content (CSAM, violence) escalated to senior moderator within 15 minutes | Legal obligation |
| Audit Trail | All moderation decisions logged with moderator ID and timestamp | Accountability and platform evidence |

**Moderation Dashboard Features**

- Queue prioritization: CSAM reports → Violence → Harassment → Spam
- Moderator actions: Approve, Reject Photo, Warn User, Suspend Account, Permanent Ban
- Appeal system: Users can contest moderation decisions within 48 hours
- Performance metrics: Average review time, accuracy rate (measured via quality assurance sampling)

**Platform Policy Alignment**

Prohibited Content (enforced via AI + human review):
- Sexual services or prostitution solicitation
- Graphic sexual acts or pornography
- Child exploitation imagery (zero tolerance, immediate law enforcement referral)
- Hate speech or discriminatory harassment
- Sale of illegal substances

Permitted Content (aligns with "edgy" brand):
- Suggestive poses without explicit nudity
- Alternative lifestyle aesthetics (BDSM fashion, tattoos, piercings)
- Alcohol consumption in nightlife settings
- Provocative language in profiles (within harassment policy limits)

### Localization & Internationalization Architecture

**Multi-Language Support System**

Supported Languages (Launch): English, French, German, Spanish, Italian

Implementation Framework: Flutter i18n with ARB (Application Resource Bundle) files

**Language Detection & Selection**

Automatic Detection:
- On first app launch, read device locale setting
- Map locale to supported language (fallback to English if unsupported)
- Store user language preference in profile

Manual Override:
- Settings menu allows language change without app restart
- Hot reload all UI strings from new language ARB file
- Push notification templates updated to match selected language

**Translation Scope**

| Content Category | Translation Requirement | Update Mechanism |
|-----------------|------------------------|------------------|
| UI Labels & Buttons | 100% coverage for all screens | Bundled in app, updated via app release |
| Error Messages | Full coverage including API errors | Bundled in app |
| Red Flag Labels | Culturally adapted per region | Backend CMS, dynamic loading |
| Push Notifications | Template-based with variable substitution | Backend configuration |
| Legal Documents | Professional legal translation required | Bundled in app, version tracked |
| Customer Support | Live agent language matching | Zendesk routing rules |

**Regional Red Flag Adaptation**

Challenge: Personality traits have different cultural connotations across European markets

Solution: Backend-driven Red Flag configuration

**Content Management System (CMS) Integration**

Flag Definition Schema:

```
{
  flag_id: String,
  default_label: String,
  regional_labels: {
    en: String,
    fr: String,
    de: String,
    es: String,
    it: String
  },
  description: Object (multi-language),
  icon_url: String,
  is_active: Boolean,
  display_order: Integer
}
```

Update Flow:
1. Content manager updates flag definition in admin CMS
2. Backend API serves updated flag list on app launch
3. Application caches flags locally for 24 hours
4. No app store review required for flag label changes

**Multi-Currency Payment System**

Supported Currencies: EUR (Euro), GBP (British Pound), CHF (Swiss Franc)

**Payment Provider Integration**

Mobile: RevenueCat SDK with Apple/Google platform billing
Web: Stripe Checkout with multi-currency support

**Pricing Strategy Per Region**

| Region | Currency | 1-Month VIP | 3-Month VIP | 12-Month VIP |
|--------|----------|-------------|-------------|-------------|
| Eurozone | EUR | €19.99 | €44.99 | €119.99 |
| United Kingdom | GBP | £17.99 | £39.99 | £99.99 |
| Switzerland | CHF | 21.99 | 49.99 | 129.99 |

**VAT/Tax Handling**

Compliance Requirement: EU VAT Directive requires tax collection based on customer location

Implementation:
- RevenueCat automatically handles Apple/Google platform tax collection
- Stripe Tax API calculates VAT rate based on billing address country
- Display prices inclusive of tax (EU legal requirement): "€19.99 (incl. VAT)"
- Backend generates VAT-compliant invoices for all VIP subscriptions

**Currency Conversion Logic**

User travel scenario: German user (EUR) travels to London
- Display prices in user's original currency for consistency
- Payment processed in original currency to avoid confusion
- Exception: User can manually change preferred currency in settings

### Customer Support Operations

**Support Platform Integration**

Provider: Zendesk or Intercom embedded in application

Integration Points:
- In-app help center accessible from "Throne" (Profile) screen
- Live chat widget for real-time support
- Ticket submission form for non-urgent issues
- Knowledge base with FAQ articles

**VIP Priority Support System**

**Routing Logic**

When user initiates support request:
1. Application checks is_vip status from user profile
2. If VIP: Ticket tagged with "golden_devil_priority" and routed to premium support queue
3. If Free: Ticket routed to standard support queue

**Service Level Agreements (SLA)**

| User Tier | First Response Time | Resolution Time Target | Support Channels |
|-----------|--------------------|-----------------------|-----------------|
| Golden Devil VIP | < 60 minutes | < 24 hours for non-technical issues | Live chat, email, priority phone line |
| Free Tier | < 24 hours | < 72 hours | Email, knowledge base |

**Automated Refund System**

Compliance Driver: EU Consumer Rights Directive (14-day cooling-off period for digital services)

**Refund Policy Implementation**

Eligible Scenarios:
1. Accidental purchase within 48 hours (full refund)
2. Technical issue preventing service access (prorated refund)
3. EU cooling-off period request within 14 days (full refund minus used days)

**Self-Service Refund Flow**

1. User navigates to Settings → Subscription → Request Refund
2. Application displays refund eligibility check:
   - Purchase date < 14 days ago: Eligible for cooling-off refund
   - Reported critical bug: Eligible for technical issue refund
   - Otherwise: Display reason for ineligibility
3. User selects refund reason from dropdown
4. Backend triggers refund via RevenueCat/Stripe API
5. Refund processed within 5-7 business days
6. VIP access revoked immediately upon refund approval

**Support Analytics Dashboard**

Metrics tracked:
- Average first response time (by tier)
- Customer satisfaction score (CSAT)
- Ticket volume by category (billing, technical, abuse reports)
- VIP vs. Free tier support cost ratio

### Viral Growth & Referral System

**Deep Link Architecture**

Provider: Branch.io or Firebase Dynamic Links

Purpose: Enable seamless profile sharing to social media with direct app navigation

**Deep Link Flow**

1. User taps "Share Profile" button on another user's profile card
2. Application generates unique deep link: `https://malo.app/profile/{user_id}?ref={referrer_id}`
3. User shares link to Instagram Story, WhatsApp, etc.
4. Recipient clicks link:
   - If app installed: Opens directly to profile view
   - If app not installed: Redirects to App Store/Play Store, then to profile after install
5. Attribution tracked: referrer_id receives credit if recipient signs up

**Deep Link Use Cases**

| Scenario | Link Pattern | Behavior |
|----------|-------------|----------|
| Profile Tease | `/profile/{user_id}` | Direct to profile, blur photos for non-matched users |
| Event Check-In | `/event/{venue_id}` | Show all users checked in at venue |
| Referral Invite | `/invite/{referrer_code}` | Pre-fill referral credit on signup |
| VIP Promotion | `/vip/{campaign_id}` | Direct to subscription page with discount code |

**Referral Reward System**

**Mechanics**

Goal: Incentivize users to invite high-quality, engaged users

**Referral Requirements**

To prevent gaming the system:
- Referred user must complete age verification
- Referred user must upload at least 3 photos
- Referred user must select 3 Red Flags
- Referred user must remain active for 7 days (open app at least 3 times)

**Reward Tiers**

| Milestone | Reward | Business Logic |
|-----------|--------|---------------|
| First qualified referral | 3 days VIP access | Encourage initial sharing |
| 5 qualified referrals | 14 days VIP access | Reward consistent advocates |
| 20 qualified referrals | 60 days VIP access | VIP-level value for power users |
| 50 qualified referrals | Permanent VIP status | Ultimate brand ambassador recognition |

**Referral Tracking Data Model**

```
{
  referrer_user_id: UUID,
  referred_user_id: UUID,
  referral_code: String (unique per user),
  click_timestamp: ISO8601,
  signup_timestamp: ISO8601 (nullable),
  qualification_timestamp: ISO8601 (nullable),
  reward_granted: Boolean,
  reward_type: Enum (vip_days, permanent_vip)
}
```

**Viral Loop Optimization**

Prompt Timing:
- After user's first successful match: "Share MALO with your wild friends"
- After 10 swipes completed: "Know someone who'd love this? Invite them for free VIP"
- When VIP subscription expires: "Earn VIP days by inviting others"

### Legal Compliance Documentation

**Terms of Service (ToS) Requirements**

**Code of Conduct Section**

Must explicitly define acceptable vs. prohibited behavior:

**Permitted "Bad Behavior" (Brand-Aligned)**
- Flirtatious or suggestive messaging between matched users
- Transparent disclosure of non-traditional relationship preferences
- Nightlife-focused spontaneous meetup requests
- Provocative profile content without explicit nudity

**Prohibited Behavior (Zero Tolerance)**
- Harassment after unmatch or explicit rejection
- Unsolicited explicit imagery
- Stalking or doxxing (sharing private information)
- Impersonation or catfishing
- Solicitation of prostitution or sexual services
- Hate speech based on protected characteristics

**Enforcement Consequences**

First Violation (Minor): Warning message + 24-hour account suspension
Second Violation: 7-day account suspension + reputation score penalty
Third Violation or Severe First Offense: Permanent ban + device blacklist

**Privacy Policy Transparency Requirements**

**Burner Mode Data Retention Clause**

Required Language:
"Messages sent in Burner Mode are automatically deleted from our servers 24 hours after sending. This deletion is permanent and irreversible. We retain no backup copies of expired Burner messages. However, message metadata (sender, recipient, timestamp) is retained for safety and legal compliance purposes."

**Data Processing Disclosure**

Must enumerate all third-party data processors:

| Service Provider | Data Shared | Purpose | Legal Basis |
|-----------------|-------------|---------|-------------|
| Amazon Web Services (AWS) | All user data | Infrastructure hosting | Legitimate interest (service provision) |
| Twilio | Phone numbers, SMS content | Phone verification, emergency notifications | Consent + Legitimate interest |
| Stripe/RevenueCat | Payment info, email | Subscription billing | Contractual necessity |
| Amazon Rekognition | Profile photos | Content moderation | Legitimate interest (safety) |
| Branch.io | Device IDs, referral data | Deep linking, attribution | Consent |
| Zendesk | Support tickets, email | Customer support | Legitimate interest |

**Data Processing Agreement (DPA)**

GDPR Article 28 requires written agreements with all processors confirming:
- They process data only per controller (MALO) instructions
- They implement appropriate security measures
- They assist with data subject rights requests
- They notify MALO of data breaches within 24 hours
- They delete/return data upon contract termination

**DPA Validation Checklist**

For each third-party service:
- [ ] Signed DPA on file
- [ ] EU data residency confirmed or Standard Contractual Clauses (SCCs) in place
- [ ] Annual security audit report reviewed
- [ ] Sub-processor list disclosed and approved

### Continuous Deployment Infrastructure

**Zero-Downtime Deployment Strategy**

Method: Blue/Green Deployment Pattern

**Architecture**

Environments:
- Blue: Currently serving production traffic
- Green: New version deployed and validated

Deployment Flow:
1. New code version deployed to Green environment
2. Automated smoke tests executed against Green
3. Manual QA validation on Green environment
4. Load balancer gradually shifts traffic from Blue to Green (10% → 50% → 100% over 30 minutes)
5. Monitor error rates and latency during cutover
6. If anomaly detected: Instant rollback to Blue (< 30 seconds)
7. If stable: Blue environment kept warm for 24 hours, then decommissioned

**Rollback Triggers (Automatic)**

| Metric | Threshold | Action |
|--------|-----------|--------|
| Error rate | > 5% increase | Instant rollback to Blue |
| p95 latency | > 2x baseline | Instant rollback to Blue |
| WebSocket connection failure | > 10% | Instant rollback to Blue |
| Database connection pool exhaustion | Any instance | Instant rollback to Blue |

**Staging Environment Architecture**

Purpose: Pre-production validation with production-equivalent infrastructure

**Environment Specifications**

Infrastructure: Identical to production but 25% scale
- 3 backend service instances (vs. 10 in production)
- PostgreSQL with same schema, synthetic test data (100k users)
- Redis cluster with same configuration
- MongoDB with test chat history
- All third-party integrations configured with test/sandbox accounts

**Staging Deployment Pipeline**

Every code commit to main branch triggers:
1. Automated unit tests (must pass 100%)
2. Automated integration tests against staging database
3. Automated E2E tests (critical user flows: signup, swipe, match, chat)
4. Deployment to staging environment
5. Automated smoke tests (API health checks)
6. Staging environment URL shared with QA team for manual validation

**Production Deployment Gating**

Production deployment allowed only if:
- All staging tests pass
- Manual QA approval in staging
- No critical bugs reported in last 24 hours
- Deployment scheduled during low-traffic hours (02:00-06:00 EU time)

**CI/CD Pipeline Tooling**

Version Control: GitHub with protected main branch
CI/CD Platform: GitHub Actions or GitLab CI
Container Registry: AWS ECR (Elastic Container Registry)
Orchestration: AWS ECS with task definitions per service
Infrastructure as Code: Terraform for reproducible environment provisioning

**Deployment Frequency Target**

Goal: Ship new features and bug fixes rapidly without compromising stability

Target Cadence:
- Hotfix deployments (critical bugs): Within 2 hours of fix validation
- Feature releases: 2-3 times per week during active development
- Dependency updates: Weekly security patch cycle

**Deployment Monitoring Dashboard**

Real-time visibility during deployments:
- Traffic split percentage (Blue vs. Green)
- Error rate comparison (current vs. baseline)
- Latency percentiles (p50, p95, p99)
- Active user count
- Database query performance
- Manual rollback button (one-click revert)

## Production Operations Excellence

### Launch Checklist

Pre-launch validation gates that must all be satisfied:

**Infrastructure Readiness**
- [ ] Load testing completed with 100k concurrent users, zero critical failures
- [ ] Auto-scaling triggers validated under simulated traffic spikes
- [ ] Database sharding strategy documented and tested
- [ ] CDN cache hit rate > 95% in staging
- [ ] Disaster recovery runbook documented and team-validated
- [ ] All production secrets stored in AWS Secrets Manager
- [ ] SSL/TLS certificates valid for 12+ months

**Compliance & Legal**
- [ ] Age verification system tested with test accounts (approve and reject paths)
- [ ] GDPR consent flow validated with legal team
- [ ] Terms of Service and Privacy Policy reviewed by EU legal counsel
- [ ] Data Processing Agreements signed with all vendors
- [ ] Content moderation team trained and 24/7 coverage confirmed
- [ ] Safe Word emergency flow tested end-to-end
- [ ] Data deletion (Nuke button) tested and verified in staging

**App Store Submission**
- [ ] Apple App Store submission with moderation evidence documentation
- [ ] Google Play Store submission with content rating questionnaire
- [ ] App Store screenshots and description emphasize "Social Discovery" positioning
- [ ] Age rating set to 17+/Adults Only across all regions
- [ ] In-app content filtering demonstrated in review notes

**Localization**
- [ ] All 5 languages (EN, FR, DE, ES, IT) translated and QA validated
- [ ] Currency display correct for EUR, GBP, CHF
- [ ] VAT/tax calculation tested for all EU countries
- [ ] Regional Red Flag labels reviewed by native speakers
- [ ] Push notification templates translated

**Monitoring & Support**
- [ ] Prometheus/Grafana dashboards configured with critical metrics
- [ ] PagerDuty on-call rotation scheduled for launch week
- [ ] Zendesk support queue configured with VIP routing rules
- [ ] Knowledge base populated with 20+ FAQ articles
- [ ] Customer support team trained on app features and policies

**Marketing & Growth**
- [ ] Branch.io deep links tested across iOS/Android
- [ ] Referral reward system tested with test accounts
- [ ] Social media sharing preview images (Open Graph tags) configured
- [ ] Launch city targeting (Berlin, London, Paris) confirmed in marketing campaigns

### Success Metrics Baseline

Post-launch monitoring targets for first 90 days:

**Technical Performance**
- API response time p95: < 200ms
- WebSocket connection success rate: > 99%
- App crash rate: < 0.5% of sessions
- CDN availability: 99.9%

**User Engagement**
- Day 1 retention: > 40%
- Day 7 retention: > 25%
- Day 30 retention: > 15%
- Average daily swipes per active user: > 20
- Match rate: > 30% of right swipes
- Message response rate within 24h: > 50%

**Business Metrics**
- Free to VIP conversion rate: > 5% within 30 days
- VIP subscriber retention (monthly): > 60%
- Support ticket volume: < 2% of DAU
- Content moderation response time: < 2 hours (100%)

**Safety & Compliance**
- User reports per 1000 DAU: < 10
- False positive moderation rate: < 5%
- Safe Word activations: Monitored (no target, emergency metric)
- GDPR data deletion requests processed within SLA: 100%

These operational foundations ensure MALO launches as a production-grade platform capable of scaling from initial European markets to continent-wide adoption while maintaining brand identity, legal compliance, and technical excellence.

### Security Risks

| Risk | Likelihood | Impact | Mitigation |
| Account takeover via stolen credentials | Medium | High | Mandatory 2FA for VIP accounts, device fingerprinting |
| Profile photo scraping by bots | High | Medium | Rate limiting on photo URLs, CAPTCHA on suspicious activity |
| Fake profile proliferation | High | High | AI face verification, social auth requirement, manual review queue |
| Malicious users exploiting Safe Word | Low | Medium | Audit trail of emergency triggers, abuse detection patterns |
| GDPR violation lawsuit | Low | Critical | Legal review of all data practices, strict consent management |

### Business Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Low user retention after initial signup | High | High | Onboarding optimization, early match success rate improvement |
| VIP conversion rate below target | Medium | High | A/B testing of pricing, feature exclusivity adjustments |
| Reputation as "toxic" platform | Medium | Critical | Aggressive content moderation, positive community campaigns |
| Regulatory ban in specific countries | Low | High | Legal compliance review per market, age gate enforcement |
| Competitor launch with similar concept | Medium | Medium | Fast iteration cycle, unique brand differentiation |

## Design Validation Criteria

The system design succeeds if it enables:

1. Sub-100ms average discovery feed load time for users in target European markets
2. Real-time match notifications delivered within 1 second of mutual swipe
3. Heat map updates reflecting user density within 2 minutes of location changes
4. Zero data residency outside EU jurisdiction (GDPR compliance)
5. Automatic scaling from 10,000 to 500,000 concurrent users without manual intervention
6. Safe Word emergency notifications delivered to contacts within 10 seconds
7. VIP subscription activation reflected in user experience within 5 seconds of payment confirmation
8. Shadow ban system reducing toxic user reports by 60% within 3 months of activation
9. Message delivery success rate exceeding 99.5% under normal network conditions
10. System capable of processing 1 million swipes per hour during peak weekend traffic

The architecture prioritizes real-time performance, geographic proximity matching, and GDPR compliance while maintaining the brand's edgy aesthetic through strategic feature design rather than technical implementation details.

### Security Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
