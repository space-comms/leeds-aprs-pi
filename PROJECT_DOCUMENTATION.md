# Leeds APRS Pi - Complete Project Documentation

## ?? Project Overview

The Leeds APRS Pi is a comprehensive, containerized APRS (Automatic Packet Reporting System) solution designed specifically for educational use, amateur radio experimentation, and rapid deployment scenarios. This project transforms a standard Raspberry Pi into a complete APRS station with minimal setup requirements.

### Key Features

- **Containerized Architecture**: Docker-based deployment for consistency and portability
- **Educational Focus**: Designed for university courses and amateur radio education
- **Hardware Agnostic**: Supports various RTL-SDR, GPS, and audio interfaces
- **Web-Based Management**: Modern, responsive web interface for monitoring and control
- **Multi-Platform Support**: Runs on Raspberry Pi, Linux, Windows, and macOS
- **Professional Documentation**: Comprehensive guides for all skill levels

## ??? Architecture Overview

### System Components

```
???????????????????????    ???????????????????????    ???????????????????????
?   Web Interface     ?    ?   API Server        ?    ?   APRS Service      ?
?   (port 8080)       ??????   (port 8000)       ??????   (Direwolf)        ?
?                     ?    ?                     ?    ?                     ?
? - Dashboard         ?    ? - REST API          ?    ? - APRS Modem        ?
? - Configuration     ?    ? - Status Monitoring ?    ? - Beacon Generation ?
? - Monitoring        ?    ? - Log Management    ?    ? - Packet Processing ?
???????????????????????    ???????????????????????    ???????????????????????
```

### Container Structure

#### 1. APRS Container (`aprs`)
- **Base Image**: `arm64v8/debian:bullseye-slim`
- **Primary Function**: APRS packet processing and radio interface
- **Key Components**:
  - Direwolf APRS software
  - Hardware drivers (RTL-SDR, GPS, Audio)
  - Configuration management
  - Logging system

#### 2. Web Interface Container (`dashboard`)
- **Base Image**: `nginx:alpine`
- **Primary Function**: User interface and monitoring
- **Key Components**:
  - Static HTML/CSS/JavaScript files
  - Real-time dashboard updates
  - Mobile-responsive design
  - Configuration forms

#### 3. API Server Container (`api`)
- **Base Image**: `python:3.9-slim`
- **Primary Function**: REST API and backend services
- **Key Components**:
  - Flask web framework
  - Database management
  - Hardware status monitoring
  - Configuration management

## ?? Project Structure

```
leeds-aprs-pi/
??? ?? config/                    # Configuration files
?   ??? direwolf.conf            # Direwolf APRS software config
?   ??? beacon.conf              # Beacon configuration
??? ?? docs/                      # Documentation
?   ??? configuration.md         # Configuration guide
?   ??? flash-and-go-guide.md    # Quick start guide
?   ??? hardware-setup.md        # Hardware documentation
?   ??? leeds-setup.md           # University-specific setup
?   ??? troubleshooting.md       # Troubleshooting guide
??? ?? scripts/                   # Utility scripts
?   ??? api-server.py            # API server implementation
?   ??? auto-config.sh           # Automatic configuration
?   ??? monitor.sh               # System monitoring
?   ??? setup.sh                 # Initial setup script
?   ??? start.sh                 # Service startup
?   ??? status.sh                # Status reporting
??? ?? templates/                 # Configuration templates
?   ??? courses/                 # Course-specific templates
?   ??? labs/                    # Lab exercise templates
?   ??? assessments/             # Assessment templates
??? ?? tests/                     # Test suite
?   ??? test_full_system.py      # Integration tests
??? ?? web/                       # Web interface
?   ??? index.html               # Main dashboard
?   ??? js/
?       ??? dashboard.js         # Dashboard functionality
??? ?? docker-compose.yml        # Docker orchestration
??? ?? Dockerfile               # Main container build
??? ?? Dockerfile.debug         # Debug container build
??? ?? Dockerfile.robust        # Production container build
??? ?? Dockerfile.simple        # Minimal container build
??? ?? Dockerfile.web           # Web container build
??? ?? Dockerfile.windows       # Windows container build
??? ?? README.md                # Main documentation
??? ?? CONTRIBUTING.md          # Contributing guidelines
??? ?? LICENSE                  # MIT License
```

## ?? Technical Specifications

### Hardware Requirements

#### Minimum Configuration
- **CPU**: ARM Cortex-A53 (Pi 3B+) or equivalent
- **RAM**: 1GB (2GB recommended)
- **Storage**: 8GB microSD card
- **Network**: Ethernet or Wi-Fi connectivity

#### Recommended Configuration
- **CPU**: ARM Cortex-A72 (Pi 4) or equivalent
- **RAM**: 4GB or more
- **Storage**: 16GB+ microSD card (Class 10)
- **Network**: Gigabit Ethernet preferred

#### Optional Hardware
- **RTL-SDR**: For APRS packet reception
- **GPS Module**: For mobile operation and accurate timing
- **USB Audio**: For radio interface connections
- **External Storage**: USB drive for logs and data

### Software Dependencies

#### Core Components
- **Docker**: Container runtime environment
- **Docker Compose**: Multi-container orchestration
- **Direwolf**: APRS software modem and TNC
- **Flask**: Python web framework for API
- **Nginx**: Web server for dashboard

#### System Libraries
- **ALSA**: Audio system interface
- **RTL-SDR**: Software defined radio drivers
- **GPSD**: GPS daemon for positioning
- **Python 3.9+**: Programming language runtime

## ?? Deployment Methods

### Method 1: Quick Start (Recommended)
```bash
# Clone repository
git clone https://github.com/leedsspace/leeds-aprs-pi.git
cd leeds-aprs-pi

# Configure station settings
nano docker-compose.yml

# Deploy system
docker-compose up -d

# Access web interface
open http://localhost:8080
```

### Method 2: Automated Setup
```bash
# Download and execute setup script
curl -fsSL https://raw.githubusercontent.com/leedsspace/leeds-aprs-pi/main/scripts/setup.sh | sudo bash

# Follow interactive prompts
# System automatically configures based on detected hardware
```

### Method 3: Pre-built Images
```bash
# Download pre-configured image
wget https://github.com/leedsspace/leeds-aprs-pi/releases/latest/download/leeds-aprs-pi.img.gz

# Flash to SD card
gunzip -c leeds-aprs-pi.img.gz | dd of=/dev/sdX bs=4M status=progress
```

## ?? Configuration Management

### Environment Variables

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `CALLSIGN` | Amateur radio callsign | `G0ABC` | `W1ABC` |
| `APRS_PASS` | APRS-IS passcode | `12345` | `12345` |
| `LAT` | Latitude in decimal degrees | `53.8008` | `40.7128` |
| `LON` | Longitude in decimal degrees | `-1.5491` | `-74.0060` |
| `BEACON_MESSAGE` | Custom beacon message | `Leeds APRS Node` | `NYC APRS` |
| `BEACON_INTERVAL` | Beacon interval in seconds | `600` | `300` |
| `SYMBOL_TABLE` | APRS symbol table | `/` | `/` |
| `SYMBOL_CODE` | APRS symbol code | `&` | `>` |
| `TZ` | System timezone | `Europe/London` | `America/New_York` |

### Configuration Files

#### Direwolf Configuration (`config/direwolf.conf`)
```conf
# Station identification
MYCALL G0ABC
MODEM 1200

# APRS-IS server
IGSERVER noam.aprs2.net
IGLOGIN G0ABC 12345

# Beacon configuration
PBEACON delay=1 every=600 lat=53.8008 lon=-1.5491 symbol="/&" comment="Leeds APRS Node"

# Logging
LOGDIR /app/logs
LOGFILE direwolf.log
```

#### Docker Compose Configuration (`docker-compose.yml`)
```yaml
services:
  aprs:
    build: .
    container_name: leeds-aprs-pi
    devices:
      - "/dev/bus/usb:/dev/bus/usb"
    volumes:
      - ./config:/app/config:ro
      - ./logs:/app/logs:rw
    environment:
      - CALLSIGN=G0ABC
      - APRS_PASS=12345
      - LAT=53.8008
      - LON=-1.5491
```

## ?? Web Interface Documentation

### Dashboard Features

#### Real-time System Status
- **Service Status**: APRS, GPS, and network connectivity
- **Hardware Status**: RTL-SDR, GPS module, and audio devices
- **Performance Metrics**: CPU usage, memory consumption, temperature
- **Packet Statistics**: Transmitted and received packet counts

#### Configuration Management
- **Station Settings**: Callsign, location, and beacon configuration
- **Hardware Settings**: Audio levels, PTT control, and device selection
- **Network Settings**: APRS-IS server and filter configuration
- **Advanced Settings**: Modem parameters and logging options

#### Monitoring and Logging
- **Live Packet Display**: Real-time APRS packet monitoring
- **System Logs**: Detailed system and application logs
- **Performance Graphs**: Historical system performance data
- **Export Functions**: Data export for analysis and reporting

### API Endpoints

#### Status Endpoints
```
GET /api/status                   # System status summary
GET /api/status/hardware          # Hardware status details
GET /api/status/performance       # Performance metrics
GET /api/status/network          # Network connectivity status
```

#### Configuration Endpoints
```
GET /api/config                   # Current configuration
POST /api/config                  # Update configuration
GET /api/config/template          # Configuration template
POST /api/config/validate         # Validate configuration
```

#### Monitoring Endpoints
```
GET /api/logs                     # System logs
GET /api/logs/{service}           # Service-specific logs
GET /api/packets                  # APRS packets
GET /api/packets/statistics       # Packet statistics
```

#### Control Endpoints
```
POST /api/beacon                  # Send manual beacon
POST /api/restart                 # Restart system
POST /api/shutdown                # Shutdown system
POST /api/backup                  # Create configuration backup
```

### Laboratory Deployment

#### Multi-Station Setup
```bash
# Deploy to 20 lab stations
./scripts/deploy-lab.sh --stations 20 --callsign-base "W1ABC" --location "Lab A"

# Configure for specific exercise
./scripts/configure-exercise.sh --exercise "protocol-analysis" --duration 120
```

#### Assessment Integration
```bash
# Generate assessment configuration
./scripts/generate-assessment.sh --type "practical" --students 25

# Collect results
./scripts/collect-results.sh --assessment-id "aprs-lab-001"
```

## ?? Testing and Quality Assurance

### Test Suite Structure

#### Unit Tests
- **Configuration parsing**: Test configuration file handling
- **Hardware detection**: Test hardware enumeration and setup
- **API endpoints**: Test all REST API functionality
- **Web interface**: Test dashboard functionality

#### Integration Tests
- **End-to-end testing**: Complete system functionality
- **Hardware integration**: Test with actual hardware
- **Network integration**: Test APRS-IS connectivity
- **Multi-container testing**: Test container orchestration

#### Performance Tests
- **Resource utilization**: CPU, memory, and storage usage
- **Network performance**: Throughput and latency testing
- **Concurrent users**: Multi-user web interface testing
- **Long-running stability**: Extended operation testing

### Quality Metrics

#### Code Quality
- **Test Coverage**: >85% code coverage
- **Documentation**: Comprehensive inline documentation
- **Code Style**: PEP 8 compliance for Python, ESLint for JavaScript
- **Security**: Regular security scanning and updates

#### Performance Benchmarks
- **Boot Time**: <60 seconds from power-on to operational
- **Memory Usage**: <512MB under normal operation
- **CPU Usage**: <25% during normal operation
- **Network Latency**: <100ms API response time

## ??? Troubleshooting Guide

### Common Issues and Solutions

#### Docker Issues
```bash
# Issue: Container fails to start
# Solution: Check Docker daemon and rebuild
sudo systemctl start docker
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

#### Hardware Issues
```bash
# Issue: RTL-SDR not detected
# Solution: Check USB connection and permissions
lsusb | grep RTL
sudo chmod 666 /dev/bus/usb/*/***

# Issue: GPS not working
# Solution: Check GPS module and configure GPSD
sudo gpsd /dev/ttyUSB0 -F /var/run/gpsd.sock
```

#### Network Issues
```bash
# Issue: APRS-IS connection failed
# Solution: Check internet connectivity and credentials
ping rotate.aprs2.net
telnet rotate.aprs2.net 14580
```

#### Configuration Issues
```bash
# Issue: Invalid callsign format
# Solution: Verify callsign meets amateur radio standards
# Format: 1-2 letters, 1 number, 1-3 letters (e.g., W1ABC)

# Issue: Beacon not transmitting
# Solution: Check beacon configuration and permissions
./scripts/test-beacon.sh
```

### Debug Mode

#### Enable Debug Logging
```bash
# Set debug environment variable
export DEBUG=1

# Start with debug logging
docker-compose -f docker-compose.debug.yml up

# View detailed logs
docker-compose logs -f aprs
```

#### Hardware Diagnostics
```bash
# Run hardware diagnostic script
./scripts/diagnose-hardware.sh

# Test individual components
./scripts/test-rtl-sdr.sh
./scripts/test-gps.sh
./scripts/test-audio.sh
```

## ?? Performance Optimization

### Resource Optimization

#### Memory Optimization
```bash
# Enable memory optimization for Pi Zero
export OPTIMIZE_MEMORY=1

# Reduce log retention
export LOG_RETENTION_DAYS=7

# Optimize Docker memory usage
docker-compose -f docker-compose.lowmem.yml up
```

#### Network Optimization
```bash
# Use regional APRS-IS server
export APRS_SERVER="noam.aprs2.net"

# Optimize filter radius
export FILTER_RADIUS=50

# Enable packet compression
export ENABLE_COMPRESSION=1
```

### Performance Monitoring

#### System Monitoring
```bash
# Monitor container resource usage
docker stats

# Monitor system resources
htop
iotop
```

#### Application Monitoring
```bash
# Monitor APRS packet flow
./scripts/monitor-packets.sh

# Monitor API performance
./scripts/monitor-api.sh

# Generate performance report
./scripts/generate-report.sh
```

## ?? Security Considerations

### Network Security
- **Firewall Configuration**: Only necessary ports exposed
- **HTTPS Support**: Optional SSL/TLS encryption
- **API Authentication**: Token-based authentication available
- **Network Isolation**: Container network isolation

### System Security
- **User Permissions**: Non-root container execution
- **File Permissions**: Proper file and directory permissions
- **Dependency Management**: Regular security updates
- **Backup Procedures**: Automated configuration backups

### Amateur Radio Compliance
- **Station Identification**: Proper callsign transmission
- **Third-party Traffic**: Compliance with amateur radio regulations
- **RF Exposure**: SAR compliance for applicable configurations
- **Frequency Coordination**: Proper frequency usage

## ?? Future Roadmap

### Short-term Goals (3 months)
- **Enhanced Hardware Support**: More RTL-SDR and GPS devices
- **Improved Documentation**: Video tutorials and examples
- **Performance Optimizations**: Reduced resource usage
- **Bug Fixes**: Address reported issues

### Medium-term Goals (6 months)
- **Advanced Features**: Mesh networking, digital modes
- **Educational Content**: More course templates and exercises
- **Mobile Application**: Companion mobile app
- **Cloud Integration**: Cloud-based monitoring and management

### Long-term Goals (12 months)
- **IoT Integration**: Sensor data collection and transmission
- **Machine Learning**: Signal analysis and optimization
- **Research Applications**: Integration with academic research
- **Community Features**: User forums and collaboration tools

## ?? Contributing Guidelines

### Development Environment Setup
```bash
# Clone repository
git clone https://github.com/leedsspace/leeds-aprs-pi.git
cd leeds-aprs-pi

# Set up development environment
./scripts/dev-setup.sh

# Run development server
docker-compose -f docker-compose.dev.yml up
```

### Code Standards
- **Python**: PEP 8 compliance, type hints, docstrings
- **JavaScript**: ESLint configuration, JSDoc comments
- **Shell**: Bash strict mode, error handling
- **Docker**: Multi-stage builds, minimal images

### Testing Requirements
- **Unit Tests**: Required for all new features
- **Integration Tests**: Required for API changes
- **Hardware Tests**: Required for hardware-related changes
- **Documentation**: Required for all changes

## ?? Support and Community

### Getting Help
- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Community Q&A and ideas
- **Documentation**: Comprehensive guides and tutorials
- **Wiki**: Community-maintained knowledge base

### Leeds University Support
- **Student Support**: Available during lab hours
- **Faculty Support**: Integration with course curriculum
- **Research Support**: Collaboration opportunities
- **Equipment Loans**: Hardware for student projects

### Community Resources
- **Amateur Radio Clubs**: Local club integration
- **Online Forums**: Reddit, Discord, and forums
- **Conferences**: Presentations at amateur radio events
- **Workshops**: Hands-on training sessions

---

**This documentation is maintained by the Leeds Space Communications Society and the amateur radio community. For questions, suggestions, or contributions, please visit our GitHub repository or contact us directly.**

**73 de Leeds Space Comms! ??**