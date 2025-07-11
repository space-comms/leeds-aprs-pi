# Leeds APRS Pi - Complete Setup Guide

## 📋 Overview

This guide provides comprehensive instructions for setting up the Leeds APRS Pi system across different platforms and use cases. Whether you're a student, instructor, or amateur radio operator, this guide will help you get your APRS station operational quickly and efficiently.

## 🎯 Pre-Installation Checklist

### Required Information
- [ ] **Amateur Radio Callsign** (required for transmission)
- [ ] **APRS-IS Passcode** (obtain from [aprs.fi](https://aprs.fi))
- [ ] **Station Location** (latitude and longitude in decimal degrees)
- [ ] **Beacon Message** (custom message for your station)

### Hardware Requirements
- [ ] **Raspberry Pi 3B+** or newer (Pi 4 recommended)
- [ ] **MicroSD Card** (8GB minimum, 16GB+ recommended)
- [ ] **Power Supply** (official Pi adapter recommended)
- [ ] **Internet Connection** (Ethernet or Wi-Fi)
- [ ] **Monitor/Keyboard** (for initial setup)

### Optional Hardware
- [ ] **RTL-SDR Dongle** (for APRS packet reception)
- [ ] **USB GPS Module** (for mobile operation)
- [ ] **USB Audio Interface** (for radio connections)
- [ ] **Ham Radio Transceiver** (for two-way operation)

## 🚀 Installation Methods

### Method 1: Quick Start with Docker Compose (Recommended)

This method is perfect for users who want to get up and running quickly with minimal configuration.

#### Step 1: Prepare Your System
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Docker and Docker Compose
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
sudo pip3 install docker-compose

# Logout and login again for group changes to take effect
```

#### Step 2: Download and Configure
```bash
# Clone the repository
git clone https://github.com/leedsspace/leeds-aprs-pi.git
cd leeds-aprs-pi

# Copy example configuration
cp docker-compose.yml docker-compose.yml.backup

# Edit configuration with your settings
nano docker-compose.yml
```

#### Step 3: Configure Your Station
Update the following environment variables in `docker-compose.yml`:
```yaml
environment:
  - CALLSIGN=YOUR_CALLSIGN        # Replace with your callsign
  - APRS_PASS=YOUR_PASSCODE       # Replace with your APRS passcode
  - LAT=YOUR_LATITUDE             # Replace with your latitude
  - LON=YOUR_LONGITUDE            # Replace with your longitude
  - BEACON_MESSAGE=Your Custom Message Here
  - BEACON_INTERVAL=600           # Beacon every 10 minutes
  - TZ=America/New_York           # Set your timezone
```

#### Step 4: Start the System
```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

#### Step 5: Access the Web Interface
Open your web browser and navigate to:
- **Dashboard**: http://localhost:8080
- **API Status**: http://localhost:8000/api/health

### Method 2: Automated Setup Script

This method uses an interactive script that automatically detects your hardware and configures the system.

#### Step 1: Download and Run Setup Script
```bash
# Download the setup script
curl -fsSL https://raw.githubusercontent.com/leedsspace/leeds-aprs-pi/main/scripts/setup.sh -o setup.sh

# Make it executable
chmod +x setup.sh

# Run the setup script
sudo ./setup.sh
```

#### Step 2: Follow Interactive Prompts
The script will guide you through:
1. **Hardware Detection**: Automatic detection of RTL-SDR, GPS, and audio devices
2. **Station Configuration**: Input your callsign, location, and preferences
3. **System Setup**: Installation of dependencies and configuration
4. **Service Installation**: Setup of systemd services for automatic startup

#### Step 3: Verify Installation
```bash
# Check service status
sudo systemctl status leeds-aprs-pi

# View system logs
sudo journalctl -u leeds-aprs-pi -f

# Test web interface
curl -s http://localhost:8080/api/health | python3 -m json.tool
```

### Method 3: Pre-built Raspberry Pi Image

This method uses a pre-configured Raspberry Pi image with everything already set up.

#### Step 1: Download Pre-built Image
```bash
# Download latest image
wget https://github.com/leedsspace/leeds-aprs-pi/releases/latest/download/leeds-aprs-pi.img.gz

# Verify checksum (optional but recommended)
wget https://github.com/leedsspace/leeds-aprs-pi/releases/latest/download/SHA256SUMS
sha256sum -c SHA256SUMS --ignore-missing
```

#### Step 2: Flash to SD Card
```bash
# Using dd (Linux/macOS)
gunzip -c leeds-aprs-pi.img.gz | sudo dd of=/dev/sdX bs=4M status=progress

# Using Raspberry Pi Imager (recommended)
# Download from https://rpi.org/imager
# Select "Use custom image" and choose the downloaded .img.gz file
```

#### Step 3: First Boot Configuration
1. **Insert SD card** into Raspberry Pi and power on
2. **Connect to Wi-Fi hotspot** named "Leeds-APRS-Setup"
3. **Open web browser** and navigate to http://192.168.4.1
4. **Complete setup wizard** with your station information
5. **System will reboot** and start APRS services automatically

## ⚙️ Detailed Configuration

### Station Configuration

#### Basic Station Setup
```yaml
# docker-compose.yml
environment:
  - CALLSIGN=W1ABC                    # Your amateur radio callsign
  - APRS_PASS=12345                   # Your APRS-IS passcode
  - LAT=42.3601                       # Latitude in decimal degrees
  - LON=-71.0589                      # Longitude in decimal degrees
  - BEACON_MESSAGE=Boston APRS Node   # Custom beacon message
  - BEACON_INTERVAL=600               # Beacon every 10 minutes
  - SYMBOL_TABLE=/                    # Primary symbol table
  - SYMBOL_CODE=&                     # Gateway/Node symbol
  - TZ=America/New_York               # Your timezone
```

#### Mobile Station Setup
```yaml
# For mobile/portable operation
environment:
  - CALLSIGN=W1ABC/M                  # Mobile suffix
  - BEACON_MESSAGE=Mobile APRS        # Mobile identifier
  - BEACON_INTERVAL=300               # More frequent beacons
  - SYMBOL_CODE=>                     # Car symbol
  - GPS_ENABLED=true                  # Enable GPS tracking
```

#### Educational/Lab Setup
```yaml
# For classroom/lab use
environment:
  - CALLSIGN=W1ABC/EDU                # Educational suffix
  - BEACON_MESSAGE=University Lab     # Educational identifier
  - BEACON_COMMENT=For Educational Use Only
  - BEACON_INTERVAL=900               # Less frequent beacons
  - SYMBOL_CODE=E                     # Educational symbol
```

### Hardware Configuration

#### RTL-SDR Configuration
```yaml
# docker-compose.yml
services:
  aprs:
    devices:
      - "/dev/bus/usb:/dev/bus/usb"   # USB device access
    environment:
      - RTL_SDR_ENABLED=true          # Enable RTL-SDR
      - RTL_SDR_DEVICE=0              # Device index
      - RTL_SDR_FREQUENCY=144390000   # 144.39 MHz (APRS frequency)
      - RTL_SDR_GAIN=40               # RF gain setting
```

#### GPS Configuration
```yaml
# docker-compose.yml
services:
  aprs:
    devices:
      - "/dev/ttyUSB0:/dev/ttyUSB0"   # GPS device
    environment:
      - GPS_ENABLED=true              # Enable GPS
      - GPS_DEVICE=/dev/ttyUSB0       # GPS device path
      - GPS_BAUD=4800                 # GPS baud rate
```

#### Audio Configuration
```yaml
# docker-compose.yml
services:
  aprs:
    devices:
      - "/dev/snd:/dev/snd"           # Audio device access
    environment:
      - AUDIO_ENABLED=true            # Enable audio
      - AUDIO_DEVICE=hw:1,0           # Audio device
      - AUDIO_RATE=44100              # Sample rate
      - PTT_GPIO=23                   # PTT control GPIO pin
```

### Advanced Configuration

#### Direwolf Configuration
Create or modify `config/direwolf.conf`:
```conf
# Station identification
MYCALL W1ABC
MODEM 1200 1200 7 /4

# Audio configuration
ADEVICE plughw:1,0
ARATE 44100

# PTT control
PTT GPIO 23

# APRS-IS configuration
IGSERVER noam.aprs2.net
IGLOGIN W1ABC 12345
FILTER r/42.3601/-71.0589/50

# Beacon configuration
PBEACON delay=1 every=600 lat=42.3601 lon=-71.0589 symbol="/&" comment="Boston APRS Node"

# Digipeater configuration
DIGIPEAT 0 0 ^WIDE[3-7]-[1-7]$|^TEST$ ^WIDE[12]-[12]$ TRACE

# Logging
LOGDIR /app/logs
LOGFILE direwolf.log
```

## 🔧 Hardware Setup

### RTL-SDR Setup

#### Supported Devices
- **RTL2832U-based dongles** (most common)
- **NooElec NESDR series**
- **FlightAware dongles**
- **Generic RTL-SDR dongles**

#### Setup Steps
1. **Connect RTL-SDR** to USB port
2. **Verify detection**: `lsusb | grep RTL`
3. **Test functionality**: `rtl_test -t`
4. **Configure frequency**: Edit `RTL_SDR_FREQUENCY` in docker-compose.yml

#### Common Issues
```bash
# Issue: Device not detected
# Solution: Check USB connection and permissions
sudo chmod 666 /dev/bus/usb/*/*

# Issue: Permission denied
# Solution: Add user to plugdev group
sudo usermod -aG plugdev $USER
```

### GPS Setup

#### Supported Devices
- **u-blox modules** (NEO-6M, NEO-8M, etc.)
- **Generic NMEA GPS modules**
- **USB GPS receivers**
- **Hat/Shield GPS modules**

#### Setup Steps
1. **Connect GPS module** to USB or GPIO
2. **Verify connection**: `ls /dev/ttyUSB* /dev/ttyACM*`
3. **Test GPS data**: `cat /dev/ttyUSB0`
4. **Configure GPS daemon**: Edit `/etc/default/gpsd`

#### GPS Configuration
```bash
# Install GPS daemon
sudo apt install gpsd gpsd-clients

# Configure GPS daemon
sudo nano /etc/default/gpsd
# Add: DEVICES="/dev/ttyUSB0"
# Add: GPSD_OPTIONS="-n"

# Start GPS daemon
sudo systemctl enable gpsd
sudo systemctl start gpsd

# Test GPS functionality
gpsmon
```

### Audio Interface Setup

#### Supported Interfaces
- **USB sound cards** (Class-compliant)
- **Raspberry Pi built-in audio** (limited functionality)
- **Hat/Shield audio interfaces**
- **Professional audio interfaces**

#### Setup Steps
1. **Connect audio interface** to USB
2. **Verify detection**: `aplay -l`
3. **Test audio**: `arecord -D hw:1,0 -f cd test.wav`
4. **Configure audio levels**: `alsamixer`

#### Audio Configuration
```bash
# List audio devices
aplay -l
arecord -l

# Test audio playback
speaker-test -c 2 -t wav

# Configure audio levels
alsamixer

# Save audio settings
sudo alsactl store
```

## 🌐 Network Configuration

### APRS-IS Server Selection

#### Regional Servers
- **North America**: `noam.aprs2.net`
- **Europe**: `euro.aprs2.net`
- **Asia**: `asia.aprs2.net`
- **Australia**: `aunz.aprs2.net`
- **Global**: `rotate.aprs2.net`

#### Server Configuration
```yaml
# docker-compose.yml
environment:
  - APRS_SERVER=noam.aprs2.net      # Regional server
  - APRS_PORT=14580                 # Standard APRS-IS port
  - APRS_FILTER=r/42.3601/-71.0589/50  # 50km radius filter
```

### Firewall Configuration

#### Basic Firewall Setup
```bash
# Install UFW firewall
sudo apt install ufw

# Allow SSH
sudo ufw allow ssh

# Allow web interface
sudo ufw allow 8080/tcp

# Allow API access
sudo ufw allow 8000/tcp

# Enable firewall
sudo ufw enable
```

#### Advanced Firewall Rules
```bash
# Allow APRS-IS connection
sudo ufw allow out 14580/tcp

# Allow specific IP ranges
sudo ufw allow from 192.168.1.0/24 to any port 8080

# Log dropped packets
sudo ufw logging on
```

## 📱 Web Interface Setup

### Accessing the Dashboard

#### Local Access
- **Primary URL**: http://localhost:8080
- **IP Address**: http://192.168.1.100:8080 (replace with your Pi's IP)
- **Hostname**: http://raspberrypi.local:8080

#### Remote Access
```bash
# Find your Pi's IP address
hostname -I

# Access from another device
# http://[PI_IP_ADDRESS]:8080
```

### Mobile Configuration

#### Responsive Design
The web interface is fully responsive and works on:
- **Smartphones** (iOS and Android)
- **Tablets** (iPad, Android tablets)
- **Desktop browsers** (Chrome, Firefox, Safari, Edge)

#### Mobile Optimization
- **Touch-friendly interface**
- **Optimized layouts** for small screens
- **Fast loading times**
- **Offline capability** for basic monitoring

## 🎓 Educational Setup

### Classroom Deployment

#### Multi-Station Setup
```bash
# Deploy to multiple stations
./scripts/deploy-classroom.sh \
  --stations 20 \
  --callsign-prefix "W1ABC" \
  --location "Electronics Lab" \
  --subnet "192.168.100.0/24"
```

#### Lab Exercise Configuration
```bash
# Configure for APRS protocol analysis
./scripts/configure-exercise.sh \
  --exercise "protocol-analysis" \
  --duration 120 \
  --students 25

# Configure for beacon timing exercise
./scripts/configure-exercise.sh \
  --exercise "beacon-timing" \
  --interval 60 \
  --variation 10
```

### Student Access

#### Individual Student Setup
```yaml
# docker-compose.student.yml
environment:
  - CALLSIGN=W1ABC/STU01            # Student callsign
  - BEACON_MESSAGE=Student Project  # Student identifier
  - BEACON_INTERVAL=1800            # 30-minute intervals
  - LOG_LEVEL=DEBUG                 # Detailed logging
  - STUDENT_MODE=true               # Enable student features
```

#### Assessment Integration
```bash
# Generate assessment configuration
./scripts/generate-assessment.sh \
  --type "practical" \
  --duration 180 \
  --students 30 \
  --auto-grade true

# Monitor student progress
./scripts/monitor-assessment.sh \
  --assessment-id "aprs-lab-001" \
  --display-progress true
```

## 🔍 Testing and Verification

### System Testing

#### Basic Functionality Test
```bash
# Test Docker containers
docker-compose ps

# Test web interface
curl -s http://localhost:8080/api/health

# Test APRS functionality
./scripts/test-aprs.sh
```

#### Hardware Testing
```bash
# Test RTL-SDR
./scripts/test-rtl-sdr.sh

# Test GPS
./scripts/test-gps.sh

# Test audio
./scripts/test-audio.sh
```

#### Network Testing
```bash
# Test APRS-IS connectivity
./scripts/test-aprs-is.sh

# Test web interface
./scripts/test-web-interface.sh

# Test API endpoints
./scripts/test-api.sh
```

### Performance Testing

#### Resource Usage
```bash
# Monitor system resources
htop

# Monitor Docker containers
docker stats

# Generate performance report
./scripts/generate-performance-report.sh
```

#### Stress Testing
```bash
# Stress test web interface
./scripts/stress-test-web.sh --concurrent-users 50

# Stress test API
./scripts/stress-test-api.sh --requests-per-second 100

# Long-running stability test
./scripts/stability-test.sh --duration 24h
```

## 🛠️ Troubleshooting

### Common Issues and Solutions

#### Docker Issues
```bash
# Issue: Docker service not running
sudo systemctl start docker
sudo systemctl enable docker

# Issue: Permission denied
sudo usermod -aG docker $USER
# Logout and login again

# Issue: Container build fails
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

#### Network Issues
```bash
# Issue: Can't access web interface
# Check firewall
sudo ufw status

# Check port availability
sudo netstat -tulpn | grep :8080

# Check container networking
docker network ls
docker inspect leeds-aprs-pi_default
```

#### Hardware Issues
```bash
# Issue: RTL-SDR not detected
# Check USB connection
lsusb | grep RTL

# Check permissions
sudo chmod 666 /dev/bus/usb/*/*

# Test RTL-SDR
rtl_test -t
```

### Debug Mode

#### Enable Debug Logging
```bash
# Set debug environment variables
export DEBUG=1
export LOG_LEVEL=DEBUG

# Start with debug logging
docker-compose -f docker-compose.debug.yml up

# View detailed logs
docker-compose logs -f
```

#### Hardware Diagnostics
```bash
# Run comprehensive hardware diagnostic
./scripts/diagnose-hardware.sh

# Generate diagnostic report
./scripts/generate-diagnostic-report.sh
```

## 📊 Monitoring and Maintenance

### System Monitoring

#### Regular Monitoring
```bash
# Check system status
./scripts/status.sh

# Monitor resource usage
./scripts/monitor-resources.sh

# Check log files
./scripts/check-logs.sh
```

#### Automated Monitoring
```bash
# Set up monitoring cron job
crontab -e
# Add: */5 * * * * /opt/leeds-aprs-pi/scripts/monitor.sh

# Set up log rotation
sudo nano /etc/logrotate.d/leeds-aprs-pi
```

### System Maintenance

#### Regular Updates
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Update Docker images
docker-compose pull
docker-compose up -d

# Update application
git pull origin main
docker-compose build
docker-compose up -d
```

#### Backup and Recovery
```bash
# Backup configuration
./scripts/backup-config.sh

# Backup logs and data
./scripts/backup-data.sh

# Restore from backup
./scripts/restore-backup.sh --backup-file backup-20231215.tar.gz
```

## 🎯 Next Steps

### After Successful Installation

1. **Verify Operation**
   - Check web interface at http://localhost:8080
   - Monitor system logs for any errors
   - Test APRS beacon transmission

2. **Customize Configuration**
   - Adjust beacon intervals and messages
   - Configure hardware-specific settings
   - Set up monitoring and alerting

3. **Explore Advanced Features**
   - Set up digipeater functionality
   - Configure additional APRS applications
   - Integrate with other amateur radio software

## 📞 Support and Resources

### Getting Help

#### Technical Support
- **GitHub Issues**: https://github.com/leedsspace/leeds-aprs-pi/issues
- **Community Forums**: Amateur radio communities and forums
- **Documentation**: Comprehensive guides in `/docs/` directory



---

**This setup guide is maintained by the Leeds Space Communications Society. For questions, suggestions, or support, please visit our GitHub repository or contact the maintainers directly.**

**Good luck with your APRS adventures! 73 de Leeds Space Comms! 🚀**