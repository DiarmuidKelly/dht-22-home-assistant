from machine import Pin, PWM
from time import sleep

# --- Setup ---
# The onboard LED on the Pico W is available as "LED" and is PWM-capable.
# led_pin = Pin("LED")
# pwm = PWM(led_pin)
# For an external LED on GPIO pin 15
led_pin = Pin(15)
pwm = PWM(led_pin)
# ... rest of the code is the same


# Set the PWM frequency. 1000 Hz is a good value for LEDs to avoid visible flicker.
pwm.freq(1000)

print("--- LED PWM Brightness Demo ---")
print("Fading the onboard LED up and down.")
print("Press Ctrl+C to stop.")

try:
    while True:
        # Fade up
        # The duty cycle is set with duty_u16(), which takes a value from 0 (0%) to 65535 (100%).
        for duty in range(0, 65536, 128):  # Step by 128 for a smooth but quick fade
            pwm.duty_u16(duty)
            sleep(0.005)

        # Fade down
        for duty in range(65535, -1, -128):
            pwm.duty_u16(duty)
            sleep(0.005)

except KeyboardInterrupt:
    print("\nStopping demo.")
    # It's good practice to clean up
    pwm.duty_u16(0)  # Turn LED off
    pwm.deinit()  # De-initialize the PWM channel
