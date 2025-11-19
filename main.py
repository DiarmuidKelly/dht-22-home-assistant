# This script reads temperature and humidity from a DHT22 sensor
# and publishes the data to Home Assistant via MQTT.
# It also uses MQTT Discovery to automatically configure the sensors in Home Assistant.
#
# Prerequisites:
# - A secrets.py file with your WiFi and MQTT credentials.
# - The umqtt.simple library installed on your device.
#   Install using mpremote: mpremote mip install umqtt.simple

__version__ = "1.0.0"

from machine import Pin, unique_id
from time import sleep
import dht
import network
from umqtt.simple import MQTTClient
import ujson
import secrets
from logging import init_logger, logger

# --- Global MQTT Client ---
# This is needed so the interrupt handler can access the client.
mqtt_client = None

# --- Constants ---
# You can change this to a unique name for your device
DEVICE_ID = "pico_w_dht22_1"
DEVICE_NAME = "Pico DHT22 - 1"
STATE_TOPIC = f"homeassistant/sensor/{DEVICE_ID}/state"
AVAILABILITY_TOPIC = f"homeassistant/sensor/{DEVICE_ID}/status"

# Onboard LED for status indication
led = Pin("LED", Pin.OUT)

# --- Helper Functions ---
def get_temperature(dht_sensor):
    """
    Gets temperature from DHT22 sensor and properly handles negative values.
    The DHT22 sensor returns temperature as an integer representing tenths of degrees.
    For negative temperatures, bit 15 is set as a sign flag (0x8000).
    """
    temp = dht_sensor.temperature()
    # Check if the sign bit (bit 15) is set for negative temperature
    if temp & 0x8000:
        # Remove the sign bit and make it negative
        temp = -(temp & 0x7FFF) / 10.0
    else:
        temp = temp / 10.0
    return temp

# --- WiFi Connection ---
def connect_wifi(wlan):
    """Connects to the WiFi network specified in secrets.py with detailed debug status."""
    # Status dictionary for Pico W WiFi connection.
    # Provides human-readable status for debugging.
    # See: https://docs.micropython.org/en/latest/library/network.WLAN.html
    status_map = {
         0: "LINK_DOWN",
         1: "LINK_JOIN",      # Connecting to an AP
         2: "LINK_NOIP",      # Connected, but no IP address
         3: "LINK_UP",        # Connection successful, IP address obtained
        -1: "LINK_FAIL",      # Connection failed for other reason
        -2: "LINK_NONET",     # No AP available with the specified SSID
        -3: "LINK_BADAUTH",   # Incorrect password
    }

    wlan.connect(secrets.WIFI_SSID, secrets.WIFI_PASSWORD)
    logger.log(f"Connecting to WiFi '{secrets.WIFI_SSID}'...")

    max_wait = 15
    while max_wait > 0:
        status = wlan.status()
        if status < 0 or status >= 3:
            break
        max_wait -= 1
        led.toggle()
        status_string = status_map.get(status, f"Unknown status ({status})")
        logger.log(f"Awaiting connection... status: {status_string}")
        sleep(1)

    led.off()
    status = wlan.status()
    status_string = status_map.get(status, "Unknown Status")
    logger.log(f"WiFi connection status: {status_string} ({status})")

    if status != 3: # 3 is LINK_UP, the success state
        raise RuntimeError(f'WiFi connection failed: {status_string}')
    else:
        led.on() # Solid LED indicates successful connection
        logger.log(f"Connected to WiFi. IP address: {wlan.ifconfig()[0]}")
    return wlan

# --- MQTT Setup ---
def setup_mqtt_client():
    """Sets up and returns an MQTT client."""
    # Use the unique ID of the chip for the MQTT client ID
    logger.log("Attempting set up of MQTT client...")
    try:
      client_id_hex = ''.join(['%02x' % b for b in unique_id()])
      client = MQTTClient(
          client_id=client_id_hex,
          server=secrets.MQTT_BROKER,
          user=secrets.MQTT_USER,
          password=secrets.MQTT_PASSWORD,
          keepalive=60
      )
      # Set last will and testament to mark the device as offline if it disconnects
      client.set_last_will(AVAILABILITY_TOPIC, "offline", retain=True)
      logger.log("MQTT client configured successfully.")
      return client
    except Exception as e:
        logger.log(f"Error setting up MQTT client: {e}")
        # Re-raise the exception to be caught by the main loop's fatal error handler.
        raise

def publish_ha_discovery(client):
    """
    Publishes Home Assistant MQTT discovery messages for temperature and humidity sensors.
    This allows Home Assistant to automatically add the sensors.
    """
    device_info = {
          "identifiers": [DEVICE_ID],
          "name": DEVICE_NAME,
          "manufacturer": "Raspberry Pi",
          "model": "Pico W with DHT22",
          "sw_version": __version__
      }

    # Temperature Sensor Discovery Configuration
    temp_config_topic = f"homeassistant/sensor/{DEVICE_ID}_temp/config"
    temp_payload = {
        "name": "Pico DHT22 Temperature",
        "unique_id": f"{DEVICE_ID}_temperature",
        "device_class": "temperature",
        "state_topic": STATE_TOPIC,
        # "unit_of_measurement": "°C",
        "value_template": "{{ value_json.temperature | round(1) }}",
        "availability_topic": AVAILABILITY_TOPIC,
        "payload_available": "online",
        "payload_not_available": "offline",
        "device": device_info
    }
    client.publish(temp_config_topic, ujson.dumps(temp_payload), retain=True)
    logger.log(f"Published discovery for Temperature to {temp_config_topic}")

    # Humidity Sensor Discovery Configuration
    hum_config_topic = f"homeassistant/sensor/{DEVICE_ID}_hum/config"
    hum_payload = {
        "name": "Pico DHT22 Humidity",
        "unique_id": f"{DEVICE_ID}_humidity",
        "device_class": "humidity",
        "state_topic": STATE_TOPIC,
        "unit_of_measurement": "%",
        "value_template": "{{ value_json.humidity | round(1) }}",
        "availability_topic": AVAILABILITY_TOPIC,
        "payload_available": "online",
        "payload_not_available": "offline",
        "device": device_info
    }
    client.publish(hum_config_topic, ujson.dumps(hum_payload), retain=True)
    logger.log(f"Published discovery for Humidity to {hum_config_topic}")

# --- Main Execution ---
def main():
    """Main function to manage connections and run the sensor loop with auto-reconnection."""
    global mqtt_client, logger

    # --- Logger Configuration ---
    # Initialize the logger. This should be the first thing to run.
    # All subsequent logger.log() calls will use this configuration.
    logger = init_logger(filename='app.log', max_lines=500)
    logger.log(f"DHT22 Home Assistant Sensor - Version {__version__}")

    # --- Initial Hardware Setup (runs once on boot) ---
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)

    dht_sensor = dht.DHT22(Pin(22))

    # --- Main Reconnection Loop ---
    while True:
        try:
            # 1. Connect to WiFi (or reconnect if connection was lost)
            if not wlan.isconnected():
                connect_wifi(wlan)

            # 2. Connect to MQTT Broker
            mqtt_client = setup_mqtt_client()
            mqtt_client.connect()
            logger.log(f"Connected to MQTT Broker at {secrets.MQTT_BROKER}")

            # 3. Setup MQTT-dependent features
            publish_ha_discovery(mqtt_client)
            mqtt_client.publish(AVAILABILITY_TOPIC, "online", retain=True)

            # 4. Start the main operational loop
            logger.log("Starting sensor readings and publishing...")
            while True:
                led.toggle() # Heartbeat blink

                # A. Read the DHT22 sensor
                try:
                    led.toggle()
                    dht_sensor.measure()
                    temperature = get_temperature(dht_sensor)
                    humidity = dht_sensor.humidity()
                    payload = {"temperature": temperature, "humidity": humidity}
                    # B. Publish the data via MQTT
                    mqtt_client.publish(STATE_TOPIC, ujson.dumps(payload))
                    logger.log(f"Published: Temp={payload['temperature']:.1f}°C, Hum={payload['humidity']:.1f}%")
                    led.toggle()
                except (OSError, TypeError) as e:
                    # This specifically catches errors from dht_sensor.measure()
                    logger.log(f'Failed to read sensor: {e}')

                led.toggle()
                # C. Check for any incoming MQTT messages (and keep-alive)
                mqtt_client.check_msg()
                sleep(28) # Wait for the next cycle (total loop time ~30s)

        except Exception as e:
            # This block catches all other errors, primarily network/MQTT connection issues.
            logger.log(f"A connection error occurred: {e}. Resetting connections...")
            led.off() # Turn off status LED
            try:
                if mqtt_client: mqtt_client.disconnect()
            except Exception: pass
            mqtt_client = None
            logger.log("Retrying in 15 seconds...")
            sleep(15)

if __name__ == "__main__":
    main()