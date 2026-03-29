# Auth Backend Actions

This document describes the backend work required for Bicount's new modern auth flow.

## Product Direction

The mobile app no longer exposes separate public onboarding, login, and signup screens.

Public auth flow is now:

- one unified `Auth` entry screen
- Google sign-in
- Apple sign-in on Apple devices
- email OTP flow
- one email code confirmation screen

Important:

- Google auth already works and must remain stable
- email auth is now passwordless
- users should not choose between "log in" and "sign up"
- the backend should allow the same email flow to handle both returning and first-time users

## Supabase Auth Requirements

Enable and verify these providers in Supabase Auth:

- Google
- Apple
- Email OTP

## Email OTP

Expected app behavior:

- user enters an email
- app calls `signInWithOtp`
- user receives a one-time code by email
- user enters that code in the app
- app verifies with `verifyOTP`

Backend requirements:

- email auth provider enabled
- OTP/code-based email template configured
- the email content must clearly expose the one-time code to the user
- first-time users must be allowed through the same OTP flow

Recommended settings:

- allow automatic user creation during OTP sign-in
- keep OTP expiration short and secure
- rate-limit repeated OTP requests

## Apple Sign-In

The Flutter app uses Apple auth on Apple devices.

Backend requirements in Supabase:

- enable Apple provider
- configure the Apple client details in Supabase Auth
- configure the Apple team/app identifiers required by Supabase
- add `https://bicount.levelingcoder.com/auth` to the allowed redirect URLs
- keep the app-links and universal-links setup valid for that auth return path

Expected app behavior:

- on iOS or macOS, the app starts the Apple OAuth flow through Supabase
- Supabase redirects back to `https://bicount.levelingcoder.com/auth`
- if the app is installed, that link should reopen Bicount and complete the session

## Users Table

The mobile app still needs a usable row in `public.users`.

Current frontend behavior:

- after successful email OTP verification, the app checks whether the current user already exists in `public.users`
- if no row is found, the app creates a default profile row locally and syncs it

Backend recommendation:

- keep `public.users` insert/update policies compatible with this flow
- authenticated users must be allowed to insert their own row if it does not exist yet
- authenticated users must be allowed to read and update only their own row

## RLS Guidance

For `public.users`:

- `select`: authenticated user can read their own row
- `insert`: authenticated user can insert their own row
- `update`: authenticated user can update their own row
- no user can read or edit another user's row

## Email Templates

The new auth UX assumes the email template matches a code-entry flow.

Template expectations:

- clear one-time code
- concise copy
- Bicount branding
- short validity window

The app UI no longer assumes password creation during entry auth.

## Redirect And Callback Notes

This new flow does not depend on the old onboarding/login/signup public screens.

If Supabase Auth settings still reference older landing assumptions, update them to match the new auth entry at the app level.

Important callback expectations:

- keep `https://bicount.levelingcoder.com/auth` reserved for the mobile auth return flow
- do not break the domain-level app-links configuration for `/auth`
- if the web team later creates a landing auth page, coordinate first because the mobile callback depends on this exact public path

## Final Check

Before QA, confirm:

- Google sign-in still works
- Apple sign-in works on Apple devices
- email OTP arrives reliably
- OTP verification creates a valid session
- first-time OTP users can get a usable `users` row
