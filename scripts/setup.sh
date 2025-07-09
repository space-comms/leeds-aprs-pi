#!/bin/bash

#
# Changelog - setup.sh
#
# [Initial]
# - Initial setup script for Leeds APRS Pi system
# - Hardware detection and configuration
# - Dependency installation and verification
# - Docker environment preparation
# - User permission and group setup
# - Configuration file generation
# - System service installation
#
# [Purpose]
# - Automates initial system setup on fresh Raspberry Pi
# - Handles hardware detection and driver installation
# - Configures system for optimal APRS operation
# - Provides guided setup for new users
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

# Welcome banner
cat << 'EOF'
 _               _        _    ____  ____  ____      ____  _ 
| |   ___  ___  __| |___   / \  |  _ \|  _ \/ ___|    |  _ \(_)
| |  / _ \/ _ \/ _` / __| / _ \ | |_) | |_) \___ \    | |_) | |
| | |  __/  __/ (_| \__ \/ ___ \|  __/|  _ < ___) |___|  __/| |
|_|  \___|\___|\__,_|___/_/   \_\_|   |_| \_\____/_____|_|   |_|

Leeds Space Comms - APRS System Setup
====================================
EOF

log "Starting system setup..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "This script must be run as root (use sudo)"
    exit 1
fi

# Check if running on Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
    warn "This system may not be a Raspberry Pi"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Update system packages
log "Updating system packages..."
apt-get update && apt-get upgrade -y

# Install required packages
log "Installing required packages..."
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    usbutils \
    alsa-utils \
    gpsd \
    gpsd-clients \
    rtl-sdr \
    build-essential \
    python3 \
    python3-pip

# Install Docker
log "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    success "Docker installed successfully"
else
    log "Docker already installed"
fi

# Install Docker Compose
log "Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    pip3 install docker-compose
    success "Docker Compose installed successfully"
else
    log "Docker Compose already installed"
fi

# Add user to docker group
log "Configuring user permissions..."
if [ -n "$SUDO_USER" ]; then
    usermod -aG docker $SUDO_USER
    usermod -aG audio $SUDO_USER
    usermod -aG dialout $SUDO_USER
    success "User $SUDO_USER added to required groups"
else
    warn "SUDO_USER not set, please manually add your user to docker, audio, and dialout groups"
fi

# Enable required services
log "Enabling system services..."
systemctl enable docker
systemctl start docker

# Hardware detection and setup
log "Detecting hardware..."

# Check for RTL-SDR
if lsusb | grep -q "RTL"; then
    success "RTL-SDR device detected"
    
    # Configure RTL-SDR
    log "Configuring RTL-SDR..."
    
    # Create udev rules for RTL-SDR
    cat > /etc/udev/rules.d/20-rtl-sdr.rules << 'EOF'
# RTL-SDR device rules
SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP="plugdev", MODE="0666", SYMLINK+="rtl_sdr"
EOF
    
    # Reload udev rules
    udevadm control --reload-rules
    udevadm trigger
    
    success "RTL-SDR configured"
else
    warn "No RTL-SDR device found"
fi

# Check for GPS device
if [ -e /dev/ttyUSB0 ] || [ -e /dev/ttyACM0 ]; then
    success "GPS device detected"
    
    # Configure GPS
    log "Configuring GPS..."
    
    # Create GPS configuration
    cat > /etc/default/gpsd << 'EOF'
# GPS daemon configuration
DEVICES=""
USBAUTO="true"
GPSD_OPTIONS="-n -G"
EOF
    
    # Enable GPS daemon
    systemctl enable gpsd
    
    success "GPS configured"
else
    warn "No GPS device found"
fi

# Check for audio devices
if [ -e /dev/snd/controlC0 ]; then
    success "Audio device detected"
    
    # Configure audio
    log "Configuring audio..."
    
    # Set default audio levels
    amixer set Master 80% 2>/dev/null || true
    amixer set PCM 80% 2>/dev/null || true
    
    success "Audio configured"
else
    warn "No audio device found"
fi

# Create application directory
log "Creating application directory..."
mkdir -p /opt/leeds-aprs-pi
cd /opt/leeds-aprs-pi

# Clone or copy application files
if [ -d "/home/$SUDO_USER/leeds-aprs-pi" ]; then
    log "Copying application files..."
    cp -r /home/$SUDO_USER/leeds-aprs-pi/* .
else
    warn "Application files not found in expected location"
fi

# Set proper permissions
chown -R $SUDO_USER:$SUDO_USER /opt/leeds-aprs-pi
chmod +x scripts/*.sh

# Create log directory
mkdir -p /var/log/aprs
chown $SUDO_USER:$SUDO_USER /var/log/aprs

# Create systemd service
log "Creating systemd service..."
cat > /etc/systemd/system/leeds-aprs-pi.service << 'EOF'
[Unit]
Description=Leeds APRS Pi Docker Service
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/leeds-aprs-pi
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
TimeoutStartSec=0
User=pi
Group=pi

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
systemctl daemon-reload
systemctl enable leeds-aprs-pi

# Interactive configuration
log "Starting interactive configuration..."

echo
echo "Please provide your station information:"
echo

# Get callsign
while true; do
    read -p "Enter your amateur radio callsign: " CALLSIGN
    if [[ $CALLSIGN =~ ^[A-Z0-9]{3,7}$ ]]; then
        break
    else
        error "Invalid callsign format. Please use only letters and numbers (3-7 characters)."
    fi
done

# Get APRS passcode
while true; do
    read -p "Enter your APRS-IS passcode: " APRS_PASS
    if [[ $APRS_PASS =~ ^[0-9]{1,5}$ ]]; then
        break
    else
        error "Invalid passcode. Please enter a numeric passcode."
    fi
done

# Get location
read -p "Enter your latitude (default: 53.8008): " LAT
LAT=${LAT:-53.8008}

read -p "Enter your longitude (default: -1.5491): " LON
LON=${LON:--1.5491}

read -p "Enter your beacon message (default: Leeds Space Comms APRS Node): " BEACON_MESSAGE
BEACON_MESSAGE=${BEACON_MESSAGE:-"Leeds Space Comms APRS Node"}

# Update docker-compose.yml with user settings
log "Updating configuration..."
sed -i "s/CALLSIGN=G0ABC/CALLSIGN=$CALLSIGN/g" docker-compose.yml
sed -i "s/APRS_PASS=12345/APRS_PASS=$APRS_PASS/g" docker-compose.yml
sed -i "s/LAT=53.8008/LAT=$LAT/g" docker-compose.yml
sed -i "s/LON=-1.5491/LON=$LON/g" docker-compose.yml
sed -i "s/BEACON_MESSAGE=Leeds Space Comms APRS Node/BEACON_MESSAGE=$BEACON_MESSAGE/g" docker-compose.yml

# Build Docker image
log "Building Docker image..."
docker-compose build

# Final instructions
cat << EOF

${GREEN}Setup completed successfully!${NC}

Your Leeds APRS Pi system is now configured with:
- Callsign: $CALLSIGN
- Location: $LAT, $LON
- Beacon Message: $BEACON_MESSAGE

${YELLOW}Next steps:${NC}
1. Reboot your Raspberry Pi to apply all changes
2. After reboot, the service will start automatically
3. Check service status with: systemctl status leeds-aprs-pi
4. View logs with: docker-compose logs -f
5. Access web interface at: http://localhost:8080

${YELLOW}Manual control:${NC}
- Start: sudo systemctl start leeds-aprs-pi
- Stop: sudo systemctl stop leeds-aprs-pi
- Restart: sudo systemctl restart leeds-aprs-pi

${YELLOW}Configuration files:${NC}
- Main config: /opt/leeds-aprs-pi/docker-compose.yml
- Direwolf config: /opt/leeds-aprs-pi/config/direwolf.conf
- Beacon config: /opt/leeds-aprs-pi/config/beacon.conf

${BLUE}Happy APRS-ing from Leeds Space Comms!${NC}
EOF

# Ask if user wants to reboot now
echo
read -p "Reboot now to complete setup? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Rebooting system..."
    reboot
else
    log "Please reboot manually to complete setup"
fi
