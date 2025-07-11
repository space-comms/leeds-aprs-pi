# Leeds APRS Pi 📡

A comprehensive, containerized APRS (Automatic Packet Reporting System) solution designed for educational use, amateur radio experimentation, and rapid deployment. Originally developed for the Leeds Space Communications Society but suitable for any amateur radio operator or educational institution.

## 🎯 Project Overview

The Leeds APRS Pi transforms a Raspberry Pi into a complete APRS station with minimal setup. It provides:

- **Plug-and-play APRS operation** with automatic hardware detection
- **Educational-focused design** with extensive documentation and examples
- **Professional web interface** for monitoring and configuration
- **Multi-platform support** (Raspberry Pi, Linux, Windows, macOS)
- **Containerized deployment** for easy installation and management

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [System Requirements](#system-requirements)
- [Installation Methods](#installation-methods)
- [Configuration](#configuration)
- [Hardware Support](#hardware-support)
- [Web Interface](#web-interface)
- [Educational Use](#educational-use)
- [API Documentation](#api-documentation)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## 🚀 Quick Start

### Method 1: Docker Compose (Recommended)
# Clone the repository
git clone https://github.com/leedsspace/leeds-aprs-pi.git
cd leeds-aprs-pi

# Configure your station (edit docker-compose.yml)
nano docker-compose.yml

# Start the system
docker-compose up -d

# Access web interface
open http://localhost:8080
### Method 2: Automated Setup Script
# Download and run setup script
curl -fsSL https://raw.githubusercontent.com/leedsspace/leeds-aprs-pi/main/scripts/setup.sh | sudo bash

# Follow interactive prompts
# System will auto-configure based on your hardware
### Method 3: Pre-built Images

Download pre-configured Raspberry Pi images from the [releases page](https://github.com/leedsspace/leeds-aprs-pi/releases).

## 💻 System Requirements

### Minimum Requirements
- **Raspberry Pi 3B+** or newer (Pi 4 recommended)
- **8GB microSD card** (16GB+ recommended)
- **Internet connection** for APRS-IS connectivity
- **Valid amateur radio license** (for transmitting)

### Recommended Hardware
- **Raspberry Pi 4** (2GB+ RAM)
- **16GB+ microSD card** (Class 10 or better)
- **RTL-SDR dongle** for receiving
- **USB GPS module** for mobile operation
- **USB sound card** for audio interfaces

### Supported Platforms
- **Raspberry Pi OS** (32-bit and 64-bit)
- **Ubuntu** (18.04+)
- **Debian** (10+)
- **Windows** (with Docker Desktop)
- **macOS** (with Docker Desktop)

## 🔧 Installation Methods

### Option 1: Docker Compose Installation

This is the recommended method for most users.
# Install Docker and Docker Compose
curl -fsSL https://get.docker.com | sh
sudo pip3 install docker-compose

# Clone repository
git clone https://github.com/leedsspace/leeds-aprs-pi.git
cd leeds-aprs-pi

# Configure environment
cp .env.example .env
nano .env

# Start services
docker-compose up -d
### Option 2: Automated Setup

For new Raspberry Pi installations:
# Download setup script
wget https://raw.githubusercontent.com/leedsspace/leeds-aprs-pi/main/scripts/setup.sh

# Make executable and run
chmod +x setup.sh
sudo ./setup.sh

# Follow interactive configuration
### Option 3: Manual Installation

For advanced users who want full control:
# Install dependencies
sudo apt-get update
sudo apt-get install -y docker.io docker-compose git

# Clone and configure
git clone https://github.com/leedsspace/leeds-aprs-pi.git
cd leeds-aprs-pi

# Build containers
docker-compose build

# Configure system
./scripts/configure.sh

# Start services
docker-compose up -d
## ⚙️ Configuration

### Environment Variables

Configure your station by editing `docker-compose.yml`:
environment:
  # Station identification
  - CALLSIGN=YOUR_CALLSIGN           # Your amateur radio callsign
  - APRS_PASS=YOUR_PASSCODE          # APRS-IS passcode (get from aprs.fi)
  
  # Location settings
  - LAT=YOUR_LATITUDE                # Decimal degrees
  - LON=YOUR_LONGITUDE               # Decimal degrees
  
  # Beacon configuration
  - BEACON_MESSAGE=Your Custom Message
  - BEACON_INTERVAL=600              # Seconds between beacons
  
  # Advanced settings
  - SYMBOL_TABLE=/                   # APRS symbol table
  - SYMBOL_CODE=&                    # APRS symbol code
  - TZ=America/New_York              # Timezone
### Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| `docker-compose.yml` | Main configuration | Root directory |
| `config/direwolf.conf` | Direwolf APRS software | `/config/` |
| `config/beacon.conf` | Beacon settings | `/config/` |
| `web/index.html` | Web interface | `/web/` |

### Quick Configuration Examples

#### Basic Station Setupexport CALLSIGN="W1ABC"
export APRS_PASS="12345"
export LAT="40.7128"
export LON="-74.0060"
export BEACON_MESSAGE="NYC APRS Node"
#### Mobile Station Setupexport CALLSIGN="W1ABC/M"
export BEACON_MESSAGE="Mobile APRS"
export BEACON_INTERVAL="300"    # More frequent for mobile
export SYMBOL_CODE=">"          # Car symbol
#### Educational Setupexport CALLSIGN="W1ABC/EDU"
export BEACON_MESSAGE="University APRS Lab"
export BEACON_COMMENT="Educational Use"
## 🔌 Hardware Support

### RTL-SDR Support
- **Automatic detection** of RTL-SDR dongles
- **Multiple device support** for diversity reception
- **Frequency scanning** capabilities
- **Web-based spectrum analyzer**

### GPS Integration
- **USB GPS modules** (most NMEA-compatible devices)
- **Automatic position updates** for mobile operation
- **Time synchronization** for accurate timestamps
- **Track logging** with KML export

### Audio Interfaces
- **USB sound cards** for radio interfaces
- **Raspberry Pi built-in audio** (with limitations)
- **Digital modes** support (PSK31, RTTY, etc.)
- **VOX and PTT control** options

### Supported Hardware List

| Category | Device | Status | Notes |
|----------|--------|--------|-------|
| RTL-SDR | RTL2832U-based | ✅ Supported | Most common dongles |
| GPS | u-blox modules | ✅ Supported | USB and serial |
| Audio | USB sound cards | ✅ Supported | Class-compliant devices |
| Radio | Baofeng UV-5R | ✅ Tested | With audio cable |
| Radio | Yaesu FT-991A | ✅ Tested | USB CAT control |

## 🌐 Web Interface

### Dashboard Features
- **Real-time system status** with automatic updates
- **Hardware monitoring** with status indicators
- **Packet statistics** and activity logs
- **Interactive configuration** forms
- **Mobile-responsive design** for phone/tablet access

### Interface Sections

#### System Status
- APRS service status
- Hardware connectivity
- Network connectivity  
- System performance metrics

#### Configuration
- Station information
- Beacon settings
- Hardware configuration
- Network settings

#### Monitoring
- Live packet display
- System logs
- Performance graphs
- Historical data

### API Endpoints

The web interface is powered by a REST API:
GET  /api/status      # System status
GET  /api/config      # Configuration
POST /api/config      # Update configuration
GET  /api/logs        # System logs
GET  /api/packets     # APRS packets
POST /api/beacon      # Send beacon
## 📚 Educational Use

### Curriculum Integration

#### Course Applications
- **Electronics Engineering**: Digital signal processing, modulation theory
- **Computer Science**: Network protocols, embedded systems
- **Physics**: Wave propagation, electromagnetic theory
- **Amateur Radio**: License preparation, practical applications

#### Lab Exercises
1. **APRS Protocol Analysis** - Decode and analyze APRS packets
2. **Digital Signal Processing** - Audio filtering and demodulation
3. **Network Architecture** - Internet gateway implementation
4. **Embedded Systems** - Hardware interfacing and control

### Educational Templates

#### Classroom Deployment# Deploy to multiple stations
./scripts/deploy-classroom.sh --stations 20 --callsign-prefix "W1ABC"

# Configure for specific exercise
./scripts/configure-exercise.sh --exercise "protocol-analysis"
#### Assessment Integration
- **Automated testing** with unit tests
- **Performance benchmarks** for optimization exercises
- **Report generation** for lab submissions
- **Progress tracking** across multiple sessions

### Student Projects

#### Beginner Projects
- Basic APRS beacon setup
- Packet decoding and analysis
- Simple web interface customization

#### Advanced Projects
- Custom protocol implementation
- Advanced signal processing
- IoT sensor integration
- Emergency communication systems

## 🔍 API Documentation

### Status API
# Get system status
curl http://localhost:8000/api/status

# Response format
{
  "aprs": true,
  "gps": false,
  "callsign": "W1ABC",
  "uptime": 3600,
  "packets_sent": 42,
  "packets_received": 128,
  "hardware": {
    "rtl_sdr": true,
    "gps_device": false,
    "audio_device": true
  },
  "metrics": {
    "cpu_usage": 25,
    "memory_usage": 60,
    "disk_usage": 45,
    "temperature": 42.5
  }
}
### Configuration API
# Get configuration
curl http://localhost:8000/api/config

# Update configuration
curl -X POST http://localhost:8000/api/config \
  -H "Content-Type: application/json" \
  -d '{"callsign": "W1ABC", "beacon_interval": 300}'
### Logging API
# Get recent logs
curl http://localhost:8000/api/logs?lines=50

# Stream logs (WebSocket)
ws://localhost:8000/api/logs/stream
## 🛠️ Troubleshooting

### Common Issues

#### Docker Issues# Check Docker status
sudo systemctl status docker

# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d
#### Hardware Issues# Check USB devices
lsusb

# Test RTL-SDR
rtl_test -t

# Check GPS
cat /dev/ttyUSB0
#### Network Issues# Test APRS-IS connectivity
telnet rotate.aprs2.net 14580

# Check firewall
sudo ufw status
### Debug Mode

Enable debug logging:# Enable debug mode
export DEBUG=1
docker-compose up

# View detailed logs
docker-compose logs -f
### Performance Optimization

#### Resource Usage# Check resource usage
docker stats

# Optimize for Pi Zero
export OPTIMIZE_LOW_MEMORY=1
#### Network Optimization# Use local APRS-IS server
export APRS_SERVER="local.aprs2.net"

# Adjust filter radius
export FILTER_RADIUS=25
## 🤝 Contributing

We welcome contributions from the amateur radio community! See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

### Development Setup
# Clone repository
git clone https://github.com/leedsspace/leeds-aprs-pi.git
cd leeds-aprs-pi

# Set up development environment
./scripts/dev-setup.sh

# Run tests
./scripts/test.sh

# Start development server
docker-compose -f docker-compose.dev.yml up
### Testing
# Run unit tests
python -m pytest tests/

# Run integration tests
./scripts/test-integration.sh

# Test on hardware
./scripts/test-hardware.sh
## 📊 Project Statistics

- **Languages**: Python, JavaScript, Shell, Dockerfile
- **Containers**: 3 (APRS, Web, API)
- **Supported Platforms**: 5+
- **Documentation Pages**: 15+
- **Test Coverage**: 85%+

## 🏆 Acknowledgments

### Leeds Space Communications Society
- **Project Lead**: [Your Name]
- **Contributors**: [List of contributors]
- **Faculty Advisor**: [Advisor name]

### Open Source Dependencies
- **Direwolf**: WB2OSZ - APRS software modem
- **Flask**: Web framework for API
- **Docker**: Containerization platform
- **Bootstrap**: Web interface styling

### Community Thanks
- **APRS Community**: For protocol development and support
- **Amateur Radio Community**: For testing and feedback
- **Educational Institutions**: For adoption and feedback

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Amateur Radio Compliance
- **Station identification**: Ensure proper callsign usage
- **Third-party traffic**: Respect amateur radio regulations
- **RF exposure**: Follow applicable safety guidelines
- **Licensing**: Valid amateur radio license required for transmission

## 📞 Support

### Getting Help
- **Documentation**: [docs/](docs/) directory
- **GitHub Issues**: Report bugs and request features
- **Discussions**: Community Q&A and ideas
- **Email**: [Contact information]

### Leeds Students
- **Lab Support**: Available during lab hours
- **Office Hours**: [Schedule]
- **Course Integration**: Contact your instructor

---

**Leeds University Space Communications Society**  
*Advancing amateur radio education and experimentation*

**73 de Leeds Space Comms! 🚀**
