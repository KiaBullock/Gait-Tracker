#include <ArduinoBLE.h>
#include <Arduino_LSM9DS1.h>
#include <Arduino_BMI270_BMM150.h>

BLEService gyroService("180A");
BLEIntCharacteristic gyroCharacteristicX("241A", BLENotify);

unsigned long previousMillis = 0;
const long interval = 250; // Send data every second

void setup() {

  if (!BLE.begin()) {
    while (1);
  }

  if (!IMU.begin()) {
    while (1);
  }

  BLE.setLocalName("KneeArduinoNano33BLE");
  BLE.setDeviceName("KneeArduinoNano33BLE");
  BLE.setAdvertisedService(gyroService);

  gyroService.addCharacteristic(gyroCharacteristicX);
  BLE.addService(gyroService);

  BLE.advertise();
}

void loop() {
  BLEDevice central = BLE.central();
  float x, y, z, accelAngleX, accelAngleY;

  if (central) {

    while (central.connect() && central.connected()) {
      unsigned long currentMillis = millis();

      if (currentMillis - previousMillis >= interval) {
        previousMillis = currentMillis;

        IMU.readAcceleration(x, y, z);

        float delta_angle = (atan2(y, x)* 180 / PI); // Calculate angle in degrees
        
        gyroCharacteristicX.writeValue(round(delta_angle));
      }
    }
  }
  BLE.advertise();
}
