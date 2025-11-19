# DHT22 Home Assistant Sensor

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

A production-ready MicroPython application for Raspberry Pi Pico W that reads temperature and humidity from a DHT22 sensor and publishes the data to Home Assistant via MQTT with automatic discovery.

## Features

- **Automatic Home Assistant Discovery**: Sensors automatically appear in Home Assistant via MQTT Discovery
- **WiFi Auto-Reconnection**: Automatically reconnects to WiFi if connection is lost
- **MQTT Keep-Alive**: Maintains persistent MQTT connection with automatic recovery
- **Status Indicators**: Onboard LED provides visual feedback on connection status
- **Rotating Logs**: Built-in logging system with automatic log rotation
- **Negative Temperature Support**: Correctly handles temperatures below 0°C (fixed DHT22 sign bit handling)
- **Version Tracking**: Semantic versioning visible in logs and Home Assistant device info

## Hardware Requirements

- Raspberry Pi Pico W
- DHT22 (AM2302) Temperature and Humidity Sensor
- Jumper wires
- (Optional) Breadboard

## Wiring Diagram

```
DHT22 Sensor          Pico W
------------          ------
VCC (Pin 1)    --->   3.3V or VBUS
DATA (Pin 2)   --->   GPIO 22
NC (Pin 3)     --->   Not Connected
GND (Pin 4)    --->   GND
```

**Note**: A 10kΩ pull-up resistor between DATA and VCC is recommended but often not required.

## Software Requirements

- MicroPython installed on Raspberry Pi Pico W
- Home Assistant with MQTT broker (Mosquitto recommended)
- `umqtt.simple` library

## Installation

### 1. Install MicroPython on Pico W

Download and install MicroPython firmware from [micropython.org](https://micropython.org/download/rp2-pico-w/).

### 2. Install Required Libraries

Connect to your Pico W and install the MQTT library:

```bash
mpremote mip install umqtt.simple
```

### 3. Configure Credentials

Copy `secrets.example.py` to `secrets.py` and update with your credentials:

```bash
cp secrets.example.py secrets.py
```

Edit `secrets.py`:

```python
WIFI_SSID = "YourWiFiSSID"
WIFI_PASSWORD = "YourWiFiPassword"

MQTT_BROKER = "homeassistant.local"  # or IP address
MQTT_USER = "your_mqtt_username"
MQTT_PASSWORD = "your_mqtt_password"
```

### 4. Upload Code to Pico W

Upload all files to your Pico W:

```bash
mpremote cp main.py :
mpremote cp logging.py :
mpremote cp secrets.py :
```

### 5. Run the Application

The application will start automatically on boot. To run manually:

```bash
mpremote run main.py
```

Or reset the Pico W to start the application.

## Configuration

### Device Settings

Edit `main.py` to customize your device:

```python
DEVICE_ID = "pico_w_dht22_1"        # Unique device identifier
DEVICE_NAME = "Pico DHT22 - 1"      # Human-readable name
```

### Sensor Pin

The DHT22 sensor is configured on GPIO 22 by default. To change:

```python
dht_sensor = dht.DHT22(Pin(22))  # Change pin number here
```

### Reading Interval

Default interval is ~30 seconds. Adjust in the main loop:

```python
sleep(28)  # Total loop time ~30s
```

## Home Assistant Integration

Once running, sensors will automatically appear in Home Assistant:

1. **Temperature Sensor**: `sensor.pico_dht22_temperature`
2. **Humidity Sensor**: `sensor.pico_dht22_humidity`

### Device Information

The device will appear in Home Assistant with:
- Manufacturer: Raspberry Pi
- Model: Pico W with DHT22
- Software Version: Current application version
- Online/Offline status

## LED Status Indicators

- **Blinking during WiFi connection**: Attempting to connect
- **Solid ON**: WiFi connected successfully
- **Heartbeat blink**: Normal operation, publishing sensor data
- **OFF**: Connection lost or error occurred

## Logging

Logs are stored in `app.log` on the Pico W with automatic rotation (max 500 lines).

To view logs:

```bash
mpremote fs cat app.log
```

Or use the included log reader utility:

```bash
mpremote run utils/read_logs.py
```

## Troubleshooting

### WiFi Connection Issues

- Check SSID and password in `secrets.py`
- Ensure 2.4GHz WiFi (Pico W doesn't support 5GHz)
- Check WiFi signal strength

### MQTT Connection Issues

- Verify MQTT broker is running
- Check MQTT credentials
- Test broker connection: `mosquitto_sub -h <broker> -t '#' -u <user> -P <password>`

### Sensor Reading Errors

- Check DHT22 wiring
- Verify GPIO pin number in code
- DHT22 requires 2-second minimum interval between reads

### Negative Temperature Issues

Version 1.0.0+ includes fixes for negative temperature handling. Update to the latest version if seeing incorrect readings below 0°C.

## Development

### Version Bumping

Use the release script to bump versions:

```bash
./scripts/release.sh patch  # 1.0.0 -> 1.0.1
./scripts/release.sh minor  # 1.0.0 -> 1.1.0
./scripts/release.sh major  # 1.0.0 -> 2.0.0
```

### Release Process

1. Make changes and test
2. Update `CHANGELOG.md`
3. Run release script
4. Commit and push
5. Create GitHub release with tag

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.

## Acknowledgments

- MicroPython project
- Home Assistant community
- DHT sensor library contributors

## Support

For issues and questions:
- Open an issue on GitHub
- Check existing issues for solutions
- Review logs for error messages

---

**Version**: 1.0.0
**Last Updated**: 2025-11-19
