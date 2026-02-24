# IoT Tag Wiring Connection Guide

## Component List
1. ESP32 Dev Module
2. DHT11 Temperature/Humidity Sensor
3. NEO-6M GPS Module
4. SIM800L GSM Module
5. MPU6050 Accelerometer/Gyroscope
6. Breadboard
7. Jumper wires
8. External 5V power supply (for GSM)

## Complete Wiring Diagram

```
ESP32 Pin Layout:
                    ┌─────────────┐
                    │   ESP32     │
                    │             │
         3.3V ──────┤ 3V3     GND ├────── GND (Common Ground)
                    │             │
DHT11 Data ─────────┤ GPIO4       │
                    │             │
GPS TX ─────────────┤ GPIO16  21  ├────── MPU6050 SDA
GPS RX ─────────────┤ GPIO17  22  ├────── MPU6050 SCL
                    │             │
GSM TX ─────────────┤ GPIO25      │
GSM RX ─────────────┤ GPIO26      │
                    │             │
         5V ────────┤ VIN         │
                    └─────────────┘
```

## Detailed Connections

### 1. DHT11 Sensor
```
DHT11          →    ESP32
─────────────────────────
VCC (+)        →    3.3V
GND (-)        →    GND
DATA (OUT)     →    GPIO 4
```

### 2. GPS Module (NEO-6M)
```
GPS NEO-6M     →    ESP32
─────────────────────────
VCC            →    5V (VIN)
GND            →    GND
TX             →    GPIO 16 (RX1)
RX             →    GPIO 17 (TX1)
```

### 3. GSM Module (SIM800L)
```
SIM800L        →    Connection
─────────────────────────────────
VCC            →    External 5V Power Supply (3.7-4.2V, 2A)
GND            →    Common GND (ESP32 + Power Supply)
TX             →    GPIO 25 (RX2)
RX             →    GPIO 26 (TX2)

⚠️ IMPORTANT: SIM800L needs external power supply (2A)
   Do NOT power from ESP32 - it will reset!
```

### 4. Accelerometer (MPU6050)
```
MPU6050        →    ESP32
─────────────────────────
VCC            →    3.3V
GND            →    GND
SDA            →    GPIO 21
SCL            →    GPIO 22
```

## Power Supply Notes

### Option 1: USB Power (Testing Only)
- ESP32 powered via USB
- GPS powered from ESP32 5V pin
- GSM requires separate 5V/2A adapter
- MPU6050 and DHT11 from ESP32 3.3V

### Option 2: Battery Power (Deployment)
- 3.7V LiPo battery (2000mAh+) for ESP32
- Separate battery/power for GSM module
- Use voltage regulator if needed

## Common Ground Connection
```
All GND pins must be connected together:

ESP32 GND ──┬── DHT11 GND
            ├── GPS GND
            ├── GSM GND (+ External Power GND)
            └── MPU6050 GND
```

## Step-by-Step Assembly

1. **Place ESP32 on breadboard**
2. **Connect Power Rails**
   - 3.3V rail from ESP32
   - 5V rail from ESP32 VIN
   - Common GND rail

3. **Connect DHT11**
   - Pin 1 (VCC) → 3.3V
   - Pin 2 (DATA) → GPIO 4
   - Pin 4 (GND) → GND

4. **Connect MPU6050**
   - VCC → 3.3V
   - GND → GND
   - SDA → GPIO 21
   - SCL → GPIO 22

5. **Connect GPS**
   - VCC → 5V
   - GND → GND
   - TX → GPIO 16
   - RX → GPIO 17

6. **Connect GSM (with external power)**
   - VCC → External 5V/2A supply
   - GND → Common GND
   - TX → GPIO 25
   - RX → GPIO 26
   - Insert SIM card

7. **Double-check all connections**
8. **Upload Arduino code**
9. **Test with Flutter app**

## Testing Checklist

- [ ] All GND connected together
- [ ] DHT11 reads temperature
- [ ] GPS gets satellite fix (outdoor)
- [ ] GSM module powers on (LED blinks)
- [ ] MPU6050 detects movement
- [ ] BLE advertises "Livestock_Tag"
- [ ] Flutter app can scan and connect
- [ ] Data appears in app

## Troubleshooting

**ESP32 keeps resetting:**
- GSM drawing too much power - use external supply

**GPS no data:**
- Must be outdoors with clear sky view
- Wait 2-5 minutes for satellite lock

**GSM not working:**
- Check SIM card inserted correctly
- Verify external power supply (2A minimum)
- Check antenna connected

**BLE not visible:**
- Check Serial Monitor for errors
- Restart ESP32
- Ensure code uploaded successfully

**Sensors reading NaN:**
- Check wiring connections
- Verify correct voltage (3.3V vs 5V)
- Test sensors individually
