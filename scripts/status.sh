#!/bin/bash

#
# Changelog - status.sh
#
# [Initial]
# - System status reporting script for Leeds APRS Pi
# - Service status monitoring and display
# - Hardware status and health reporting
# - Network connectivity and APRS-IS status
# - Log file summaries and recent activities
# - Performance metrics display
#
# [Purpose]
# - Provides comprehensive system status overview
# - Helps with troubleshooting and monitoring
# - Displays key metrics and health indicators
# - Supports both interactive and automated reporting
#

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/app/logs"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Status check functions
check_service_status() {
    local service=$1
    if pgrep -f "$service" > /dev/null; then
        echo -e "${GREEN}RUNNING${NC}"
    else
        echo -e "${RED}STOPPED${NC}"
    fi
}

get_uptime() {
    local pid=$1
    if [ -n "$pid" ]; then
        local start_time=$(ps -o lstart= -p "$pid" 2>/dev/null | head -1)
        if [ -n "$start_time" ]; then
            echo "$start_time"
        else
            echo "Unknown"
        fi
    else
        echo "Not running"
    fi
}

get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}' | head -1
}

get_memory_usage() {
    free | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}'
}

get_disk_usage() {
    df /app | tail -1 | awk '{print $5}' | sed 's/%//'
}

get_temperature() {
    if [ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
        local temp=$(cat "/sys/class/thermal/thermal_zone0/temp")
        echo "$((temp / 1000))"
    else
        echo "N/A"
    fi
}

check_network() {
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        echo -e "${GREEN}ONLINE${NC}"
    else
        echo -e "${RED}OFFLINE${NC}"
    fi
}

check_aprs_is() {
    if netstat -an 2>/dev/null | grep -q ":14580.*ESTABLISHED"; then
        echo -e "${GREEN}CONNECTED${NC}"
    else
        echo -e "${RED}DISCONNECTED${NC}"
    fi
}

get_log_tail() {
    local log_file="$1"
    local lines=${2:-10}
    if [ -f "$log_file" ]; then
        tail -n "$lines" "$log_file" 2>/dev/null
    else
        echo "Log file not found"
    fi
}

# Main status display
show_status() {
    clear
    
    # Header
    echo -e "${BOLD}${BLUE}"
    cat << 'EOF'
 _               _        _    ____  ____  ____      ____  _ 
| |   ___  ___  __| |___   / \  |  _ \|  _ \/ ___|    |  _ \(_)
| |  / _ \/ _ \/ _` / __| / _ \ | |_) | |_) \___ \    | |_) | |
| | |  __/  __/ (_| \__ \/ ___ \|  __/|  _ < ___) |___|  __/| |
|_|  \___|\___|\__,_|___/_/   \_\_|   |_| \_\____/_____|_|   |_|

EOF
    echo -e "${NC}"
    echo -e "${BOLD}Leeds Space Comms - APRS System Status${NC}"
    echo -e "${CYAN}Generated: $(date)${NC}"
    echo
    
    # System Information
    echo -e "${BOLD}${BLUE}=== SYSTEM INFORMATION ===${NC}"
    echo -e "Hostname:     $(hostname)"
    echo -e "Uptime:       $(uptime -p)"
    echo -e "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo -e "Kernel:       $(uname -r)"
    echo -e "Architecture: $(uname -m)"
    echo
    
    # Service Status
    echo -e "${BOLD}${BLUE}=== SERVICE STATUS ===${NC}"
    
    # Direwolf status
    local direwolf_pid=$(pgrep -f direwolf | head -1)
    echo -e "Direwolf:     $(check_service_status direwolf)"
    if [ -n "$direwolf_pid" ]; then
        echo -e "  PID:        $direwolf_pid"
        echo -e "  Started:    $(get_uptime $direwolf_pid)"
    fi
    
    # GPS daemon status
    local gpsd_pid=$(pgrep -f gpsd | head -1)
    echo -e "GPS Daemon:   $(check_service_status gpsd)"
    if [ -n "$gpsd_pid" ]; then
        echo -e "  PID:        $gpsd_pid"
        echo -e "  Started:    $(get_uptime $gpsd_pid)"
    fi
    
    # Docker status
    if command -v docker &> /dev/null; then
        local docker_status="RUNNING"
        if ! systemctl is-active --quiet docker; then
            docker_status="STOPPED"
        fi
        echo -e "Docker:       $(echo $docker_status | sed 's/RUNNING/\x1b[32mRUNNING\x1b[0m/g; s/STOPPED/\x1b[31mSTOPPED\x1b[0m/g')"
    fi
    echo
    
    # Hardware Status
    echo -e "${BOLD}${BLUE}=== HARDWARE STATUS ===${NC}"
    
    # CPU and Memory
    echo -e "CPU Usage:    $(get_cpu_usage)%"
    echo -e "Memory Usage: $(get_memory_usage)%"
    echo -e "Disk Usage:   $(get_disk_usage)%"
    echo -e "Temperature:  $(get_temperature)°C"
    echo
    
    # Hardware detection
    echo -e "${BOLD}${BLUE}=== HARDWARE DETECTION ===${NC}"
    
    # RTL-SDR
    if lsusb | grep -q "RTL"; then
        echo -e "RTL-SDR:      ${GREEN}DETECTED${NC}"
        lsusb | grep RTL | head -1 | awk '{print "  Device:     " $6}'
    else
        echo -e "RTL-SDR:      ${YELLOW}NOT DETECTED${NC}"
    fi
    
    # GPS device
    if [ -e /dev/ttyUSB0 ]; then
        echo -e "GPS Device:   ${GREEN}DETECTED${NC} (/dev/ttyUSB0)"
    elif [ -e /dev/ttyACM0 ]; then
        echo -e "GPS Device:   ${GREEN}DETECTED${NC} (/dev/ttyACM0)"
    else
        echo -e "GPS Device:   ${YELLOW}NOT DETECTED${NC}"
    fi
    
    # Audio devices
    if [ -e /dev/snd/controlC0 ]; then
        echo -e "Audio Device: ${GREEN}DETECTED${NC}"
    else
        echo -e "Audio Device: ${YELLOW}NOT DETECTED${NC}"
    fi
    echo
    
    # Network Status
    echo -e "${BOLD}${BLUE}=== NETWORK STATUS ===${NC}"
    echo -e "Internet:     $(check_network)"
    echo -e "APRS-IS:      $(check_aprs_is)"
    
    # Get IP addresses
    local ip_addr=$(hostname -I | awk '{print $1}')
    echo -e "IP Address:   ${ip_addr:-Unknown}"
    echo
    
    # Configuration Status
    echo -e "${BOLD}${BLUE}=== CONFIGURATION ===${NC}"
    
    # Read environment variables from docker-compose.yml
    if [ -f "docker-compose.yml" ]; then
        local callsign=$(grep "CALLSIGN=" docker-compose.yml | head -1 | cut -d'=' -f2)
        local lat=$(grep "LAT=" docker-compose.yml | head -1 | cut -d'=' -f2)
        local lon=$(grep "LON=" docker-compose.yml | head -1 | cut -d'=' -f2)
        local beacon_interval=$(grep "BEACON_INTERVAL=" docker-compose.yml | head -1 | cut -d'=' -f2)
        
        echo -e "Callsign:     $callsign"
        echo -e "Location:     $lat, $lon"
        echo -e "Beacon Int:   ${beacon_interval}s"
    fi
    echo
    
    # Log Summary
    echo -e "${BOLD}${BLUE}=== LOG SUMMARY ===${NC}"
    
    # Recent Direwolf log entries
    if [ -f "$LOG_DIR/direwolf.log" ]; then
        echo -e "${CYAN}Recent Direwolf activity:${NC}"
        get_log_tail "$LOG_DIR/direwolf.log" 5 | sed 's/^/  /'
    fi
    
    # Recent monitoring log entries
    if [ -f "$LOG_DIR/monitor.log" ]; then
        echo -e "${CYAN}Recent monitoring activity:${NC}"
        get_log_tail "$LOG_DIR/monitor.log" 5 | sed 's/^/  /'
    fi
    
    # Recent alerts
    if [ -f "$LOG_DIR/alerts.log" ]; then
        echo -e "${CYAN}Recent alerts:${NC}"
        get_log_tail "$LOG_DIR/alerts.log" 3 | sed 's/^/  /'
    fi
    echo
    
    # Performance Metrics
    if [ -f "$LOG_DIR/health.log" ]; then
        echo -e "${BOLD}${BLUE}=== PERFORMANCE METRICS ===${NC}"
        echo -e "${CYAN}Last 24 hours average:${NC}"
        
        # Calculate averages from health log
        local avg_cpu=$(tail -n 288 "$LOG_DIR/health.log" 2>/dev/null | grep -o 'CPU:[0-9.]*%' | sed 's/CPU:\([0-9.]*\)%/\1/' | awk '{sum+=$1} END {print (NR>0 ? sum/NR : 0)}')
        local avg_mem=$(tail -n 288 "$LOG_DIR/health.log" 2>/dev/null | grep -o 'MEM:[0-9.]*%' | sed 's/MEM:\([0-9.]*\)%/\1/' | awk '{sum+=$1} END {print (NR>0 ? sum/NR : 0)}')
        
        echo -e "  CPU Usage: $(printf "%.1f" $avg_cpu)%"
        echo -e "  Memory Usage: $(printf "%.1f" $avg_mem)%"
        echo
    fi
    
    # Footer
    echo -e "${BOLD}${BLUE}=== CONTROLS ===${NC}"
    echo -e "View logs:    ${CYAN}docker-compose logs -f${NC}"
    echo -e "Restart:      ${CYAN}docker-compose restart${NC}"
    echo -e "Stop:         ${CYAN}docker-compose down${NC}"
    echo -e "Start:        ${CYAN}docker-compose up -d${NC}"
    echo
    echo -e "${CYAN}Press 'q' to quit, 'r' to refresh${NC}"
}

# Interactive mode
interactive_mode() {
    while true; do
        show_status
        
        # Wait for user input with timeout
        if read -t 30 -n 1 key; then
            case $key in
                q|Q) break ;;
                r|R) continue ;;
                *) continue ;;
            esac
        fi
    done
}

# Command line argument handling
case "${1:-}" in
    --once|-o)
        show_status
        ;;
    --json|-j)
        # JSON output for programmatic use
        echo "{"
        echo "  \"timestamp\": \"$(date -Iseconds)\","
        echo "  \"direwolf\": \"$(check_service_status direwolf | sed 's/\x1b\[[0-9;]*m//g')\","
        echo "  \"gpsd\": \"$(check_service_status gpsd | sed 's/\x1b\[[0-9;]*m//g')\","
        echo "  \"network\": \"$(check_network | sed 's/\x1b\[[0-9;]*m//g')\","
        echo "  \"aprs_is\": \"$(check_aprs_is | sed 's/\x1b\[[0-9;]*m//g')\","
        echo "  \"cpu_usage\": \"$(get_cpu_usage)\","
        echo "  \"memory_usage\": \"$(get_memory_usage)\","
        echo "  \"disk_usage\": \"$(get_disk_usage)\","
        echo "  \"temperature\": \"$(get_temperature)\""
        echo "}"
        ;;
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo "Options:"
        echo "  --once, -o     Show status once and exit"
        echo "  --json, -j     Output status in JSON format"
        echo "  --help, -h     Show this help message"
        echo ""
        echo "Without options, runs in interactive mode"
        ;;
    *)
        interactive_mode
        ;;
esac
