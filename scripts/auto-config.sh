#!/bin/bash

#
# Changelog - auto-config.sh
#
# [Initial]
# - Automatic hardware detection and configuration for Leeds APRS Pi
# - RTL-SDR device detection and optimization
# - GPS receiver configuration and testing
# - Audio system setup and level adjustment
# - Dynamic Direwolf configuration generation
# - Hardware-specific optimization profiles
#
# [Purpose]
# - Eliminates manual hardware configuration
# - Provides optimal settings for detected hardware
# - Enables plug-and-play APRS operation
# - Supports multiple hardware configurations
#

set -e  # Exit on any error

# Color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Configuration variables
CONFIG_DIR="/app/config"
LOGS_DIR="/app/logs"
DATA_DIR="/app/data"
TEMP_DIR="/tmp/aprs-autoconfig"

# Hardware detection results
HARDWARE_PROFILE=""
RTL_SDR_DETECTED=false
RTL_SDR_DEVICE=""
RTL_SDR_GAIN=""
GPS_DETECTED=false
GPS_DEVICE=""
GPS_WORKING=false
AUDIO_DETECTED=false
AUDIO_DEVICE=""
AUDIO_INPUT=""
AUDIO_OUTPUT=""

# Create working directory
mkdir -p "$TEMP_DIR"

log "Starting Leeds APRS Pi Hardware Auto-Configuration..."

# Function to detect and configure RTL-SDR devices
detect_rtl_sdr() {
    log "Detecting RTL-SDR devices..."
    
    # Check for RTL-SDR via lsusb
    if lsusb | grep -q -i "rtl\|realtek.*2838\|0bda:2838"; then
        RTL_SDR_DETECTED=true
        success "RTL-SDR device detected via USB"
        
        # Get device information
        local rtl_info=$(rtl_test -t 2>&1 || echo "")
        if echo "$rtl_info" | grep -q "Found.*device"; then
            RTL_SDR_DEVICE=$(echo "$rtl_info" | grep -o "Device.*:" | head -1)
            success "RTL-SDR device info: $RTL_SDR_DEVICE"
            
            # Test device functionality
            if timeout 5 rtl_test -s 250000 -t >/dev/null 2>&1; then
                success "RTL-SDR device is functional"
                
                # Determine optimal gain setting
                configure_rtl_sdr_gain
            else
                warn "RTL-SDR device detected but not responding properly"
            fi
        fi
    else
        info "No RTL-SDR device detected"
    fi
}

configure_rtl_sdr_gain() {
    log "Configuring RTL-SDR gain settings..."
    
    # Get available gain values
    local gain_values=$(rtl_test -g 2>&1 | grep -o "[0-9]\+\.[0-9]\+" | sort -n)
    
    if [ -n "$gain_values" ]; then
        # Use a moderate gain value (around middle of range)
        local gain_array=($gain_values)
        local middle_index=$((${#gain_array[@]} / 2))
        RTL_SDR_GAIN=${gain_array[$middle_index]}
        
        success "RTL-SDR gain set to: $RTL_SDR_GAIN dB"
        
        # Test with selected gain
        if timeout 3 rtl_fm -f 144.39M -M fm -s 22050 -g "$RTL_SDR_GAIN" - 2>/dev/null | head -c 1000 >/dev/null; then
            success "RTL-SDR gain setting verified"
        else
            warn "RTL-SDR gain test failed, using automatic gain"
            RTL_SDR_GAIN="auto"
        fi
    else
        warn "Could not determine RTL-SDR gain values, using automatic"
        RTL_SDR_GAIN="auto"
    fi
}

# Function to detect and configure GPS devices
detect_gps() {
    log "Detecting GPS devices..."
    
    # Common GPS device paths
    local gps_devices=("/dev/ttyUSB0" "/dev/ttyACM0" "/dev/ttyS0" "/dev/ttyAMA0")
    
    for device in "${gps_devices[@]}"; do
        if [ -c "$device" ]; then
            info "Testing GPS device: $device"
            
            # Test if device responds to GPS commands
            if timeout 5 stty -F "$device" 9600 2>/dev/null; then
                # Try to read NMEA data
                if timeout 10 cat "$device" 2>/dev/null | head -5 | grep -q "^\$GP\|^\$GN"; then
                    GPS_DETECTED=true
                    GPS_DEVICE="$device"
                    GPS_WORKING=true
                    success "Working GPS device found: $device"
                    
                    # Test GPS data quality
                    test_gps_quality "$device"
                    break
                else
                    info "Device $device exists but no GPS data received"
                fi
            fi
        fi
    done
    
    if [ "$GPS_DETECTED" = false ]; then
        info "No GPS device detected"
    fi
}

test_gps_quality() {
    local device="$1"
    log "Testing GPS data quality on $device..."
    
    # Collect GPS data for analysis
    local gps_data=$(timeout 15 cat "$device" 2>/dev/null | head -20)
    
    if echo "$gps_data" | grep -q "GPGGA\|GNGGA"; then
        # Check for fix quality
        local fix_quality=$(echo "$gps_data" | grep "GPGGA\|GNGGA" | head -1 | cut -d',' -f7)
        if [ "$fix_quality" -gt 0 ] 2>/dev/null; then
            success "GPS has position fix (quality: $fix_quality)"
        else
            warn "GPS device working but no position fix yet"
        fi
        
        # Check satellite count
        local sat_data=$(echo "$gps_data" | grep "GPGSV\|GNGSV" | head -1)
        if [ -n "$sat_data" ]; then
            local sat_count=$(echo "$sat_data" | cut -d',' -f4)
            if [ "$sat_count" -gt 0 ] 2>/dev/null; then
                success "GPS sees $sat_count satellites"
            fi
        fi
    else
        warn "GPS device responds but data format unrecognized"
    fi
}

# Function to detect and configure audio devices
detect_audio() {
    log "Detecting audio devices..."
    
    # Check for ALSA sound cards
    if [ -d "/proc/asound" ]; then
        local sound_cards=$(cat /proc/asound/cards 2>/dev/null || echo "")
        
        if [ -n "$sound_cards" ]; then
            AUDIO_DETECTED=true
            info "Available sound cards:"
            echo "$sound_cards" | while read line; do
                if [ -n "$line" ]; then
                    info "  $line"
                fi
            done
            
            # Determine best audio device
            configure_audio_device
        fi
    fi
    
    # Check for USB audio devices
    if lsusb | grep -q -i "audio\|sound"; then
        success "USB audio device detected"
        AUDIO_DETECTED=true
    fi
    
    if [ "$AUDIO_DETECTED" = false ]; then
        warn "No audio devices detected - will use null audio device"
        AUDIO_DEVICE="null"
    fi
}

configure_audio_device() {
    log "Configuring audio device..."
    
    # Test different audio devices
    local devices=("plughw:0,0" "plughw:1,0" "hw:0,0" "hw:1,0")
    
    for device in "${devices[@]}"; do
        if aplay -l 2>/dev/null | grep -q "card [01]"; then
            # Test if device works
            if timeout 2 arecord -D "$device" -f S16_LE -r 44100 -c 1 -t wav /dev/null 2>/dev/null; then
                AUDIO_DEVICE="$device"
                success "Audio device configured: $device"
                
                # Test audio levels
                configure_audio_levels "$device"
                break
            fi
        fi
    done
    
    if [ -z "$AUDIO_DEVICE" ]; then
        warn "No working audio device found, using null device"
        AUDIO_DEVICE="null"
    fi
}

configure_audio_levels() {
    local device="$1"
    log "Configuring audio levels for $device..."
    
    # Set reasonable default levels
    if command -v amixer >/dev/null 2>&1; then
        # Capture level
        amixer set Capture 80% 2>/dev/null || true
        amixer set Mic 70% 2>/dev/null || true
        
        # Playback level  
        amixer set Master 60% 2>/dev/null || true
        amixer set PCM 80% 2>/dev/null || true
        
        success "Audio levels configured"
    fi
}

# Function to determine hardware profile
determine_hardware_profile() {
    log "Determining hardware profile..."
    
    # Raspberry Pi detection
    if [ -f "/proc/device-tree/model" ]; then
        local pi_model=$(cat /proc/device-tree/model 2>/dev/null | tr -d '\0')
        if echo "$pi_model" | grep -q -i "raspberry pi"; then
            HARDWARE_PROFILE="raspberry_pi"
            success "Detected Raspberry Pi: $pi_model"
            
            # Specific Pi optimizations
            if echo "$pi_model" | grep -q "Pi 4"; then
                HARDWARE_PROFILE="raspberry_pi_4"
            elif echo "$pi_model" | grep -q "Pi 3"; then
                HARDWARE_PROFILE="raspberry_pi_3"
            elif echo "$pi_model" | grep -q "Pi Zero"; then
                HARDWARE_PROFILE="raspberry_pi_zero"
            fi
        fi
    fi
    
    # Generic Linux detection
    if [ -z "$HARDWARE_PROFILE" ]; then
        HARDWARE_PROFILE="generic_linux"
        info "Using generic Linux profile"
    fi
    
    success "Hardware profile: $HARDWARE_PROFILE"
}

# Function to generate optimized Direwolf configuration
generate_direwolf_config() {
    log "Generating optimized Direwolf configuration..."
    
    local config_file="$CONFIG_DIR/direwolf.conf"
    local temp_config="$TEMP_DIR/direwolf.conf.new"
    
    # Start with base configuration
    cat > "$temp_config" << EOF
# Direwolf Configuration - Auto-generated by Leeds APRS Pi
# Generated on: $(date)
# Hardware Profile: $HARDWARE_PROFILE

# Station identification
MYCALL ${CALLSIGN:-N0CALL}

EOF

    # Add modem configuration based on hardware
    if [ "$RTL_SDR_DETECTED" = true ]; then
        cat >> "$temp_config" << EOF
# RTL-SDR Configuration
MODEM 1200
ARATE 22050

EOF
    else
        cat >> "$temp_config" << EOF
# Standard modem configuration
MODEM 1200

EOF
    fi
    
    # Add audio configuration
    cat >> "$temp_config" << EOF
# Audio device configuration
ADEVICE $AUDIO_DEVICE

EOF
    
    # Add RTL-SDR specific settings
    if [ "$RTL_SDR_DETECTED" = true ]; then
        cat >> "$temp_config" << EOF
# RTL-SDR specific settings
# Frequency: 144.390 MHz (North America APRS)
# Gain: $RTL_SDR_GAIN
# Note: RTL-SDR integration requires additional software

EOF
    fi
    
    # Add GPS configuration
    if [ "$GPS_DETECTED" = true ] && [ "$GPS_WORKING" = true ]; then
        cat >> "$temp_config" << EOF
# GPS Configuration
# GPS device: $GPS_DEVICE
# GPS beacons will use live coordinates

EOF
    fi
    
    # Add APRS-IS configuration
    cat >> "$temp_config" << EOF
# APRS-IS configuration
IGSERVER noam.aprs2.net
IGLOGIN ${CALLSIGN:-N0CALL} ${APRS_PASS:-00000}

# Beacon configuration
EOF
    
    # GPS vs static beacon
    if [ "$GPS_DETECTED" = true ] && [ "$GPS_WORKING" = true ]; then
        cat >> "$temp_config" << EOF
# GPS-based mobile beacon
GPSBEACON delay=1 every=${BEACON_INTERVAL:-600} symbol="${SYMBOL_TABLE:-/}${SYMBOL_CODE:-&}" comment="${BEACON_MESSAGE:-Leeds Space Comms APRS Node - Mobile}"

EOF
    else
        cat >> "$temp_config" << EOF
# Static position beacon
PBEACON delay=1 every=${BEACON_INTERVAL:-600} lat=${LAT:-53.8008} lon=${LON:--1.5491} symbol="${SYMBOL_TABLE:-/}${SYMBOL_CODE:-&}" comment="${BEACON_MESSAGE:-Leeds Space Comms APRS Node}"

EOF
    fi
    
    # Add network interfaces
    cat >> "$temp_config" << EOF
# Network interfaces
AGWPORT 8000
KISSPORT 8001

# Logging
LOGDIR $LOGS_DIR
LOGFILE direwolf.log

# Hardware-specific optimizations
EOF
    
    # Add hardware-specific optimizations
    case "$HARDWARE_PROFILE" in
        "raspberry_pi_zero")
            cat >> "$temp_config" << EOF
# Raspberry Pi Zero optimizations
ARATE 22050
FIX_BITS 1
EOF
            ;;
        "raspberry_pi_3"|"raspberry_pi_4")
            cat >> "$temp_config" << EOF
# Raspberry Pi 3/4 optimizations
ARATE 44100
FIX_BITS 2
PASSALL
EOF
            ;;
        *)
            cat >> "$temp_config" << EOF
# Generic optimizations
ARATE 22050
FIX_BITS 1
EOF
            ;;
    esac
    
    # Move new configuration into place
    cp "$temp_config" "$config_file"
    success "Direwolf configuration generated: $config_file"
}

# Function to create hardware summary
create_hardware_summary() {
    log "Creating hardware summary..."
    
    local summary_file="$DATA_DIR/hardware-summary.json"
    
    cat > "$summary_file" << EOF
{
    "detection_timestamp": "$(date -Iseconds)",
    "hardware_profile": "$HARDWARE_PROFILE",
    "rtl_sdr": {
        "detected": $RTL_SDR_DETECTED,
        "device": "$RTL_SDR_DEVICE",
        "gain": "$RTL_SDR_GAIN"
    },
    "gps": {
        "detected": $GPS_DETECTED,
        "device": "$GPS_DEVICE",
        "working": $GPS_WORKING
    },
    "audio": {
        "detected": $AUDIO_DETECTED,
        "device": "$AUDIO_DEVICE"
    },
    "recommendations": [
EOF
    
    # Add recommendations based on detected hardware
    local recommendations=""
    
    if [ "$RTL_SDR_DETECTED" = true ]; then
        recommendations+='"RTL-SDR detected - receive-only operation enabled",'
    fi
    
    if [ "$GPS_DETECTED" = true ]; then
        recommendations+='"GPS detected - mobile beacon mode available",'
    fi
    
    if [ "$AUDIO_DETECTED" = false ]; then
        recommendations+='"No audio device - transmit functionality limited",'
    fi
    
    # Remove trailing comma and add to file
    recommendations=$(echo "$recommendations" | sed 's/,$//')
    echo "        $recommendations" >> "$summary_file"
    
    cat >> "$summary_file" << EOF
    ]
}
EOF
    
    success "Hardware summary saved: $summary_file"
}

# Function to run hardware tests
run_hardware_tests() {
    log "Running hardware validation tests..."
    
    local test_results="$DATA_DIR/hardware-tests.log"
    echo "Hardware Tests - $(date)" > "$test_results"
    
    # Test RTL-SDR
    if [ "$RTL_SDR_DETECTED" = true ]; then
        echo "Testing RTL-SDR..." >> "$test_results"
        if timeout 5 rtl_test -t >> "$test_results" 2>&1; then
            echo "RTL-SDR test: PASS" >> "$test_results"
            success "RTL-SDR hardware test passed"
        else
            echo "RTL-SDR test: FAIL" >> "$test_results"
            warn "RTL-SDR hardware test failed"
        fi
    fi
    
    # Test GPS
    if [ "$GPS_DETECTED" = true ]; then
        echo "Testing GPS..." >> "$test_results"
        if timeout 10 cat "$GPS_DEVICE" | head -5 | grep -q "^\$" >> "$test_results" 2>&1; then
            echo "GPS test: PASS" >> "$test_results"
            success "GPS hardware test passed"
        else
            echo "GPS test: FAIL" >> "$test_results"
            warn "GPS hardware test failed"
        fi
    fi
    
    # Test audio
    if [ "$AUDIO_DETECTED" = true ] && [ "$AUDIO_DEVICE" != "null" ]; then
        echo "Testing audio..." >> "$test_results"
        if timeout 3 arecord -D "$AUDIO_DEVICE" -f S16_LE -r 22050 -c 1 -t wav /dev/null >> "$test_results" 2>&1; then
            echo "Audio test: PASS" >> "$test_results"
            success "Audio hardware test passed"
        else
            echo "Audio test: FAIL" >> "$test_results"
            warn "Audio hardware test failed"
        fi
    fi
    
    success "Hardware tests completed: $test_results"
}

# Main execution
main() {
    log "Leeds APRS Pi Hardware Auto-Configuration"
    log "========================================="
    
    # Create required directories
    mkdir -p "$CONFIG_DIR" "$LOGS_DIR" "$DATA_DIR"
    
    # Run detection and configuration
    determine_hardware_profile
    detect_rtl_sdr
    detect_gps
    detect_audio
    
    # Generate configuration
    generate_direwolf_config
    create_hardware_summary
    run_hardware_tests
    
    # Clean up
    rm -rf "$TEMP_DIR"
    
    log "Hardware auto-configuration completed!"
    log "======================================="
    
    # Display summary
    echo ""
    success "Hardware Configuration Summary:"
    echo "  Profile: $HARDWARE_PROFILE"
    echo "  RTL-SDR: $([ "$RTL_SDR_DETECTED" = true ] && echo "Detected ($RTL_SDR_GAIN gain)" || echo "Not found")"
    echo "  GPS: $([ "$GPS_DETECTED" = true ] && echo "Detected ($GPS_DEVICE)" || echo "Not found")"
    echo "  Audio: $([ "$AUDIO_DETECTED" = true ] && echo "Detected ($AUDIO_DEVICE)" || echo "Using null device")"
    echo ""
    
    if [ "$RTL_SDR_DETECTED" = true ] || [ "$GPS_DETECTED" = true ] || [ "$AUDIO_DETECTED" = true ]; then
        success "Hardware auto-configuration successful!"
        info "Direwolf configuration optimized for detected hardware"
        info "Review configuration in: $CONFIG_DIR/direwolf.conf"
    else
        warn "Limited hardware detected - basic configuration applied"
        info "System will work with software simulation"
    fi
    
    log "Ready to start APRS services"
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi