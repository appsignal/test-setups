/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    // Add the following line inside the object
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
