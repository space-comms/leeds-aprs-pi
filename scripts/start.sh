#!/bin/bash

#
# Changelog - start.sh
#
# [Initial]
# - Main startup script for Leeds APRS Pi Docker container
# - GPS daemon initialization and configuration
# - RTL-SDR device detection and setup
# - Audio system configuration for soundcard interfaces
# - Direwolf APRS software startup with dynamic configuration
# - Environment variable validation and default settings
# - Hardware detection and adaptive configuration
# - Logging and monitoring setup
#
# [Purpose]
# - Provides unified startup sequence for all APRS services
# - Handles hardware detection and configuration automatically
# - Enables flexible deployment across different Pi configurations
# - Supports both development and production environments
#

set -e  # Exit on any error

# Color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Banner display
cat << 'EOF'
 _               _        _    ____  ____  ____      ____  _ 
| |   ___  ___  __| |___   / \  |  _ \|  _ \/ ___|    |  _ \(_)
| |  / _ \/ _ \/ _` / __| / _ \ | |_) | |_) \___ \    | |_) | |
| | |  __/  __/ (_| \__ \/ ___ \|  __/|  _ < ___) |___|  __/| |
|_|  \___|\___|\__,_|___/_/   \_\_|   |_| \_\____/_____|_|   |_|
                                                               
Leeds Space Comms - APRS & Beacon System
EOF

log "Starting Leeds APRS Pi system..."

# Validate required environment variables
if [ -z "$CALLSIGN" ] || [ "$CALLSIGN" == "N0CALL" ]; then
    error "CALLSIGN environment variable must be set to your amateur radio callsign"
    exit 1
fi

if [ -z "$APRS_PASS" ] || [ "$APRS_PASS" == "00000" ]; then
    error "APRS_PASS environment variable must be set to your APRS-IS passcode"
    exit 1
fi

# Set default values for optional variables
LAT=${LAT:-"53.8008"}
LON=${LON:-"-1.5491"}
BEACON_MESSAGE=${BEACON_MESSAGE:-"Leeds Space Comms APRS Node"}
BEACON_INTERVAL=${BEACON_INTERVAL:-"600"}
SYMBOL_TABLE=${SYMBOL_TABLE:-"/"}
SYMBOL_CODE=${SYMBOL_CODE:-"&"}

log "Configuration:"
log "  Callsign: $CALLSIGN"
log "  Location: $LAT, $LON"
log "  Beacon Message: $BEACON_MESSAGE"
log "  Beacon Interval: ${BEACON_INTERVAL}s"

# Create necessary directories
mkdir -p /app/logs /app/data /tmp/aprs

# Hardware detection and setup
log "Detecting hardware..."

# Check for GPS device
GPS_DEVICE=""
if [ -e /dev/ttyUSB0 ]; then
    GPS_DEVICE="/dev/ttyUSB0"
    log "GPS device found at $GPS_DEVICE"
elif [ -e /dev/ttyACM0 ]; then
    GPS_DEVICE="/dev/ttyACM0"
    log "GPS device found at $GPS_DEVICE"
else
    warn "No GPS device found, using static coordinates"
fi

# Check for RTL-SDR device
RTL_SDR_PRESENT=false
if lsusb | grep -q "RTL"; then
    RTL_SDR_PRESENT=true
    log "RTL-SDR device detected"
    # Reset RTL-SDR device
    rtl_test -t 2>/dev/null || warn "RTL-SDR test failed"
else
    warn "No RTL-SDR device found"
fi

# Check for audio devices
AUDIO_DEVICE=""
if [ -e /dev/snd/controlC0 ]; then
    AUDIO_DEVICE="/dev/snd/controlC0"
    log "Audio device found"
    # Test audio system
    amixer scontrols >/dev/null 2>&1 || warn "Audio mixer access failed"
else
    warn "No audio device found"
fi

# Start GPS daemon if GPS device is present
if [ -n "$GPS_DEVICE" ]; then
    log "Starting GPS daemon..."
    gpsd -n -D 2 -F /tmp/gpsd.sock $GPS_DEVICE &
    sleep 2
    
    # Test GPS functionality
    if timeout 5 gpspipe -w -n 5 >/dev/null 2>&1; then
        success "GPS daemon started successfully"
    else
        warn "GPS daemon started but no data received"
    fi
else
    log "Skipping GPS daemon startup"
fi

# Generate Direwolf configuration
log "Generating Direwolf configuration..."

# Create base configuration
cat > /app/config/direwolf.conf << EOF
# Direwolf configuration for Leeds APRS Pi
# Generated automatically by start.sh

# Station identification
MYCALL $CALLSIGN
MODEM 1200

# Audio configuration
EOF

# Add audio configuration based on detected hardware
if [ -n "$AUDIO_DEVICE" ]; then
    cat >> /app/config/direwolf.conf << EOF
# Audio device configuration
ADEVICE plughw:0,0

# Audio levels (adjust as needed)
AGWPORT 8000
KISSPORT 8001

EOF
else
    cat >> /app/config/direwolf.conf << EOF
# No audio device - using null device
ADEVICE null

EOF
fi

# Add RTL-SDR configuration if present
if [ "$RTL_SDR_PRESENT" == "true" ]; then
    cat >> /app/config/direwolf.conf << EOF
# RTL-SDR configuration
CHANNEL 0
MODEM 1200
DTMF

EOF
fi

# Add APRS-IS configuration
cat >> /app/config/direwolf.conf << EOF
# APRS-IS configuration
IGSERVER noam.aprs2.net
IGLOGIN $CALLSIGN $APRS_PASS

# Beacon configuration
PBEACON delay=1 every=$BEACON_INTERVAL lat=$LAT lon=$LON symbol="${SYMBOL_TABLE}${SYMBOL_CODE}" comment="$BEACON_MESSAGE"

# Logging
LOGDIR /app/logs
LOGFILE direwolf.log

EOF

# Add GPS beacon if GPS is available
if [ -n "$GPS_DEVICE" ]; then
    cat >> /app/config/direwolf.conf << EOF
# GPS-based beacon
GPSBEACON delay=1 every=$BEACON_INTERVAL symbol="${SYMBOL_TABLE}${SYMBOL_CODE}" comment="$BEACON_MESSAGE - GPS"

EOF
fi

success "Direwolf configuration generated"

# Create startup monitoring script
cat > /app/scripts/monitor.sh << 'EOF'
#!/bin/bash
# Monitor script for APRS services
while true; do
    if ! pgrep -f direwolf > /dev/null; then
        echo "$(date): Direwolf not running, restarting..." >> /app/logs/monitor.log
        /app/scripts/start.sh
    fi
    sleep 30
done
EOF

chmod +x /app/scripts/monitor.sh

# Start Direwolf in the background
log "Starting Direwolf APRS software..."
direwolf -c /app/config/direwolf.conf -l /app/logs 2>&1 | tee /app/logs/direwolf.log &

# Wait for Direwolf to initialize
sleep 5

# Check if Direwolf is running
if pgrep -f direwolf > /dev/null; then
    success "Direwolf started successfully"
    log "APRS station $CALLSIGN is now operational"
    log "Monitor logs with: docker-compose logs -f"
    log "Check status at: http://localhost:8080"
else
    error "Failed to start Direwolf"
    cat /app/logs/direwolf.log
    exit 1
fi

# Keep the container running and monitor services
log "System ready - entering monitoring loop..."
while true; do
    # Check if Direwolf is still running
    if ! pgrep -f direwolf > /dev/null; then
        error "Direwolf process died, restarting..."
        direwolf -c /app/config/direwolf.conf -l /app/logs 2>&1 | tee -a /app/logs/direwolf.log &
        sleep 5
    fi
    
    # Check GPS status if available
    if [ -n "$GPS_DEVICE" ]; then
        if ! pgrep -f gpsd > /dev/null; then
            warn "GPS daemon not running, attempting restart..."
            gpsd -n -D 2 -F /tmp/gpsd.sock $GPS_DEVICE &
        fi
    fi
    
    # Health check output
    echo "$(date): System healthy - Direwolf: $(pgrep -f direwolf > /dev/null && echo "OK" || echo "FAIL")" >> /app/logs/health.log
    
    sleep 60
done
