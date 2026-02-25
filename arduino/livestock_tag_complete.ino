// --- Modem Configuration ---
#define TINY_GSM_MODEM_SIM800
#define TINY_GSM_RX_BUFFER 1024

#include <TinyGsmClient.h>
#include <Firebase_ESP_Client.h>
#include <ArduinoJson.h>
#include "DHT.h"
#include <TinyGPS++.h>
#include <Wire.h>
#include <MPU6050.h>
#include <U8g2lib.h>

// --- GSM & GPRS Credentials ---
// For Zimbabwe: Econet APN is "internet", NetOne is "internet.netone"
const char apn[] = "internet";
const char gprsUser[] = "";
const char gprsPass[] = "";

// --- Firebase Configuration ---
#define API_KEY "AIzaSyBUShhpuHqC1wbkfuggTB2FtmDGuHDUPvc"
#define DATABASE_URL "https://ceres-tag-8115b-default-rtdb.asia-southeast1.firebasedatabase.app/"

// --- Pin Definitions ---
#define GSM_RX 27
#define GSM_TX 26
#define DHTPIN 4
#define DHTTYPE DHT11
#define MPU_SDA 21
#define MPU_SCL 22

// --- Object Instances ---
HardwareSerial gsmSerial(1);
TinyGsm modem(gsmSerial);
TinyGsmClient client(modem);

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

DHT dht(DHTPIN, DHTTYPE);
TinyGPSPlus gps;
HardwareSerial gpsSerial(2);
MPU6050 mpu;
U8G2_SSD1306_128X64_NONAME_F_HW_I2C u8g2(U8G2_R0);

// --- Global Variables ---
String deviceId = "ESP32_001";
String recipientNumber = "+263776015100";
float temperature = 0, humidity = 0;
float latitude = 0, longitude = 0;
int16_t ax, ay, az;
unsigned long lastUpdate = 0;
const long interval = 10000;

// ====================================================================
// SETUP
// ====================================================================

void setup() {
  Serial.begin(115200);
  gpsSerial.begin(9600, SERIAL_8N1, 16, 17);
  gsmSerial.begin(9600, SERIAL_8N1, GSM_RX, GSM_TX);

  u8g2.begin();
  dht.begin();
  Wire.begin(MPU_SDA, MPU_SCL);
  mpu.initialize();

  Serial.println("Initializing modem...");
  if (!modem.restart()) {
    Serial.println("Failed to restart modem");
    return;
  }

  Serial.print("Connecting to GPRS...");
  if (!modem.gprsConnect(apn, gprsUser, gprsPass)) {
    Serial.println(" GPRS Connection Failed");
    return;
  }
  Serial.println(" Success!");

  // Firebase Setup
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  Firebase.reconnectNetwork(true);
  Firebase.begin(&config, &auth);
}

// ====================================================================
// LOOP
// ====================================================================

void loop() {
  // Process GPS data constantly
  while (gpsSerial.available()) {
    gps.encode(gpsSerial.read());
  }

  if (millis() - lastUpdate >= interval) {
    lastUpdate = millis();

    // Read Sensors
    temperature = dht.readTemperature();
    humidity = dht.readHumidity();
    mpu.getAcceleration(&ax, &ay, &az);

    if (gps.location.isValid()) {
      latitude = gps.location.lat();
      longitude = gps.location.lng();
    }

    // Upload to Firebase via GSM
    sendDataToFirebase();
    updateDisplay();

    // SMS Alert Logic
    if (temperature > 35.0) {
      sendSMS("ALERT: High Temperature detected!", recipientNumber);
    }
  }
}

// ====================================================================
// HELPER FUNCTIONS
// ====================================================================

void sendDataToFirebase() {
  FirebaseJson json;

  // Environment
  json.set("environment/temp", temperature);
  json.set("environment/hum", humidity);

  // GPS
  json.set("gps/lat", latitude);
  json.set("gps/lng", longitude);

  // Accel
  json.set("accel/x", ax / 16384.0);
  json.set("accel/y", ay / 16384.0);

  Serial.print("Pushing data... ");
  if (Firebase.RTDB.updateNode(&fbdo, "/devices/" + deviceId, &json)) {
    Serial.println("OK");
  } else {
    Serial.println(fbdo.errorReason());
  }
}

void sendSMS(String message, String number) {
  modem.sendSMS(number, message);
  Serial.println("SMS Sent.");
}

void updateDisplay() {
  u8g2.clearBuffer();
  u8g2.setFont(u8g2_font_profont10_tr);
  u8g2.setCursor(0, 10);
  u8g2.print("GSM Status: Connected");
  u8g2.setCursor(0, 30);
  u8g2.print("Temp: ");
  u8g2.print(temperature);
  u8g2.setCursor(0, 50);
  u8g2.print("Lat: ");
  u8g2.print(latitude, 4);
  u8g2.sendBuffer();
}
