# Bicount Invite Link Web Instructions

This document is for the web developer working on `https://bicount.levelingcoder.com`.

Its goal is to make Bicount invite links open the mobile app correctly on Android and iOS when possible, while keeping `/friend/invite` as a safe web fallback page.

Reference date:
- 2026-03-31

## Current Diagnosis

The mobile app is already configured to handle:
- `https://bicount.levelingcoder.com/friend/invite?code=<invite_code>` on Android
- `https://bicount.levelingcoder.com/friend/invite?code=<invite_code>` on iOS

The current web-side blockers are:

1. Android app-link verification only works if the deployed `/.well-known/assetlinks.json` uses the exact fingerprint of the installed app.
2. iOS universal links are currently blocked because `public/.well-known/apple-app-site-association` still contains the placeholder `REPLACE_WITH_APPLE_TEAM_ID`.
3. The public production domain returned `404` for both `/.well-known/assetlinks.json` and `/.well-known/apple-app-site-association` during verification on 2026-04-01, even though those files exist in the website repository and in `dist/.well-known`.
4. The website deployment workflow was uploading the `dist` artifact without hidden files, which drops the `.well-known` directory before the FTP deploy step.
5. The fallback page `/friend/invite` currently shows the invite code, but it does not itself force-open the app.

Important product note:
- if the user already landed inside the browser on `/friend/invite`, the website alone cannot reliably force Safari or Chrome to reopen the app through the same universal link
- the normal expected behavior is that the first tap from Messages, WhatsApp, Gmail, Telegram, etc. opens the app directly once domain association is valid
- if product later wants a real `Open in Bicount` fallback button from the webpage itself, mobile will also need a dedicated custom URI scheme, not only universal/app links

## Mobile Contract

The app expects:
- domain: `https://bicount.levelingcoder.com`
- invite route: `/friend/invite`
- query parameter: `code`

Examples:
- `https://bicount.levelingcoder.com/friend/invite?code=test123`

Android package name:
- `com.youngsolver.bicount`

iOS bundle identifier:
- `com.youngsolver.bicount`

## Android Requirements

### 1. Publish `assetlinks.json`

Deploy this file exactly at:
- `https://bicount.levelingcoder.com/.well-known/assetlinks.json`

Use this exact content for the current mobile build:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.youngsolver.bicount",
      "sha256_cert_fingerprints": [
        "CE:C4:26:D1:E3:78:1C:18:5C:B8:51:04:E3:84:53:7B:5A:50:0F:D2:BE:A1:6C:22:49:09:B0:E4:E7:AE:7D:5A"
      ]
    }
  }
]
```

Important note:
- the current Android project uses the debug signing key even for `release`
- this is confirmed by `android/app/build.gradle.kts`, where `release` uses `signingConfigs.getByName("debug")`
- therefore the fingerprint above is the correct SHA-256 for the currently built app

Reference values for the current signing key:
- SHA-256: `CE:C4:26:D1:E3:78:1C:18:5C:B8:51:04:E3:84:53:7B:5A:50:0F:D2:BE:A1:6C:22:49:09:B0:E4:E7:AE:7D:5A`
- SHA-1: `49:61:52:B5:3C:EB:1A:D0:97:73:95:AD:13:41:61:9A:02:D8:B4:57`

### 2. Delivery rules for `assetlinks.json`

The file must:
- be reachable with HTTP `200`
- be served directly on the final URL
- have no redirect
- keep the JSON body unchanged
- ideally be served with `application/json`

Do not:
- redirect `/.well-known/assetlinks.json`
- inject HTML
- protect it behind auth

## iOS Requirements

### 1. Publish `apple-app-site-association`

Deploy this file exactly at:
- `https://bicount.levelingcoder.com/.well-known/apple-app-site-association`

Current problem:
- the repository still contains a placeholder Apple Team ID
- this file will not work until that placeholder is replaced

Current invalid value:
- `REPLACE_WITH_APPLE_TEAM_ID.com.youngsolver.bicount`

The web developer must replace `REPLACE_WITH_APPLE_TEAM_ID` with the real Apple Developer Team ID from the iOS owner.

Expected structure:

```json
{
  "applinks": {
    "details": [
      {
        "appIDs": ["REAL_APPLE_TEAM_ID.com.youngsolver.bicount"],
        "components": [
          {
            "/": "/friend/invite",
            "?": {
              "code": "*"
            }
          }
        ]
      }
    ]
  }
}
```

### 2. Delivery rules for `apple-app-site-association`

The file must:
- be reachable with HTTP `200`
- be served directly on the final URL
- have no redirect
- not use a `.json` extension
- be served as `application/json` or `application/pkcs7-mime`

## Invite Page Requirements

The public fallback page is:
- `https://bicount.levelingcoder.com/friend/invite?code=<invite_code>`

What the page should do:
- stay public
- stay `noindex`
- preserve the `code` query parameter
- render a lightweight fallback experience if the app did not open
- show the invite code clearly
- provide a download CTA

What the page should not do:
- remove the `code` query parameter
- redirect to a different domain
- force a generic homepage redirect

## Important Limitation To Understand

The web page cannot by itself guarantee that a user who is already inside Safari/Chrome on `/friend/invite` will jump back into the app.

What should work once domain association is correct:
- tapping the invite link from an external app should open Bicount directly

What is not guaranteed with the current mobile contract:
- landing on the website first and then having the website forcibly reopen Bicount

If product wants that later, mobile must add a custom scheme like:
- `bicount://friend/invite?code=...`

Then the web fallback page could expose a true `Open Bicount` button.

For now, the correct web mission is:
- fix domain association
- keep `/friend/invite` as a clean fallback page

## Deployment Checklist

Important deployment fix already applied in the website repository:
- `.github/workflows/ci-cd.yml` now sets `include-hidden-files: true` on `actions/upload-artifact@v4`
- this is required because `.well-known` is a hidden directory and was previously missing from the uploaded artifact
- without this flag, the FTP deploy step publishes the site without `assetlinks.json` and `apple-app-site-association`

The web developer should verify all of these after deployment:

1. `https://bicount.levelingcoder.com/.well-known/assetlinks.json` returns `200` with the exact JSON above.
2. `https://bicount.levelingcoder.com/.well-known/apple-app-site-association` returns `200` without redirect.
3. `/friend/invite?code=test123` keeps the query parameter and renders the fallback page.
4. No CDN, framework, or hosting rule rewrites the `.well-known` files into HTML.
5. No redirect strips `?code=...`.

## Real-Device QA

### Android

Test on a device with the currently signed Bicount app installed:

1. Install the current Android build.
2. Tap an invite link from an external app such as WhatsApp, Gmail, Telegram, or Notes.
3. Expected result: Bicount opens directly on the invite flow.

If it still opens only the website:
- check that the deployed `assetlinks.json` matches the SHA-256 above exactly
- check that the server does not redirect the `.well-known` URL
- check that the installed APK is signed with the same key as the fingerprint above

### iOS

1. Replace the Apple Team ID placeholder.
2. Deploy `apple-app-site-association`.
3. Install the app on a real iPhone.
4. Tap the invite link from an external app.
5. Expected result: Bicount opens directly.

If it still opens only Safari:
- verify the Apple Team ID is correct
- verify the entitlements in the app still target `applinks:bicount.levelingcoder.com`
- verify the `.well-known/apple-app-site-association` response has no redirect

## Short Action List For The Web Developer

Do these in order:

1. Deploy the exact Android `assetlinks.json` shown in this document.
2. Replace the placeholder Apple Team ID in `apple-app-site-association`.
3. Deploy the corrected iOS file with no redirect.
4. Keep `/friend/invite` as a fallback page and preserve `?code=...`.
5. Test from a real message app, not only by pasting the link in the browser address bar.

## Source Of Truth

These app-side files currently define the mobile contract:
- [app_config.dart](/C:/Users/louis/Documents/Projet/Young%20solver/IA%20-%20Sandox/bicount_proj/lib/core/constants/app_config.dart)
- [AndroidManifest.xml](/C:/Users/louis/Documents/Projet/Young%20solver/IA%20-%20Sandox/bicount_proj/android/app/src/main/AndroidManifest.xml)
- [Runner.entitlements](/C:/Users/louis/Documents/Projet/Young%20solver/IA%20-%20Sandox/bicount_proj/ios/Runner/Runner.entitlements)
- [build.gradle.kts](/C:/Users/louis/Documents/Projet/Young%20solver/IA%20-%20Sandox/bicount_proj/android/app/build.gradle.kts)
