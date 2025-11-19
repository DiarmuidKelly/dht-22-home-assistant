# This file is where you keep secret settings, passwords, and tokens!
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
