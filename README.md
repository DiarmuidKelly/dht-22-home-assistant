# DHT22 Home Assistant Sensor

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

MicroPython application for Raspberry Pi Pico W that reads temperature and humidity from a DHT22 sensor and publishes to Home Assistant via MQTT with automatic discovery.

## Features

- Auto-discovery in Home Assistant via MQTT
- WiFi and MQTT auto-reconnection with recovery
- LED status indicators and rotating logs
- Handles negative temperatures correctly
- Semantic versioning in device info

## Requirements

**Hardware:**
- Raspberry Pi Pico W
- DHT22 (AM2302) sensor
- Jumper wires

**Software:**
- MicroPython on Pico W
- Home Assistant with MQTT broker
- `umqtt.simple` library (auto-installed)

**Wiring:**
```
DHT22          Pico W
-----          ------
VCC     --->   3.3V or VBUS
DATA    --->   GPIO 22
GND     --->   GND
```

## Quick Start

```bash
# 1. Install MicroPython on your Pico W
# Download from: https://micropython.org/download/rp2-pico-w/

# 2. Install mpremote
pip install mpremote

# 3. Configure credentials
cp secrets.example.py secrets.py
# Edit secrets.py with your WiFi and MQTT details

# 4. Deploy
./scripts/deploy.sh
```

The deploy script automatically installs dependencies and uploads files to your Pico W.

### Manual Installation

```bash
# Install dependencies
mpremote mip install umqtt.simple

# Upload files
mpremote cp main.py :
mpremote cp logging.py :
mpremote cp secrets.py :

# Run
mpremote run main.py
```

## Configuration

Edit `main.py` to customize:
- Device ID/Name: `DEVICE_ID`, `DEVICE_NAME`
- Sensor pin: `dht.DHT22(Pin(22))` (default GPIO 22)
- Reading interval: `sleep(28)` (default ~30s)

## Home Assistant

Sensors auto-appear as:
- `sensor.pico_dht22_temperature`
- `sensor.pico_dht22_humidity`

Device info includes manufacturer, model, software version, and online/offline status.

## Troubleshooting

**WiFi Issues:**
- Check SSID/password in `secrets.py`
- Ensure 2.4GHz WiFi (5GHz not supported)
- Check signal strength

**MQTT Issues:**
- Verify MQTT broker is running
- Check credentials in `secrets.py`
- Test: `mosquitto_sub -h <broker> -t '#' -u <user> -P <password>`

**Sensor Issues:**
- Verify wiring (see diagram above)
- Check GPIO pin in code
- DHT22 needs 2-second minimum between reads
- Negative temps: Update to v1.0.0+

**View Logs:**
```bash
mpremote fs cat app.log
# or
mpremote run utils/read_logs.py
```

## 3D Printed Enclosure

STL files for a 3D printed case are available in `3D-print/`. See [3D-print/README.md](3D-print/README.md) for details and attribution.

## Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for workflow details.

Fork → Branch → Commits → PR with `[MAJOR]`/`[MINOR]`/`[PATCH]` title → Auto-release on merge!

## License

MIT License - See [LICENSE](LICENSE) file.

**Note:** 3D enclosure has separate license (CC BY-NC-SA 4.0).

## Links

- [Changelog](CHANGELOG.md)
- [Branch Protection](.github/BRANCH_PROTECTION.md)
- [Issues](https://github.com/DiarmuidKelly/dht-22-ha/issues)

---

**Version**: 1.0.0 | **Last Updated**: 2025-11-19
