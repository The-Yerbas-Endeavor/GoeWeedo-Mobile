const config = {
  appId: 'com.geoweedo.app',
  appName: 'GeoWeedo',
  webDir: 'mobile-shell',
  server: {
    url: 'https://geoweedo.com',
    cleartext: false,
    errorPath: 'index.html',
  },
  android: {
    allowMixedContent: false,
  },
  ios: {
    contentInset: 'automatic',
  },
};

export default config;
