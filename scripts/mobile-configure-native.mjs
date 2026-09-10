#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';

const platform = process.argv[2];
const root = process.cwd();
const packageJson = JSON.parse(fs.readFileSync(path.join(root, 'package.json'), 'utf8'));
const appVersion = String(packageJson.version || '0.0.0');

function androidVersionCode(version) {
  const [major = 0, minor = 0, patch = 0] = version.split('.').map((part) => Number.parseInt(part, 10) || 0);
  return major * 10000 + minor * 100 + patch;
}

function replaceOrFail(file, matcher, replacement, label) {
  const original = fs.readFileSync(file, 'utf8');
  const updated = original.replace(matcher, replacement);
  if (updated === original) {
    if (original.includes(replacement)) return;
    throw new Error(`Could not configure ${label} in ${file}`);
  }
  fs.writeFileSync(file, updated);
}

function writeFileEnsured(file, content) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, content);
}

function configureAndroidLauncherIcon(manifest, mascotSource) {
  const resDir = path.join(root, 'android', 'app', 'src', 'main', 'res');
  const drawableDir = path.join(resDir, 'drawable-nodpi');
  const valuesDir = path.join(resDir, 'values');
  const adaptiveDir = path.join(resDir, 'mipmap-anydpi-v26');
  const mascotTarget = path.join(drawableDir, 'geoweedo_mascot.png');

  if (!fs.existsSync(mascotSource)) {
    console.warn('GeoWeedo mascot asset not found at assets/geoweedo-icon-master.png; keeping generated launcher icon.');
    return fs.readFileSync(manifest, 'utf8');
  }

  fs.mkdirSync(drawableDir, { recursive: true });
  fs.copyFileSync(mascotSource, mascotTarget);

  writeFileEnsured(
    path.join(valuesDir, 'geoweedo_launcher_colors.xml'),
    `<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="geoweedo_launcher_background">#0F1D14</color>\n</resources>\n`,
  );

  const adaptiveIcon = `<?xml version="1.0" encoding="utf-8"?>\n<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n    <background android:drawable="@color/geoweedo_launcher_background" />\n    <foreground>\n        <inset android:drawable="@drawable/geoweedo_mascot" android:inset="16%" />\n    </foreground>\n</adaptive-icon>\n`;

  writeFileEnsured(path.join(adaptiveDir, 'geoweedo_launcher.xml'), adaptiveIcon);
  writeFileEnsured(path.join(adaptiveDir, 'geoweedo_launcher_round.xml'), adaptiveIcon);

  let xml = fs.readFileSync(manifest, 'utf8');
  xml = xml
    .replace(/android:icon="@[^"]+"/, 'android:icon="@mipmap/geoweedo_launcher"')
    .replace(/android:roundIcon="@[^"]+"/, 'android:roundIcon="@mipmap/geoweedo_launcher_round"');

  console.log('Configured Android adaptive GeoWeedo mascot launcher icon');
  return xml;
}

function configureAndroid() {
  const variables = path.join(root, 'android', 'variables.gradle');
  const appGradle = path.join(root, 'android', 'app', 'build.gradle');
  const manifest = path.join(root, 'android', 'app', 'src', 'main', 'AndroidManifest.xml');
  const mascotSource = path.join(root, 'assets', 'geoweedo-icon-master.png');
  const versionCode = androidVersionCode(appVersion);

  replaceOrFail(
    variables,
    /minSdkVersion\s*=\s*\d+/,
    'minSdkVersion = 26',
    'Android minSdkVersion',
  );

  replaceOrFail(
    appGradle,
    /versionCode\s+\d+/,
    `versionCode ${versionCode}`,
    'Android versionCode',
  );
  replaceOrFail(
    appGradle,
    /versionName\s+["'][^"']+["']/,
    `versionName "${appVersion}"`,
    'Android versionName',
  );

  let xml = fs.readFileSync(manifest, 'utf8');
  const permissions = [
    'android.permission.ACCESS_COARSE_LOCATION',
    'android.permission.ACCESS_FINE_LOCATION',
    'android.permission.CAMERA',
  ];

  const missing = permissions.filter((permission) => !xml.includes(`android:name="${permission}"`));
  if (missing.length) {
    const block = missing
      .map((permission) => `    <uses-permission android:name="${permission}" />`)
      .join('\n');
    xml = xml.replace(/(<manifest\b[^>]*>)/, `$1\n${block}`);
    fs.writeFileSync(manifest, xml);
  }

  xml = configureAndroidLauncherIcon(manifest, mascotSource);
  fs.writeFileSync(manifest, xml);
  console.log(`Configured Android: GeoWeedo ${appVersion} (${versionCode}) + minSdk 26 + location/camera permissions`);
}

function plistEntry(key, value) {
  return `\t<key>${key}</key>\n\t<string>${value}</string>`;
}

function configureIos() {
  const plist = path.join(root, 'ios', 'App', 'App', 'Info.plist');
  const project = path.join(root, 'ios', 'App', 'App.xcodeproj', 'project.pbxproj');
  let xml = fs.readFileSync(plist, 'utf8');
  const entries = [
    [
      'NSLocationWhenInUseUsageDescription',
      'GeoWeedo uses your location to show nearby dispensaries and improve location-based game features.',
    ],
    [
      'NSLocationAlwaysAndWhenInUseUsageDescription',
      'GeoWeedo uses location while you are using the app for nearby dispensary and game features.',
    ],
    [
      'NSCameraUsageDescription',
      'GeoWeedo uses the camera to scan product barcodes and QR codes for Weedo Facts.',
    ],
  ];

  const missing = entries.filter(([key]) => !xml.includes(`<key>${key}</key>`));
  if (missing.length) {
    const block = missing.map(([key, value]) => plistEntry(key, value)).join('\n');
    xml = xml.replace(/\n<\/dict>\s*<\/plist>/, `\n${block}\n</dict>\n</plist>`);
    fs.writeFileSync(plist, xml);
  }

  if (fs.existsSync(project)) {
    let pbx = fs.readFileSync(project, 'utf8');
    pbx = pbx.replace(/MARKETING_VERSION = [^;]+;/g, `MARKETING_VERSION = ${appVersion};`);
    pbx = pbx.replace(/CURRENT_PROJECT_VERSION = \d+;/g, `CURRENT_PROJECT_VERSION = ${androidVersionCode(appVersion)};`);
    fs.writeFileSync(project, pbx);
  }

  console.log(`Configured iOS: GeoWeedo ${appVersion} + location/camera privacy descriptions`);
}

if (platform === 'android') {
  configureAndroid();
} else if (platform === 'ios') {
  configureIos();
} else {
  throw new Error('Usage: node scripts/mobile-configure-native.mjs [android|ios]');
}
