# Leeds APRS Pi 🚀

**Plug & Play APRS Station for Raspberry Pi**

Flash SD card → Insert → Power On → Configure via Web → Done!

## 🎯 Quick Start

### Method 1: Flash & Go (Recommended)
1. **Download**: Get the latest `.img` file from [Releases](https://github.com/space-comms/leeds-aprs-pi/releases)
2. **Flash**: Use [Raspberry Pi Imager](https://rpi.org/imager) or Rufus to flash SD card
3. **Boot**: Insert SD card into Pi and power on
4. **Connect**: Join WiFi network `Leeds-APRS-Setup` (password: `aprssetup`)
5. **Configure**: Open browser to `http://192.168.4.1` and enter your callsign/location
6. **Done**: System connects to your WiFi and starts beaconing

### Method 2: Docker (Advanced Users)git clone https://github.com/space-comms/leeds-aprs-pi.git
cd leeds-aprs-pi
# Edit docker-compose.yml with your callsign/location
docker-compose up -d
## 📡 What You Get

- **APRS Station**: Automatic beaconing to APRS-IS network
- **Web Dashboard**: Monitor and configure via browser
- **Hardware Support**: RTL-SDR, GPS, audio interfaces
- **Educational Features**: Perfect for universities and clubs
- **Auto-Configuration**: Detects and configures hardware automatically

## ⚙️ Configuration

Via web interface at `http://your-pi-ip:8080` or initially at `http://192.168.4.1`:

- **Callsign**: Your amateur radio callsign
- **Location**: Latitude/longitude or address
- **Beacon Message**: Custom message for your station
- **Hardware**: Enable RTL-SDR, GPS, audio interfaces
- **Network**: WiFi settings for your home network

## 🔧 System Requirements

- **Raspberry Pi 3B+** or newer (Pi 4 recommended)
- **8GB+ SD card** (16GB recommended)
- **Internet connection** (WiFi or Ethernet)
- **Amateur radio license** (for transmission)

## 🎓 Educational Use

Perfect for:
- **University courses** (electronics, communications, networking)
- **Amateur radio