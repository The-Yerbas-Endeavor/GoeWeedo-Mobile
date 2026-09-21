# GeoWeedo Mobile

Dedicated Android and iOS application repository for [GeoWeedo](https://geoweedo.com).

## Architecture

This repository contains the native mobile shell, Capacitor configuration, native platform bootstrap/configuration, and mobile CI/release workflows.

The production website and backend remain in `The-Yerbas-Endeavor/GeoWeedo`. GeoWeedo Mobile loads the canonical production application at `https://geoweedo.com` and adds native device capabilities where they provide real value.

### Mobile responsibilities

- Android and iOS native projects
- Capacitor configuration and plugins
- Camera / barcode / QR scanning
- Native geolocation
- Haptics
- Share sheet
- Network/offline integration
- App icons and store assets
- Android APK/AAB builds
- iOS simulator/App Store builds
- Play Store / App Store release tooling

### Web responsibilities

The `GeoWeedo` web repository remains authoritative for accounts, gameplay, dispensaries, maps, sponsorships, Weedo Facts data, product/COA records, admin tools, APIs, and production SQLite state.

That also includes the shared product system used by dispensary menus:

- canonical GeoWeedo Products
- canonical Product Categories
- dispensary Menu category grouping
- product-to-menu linking
- product search and category-aware dispensary search
- GeoWeedo Facts product and batch detail pages

The mobile apps do **not** duplicate that taxonomy or menu database. Android and iOS render the live canonical experience from `https://geoweedo.com`, while native code remains focused on device capabilities.

## Cross-repository compatibility contract

`The-Yerbas-Endeavor/GeoWeedo` is the source of truth for web UI, APIs, products, categories, menus, accounts, gameplay, and data.

`The-Yerbas-Endeavor/GoeWeedo-Mobile` is the source of truth for Android/iOS packaging, Capacitor, native plugins, permissions, store builds, and native scanner/device integration.

Current mobile web origin:

```text
https://geoweedo.com
```

Current mobile build line: `0.4.2`.

Current canonical GeoWeedo web revision: `83f895b98452e986c543ea0f600a9ccb8bb12a34` (2026-09-21).

When GeoWeedo web-only behavior changes, such as product categories or dispensary menu presentation, the mobile apps receive that behavior from the live production site and should not copy the same business logic into this repository. A mobile release bump is still useful when we want fresh APK/AAB/iOS artifacts that explicitly represent the current production web contract.

## Application identity

- App name: `GeoWeedo`
- Android package / iOS bundle ID: `com.geoweedo.app`
- Production URL: `https://geoweedo.com`
- Android distribution: Google Play
- iOS distribution: Apple App Store

## Repository rule

Do not use the production `/home/geo/GeoWeedo` checkout for mobile feature development or native platform generation. Mobile work belongs in this repository.
