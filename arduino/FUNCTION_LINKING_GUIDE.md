# Arduino Smart Tag - Complete Function Linking Guide

## 📋 Overview
This guide explains how all functions in the Smart Tag Arduino code are linked together and how data flows through the system.

---

## 🔗 System Architecture & Data Flow

```
SETUP SEQUENCE
│
├─→ initDisplay()          → Display "Starting..."
├─→ initSensors()          → Initialize DHT, MPU6050, GPS
├─→ initWiFi()             → Connect to WiFi
├─→ initFirebase()         → Initialize Firebase connection
└─→ initGSM()              → Initialize SMS module

MAIN LOOP (CONTINUOUS)
│
├─→ GPS Continuous Reading → readGPS() (from serial buffer)
│
├─→ Timer 1 (5 sec):  readEnvironmental()  → checkAlerts() → updateDisplay()
│
├─→ Timer 2 (5 sec):  readGPS()  → updateDisplay()
│
├─→ Timer 3 (1 sec):  readAccelerometer()  → updateDisplay()
│
├─→ Timer 4 (1 sec):  updateDisplay()  → Refresh OLED
│
└─→ Timer 5 (10 sec): Send all data to Firebase
    ├─→ sendEnvironmentalToFirebase()
    ├─→ sendGPSToFirebase()
    └─→ sendAccelerometerToFirebase()
```

---

## 🎯 Key Function Groups & How They Link

### 1️⃣ INITIALIZATION FUNCTIONS (Run Once in setup())
```
setup()
  ├─ initDisplay()      → Sets up OLED display
  ├─ initSensors()      → DHT11, MPU6050, GPS
  ├─ initWiFi()         → WiFi connection
  ├─ initFirebase()     → Firebase authentication
  └─ initGSM()          → GSM/SMS module

These set global variables:
  • wifiConnected = true/false
  • firebaseConnected = true/false
  • sensorErrors = true/false
```

### 2️⃣ DATA READING FUNCTIONS (Called regularly in loop())
```
readEnvironmental()
  ├─ Read temperature from DHT11
  ├─ Read humidity from DHT11
  └─ Check for sensor errors

readGPS()
  ├─ Decode GPS serial data
  ├─ Extract latitude/longitude
  └─ Count satellites

readAccelerometer()
  └─ Read X, Y, Z acceleration from MPU6050
```

### 3️⃣ DATA PROCESSING FUNCTIONS
```
checkAlerts()
  ├─ Compares temperature to tempThreshold
  ├─ Triggers sendSMS() if threshold exceeded
  └─ Resets alert flag when temperature drops
```

### 4️⃣ DATA SENDING FUNCTIONS
```
sendEnvironmentalToFirebase()
  ├─ Packages temperature + humidity
  ├─ Adds timestamp
  └─ Sends to Firebase path: /devices/ESP32_001/environment

sendGPSToFirebase()
  ├─ Packages latitude + longitude + satellites
  ├─ Adds timestamp
  └─ Sends to Firebase path: /devices/ESP32_001/gps

sendAccelerometerToFirebase()
  ├─ Packages X, Y, Z acceleration
  ├─ Adds timestamp
  └─ Sends to Firebase path: /devices/ESP32_001/accel

sendSMS()
  ├─ Sets GSM recipient number
  ├─ Sends temperature alert message
  └─ Includes Google Maps link with coordinates
```

### 5️⃣ DISPLAY FUNCTIONS
```
updateDisplay()
  ├─ Clears OLED buffer
  ├─ Shows temperature, humidity, GPS status
  ├─ Shows WiFi and Firebase connection status
  └─ Sends buffer to display

displaySensorData()
  └─ Prints all sensor readings to Serial Monitor

displayConnectionStatus()
  └─ Prints system connection status to Serial Monitor
```

---

## 📊 Data Flow Example - Temperature Alert

```
loop()  [runs every 10ms]
  │
  └─▶ if (now - lastEnvRead >= 5000ms)
      │
      └─▶ readEnvironmental()
          ├─ Reads DHT sensor
          ├─ Sets: temperature = 25.5°C, humidity = 65%
          │
          └─▶ checkAlerts()
              ├─ Checks: Is 25.5°C > tempThreshold (20°C)?
              │
              └─ YES! ─▶ sendSMS()
                        ├─ Reads current GPS location
                        ├─ Formats message with temp data
                        ├─ Sends to GSM module
                        ├─ Sets smsSent = true
                        │
                        └─▶ updateDisplay()
                            └─ Shows alert indicator on OLED
```

---

## ⏱️ Timing/Schedule

| Function | Interval | Purpose |
|----------|----------|---------|
| readEnvironmental() | 5 sec | Read temperature & humidity |
| readGPS() | 5 sec | Update location data |
| readAccelerometer() | 1 sec | Movement detection |
| updateDisplay() | 1 sec | Refresh OLED screen |
| sendToFirebase() | 10 sec | Upload all data |
| checkAlerts() | 5 sec | Monitor temperature |

---

## 🔍 How to Debug & Verify Functions Work

### 1. Check Serial Monitor Output
```
Open Arduino IDE → Tools → Serial Monitor (115200 baud)

You should see:
╔════════════════════════════════════╗
║   SMART TAG SYSTEM - INITIALIZING  ║
╚════════════════════════════════════╝

→ Initializing Display...
✓ Display initialized

→ Initializing Sensors...
  ✓ DHT11 sensor initialized
  ✓ MPU6050 initialized successfully
  ✓ GPS module initialized

→ Connecting to WiFi...
  SSID: TECH
✓ WiFi connected!
  IP Address: 192.168.x.x

→ Initializing Firebase...
✓ Firebase initialized

✓ System fully initialized. Starting main loop...
```

### 2. Check Data Display on OLED
You should see:
```
┌──────────────────┐
│ SMART TAG MONITOR│
├──────────────────┤
│ T: 25.5C  H: 65% │
│ GPS: FIXED (12)  │
│ WiFi: ON  FB: ON │
└──────────────────┘
```

### 3. Check Serial Monitor During Operation
```
📊 Environmental Data - Temp: 25.5°C | Humidity: 65%
📍 GPS Data - Lat: -17.825000 | Lon: 31.033000 | Satellites: 12
📈 Accelerometer - X: 0.05 | Y: -0.02 | Z: 0.98 g
🔥 Environmental data sent to Firebase
🔥 GPS data sent to Firebase
🔥 Accelerometer data sent to Firebase
```

### 4. Check Firebase (Optional)
Visit Firebase Console:
```
Database Path: /devices/ESP32_001/
├─ environment
│  ├─ temperature: "25.5"
│  ├─ humidity: "65.0"
│  └─ timestamp: 1234567890
├─ gps
│  ├─ latitude: "-17.825000"
│  ├─ longitude: "31.033000"
│  ├─ satellites: 12
│  └─ timestamp: 1234567890
└─ accel
   ├─ x: "0.0512"
   ├─ y: "-0.0155"
   ├─ z: "0.9834"
   └─ timestamp: 1234567890
```

---

## 🐛 Troubleshooting Function Links

### Problem: Display shows "Starting..." but never updates
**Solution**: Check if `updateDisplay()` is being called. Verify:
- OLED I2C pins are correct (SDA=21, SCL=22)
- U8G2 library is installed
- Display has power

### Problem: No serial output
**Solution**: 
- Check USB cable connection
- Verify baud rate is 115200
- Check Tools → Board is "ESP32 Dev Module"

### Problem: Temperature not showing
**Solution**: In `readEnvironmental()`, DHT sensor may need reinitialization:
```cpp
if (isnan(temperature)) {
    dht.begin();  // Reinitialize
    return;
}
```

### Problem: Firebase data not updating
**Solution**: Check in `sendEnvironmentalToFirebase()`:
- Verify WiFi connection (wifiConnected = true)
- Verify Firebase connection (firebaseConnected = true)
- Check API key is correct
- Check database URL is correct

### Problem: SMS not sending
**Solution**: In `sendSMS()`, ensure:
- GSM module is powered
- SIM card has credit/data
- Phone number format is correct (include country code)
- GSM_RX (27) and GSM_TX (26) pins are correct

---

## ✅ Complete Function Call Chain

```
POWER ON
  └─→ setup()
      ├─→ initDisplay()        [Display init]
      ├─→ initSensors()        [Sensor init]
      ├─→ initWiFi()           [Network init]
      ├─→ initFirebase()        [Firebase init]
      ├─→ initGSM()            [SMS init]
      └─→ Ready for loop()

ENTER loop() [INFINITE]
  Every 10ms:
  │
  ├─→ GPS encoding (continuous from serial)
  │
  ├─→ If 5 sec elapsed:
  │   ├─→ readEnvironmental()
  │   └─→ checkAlerts()
  │       └─→ mayCall sendSMS()
  │
  ├─→ If 5 sec elapsed:
  │   └─→ readGPS()
  │
  ├─→ If 1 sec elapsed:
  │   └─→ readAccelerometer()
  │
  ├─→ If 1 sec elapsed:
  │   └─→ updateDisplay()
  │
  └─→ If 10 sec elapsed:
      ├─→ sendEnvironmentalToFirebase()
      ├─→ sendGPSToFirebase()
      └─→ sendAccelerometerToFirebase()
```

---

## 🎓 Best Practices for Function Linking

1. **Always check preconditions**
   ```cpp
   void sendEnvironmentalToFirebase() {
       if (!firebaseConnected) return;  // Don't proceed if not connected
       // ... rest of function
   }
   ```

2. **Use meaningful status flags**
   ```cpp
   wifiConnected = (WiFi.status() == WL_CONNECTED);
   firebaseConnected = Firebase.ready();
   sensorErrors = isnan(temperature);
   ```

3. **Initialize in correct order**
   ```cpp
   // Must initialize in this order:
   // 1. Sensors (they use I2C/Serial ports)
   // 2. WiFi (network connectivity)
   // 3. Firebase (uses WiFi)
   ```

4. **Use global variables for shared data**
   ```cpp
   float temperature = 0.0;  // Set by readEnvironmental()
   // Used by checkAlerts(), updateDisplay(), sendEnvironmentalToFirebase()
   ```

---

## 📱 Arduino to Flutter App Connection

The Flutter app shown in your workspace reads data from Firebase paths:
```
/devices/ESP32_001/environment  → Temperature & Humidity
/devices/ESP32_001/gps          → Location & Satellites
/devices/ESP32_001/accel        → Movement Data
```

This allows your Flutter app to display real-time data from the Arduino device!

---

**End of Linking Guide**
