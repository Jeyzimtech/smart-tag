/*
 * Smart IoT Tag for Livestock Monitoring
 * Board: ESP32 Dev Module
 * Hardware: GPS, GSM (SIM800L), Accelerometer (MPU6050), DHT11
 */

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <TinyGPS++.h>
#include <DHT.h>
#include <Wire.h>
#include <MPU6050.h>

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

#define DHT_PIN 4
#define DHT_TYPE DHT11
#define GPS_RX 16
#define GPS_TX 17
#define GSM_RX 25
#define GSM_TX 26

DHT dht(DHT_PIN, DHT_TYPE);
TinyGPSPlus gps;
MPU6050 mpu;
HardwareSerial gpsSerial(1);
HardwareSerial gsmSerial(2);

// BLE
BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;

// Data variables
float temperature = 0;
float humidity = 0;
double latitude = 0;
double longitude = 0;
int activityLevel = 0;

class ServerCallbacks: public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
    Serial.println("Device connected");
  }
  
  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
    Serial.println("Device disconnected");
    BLEDevice::startAdvertising();
  }
};

class CharacteristicCallbacks: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    String value = pCharacteristic->getValue().c_str();
    Serial.println("Received: " + value);
    
    // Handle commands from app
    if (value == "GET_STATUS") {
      sendData();
    }
  }
};

void setup() {
  Serial.begin(115200);
  Serial.println("Initializing IoT Tag...");
  
  dht.begin();
  gpsSerial.begin(9600, SERIAL_8N1, GPS_RX, GPS_TX);
  gsmSerial.begin(9600, SERIAL_8N1, GSM_RX, GSM_TX);
  Wire.begin();
  mpu.initialize();
  
  if (!mpu.testConnection()) {
    Serial.println("MPU6050 failed");
  }
  
  initGSM();
  
  // Initialize BLE
  BLEDevice::init("Livestock_Tag");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());
  
  BLEService *pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ | 
    BLECharacteristic::PROPERTY_WRITE |
    BLECharacteristic::PROPERTY_NOTIFY
  );
  
  pCharacteristic->addDescriptor(new BLE2902());
  pCharacteristic->setCallbacks(new CharacteristicCallbacks());
  pService->start();
  
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->start();
  
  Serial.println("IoT Tag ready!");
}

void loop() {
  readSensors();
  
  if (deviceConnected) {
    sendData();
  }
  
  delay(5000); // Send data every 5 seconds
}

void readSensors() {
  // Read temperature and humidity
  temperature = dht.readTemperature();
  humidity = dht.readHumidity();
  
  // Read GPS
  while (gpsSerial.available() > 0) {
    if (gps.encode(gpsSerial.read())) {
      if (gps.location.isValid()) {
        latitude = gps.location.lat();
        longitude = gps.location.lng();
      }
    }
  }
  
  // Read accelerometer for activity
  int16_t ax, ay, az;
  mpu.getAcceleration(&ax, &ay, &az);
  activityLevel = (abs(ax) + abs(ay) + abs(az)) / 1000;
}

void sendData() {
  String data = "{";
  data += "\"temp\":" + String(temperature, 1) + ",";
  data += "\"humidity\":" + String(humidity, 1) + ",";
  data += "\"lat\":" + String(latitude, 6) + ",";
  data += "\"lng\":" + String(longitude, 6) + ",";
  data += "\"activity\":" + String(activityLevel);
  data += "}";
  
  pCharacteristic->setValue(data.c_str());
  pCharacteristic->notify();
  
  Serial.println("Sent: " + data);
}

void initGSM() {
  Serial.println("Initializing GSM...");
  gsmSerial.println("AT");
  delay(1000);
  gsmSerial.println("AT+CMGF=1");
  delay(1000);
}

void sendSMS(String phone, String message) {
  gsmSerial.println("AT+CMGS=\"" + phone + "\"");
  delay(1000);
  gsmSerial.print(message);
  delay(100);
  gsmSerial.write(26);
  delay(1000);
}
