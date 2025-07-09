#!/bin/bash

#
# Changelog - monitor.sh
#
# [Initial]
# - System monitoring script for Leeds APRS Pi
# - Service health checking and automatic restart
# - Hardware monitoring and status reporting
# - Log file management and rotation
# - Performance metrics collection
# - Alert system for critical issues
#
# [Purpose]
# - Ensures continuous operation of APRS services
# - Provides system health monitoring and alerts
# - Manages log files and prevents disk space issues
# - Collects performance data for optimization
#

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/app/logs"
MONITOR_LOG="$LOG_DIR/monitor.log"
HEALTH_LOG="$LOG_DIR/health.log"
ALERT_LOG="$LOG_DIR/alerts.log"

# Monitoring intervals (seconds)
CHECK_INTERVAL=30
HEALTH_INTERVAL=300
LOG_ROTATION_INTERVAL=3600

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$MONITOR_LOG"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$MONITOR_LOG" "$ALERT_LOG"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$MONITOR_LOG"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$MONITOR_LOG"
}

# Create log directories if they don't exist
mkdir -p "$LOG_DIR"

# Health check functions
check_direwolf() {
    if pgrep -f direwolf > /dev/null; then
        return 0
    else
        return 1
    fi
}

check_gpsd() {
    if pgrep -f gpsd > /dev/null; then
        return 0
    else
        return 1
    fi
}

check_disk_space() {
    local usage=$(df /app | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$usage" -gt 85 ]; then
        return 1
    else
        return 0
    fi
}

check_memory() {
    local mem_usage=$(free | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}')
    if (( $(echo "$mem_usage > 90" | bc -l) )); then
        return 1
    else
        return 0
    fi
}

check_cpu_temp() {
    local temp_file="/sys/class/thermal/thermal_zone0/temp"
    if [ -f "$temp_file" ]; then
        local temp=$(cat "$temp_file")
        local temp_c=$((temp / 1000))
        if [ "$temp_c" -gt 75 ]; then
            return 1
        else
            return 0
        fi
    else
        return 0  # No temperature sensor available
    fi
}

check_network() {
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

check_aprs_is() {
    if netstat -an | grep -q ":14580.*ESTABLISHED"; then
        return 0
    else
        return 1
    fi
}

# Service restart functions
restart_direwolf() {
    log "Restarting Direwolf..."
    pkill -f direwolf || true
    sleep 2
    direwolf -c /app/config/direwolf.conf -l /app/logs 2>&1 | tee -a /app/logs/direwolf.log &
    sleep 5
    if check_direwolf; then
        success "Direwolf restarted successfully"
    else
        error "Failed to restart Direwolf"
    fi
}

restart_gpsd() {
    log "Restarting GPS daemon..."
    pkill -f gpsd || true
    sleep 2
    
    # Find GPS device
    local gps_device=""
    if [ -e /dev/ttyUSB0 ]; then
        gps_device="/dev/ttyUSB0"
    elif [ -e /dev/ttyACM0 ]; then
        gps_device="/dev/ttyACM0"
    fi
    
    if [ -n "$gps_device" ]; then
        gpsd -n -D 2 -F /tmp/gpsd.sock "$gps_device" &
        sleep 3
        if check_gpsd; then
            success "GPS daemon restarted successfully"
        else
            error "Failed to restart GPS daemon"
        fi
    else
        warn "No GPS device found for restart"
    fi
}

# Log rotation function
rotate_logs() {
    local max_size=10485760  # 10MB in bytes
    
    for log_file in "$LOG_DIR"/*.log; do
        if [ -f "$log_file" ] && [ $(stat -c%s "$log_file") -gt $max_size ]; then
            log "Rotating log file: $log_file"
            mv "$log_file" "$log_file.old"
            touch "$log_file"
        fi
    done
}

# System metrics collection
collect_metrics() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # CPU usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    
    # Memory usage
    local mem_usage=$(free | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}')
    
    # Disk usage
    local disk_usage=$(df /app | tail -1 | awk '{print $5}' | sed 's/%//')
    
    # Temperature
    local temp_c="N/A"
    if [ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
        local temp=$(cat "/sys/class/thermal/thermal_zone0/temp")
        temp_c=$((temp / 1000))
    fi
    
    # Network status
    local network_status="OK"
    if ! check_network; then
        network_status="FAIL"
    fi
    
    # APRS-IS status
    local aprs_is_status="OK"
    if ! check_aprs_is; then
        aprs_is_status="FAIL"
    fi
    
    # Write to health log
    echo "$timestamp,CPU:${cpu_usage}%,MEM:${mem_usage}%,DISK:${disk_usage}%,TEMP:${temp_c}°C,NET:$network_status,APRS-IS:$aprs_is_status" >> "$HEALTH_LOG"
}

# Alert system
send_alert() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log alert
    echo "$timestamp - ALERT: $message" >> "$ALERT_LOG"
    
    # Could add email/webhook notifications here
    # curl -X POST -H 'Content-type: application/json' \
    #   --data '{"text":"Leeds APRS Pi Alert: '"$message"'"}' \
    #   YOUR_WEBHOOK_URL
}

# Main monitoring function
monitor_system() {
    local last_health_check=0
    local last_log_rotation=0
    
    log "Starting system monitoring..."
    
    while true; do
        local current_time=$(date +%s)
        
        # Check critical services
        if ! check_direwolf; then
            error "Direwolf is not running"
            send_alert "Direwolf service failed"
            restart_direwolf
        fi
        
        # Check GPS daemon if GPS device is present
        if [ -e /dev/ttyUSB0 ] || [ -e /dev/ttyACM0 ]; then
            if ! check_gpsd; then
                warn "GPS daemon is not running"
                restart_gpsd
            fi
        fi
        
        # Check disk space
        if ! check_disk_space; then
            error "Disk space is critically low"
            send_alert "Disk space critically low"
            rotate_logs
        fi
        
        # Check memory usage
        if ! check_memory; then
            warn "Memory usage is high"
            send_alert "High memory usage detected"
        fi
        
        # Check CPU temperature
        if ! check_cpu_temp; then
            warn "CPU temperature is high"
            send_alert "High CPU temperature detected"
        fi
        
        # Check network connectivity
        if ! check_network; then
            error "Network connectivity lost"
            send_alert "Network connectivity lost"
        fi
        
        # Check APRS-IS connection
        if ! check_aprs_is; then
            warn "APRS-IS connection not established"
        fi
        
        # Periodic health check
        if [ $((current_time - last_health_check)) -ge $HEALTH_INTERVAL ]; then
            collect_metrics
            last_health_check=$current_time
        fi
        
        # Periodic log rotation
        if [ $((current_time - last_log_rotation)) -ge $LOG_ROTATION_INTERVAL ]; then
            rotate_logs
            last_log_rotation=$current_time
        fi
        
        sleep $CHECK_INTERVAL
    done
}

# Signal handlers
cleanup() {
    log "Monitoring script shutting down..."
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start monitoring
log "Leeds APRS Pi Monitor starting..."
monitor_system
