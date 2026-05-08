# ---------- Build stage ----------
FROM node:20-alpine AS build

WORKDIR /app

# Install deps separately for better layer caching
COPY package*.json ./
RUN npm ci --omit=dev

# ---------- Runtime stage ----------
FROM node:20-alpine AS runtime

# Run as non-root for security
RUN addgroup -S app && adduser -S app -G app

WORKDIR /app

ENV NODE_ENV=production \
    PORT=8000

# Copy production node_modules from build stage
COPY --from=build /app/node_modules ./node_modules

# Copy source
COPY package*.json ./
COPY index.js ./
COPY src ./src

# Drop privileges
USER app

EXPOSE 8000

# Basic container healthcheck against the existing /api/health route
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8000/api/health || exit 1

CMD ["node", "index.js"]
