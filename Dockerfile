# Base image for building the application
FROM node:22-alpine AS builder

WORKDIR /app

# Enable corepack for pnpm (or npm/yarn if preferred)
RUN corepack enable

# Copy package files
COPY package.json package-lock.json ./

# Install all dependencies (including dev for building)
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build the TanStack Start app
RUN npm run build

# Production image
FROM node:22-alpine AS runner

WORKDIR /app

# Set environment to production
ENV NODE_ENV=production
ENV PORT=3000

# Install production dependencies only (if needed for the server to run)
# For nitro with node-server preset, it bundles everything into .output/server,
# so usually we don't need node_modules in the runner, just the .output folder.
# We'll copy just what's needed.

# Copy the built nitro output
COPY --from=builder /app/.output ./.output

# Expose the port
EXPOSE 3000

# Start the nitro server
CMD ["node", ".output/server/index.mjs"]
