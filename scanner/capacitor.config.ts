const config = {
  appId: 'com.geoweedo.scanner',
  appName: 'GeoWeedo Scanner',
  webDir: 'mobile-shell',
  server: {
    url: 'https://geoweedo.com/facts',
    cleartext: false,
    errorPath: 'index.html',
  },
  android: { allowMixedContent: false },
  ios: { contentInset: 'automatic' },
};

export default config;
