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

## Application identity

- App name: `GeoWeedo`
- Android package / iOS bundle ID: `com.geoweedo.app`
- Production URL: `https://geoweedo.com`
- Android distribution: Google Play
- iOS distribution: Apple App Store

## Repository rule

Do not use the production `/home/geo/GeoWeedo` checkout for mobile feature development or native platform generation. Mobile work belongs in this repository.
