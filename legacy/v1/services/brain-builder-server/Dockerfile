FROM node:22-slim

WORKDIR /app

# pnpm
RUN corepack enable && corepack prepare pnpm@9 --activate

# Workspace install — needs root package.json + lockfile + workspace globs.
# brain-builder-server's only workspace dep is @intelforce/db; we copy the
# packages dir so pnpm can resolve it.
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
COPY packages ./packages
COPY services/brain-builder-server ./services/brain-builder-server

# install + generate prisma client + build the server. We must `prisma generate`
# inside the container so the client matches the runtime architecture.
RUN pnpm install --frozen-lockfile --filter "@intelforce/brain-builder-server..."
RUN cd packages/db && pnpm exec prisma generate
RUN pnpm --filter @intelforce/brain-builder-server build

EXPOSE 8090
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8090/health || exit 1

CMD ["node", "services/brain-builder-server/dist/server.js"]
