# Leeds APRS Pi Documentation
**Leeds Space Comms Setup Guide**

---

## Welcome to Leeds Space Comms

This guide provides specific setup instructions for Leeds Space Comms members and visitors to the University of Leeds amateur radio station.

---

## Leeds Space Comms Overview

### About Us
**Leeds Space Comms** is the amateur radio society at the University of Leeds, supporting students, staff, and the wider amateur radio community in Yorkshire and beyond.

### Our Mission
- Promote amateur radio education and experimentation
- Provide hands-on learning opportunities
- Support emergency communications training
- Foster innovation in radio technology

### Club Information
- **Callsign**: G0XYZ (Example - use actual club callsign when received)
- **Location**: University of Leeds, Leeds, UK
- **Grid Square**: IO93ST
- **Coordinates**: 53.8008°N, 1.5491°W

---

## Club Station Configuration

### Default Settings for Leeds

#### Location Configuration
```yaml
# Leeds University coordinates
LAT=53.8008
LON=-1.5491
ALTITUDE=100

# Grid square and location info
GRID_SQUARE=IO93ST
LOCATION=Leeds, UK
```

#### Beacon Configuration
```yaml
# Standard club beacon
BEACON_MESSAGE=Leeds Space Comms - University of Leeds
BEACON_COMMENT=Educational APRS station - Students welcome!
BEACON_URL=https://leedsspace.com

# Beacon timing for club use
BEACON_INTERVAL=600    # 10 minutes
```

#### Symbol Configuration
```yaml
# Use appropriate symbol for club station
SYMBOL_TABLE=/
SYMBOL_CODE=&          # Gateway/IGate symbol
```

---

## Member Setup Instructions

### Individual Member Setup

#### Personal Configuration
```bash
# Edit your personal settings
CALLSIGN=YOUR_CALLSIGN
APRS_PASS=YOUR_PASSCODE
BEACON_MESSAGE=Leeds Space Comms Member - YOUR_NAME
```

#### Member Beacon Format
```bash
# Standard member beacon format
BEACON_MESSAGE="Leeds Space Comms - {Member Name}"
BEACON_COMMENT="Student/Staff at University of Leeds"
BEACON_URL="https://leedsspace.com"
```

### Group Project Setup

#### Project Configuration
```bash
# Project-specific settings
CALLSIGN=PROJECT_CALLSIGN
BEACON_MESSAGE="Leeds Space Comms - {Project Name}"
BEACON_COMMENT="Educational project - University of Leeds"
```

#### Multiple Station Setup
```bash
# For multiple stations
STATION_ID=1
BEACON_MESSAGE="Leeds Space Comms Node ${STATION_ID}"
SYMBOL_CODE="&"        # Gateway for base stations
```

---

## Hardware Recommendations for Leeds

### Recommended Hardware

#### Basic Setup (Students)
- **Raspberry Pi 4B 4GB**: Good performance, educational value
- **RTL-SDR V3**: Affordable receive-only setup
- **GPS Module**: USB GPS for accuracy
- **32GB SD Card**: Sufficient for basic operation

#### Advanced Setup (Research)
- **Raspberry Pi 4B 8GB**: Better performance for complex projects
- **RTL-SDR + Audio Interface**: Full TX/RX capability
- **External GPS**: Higher accuracy for research applications
- **SSD Storage**: Better reliability for continuous operation

#### Club Station Setup
- **Raspberry Pi 4B 8GB**: Maximum performance
- **Professional Audio Interface**: High-quality audio
- **Redundant GPS**: Multiple GPS sources
- **UPS Power**: Uninterruptible power supply

### Hardware Procurement

#### University Procurement
- Contact IT Services for approved suppliers
- Use university purchase orders for equipment
- Consider educational discounts available

#### Personal Purchases
- Recommended suppliers for students
- Educational discounts and programs
- Club group purchases for better pricing

---

## Network Configuration for Leeds

### University Network Setup

#### Network Requirements
```bash
# University network configuration
NETWORK_MODE=university
PROXY_SERVER=proxy.leeds.ac.uk:8080
DNS_SERVERS=129.11.1.1,129.11.1.2
```

#### Firewall Configuration
```bash
# Required ports for university network
APRS_IS_PORT=14580      # APRS-IS connection
HTTP_PORT=8080          # Web interface
MONITOR_PORT=8001       # Monitoring interface
```

#### VPN Configuration
```bash
# For off-campus access
VPN_SERVER=vpn.leeds.ac.uk
VPN_TYPE=anyconnect
```

### Eduroam Configuration

#### WiFi Setup
```bash
# Eduroam credentials
SSID=eduroam
USERNAME=your_username@leeds.ac.uk
PASSWORD=your_password
```

#### Connection Testing
```bash
# Test university network connectivity
ping google.com
ping noam.aprs2.net
nslookup aprs.fi
```

---

## Educational Integration

### Course Integration

#### Electronics Courses
- **ELEC2630**: Digital Signal Processing
- **ELEC3630**: Communications Systems
- **ELEC5620**: Advanced Digital Signal Processing

#### Computing Courses
- **COMP2611**: Embedded Systems
- **COMP3611**: Computer Networks
- **COMP5611**: Distributed Systems

#### Physics Courses
- **PHYS2600**: Electromagnetism
- **PHYS3600**: Waves and Optics
- **PHYS5600**: Advanced Electromagnetism

### Project Ideas

#### Undergraduate Projects
1. **APRS Tracker Development**
   - GPS-based position reporting
   - Low-power design considerations
   - Real-time tracking implementation

2. **Digital Signal Processing**
   - Modem design and optimization
   - Error correction implementation
   - Signal analysis and filtering

3. **Network Protocol Analysis**
   - APRS protocol implementation
   - Network performance analysis
   - Internet gateway development

#### Postgraduate Projects
1. **Advanced APRS Applications**
   - Mesh networking implementation
   - Emergency communication systems
   - IoT integration with APRS

2. **Research Applications**
   - Propagation studies
   - Antenna design optimization
   - Software-defined radio development

---

## Lab Setup and Procedures

### Laboratory Configuration

#### Standard Lab Setup
```bash
# Lab station configuration
LOCATION=Electronics_Lab_A
CALLSIGN=G0XYZ/P
BEACON_MESSAGE="Leeds Space Comms - Lab Station"
BEACON_COMMENT="Educational demonstration"
```

#### Multi-Station Lab
```bash
# Multiple lab stations
STATION_COUNT=10
for i in $(seq 1 $STATION_COUNT); do
    STATION_ID=$i
    CALLSIGN="G0XYZ/P$i"
    BEACON_MESSAGE="Leeds Space Comms - Lab Station $i"
done
```

### Safety Procedures

#### RF Safety
- Maximum power levels for educational use
- Antenna placement guidelines
- Exposure calculations and limits

#### Electrical Safety
- Proper grounding procedures
- Safe power supply practices
- Emergency procedures

---

## Event and Demonstration Setup

### Special Events

#### Open Days
```bash
# Open day configuration
CALLSIGN=G0XYZ/OPEN
BEACON_MESSAGE="Leeds Space Comms - Open Day Demo"
BEACON_COMMENT="University of Leeds - Visitors Welcome!"
BEACON_INTERVAL=180    # More frequent for demos
```

#### Field Day
```bash
# Field day configuration
CALLSIGN=G0XYZ/FD
BEACON_MESSAGE="Leeds Space Comms - Field Day"
BEACON_COMMENT="ARRL Field Day - University of Leeds"
SYMBOL_CODE="F"        # Field Day symbol
```

### Demonstration Scripts

#### Automated Demo
```bash
#!/bin/bash
# Automated demonstration script
echo "Starting Leeds Space Comms APRS Demo..."
docker-compose up -d
sleep 30
scripts/status.sh --once
echo "Demo running - check aprs.fi for beacons"
```

#### Interactive Demo
```bash
#!/bin/bash
# Interactive demonstration
echo "Welcome to Leeds Space Comms APRS Demo"
echo "1. View system status"
echo "2. Send test beacon"
echo "3. Monitor received packets"
read -p "Choose option: " choice
case $choice in
    1) scripts/status.sh --once ;;
    2) scripts/send-beacon.sh ;;
    3) scripts/monitor-packets.sh ;;
esac
```

---

## Maintenance and Support

### Regular Maintenance

#### Daily Tasks
- Check system status
- Monitor beacon operation
- Verify network connectivity

#### Weekly Tasks
- Review system logs
- Check hardware connections
- Update configuration if needed

#### Monthly Tasks
- System updates and patches
- Hardware inspection
- Performance review

### Support Procedures

#### Technical Support
- **Primary Contact**: Club Technical Officer
- **Backup Contact**: Faculty Technical Support
- **Email**: tech@leedsspace.com

#### Emergency Procedures
- **Emergency Contact**: 24/7 IT Support
- **Backup Systems**: Manual operation procedures
- **Recovery**: Disaster recovery procedures

---

## Advanced Features for Leeds

### Custom Applications

#### Student Projects
```bash
# Custom application framework
APP_NAME=student_project
APP_VERSION=1.0
APP_AUTHOR=student_name
APP_DESCRIPTION="Custom APRS application for Leeds Space Comms"
```

#### Research Integration
```bash
# Research data collection
RESEARCH_MODE=enabled
DATA_COLLECTION=enabled
ANALYSIS_TOOLS=enabled
```

### Integration with Other Systems

#### University Systems
- **LDAP Integration**: User authentication
- **Network Monitoring**: Integration with campus monitoring
- **Data Logging**: Research data collection

#### External Services
- **Weather Station**: Local weather data
- **Emergency Services**: Emergency communication links
- **Other Clubs**: Inter-club communication

---

## Resources and References

### Leeds Space Comms Resources

#### Internal Resources
- **Club Wiki**: Internal documentation
- **Equipment Database**: Hardware inventory
- **Project Archive**: Past student projects

#### External Resources
- **RSGB**: Radio Society of Great Britain
- **AMSAT-UK**: Amateur satellite information
- **UKHAS**: UK High Altitude Society

### Training Materials

#### Beginner Resources
- **Foundation License**: Basic amateur radio concepts
- **APRS Basics**: Introduction to APRS
- **Raspberry Pi**: Basic Pi setup and operation

#### Advanced Resources
- **Digital Signal Processing**: Advanced DSP concepts
- **Software-Defined Radio**: SDR theory and practice
- **Network Protocols**: Advanced networking concepts

---

## Contact Information

### Leeds Space Comms Officers

#### Club Officers
- **President**: [Name] - president@leedsspace.com
- **Secretary**: [Name] - secretary@leedsspace.com
- **Treasurer**: [Name] - treasurer@leedsspace.com
- **Technical Officer**: [Name] - tech@leedsspace.com

#### Faculty Support
- **Faculty Advisor**: [Name] - advisor@leedsspace.com
- **Technical Support**: [Name] - support@leedsspace.com

### Meeting Information

#### Regular Meetings
- **When**: Every Thursday, 7:00 PM
- **Where**: Electronics Lab A, Engineering Building
- **Format**: Hybrid (in-person and online)

#### Special Events
- **Monthly Projects**: First Saturday of each month
- **Annual Field Day**: Summer term
- **Training Sessions**: Throughout the year

---

*This guide is maintained by Leeds Space Comms for club members and the amateur radio community.*
