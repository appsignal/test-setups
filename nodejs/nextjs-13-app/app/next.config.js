/** @type {import('next').NextConfig} */
const nextConfig = {
  // Add the `experimental` object if not present
  experimental: {
    // Add the following line inside the object
    instrumentationHook: true,
  },
  webpack: (config, {isServer}) => {
    if (isServer) {
      config.devtool = 'eval-source-map'
    }
    return config
  }
};

module.exports = nextConfig
