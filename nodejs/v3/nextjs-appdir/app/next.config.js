/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    instrumentationHook: true,
    appDir: true,
  },
}

module.exports = nextConfig
