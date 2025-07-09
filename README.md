# Leeds APRS Pi
**Dockerized APRS & Beacon System for Raspberry Pi**

🚀 **Flash-and-Go Solution Available!** Just flash an SD card and plug into your Pi with an SDR dongle. No configuration required!

Easily set up an APRS receiver, transmitter, and beacon node with minimal configuration—ideal for clubs, educational groups, and amateur radio enthusiasts. Supports RTL-SDR, GPS dongles, and soundcard interfaces for flexible operation.

---

## ⚡ Flash-and-Go Quick Start (Recommended)

**Get running in 5 minutes with zero configuration:**

### Step 1: Download Pre-built Image
1. Go to [Releases](https://github.com/leeds-space-comms/leeds-aprs-pi/releases)
2. Download `leeds-aprs-pi-YYYYMMDD.img.gz`

### Step 2: Flash SD Card
**Windows users:**
```bash
# Download this repo and run the GUI tool
git clone https://github.com/leeds-space-comms/leeds-aprs-pi.git
cd leeds-aprs-pi\build
.\flash-aprs.bat
```

**Linux/Mac users:**
```bash
git clone https://github.com/leeds-space-comms/leeds-aprs-pi.git
cd leeds-aprs-pi/build
./quick-flash.sh
```

### Step 3: First Boot
1. Insert SD card into Raspberry Pi
2. Connect RTL-SDR dongle and antenna
3. Power on and wait 2-3 minutes
4. Connect to WiFi: `Leeds-APRS-Setup` (password: `aprssetup`)
5. Open browser: `http://192.168.4.1`
6. Follow the setup wizard

**That's it!** 🎉 See the [Flash-and-Go Guide](docs/flash-and-go-guide.md) for detailed instructions.

---

## Features

- **🔥 Flash-and-Go Deployment**: Pre-built SD card images with web-based setup
- **🎯 Zero Configuration**: Automatic hardware detection and configuration
- **📡 Full APRS Operation**: Receive, transmit, beacon, and IGate functionality
- **🐳 Docker Deployment**: Containerized for reliability and easy updates
- **🎓 Educational Focus**: Perfect for clubs, universities, and learning
- **🛠️ Multi-Interface Support**: RTL-SDR, GPS, audio interfaces
- **🌐 Web Dashboard**: Real-time monitoring and configuration
- **📱 Mobile-Friendly Setup**: Configure via phone/tablet browser

## Manual Installation (Advanced Users)

### Prerequisites

Install Docker and Docker Compose on your Raspberry Pi:

```bash
# Install Docker
curl -sSL https://get.docker.com | sh

# Install Docker Compose
sudo apt-get install -y docker-compose

# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login again for group changes to take effect
```

### Setup

1. **Clone this repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/leeds-aprs-pi.git
   cd leeds-aprs-pi
   ```

2. **Configure your settings**
   - Edit `config/direwolf.conf` with your callsign and location
   - Update `config/beacon.conf` with your beacon message
   - Modify `docker-compose.yml` environment variables

3. **Start the services**
   ```bash
   docker-compose up -d
   ```

4. **Verify operation**
   ```bash
   # Check service status
   docker-compose ps
   
   # View logs
   docker-compose logs -f
   
   # Confirm beacon on aprs.fi
   ```

## Configuration

### Environment Variables

Edit the environment section in `docker-compose.yml`:

```yaml
environment:
  - CALLSIGN=YOUR_CALLSIGN        # Your amateur radio callsign
  - APRS_PASS=YOUR_PASSCODE       # APRS-IS passcode
  - LAT=53.8008                   # Latitude (Leeds default)
  - LON=-1.5491                   # Longitude (Leeds default)
  - BEACON_MESSAGE=Leeds Space Comms APRS Node
  - BEACON_INTERVAL=600           # Beacon interval in seconds
```

### Hardware Setup

- **RTL-SDR**: Connect USB RTL-SDR dongle for receiving
- **GPS**: Connect USB GPS dongle for position updates
- **Audio**: Use Pi audio jack or USB audio interface for TX

## Hardware Requirements

- Raspberry Pi 3/4/5 (ARM64 recommended)
- RTL-SDR dongle (RX) or soundcard interface (RX/TX)
- USB GPS dongle (optional, for mobile beacons)
- Audio interface for transmit (if using soundcard mode)

## Documentation

- [Hardware Setup Guide](docs/hardware-setup.md)
- [Configuration Reference](docs/configuration.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Leeds Space Comms Setup](docs/leeds-setup.md)

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Contributing

This project is primarily maintained for Leeds Space Comms members but is open to public contributions. Please read our contributing guidelines before submitting pull requests.

---

*Developed for Leeds Space Comms by Ahmad Al-Musbahi*
