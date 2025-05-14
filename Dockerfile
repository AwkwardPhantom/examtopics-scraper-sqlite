# syntax=docker/dockerfile:1.4

FROM --platform=$BUILDPLATFORM node:20-slim AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "Building on $BUILDPLATFORM for $TARGETPLATFORM"

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssl \
    && rm -rf /var/lib/apt/lists/*

ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm install -g npm@latest && \
    npm config set fund false && \
    npm config set update-notifier false

# Copy npm package dep list
COPY package*.json ./

# Install deps with strict versioning
RUN npm ci --no-audit --no-fund

# Copy source
COPY . .

# Prepare prisma client and init db
RUN npx prisma generate
RUN npx prisma db push
RUN npx prisma db seed

# Build
RUN npm run build


# Runtime
FROM --platform=$TARGETPLATFORM node:20-slim AS runner

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tini \
    curl \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy only production files from builder
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.env ./.env
COPY package.json ./
COPY prisma ./prisma
RUN echo "NEXTAUTH_SECRET=dummy-secret-value" > .env


ENV HOST=0.0.0.0 \
    PORT=3000 \
    NODE_ENV=production \
    TINI_SUBREAPER=true

EXPOSE 3000

ENTRYPOINT ["/usr/bin/tini", "-s", "--"]
CMD ["npm", "run", "start"]
