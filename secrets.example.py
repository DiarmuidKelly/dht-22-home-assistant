# This file is where you keep secret settings, passwords, and tokens!
# And because I'm lazy - also some config
# Rename it to secrets.py
# If you put this file in git, make sure you add it to your .gitignore file.

WIFI_SSID = "MyWIFI"
WIFI_PASSWORD = "password"

MQTT_BROKER = "homeassistant.local"  # e.g., "192.168.1.100" or FQDN of Home Assistant
MQTT_USER = "mosquitto"  # Optional, leave empty if none
MQTT_PASSWORD = "mqttpassword"  # Optional, leave empty if none

# You can change this to a unique name for your device
DEVICE_ID = "pico_w_dht22_1"
DEVICE_NAME = "Pico DHT22 - 1"

# How often to send updates to MQTT
REFRESH_INTERVAL = 28

# SET GPIO pin for DHT data line
DHT_PIN = 22

# DHT22 Temperature Encoding
# Some DHT22 sensors use 2's complement for negative temperatures (non-standard).
# If you see impossible negative readings like -3262.1°C, set this to True.
# Standard DHT22 sensors should use False (sign-magnitude encoding).
# See: https://github.com/micropython/micropython-lib/issues/611
DHT_USE_2S_COMPLEMENT = True  # Set to False for standard DHT22 sensors
