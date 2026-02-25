# GSM Tag Server Integration

## Architecture

```
ESP32 + GSM Module → HTTP POST → Server/Firebase → Flutter App
```

## Arduino Code (GSM Module sends data via HTTP)

The Arduino code sends GPS and sensor data to your server via GSM:

```cpp
void sendDataViaGSM() {
  String url = "https://your-server.com/api/livestock-data";
  
  // Prepare JSON data
  String jsonData = "{";
  jsonData += "\"tagId\":\"" + String(TAG_ID) + "\",";
  jsonData += "\"latitude\":" + String(latitude, 6) + ",";
  jsonData += "\"longitude\":" + String(longitude, 6) + ",";
  jsonData += "\"temperature\":" + String(temperature, 1) + ",";
  jsonData += "\"humidity\":" + String(humidity, 1) + ",";
  jsonData += "\"activity\":" + String(activityLevel);
  jsonData += "}";
  
  // Send via GSM
  gsmSerial.println("AT+HTTPINIT");
  delay(1000);
  gsmSerial.println("AT+HTTPPARA=\"URL\",\"" + url + "\"");
  delay(1000);
  gsmSerial.println("AT+HTTPPARA=\"CONTENT\",\"application/json\"");
  delay(1000);
  gsmSerial.println("AT+HTTPDATA=" + String(jsonData.length()) + ",10000");
  delay(1000);
  gsmSerial.print(jsonData);
  delay(1000);
  gsmSerial.println("AT+HTTPACTION=1"); // POST
  delay(5000);
  gsmSerial.println("AT+HTTPTERM");
}
```

## Server Options

### Option 1: Firebase Cloud Functions (Recommended)

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.receiveLivestockData = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).send('Method Not Allowed');
  }

  const { tagId, latitude, longitude, temperature, humidity, activity } = req.body;

  await admin.firestore().collection('livestock_tags').doc(tagId).set({
    latitude,
    longitude,
    temperature,
    humidity,
    activity,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    status: 'active'
  }, { merge: true });

  res.status(200).send('Data received');
});
```

### Option 2: Node.js Express Server

```javascript
const express = require('express');
const admin = require('firebase-admin');
const app = express();

admin.initializeApp({
  credential: admin.credential.cert('./serviceAccountKey.json')
});

app.use(express.json());

app.post('/api/livestock-data', async (req, res) => {
  const { tagId, latitude, longitude, temperature, humidity, activity } = req.body;

  await admin.firestore().collection('livestock_tags').doc(tagId).set({
    latitude,
    longitude,
    temperature,
    humidity,
    activity,
    timestamp: admin.firestore.Timestamp.now(),
    status: 'active'
  }, { merge: true });

  res.json({ success: true });
});

app.listen(3000);
```

## Flutter App Setup

1. Add GsmTagService to providers in main.dart
2. App listens to Firestore real-time updates
3. Map updates automatically when GSM tags send new data

## Data Flow

1. ESP32 reads sensors (GPS, DHT11, MPU6050)
2. GSM module sends HTTP POST to server every 30-60 seconds
3. Server stores data in Firestore
4. Flutter app receives real-time updates via Firestore streams
5. Map markers update automatically

## Benefits of GSM over BLE

- Long-range communication (no proximity needed)
- Works anywhere with cellular coverage
- Real-time tracking from anywhere
- Multiple users can monitor simultaneously
- Data stored in cloud (history/analytics)

## Cost Considerations

- GSM data plan per tag (~$2-5/month)
- Firebase usage (free tier: 50K reads/day)
- Server hosting (if not using Firebase Functions)
