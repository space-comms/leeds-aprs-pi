# ?? Leeds APRS Pi v1.1a Release Notes

## ?? Release Summary

**Version:** v1.1a  
**Release Date:** January 2025  
**Repository:** https://github.com/space-comms/leeds-aprs-pi  
**Tag:** v1.1a  
**Status:** ? Production Ready - Enhanced Beacon Configuration

## ?? What's New in v1.1a

### ?? **Enhanced Beacon Configuration System**

#### **Dynamic Beacon Configuration**
- **Environment Variable Integration**: Full support for `${VARIABLE}` substitution in beacon.conf
- **Leeds Space Comms Specific Settings**: Tailored configurations for university operations
- **Multiple Operational Profiles**: Fixed, Mobile, Event, Emergency, Field Day modes
- **Time-based Scheduling**: Automatic beacons at specific times (morning, noon, evening)
- **Educational Mode**: Special settings for demonstrations and teaching
- **University Schedule Integration**: Term-time awareness and vacation modes

#### **Advanced Beacon Processor Script**
- **Configuration Validation**: Comprehensive validation of callsign, coordinates, and timing
- **Direwolf Integration**: Automatic generation of proper Direwolf beacon statements
- **Error Handling**: Detailed error reporting and configuration suggestions
- **Summary Generation**: Human-readable configuration reports

### ?? **Leeds Space Comms Educational Features**

#### **Club-Specific Enhancements**
- **Net Reminders**: Automatic reminders for weekly club nets
- **Contact Information**: Embedded club and university contact details
- **Educational Demonstrations**: Special beacon modes for open days and lab sessions
- **Emergency Training**: Support for emergency communication exercises
- **Field Day Operations**: Optimized configurations for contests and field activities

#### **University Integration**
- **Academic Schedule**: Different beacon behavior during term vs. vacation
- **Course Integration**: Ready-to-use templates for academic courses
- **Laboratory Support**: Multi-station lab configurations
- **Student Projects**: Framework for student project deployments

### ?? **Configuration Improvements**

#### **Beacon Profiles**
```
[PROFILE_FIXED]        # Normal club station operation
[PROFILE_MOBILE]       # Field activities and portable operation  
[PROFILE_EVENT]        # Special events and demonstrations
[PROFILE_EMERGENCY_TRAINING]  # Emergency communication exercises
[PROFILE_FIELD_DAY]    # Contest and field day operations
```

#### **Time-Based Beacons**
```
08:00="Leeds Space Comms - Good Morning from the University of Leeds!"
12:00="Leeds Space Comms - Midday operational check"  
19:00="Leeds Space Comms - Net starting now on 145.500 MHz"
22:00="Leeds Space Comms - QRT for tonight, 73!"
```

#### **Quality of Service Features**
- **Rate Limiting**: Prevents excessive network usage
- **Bandwidth Conservation**: Compressed packets and smart scheduling
- **APRS Compliance**: Ensures all beacons meet APRS specifications
- **Quiet Hours**: Automatic beacon suspension during nighttime hours

## ?? **New Configuration Options**

### **Environment Variables**
```yaml
# Enhanced beacon control
- EDUCATIONAL_MODE=true           # Enable educational features
- GPS_ENABLED=true               # Enable GPS beacons
- BEACON_JITTER=30               # Randomization to avoid collisions
- QUIET_HOURS=23,0,1,2,3,4,5     # No beacons during these hours
- CLUB_NET_TIME=19:00            # Weekly net reminder time
- TERM_SCHEDULE=true             # University term awareness
```

### **Advanced Features**
```yaml
# Quality of service
- LOW_BANDWIDTH_MODE=false       # Bandwidth conservation mode
- MAX_BEACONS_PER_HOUR=6        # Rate limiting
- VALIDATE_CONTENT=true          # Content validation
- LOG_LEVEL=INFO                 # Configurable logging

# Emergency features
- EMERGENCY_ENABLED=false        # Emergency beacon capability
- EMERGENCY_CONTACT=info         # Emergency contact information
```

## ?? **Changes from v1.1.0**

### **Added**
- ? **Enhanced beacon.conf**: Complete rewrite with environment variable support
- ? **configure-beacon.sh**: New beacon configuration processor script
- ? **Leeds-specific settings**: University and club-specific configurations
- ? **Multiple beacon profiles**: Support for different operational modes
- ? **Time-based scheduling**: Automatic beacon scheduling throughout the day
- ? **Educational features**: Special modes for teaching and demonstrations
- ? **Quality of service**: Rate limiting and bandwidth conservation
- ? **Configuration validation**: Comprehensive parameter checking

### **Improved**
- ? **Beacon flexibility**: Much more flexible and powerful beacon system
- ? **User experience**: Easier configuration through environment variables
- ? **Educational use**: Better support for university and club activities
- ? **APRS compliance**: Enhanced compliance with APRS best practices
- ? **Documentation**: Comprehensive beacon configuration documentation

## ?? **Project Statistics Update**

| Metric | v1.1.0 | v1.1a | Change |
|--------|--------|-------|--------|
| **Configuration Files** | 2 | 3 | +50% |
| **Beacon Profiles** | 1 | 5 | +400% |
| **Environment Variables** | 8 | 25+ | +200% |
| **Scripts** | 6 | 7 | +17% |
| **Educational Features** | Basic | Advanced | ?? |
| **Leeds Integration** | Basic | Comprehensive | ?? |

## ??? **Technical Specifications**

### **New Dependencies**
- **envsubst**: For environment variable substitution
- **bc**: For floating-point arithmetic in validation
- **Enhanced bash scripting**: More sophisticated configuration processing

### **Configuration Processing**
- **Template Processing**: Dynamic substitution of environment variables
- **Validation Pipeline**: Multi-stage validation of all parameters
- **Error Reporting**: Detailed error messages with suggestions
- **Configuration Summary**: Generated documentation of active settings

## ?? **Installation & Upgrade**

### **Fresh Installation**
```bash
# Clone repository
git clone https://github.com/space-comms/leeds-aprs-pi.git
cd leeds-aprs-pi

# Configure your settings
nano docker-compose.yml

# Deploy with enhanced beacon configuration
docker-compose up -d
```

### **Upgrade from v1.1.0**
```bash
# Update repository
git fetch origin
git checkout v1.1a

# Your existing docker-compose.yml will work with new features
# Optional: Add new environment variables for enhanced features

# Restart with new configuration
docker-compose down
docker-compose up -d
```

### **Enhanced Configuration Example**
```yaml
# Add these to your docker-compose.yml for v1.1a features
environment:
  - CALLSIGN=G0LDS
  - APRS_PASS=12345
  - LAT=53.8008
  - LON=-1.5491
  - BEACON_MESSAGE=Leeds Space Comms APRS Node
  - EDUCATIONAL_MODE=true        # New in v1.1a
  - GPS_ENABLED=true            # Enhanced in v1.1a
  - CLUB_NET_TIME=19:00         # New in v1.1a
  - TERM_SCHEDULE=true          # New in v1.1a
```

## ?? **Educational Use Cases**

### **University Demonstrations**
```yaml
# Perfect for open days and lab demonstrations
- EDUCATIONAL_MODE=true
- BEACON_INTERVAL=180           # 3-minute beacons for demos
- BEACON_MESSAGE=Leeds Space Comms - Open Day Demo
- SYMBOL_CODE=E                 # Educational symbol
```

### **Student Projects**
```yaml
# Individual student station configuration
- CALLSIGN=G0LDS/STU01
- BEACON_MESSAGE=Leeds Space Comms - Student Project
- STUDENT_MODE=true
- LOG_LEVEL=DEBUG
```

### **Field Day Operations**
```yaml
# Contest and field day configuration
- CALLSIGN=G0LDS/FD
- BEACON_MESSAGE=Leeds Space Comms - Field Day
- BEACON_INTERVAL=300
- SYMBOL_CODE=F
- GPS_ENABLED=true
```

## ?? **Community & Repository**

### **Updated Repository Information**
- **New Repository**: https://github.com/space-comms/leeds-aprs-pi
- **Organization**: Space Communications
- **Maintainer**: Leeds Space Communications Society
- **Community**: Amateur radio and educational communities

### **Support Channels**
- **GitHub Issues**: Technical support and bug reports
- **Documentation**: Comprehensive guides in the docs/ directory
- **Club Support**: Direct support for Leeds Space Comms members
- **Community Forums**: Amateur radio community discussions

## ?? **Future Development**

### **v1.2.0 Planned Features**
- **Web-based Configuration**: Browser-based beacon configuration interface
- **Real-time Monitoring**: Live beacon status and performance monitoring
- **Advanced Scheduling**: Calendar-based beacon scheduling
- **Multi-language Support**: International language support for messages

### **Long-term Roadmap**
- **Cloud Configuration**: Cloud-based configuration management
- **Machine Learning**: Intelligent beacon optimization
- **Mobile Applications**: Smartphone companion apps
- **Research Integration**: Advanced research and development features

## ?? **Contributors**

### **v1.1a Development Team**
- **Lead Developer**: Al-Musbahi
- **Leeds Space Comms**: Requirements and testing
- **Amateur Radio Community**: Feedback and validation
- **University of Leeds**: Educational requirements and integration

### **Special Recognition**
- **Beta Testers**: Early adopters of the enhanced beacon system
- **Configuration Contributors**: Community members who provided configuration examples
- **Documentation Team**: Contributors who improved the documentation

## ?? **Technical Notes**

### **Compatibility**
- **Backward Compatible**: All v1.1.0 configurations continue to work
- **Enhanced Features**: New features available through environment variables
- **Gradual Migration**: Can gradually adopt new features as needed

### **Performance Impact**
- **Minimal Overhead**: Configuration processing adds <5 seconds to startup
- **Memory Usage**: No significant increase in memory usage
- **Network Impact**: Improved rate limiting reduces network usage

## ?? **Conclusion**

Leeds APRS Pi v1.1a represents a significant enhancement to the beacon configuration system, making it much more suitable for educational use, club operations, and amateur radio activities. The enhanced configuration system provides unprecedented flexibility while maintaining simplicity for basic users.

The Leeds Space Comms specific features make this release particularly valuable for university amateur radio clubs and educational institutions looking to integrate APRS technology into their curriculum.

**73 de Leeds Space Comms! ??**

---

*For support, documentation, and community resources, visit:*  
**https://github.com/space-comms/leeds-aprs-pi**

*Leeds Space Communications Society*  
*University of Leeds*  
*Amateur Radio Education and Innovation*