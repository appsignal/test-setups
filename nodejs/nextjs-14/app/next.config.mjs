/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    // Add the following line inside the object
    instrumentationHook: true,
    serverComponentsExternalPackages: ['@appsignal/nodejs'],
  },
};

export default nextConfig;
