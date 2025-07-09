# Flash-and-Go Quick Start Guide

Welcome to the Leeds APRS Pi flash-and-go solution! This guide will get you from zero to a working APRS station in minutes.

## What You Need

### Hardware Requirements
- **Raspberry Pi 4** (2GB+ recommended)
- **MicroSD card** (16GB+ Class 10)
- **RTL-SDR dongle** (RTL2832U + R820T2 recommended)
- **Antenna** (quarter-wave for 144-146 MHz)
- **Power supply** (Official Pi adapter recommended)

### Optional Hardware
- Ethernet cable (for initial setup)
- HDMI cable and monitor (for troubleshooting)
- USB keyboard (for direct configuration)

### Software Requirements
Choose your platform:
- **Windows**: PowerShell 5.1+ with Admin rights
- **Linux/Mac**: Bash with sudo access
- **Any platform**: Raspberry Pi Imager (alternative method)

## Quick Start (5 Minutes)

### Step 1: Download the Image
1. Go to [Releases](https://github.com/leeds-space-comms/leeds-aprs-pi/releases)
2. Download the latest `leeds-aprs-pi-YYYYMMDD.img.gz` file
3. Save it to an easy-to-find location

### Step 2: Flash the SD Card

#### Windows Users (Recommended)
```powershell
# Download this repository
git clone https://github.com/leeds-space-comms/leeds-aprs-pi.git
cd leeds-aprs-pi\build

# Run the GUI flash tool (easiest)
.\flash-gui.ps1

# OR use the command line tool
.\quick-flash.ps1
```

#### Linux/Mac Users
```bash
# Download this repository
git clone https://github.com/leeds-space-comms/leeds-aprs-pi.git
cd leeds-aprs-pi/build

# Run the flash script
./quick-flash.sh
```

#### Alternative: Raspberry Pi Imager
1. Download [Raspberry Pi Imager](https://www.raspberrypi.org/software/)
2. Choose "Use custom image" and select the downloaded `.img` file
3. Flash to your SD card

### Step 3: First Boot
1. Insert the SD card into your Raspberry Pi
2. Connect your RTL-SDR dongle
3. Connect the antenna to your RTL-SDR
4. Power on the Raspberry Pi
5. Wait 2-3 minutes for initial setup

### Step 4: Connect and Configure
1. On your phone/laptop, connect to WiFi network: `Leeds-APRS-Setup`
2. Password: `aprssetup`
3. Open your browser and go to: `http://192.168.4.1`
4. Follow the setup wizard

## Detailed Setup Instructions

### Pre-Configuration (Optional)

If you want to customize the image before flashing:

```bash
# Run the pre-configuration tool
./preconfig.sh

# Choose from templates:
./preconfig.sh --template leeds-university
./preconfig.sh --template educational
./preconfig.sh --template club-basic

# Build custom image with your settings
./build-image.sh --config customized/
```

### Web Setup Wizard

The web interface will guide you through:

1. **Station Information**
   - Your callsign
   - Name and location
   - Grid square (optional)

2. **APRS Configuration**
   - Beacon interval
   - Symbol selection
   - Custom comment

3. **Network Setup**
   - Home WiFi credentials
   - APRS-IS connection
   - IGate configuration

4. **Hardware Detection**
   - Automatic SDR detection
   - Audio device selection
   - Antenna tuning

### Manual Configuration

If you prefer command-line setup:

```bash
# SSH into the Pi (if enabled)
ssh pi@192.168.4.1
# Default password: raspberry

# Edit configuration
sudo nano /opt/leeds-aprs-pi/config/beacon.conf

# Restart services
sudo systemctl restart aprs-beacon
sudo systemctl restart direwolf
```

## Troubleshooting

### Common Issues

#### No WiFi Hotspot
- Wait 3-5 minutes after boot
- Check LED status: solid green = ready
- Power cycle if needed

#### Can't Connect to Setup Network
- Verify password: `aprssetup`
- Try forgetting and reconnecting
- Check if network appears in WiFi list

#### SDR Not Detected
- Unplug and reconnect SDR dongle
- Try a different USB port
- Check antenna connection

#### No Web Interface
- Ensure connected to `Leeds-APRS-Setup` network
- Try `http://aprs.local` or `http://192.168.4.1`
- Clear browser cache

### LED Status Indicators

| LED Pattern | Status |
|-------------|--------|
| Blinking red | Booting/setup in progress |
| Solid green | Ready for configuration |
| Blinking green | APRS active, receiving |
| Fast blinking green | APRS active, transmitting beacon |
| Solid red | Error - check logs |

### Getting Help

1. **Check the logs**:
   ```bash
   # View system logs
   sudo journalctl -u aprs-autoconfig
   
   # View APRS logs
   sudo journalctl -u direwolf
   ```

2. **Reset to defaults**:
   ```bash
   sudo rm /var/lib/aprs-setup-complete
   sudo reboot
   ```

3. **Contact support**:
   - Open an issue on GitHub
   - Email: space@leeds.ac.uk
   - Discord: Leeds Space Comms server

## Advanced Features

### Mass Deployment

For clubs or educational environments:

```bash
# Create custom configuration
./preconfig.sh --template educational

# Build multiple images
for i in {1..10}; do
    ./build-image.sh --config customized/ --suffix "-station-$i"
done

# Flash multiple cards
./quick-flash.sh --batch station-list.txt
```

### Remote Management

Once configured, you can:
- Monitor via web dashboard
- SSH for advanced configuration
- Update via GitHub integration
- Backup configurations

### Integration with APRS Networks

The system automatically:
- Connects to APRS-IS servers
- Provides IGate functionality
- Forwards packets to internet
- Logs activity for analysis

## Educational Use

### Leeds University Setup

For Leeds Space Society members:
```bash
./preconfig.sh --template leeds-university
```

This includes:
- Pre-configured for university network
- Educational beacon messages
- Group project settings
- Monitoring and logging enabled

### Classroom Deployment

For teachers:
1. Use the `educational` template
2. Pre-configure with classroom WiFi
3. Set appropriate beacon intervals
4. Enable student monitoring dashboard

### Learning Activities

Suggested classroom activities:
- Packet monitoring and analysis
- Antenna pattern measurements
- Network topology mapping
- Emergency communication exercises

## Safety and Regulations

### RF Safety
- Use appropriate antennas for power levels
- Maintain safe distances during transmission
- Follow local RF exposure guidelines

### Licensing
- Ensure proper amateur radio licensing
- Use appropriate callsigns
- Respect frequency allocations
- Follow local regulations

### Network Security
- Change default passwords
- Use WPA2/WPA3 for WiFi
- Keep software updated
- Monitor for unauthorized access

## Support and Community

### Getting Involved
- Join the Leeds Space Comms Discord
- Contribute to the GitHub repository
- Share your experiences and improvements
- Help other users in the community

### Contributing
- Report bugs and issues
- Submit feature requests
- Contribute code improvements
- Write documentation
- Share educational materials

---

**Happy APRS-ing!** 🚀📡

*Leeds Space Communications Society*  
*University of Leeds*
