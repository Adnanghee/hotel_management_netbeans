# Multi-Stage Dockerfile for Grandeur Hotel Management System (PMS)

# --- Stage 1: Build Frontend ---
FROM node:22-alpine AS frontend-builder
WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm ci

COPY frontend/ ./
RUN npm run build

# --- Stage 2: Build Backend ---
FROM node:22-alpine AS backend-builder
WORKDIR /app/backend

COPY backend/package*.json ./
RUN npm ci

COPY backend/ ./
RUN npm run build

# --- Stage 3: Production Runner ---
FROM node:22-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=5000

# Copy backend dependencies and compiled files
COPY backend/package*.json ./backend/
RUN cd backend && npm ci --only=production

COPY --from=backend-builder /app/backend/dist ./backend/dist
COPY --from=frontend-builder /app/frontend/dist ./frontend/dist

# Expose port
EXPOSE 5000

# Volume for persistent SQLite database
VOLUME ["/app/backend/data"]

CMD ["node", "backend/dist/server.js"]

