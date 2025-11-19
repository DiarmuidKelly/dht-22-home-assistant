# DHT22 Home Assistant Sensor

![Version](https://img.shields.io/github/v/release/DiarmuidKelly/dht-22-ha?label=version)
![License](https://img.shields.io/badge/license-MIT-green.svg)

MicroPython application for Raspberry Pi Pico (2) W that reads temperature and humidity from a DHT22 sensor and publishes to Home Assistant via MQTT with automatic discovery.

## Features

- Auto-discovery in Home Assistant via MQTT
- WiFi and MQTT auto-reconnection with recovery
- LED status indicators and rotating logs
- Handles negative temperatures correctly
- Semantic versioning in device info

## Requirements

**Hardware:**
- Raspberry Pi Pico W or Pico 2 W
- DHT22 (AM2302) sensor - Aliexpress version
- Jumper wires

**Software:**
- MicroPython on Pico (2) W (tested on Pico W v1.25.0 and Pico 2 W 3.4.0; MicroPython v1.26.1 on 2025-09-11)
- MicroPython remote control (v1.26.1)
- Home Assistant (CORE: v2025.7.3, OS: v15.2) with Mosquitto MQTT broker (v6.5.1)
- `umqtt.simple` library (tested 1.3.4)

**Wiring:**
```
DHT22          Pico 2 W
-----          ------
VCC     --->   3.3V or VBUS
DATA    --->   GPIO 22
GND     --->   GND
```

## Quick Start

```bash
# 1. Install MicroPython on your Pico 2 W
# Download from: https://micropython.org/download/RPI_PICO2_W/

# 2. Install mpremote from: https://docs.micropython.org/en/latest/reference/mpremote.html
pipx install mpremote

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
mpremote cp VERSION :

# Run
mpremote run main.py
```

## Configuration

### secrets.py

Edit `secrets.py` to configure your credentials and device settings:

```python
# WiFi credentials
WIFI_SSID = "YourWiFiSSID"
WIFI_PASSWORD = "YourWiFiPassword"

# MQTT broker settings
MQTT_BROKER = "192.168.1.100"  # IP address or hostname of your MQTT broker
MQTT_USER = "your_mqtt_user"   # MQTT username (leave empty if not required)
MQTT_PASSWORD = "your_mqtt_pw"  # MQTT password (leave empty if not required)

# Device identification (customize for each sensor)
DEVICE_ID = "pico_w_dht22_1"        # Unique ID for this device
DEVICE_NAME = "Pico DHT22 - 1"      # Friendly name in Home Assistant
```

### Hardware Configuration

Edit `secrets.py` to customize hardware settings:
- **Sensor pin**: `DHT_PIN = 22` (default GPIO 22)
- **Refresh interval**: `REFRESH_INTERVAL = 28` (seconds between readings)
- **DHT22 encoding**: `DHT_USE_2S_COMPLEMENT = True/False` (see below)

#### DHT22 Temperature Encoding

Different DHT22 manufacturers use different temperature encodings:

- **Standard (sign-magnitude)**: Most common, supported natively by MicroPython
- **Non-standard (2's complement)**: Some manufacturers use this variant

**How to identify your sensor type:**

If you see impossible negative temperatures like `-3262.1°C` instead of reasonable values (e.g., `-14.7°C`), your sensor uses 2's complement encoding.

**Configuration:**
```python
# In secrets.py:
DHT_USE_2S_COMPLEMENT = True   # For non-standard sensors showing -3262°C readings
DHT_USE_2S_COMPLEMENT = False  # For standard DHT22 sensors
```

See [GitHub issue #611](https://github.com/micropython/micropython-lib/issues/611) for technical details.

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
- Check GPIO pin in `secrets.py` (`DHT_PIN`)
- DHT22 needs 2-second minimum between reads
- **Impossible negative temperature readings** (e.g., -3262°C): Your DHT22 sensor uses 2's complement encoding. Set `DHT_USE_2S_COMPLEMENT = True` in `secrets.py`. See "DHT22 Temperature Encoding" section above for details.

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

**Note:** Version numbers are automatically updated by CI/CD when PRs merge - no manual version changes needed.

## License

MIT License - See [LICENSE](LICENSE) file.

**Note:** 3D enclosure has separate license (CC BY-NC-SA 4.0).

## Links

- [Changelog](CHANGELOG.md)
- [Branch Protection](.github/BRANCH_PROTECTION.md)
- [Issues](https://github.com/DiarmuidKelly/dht-22-ha/issues)
