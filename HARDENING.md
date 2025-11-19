# Raspberry Pi Pico Hardening Guide

This guide explains how to "lock down" your Raspberry Pi Pico running the DHT22 sensor code to prevent unauthorized modifications when deployed in production.

## Why Harden?

When giving this device to someone else or deploying it in a shared environment, you may want to:
- Prevent the device from appearing as a USB drive
- Disable the interactive REPL console
- Make the code read-only or hidden
- Present the device as a simple USB sensor rather than a programmable board

## Hardening Options

### Option 1: Disable USB Mass Storage

Create or modify `boot.py` to disable the USB drive functionality:

```python
import storage

# Make filesystem read-only from USB perspective
storage.remount("/", readonly=True)
```

Or completely disable USB drive:
```python
import storage
storage.disable_usb_drive()
```

**Effect:** The Pico won't appear as a USB drive, but serial communication still works for sensor data.

### Option 2: Disable REPL/Serial Console

**For CircuitPython**, add to `boot.py`:
```python
import usb_cdc

# Disable USB serial (REPL)
usb_cdc.disable()
```

**For MicroPython**, add to `boot.py`:
```python
import uos

# Disable REPL on USB
uos.dupterm(None, 1)
```

**Effect:** Prevents interactive console access, but may interfere with debugging.

### Option 3: Combined Protection (Recommended)

Add this to your `boot.py` for basic protection:

```python
import storage
import usb_cdc

# Make filesystem read-only
storage.remount("/", readonly=True)

# Disable USB CDC (serial/REPL)
usb_cdc.disable()

print("Device hardened - USB access restricted")
```

**Effect:** Device appears as a simple USB device, not programmable. Code cannot be easily viewed or modified.

### Option 4: Frozen Bytecode (Advanced)

For maximum security, compile your Python code directly into the firmware:

1. Clone the MicroPython/CircuitPython repository
2. Add your `.py` files to the frozen modules directory
3. Rebuild the firmware with your code baked in
4. Flash the custom firmware to the Pico

**Effect:** Code becomes part of the firmware, cannot be extracted or modified without reflashing. This is the most secure option.

### Option 5: Custom USB Descriptor (Advanced)

Modify the USB descriptor to make the device identify as a generic HID device or custom sensor rather than a Raspberry Pi Pico.

## Re-Enabling Access

**Important:** Once hardened, you'll need to use BOOTSEL mode to regain access:

1. Unplug the Pico
2. Hold the BOOTSEL button
3. Plug in the USB cable while holding BOOTSEL
4. Release the button
5. The Pico appears as a USB drive - drag and drop new firmware to update

## Recommendations

**For casual use (lending to friends):**
- Use Option 3 (Combined Protection)
- Simple, effective, reversible

**For production deployment:**
- Use Option 4 (Frozen Bytecode)
- Maximum security, professional appearance

**For development:**
- Don't harden yet!
- Keep full USB access until code is stable

## Testing Your Hardening

After applying hardening:

1. Unplug and replug the Pico
2. Check if it appears as a USB drive: `ls /dev/` or check File Explorer
3. Try connecting with Thonny or other IDE - should fail
4. Verify sensor data still works with Home Assistant

## Security Note

These hardening techniques provide **convenience security**, not cryptographic security. They prevent casual access and modifications, but a determined person could still:
- Use BOOTSEL mode to reflash
- Read the code if not using frozen bytecode
- Reverse engineer the device

For true security applications, consider additional measures like encrypted communications or hardware security modules.
