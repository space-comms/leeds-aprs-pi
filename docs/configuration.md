# Leeds APRS Pi Documentation
**Configuration Reference**

---

## Configuration Overview

The Leeds APRS Pi system uses multiple configuration files to control different aspects of the APRS operation. This guide provides comprehensive reference for all configuration options.

---

## Docker Compose Configuration

### File Location
`docker-compose.yml`

### Environment Variables

#### Required Settings
```yaml
environment:
  - CALLSIGN=G0ABC                    # Your amateur radio callsign
  - APRS_PASS=12345                   # APRS-IS passcode
  - LAT=53.8008                       # Latitude (decimal degrees)
  - LON=-1.5491                       # Longitude (decimal degrees)
```

#### Optional Settings
```yaml
environment:
  - BEACON_MESSAGE=Leeds Space Comms APRS Node
  - BEACON_INTERVAL=600               # Beacon interval in seconds
  - SYMBOL_TABLE=/                    # APRS symbol table (/ or \)
  - SYMBOL_CODE=&                     # APRS symbol code
  - TZ=Europe/London                  # Timezone
```

#### Advanced Settings
```yaml
environment:
  - DIREWOLF_OPTS=-d k -d n          # Additional Direwolf options
  - APRS_SERVER=noam.aprs2.net       # APRS-IS server
  - APRS_PORT=14580                  # APRS-IS port
  - FILTER_RADIUS=50                 # APRS filter radius (km)
  - LOG_LEVEL=INFO                   # Logging level
```

### Volume Mounts
```yaml
volumes:
  - ./config:/app/config:ro          # Configuration files
  - ./scripts:/app/scripts:ro        # Startup scripts
  - ./logs:/app/logs:rw              # Log files
  - ./data:/app/data:rw              # Persistent data
```

### Device Mapping
```yaml
devices:
  - "/dev/bus/usb:/dev/bus/usb"      # RTL-SDR access
  - "/dev/ttyUSB0:/dev/ttyUSB0"      # GPS device
  - "/dev/ttyACM0:/dev/ttyACM0"      # Alternative GPS interface
```

---

## Direwolf Configuration

### File Location
`config/direwolf.conf`

### Station Configuration
```bash
# Station identification
MYCALL G0ABC                         # Your callsign
MODEM 1200                          # Modem speed (1200 baud)
```

### Audio Configuration
```bash
# Audio device settings
ADEVICE plughw:0,0                  # Audio device
ARATE 44100                         # Sample rate
```

### RTL-SDR Configuration
```bash
# RTL-SDR settings
CHANNEL 0                           # Channel number
MODEM 1200                          # Modem type
MARK 1200                           # Mark frequency
SPACE 2200                          # Space frequency
```

### APRS-IS Configuration
```bash
# Internet gateway settings
IGSERVER noam.aprs2.net             # APRS-IS server
IGLOGIN G0ABC 12345                 # Callsign and passcode
FILTER r/53.8008/-1.5491/50         # Geographic filter
```

### Beacon Configuration
```bash
# Position beacon
PBEACON delay=1 every=600 lat=53.8008 lon=-1.5491 symbol="/&" \
        comment="Leeds Space Comms APRS Node"

# GPS beacon (if GPS available)
GPSBEACON delay=1 every=600 symbol="/>" \
          comment="Leeds Space Comms Mobile"
```

### Digipeater Configuration
```bash
# Digipeater settings
DIGIPEAT 0 0 ^WIDE[3-7]-[1-7]$|^TEST$ ^WIDE[12]-[12]$ TRACE
```

### Advanced Options
```bash
# Fix bits mode for weak signals
FIX_BITS 1

# Multiple decoders
MODEM 0 1200
MODEM 1 300

# PTT control
PTT GPIO 23

# VOX control
VOX 30
```

---

## Beacon Configuration

### File Location
`config/beacon.conf`

### Basic Settings
```bash
# Station information
CALLSIGN=G0ABC
APRS_PASS=12345
LATITUDE=53.8008
LONGITUDE=-1.5491
ALTITUDE=100
```

### Beacon Content
```bash
# Beacon messages
BEACON_MESSAGE="Leeds Space Comms APRS Node"
BEACON_COMMENT="Educational APRS station - University of Leeds"
BEACON_URL="https://leedsspace.com"
```

### Timing Configuration
```bash
# Beacon timing
BEACON_INTERVAL=600                 # 10 minutes
BEACON_DELAY=60                     # Initial delay
GPS_BEACON_INTERVAL=300             # GPS beacon interval
```

### Symbol Configuration
```bash
# APRS symbols
SYMBOL_TABLE="/"                    # Primary table
SYMBOL_CODE="&"                     # Gateway symbol
GPS_SYMBOL=">"                      # Mobile symbol
```

### Multiple Profiles
```bash
# Profile definitions
[PROFILE_FIXED]
MESSAGE="Leeds Space Comms - Fixed Station"
SYMBOL="&"
INTERVAL=600

[PROFILE_MOBILE]
MESSAGE="Leeds Space Comms - Mobile"
SYMBOL=">"
INTERVAL=300
```

---

## Hardware-Specific Configuration

### RTL-SDR Configuration
```bash
# RTL-SDR specific settings
CHANNEL 0
MODEM 1200
FIX_BITS 1 0 0x24 0x7E

# Multiple decoders for better reception
MODEM 0 1200
MODEM 1 300
```

### Audio Interface Configuration
```bash
# Audio device configuration
ADEVICE plughw:1,0                  # USB audio interface
ARATE 44100                         # Sample rate
AGWPORT 8000                        # AGW port
KISSPORT 8001                       # KISS port
```

### GPS Configuration
```bash
# GPS device settings
GPS_DEVICE="/dev/ttyUSB0"           # GPS device path
GPS_BAUD=4800                       # GPS baud rate
GPS_TIMEOUT=30                      # GPS timeout
```

---

## Network Configuration

### APRS-IS Settings
```bash
# Primary server
APRS_SERVER="noam.aprs2.net"
APRS_PORT=14580

# Backup server
APRS_BACKUP_SERVER="euro.aprs2.net"

# Connection options
APRS_TIMEOUT=30
APRS_RETRY=5
```

### Firewall Configuration
```bash
# Required ports
# Incoming
8000/tcp    # AGW interface
8001/tcp    # KISS interface
8080/tcp    # Web interface

# Outgoing
14580/tcp   # APRS-IS
123/udp     # NTP
53/udp      # DNS
```

---

## Logging Configuration

### Log Levels
```bash
# Available log levels
LOG_LEVEL=DEBUG     # Detailed debugging
LOG_LEVEL=INFO      # General information
LOG_LEVEL=WARNING   # Warning messages
LOG_LEVEL=ERROR     # Error messages only
```

### Log Files
```bash
# Log file locations
LOGDIR=/app/logs
LOGFILE=direwolf.log
BEACON_LOG_FILE=beacon.log
MONITOR_LOG_FILE=monitor.log
```

### Log Rotation
```bash
# Log rotation settings
LOG_MAX_SIZE=10M        # Maximum log file size
LOG_MAX_FILES=5         # Number of rotated files
LOG_ROTATE_INTERVAL=24  # Hours between rotation
```

---

## Performance Tuning

### CPU Optimization
```bash
# Reduce CPU usage
MODEM 1200              # Single modem
ARATE 22050             # Lower sample rate
FIX_BITS 0              # Disable fix bits
```

### Memory Optimization
```bash
# Memory settings
AUDIO_BUFFER_SIZE=1024  # Audio buffer size
PACKET_BUFFER_SIZE=256  # Packet buffer size
```

### Network Optimization
```bash
# Network settings
IGSERVER noam.aprs2.net # Close server
FILTER r/53.8008/-1.5491/25  # Smaller filter radius
```

---

## Security Configuration

### User Permissions
```bash
# Required groups
audio       # Audio device access
dialout     # Serial device access
docker      # Docker access
```

### File Permissions
```bash
# Configuration files
chmod 644 config/*.conf
chmod 755 scripts/*.sh
chmod 755 logs/
```

### Network Security
```bash
# Firewall rules
ufw allow 8000/tcp      # AGW interface
ufw allow 8001/tcp      # KISS interface
ufw allow 8080/tcp      # Web interface
```

---

## Monitoring Configuration

### Health Checks
```bash
# Health check intervals
CHECK_INTERVAL=30           # Service check interval
HEALTH_INTERVAL=300         # Health metrics interval
LOG_ROTATION_INTERVAL=3600  # Log rotation interval
```

### Alert Thresholds
```bash
# System thresholds
CPU_THRESHOLD=80            # CPU usage alert
MEMORY_THRESHOLD=90         # Memory usage alert
DISK_THRESHOLD=85           # Disk usage alert
TEMP_THRESHOLD=75           # Temperature alert
```

### Monitoring Endpoints
```bash
# Monitoring ports
STATUS_PORT=8002            # Status endpoint
METRICS_PORT=8003           # Metrics endpoint
HEALTH_PORT=8004            # Health check endpoint
```

---

## Backup Configuration

### Backup Settings
```bash
# Backup directories
BACKUP_DIR=/app/backups
CONFIG_BACKUP=daily
LOG_BACKUP=weekly
DATA_BACKUP=monthly
```

### Backup Retention
```bash
# Retention periods
DAILY_RETENTION=7           # Days
WEEKLY_RETENTION=4          # Weeks
MONTHLY_RETENTION=12        # Months
```

---

## Troubleshooting Configuration

### Debug Settings
```bash
# Debug options
DEBUG_LEVEL=3               # Direwolf debug level
VERBOSE_LOGGING=true        # Verbose logging
PACKET_LOGGING=true         # Log all packets
```

### Test Mode
```bash
# Test configuration
TEST_MODE=false             # Enable test mode
SIMULATION=false            # Simulation mode
DRY_RUN=false              # Dry run mode
```

---

## Configuration Validation

### Syntax Checking
```bash
# Validate configuration
direwolf -c config/direwolf.conf -t

# Check Docker Compose
docker-compose config

# Validate beacon config
scripts/validate-config.sh
```

### Configuration Testing
```bash
# Test configuration
scripts/test-config.sh

# Validate hardware
scripts/hardware-test.sh

# Check network connectivity
scripts/network-test.sh
```

---

*This configuration reference is maintained by Leeds Space Comms for the amateur radio community.*
