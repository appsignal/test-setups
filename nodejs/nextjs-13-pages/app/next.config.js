/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  experimental: {
    instrumentationHook: true,
  },
  webpack: (config, {isServer}) => {
    if (isServer) {
      config.devtool = 'eval-source-map'
    }
    return config
  }
}

module.exports = nextConfig
