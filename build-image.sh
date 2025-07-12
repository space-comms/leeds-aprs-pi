#!/bin/bash
#
# Leeds APRS Pi - SD Card Image Builder
# Creates ready-to-flash Raspberry Pi images with APRS software pre-installed
#

set -e

# Configuration
BUILD_DIR="$(pwd)/build"
IMAGE_NAME="leeds-aprs-pi"
VERSION="1.2.0"
PI_OS_URL="https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2024-03-15/2024-03-15-raspios-bookworm-arm64-lite.img.xz"
IMAGE_SIZE="4GB"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Banner
cat << 'EOF'
 _               _        _    ____  ____  ____      ____  _ 
| |   ___  ___  __| |___   / \  |  _ \|  _ \/ ___|    |  _ \(_)
| |  / _ \/ _ \/ _` / __| / _ \ | |_) | |_) \___ \    | |_) | |
| | |  __/  __/ (_| \__ \/ ___ \|  __/|  _ < ___) |___|  __/| |
|_|  \___|\___|\__,_|___/_/   \_\_|   |_| \_\____/_____|_|   |_|

Leeds APRS Pi - Image Builder v1.2.0
=====================================
EOF

# Check dependencies
check_deps() {
    log "Checking dependencies..."
    local deps=("curl" "xz" "qemu-user-static" "kpartx" "parted")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            error "Required dependency not found: $dep"
            exit 1
        fi
    done
    success "All dependencies found"
}

# Download base Raspberry Pi OS
download_base_image() {
    log "Downloading Raspberry Pi OS..."
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    if [ ! -f "raspios-base.img.xz" ]; then
        curl -L "$PI_OS_URL" -o "raspios-base.img.xz"
        success "Base image downloaded"
    else
        log "Base image already exists"
    fi
    
    if [ ! -f "raspios-base.img" ]; then
        log "Extracting base image..."
        xz -d -k "raspios-base.img.xz"
        success "Base image extracted"
    fi
}

# Mount image for modification
mount_image() {
    log "Mounting image for modification..."
    
    # Create loop device
    LOOP_DEVICE=$(sudo losetup -f --show "raspios-base.img")
    log "Loop device: $LOOP_DEVICE"
    
    # Map partitions
    sudo kpartx -av "$LOOP_DEVICE"
    sleep 2
    
    # Mount partitions
    BOOT_MOUNT="$BUILD_DIR/boot"
    ROOT_MOUNT="$BUILD_DIR/root"
    mkdir -p "$BOOT_MOUNT" "$ROOT_MOUNT"
    
    sudo mount "/dev/mapper/$(basename $LOOP_DEVICE)p1" "$BOOT_MOUNT"
    sudo mount "/dev/mapper/$(basename $LOOP_DEVICE)p2" "$ROOT_MOUNT"
    
    success "Image mounted"
}

# Install APRS software and configuration
install_aprs_software() {
    log "Installing APRS software..."
    
    # Enable SSH
    sudo touch "$BOOT_MOUNT/ssh"
    
    # Configure WiFi for setup hotspot
    sudo tee "$BOOT_MOUNT/wpa_supplicant.conf" > /dev/null << 'EOF'
country=GB
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="Leeds-APRS-Setup"
    psk="aprssetup"
    mode=2
    key_mgmt=WPA-PSK
}
EOF

    # Install packages via chroot
    sudo cp /usr/bin/qemu-aarch64-static "$ROOT_MOUNT/usr/bin/"
    
    # Create install script
    sudo tee "$ROOT_MOUNT/install_aprs.sh" > /dev/null << 'EOF'
#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install dependencies
apt-get install -y \
    docker.io \
    docker-compose \
    direwolf \
    gpsd \
    gpsd-clients \
    rtl-sdr \
    hostapd \
    dnsmasq \
    git \
    python3 \
    python3-pip \
    nginx

# Install Python packages
pip3 install flask flask-cors

# Enable services
systemctl enable docker
systemctl enable ssh

# Create APRS user
useradd -m -s /bin/bash aprs
usermod -aG docker,audio,dialout,plugdev aprs

# Create directories
mkdir -p /opt/leeds-aprs-pi/{config,scripts,web,logs,data}
chown -R aprs:aprs /opt/leeds-aprs-pi

# Install APRS system files
EOF

    # Copy project files
    sudo cp -r ../config "$ROOT_MOUNT/opt/leeds-aprs-pi/"
    sudo cp -r ../scripts "$ROOT_MOUNT/opt/leeds-aprs-pi/"
    sudo cp -r ../web "$ROOT_MOUNT/opt/leeds-aprs-pi/"
    sudo cp ../docker-compose.yml "$ROOT_MOUNT/opt/leeds-aprs-pi/"
    sudo cp ../Dockerfile "$ROOT_MOUNT/opt/leeds-aprs-pi/"
    
    # Install first-boot configuration
    sudo tee "$ROOT_MOUNT/opt/leeds-aprs-pi/first-boot.sh" > /dev/null << 'EOF'
#!/bin/bash
#
# First boot configuration script
#

set -e

# Setup WiFi hotspot for initial configuration
setup_hotspot() {
    # Configure hostapd
    cat > /etc/hostapd/hostapd.conf << 'HOSTAPD'
interface=wlan0
driver=nl80211
ssid=Leeds-APRS-Setup
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=aprssetup
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
HOSTAPD

    # Configure dnsmasq
    cat > /etc/dnsmasq.conf << 'DNSMASQ'
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
address=/aprs.local/192.168.4.1
DNSMASQ

    # Configure network interface
    cat >> /etc/dhcpcd.conf << 'DHCPCD'
interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
DHCPCD

    # Enable services
    systemctl enable hostapd
    systemctl enable dnsmasq
}

# Setup web configuration interface
setup_web_config() {
    # Create simple web server for configuration
    mkdir -p /var/www/setup
    
    cat > /var/www/setup/index.html << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leeds APRS Pi Setup</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2c5aa0; text-align: center; margin-bottom: 30px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; color: #333; }
        input, select, textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; font-size: 16px; }
        button { background: #2c5aa0; color: white; padding: 12px 30px; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; width: 100%; }
        button:hover { background: #1e3f73; }
        .info { background: #e7f3ff; padding: 15px; border-radius: 5px; margin-bottom: 20px; border-left: 4px solid #2c5aa0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>?? Leeds APRS Pi Setup</h1>
        
        <div class="info">
            <strong>Welcome!</strong> Configure your APRS station below. You'll need your amateur radio callsign and APRS-IS passcode.
        </div>
        
        <form id="setupForm" onsubmit="submitConfig(event)">
            <div class="form-group">
                <label for="callsign">Amateur Radio Callsign *</label>
                <input type="text" id="callsign" name="callsign" required placeholder="e.g., G0ABC">
            </div>
            
            <div class="form-group">
                <label for="aprs_pass">APRS-IS Passcode *</label>
                <input type="number" id="aprs_pass" name="aprs_pass" required placeholder="Get from aprs.fi">
            </div>
            
            <div class="form-group">
                <label for="lat">Latitude *</label>
                <input type="number" id="lat" name="lat" step="0.0001" required placeholder="53.8008">
            </div>
            
            <div class="form-group">
                <label for="lon">Longitude *</label>
                <input type="number" id="lon" name="lon" step="0.0001" required placeholder="-1.5491">
            </div>
            
            <div class="form-group">
                <label for="beacon_message">Beacon Message</label>
                <input type="text" id="beacon_message" name="beacon_message" placeholder="Leeds Space Comms APRS Node">
            </div>
            
            <div class="form-group">
                <label for="wifi_ssid">Home WiFi Network</label>
                <input type="text" id="wifi_ssid" name="wifi_ssid" placeholder="Your WiFi network name">
            </div>
            
            <div class="form-group">
                <label for="wifi_pass">WiFi Password</label>
                <input type="password" id="wifi_pass" name="wifi_pass" placeholder="WiFi password">
            </div>
            
            <button type="submit">?? Start APRS Station</button>
        </form>
    </div>
    
    <script>
        function submitConfig(event) {
            event.preventDefault();
            
            const formData = new FormData(event.target);
            const config = {};
            for (let [key, value] of formData.entries()) {
                config[key] = value;
            }
            
            fetch('/api/configure', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(config)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    document.body.innerHTML = `
                        <div class="container">
                            <h1>? Configuration Complete!</h1>
                            <div class="info">
                                <p><strong>Your APRS station is now starting...</strong></p>
                                <p>The system will reboot and connect to your WiFi network.</p>
                                <p>After reboot, access your station at: <strong>http://${config.callsign.toLowerCase()}.local:8080</strong></p>
                                <p>Or find its IP address on your router and use: <strong>http://[IP]:8080</strong></p>
                            </div>
                        </div>
                    `;
                    setTimeout(() => {
                        window.location.href = '/reboot';
                    }, 5000);
                }
            })
            .catch(error => {
                alert('Configuration failed: ' + error.message);
            });
        }
    </script>
</body>
</html>
HTML

    # Configure nginx for setup interface
    cat > /etc/nginx/sites-available/aprs-setup << 'NGINX'
server {
    listen 80 default_server;
    server_name _;
    root /var/www/setup;
    index index.html;
    
    location /api/ {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
NGINX

    ln -sf /etc/nginx/sites-available/aprs-setup /etc/nginx/sites-enabled/default
    systemctl enable nginx
}

# Setup configuration API
setup_config_api() {
    cat > /opt/leeds-aprs-pi/setup-api.py << 'PYTHON'
#!/usr/bin/env python3
import json
import subprocess
import os
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/api/configure', methods=['POST'])
def configure():
    try:
        config = request.get_json()
        
        # Validate required fields
        required = ['callsign', 'aprs_pass', 'lat', 'lon']
        for field in required:
            if not config.get(field):
                return jsonify({'success': False, 'error': f'Missing {field}'})
        
        # Create docker-compose configuration
        docker_config = f"""
services:
  aprs:
    build: .
    container_name: leeds-aprs-pi
    privileged: true
    network_mode: host
    volumes:
      - ./config:/app/config:ro
      - ./scripts:/app/scripts:ro
      - ./logs:/app/logs:rw
      - ./data:/app/data:rw
    environment:
      - CALLSIGN={config['callsign']}
      - APRS_PASS={config['aprs_pass']}
      - LAT={config['lat']}
      - LON={config['lon']}
      - BEACON_MESSAGE={config.get('beacon_message', 'Leeds APRS Pi Station')}
      - BEACON_INTERVAL=600
      - SYMBOL_TABLE=/
      - SYMBOL_CODE=&
      - TZ=Europe/London
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "pgrep", "-f", "direwolf"]
      interval: 30s
      timeout: 10s
      retries: 3

  dashboard:
    image: nginx:alpine
    container_name: aprs-dashboard
    ports:
      - "8080:80"
    volumes:
      - ./web:/usr/share/nginx/html:ro
    depends_on:
      - aprs
    restart: unless-stopped
"""
        
        # Write configuration
        with open('/opt/leeds-aprs-pi/docker-compose.yml', 'w') as f:
            f.write(docker_config)
        
        # Configure WiFi if provided
        if config.get('wifi_ssid') and config.get('wifi_pass'):
            wifi_config = f"""
country=GB
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={{
    ssid="{config['wifi_ssid']}"
    psk="{config['wifi_pass']}"
}}
"""
            with open('/etc/wpa_supplicant/wpa_supplicant.conf', 'w') as f:
                f.write(wifi_config)
        
        # Setup hostname
        hostname = config['callsign'].lower().replace('/', '-')
        with open('/etc/hostname', 'w') as f:
            f.write(hostname)
        
        # Create systemd service for APRS
        service_config = f"""
[Unit]
Description=Leeds APRS Pi
After=docker.service network.target
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/leeds-aprs-pi
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
User=aprs
Group=aprs

[Install]
WantedBy=multi-user.target
"""
        with open('/etc/systemd/system/leeds-aprs-pi.service', 'w') as f:
            f.write(service_config)
        
        # Enable APRS service
        subprocess.run(['systemctl', 'daemon-reload'])
        subprocess.run(['systemctl', 'enable', 'leeds-aprs-pi'])
        
        # Disable setup services
        subprocess.run(['systemctl', 'disable', 'hostapd'])
        subprocess.run(['systemctl', 'disable', 'dnsmasq'])
        subprocess.run(['systemctl', 'disable', 'nginx'])
        
        # Mark setup as complete
        with open('/boot/setup-complete', 'w') as f:
            f.write('configured')
        
        return jsonify({'success': True})
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@app.route('/reboot')
def reboot():
    subprocess.run(['systemctl', 'reboot'])
    return "Rebooting..."

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
PYTHON

    chmod +x /opt/leeds-aprs-pi/setup-api.py
    
    # Create systemd service for setup API
    cat > /etc/systemd/system/aprs-setup-api.service << 'SERVICE'
[Unit]
Description=APRS Setup API
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/leeds-aprs-pi
ExecStart=/usr/bin/python3 /opt/leeds-aprs-pi/setup-api.py
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE

    systemctl enable aprs-setup-api
}

# Main setup execution
main() {
    # Check if already configured
    if [ -f /boot/setup-complete ]; then
        # Start APRS system
        systemctl start leeds-aprs-pi
        exit 0
    fi
    
    # Run first-time setup
    setup_hotspot
    setup_web_config
    setup_config_api
    
    # Start setup services
    systemctl start hostapd
    systemctl start dnsmasq
    systemctl start nginx
    systemctl start aprs-setup-api
}

main "$@"
EOF

    # Make executable and install as service
    sudo chmod +x "$ROOT_MOUNT/opt/leeds-aprs-pi/first-boot.sh"
    
    # Create systemd service for first boot
    sudo tee "$ROOT_MOUNT/etc/systemd/system/aprs-first-boot.service" > /dev/null << 'EOF'
[Unit]
Description=APRS First Boot Setup
After=network.target
Before=getty@tty1.service

[Service]
Type=oneshot
ExecStart=/opt/leeds-aprs-pi/first-boot.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    # Execute install script
    sudo chmod +x "$ROOT_MOUNT/install_aprs.sh"
    sudo chroot "$ROOT_MOUNT" /install_aprs.sh
    
    # Enable first boot service
    sudo chroot "$ROOT_MOUNT" systemctl enable aprs-first-boot
    
    # Cleanup
    sudo rm "$ROOT_MOUNT/install_aprs.sh"
    sudo rm "$ROOT_MOUNT/usr/bin/qemu-aarch64-static"
    
    success "APRS software installed"
}

# Cleanup and finalize image
finalize_image() {
    log "Finalizing image..."
    
    # Unmount partitions
    sudo umount "$BOOT_MOUNT" "$ROOT_MOUNT"
    sudo kpartx -dv "$LOOP_DEVICE"
    sudo losetup -d "$LOOP_DEVICE"
    
    # Create final image
    OUTPUT_IMAGE="${IMAGE_NAME}-v${VERSION}.img"
    cp "raspios-base.img" "$OUTPUT_IMAGE"
    
    # Compress image
    log "Compressing image..."
    gzip -9 "$OUTPUT_IMAGE"
    
    # Calculate checksums
    sha256sum "${OUTPUT_IMAGE}.gz" > "${OUTPUT_IMAGE}.gz.sha256"
    
    success "Image created: ${OUTPUT_IMAGE}.gz"
    log "Size: $(du -h ${OUTPUT_IMAGE}.gz | cut -f1)"
    log "SHA256: $(cat ${OUTPUT_IMAGE}.gz.sha256)"
}

# Main execution
main() {
    log "Starting Leeds APRS Pi image build..."
    
    check_deps
    download_base_image
    mount_image
    install_aprs_software
    finalize_image
    
    success "Build complete!"
    log "Flash the image using:"
    log "  Raspberry Pi Imager: Select '${OUTPUT_IMAGE}.gz'"
    log "  Rufus: Select '${OUTPUT_IMAGE}.gz'"
    log "  dd: gunzip -c '${OUTPUT_IMAGE}.gz' | sudo dd of=/dev/sdX bs=4M"
}

# Cleanup on exit
trap 'if [ -n "$LOOP_DEVICE" ]; then sudo umount "$BOOT_MOUNT" "$ROOT_MOUNT" 2>/dev/null; sudo kpartx -dv "$LOOP_DEVICE" 2>/dev/null; sudo losetup -d "$LOOP_DEVICE" 2>/dev/null; fi' EXIT

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi