# Auth Web Legal Pages

This document is for the web developer working on `https://bicount.levelingcoder.com`.

The mobile auth screen now links directly to three legal pages hosted on the Bicount website.

## Required Pages

Create these public pages:

- `https://bicount.levelingcoder.com/consumer-terms`
- `https://bicount.levelingcoder.com/usage-policy`
- `https://bicount.levelingcoder.com/privacy-policy`

## Purpose

These pages are linked from the mobile auth flow in the same spirit as modern apps such as Claude:

- user sees legal references directly on the auth screen
- the links open the website pages externally

## Content Expectations

Each page should:

- be publicly accessible without login
- load correctly on mobile first
- have a clear title and readable long-form layout
- use the Bicount brand and visual style
- include a last-updated date

## Navigation Recommendation

At minimum, each page should include:

- Bicount logo or brand mark
- page title
- readable article content width
- footer link back to the main landing page

## SEO And Sharing

Recommended:

- unique page title
- meta description
- canonical URL
- Open Graph tags

## Stability Requirements

Do not change these final public paths without coordinating with the mobile app:

- `/consumer-terms`
- `/usage-policy`
- `/privacy-policy`

The Flutter app uses these exact URLs for the auth legal links.

## Important Auth Path Reservation

The mobile app also uses this path for auth provider return flows:

- `https://bicount.levelingcoder.com/auth`

Please keep this path reserved for the mobile callback flow.
Do not reuse or redirect it without coordinating with the mobile app and backend configuration.
