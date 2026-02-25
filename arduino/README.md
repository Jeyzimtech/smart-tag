# Arduino IoT Tag Setup

## Hardware

- ESP32 Dev Module
- DHT11 Temperature/Humidity Sensor
- NEO-6M GPS Module
- SIM800L GSM Module
- MPU6050 Accelerometer

## Wiring

### DHT11
- VCC → 3.3V
- GND → GND
- DATA → GPIO 4

### GPS NEO-6M
- VCC → 5V
- GND → GND
- TX → GPIO 16
- RX → GPIO 17

### GSM SIM800L
- VCC → 5V (use external power supply)
- GND → GND
- TX → GPIO 25
- RX → GPIO 26

### MPU6050
- VCC → 3.3V
- GND → GND
- SDA → GPIO 21
- SCL → GPIO 22

## Arduino IDE Setup

1. Install Arduino IDE from https://www.arduino.cc/en/software

2. Add ESP32 Board Support:
   - File → Preferences
   - Add to "Additional Board Manager URLs":
     ```
     https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
     ```
   - Tools → Board → Boards Manager
   - Search "ESP32" and install

3. Install Required Libraries:
   - Sketch → Include Library → Manage Libraries
   - Install:
     - DHT sensor library by Adafruit
     - TinyGPS++ by Mikal Hart
     - MPU6050 by Electronic Cats

4. Select Board:
   - Tools → Board → ESP32 Arduino → ESP32 Dev Module

5. Upload Code:
   - Connect ESP32 via USB
   - Select correct COM port in Tools → Port
   - Click Upload button

## Testing

1. Upload `livestock_tag_simple.ino` first to test BLE connection
2. Open Serial Monitor (115200 baud) to see debug messages
3. Use Flutter app to scan and connect
4. Once working, upgrade to `livestock_tag_full.ino` with sensors

## BLE Configuration

- Service UUID: `4fafc201-1fb5-459e-8fcc-c5c9c331914b`
- Characteristic UUID: `beb5483e-36e1-4688-b7f5-ea07361b26a8`
- Device Name: `Livestock_Tag`

## Data Format

JSON format sent every 3-5 seconds:
```json
{
  "temp": 25.5,
  "humidity": 60.0,
  "lat": 40.712800,
  "lng": -74.006000,
  "activity": 45,
  "count": 123
}
```

## Troubleshooting

- If upload fails: Hold BOOT button while uploading
- If BLE not visible: Check Serial Monitor for errors
- If sensors not working: Verify wiring and library installation
