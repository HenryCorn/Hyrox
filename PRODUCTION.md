# Hyrox — Production Setup Guide

Everything you need to go from this repo to a live, monetised app on the App Store with real users.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Target Priority Order](#2-target-priority-order)
3. [Simulator — Reload After Code Changes](#3-simulator--reload-after-code-changes)
4. [AdMob — Ads Setup](#4-admob--ads-setup)
5. [Apple Sign-In](#5-apple-sign-in)
6. [Google Sign-In](#6-google-sign-in)
7. [Backend API — Production Deployment](#7-backend-api--production-deployment)
8. [Flutter Build — Environment Variables](#8-flutter-build--environment-variables)
9. [iOS — Signing & Provisioning](#9-ios--signing--provisioning)
10. [Secrets & Info Required Before Device Testing](#10-secrets--info-required-before-device-testing)
11. [Testing on Your Physical Devices](#11-testing-on-your-physical-devices)
12. [TestFlight Beta](#12-testflight-beta)
13. [App Store Submission — Step by Step](#13-app-store-submission--step-by-step)
14. [Revenue Optimisation Tips](#14-revenue-optimisation-tips)

---

## 1. Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.7.2 |
| Xcode | ≥ 15 |
| .NET SDK | 9.0 |
| PostgreSQL | ≥ 15 |
| An Apple Developer account | $99/yr |
| A Google Play account (Android later) | $25 one-off |

---

## 2. Target Priority Order

When a user sets targets on the Target Setup screen, the app resolves the effective target for each segment using a strict priority chain. Understanding this prevents confusion when multiple targets overlap.

### 2.1 Priority table

| Priority | Source | Applies to |
|----------|--------|-----------|
| **1 (highest)** | Individual exercise target (`INDIVIDUAL SEGMENT TARGETS → TARGET TIME`) | Any segment |
| **2** | Individual run pace (`INDIVIDUAL SEGMENT TARGETS → PACE /KM`) | Run segments only |
| **3** | Global run pace (`RUN PACE (ALL RUNS)`) | Run segments only |
| **4 (lowest)** | No target — segment shown without colour indicator | Any segment |

### 2.2 Rules in plain English

- **Individual exercise target always wins.** If you set a specific time for segment N, that time is used regardless of any pace setting.
- **Individual pace overrides the global pace.** If you set a per-segment pace for a run, it replaces the global pace for that run only. Other runs still use the global pace.
- **Global run pace applies to every run with no individual override.** It is a convenient way to set the same pace for all 8 km runs at once.
- **Stations (SkiErg, Rowing, etc.) never inherit run paces.** Only an explicit individual exercise target applies to them; global run pace and individual run paces are ignored.
- **Rox Zones are never targeted.** The transition zones between exercises have no target — they are excluded from pace colouring entirely.

### 2.3 Examples

```
Global run pace = 5:30/km
Individual pace for Run 3 = 4:45/km
Individual exercise target for SkiErg = 4:00

Run 1   → 5:30/km  (from global run pace, P3)
Run 2   → 5:30/km  (from global run pace, P3)
Run 3   → 4:45/km  (individual pace overrides global, P2)
SkiErg  → 4:00     (individual exercise target, P1)
Rox Zone → no target (always excluded)
```

### 2.4 Tests

Priority behaviour is fully covered in `apps/mobile/test/workout_target_priority_test.dart`. Run them with:

```bash
cd apps/mobile
flutter test test/workout_target_priority_test.dart
```

---

## 3. Simulator — Reload After Code Changes

### 3.1 Hot reload (fastest — UI/logic changes)

While the app is running, press **`r`** in the terminal that ran `flutter run`. Applies Dart changes in < 1 second. State is preserved.

```bash
# The terminal shows:
# Flutter run key commands.
# r Hot reload. 🔥🔥🔥
```

Use hot reload for: widget changes, logic tweaks, style fixes.

### 3.2 Hot restart (state reset)

Press **`R`** (capital) in the same terminal. Restarts the Dart VM, resetting all state. Same speed as hot reload.

Use hot restart for: provider/notifier changes, `initState` changes, anything that hot reload misses.

### 3.3 Full rebuild (new packages, native changes)

Stop the app (`q` in terminal), then:

```bash
cd apps/mobile
flutter run -d <simulator-id>
```

Find your simulator ID:

```bash
flutter devices
# Example output:
# iPhone 16 Plus (mobile) • CE9D0FF2-... • ios • com.apple.CoreSimulator...
```

Use full rebuild for: adding packages (`pubspec.yaml` changes), changing `Info.plist`, changing `AppDelegate`, changing native iOS code.

### 3.4 Wipe simulator state (clean slate)

If the app is in a broken state or you want to test first-launch:

```bash
# Stop the app first, then:
xcrun simctl erase <simulator-id>   # wipes all data for that simulator
flutter run -d <simulator-id>
```

Or in the simulator: **Device → Erase All Content and Settings**.

---

## 4. AdMob — Ads Setup

### 2.1 Create an AdMob account

1. Go to <https://admob.google.com> and sign in with a Google account.
2. Add a new app → iOS → **com.quique.hyrox** (or your bundle ID).
3. Copy the **App ID** — it looks like `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`.

### 2.2 Update Info.plist (iOS)

In `apps/mobile/ios/Runner/Info.plist`, replace the test App ID:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>   <!-- your real App ID -->
```

### 2.3 Create Ad Units

In AdMob → your app → **Ad units**, create these three:

| Placement | Type | Name (your choice) |
|-----------|------|--------------------|
| Station workout banner | Banner | `hyrox_station_banner` |
| Workout save gate | Rewarded | `hyrox_save_rewarded` |
| Friends screen banner | Banner | `hyrox_friends_banner` |

Copy the resulting `ca-app-pub-...` unit IDs.

### 2.4 Pass unit IDs at build time

Add them to your build command (see §6) so they never live in source control:

```
--dart-define=ADMOB_IOS_BANNER_STATION=ca-app-pub-XXX/YYY
--dart-define=ADMOB_IOS_REWARDED_SAVE=ca-app-pub-XXX/YYY
--dart-define=ADMOB_IOS_BANNER_FRIENDS=ca-app-pub-XXX/YYY
```

### 2.5 Test device registration

AdMob blocks test traffic if your device isn't registered. To add your real device:

1. Run the app on device once — AdMob logs your **test device ID** in the console (looks like `I/Ads: Use RequestConfiguration.Builder().setTestDeviceIds...`).
2. Add it to `AdService.initialise()` in `ad_service.dart`:

```dart
await MobileAds.instance.updateRequestConfiguration(
  RequestConfiguration(testDeviceIds: ['YOUR_DEVICE_ID_HERE']),
);
```

Remove this before release (or gate it on `kDebugMode`, which is already done).

---

## 5. Apple Sign-In

### 3.1 App ID capability

1. In [Apple Developer](https://developer.apple.com) → Certificates, IDs & Profiles → **Identifiers**.
2. Select your App ID (`com.quique.hyrox`).
3. Enable **Sign In with Apple** → Save.
4. Xcode → Runner target → **Signing & Capabilities** → **+ Capability** → Sign In with Apple.

### 3.2 Bundle ID in appsettings.json

In `services/api/Hyrox.Api/appsettings.json`:

```json
"AppleSignIn": {
  "AppBundleId": "com.quique.hyrox"
}
```

This must exactly match your Xcode bundle identifier.

### 3.3 No client secret needed

Unlike OAuth, Apple Sign-In uses JWT tokens signed by Apple. The API validates them against Apple's public JWKS endpoint automatically — no secret key to manage.

---

## 6. Google Sign-In

### 4.1 Create OAuth credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com) → APIs & Services → **Credentials**.
2. Create → **OAuth client ID** → **iOS**.
3. Enter your bundle ID: `com.quique.hyrox`.
4. Copy the generated client ID (`XXXXXXXXX.apps.googleusercontent.com`).

### 4.2 Configure the app

**`GoogleService-Info.plist`** (iOS):

Download from Google Cloud Console and add it to `apps/mobile/ios/Runner/`.

In Xcode, add it to the Runner target (drag into the project navigator).

**`appsettings.json`** (API):

```json
"GoogleSignIn": {
  "ClientId": "XXXXXXXXX.apps.googleusercontent.com"
}
```

**`Info.plist`** (iOS URL scheme — required for the Google Sign-In redirect):

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.XXXXXXXXX</string>  <!-- reversed client ID -->
    </array>
  </dict>
</array>
```

---

## 7. Backend API — Production Deployment

### 5.1 Database

Provision a PostgreSQL 15+ instance. Recommended options:

- **Supabase** (generous free tier, built-in connection pooling)
- **Neon** (serverless Postgres, scales to zero)
- **Railway** (simplest self-host)

Get your connection string:

```
Host=db.xxxx.supabase.co;Database=postgres;Username=postgres;Password=YOUR_PASSWORD;SSL Mode=Require
```

### 5.2 API environment variables

Never put secrets in `appsettings.json`. Use environment variables in production:

| Variable | Description |
|----------|-------------|
| `ConnectionStrings__hyroxdb` | PostgreSQL connection string |
| `Jwt__Key` | ≥ 32-character random secret (e.g. `openssl rand -base64 32`) |
| `Jwt__Issuer` | `hyrox-api` |
| `Jwt__Audience` | `hyrox-app` |
| `AppleSignIn__AppBundleId` | `com.quique.hyrox` |
| `GoogleSignIn__ClientId` | Your Google OAuth client ID |

Generate a JWT key:

```bash
openssl rand -base64 32
```

### 5.3 Deployment options

**Option A — Railway (easiest)**

```bash
cd services/api/Hyrox.Api
railway login
railway init
railway up
```

Set env vars in the Railway dashboard.

**Option B — Docker**

```bash
docker build -t hyrox-api .
docker run -p 8080:8080 \
  -e ConnectionStrings__hyroxdb="..." \
  -e Jwt__Key="..." \
  hyrox-api
```

**Option C — Azure App Service / AWS App Runner**

Standard .NET 9 deployment — publish with `dotnet publish -c Release` and deploy the output.

### 5.4 Migrations

Migrations run automatically on startup (`MigrateAsync()` in `Program.cs`). No manual step needed.

### 5.5 Health check

Once deployed, verify:

```bash
curl https://your-api-url/health   # → {"status":"Healthy"}
curl https://your-api-url/swagger  # → Swagger UI (disable in prod if desired)
```

---

## 8. Flutter Build — Environment Variables

All secrets and environment-specific values are passed via `--dart-define` so they are compiled into the binary and never in source control.

### 6.1 Development (simulator, test ads)

```bash
flutter run -d <device-id>
# No dart-defines needed — test ad IDs are the defaults
```

### 6.2 Release build (real ads, real API)

Create a file `scripts/build_release.sh` (gitignored):

```bash
#!/usr/bin/env bash
set -e

flutter build ios \
  --release \
  --dart-define=API_BASE_URL=https://your-api-url.com \
  --dart-define=ADMOB_IOS_BANNER_STATION=ca-app-pub-XXXX/YYYY \
  --dart-define=ADMOB_IOS_REWARDED_SAVE=ca-app-pub-XXXX/YYYY \
  --dart-define=ADMOB_IOS_BANNER_FRIENDS=ca-app-pub-XXXX/YYYY
```

```bash
chmod +x scripts/build_release.sh
echo "scripts/build_release.sh" >> .gitignore
```

### 6.3 CI/CD (GitHub Actions example)

Store secrets in GitHub → Settings → Secrets:

```yaml
- name: Build iOS
  run: |
    flutter build ios --release \
      --dart-define=API_BASE_URL=${{ secrets.API_BASE_URL }} \
      --dart-define=ADMOB_IOS_BANNER_STATION=${{ secrets.ADMOB_IOS_BANNER_STATION }} \
      --dart-define=ADMOB_IOS_REWARDED_SAVE=${{ secrets.ADMOB_IOS_REWARDED_SAVE }} \
      --dart-define=ADMOB_IOS_BANNER_FRIENDS=${{ secrets.ADMOB_IOS_BANNER_FRIENDS }}
```

---

## 9. iOS — Signing & Provisioning

### 7.1 In Xcode

1. Open `apps/mobile/ios/Runner.xcworkspace` in Xcode.
2. Select the **Runner** target → **Signing & Capabilities**.
3. Set **Team** to your Apple Developer team.
4. Set **Bundle Identifier** to `com.quique.hyrox` (or whatever you registered).
5. Enable **Automatically manage signing** for development.

For release/TestFlight, use a **Distribution** certificate and an **App Store** provisioning profile.

### 7.2 Capabilities checklist

| Capability | Needed for |
|------------|-----------|
| HealthKit | Heart rate + calories |
| Sign In with Apple | Auth |
| Background Modes → Location | GPS pace during runs |

---

## 10. Secrets & Info Required Before Device Testing

Before you can run the app on a real device or submit to the App Store, you need to collect the following. Everything marked **secret** must never be committed to git.

### 10.1 Apple Developer account

| What | Where to get it |
|------|----------------|
| Apple Developer Team ID | [developer.apple.com](https://developer.apple.com) → Membership → Team ID |
| Bundle Identifier | You choose it (e.g. `com.yourname.hyrox`) — register it under Identifiers |
| Distribution certificate | Xcode → Settings → Accounts → Manage Certificates → + → Apple Distribution |
| App Store provisioning profile | developer.apple.com → Profiles → New → App Store Distribution |

### 10.2 AdMob (Google)

| What | Where to get it | Secret? |
|------|----------------|---------|
| AdMob App ID | admob.google.com → Apps → your app | Yes — goes in `Info.plist` (not git-ignored, so use test ID until release) |
| Banner ad unit ID (station) | AdMob → Ad units | Yes — pass via `--dart-define` |
| Rewarded ad unit ID (save gate) | AdMob → Ad units | Yes — pass via `--dart-define` |
| Banner ad unit ID (friends) | AdMob → Ad units | Yes — pass via `--dart-define` |

### 10.3 Google Sign-In

| What | Where to get it | Secret? |
|------|----------------|---------|
| OAuth Client ID | Google Cloud Console → APIs & Services → Credentials → iOS | No (it's in the app binary) |
| `GoogleService-Info.plist` | Download from Cloud Console | No (but keep private) — add to Xcode target |
| Server Client ID (for API validation) | Same credentials page — Web client ID | Yes — set as `GoogleSignIn__ClientId` env var on server |

### 10.4 Backend API

| What | Description | Secret? |
|------|-------------|---------|
| PostgreSQL connection string | Host, database, username, password | **Yes** — env var `ConnectionStrings__hyroxdb` |
| JWT signing key | ≥ 32 random chars (`openssl rand -base64 32`) | **Yes** — env var `Jwt__Key` |
| Deployed API base URL | e.g. `https://hyrox-api.railway.app` | No — pass via `--dart-define=API_BASE_URL=...` |

### 10.5 App Store Connect

| What | Where to get it |
|------|----------------|
| App Store Connect API key (for upload) | App Store Connect → Users → Integrations → Keys → Generate |
| Key ID | Shown next to your key |
| Issuer ID | Shown at the top of the Keys page |
| `.p8` private key file | Downloaded once at creation — store safely, cannot re-download |

### 10.6 Summary checklist

Before your first real-device build, confirm you have:

- [ ] Apple Developer Team ID and Bundle ID registered
- [ ] Distribution certificate installed in Keychain
- [ ] App Store provisioning profile downloaded
- [ ] Real AdMob App ID in `Info.plist`
- [ ] `GoogleService-Info.plist` added to Xcode target
- [ ] JWT key generated and stored (password manager or secrets vault)
- [ ] PostgreSQL provisioned and connection string noted
- [ ] API deployed and `/health` returning 200
- [ ] App Store Connect API key `.p8` saved securely

---

## 11. Testing on Your Physical Devices

### 11.1 Register device in Apple Developer

1. Connect device → Xcode identifies UDID automatically.
2. Apple Developer → Devices → Register Device.

### 11.2 Run directly

```bash
flutter devices                          # find your device ID
flutter run -d <your-device-id>          # debug build, hot reload works
```

### 11.3 Test the full ad flow

- Station banner: start a workout, advance past the first run to a station.
- Rewarded ad gate: complete a workout (advance through all exercises).
- Friends banners: sign in, open the Friends screen.

Google test ads will appear automatically in debug mode. They look like real ads but never generate revenue.

### 11.4 Test auth flows

Apple Sign-In only works on a real device (not simulator). Google Sign-In works on both.

---

## 12. TestFlight Beta

### 12.1 Archive the app

```bash
flutter build ipa \
  --dart-define=API_BASE_URL=https://your-api.com \
  --dart-define=ADMOB_IOS_BANNER_STATION=ca-app-pub-XXX/YYY \
  --dart-define=ADMOB_IOS_REWARDED_SAVE=ca-app-pub-XXX/YYY \
  --dart-define=ADMOB_IOS_BANNER_FRIENDS=ca-app-pub-XXX/YYY
```

The `.ipa` is output to `build/ios/ipa/`.

### 12.2 Upload to App Store Connect

```bash
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/hyrox_tracker.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

Or drag the `.ipa` into **Transporter** (Mac App Store).

### 12.3 Add testers

App Store Connect → TestFlight → Add Internal / External Testers → send invite link.

External testers (up to 10,000) require Apple review (usually < 24 hours for TestFlight).

---

## 13. App Store Submission — Step by Step

### 13.1 Prepare App Store Connect

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → My Apps → **+** → New App.
2. Fill in:
   - **Platform**: iOS
   - **Name**: Hyrox Tracker (or your chosen name)
   - **Primary Language**: English
   - **Bundle ID**: select the one you registered (e.g. `com.yourname.hyrox`)
   - **SKU**: any unique string (e.g. `hyrox-tracker-001`)
3. Click Create.

### 13.2 Fill in app metadata

In your app's page on App Store Connect:

- **App Information**: subtitle, category (Health & Fitness), content rating.
- **Pricing and Availability**: Free (revenue comes from ads).
- **App Privacy**: set data types (see §13.5 AdMob disclosure).
- **Screenshots**: required sizes — 6.9" (iPhone 16 Pro Max) and 6.5" (iPhone 14 Plus). Add 12.9" iPad if supporting iPad. Use the simulator: `⌘ + S` saves a screenshot.
- **Description & Keywords**: write these for App Store search — include "hyrox", "workout tracker", "race prep", "running".

### 13.3 Build and archive

Bump version and build number in `apps/mobile/pubspec.yaml`:

```yaml
version: 1.0.0+1   # format: version+buildNumber
```

Build the IPA:

```bash
cd apps/mobile
flutter build ipa --release \
  --dart-define=API_BASE_URL=https://your-api.com \
  --dart-define=ADMOB_IOS_BANNER_STATION=ca-app-pub-XXXX/YYYY \
  --dart-define=ADMOB_IOS_REWARDED_SAVE=ca-app-pub-XXXX/YYYY \
  --dart-define=ADMOB_IOS_BANNER_FRIENDS=ca-app-pub-XXXX/YYYY
```

The IPA is written to `build/ios/ipa/`.

### 13.4 Upload the build

**Option A — Transporter (easiest)**

1. Download [Transporter](https://apps.apple.com/app/transporter/id1450874784) from the Mac App Store.
2. Sign in with your Apple ID.
3. Drag the `.ipa` file into Transporter → **Deliver**.

**Option B — xcrun altool (CLI)**

```bash
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/hyrox_tracker.ipa \
  --apiKey YOUR_KEY_ID \
  --apiIssuer YOUR_ISSUER_ID \
  --apiKey-path ~/private_keys/AuthKey_KEYID.p8
```

Get `KEY_ID` and `ISSUER_ID` from App Store Connect → Users → Integrations → Keys.

Wait ~5 minutes for the build to process, then it appears under **TestFlight** and **App Store** in App Store Connect.

### 13.5 AdMob disclosure (required)

Apple will reject the app if you skip this.

App Store Connect → your app → **App Privacy** → Data collected:

| Data type | Collected | Used for |
|-----------|-----------|---------|
| Advertising Data | Yes | Third-Party Advertising |
| Device ID | Yes | Third-Party Advertising |
| Usage Data | Yes | Analytics, Third-Party Advertising |
| Coarse Location | Yes (if ATT granted) | Third-Party Advertising |

### 13.6 App Tracking Transparency (ATT)

Required for personalised ads (significantly higher CPM). Add to `Info.plist`:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>We use this to show you relevant ads and keep the app free.</string>
```

And request permission early in `main()` (after `AdService.initialise()`):

```dart
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

await AppTrackingTransparency.requestTrackingAuthorization();
```

Add to `pubspec.yaml`:

```yaml
app_tracking_transparency: ^3.0.4
```

Without consent, AdMob shows non-personalised ads (lower CPM but still earns revenue).

### 13.7 Submit for review

1. In App Store Connect → your app → **App Store** tab → select your build.
2. Fill in **Review Information**:
   - Demo account credentials (create a test account on your API).
   - Contact info.
   - Notes: explain the rewarded ad gate ("Users must watch a short ad to save their workout — this is intentional and disclosed").
3. Click **Submit for Review**.

Review usually takes 24–48 hours. Apple may ask clarifying questions about the ad placement or Sign In with Apple usage — answer promptly.

### 13.8 Pre-submission checklist

- [ ] Version + build number bumped in `pubspec.yaml`
- [ ] Real AdMob App ID in `Info.plist`
- [ ] Real ad unit IDs in build command (never hardcoded in source)
- [ ] JWT key is ≥ 32 random chars (not the placeholder from `appsettings.json`)
- [ ] Apple Sign-In bundle ID matches Xcode exactly
- [ ] `GoogleService-Info.plist` added to Xcode target and committed
- [ ] API deployed, `/health` returns 200, migrations applied
- [ ] App Privacy label completed in App Store Connect
- [ ] ATT prompt added to `Info.plist` and `main()`
- [ ] Screenshots uploaded (6.9" and 6.5" minimum)
- [ ] App description, keywords, and category filled
- [ ] Review notes written explaining the rewarded-ad save gate
- [ ] Demo account credentials ready for the reviewer

---

## 14. Revenue Optimisation Tips

### Ad placement strategy (already implemented)

| Placement | Type | Why it works |
|-----------|------|-------------|
| **Station exercise** | Banner | User is mid-exercise, phone face-up but untouched. 60–90 second dwell time per station × 8 stations = strong session CPM |
| **Workout save gate** | Rewarded | 100% view-through rate. Rewarded ads pay 3–10× more than banners ($10–30 CPM vs $1–3). Users accept it because the value exchange is clear |
| **Friends / Find tab** | 2× Banner | Social browsing = high session frequency, idle scroll time |

### Increasing fill rate and CPM

1. **Enable mediation** in AdMob — add Meta Audience Network, AppLovin, Unity Ads as bidders. Mediation can increase CPM by 40–80%.
2. **Enable adaptive banners** — replace `AdSize.banner` with `AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width)` for ~15% higher CPM.
3. **Target fitness keywords** — in AdMob → Ad sources, ensure "Sports & Fitness" category ads are allowed. Your audience commands premium rates.
4. **Geography** — US/UK/AU/DE users generate 5–10× higher CPM than other regions. Consider a premium tier for those markets.

### Freemium upgrade path (future)

Consider a **Hyrox Pro** in-app purchase (~$4.99/mo or $29.99/yr) that:
- Removes all ads
- Unlocks unlimited friend comparisons
- Enables workout export (CSV/GPX)

Use `in_app_purchase` Flutter package. Users who convert to Pro have higher LTV than pure ad-supported users.

### AdMob policy compliance

- Never click your own ads.
- Never incentivise clicks (only views — which is what rewarded ads do correctly).
- Never place banners too close to interactive elements (keep ≥ 8dp margin from buttons).
- The station banner placement is clean — user cannot accidentally tap it during a workout.
