# Arduino ESP32 Wiring Diagram

## Components Required
- ESP32 Dev Module
- RFID-RC522 Module
- Jumper wires
- USB cable for programming

## Pin Connections

### RFID-RC522 to ESP32

| RC522 Pin | ESP32 Pin | Description |
|-----------|-----------|-------------|
| SDA (SS)  | GPIO 5    | Chip Select |
| SCK       | GPIO 18   | SPI Clock   |
| MOSI      | GPIO 23   | SPI MOSI    |
| MISO      | GPIO 19   | SPI MISO    |
| IRQ       | Not connected | (Optional) |
| GND       | GND       | Ground      |
| RST       | GPIO 22   | Reset       |
| 3.3V      | 3.3V      | Power       |

## Wiring Diagram (Text)

```
ESP32                    RC522
-----                    -----
GPIO 5  --------------> SDA
GPIO 18 --------------> SCK
GPIO 23 --------------> MOSI
GPIO 19 --------------> MISO
GPIO 22 --------------> RST
3.3V    --------------> 3.3V
GND     --------------> GND
```

## Important Notes

⚠️ **Power**: RC522 operates at 3.3V. Do NOT connect to 5V or it may damage the module.

⚠️ **SPI Pins**: These are the default SPI pins for ESP32. Do not change unless necessary.

⚠️ **Connections**: Ensure all connections are secure and correct before powering on.

## Testing

After wiring, upload the Arduino sketch and:
1. Open Serial Monitor (115200 baud)
2. Place an RFID tag near the RC522 reader
3. You should see the tag UID displayed
4. The Flutter app should detect the ESP32 via BLE
