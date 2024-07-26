/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  experimental: {
    instrumentationHook: true,
    serverComponentsExternalPackages: ['@appsignal/nodejs'],
  },
  webpack: (config, {isServer}) => {
    if (isServer) {
      config.devtool = 'eval-source-map'
    }
    return config
  }
};

export default nextConfig;
