# Leeds APRS Pi Documentation
**Hardware Setup Guide**

---

## Hardware Requirements

### Essential Components

#### Raspberry Pi
- **Recommended**: Raspberry Pi 4 Model B (4GB or 8GB RAM)
- **Minimum**: Raspberry Pi 3 Model B+ (1GB RAM)
- **Future-proof**: Raspberry Pi 5 (when available)

#### Storage
- **MicroSD Card**: 32GB Class 10 or better
- **Recommended**: SanDisk Ultra or Samsung EVO Select
- **Optional**: USB SSD for better performance

#### Power Supply
- **Official**: Raspberry Pi USB-C Power Supply (5V 3A)
- **Alternative**: Quality 5V 3A USB-C power adapter
- **Note**: Insufficient power causes instability

### APRS Hardware Options

#### Option 1: RTL-SDR (Receive Only)
- **Device**: RTL-SDR V3 dongle
- **Frequency Range**: 500kHz - 1.7GHz
- **Use Case**: APRS receiving, APRS-IS gateway
- **Antenna**: 2m band dipole or mobile antenna

#### Option 2: Soundcard Interface (TX/RX)
- **Device**: USB audio interface or Pi built-in audio
- **Radio**: Any 2m FM transceiver with audio connections
- **Cables**: Audio isolation cables
- **PTT**: GPIO-controlled relay or VOX

#### Option 3: Complete TNC Solution
- **Device**: Direwolf software TNC
- **Radio**: Handheld or mobile 2m transceiver
- **Interface**: Audio isolator and PTT circuit

### GPS Hardware (Optional)

#### USB GPS Receivers
- **Recommended**: GlobalSat BU-353-S4
- **Alternative**: Any USB GPS with NMEA output
- **Use Case**: Mobile beacons, accurate time sync

#### GPIO GPS Modules
- **Device**: GPS HAT or breakout board
- **Advantage**: No USB port required
- **Disadvantage**: More complex wiring

---

## Physical Setup

### Basic RTL-SDR Setup

```
[Antenna] ──── [RTL-SDR] ──── [Pi USB Port]
```

1. **Connect RTL-SDR** to Pi USB port
2. **Attach antenna** to RTL-SDR SMA connector
3. **Position antenna** for best reception
4. **Test reception** with `rtl_test`

### Soundcard Interface Setup

```
[Radio] ──── [Audio Interface] ──── [Pi USB/Audio]
           ∧                     ∧
           │                     │
      [PTT Circuit]         [GPIO Pin]
```

1. **Connect audio cables** from radio to interface
2. **Wire PTT circuit** to GPIO pin
3. **Test audio levels** with `alsamixer`
4. **Verify PTT operation** with test script

### Complete Station Layout

```
┌─────────────────┐    ┌─────────────┐    ┌─────────────┐
│   Raspberry Pi  │    │   Radio     │    │   Antenna   │
│                 │    │             │    │             │
│  ┌─────────┐    │    │  ┌───────┐  │    │      |      │
│  │Direwolf │◄───┼────┤  │ 2m FM │  │    │      |      │
│  │   TNC   │    │    │  │  TX   │  │    │      |      │
│  └─────────┘    │    │  └───────┘  │    │      |      │
│                 │    │             │    │             │
│  ┌─────────┐    │    │  ┌───────┐  │    │             │
│  │GPS/Time │    │    │  │RTL-SDR│  │    │             │
│  │ Module  │    │    │  │  RX   │  │    │             │
│  └─────────┘    │    │  └───────┘  │    │             │
└─────────────────┘    └─────────────┘    └─────────────┘
```

---

## Wiring Diagrams

### RTL-SDR Connection

```
RTL-SDR Dongle
┌─────────────────┐
│  [USB-A Male]   │ ──── To Pi USB Port
│                 │
│  [SMA Female]   │ ──── To 2m Antenna
│                 │
│  [LED Status]   │
└─────────────────┘
```

### Audio Interface Wiring

```
Radio Audio Connections:
┌─────────────────┐
│     Radio       │
│  ┌───────────┐  │
│  │ MIC       │──┼──── Audio Out to Pi
│  │ SPK       │◄─┼──── Audio In from Pi
│  │ PTT       │◄─┼──── PTT Control
│  └───────────┘  │
└─────────────────┘

GPIO PTT Circuit:
Pi GPIO ──[1kΩ]──┤ 
                 │ 2N2222
                 ├─────── To Radio PTT
                 │
               [GND]
```

### GPS Module Connection

```
GPS Module (USB):
┌─────────────────┐
│  USB GPS        │
│  ┌───────────┐  │
│  │ USB-A     │──┼──── To Pi USB Port
│  │           │  │
│  │ Status    │  │
│  │ LEDs      │  │
│  └───────────┘  │
└─────────────────┘

GPS Module (GPIO):
┌─────────────────┐
│  GPIO GPS       │
│  ┌───────────┐  │
│  │ VCC   ──  │──┼──── Pi 3.3V
│  │ GND   ──  │──┼──── Pi GND
│  │ TX    ──  │──┼──── Pi GPIO 14 (RX)
│  │ RX    ──  │──┼──── Pi GPIO 15 (TX)
│  └───────────┘  │
└─────────────────┘
```

---

## Hardware Testing

### RTL-SDR Testing

```bash
# Test RTL-SDR functionality
rtl_test -t

# Scan for APRS signals
rtl_fm -f 144.39M -s 22050 -A fast | direwolf -c sdr.conf -r 22050 -D 1 -
```

### Audio Interface Testing

```bash
# List audio devices
aplay -l
arecord -l

# Test audio levels
alsamixer

# Record test
arecord -D plughw:1,0 -f cd test.wav
```

### GPS Testing

```bash
# Test GPS functionality
gpspipe -w -n 10

# Check GPS status
gpsmon
```

---

## Troubleshooting

### Common Issues

#### RTL-SDR Not Detected
- **Check**: `lsusb` output
- **Fix**: Install RTL-SDR drivers
- **Test**: `rtl_test -t`

#### Audio Issues
- **Check**: Audio device permissions
- **Fix**: Add user to audio group
- **Test**: `aplay /usr/share/sounds/alsa/Front_Left.wav`

#### GPS Not Working
- **Check**: Device permissions
- **Fix**: Add user to dialout group
- **Test**: `gpspipe -w -n 5`

#### High CPU Usage
- **Cause**: Multiple decoders running
- **Fix**: Optimize Direwolf configuration
- **Monitor**: `htop` or `top`

### Performance Optimization

#### CPU Optimization
- Use single modem for RTL-SDR
- Reduce audio sample rate
- Disable unnecessary features

#### Memory Optimization
- Limit log file sizes
- Use swap file if needed
- Monitor with `free -h`

#### Network Optimization
- Use wired connection if possible
- Optimize APRS-IS filter
- Monitor bandwidth usage

---

## Maintenance

### Regular Tasks

#### Weekly
- Check log files for errors
- Verify APRS-IS connectivity
- Monitor system temperature

#### Monthly
- Update system packages
- Check disk space usage
- Review configuration

#### Quarterly
- Full system backup
- Hardware inspection
- Performance review

### Hardware Maintenance

#### Cleaning
- Dust removal from Pi case
- Antenna connection inspection
- Cable integrity check

#### Monitoring
- Temperature monitoring
- Voltage stability check
- Performance metrics review

---

## Upgrades and Modifications

### Hardware Upgrades

#### Storage Upgrade
- Replace SD card with SSD
- Improves reliability and performance
- Requires USB-to-SATA adapter

#### Cooling Upgrade
- Add heatsinks or fan
- Reduces thermal throttling
- Improves long-term stability

#### Power Upgrade
- Uninterruptible power supply
- Battery backup for mobile use
- Solar power for remote stations

### Software Enhancements

#### Additional Software
- APRS message handling
- Weather station integration
- Web interface improvements

#### Monitoring Enhancements
- Remote monitoring setup
- Alert system configuration
- Performance dashboards

---

*This guide is maintained by Leeds Space Comms for the amateur radio community.*
