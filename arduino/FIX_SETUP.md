# Fix: BLE Library Errors - ESP32 Setup Required

## Problem
The errors occur because ESP32 board support is not installed in Arduino IDE.
BLEDevice.h, BLEServer.h, etc. are part of the ESP32 board package.

## Solution: Install ESP32 Board Support

### Step 1: Open Arduino IDE

### Step 2: Add ESP32 Board Manager URL
1. Go to **File → Preferences**
2. In "Additional Board Manager URLs" field, add:
   ```
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
3. Click **OK**

### Step 3: Install ESP32 Board Package
1. Go to **Tools → Board → Boards Manager**
2. Search for **"ESP32"**
3. Find **"esp32 by Espressif Systems"**
4. Click **Install** (this will download all ESP32 libraries including BLE)
5. Wait for installation to complete (may take several minutes)

### Step 4: Select ESP32 Board
1. Go to **Tools → Board → ESP32 Arduino**
2. Select **"ESP32 Dev Module"**

### Step 5: Verify Installation
1. Open the .ino file again
2. The red squiggles should disappear
3. You can now compile and upload

## Alternative: VS Code with Arduino Extension

If using VS Code:

1. Install **Arduino extension** by Microsoft
2. Press **Ctrl+Shift+P** → Type "Arduino: Board Manager"
3. Search and install **esp32**
4. Press **Ctrl+Shift+P** → Type "Arduino: Board Config"
5. Select **ESP32 Dev Module**
6. Reload VS Code

## Verify Libraries Are Available

After installation, these libraries should work:
- BLEDevice.h
- BLEServer.h
- BLEUtils.h
- BLE2902.h
- WiFi.h
- Wire.h (I2C)

## Quick Test

Try compiling this simple code:
```cpp
#include <BLEDevice.h>

void setup() {
  Serial.begin(115200);
  BLEDevice::init("Test");
  Serial.println("BLE initialized!");
}

void loop() {}
```

If it compiles without errors, ESP32 board support is correctly installed.
