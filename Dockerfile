/*
Changelog - Dockerfile

[Initial]
- ARM64 base image for Raspberry Pi 3/4/5 compatibility
- Direwolf APRS software installation and configuration
- GPS daemon (gpsd) support for position tracking
- RTL-SDR tools for software-defined radio operations
- Audio system libraries for soundcard interface support
- Environment variable configuration for callsign and location
- Automatic service startup with health monitoring

[Purpose]
- Provides containerized APRS and beacon functionality
- Supports multiple hardware interfaces (RTL-SDR, GPS, audio)
- Enables consistent deployment across different Pi configurations
- Designed for Leeds Space Comms club operations and educational use
*/

# Use ARM64 base image optimized for Raspberry Pi
FROM arm64v8/debian:bullseye-slim

# Set maintainer information
LABEL maintainer="Leeds Space Comms <info@leedsspace.com>"
LABEL description="Dockerized APRS & Beacon System for Raspberry Pi"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install core dependencies
RUN apt-get update && apt-get install -y \
    # Core system utilities
    curl \
    wget \
    git \
    build-essential \
    cmake \
    # Audio system support
    alsa-utils \
    libasound2-dev \
    # GPS daemon and utilities
    gpsd \
    gpsd-clients \
    # RTL-SDR software defined radio
    rtl-sdr \
    librtlsdr-dev \
    # Direwolf APRS software dependencies
    direwolf \
    # Network and USB utilities
    usbutils \
    # Cleanup package cache
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create application directory structure
RUN mkdir -p /app/config /app/scripts /app/logs /app/data

# Set working directory
WORKDIR /app

# Copy configuration files
COPY config/ /app/config/
COPY scripts/ /app/scripts/

# Make scripts executable
RUN chmod +x /app/scripts/*.sh

# Create non-root user for security
RUN useradd -m -s /bin/bash aprs && \
    usermod -aG audio,dialout aprs && \
    chown -R aprs:aprs /app

# Switch to non-root user
USER aprs

# Expose APRS and monitoring ports
EXPOSE 14580 8000 8001

# Health check for service monitoring
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD pgrep -f direwolf || exit 1

# Default environment variables (override in docker-compose.yml)
ENV CALLSIGN="N0CALL" \
    APRS_PASS="00000" \
    LAT="53.8008" \
    LON="-1.5491" \
    BEACON_MESSAGE="Leeds Space Comms APRS Node" \
    BEACON_INTERVAL="600"

# Start the APRS system
CMD ["/app/scripts/start.sh"]
