#include <WiFi.h>
#include <FirebaseESP32.h>
#include "DHT.h"
#include <TinyGPS++.h>
#include <Wire.h>
#include <MPU6050.h>
#include <U8g2lib.h>

// --- Network and Firebase Configuration ---
#define WIFI_SSID "TECH"
#define WIFI_PASSWORD "Jefter1234"
#define DATABASE_URL "https://ceres-tag-8115b-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define API_KEY "AIzaSyBUShhpuHqC1wbkfuggTB2FtmDGuHDUPvc"

// --- GSM Configuration ---
#define GSM_RX 27  
#define GSM_TX 26  
HardwareSerial gsmSerial(1); 
String recipientNumber = "+263776015100"; 
float tempThreshold = 20;              
bool smsSent = false;

// Device Identifier and Firebase Data Object
String deviceId = "ESP32_001";
FirebaseData fbdo;

// --- SENSOR CONFIGURATION ---
#define DHTPIN 4
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

TinyGPSPlus gps;
HardwareSerial gpsSerial(2); 

MPU6050 mpu;
#define MPU_SDA 21 
#define MPU_SCL 22 

U8G2_SSD1306_128X64_NONAME_F_HW_I2C u8g2(U8G2_R0); 

// --- Data Variables ---
float temperature = 0, humidity = 0;
float latitude = 0, longitude = 0;
int satellites = 0;
int16_t ax, ay, az;

// --- Timing Variables ---
const long envInterval = 5000;
const long gpsInterval = 5000;
const long accelInterval = 1000;
unsigned long lastEnvRead = 0, lastGPSRead = 0, lastAccelRead = 0;

// Function prototypes
void sendEnvironmental(float t, float h);
void readGPS();
void sendGPS();
void readAccelerometer();
void sendAccelerometer();
void updateDisplay();
void initGSM();
void sendSMS(String message, String number);

// ====================================================================
// SETUP
// ====================================================================

void setup() {
    Serial.begin(115200); 
    delay(1000);
    Serial.println("--- SYSTEM STARTUP ---");
    
    // 1. WiFi & Firebase
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    Serial.print("Connecting to WiFi");
    while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
    Serial.println("\nWiFi Connected.");

    Firebase.begin(DATABASE_URL, API_KEY);
    Firebase.reconnectWiFi(true);
    
    // 2. Sensor & Display Init
    dht.begin();
    Wire.begin(MPU_SDA, MPU_SCL);
    if (mpu.testConnection()) {
        mpu.initialize();
        Serial.println("MPU6050 Initialized.");
    }
    
    // 3. Serial Interfaces
    gpsSerial.begin(9600, SERIAL_8N1, 16, 17); 
    initGSM(); 
    
    u8g2.begin();
    Serial.println("System Fully Initialized. Waiting for sensor data...");
}

// ====================================================================
// MAIN LOOP
// ====================================================================

void loop() {
    unsigned long now = millis();
    
    while (gpsSerial.available()) {
        gps.encode(gpsSerial.read());
    }

    if (now - lastEnvRead >= envInterval) {
        lastEnvRead = now;
        humidity = dht.readHumidity();
        temperature = dht.readTemperature();

        if (!isnan(humidity) && !isnan(temperature)) {
            Serial.print("Current Temp: "); Serial.print(temperature);
            Serial.print(" | Humidity: "); Serial.println(humidity);
            
            sendEnvironmental(temperature, humidity);
            updateDisplay();

            // SMS Alert Logic
            if (temperature > tempThreshold && !smsSent) {
                Serial.println("!!! THRESHOLD EXCEEDED !!! Preparing SMS...");
                String msg = "ALERT! High Temp: " + String(temperature,1) + "C. ";
                msg += "Loc: https://maps.google.com/?q=" + String(latitude, 6) + "," + String(longitude, 6);
                sendSMS(msg, recipientNumber);
                smsSent = true; 
            } else if (temperature <= (tempThreshold - 2.0)) {
                if(smsSent) Serial.println("Temperature cooled down. SMS Reset.");
                smsSent = false; 
            }
        } else {
            Serial.println("Failed to read from DHT sensor!");
        }
    }
    
    if (now - lastAccelRead >= accelInterval) {
        lastAccelRead = now;
        readAccelerometer();
        sendAccelerometer();
    }
    
    if (now - lastGPSRead >= gpsInterval) {
        lastGPSRead = now;
        readGPS();
        sendGPS();
    }
    
    delay(10); 
}

// ====================================================================
// GSM & SMS FUNCTIONS (DEBUG ENHANCED)
// ====================================================================

void initGSM() {
    Serial.println("Initializing GSM Module...");
    gsmSerial.begin(9600, SERIAL_8N1, GSM_RX, GSM_TX);
    delay(3000); // Wait for module to stabilize

    gsmSerial.println("AT"); 
    delay(1000);
    while(gsmSerial.available()) {
        Serial.print("GSM Response (AT Check): ");
        Serial.println(gsmSerial.readString());
    }

    gsmSerial.println("AT+CMGF=1"); 
    delay(1000);
    while(gsmSerial.available()) {
        Serial.print("GSM Response (Mode Set): ");
        Serial.println(gsmSerial.readString());
    }
    Serial.println("GSM Initialization Routine Complete.");
}

void sendSMS(String message, String number) {
    Serial.println(">>> STARTING SMS SEND PROCESS <<<");
    
    // Step 1: Destination Number
    gsmSerial.print("AT+CMGS=\"");
    gsmSerial.print(number);
    gsmSerial.println("\"");
    delay(2000); // Important: Wait for '>' prompt from module

    // Step 2: Message Content
    Serial.println("Writing Message Content...");
    gsmSerial.print(message);
    delay(500);

    // Step 3: Termination Character (CTRL+Z)
    Serial.println("Sending CTRL+Z Termination...");
    gsmSerial.write(26); 
    
    // Step 4: Wait for Confirmation
    Serial.println("Waiting for GSM Module confirmation (approx 5-10 seconds)...");
    unsigned long startWait = millis();
    while (millis() - startWait < 10000) { // Wait up to 10 seconds for response
        if (gsmSerial.available()) {
            String response = gsmSerial.readString();
            Serial.print("GSM FINAL RESPONSE: ");
            Serial.println(response);
            break;
        }
    }
    Serial.println(">>> SMS PROCESS FINISHED <<<");
}

// ====================================================================
// SENSOR & FIREBASE HELPER FUNCTIONS
// ====================================================================

void readGPS() {
    if (gps.location.isValid()) {
        latitude = gps.location.lat();
        longitude = gps.location.lng();
        satellites = gps.satellites.value();
    }
}

void readAccelerometer() {
    mpu.getAcceleration(&ax, &ay, &az);
}

void sendEnvironmental(float t, float h) {
    FirebaseJson json;
    json.set("temperature", String(t, 1));
    json.set("humidity", String(h, 1));
    Firebase.RTDB.setJSON(&fbdo, ("/devices/" + deviceId + "/environment").c_str(), &json);
}

void sendGPS() {
    FirebaseJson json;
    json.set("latitude", String(latitude, 6));
    json.set("longitude", String(longitude, 6));
    json.set("satellites", satellites);
    Firebase.RTDB.setJSON(&fbdo, ("/devices/" + deviceId + "/gps").c_str(), &json);
}

void sendAccelerometer() {
    FirebaseJson json;
    json.set("x", String(ax / 16384.0, 4));
    json.set("y", String(ay / 16384.0, 4));
    json.set("z", String(az / 16384.0, 4));
    Firebase.RTDB.setJSON(&fbdo, ("/devices/" + deviceId + "/accel").c_str(), &json);
}

void updateDisplay() {
    u8g2.clearBuffer();
    u8g2.setFont(u8g2_font_5x8_tr);
    u8g2.drawStr(12, 10, "SMART TAG");
    u8g2.setFont(u8g2_font_profont10_tr);
    u8g2.setCursor(23, 33);
    u8g2.print("Temp: "); u8g2.print(temperature, 1); u8g2.print(" C");
    u8g2.setCursor(22, 56);
    u8g2.print("Hum:  "); u8g2.print(humidity, 1); u8g2.print(" %");
    u8g2.sendBuffer();
}
*/
