#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>

// Pin definitions
const int pH_PIN = 34; // Analog pin connected to the pH sensor
const int TDS_PIN = 35; // Analog pin connected to the TDS meter
const int ONE_WIRE_BUS = 4; // Digital pin connected to the DS18B20 sensor (can be any GPIO pin)

// I2C LCD address and dimensions
LiquidCrystal_I2C lcd(0x27, 16, 2); // I2C address 0x27, 16x2 LCD

OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

// WiFi credentials
#define WIFI_SSID "OPPO A7"
#define WIFI_PASSWORD "12345678"

// Firebase credentials
#define FIREBASE_API_KEY "AIzaSyC_zE2E--Bcm7tKLuXFZE9d7Xd-77vM3BY"
#define FIREBASE_HOST "https://esp32-graph-default-rtdb.firebaseio.com/"

// Define Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

void setup() {
  Serial.begin(115200);
  sensors.begin();
  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("Initializing");
  delay(2000);
  lcd.clear();

  // Connect to WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());

  // Initialize Firebase
  config.api_key = FIREBASE_API_KEY;
  config.database_url = FIREBASE_HOST;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Anonymous authentication
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("Anonymous sign-in successful!");
  } else {
    Serial.println("Failed to sign in. Error: " + fbdo.errorReason());
  }

  // Verify Firebase connection
  if (Firebase.ready()) {
    Serial.println("Connected to Firebase!");
    // Test data write
    if (Firebase.RTDB.setString(&fbdo, "/test", "Hello from ESP32")) {
      Serial.println("Test data sent successfully");
    } else {
      Serial.println("Failed to send test data");
      Serial.println("Reason: " + fbdo.errorReason());
    }
  } else {
    Serial.println("Failed to connect to Firebase. Check your credentials.");
    Serial.println("Firebase Error: " + fbdo.errorReason());
  }
}


void loop() {
  // Reading pH value
  int pHValue = analogRead(pH_PIN);          // Read raw analog value
  float voltage = pHValue * (5.0 / 4095.0);  // ESP32 ADC resolution is 12-bit (4095 max), and it runs at 5V
  float pH = 7 + ((2.5 - voltage) / 0.18);   // Use the same pH calculation formula

  // Reading TDS value
  int TDSValue = analogRead(TDS_PIN);        // Read raw analog value
  float tdsVoltage = TDSValue * (5.0 / 4095.0);  // Convert raw value to voltage
  float tds = (133.42 * tdsVoltage * tdsVoltage * tdsVoltage 
              - 255.86 * tdsVoltage * tdsVoltage 
              + 857.39 * tdsVoltage) * 0.5;  // Use the same TDS calculation formula

  // Reading temperature from DS18B20
  sensors.requestTemperatures();             // Request temperature from DS18B20
  float temperature = sensors.getTempCByIndex(0); // Get temperature in Celsius

  // Printing values to Serial Monitor for debugging
  Serial.print("pH: ");
  Serial.print(pH);
  Serial.print(" | TDS: ");
  Serial.print(tds);
  Serial.print(" ppm | Temperature: ");
  Serial.print(temperature);
  Serial.println(" C");

  // Displaying values on the LCD
  lcd.setCursor(0, 0);  // Set cursor to the first row
  lcd.print("pH: ");
  lcd.print(pH, 2);     // Print pH value with 2 decimal places
  
  lcd.setCursor(9, 0);  // Move to the same row, further right
  lcd.print("TDS: ");
  lcd.print(tds, 1);    // Print TDS value with 1 decimal place
  
  lcd.setCursor(0, 1);  // Move to the second row
  lcd.print("Temp: ");
  lcd.print(temperature, 1);  // Print temperature with 1 decimal place
  lcd.print(" C");

  // Send data to Firebase
  if (Firebase.ready()) {
    String path = "/sensor_data";
    
    if (Firebase.RTDB.setFloat(&fbdo, path + "/pH", pH)) {
      Serial.println("pH sent to Firebase");
    } else {
      Serial.println("Failed to send pH to Firebase");
      Serial.println("Reason: " + fbdo.errorReason());
    }

    if (Firebase.RTDB.setFloat(&fbdo, path + "/TDS", tds)) {
      Serial.println("TDS sent to Firebase");
    } else {
      Serial.println("Failed to send TDS to Firebase");
      Serial.println("Reason: " + fbdo.errorReason());
    }

    if (Firebase.RTDB.setFloat(&fbdo, path + "/Temperature", temperature)) {
      Serial.println("Temperature sent to Firebase");
    } else {
      Serial.println("Failed to send Temperature to Firebase");
      Serial.println("Reason: " + fbdo.errorReason());
    }
  } else {
    Serial.println("Firebase not ready. Check your connection.");
  }

  delay(1000);  // Delay for 1 second before the next reading
}