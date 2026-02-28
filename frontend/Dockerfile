FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package.json
COPY package-lock.json package-lock.json
COPY apps/web/package.json apps/web/package.json
COPY packages/ui/package.json packages/ui/package.json
COPY packages/api/package.json packages/api/package.json
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules node_modules
COPY . .
RUN mkdir -p /app/apps/web/public
RUN npm run build --workspace @gmp/web

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
COPY --from=builder /app/apps/web/.next/standalone ./
COPY --from=builder /app/apps/web/.next/static ./apps/web/.next/static
COPY --from=builder /app/apps/web/public ./apps/web/public
EXPOSE 3000
CMD ["node", "apps/web/server.js"]
