# LankaSeva — Product Specification

> **Version:** 1.0.0  
> **Last updated:** June 2026  
> **Platform:** Android (primary) · iOS  
> **Languages:** සිංහල · English · தமிழ்

---

## Table of Contents

1. [Product Overview](#1-product-overview)
2. [Design System](#2-design-system)
   - 2.1 [Color Themes — Light Mode](#21-color-themes--light-mode)
   - 2.2 [Color Themes — Dark Mode](#22-color-themes--dark-mode)
   - 2.3 [Typography](#23-typography)
   - 2.4 [Spacing & Radius](#24-spacing--radius)
   - 2.5 [Iconography](#25-iconography)
3. [Architecture Overview](#3-architecture-overview)
4. [Pages & Screens](#4-pages--screens)
   - 4.1 [Splash Screen](#41-splash-screen)
   - 4.2 [Onboarding](#42-onboarding)
   - 4.3 [Language Selection](#43-language-selection)
   - 4.4 [District Selection](#44-district-selection)
   - 4.5 [Home Screen](#45-home-screen)
   - 4.6 [Emergency Screen](#46-emergency-screen)
   - 4.7 [Category List Screen](#47-category-list-screen)
   - 4.8 [Service Detail Screen](#48-service-detail-screen)
   - 4.9 [Search Screen](#49-search-screen)
   - 4.10 [Map Screen](#410-map-screen)
   - 4.11 [Reviews Screen](#411-reviews-screen)
   - 4.12 [Write a Review Screen](#412-write-a-review-screen)
   - 4.13 [Login / OTP Screen](#413-login--otp-screen)
   - 4.14 [Profile Screen](#414-profile-screen)
   - 4.15 [Settings Screen](#415-settings-screen)
   - 4.16 [Ad Self-Serve Portal](#416-ad-self-serve-portal)
   - 4.17 [About & Legal Screen](#417-about--legal-screen)
5. [Features & Functionalities](#5-features--functionalities)
   - 5.1 [Core Features](#51-core-features)
   - 5.2 [Emergency Features](#52-emergency-features)
   - 5.3 [Directory & Search](#53-directory--search)
   - 5.4 [Review System](#54-review-system)
   - 5.5 [Map & Location](#55-map--location)
   - 5.6 [Multilingual System](#56-multilingual-system)
   - 5.7 [Ad System](#57-ad-system)
   - 5.8 [Notifications](#58-notifications)
   - 5.9 [Offline Mode](#59-offline-mode)
   - 5.10 [Accessibility](#510-accessibility)
6. [Navigation Structure](#6-navigation-structure)
7. [Data Model](#7-data-model)
8. [API & Backend Outline](#8-api--backend-outline)
9. [Build Roadmap](#9-build-roadmap)

---

## 1. Product Overview

**LankaSeva** (ලංකා සේවා) is a free mobile directory app for Sri Lanka that consolidates every government service, emergency hotline, and public institution contact into a single searchable, reviewable, one-tap-callable application.

### Problem

There is no unified digital directory for Sri Lanka's government services. Citizens looking for their electricity board fault line, nearest hospital, or police station must search across dozens of disconnected websites or rely on word of mouth — especially difficult during emergencies.

### Solution

A lightweight, offline-capable, static-data app that:

- Lists every government service contact by district
- Enables one-tap calling directly from any listing
- Allows verified Sri Lankan residents to rate and review services
- Earns revenue through hyper-local contextual advertising

### Target Users

- All Sri Lankan residents (urban and rural)
- Primarily Android users (80%+ of Sri Lanka smartphones)
- Age range: 18–65
- Network conditions: 3G to 4G, occasional offline

### Revenue Model

| Stream | Mechanism | Estimated Share |
|---|---|---|
| Contextual in-app ads | Google AdMob + direct local deals | 40% |
| Promoted listings | Businesses pay to appear first in category | 30% |
| Self-serve ad portal | SMEs buy placements from LKR 500/day | 20% |
| Premium features | Verified business badge, analytics | 10% |

---

## 2. Design System

### 2.1 Color Themes — Light Mode

#### Primary Brand

| Token | Hex | Usage |
|---|---|---|
| `--color-primary` | `#0F6E56` | App bar, primary buttons, active nav tab, links |
| `--color-primary-light` | `#E1F5EE` | Category icon backgrounds, success tints |
| `--color-primary-dark` | `#085041` | Pressed state, dark header |
| `--color-primary-text` | `#FFFFFF` | Text on primary backgrounds |

#### Neutral Surface

| Token | Hex | Usage |
|---|---|---|
| `--color-bg-screen` | `#F4F4F2` | Screen background |
| `--color-bg-card` | `#FFFFFF` | Cards, modal surfaces |
| `--color-bg-input` | `#F8F8F7` | Input fields, search bar |
| `--color-bg-secondary` | `#EFEFED` | Metric chips, muted containers |

#### Text

| Token | Hex | Usage |
|---|---|---|
| `--color-text-primary` | `#1A1A18` | Headings, primary body |
| `--color-text-secondary` | `#5C5C59` | Sub-labels, descriptions |
| `--color-text-tertiary` | `#9C9C98` | Hints, timestamps, metadata |
| `--color-text-disabled` | `#C4C4C0` | Disabled controls |

#### Semantic

| Token | Hex | Usage |
|---|---|---|
| `--color-emergency` | `#A32D2D` | Emergency banner, SOS buttons |
| `--color-emergency-light` | `#FCEBEB` | Emergency tint backgrounds |
| `--color-success` | `#3B6D11` | Open status, success badge |
| `--color-success-light` | `#EAF3DE` | Open badge background |
| `--color-warning` | `#854F0B` | Warning, fire category |
| `--color-warning-light` | `#FAEEDA` | Warning tint backgrounds |
| `--color-info` | `#185FA5` | Water/ambulance category |
| `--color-info-light` | `#E6F1FB` | Info tint backgrounds |
| `--color-star` | `#BA7517` | Star ratings |
| `--color-star-light` | `#FAEEDA` | Star badge background |

#### Borders

| Token | Hex / Value | Usage |
|---|---|---|
| `--color-border-light` | `rgba(0,0,0,0.08)` | Card borders, dividers |
| `--color-border-medium` | `rgba(0,0,0,0.15)` | Input borders on focus |
| `--color-border-strong` | `rgba(0,0,0,0.25)` | Active selection border |

---

### 2.2 Color Themes — Dark Mode

All tokens are prefixed identically. Dark mode activates via system preference or the in-app toggle in Settings.

#### Primary Brand — Dark

| Token | Hex | Usage |
|---|---|---|
| `--color-primary` | `#1D9E75` | App bar, buttons, active nav (brighter for contrast) |
| `--color-primary-light` | `#04342C` | Category icon backgrounds |
| `--color-primary-dark` | `#085041` | Pressed state |
| `--color-primary-text` | `#FFFFFF` | Text on primary backgrounds |

#### Neutral Surface — Dark

| Token | Hex | Usage |
|---|---|---|
| `--color-bg-screen` | `#111110` | Screen background |
| `--color-bg-card` | `#1E1E1C` | Cards, modal surfaces |
| `--color-bg-input` | `#252523` | Input fields |
| `--color-bg-secondary` | `#2C2C2A` | Metric chips, muted containers |

#### Text — Dark

| Token | Hex | Usage |
|---|---|---|
| `--color-text-primary` | `#F0F0EE` | Headings, primary body |
| `--color-text-secondary` | `#ABABAB` | Sub-labels, descriptions |
| `--color-text-tertiary` | `#6E6E6A` | Hints, timestamps |
| `--color-text-disabled` | `#4A4A47` | Disabled controls |

#### Semantic — Dark

| Token | Hex | Usage |
|---|---|---|
| `--color-emergency` | `#E24B4A` | Emergency elements |
| `--color-emergency-light` | `#501313` | Emergency tint |
| `--color-success` | `#97C459` | Open status |
| `--color-success-light` | `#173404` | Success tint |
| `--color-warning` | `#EF9F27` | Warning elements |
| `--color-warning-light` | `#412402` | Warning tint |
| `--color-info` | `#85B7EB` | Info elements |
| `--color-info-light` | `#042C53` | Info tint |
| `--color-star` | `#FAC775` | Star ratings |
| `--color-star-light` | `#412402` | Star badge background |

#### Borders — Dark

| Token | Value | Usage |
|---|---|---|
| `--color-border-light` | `rgba(255,255,255,0.08)` | Card borders |
| `--color-border-medium` | `rgba(255,255,255,0.15)` | Input focus borders |
| `--color-border-strong` | `rgba(255,255,255,0.25)` | Active selection |

---

### 2.3 Typography

**Font Family:** System default — Sinhala/Tamil system fonts are prioritised to ensure correct script rendering.

```
font-family:
  'Noto Sans Sinhala',   /* Sinhala script */
  'Noto Sans Tamil',     /* Tamil script */
  -apple-system,         /* iOS San Francisco */
  'Roboto',              /* Android */
  sans-serif;
```

#### Type Scale

| Role | Size | Weight | Line Height | Usage |
|---|---|---|---|---|
| `display` | 24px | 600 | 1.2 | Screen titles |
| `heading-1` | 20px | 600 | 1.3 | Section headings |
| `heading-2` | 17px | 600 | 1.4 | Card titles |
| `heading-3` | 15px | 500 | 1.4 | Sub-headings, service names |
| `body` | 14px | 400 | 1.6 | Body text, descriptions |
| `body-sm` | 13px | 400 | 1.5 | Secondary body, addresses |
| `caption` | 12px | 400 | 1.4 | Reviews, timestamps |
| `label` | 11px | 500 | 1.2 | Badges, section labels (uppercase) |
| `micro` | 10px | 400 | 1.2 | Category grid labels |

#### Special Rules

- **Section labels** always `uppercase`, `letter-spacing: 0.07em`, `--color-text-tertiary`
- **Phone numbers** always `font-variant-numeric: tabular-nums`, `font-weight: 500`, `--color-primary`
- **Emergency numbers** always `font-size: 24px`, `font-weight: 700`, white text on coloured tile

---

### 2.4 Spacing & Radius

#### Spacing Scale

| Token | Value | Usage |
|---|---|---|
| `--space-1` | 4px | Icon gap, tight inline |
| `--space-2` | 8px | Grid gaps, badge padding |
| `--space-3` | 12px | Card internal padding |
| `--space-4` | 16px | Screen horizontal padding |
| `--space-5` | 20px | Section vertical gap |
| `--space-6` | 24px | Large section gap |

#### Border Radius

| Token | Value | Usage |
|---|---|---|
| `--radius-sm` | 6px | Badges, chips |
| `--radius-md` | 10px | Buttons, inputs, small cards |
| `--radius-lg` | 14px | Service cards, modals |
| `--radius-xl` | 20px | Bottom sheets |
| `--radius-full` | 999px | Avatar circles, language pills |

---

### 2.5 Iconography

Icon library: **Tabler Icons** (outline variant, 24px grid).

| Category | Icon name |
|---|---|
| Electricity | `ti-bolt` |
| Water | `ti-droplet` |
| Hospital | `ti-building-hospital` |
| Police | `ti-shield` |
| Fire | `ti-flame` |
| Ambulance | `ti-ambulance` |
| Court | `ti-gavel` |
| School | `ti-school` |
| Government | `ti-building-bank` |
| Phone / Call | `ti-phone`, `ti-phone-call` |
| Map / Location | `ti-map`, `ti-map-pin`, `ti-map-2` |
| Search | `ti-search` |
| Star / Review | `ti-star`, `ti-star-filled` |
| User / Profile | `ti-user`, `ti-user-circle` |
| Settings | `ti-settings` |
| Emergency | `ti-urgent` |
| Notification | `ti-bell` |
| Share | `ti-share` |
| Language | `ti-language` |
| Dark/Light mode | `ti-moon`, `ti-sun` |
| Disaster | `ti-alert-triangle` |
| Ad | `ti-speakerphone` |
| Chevrons | `ti-chevron-right`, `ti-chevron-down` |

---

## 3. Architecture Overview

```
LankaSeva
├── Mobile App (React Native)
│   ├── Navigation (React Navigation v6)
│   ├── State (Zustand)
│   ├── Language (i18n — Sinhala / English / Tamil)
│   ├── Theme (Light / Dark context)
│   ├── Offline Cache (AsyncStorage + SQLite)
│   └── Ads (Google AdMob SDK)
│
├── Backend (Node.js + Express)
│   ├── REST API
│   ├── PostgreSQL (services, reviews, users)
│   ├── Redis (rate limiting, OTP sessions)
│   └── Admin CMS (manage service data)
│
└── Ad Portal (React web)
    ├── Advertiser self-serve
    ├── Campaign management
    └── Reporting dashboard
```

### Data Flow

```
App Launch
  └── Load cached data (SQLite)
  └── Background sync with API (if online)
        └── Update services, reviews, ads
  └── Show home screen immediately
```

---

## 4. Pages & Screens

---

### 4.1 Splash Screen

**Purpose:** Brand moment on cold launch.

**Elements:**
- App logo (ලංකා සේවා wordmark + shield icon in `--color-primary`)
- Tagline: *"Every service. One tap away."* in all three scripts
- Background: `--color-primary`
- Version number (`--color-primary-light`, `caption`)

**Behaviour:**
- Duration: 1.5 seconds
- Transitions to Onboarding (first launch) or Home (returning user)
- Respects system light/dark mode from this screen onward

---

### 4.2 Onboarding

**Purpose:** Show value before asking for any permissions.

**Screens (3 slides, swipeable):**

| Slide | Headline | Sub | Illustration |
|---|---|---|---|
| 1 | Every government contact, in one place | CEB, NWSDB, hospitals, police — all districts | Directory icon grid |
| 2 | One tap to call any service | No searching, no copying numbers | Phone + service card |
| 3 | Real reviews from real Sri Lankans | Rate services, help your community | Stars + avatar row |

**Elements per slide:**
- Progress dots (3)
- Skip button (top right, `--color-text-tertiary`)
- Next / Get started button (`--color-primary`, full width)

**Permissions requested after slide 3:**
- Location (for auto district detection) — optional, can skip
- Notifications — optional, can skip

---

### 4.3 Language Selection

**Purpose:** Set app language before first use.

**Triggered:** After onboarding, before district selection. Also accessible from Settings at any time.

**Elements:**
- Screen title: "Choose your language"
- Three large selectable cards:
  - 🇱🇰 **සිංහල** — Sinhala
  - 🇬🇧 **English** — English
  - 🇱🇰 **தமிழ்** — Tamil
- Selected card: `border: 2px solid --color-primary`, checkmark icon
- Continue button (disabled until selection)

**Behaviour:**
- Persists to `AsyncStorage` as `app_language`
- All strings switch immediately on selection (live preview)
- Can be changed at any time from Settings → Language

---

### 4.4 District Selection

**Purpose:** Set the user's district to show relevant services first.

**Triggered:** After language selection on first launch. Also accessible from the district chip on Home.

**Elements:**
- Screen title in selected language
- Auto-detect button: "Use my location" (calls device GPS, reverse-geocodes to district)
- Or manual selection: scrollable flat list of all 25 districts grouped by province
- Search field to filter districts
- Each district row: district name + province label
- Confirm button

**Districts covered (25):**

Western: Colombo, Gampaha, Kalutara  
Central: Kandy, Matale, Nuwara Eliya  
Southern: Galle, Matara, Hambantota  
Northern: Jaffna, Kilinochchi, Mannar, Mullaitivu, Vavuniya  
Eastern: Batticaloa, Ampara, Trincomalee  
North Western: Kurunegala, Puttalam  
North Central: Anuradhapura, Polonnaruwa  
Uva: Badulla, Monaragala  
Sabaragamuwa: Ratnapura, Kegalle

---

### 4.5 Home Screen

**Purpose:** Primary entry point. Quick access to emergency, categories, and nearby services.

**App Bar:**
- Left: "ලංකා සේවා" wordmark (white text on `--color-primary`)
- Right: Notification bell icon + Profile avatar icon

**Language Switcher:** Three pill buttons inline in the app bar (සිංහල · English · தமிழ்)

**Search Bar:**
- Full-width below app bar
- Placeholder in current language
- Left icon: `ti-search`
- Right icon: `ti-adjustments-horizontal` (filter)
- Tapping navigates to Search Screen

**District Chip:**
- Shows selected district (e.g. "Colombo District")
- Sub-label: "Tap to change"
- Right: `ti-chevron-down`
- Tapping opens District Selection bottom sheet

**Emergency Section:**
- `--color-emergency` banner card labelled "Emergency Contacts"
- Icon: `ti-urgent`
- Tapping opens Emergency Screen
- Below banner: 2×2 quick-dial grid tiles (Police 119, Ambulance 110, Fire 111, Disaster 117)
- Each tile: coloured background, icon, label, number. Tapping initiates call immediately with confirm dialog

**Category Grid:**
- Label: "Browse by category" (section label style)
- 4-column grid, 2 rows (8 categories + "More" overflow)
- Each item: coloured icon circle, label below
- Tapping navigates to Category List Screen

**Nearby Services:**
- Label: "Near you — [District]"
- Vertical list of Service Cards (see 4.8 for card spec)
- Maximum 10 items; "See all" link at bottom

**Ad Strip:**
- 1 contextual ad strip between nearby service items
- Labelled "Ad" (small pill, `--color-text-tertiary`)
- Tapping opens advertiser link

**Bottom Navigation:**
- 5 tabs: Home · Search · Map · Reviews · Profile
- Active tab: `--color-primary` icon + label
- Inactive: `--color-text-tertiary`

---

### 4.6 Emergency Screen

**Purpose:** Immediate, no-friction access to all emergency numbers.

**Design:** Full-screen, red-tinted background (`--color-emergency-light`). This screen is intentionally different from the rest of the app — high contrast, large text.

**Header:**
- Large `ti-urgent` icon
- Title: "Emergency Contacts" (24px, bold)
- Sub: "Tap any number to call immediately"

**Number Tiles (full-width, high contrast):**

| Service | Number | Background |
|---|---|---|
| Police | 119 | `--color-emergency` |
| Ambulance / Suwaseriya | 1990 | `--color-info` |
| Fire & Rescue | 111 | `--color-warning` |
| Disaster Management | 117 | `--color-success` |
| Women / Child Helpline | 1938 | `#72243E` |
| Mental Health | 1926 | `#534AB7` |
| Electricity Fault (CEB) | 1987 | `#0F6E56` |
| Water Emergency (NWSDB) | 1954 | `#185FA5` |
| Tourist Police | 1912 | `#3C3489` |
| Consumer Affairs | 1977 | `#5F5E5A` |

Each tile:
- Service icon (24px, white)
- Service name (14px, white, 500 weight)
- Number (28px, white, 700 weight)
- Full width, `--radius-md`, 16px padding

**Behaviour:**
- Tapping any tile shows a native confirm dialog: "Call [number]?" → Yes / Cancel
- No login required
- Screen accessible even in offline mode (numbers are stored locally)
- "Share this screen" button at bottom (shares as text list)

---

### 4.7 Category List Screen

**Purpose:** Browse all services within a selected category, filtered by district.

**App Bar:**
- Back arrow
- Category name (e.g. "Electricity")
- Category icon (colored, matching home grid)

**District filter chip:** Inline below app bar — shows current district, tappable to change

**Sort bar:**
- Chips: Nearest · Highest rated · Most reviewed · Open now
- Selected chip: `--color-primary-light` background, `--color-primary` text

**Service cards:** Vertical list (identical to Home Screen service cards)

**Empty state:**
- If no services in district: "No [category] services listed for [District] yet."
- CTA: "Suggest a service" — opens a simple form (name, phone number, address)

---

### 4.8 Service Detail Screen

**Purpose:** Full contact info, call actions, map, and reviews for a single service.

**Header:**
- Coloured background matching category
- Service logo icon (white, 44px circle)
- Service name (heading-2, white)
- Department / institution name (body-sm, white 75% opacity)
- District badge

**Stats Row (3 metric chips):**
- Rating (star + number)
- Review count
- Open / Closed status with hours

**Contact Table:**
- All phone numbers (each is tappable to call)
- Address (tappable to open in Google Maps / Apple Maps)
- Opening hours by day
- Website (if available)
- WhatsApp (if available)

**Action Buttons:**
- Primary: "Call [main number]" — `--color-primary` button
- Secondary: Map icon — opens native map
- Tertiary: Share icon — shares service details as text

**Contextual Ad Strip:** 1 ad shown between contact table and reviews

**Reviews Section:**
- Average star display (large number + 5 filled/empty stars)
- Distribution bar (5★ to 1★ counts)
- Review cards (10 most recent, paginated)
  - User avatar (initials circle, coloured)
  - Display name
  - Star rating
  - Date (relative: "3 days ago")
  - Review text
  - Helpful / Not helpful thumbs
- "Write a review" button (requires login)
- "See all [N] reviews" link

**Report button:** Small text link at bottom — "Report incorrect info"

---

### 4.9 Search Screen

**Purpose:** Full-text search across all services and categories.

**Elements:**
- Auto-focused search input on screen enter
- Placeholder: "Search electricity, hospital, police…"
- Clear button (×) when text is entered

**Search Scope:**
- Service name
- Department name
- Phone numbers
- Address
- Category
- District

**Results:**
- Grouped by: Services · Categories · Districts
- Each result shows service name, category chip, district
- Tapping navigates to Service Detail Screen

**Recent Searches:**
- Stored locally (last 10 searches)
- Shown when search bar is focused and empty
- Each item: clock icon + search term + × to remove

**No results state:**
- "No results for '[query]'"
- Suggestions: Browse categories / Browse emergency contacts
- CTA: "Suggest a missing service"

---

### 4.10 Map Screen

**Purpose:** Visual district map of all services.

**Map Provider:** Google Maps SDK (Android/iOS)

**Controls:**
- Current location button (top right)
- Category filter chips (horizontal scroll above map)
- District boundary overlay (optional, toggled by button)

**Markers:**
- Coloured by category (matching category color system)
- Clustered when zoomed out
- Tapping a marker shows a bottom sheet mini-card with service name, rating, and "View details" button

**List toggle:**
- Toggle button: Map / List
- List view shows same results as a scrollable service list

---

### 4.11 Reviews Screen

**Purpose:** Community feed of recent reviews across all services.

**Header:** "Community Reviews" + district chip

**Feed items (each card):**
- Service name + category badge
- Reviewer name + avatar
- Star rating
- Review text (truncated to 3 lines, "Read more" expands)
- Date
- Helpful count + thumbs up button

**Filters:**
- Category filter (multi-select chips)
- Star filter (1★ to 5★)
- District filter

**Empty state:** "No reviews yet for your district. Be the first to help your community."

---

### 4.12 Write a Review Screen

**Purpose:** Authenticated review submission.

**Triggered from:** Service Detail Screen → "Write a review" button

**Requires login** (see 4.13). If not logged in, tapping "Write a review" triggers Login screen with a return redirect.

**Elements:**
- Service name header (read-only)
- Star picker (5 large tappable stars)
- Text area: "Describe your experience" — minimum 20 characters, maximum 500
- Character counter
- Optional: "What went well?" tags (multi-select chips — e.g. Helpful staff, Fast response, Accurate information, Easy to find)
- Optional: "What could improve?" tags (e.g. Long wait, Outdated info, Hard to reach, Rude staff)
- Submit button (disabled until star + minimum text filled)

**Post-submit:**
- Success toast: "Review submitted. Thank you for helping your community."
- Returns to Service Detail Screen
- New review appears after moderation (auto-approved unless flagged by keyword filter)

**Rules:**
- One review per user per service (can edit within 7 days)
- Reviews are public and attributed to user's display name
- No phone numbers or personal info in review text (filtered client-side)

---

### 4.13 Login / OTP Screen

**Purpose:** Verify Sri Lankan mobile numbers to enable review posting. No email or password required.

**Flow:**

```
Step 1 — Enter phone number
  └── Country code locked to +94 (Sri Lanka)
  └── 9-digit mobile number input
  └── "Send OTP" button

Step 2 — Enter OTP
  └── 6-digit OTP sent via SMS
  └── Auto-fills if SMS permissions granted (Android)
  └── "Verify" button
  └── Resend OTP (after 60-second countdown)

Step 3 — Set display name (first time only)
  └── Name input (shown publicly on reviews)
  └── "Continue" button
```

**Design:**
- Clean single-column layout
- Phone input: large font (`heading-2`), tabular numbers
- OTP input: 6 separate single-digit boxes
- Back button to return without logging in (browsing always remains available)

**Data stored:**
- Phone number (hashed, never displayed)
- Display name (user-set, shown on reviews)
- JWT token (7 days, stored in SecureStore)

**Privacy note displayed:** "Your number is used only for verification. It is never shown publicly."

---

### 4.14 Profile Screen

**Purpose:** User account details, review history, saved services.

**Accessible:** Only when logged in. Shows login prompt if not.

**Sections:**

**Account card:**
- Avatar circle (initials)
- Display name (editable)
- Member since date
- Edit name button

**My Reviews:**
- List of all reviews submitted by user
- Each item: service name, star rating, date, edit / delete options

**Saved Services:**
- Bookmarked services (heart icon on service card to save)
- "No saved services yet" empty state

**My District:**
- Current district with change button

**Language:**
- Current language with change button

**Log out button** (bottom, `--color-emergency` text color)

---

### 4.15 Settings Screen

**Purpose:** App-wide preferences.

**Sections:**

**Appearance:**
- Theme toggle: Light / Dark / System default
  - Light: sun icon, white preview swatch
  - Dark: moon icon, dark preview swatch
  - System: device icon, auto label
- Language selector (opens Language Selection screen)

**Location:**
- Auto-detect district: toggle on/off
- Current district (tappable to change)

**Notifications:**
- Service update alerts: toggle
- Emergency alerts for district: toggle
- New review replies: toggle

**Data & Privacy:**
- Clear search history
- Clear saved services
- Delete account (destructive, requires confirmation dialog)
- Privacy policy link
- Terms of service link

**About:**
- App version
- "Rate LankaSeva on Play Store" (opens store link)
- "Report a bug" (opens mailto or feedback form)
- "Suggest a missing service"

---

### 4.16 Ad Self-Serve Portal

**Purpose:** Allow local Sri Lankan businesses to buy ad placements in 3 steps.

**Accessed via:** Web browser (mobile-responsive). Link in app under "Advertise with us".

**Step 1 — Business details:**
- Business name
- Category (dropdown — matches app categories)
- District targeting (multi-select — all 25 districts)
- Contact number

**Step 2 — Ad creative:**
- Headline (max 40 chars)
- Description (max 80 chars)
- Logo upload (PNG/JPG, min 200×200px)
- Preview shown live in an app mockup

**Step 3 — Budget & schedule:**
- Daily budget slider: LKR 500 minimum → LKR 50,000 maximum
- Start date (date picker)
- Duration: 7 days / 14 days / 30 days / custom
- Total cost shown in real-time
- Payment: Dialog Finance / credit card / bank transfer

**Dashboard (post-purchase):**
- Impressions, taps, tap-through rate
- Budget spent vs remaining
- Pause / Resume / Edit campaign

---

### 4.17 About & Legal Screen

**Elements:**
- LankaSeva logo + version
- Mission statement (1 paragraph)
- Data sources (list of government sources used)
- Last data update timestamp
- Privacy Policy (inline text, scrollable)
- Terms of Service
- Contact: `hello@lankseva.lk`
- Social links

---

## 5. Features & Functionalities

---

### 5.1 Core Features

| Feature | Description |
|---|---|
| Service directory | Comprehensive listing of all Sri Lanka government services by category and district |
| One-tap calling | Direct dial from any service listing — no copying numbers |
| Offline access | Core data (all service contacts) cached locally and usable without internet |
| District filtering | Auto-detect or manually select any of 25 districts |
| Multilingual | Full UI in Sinhala, English, and Tamil including script-correct fonts |
| Light / Dark mode | System-adaptive with manual override in Settings |
| Static data model | No complex server required for browsing — just a JSON/SQLite data file |

---

### 5.2 Emergency Features

| Feature | Description |
|---|---|
| Emergency hub screen | Dedicated full-screen emergency contact page accessible in 2 taps from anywhere |
| Quick-dial tiles | 4 emergency tiles on Home Screen for instant access |
| 10 national hotlines | Police, Ambulance, Fire, Disaster, Women/Child, Mental Health, CEB, NWSDB, Tourist Police, Consumer Affairs |
| Offline emergency numbers | Emergency contacts always available, even with no internet |
| Share emergency contacts | Share the full list as a text message to family/friends |
| No login for emergency | Emergency screen never requires authentication |

---

### 5.3 Directory & Search

| Feature | Description |
|---|---|
| 9 service categories | Electricity, Water, Hospitals, Police, Courts, Schools, Government Offices, Transport, Post Office |
| 25 districts | All Sri Lanka districts covered |
| Full-text search | Search by name, category, number, address |
| Filter & sort | By distance, rating, review count, open status |
| Open/closed status | Each service shows real hours and live open/closed badge |
| Suggest a service | Users can submit missing services (reviewed by admin) |
| Report incorrect info | Flag outdated contact details |
| Service sharing | Share any service card as a formatted text message |

---

### 5.4 Review System

| Feature | Description |
|---|---|
| Verified reviews | Only verified Sri Lanka phone numbers can post |
| OTP login | No email, no password — Sri Lanka +94 mobile only |
| Star rating | 1–5 stars per service |
| Review tags | Pre-set positive / negative experience tags |
| One review per service | Each user can review each service once (editable for 7 days) |
| Helpful voting | Other users can mark reviews as helpful |
| Review moderation | Auto-filter for phone numbers and abusive terms; admin review queue for flagged content |
| Community feed | District-level reviews feed on Reviews tab |
| Anonymous display | Only display name shown (never phone number) |

---

### 5.5 Map & Location

| Feature | Description |
|---|---|
| Google Maps integration | All services pinned on an interactive map |
| Category-coloured markers | Each category has a distinct pin colour |
| Marker clustering | Groups nearby pins when zoomed out |
| Service mini-card | Tap a pin for a quick summary card |
| Navigate to service | Hands off to Google Maps / Apple Maps for turn-by-turn |
| District boundary overlay | Optional view of district boundaries |
| Auto location detection | Optional GPS-based district assignment |

---

### 5.6 Multilingual System

| Feature | Description |
|---|---|
| 3 languages | Sinhala, English, Tamil |
| Script-correct fonts | Noto Sans Sinhala, Noto Sans Tamil — prevent rendering issues |
| Language persistence | Selected language saved to device, persists across sessions |
| In-app switcher | Language pills in app bar — switches immediately |
| Separate data | Service names and descriptions provided in all 3 languages |
| RTL awareness | Tamil requires partial RTL layout support |

---

### 5.7 Ad System

| Feature | Description |
|---|---|
| Google AdMob | Integrated for banner + interstitial ads (post 10K users) |
| Contextual placement | Ads match the category being browsed — solar ads in electricity, plumbers in water |
| Local advertiser portal | Self-serve ad creation for Sri Lankan SMEs |
| Minimum spend | LKR 500/day — accessible to any small business |
| District targeting | Ads shown only to users in targeted district(s) |
| Ad label | All ads clearly marked "Ad" per user trust guidelines |
| Frequency cap | Maximum 1 ad strip per screen, no interstitials on Emergency screen |
| No ads on Emergency | Emergency screen and quick-dial tiles are always ad-free |

---

### 5.8 Notifications

| Feature | Description |
|---|---|
| Service update alerts | Push notification when a service's contact details are updated |
| Emergency district alerts | Opt-in alerts for local emergencies (power outages, floods) |
| Review replies | Notify user when their review receives a helpful vote or reply |
| New service added | Notify users when a new service is added in their district |
| Opt-in only | All notifications require explicit permission; each type toggleable independently |

---

### 5.9 Offline Mode

| Feature | Description |
|---|---|
| Full contact directory | All service contacts cached in SQLite on first launch |
| Emergency numbers | Always available offline |
| Last-viewed services | Service detail pages cached on view |
| Background sync | Data silently refreshes when connection resumes |
| Offline indicator | Subtle banner when operating offline |
| Cache size | Estimated 5–8 MB for full district dataset |

---

### 5.10 Accessibility

| Feature | Description |
|---|---|
| Large tap targets | Minimum 44×44pt touch areas on all interactive elements |
| High contrast | All text meets WCAG AA contrast ratio in both light and dark modes |
| Dynamic type | Respects system font size preferences |
| Screen reader support | All icons labelled with `accessibilityLabel`; all images have descriptions |
| Reduced motion | Animations disabled when system reduced motion is on |
| Colour-blind safe | Emergency uses icon + text, never colour alone |

---

## 6. Navigation Structure

```
App
├── Onboarding (first launch only)
│   ├── Slide 1
│   ├── Slide 2
│   └── Slide 3
│       └── Language Selection
│               └── District Selection
│                       └── Home Screen
│
├── Bottom Tab Navigator
│   ├── Home
│   │   ├── Emergency Screen
│   │   │   └── (one-tap call confirm dialog)
│   │   ├── Category List Screen
│   │   │   └── Service Detail Screen
│   │   │       ├── Call confirm dialog
│   │   │       ├── Map (native handoff)
│   │   │       └── Write Review Screen
│   │   │           └── Login Screen (if not logged in)
│   │   └── District Selection (bottom sheet)
│   │
│   ├── Search
│   │   └── Service Detail Screen
│   │
│   ├── Map
│   │   └── Service mini-card → Service Detail Screen
│   │
│   ├── Reviews (community feed)
│   │   └── Service Detail Screen
│   │
│   └── Profile
│       ├── Login Screen (if not logged in)
│       ├── My Reviews → Service Detail Screen
│       └── Settings Screen
│           ├── Language Selection
│           └── District Selection
│
└── Ad Self-Serve Portal (web, linked from About screen)
```

---

## 7. Data Model

### Service

```typescript
interface Service {
  id: string;                    // UUID
  name: { si: string; en: string; ta: string };
  department: { si: string; en: string; ta: string };
  category: CategoryType;
  district: DistrictType;
  province: ProvinceType;
  phones: Phone[];
  address: { si: string; en: string; ta: string };
  lat: number;
  lng: number;
  hours: OpeningHours;
  website?: string;
  whatsapp?: string;
  isEmergency: boolean;
  isActive: boolean;
  lastVerified: ISO8601Date;
  createdAt: ISO8601Date;
  updatedAt: ISO8601Date;
}

interface Phone {
  label: { si: string; en: string; ta: string };
  number: string;
  isPrimary: boolean;
}

interface OpeningHours {
  mon?: { open: string; close: string };
  tue?: { open: string; close: string };
  wed?: { open: string; close: string };
  thu?: { open: string; close: string };
  fri?: { open: string; close: string };
  sat?: { open: string; close: string };
  sun?: { open: string; close: string };
  isAlwaysOpen: boolean;
  notes?: string;
}
```

### Review

```typescript
interface Review {
  id: string;
  serviceId: string;
  userId: string;                // hashed phone number
  displayName: string;
  stars: 1 | 2 | 3 | 4 | 5;
  text: string;
  positiveTags: string[];
  negativeTags: string[];
  helpfulCount: number;
  isModerated: boolean;
  createdAt: ISO8601Date;
  editedAt?: ISO8601Date;
}
```

### User

```typescript
interface User {
  id: string;
  phoneHash: string;             // SHA-256 of +94XXXXXXXXX
  displayName: string;
  district: DistrictType;
  language: 'si' | 'en' | 'ta';
  createdAt: ISO8601Date;
  lastActive: ISO8601Date;
}
```

### Category Enum

```typescript
type CategoryType =
  | 'electricity'
  | 'water'
  | 'hospital'
  | 'police'
  | 'court'
  | 'school'
  | 'government'
  | 'transport'
  | 'post';
```

---

## 8. API & Backend Outline

### Endpoints

| Method | Path | Description | Auth |
|---|---|---|---|
| `GET` | `/services` | List services (filter by district, category) | None |
| `GET` | `/services/:id` | Single service detail | None |
| `GET` | `/services/:id/reviews` | Reviews for a service | None |
| `POST` | `/services/:id/reviews` | Submit a review | JWT |
| `PUT` | `/reviews/:id` | Edit own review (within 7 days) | JWT |
| `POST` | `/reviews/:id/helpful` | Mark review as helpful | JWT |
| `POST` | `/auth/otp/send` | Send OTP to phone number | None |
| `POST` | `/auth/otp/verify` | Verify OTP, return JWT | None |
| `GET` | `/user/profile` | Get own profile | JWT |
| `PUT` | `/user/profile` | Update display name / district | JWT |
| `GET` | `/categories` | List all categories | None |
| `GET` | `/districts` | List all districts | None |
| `POST` | `/suggest` | Suggest a missing service | None |
| `POST` | `/report/:serviceId` | Report incorrect info | None |

### Data Sync Strategy

- Full district bundle: compressed JSON (~500KB per district)
- Incremental updates: `GET /sync?district=colombo&since=[timestamp]`
- App downloads the user's district on first launch and updates in background

---

## 9. Build Roadmap

### Phase 1 — MVP (Weeks 1–8)

- [ ] Collect and structure all government contacts (9 categories × 25 districts)
- [ ] React Native project setup (navigation, theme, i18n)
- [ ] Light/Dark mode theme system
- [ ] Home, Emergency, Category List, Service Detail screens
- [ ] One-tap calling
- [ ] Offline SQLite cache
- [ ] Launch on Google Play (Android first)

### Phase 2 — Reviews (Weeks 9–12)

- [ ] OTP login system (+94 only)
- [ ] Write review screen
- [ ] Review display on service detail
- [ ] Community reviews feed
- [ ] Helpful voting

### Phase 3 — Map & Search (Weeks 13–16)

- [ ] Google Maps integration
- [ ] Full-text search screen
- [ ] Recent searches
- [ ] Map markers + clustering

### Phase 4 — Ads & Revenue (Month 4+)

- [ ] Google AdMob integration
- [ ] Contextual ad placement logic
- [ ] Self-serve ad portal (web)
- [ ] Direct local advertiser outreach (Dialog, Keells, HNB, Cargills)

### Phase 5 — Growth (Month 6+)

- [ ] iOS App Store release
- [ ] Push notifications
- [ ] Government partnership outreach
- [ ] Tamil language full QA
- [ ] Analytics dashboard (internal)

---

*LankaSeva — Built for Sri Lanka. Built by Sri Lanka.*
