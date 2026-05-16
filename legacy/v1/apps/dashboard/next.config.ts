import type { NextConfig } from 'next';

const config: NextConfig = {
  reactStrictMode: true,
  // Workspace packages need transpilation — Turbopack doesn't follow symlinks
  // through pnpm's hoisted node_modules without this hint.
  transpilePackages: [
    '@intelforce/db',
    '@intelforce/trpc',
    '@intelforce/schemas',
    '@intelforce/ui',
    '@cosmograph/cosmograph',
    '@cosmograph/react',
  ],
  // @prisma/client + the engine binary stay external (they can't be bundled).
  serverExternalPackages: ['@prisma/client', '@prisma/engines', '.prisma/client'],
};

export default config;
