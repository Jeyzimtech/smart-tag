/*
 * Simple IoT Tag - BLE Only (No External Sensors)
 * Board: ESP32 Dev Module
 * 
 * Use this for testing BLE connection with Flutter app
 */

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
int counter = 0;

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
  }
};

void setup() {
  Serial.begin(115200);
  Serial.println("Starting BLE IoT Tag...");
  
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
  
  Serial.println("BLE Tag ready!");
}

void loop() {
  if (deviceConnected) {
    String data = "{";
    data += "\"temp\":" + String(25.0 + random(-5, 5)) + ",";
    data += "\"humidity\":" + String(60.0 + random(-10, 10)) + ",";
    data += "\"lat\":" + String(40.7128, 6) + ",";
    data += "\"lng\":" + String(-74.0060, 6) + ",";
    data += "\"activity\":" + String(random(0, 100)) + ",";
    data += "\"count\":" + String(counter++);
    data += "}";
    
    pCharacteristic->setValue(data.c_str());
    pCharacteristic->notify();
    
    Serial.println("Sent: " + data);
  }
  
  delay(3000);
}
