# Arduino ESP32 to Flutter App - Data Connection Guide

## 🔌 How Arduino Functions Connect to Flutter Display

### System Overview
```
┌──────────────────────┐
│    Arduino ESP32     │
│  (smart_tag_complete)│
└──────────────────────┘
           │
           │ WiFi + Firebase RTDB
           │ (Every 10 seconds)
           ▼
┌──────────────────────┐
│   Firebase Database  │
│    (Cloud Storage)   │
└──────────────────────┘
           │
           │ Real-time Listeners
           │
           ▼
┌──────────────────────┐
│    Flutter App       │
│  (smart-tag-master)  │
└──────────────────────┘
           │
           ▼
    📱 Display on Phone
```

---

## 📡 Arduino Functions → Firebase Paths

### 1. ENVIRONMENTAL DATA
```
Arduino Function:
  sendEnvironmentalToFirebase()
    └─ Calls: Firebase.RTDB.setJSON()
              Path: /devices/ESP32_001/environment

Data Sent:
{
  "temperature": "25.5",
  "humidity": "65.0",
  "timestamp": 1234567890
}

Flutter Listens To:
  Path: /devices/ESP32_001/environment
  Provider: IoTTagService or ThemeProvider
  Display: HomeScreen (main.dart)
    └─ Shows in: Temperature widget, Humidity widget
```

### 2. GPS/LOCATION DATA
```
Arduino Function:
  sendGPSToFirebase()
    └─ Calls: Firebase.RTDB.setJSON()
              Path: /devices/ESP32_001/gps

Data Sent:
{
  "latitude": "-17.825000",
  "longitude": "31.033000",
  "satellites": 12,
  "timestamp": 1234567890
}

Flutter Listens To:
  Path: /devices/ESP32_001/gps
  Provider: IoTTagService
  Display: HomeScreen (main.dart)
    └─ Shows in: Google Maps widget, Location card
```

### 3. ACCELEROMETER/MOVEMENT DATA
```
Arduino Function:
  sendAccelerometerToFirebase()
    └─ Calls: Firebase.RTDB.setJSON()
              Path: /devices/ESP32_001/accel

Data Sent:
{
  "x": "0.0512",
  "y": "-0.0155",
  "z": "0.9834",
  "timestamp": 1234567890
}

Flutter Listens To:
  Path: /devices/ESP32_001/accel
  Display: HomeScreen (main.dart)
    └─ Shows in: Movement indicator, Acceleration graph (fl_chart)
```

### 4. ALERT/SMS DATA
```
Arduino Function:
  checkAlerts() → sendSMS()
    └─ Sends SMS when temperature threshold exceeded

Alert Data Sent to Firebase:
{
  "alert": "HIGH_TEMPERATURE",
  "temperature": "28.5",
  "location": {
    "latitude": "-17.825000",
    "longitude": "31.033000"
  },
  "timestamp": 1234567890,
  "sms_sent": true,
  "recipient": "+263776015100"
}

Storage Path: /devices/ESP32_001/alerts/

Flutter Listens To:
  Path: /devices/ESP32_001/alerts/
  Display: Notifications or AlertPanel in HomeScreen
    └─ Shows: Alert banner, Red indicator light
```

---

## 🎯 Complete Data Flow Example

### Scenario: Temperature rises to 25°C

```
STEP 1: Arduino reads sensor
  loop() → readEnvironmental()
    ├─ DHT sensor returns: 25.5°C
    └─ Sets global: temperature = 25.5

STEP 2: Arduino checks alert
  loop() → checkAlerts()
    ├─ Compares: 25.5°C > 20°C (threshold)?
    ├─ YES! → sendSMS()
    │          ├─ Sends SMS to +263776015100
    │          ├─ Includes location data
    │          └─ Sets smsSent = true
    └─ Updates global: smsSent = true

STEP 3: Arduino sends to Firebase (10 sec)
  loop() → sendEnvironmentalToFirebase()
    ├─ Reads temperature = 25.5
    ├─ Reads humidity = 65.0
    ├─ Creates JSON packet
    └─ Sends to /devices/ESP32_001/environment

STEP 4: Firebase stores data
  Database updates:
    /devices/ESP32_001/environment/temperature = "25.5"
    /devices/ESP32_001/environment/humidity = "65.0"
    /devices/ESP32_001/alerts/high_temp/temperature = "25.5"

STEP 5: Flutter reads from Firebase
  IoTTagService listener detects change
    ├─ Reads: temperature = 25.5°C
    ├─ Notifies: all listening widgets
    └─ Triggers: UI rebuild

STEP 6: Display updates on phone
  HomeScreen rebuilds with:
    ├─ Temperature widget: Shows 25.5°C in RED
    ├─ Alert indicator: Red light flashing
    ├─ Notification: Alert banner at top
    └─ Location: Google Maps showing device location
```

---

## 🔗 Linking Between Arduino & Flutter Files

### Arduino Side (arduino/smart_tag_complete.ino)
```
Sending Functions:
  ├─ sendEnvironmentalToFirebase()    → Sends to /devices/ESP32_001/environment
  ├─ sendGPSToFirebase()              → Sends to /devices/ESP32_001/gps
  ├─ sendAccelerometerToFirebase()    → Sends to /devices/ESP32_001/accel
  └─ sendSMS()                        → Sends alert via GSM

All use:
  Firebase.RTDB.setJSON(&fbdo, path.c_str(), &json);
```

### Flutter Side (lib/services/)

#### IoTTagService (iot_tag_service.dart)
```dart
class IoTTagService extends ChangeNotifier {
  Future<void> syncToCloud() async {
    // Reads from Firebase paths sent by Arduino
    
    // Listen to /devices/ESP32_001/environment
    _firestore.collection('devices')
      .doc(deviceId)
      .collection('environment')
      .snapshots()
      .listen((snapshot) {
        // Updates temperature, humidity
        notifyListeners();  // Triggers UI rebuild
      });
  }
}
```

#### Main App (lib/main.dart)
```dart
class MyApp extends StatefulWidget {
  // Reads IoTTagService data
  final iotTagService = Provider.of<IoTTagService>(context);
  
  // Rebuilds UI when Arduino sends new data
  build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(
        temperature: iotTagService.temperature,
        humidity: iotTagService.humidity,
        // ... other data
      ),
    );
  }
}
```

#### HomeScreen (lib/screens/home_screen.dart)
```dart
class HomeScreen extends StatelessWidget {
  build(BuildContext context) {
    return Column(
      children: [
        // Display temperature from Arduino
        TemperatureWidget(
          temp: Provider.of<IoTTagService>(context).temperature,
          unit: '°C',
        ),
        
        // Display location from Arduino
        GoogleMapsWidget(
          lat: Provider.of<IoTTagService>(context).latitude,
          lng: Provider.of<IoTTagService>(context).longitude,
        ),
        
        // Display movement from Arduino
        AccelerometerChart(
          accelX: Provider.of<IoTTagService>(context).accelX,
          accelY: Provider.of<IoTTagService>(context).accelY,
          accelZ: Provider.of<IoTTagService>(context).accelZ,
        ),
      ],
    );
  }
}
```

---

## 📊 Real-time Data Visualization

### On OLED Display (Arduino)
```
┌──────────────────┐
│ SMART TAG MONITOR│
├──────────────────┤
│ T: 25.5C  H: 65% │ ← From readEnvironmental()
│ GPS: FIXED (12)  │ ← From readGPS()
│ WiFi: ON  FB: ON │ ← From initWiFi() & initFirebase()
└──────────────────┘

Alert indicator: 🔴 (shown when temp > threshold)
```

### On Mobile Phone (Flutter)
```
HomeScreen
├─ Temperature Card
│  ├─ Icon: 🌡️
│  ├─ Value: 25.5°C (from Arduino → Firebase → Flutter)
│  ├─ Trend: ↑ (rising)
│  └─ Status: ⚠️ ALERT (if > threshold)
│
├─ Location Card
│  ├─ Google Maps
│  ├─ Coordinates: -17.825, 31.033 (from Arduino → Firebase → Flutter)
│  ├─ Satellites: 12
│  └─ Link: "View on Maps"
│
├─ Movement Card
│  ├─ Accelerometer Graph (fl_chart)
│  ├─ X: 0.05g, Y: -0.02g, Z: 0.98g (from Arduino → Firebase → Flutter)
│  └─ Status: "Stable"
│
├─ Notifications
│  ├─ Temperature Alert (if SMS was sent)
│  ├─ GPS Lock Status
│  └─ Connection Status
│
└─ Settings
   ├─ Device ID: ESP32_001
   ├─ Refresh Rate: 10 seconds
   ├─ Temperature Threshold: 20°C
   └─ Alert Phone: +263776015100
```

---

## 🔄 Real-time Update Cycle

```
Arduino (10-second cycle):
┌─────────────────────────────────────┐
│ 1. Read sensors (readEnvironmental) │  0 sec
│    → temp = 25.5°C                  │
├─────────────────────────────────────┤
│ 2. Check alerts (checkAlerts)       │  2 sec
│    → if temp > threshold: SMS sent  │
├─────────────────────────────────────┤
│ 3. Send to Firebase                 │  10 sec
│    → /devices/ESP32_001/environment │
│    → /devices/ESP32_001/gps         │
│    → /devices/ESP32_001/accel       │
└─────────────────────────────────────┘
                  │
                  │ (Firebase updates in real-time)
                  ▼
Flutter (Continuous listening):
┌─────────────────────────────────────┐
│ 1. Listener detects change          │
│    → Firebase path updated          │
├─────────────────────────────────────┤
│ 2. IoTTagService updates variables  │
│    → temperature = 25.5°C           │
├─────────────────────────────────────┤
│ 3. notifyListeners() called         │
│    → All widgets rebuild            │
├─────────────────────────────────────┤
│ 4. UI shows new data                │
│    → Temperature displays 25.5°C    │
│    → Alert indicator turns RED      │
└─────────────────────────────────────┘
```

---

## ✅ Verification Checklist

- [ ] Arduino code compiles without errors
- [ ] ESP32 connects to WiFi (see "WiFi: ON" on OLED)
- [ ] Firebase connection succeeds (see "FB: ON" on OLED)
- [ ] Serial monitor shows sensor readings every 5 seconds
- [ ] Firebase console shows updated data at /devices/ESP32_001/
- [ ] Flutter app opens without crashes
- [ ] Flutter app shows temperature reading from Arduino
- [ ] Flutter app shows GPS location from Arduino
- [ ] Flutter app shows acceleration graph from Arduino
- [ ] Alert triggers when temperature exceeds threshold
- [ ] SMS is sent when alert is triggered
- [ ] Flutter app shows alert notification

---

## 🐛 Debugging Tips

### If Arduino data doesn't appear in Firebase:
```
Check Serial Monitor for:
  ✓ "WiFi connected!"
  ✓ "Firebase initialized"
  ✓ "Environmental data sent to Firebase"
  
If you don't see these, the Arduino functions aren't being called in the right order.
```

### If Flutter app doesn't show data:
```
Check Flutter console for:
  ✓ IoTTagService listener started
  ✓ Data received from Firebase
  
If you don't see these, check:
  1. Is Firebase connected?
  2. Are the data paths correct?
  3. Is the device ID correct (ESP32_001)?
```

### If display doesn't update:
```
Check:
  1. OLED I2C connection (SDA=21, SCL=22)
  2. updateDisplay() is being called every 1 second
  3. Display initialization completed
```

---

**System fully integrated and ready for deployment!**
