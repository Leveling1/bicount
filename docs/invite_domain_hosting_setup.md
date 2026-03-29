# Bicount Invite Domain Hosting Setup

This document explains what must be hosted on `https://bicount.levelingcoder.com` so Bicount invite links work correctly on Android and iOS.

## App Contract

The mobile app now uses:

- base domain: `https://bicount.levelingcoder.com`
- invite route: `/friend/invite?code=<invite_code>`

Mobile identifiers:

- Android package name: `com.youngsolver.bicount`
- iOS bundle identifier: `com.youngsolver.bicount`

## What The Website Must Serve

### 1. HTTPS

The domain must be publicly reachable in HTTPS with a valid certificate.

### 2. Android file

Publish this file exactly at:

- `https://bicount.levelingcoder.com/.well-known/assetlinks.json`

Template:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.youngsolver.bicount",
      "sha256_cert_fingerprints": [
        "REPLACE_WITH_RELEASE_SHA256_FINGERPRINT"
      ]
    }
  }
]
```

Notes:

- use the SHA-256 fingerprint of the signing certificate used to distribute the Android app
- if you also want debug/emulator verification, you can temporarily add the debug fingerprint as a second value
- serve the file as JSON without redirects on the final URL

### 3. iOS file

Publish this file exactly at:

- `https://bicount.levelingcoder.com/.well-known/apple-app-site-association`

Template:

```json
{
  "applinks": {
    "details": [
      {
        "appIDs": ["REPLACE_WITH_APPLE_TEAM_ID.com.youngsolver.bicount"],
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

Notes:

- replace `REPLACE_WITH_APPLE_TEAM_ID` with the real Apple Developer Team ID
- do not add a `.json` extension to this file
- serve it as `application/json` or `application/pkcs7-mime`
- avoid redirects here as well

### 4. Fallback page

Recommended:

- serve a normal web page on `/friend/invite`
- if the app is not installed, show a simple landing page explaining that the invite should be opened in Bicount
- you can also add store links there later

## Server Checklist

- the domain points to your hosting
- HTTPS works
- `/.well-known/assetlinks.json` is reachable
- `/.well-known/apple-app-site-association` is reachable
- `/friend/invite?code=test123` returns a valid page or app-link response
- no forced redirect removes the query parameter `code`

## Quick Verification

After deployment, verify manually:

- open `https://bicount.levelingcoder.com/.well-known/assetlinks.json`
- open `https://bicount.levelingcoder.com/.well-known/apple-app-site-association`
- open `https://bicount.levelingcoder.com/friend/invite?code=test123`

If Android app links still do not verify, double-check the release SHA-256 fingerprint.
If iOS universal links still do not open the app, double-check the Apple Team ID and associated domains capability.
