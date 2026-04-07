# Hyrox — Production Setup Guide

Everything you need to go from this repo to a live, monetised app on the App Store with real users.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [AdMob — Ads Setup](#2-admob--ads-setup)
3. [Apple Sign-In](#3-apple-sign-in)
4. [Google Sign-In](#4-google-sign-in)
5. [Backend API — Production Deployment](#5-backend-api--production-deployment)
6. [Flutter Build — Environment Variables](#6-flutter-build--environment-variables)
7. [iOS — Signing & Provisioning](#7-ios--signing--provisioning)
8. [Testing on Your Physical Devices](#8-testing-on-your-physical-devices)
9. [TestFlight Beta](#9-testflight-beta)
10. [App Store Submission](#10-app-store-submission)
11. [Revenue Optimisation Tips](#11-revenue-optimisation-tips)

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

## 2. AdMob — Ads Setup

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

## 3. Apple Sign-In

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

## 4. Google Sign-In

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

## 5. Backend API — Production Deployment

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

## 6. Flutter Build — Environment Variables

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

## 7. iOS — Signing & Provisioning

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

## 8. Testing on Your Physical Devices

### 8.1 Register device in Apple Developer

1. Connect device → Xcode identifies UDID automatically.
2. Apple Developer → Devices → Register Device.

### 8.2 Run directly

```bash
flutter devices                          # find your device ID
flutter run -d <your-device-id>          # debug build, hot reload works
```

### 8.3 Test the full ad flow

- Station banner: start a workout, advance past the first run to a station.
- Rewarded ad gate: complete a workout (advance through all exercises).
- Friends banners: sign in, open the Friends screen.

Google test ads will appear automatically in debug mode. They look like real ads but never generate revenue.

### 8.4 Test auth flows

Apple Sign-In only works on a real device (not simulator). Google Sign-In works on both.

---

## 9. TestFlight Beta

### 9.1 Archive the app

```bash
flutter build ipa \
  --dart-define=API_BASE_URL=https://your-api.com \
  --dart-define=ADMOB_IOS_BANNER_STATION=ca-app-pub-XXX/YYY \
  --dart-define=ADMOB_IOS_REWARDED_SAVE=ca-app-pub-XXX/YYY \
  --dart-define=ADMOB_IOS_BANNER_FRIENDS=ca-app-pub-XXX/YYY
```

The `.ipa` is output to `build/ios/ipa/`.

### 9.2 Upload to App Store Connect

```bash
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/hyrox_tracker.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

Or drag the `.ipa` into **Transporter** (Mac App Store).

### 9.3 Add testers

App Store Connect → TestFlight → Add Internal / External Testers → send invite link.

External testers (up to 10,000) require Apple review (usually < 24 hours for TestFlight).

---

## 10. App Store Submission

### 10.1 AdMob disclosure

Apple requires you to disclose ad tracking in the Privacy Nutrition Label:

- App Store Connect → App Privacy → Data collected: **Advertising Data**, **Identifiers**, **Usage Data**.
- Select: "Used for Third-Party Advertising".

### 10.2 App Tracking Transparency (ATT)

For personalised ads (higher CPM), add ATT prompt. Add to `Info.plist`:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>We use this to show you relevant ads and keep the app free.</string>
```

And request permission in `main()`:

```dart
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

final status = await AppTrackingTransparency.requestTrackingAuthorization();
```

Add `app_tracking_transparency: ^3.0.4` to `pubspec.yaml`.

Without ATT consent, AdMob shows non-personalised ads (lower CPM but still significant revenue).

### 10.3 Checklist before submitting

- [ ] Real AdMob App ID in `Info.plist`
- [ ] Real ad unit IDs passed via `--dart-define`
- [ ] JWT key is ≥ 32 random chars, not the placeholder
- [ ] Apple Sign-In bundle ID matches exactly
- [ ] `GoogleService-Info.plist` added to Xcode target
- [ ] API deployed and `/health` returns 200
- [ ] App Privacy label filled in App Store Connect
- [ ] ATT prompt added (optional but recommended)
- [ ] Version and build number bumped in `pubspec.yaml`

---

## 11. Revenue Optimisation Tips

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
