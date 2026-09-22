const config = {
  appId: 'com.geoweedo.scanner',
  appName: 'GeoWeedo Scanner',
  webDir: 'mobile-shell',
  server: {
    url: 'https://geoweedo.com/facts',
    cleartext: false,
    allowNavigation: ['geoweedo.com', '*.geoweedo.com'],
  },
  android: { allowMixedContent: false },
  ios: { contentInset: 'automatic' },
};

export default config;
