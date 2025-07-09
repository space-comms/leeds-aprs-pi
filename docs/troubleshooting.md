# Leeds APRS Pi Documentation
**Troubleshooting Guide**

---

## Common Issues and Solutions

This guide covers the most common issues encountered when setting up and running the Leeds APRS Pi system, along with their solutions.

---

## Docker and Container Issues

### Container Won't Start

#### Symptoms
- `docker-compose up` fails
- Container exits immediately
- Error messages about permissions

#### Diagnostic Steps
```bash
# Check container logs
docker-compose logs

# Check Docker daemon status
systemctl status docker

# Verify Docker Compose file
docker-compose config
```

#### Solutions
```bash
# Restart Docker daemon
sudo systemctl restart docker

# Fix permissions
sudo chown -R $USER:$USER /opt/leeds-aprs-pi
sudo chmod +x scripts/*.sh

# Rebuild container
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Container Keeps Restarting

#### Symptoms
- Container restarts continuously
- High CPU usage
- Constant log messages

#### Diagnostic Steps
```bash
# Check restart policy
docker inspect leeds-aprs-pi | grep -i restart

# Monitor container status
watch docker-compose ps

# Check resource usage
docker stats leeds-aprs-pi
```

#### Solutions
```bash
# Temporarily disable restart
docker-compose down
# Edit docker-compose.yml, change restart: unless-stopped to restart: "no"
docker-compose up -d

# Check for configuration errors
docker-compose exec aprs /app/scripts/status.sh --once

# Monitor system resources
htop
```

---

## Hardware Detection Issues

### RTL-SDR Not Detected

#### Symptoms
- No RTL-SDR device in `lsusb`
- Direwolf can't access RTL-SDR
- Permission denied errors

#### Diagnostic Steps
```bash
# Check USB devices
lsusb | grep RTL

# Check device permissions
ls -la /dev/bus/usb/

# Test RTL-SDR directly
rtl_test -t
```

#### Solutions
```bash
# Install RTL-SDR drivers
sudo apt-get update
sudo apt-get install rtl-sdr

# Create udev rules
sudo tee /etc/udev/rules.d/20-rtl-sdr.rules << 'EOF'
SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP="plugdev", MODE="0666"
EOF

# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger

# Add user to plugdev group
sudo usermod -aG plugdev $USER
```

### GPS Device Not Working

#### Symptoms
- No GPS data in logs
- `/dev/ttyUSB0` not present
- GPS daemon won't start

#### Diagnostic Steps
```bash
# Check for GPS device
ls -la /dev/ttyUSB* /dev/ttyACM*

# Check device permissions
ls -la /dev/ttyUSB0

# Test GPS directly
sudo gpspipe -w -n 10
```

#### Solutions
```bash
# Install GPS tools
sudo apt-get install gpsd gpsd-clients

# Add user to dialout group
sudo usermod -aG dialout $USER

# Stop conflicting services
sudo systemctl stop gpsd
sudo systemctl disable gpsd

# Test GPS manually
sudo gpsd -n -D 2 -F /var/run/gpsd.sock /dev/ttyUSB0
```

### Audio Device Issues

#### Symptoms
- No audio devices detected
- Permission denied for audio
- Poor audio quality

#### Diagnostic Steps
```bash
# List audio devices
aplay -l
arecord -l

# Check audio permissions
groups $USER | grep audio

# Test audio playback
speaker-test -t sine -f 1000 -l 1
```

#### Solutions
```bash
# Add user to audio group
sudo usermod -aG audio $USER

# Install audio tools
sudo apt-get install alsa-utils

# Configure audio levels
alsamixer

# Test audio recording
arecord -D plughw:0,0 -f cd -t wav -d 5 test.wav
aplay test.wav
```

---

## Network and APRS-IS Issues

### Can't Connect to APRS-IS

#### Symptoms
- No APRS-IS connection in logs
- Beacons not appearing on aprs.fi
- Network connection errors

#### Diagnostic Steps
```bash
# Check network connectivity
ping 8.8.8.8
ping noam.aprs2.net

# Check APRS-IS connection
netstat -an | grep 14580

# Test APRS-IS login
telnet noam.aprs2.net 14580
```

#### Solutions
```bash
# Check firewall settings
sudo ufw status
sudo ufw allow out 14580/tcp

# Verify APRS passcode
# Visit https://apps.magicbug.co.uk/passcode/
# Generate correct passcode for your callsign

# Try different APRS-IS server
# Edit docker-compose.yml:
# - APRS_SERVER=euro.aprs2.net
```

### Beacons Not Appearing

#### Symptoms
- No beacons on aprs.fi
- Direwolf shows beacon transmission
- APRS-IS connected but no activity

#### Diagnostic Steps
```bash
# Check beacon configuration
grep -i beacon config/direwolf.conf

# Monitor APRS-IS traffic
docker-compose exec aprs tail -f /app/logs/direwolf.log | grep -i beacon

# Verify coordinates
echo "LAT: $LAT, LON: $LON"
```

#### Solutions
```bash
# Check beacon syntax
# Ensure proper format:
# PBEACON delay=1 every=600 lat=53.8008 lon=-1.5491 symbol="/&" comment="Test"

# Verify APRS passcode
# Must match your callsign exactly

# Check beacon timing
# Ensure beacon interval is reasonable (>60 seconds)

# Test manual beacon
# In Direwolf, use #BEACON command
```

---

## Configuration Issues

### Invalid Configuration

#### Symptoms
- Direwolf won't start
- Configuration errors in logs
- Unexpected behavior

#### Diagnostic Steps
```bash
# Test configuration
direwolf -c config/direwolf.conf -t

# Check syntax
docker-compose config

# Validate environment variables
docker-compose exec aprs env | grep APRS
```

#### Solutions
```bash
# Common configuration fixes
# 1. Check callsign format (no spaces, proper length)
# 2. Verify coordinates are decimal degrees
# 3. Ensure APRS passcode is numeric
# 4. Check symbol table and code

# Reset to default configuration
cp config/direwolf.conf config/direwolf.conf.backup
cp config/direwolf.conf.template config/direwolf.conf

# Validate step by step
scripts/validate-config.sh
```

### Environment Variables Not Set

#### Symptoms
- Default values being used
- Callsign shows as "N0CALL"
- Beacons from wrong location

#### Diagnostic Steps
```bash
# Check environment variables
docker-compose exec aprs env | grep -E "(CALLSIGN|LAT|LON|APRS_PASS)"

# Check docker-compose.yml
grep -A 10 "environment:" docker-compose.yml
```

#### Solutions
```bash
# Edit docker-compose.yml
# Ensure all required variables are set:
environment:
  - CALLSIGN=YOUR_CALLSIGN
  - APRS_PASS=YOUR_PASSCODE
  - LAT=YOUR_LATITUDE
  - LON=YOUR_LONGITUDE

# Recreate containers
docker-compose down
docker-compose up -d
```

---

## Performance Issues

### High CPU Usage

#### Symptoms
- System sluggish
- High temperature
- Thermal throttling

#### Diagnostic Steps
```bash
# Monitor CPU usage
htop
top -p $(pgrep direwolf)

# Check CPU temperature
vcgencmd measure_temp

# Check for throttling
vcgencmd get_throttled
```

#### Solutions
```bash
# Optimize Direwolf configuration
# Use single modem:
MODEM 1200

# Reduce sample rate:
ARATE 22050

# Disable fix bits:
FIX_BITS 0

# Add cooling
# - Install heatsinks
# - Add fan
# - Improve case ventilation
```

### Memory Issues

#### Symptoms
- System freezes
- Out of memory errors
- Slow response

#### Diagnostic Steps
```bash
# Check memory usage
free -h
ps aux --sort=-%mem | head

# Monitor memory over time
watch -n 1 free -h
```

#### Solutions
```bash
# Add swap file
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Optimize configuration
# Reduce buffer sizes
# Limit log file sizes
# Disable unnecessary features

# Increase GPU memory split
# Edit /boot/config.txt:
# gpu_mem=16
```

### Disk Space Issues

#### Symptoms
- Disk full errors
- System won't start
- Log rotation failures

#### Diagnostic Steps
```bash
# Check disk usage
df -h
du -h /app/logs/

# Find large files
find /app -size +10M -type f
```

#### Solutions
```bash
# Clean up logs
sudo find /app/logs -name "*.log" -mtime +7 -delete

# Rotate logs manually
scripts/rotate-logs.sh

# Configure log rotation
# Edit /etc/logrotate.d/aprs
/app/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
```

---

## Service Management Issues

### Services Not Starting

#### Symptoms
- systemctl start fails
- Services don't start at boot
- Permission errors

#### Diagnostic Steps
```bash
# Check service status
systemctl status leeds-aprs-pi

# Check service logs
journalctl -u leeds-aprs-pi

# Check service file
cat /etc/systemd/system/leeds-aprs-pi.service
```

#### Solutions
```bash
# Reload systemd
sudo systemctl daemon-reload

# Fix service file permissions
sudo chmod 644 /etc/systemd/system/leeds-aprs-pi.service

# Enable service
sudo systemctl enable leeds-aprs-pi

# Start service
sudo systemctl start leeds-aprs-pi
```

### Health Check Failures

#### Symptoms
- Container marked as unhealthy
- Automatic restarts
- Service monitoring alerts

#### Diagnostic Steps
```bash
# Check health status
docker inspect leeds-aprs-pi | grep -i health

# Manual health check
docker-compose exec aprs /app/scripts/health-check.sh

# Check monitoring logs
tail -f /app/logs/monitor.log
```

#### Solutions
```bash
# Adjust health check parameters
# In docker-compose.yml:
healthcheck:
  test: ["CMD", "pgrep", "-f", "direwolf"]
  interval: 60s
  timeout: 30s
  retries: 3
  start_period: 120s

# Fix underlying issues
# Check service logs
# Verify configuration
# Test hardware
```

---

## Advanced Troubleshooting

### Debug Mode

#### Enable Debug Logging
```bash
# Edit docker-compose.yml
environment:
  - DEBUG_LEVEL=3
  - VERBOSE_LOGGING=true

# Restart container
docker-compose restart
```

#### Analyze Debug Output
```bash
# Monitor debug logs
docker-compose logs -f | grep -i debug

# Save debug session
docker-compose logs > debug-$(date +%Y%m%d-%H%M%S).log
```

### Interactive Debugging

#### Container Shell Access
```bash
# Access running container
docker-compose exec aprs /bin/bash

# Check processes
ps aux

# Test commands manually
direwolf -c /app/config/direwolf.conf -t
```

#### Hardware Testing
```bash
# Test RTL-SDR
rtl_test -t

# Test GPS
gpspipe -w -n 5

# Test audio
aplay /usr/share/sounds/alsa/Front_Left.wav
```

### Log Analysis

#### Key Log Locations
```bash
# Main application logs
/app/logs/direwolf.log      # Direwolf output
/app/logs/monitor.log       # System monitoring
/app/logs/health.log        # Health metrics
/app/logs/alerts.log        # System alerts

# System logs
/var/log/syslog            # System messages
/var/log/kern.log          # Kernel messages
```

#### Log Analysis Commands
```bash
# Search for errors
grep -i error /app/logs/*.log

# Check for restarts
grep -i restart /app/logs/monitor.log

# Monitor real-time
tail -f /app/logs/direwolf.log | grep -i --color=always "beacon\|error\|warning"
```

---

## Getting Help

### Information to Collect

When seeking help, please provide:

1. **System Information**
   ```bash
   uname -a
   cat /proc/device-tree/model
   free -h
   df -h
   ```

2. **Hardware Information**
   ```bash
   lsusb
   lspci
   dmesg | grep -i usb
   ```

3. **Configuration Files**
   ```bash
   cat docker-compose.yml
   cat config/direwolf.conf
   ```

4. **Logs**
   ```bash
   docker-compose logs --tail=50
   tail -50 /app/logs/direwolf.log
   ```

### Support Resources

- **Leeds Space Comms Forum**: [Community support]
- **GitHub Issues**: [Bug reports and feature requests]
- **Direwolf Documentation**: [Official Direwolf manual]
- **APRS Specification**: [APRS protocol documentation]

---

*This troubleshooting guide is maintained by Leeds Space Comms for the amateur radio community.*
