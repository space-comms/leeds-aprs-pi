#!/bin/bash

#
# Changelog - configure-beacon.sh
#
# [v1.1.0]
# - Process beacon configuration with environment variable substitution
# - Generate Direwolf beacon configuration dynamically
# - Support multiple beacon profiles and scheduling
# - Integrate with Leeds Space Comms specific settings
# - Validate configuration parameters
#
# [Purpose]
# - Processes beacon.conf template with environment variables
# - Generates appropriate Direwolf configuration
# - Validates beacon parameters for APRS compliance
# - Supports different operational modes and profiles
#

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
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

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${SCRIPT_DIR}/.."
CONFIG_DIR="${APP_DIR}/config"
LOGS_DIR="${APP_DIR}/logs"

# Configuration files
BEACON_CONF="${CONFIG_DIR}/beacon.conf"
DIREWOLF_CONF="${CONFIG_DIR}/direwolf.conf"
BEACON_TEMPLATE="${CONFIG_DIR}/beacon.conf.template"

log "Starting beacon configuration processing..."

# Create directories if they don't exist
mkdir -p "${LOGS_DIR}"

# Validate required environment variables
validate_environment() {
    log "Validating environment variables..."
    
    local required_vars=("CALLSIGN" "APRS_PASS" "LAT" "LON")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        error "Missing required environment variables: ${missing_vars[*]}"
        error "Please set the following variables:"
        for var in "${missing_vars[@]}"; do
            error "  export $var=your_value"
        done
        exit 1
    fi
    
    # Validate callsign format
    if ! echo "$CALLSIGN" | grep -qE '^[A-Z0-9]{1,3}[0-9][A-Z0-9]{0,3}(/[A-Z0-9]{1,7})?$'; then
        warn "Callsign format may not be valid: $CALLSIGN"
    fi
    
    # Validate coordinates
    if ! echo "$LAT" | grep -qE '^-?[0-9]+\.?[0-9]*$'; then
        error "Invalid latitude format: $LAT"
        exit 1
    fi
    
    if ! echo "$LON" | grep -qE '^-?[0-9]+\.?[0-9]*$'; then
        error "Invalid longitude format: $LON"
        exit 1
    fi
    
    # Check coordinate ranges
    if (( $(echo "$LAT < -90 || $LAT > 90" | bc -l) )); then
        error "Latitude out of range (-90 to 90): $LAT"
        exit 1
    fi
    
    if (( $(echo "$LON < -180 || $LON > 180" | bc -l) )); then
        error "Longitude out of range (-180 to 180): $LON"
        exit 1
    fi
    
    success "Environment variables validated"
}

# Process beacon configuration template
process_beacon_config() {
    log "Processing beacon configuration..."
    
    if [ ! -f "$BEACON_CONF" ]; then
        error "Beacon configuration file not found: $BEACON_CONF"
        exit 1
    fi
    
    # Create processed configuration
    local processed_conf="${CONFIG_DIR}/beacon-processed.conf"
    
    # Substitute environment variables
    envsubst < "$BEACON_CONF" > "$processed_conf"
    
    success "Beacon configuration processed: $processed_conf"
}

# Generate Direwolf beacon configuration
generate_direwolf_beacons() {
    log "Generating Direwolf beacon configuration..."
    
    local beacon_section=""
    
    # Set defaults
    local beacon_interval="${BEACON_INTERVAL:-600}"
    local beacon_delay="${BEACON_DELAY:-60}"
    local symbol_table="${SYMBOL_TABLE:-/}"
    local symbol_code="${SYMBOL_CODE:-&}"
    local beacon_message="${BEACON_MESSAGE:-Leeds Space Comms APRS Node}"
    
    # Generate static position beacon
    beacon_section+="# Static position beacon\n"
    beacon_section+="PBEACON delay=${beacon_delay} every=${beacon_interval} "
    beacon_section+="lat=${LAT} lon=${LON} "
    beacon_section+="symbol=\"${symbol_table}${symbol_code}\" "
    beacon_section+="comment=\"${beacon_message}\"\n\n"
    
    # Generate GPS beacon if enabled
    if [ "${GPS_ENABLED:-true}" = "true" ]; then
        local gps_interval="${GPS_BEACON_INTERVAL:-300}"
        local gps_symbol="${GPS_SYMBOL:->}"
        local gps_message="${GPS_BEACON_MESSAGE:-Leeds Space Comms Mobile}"
        
        beacon_section+="# GPS-based beacon (enabled when GPS device present)\n"
        beacon_section+="GPSBEACON delay=${beacon_delay} every=${gps_interval} "
        beacon_section+="symbol=\"${symbol_table}${gps_symbol}\" "
        beacon_section+="comment=\"${gps_message}\"\n\n"
    fi
    
    # Add time-based beacons if in educational mode
    if [ "${EDUCATIONAL_MODE:-false}" = "true" ]; then
        local edu_interval="${EDUCATIONAL_INTERVAL:-180}"
        local edu_message="${EDUCATIONAL_MESSAGE:-Leeds Space Comms - Educational Demo}"
        
        beacon_section+="# Educational demonstration beacon\n"
        beacon_section+="PBEACON delay=30 every=${edu_interval} "
        beacon_section+="lat=${LAT} lon=${LON} "
        beacon_section+="symbol=\"${symbol_table}E\" "
        beacon_section+="comment=\"${edu_message}\"\n\n"
    fi
    
    echo -e "$beacon_section"
}

# Update Direwolf configuration
update_direwolf_config() {
    log "Updating Direwolf configuration..."
    
    if [ ! -f "$DIREWOLF_CONF" ]; then
        warn "Direwolf configuration not found, creating new one"
        touch "$DIREWOLF_CONF"
    fi
    
    # Backup existing configuration
    cp "$DIREWOLF_CONF" "${DIREWOLF_CONF}.backup.$(date +%Y%m%d-%H%M%S)"
    
    # Generate new beacon configuration
    local beacon_config
    beacon_config=$(generate_direwolf_beacons)
    
    # Create new Direwolf configuration
    cat > "$DIREWOLF_CONF" << EOF
#
# Direwolf Configuration for Leeds APRS Pi
# Generated automatically by configure-beacon.sh
# $(date)
#

# Station identification
MYCALL ${CALLSIGN}
MODEM 1200

# Audio configuration
ADEVICE ${AUDIO_DEVICE:-null}
ARATE ${AUDIO_RATE:-44100}

# APRS-IS configuration
IGSERVER ${APRS_SERVER:-noam.aprs2.net}
IGLOGIN ${CALLSIGN} ${APRS_PASS}

# Filter for received packets
FILTER r/${LAT}/${LON}/${FILTER_RADIUS:-50}

${beacon_config}

# Network services
AGWPORT 8000
KISSPORT 8001

# Logging
LOGDIR ${LOGS_DIR}
LOGFILE direwolf.log

# Digipeater configuration
DIGIPEAT 0 0 ^WIDE[3-7]-[1-7]$|^TEST$ ^WIDE[12]-[12]$ TRACE

EOF
    
    success "Direwolf configuration updated"
}

# Validate generated configuration
validate_configuration() {
    log "Validating generated configuration..."
    
    # Check if Direwolf can parse the configuration
    if command -v direwolf >/dev/null 2>&1; then
        log "Testing Direwolf configuration syntax..."
        if direwolf -c "$DIREWOLF_CONF" -t >/dev/null 2>&1; then
            success "Direwolf configuration syntax is valid"
        else
            error "Direwolf configuration syntax error"
            direwolf -c "$DIREWOLF_CONF" -t
            exit 1
        fi
    else
        warn "Direwolf not available for configuration testing"
    fi
    
    # Validate beacon timing
    local interval="${BEACON_INTERVAL:-600}"
    if [ "$interval" -lt 60 ]; then
        error "Beacon interval too short: ${interval}s (minimum 60s recommended)"
        exit 1
    fi
    
    if [ "$interval" -gt 3600 ]; then
        warn "Beacon interval very long: ${interval}s (may appear inactive)"
    fi
    
    success "Configuration validation complete"
}

# Generate configuration summary
generate_summary() {
    log "Generating configuration summary..."
    
    local summary_file="${LOGS_DIR}/beacon-config-summary.txt"
    
    cat > "$summary_file" << EOF
Leeds APRS Pi Beacon Configuration Summary
Generated: $(date)

Station Information:
  Callsign: ${CALLSIGN}
  Location: ${LAT}, ${LON}
  Grid Square: ${GRID_SQUARE:-Unknown}
  
Beacon Settings:
  Message: ${BEACON_MESSAGE:-Leeds Space Comms APRS Node}
  Interval: ${BEACON_INTERVAL:-600} seconds
  Symbol: ${SYMBOL_TABLE:-/}${SYMBOL_CODE:-&}
  
APRS-IS Settings:
  Server: ${APRS_SERVER:-noam.aprs2.net}
  Port: ${APRS_PORT:-14580}
  
GPS Settings:
  Enabled: ${GPS_ENABLED:-true}
  Mobile Interval: ${GPS_BEACON_INTERVAL:-300} seconds
  Mobile Symbol: ${SYMBOL_TABLE:-/}${GPS_SYMBOL:->}
  
Special Modes:
  Educational Mode: ${EDUCATIONAL_MODE:-false}
  Emergency Beacon: ${EMERGENCY_ENABLED:-false}
  Weather Beacon: ${WEATHER_BEACON:-false}

Generated Files:
  Direwolf Config: ${DIREWOLF_CONF}
  Beacon Config: ${CONFIG_DIR}/beacon-processed.conf
  Log Directory: ${LOGS_DIR}

For support: https://github.com/leedsspacecomms/leeds-aprs-pi
73 de Leeds Space Comms!
EOF
    
    success "Configuration summary: $summary_file"
    
    # Display summary
    log "Configuration Summary:"
    echo "  Callsign: ${CALLSIGN}"
    echo "  Location: ${LAT}, ${LON}"
    echo "  Beacon: Every ${BEACON_INTERVAL:-600}s - ${BEACON_MESSAGE:-Leeds Space Comms APRS Node}"
    echo "  Symbol: ${SYMBOL_TABLE:-/}${SYMBOL_CODE:-&}"
    echo "  Server: ${APRS_SERVER:-noam.aprs2.net}"
}

# Main execution
main() {
    log "Leeds APRS Pi Beacon Configuration Script v1.1.0"
    
    # Validate environment
    validate_environment
    
    # Process configuration
    process_beacon_config
    
    # Update Direwolf configuration
    update_direwolf_config
    
    # Validate configuration
    validate_configuration
    
    # Generate summary
    generate_summary
    
    success "Beacon configuration complete!"
    log "Ready to start APRS system with: docker-compose up -d"
}

# Script execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi