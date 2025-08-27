# --- Stage 1: Frontend Build ---
# Use a Node.js base image for building the React frontend.
FROM node:18-alpine as frontend-builder

# Set the working directory inside the container for the frontend project.
WORKDIR /app/frontend

# Copy package.json and package-lock.json (or yarn.lock) first.
# This allows Docker to cache the npm install step if these files don't change.
COPY frontend/package*.json ./

# Install frontend dependencies.
# --production=false ensures dev dependencies (like react-scripts) are installed,
# which are needed for the build process.
RUN npm install --production=false

# Copy the rest of the frontend source code.
COPY frontend .

# Build the React application.
# The output will typically be in a 'build' directory.
RUN npm run build

# --- Stage 2: Backend Build ---
# Use a Go base image for building the Go backend.
FROM golang:1.21-alpine as backend-builder

# Set the working directory inside the container for the backend project.
WORKDIR /app

# Copy go.mod and go.sum first to leverage Docker cache for module downloads.
COPY go.mod go.sum ./

# Download Go modules.
RUN go mod download

# Copy the rest of the Go source code.
# This includes main.go and the internal/ packages.
COPY . .

# Build the Go application.
# CGO_ENABLED=0 creates a statically linked binary, which is ideal for minimal base images.
# GOOS=linux ensures it's built for Linux.
# -a -installsuffix cgo ensures all packages are rebuilt from source and avoids issues with CGO.
# -o /app/loadbalancer specifies the output path and name for the executable.
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /app/loadbalancer main.go

# --- Stage 3: Final Image ---
# Use a minimal Alpine Linux base image for the final production image.
FROM alpine:3.18

# Install ca-certificates for secure HTTPS communication, essential for production.
RUN apk add --no-cache ca-certificates

# Set the working directory.
WORKDIR /app

# Copy the compiled Go binary from the backend-builder stage.
COPY --from=backend-builder /app/loadbalancer .

# Copy the built frontend static files from the frontend-builder stage.
# These files will be served by the Go application.
# Assuming 'npm run build' outputs to /app/frontend/build.
COPY --from=frontend-builder /app/frontend/build ./web

# Copy the configuration file for the load balancer.
COPY config/balancer.yaml ./config/balancer.yaml

# Expose the port on which the load balancer will listen.
EXPOSE 8080

# Set environment variables for runtime configuration.
# These can be overridden at runtime (e.g., with `docker run -e`).
ENV LB_PORT=8080
ENV LB_CONFIG_PATH=/app/config/balancer.yaml
# Example of cross-project context:
# Define URLs for other services this load balancer might interact with
# for service registration, health checks, or routing.
# This could include registry endpoints for an E-commerce Platform or Analytics Dashboard.
ENV SERVICE_DISCOVERY_PEER_URLS="http://ecommerce-platform-registry:8080/register,http://analytics-dashboard-registry:8080/register"
# Example for secure communication with other services, e.g., an API key for a backend service.
ENV BACKEND_SERVICE_API_KEY="your_secure_api_key_here"

# Set the entrypoint command to run the Go application.
ENTRYPOINT ["./loadbalancer"]