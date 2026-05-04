#define BLYNK_PRINT Serial

#define BLYNK_TEMPLATE_ID "TMPL3ATGvmrTR"
#define BLYNK_TEMPLATE_NAME "smartlock"
#define BLYNK_AUTH_TOKEN "YOUR_BLYNK_TOKEN"

#include <WiFi.h>
#include <BlynkSimpleEsp32.h>
#include <ESP32Servo.h>
#include <SPI.h>
#include <MFRC522.h>
#include <Keypad.h>

char ssid[] = "xxx";
char pass[] = "password";

/******** SERVO ********/
Servo lockServo;
#define SERVO_PIN 15

/******** BUZZER ********/
#define BUZZER_PIN 22

/******** RFID ********/
#define SS_PIN 5
#define RST_PIN 4
MFRC522 rfid(SS_PIN, RST_PIN);

// >>> YOUR TWO CARDS <<<
byte allowedUID1[] = {0x73, 0x38, 0xEE, 0xDA};
byte allowedUID2[] = {0x16, 0x57, 0x8B, 0x3F};

/******** KEYPAD ********/
const byte ROWS = 4;
const byte COLS = 4;

char keys[ROWS][COLS] = {
  {'1','2','3','A'},
  {'4','5','6','B'},
  {'7','8','9','C'},
  {'*','0','#','D'}
};

byte rowPins[ROWS] = {13, 12, 14, 27};
byte colPins[COLS] = {26, 25, 33, 32};

Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);

String enteredPassword = "";
String correctPassword = "1234";   // Change your PIN here

bool doorLocked = true;

/******** AUTO LOCK TIMER ********/
unsigned long unlockTime = 0;
const unsigned long AUTO_LOCK_DELAY = 10000; // 10 seconds

/******** BLYNK BUTTON ********/
BLYNK_WRITE(V0) {
  int btn = param.asInt();
  if (btn == 1) {
    unlockDoor();
  } else {
    lockDoor();
  }
}

/******** FUNCTIONS ********/
void unlockDoor() {
  lockServo.write(90);   // Unlock position
  doorLocked = false;
  unlockTime = millis(); // start 10-sec timer
  Serial.println("Door Unlocked");
}

void lockDoor() {
  lockServo.write(0);   // Lock position
  doorLocked = true;
  Serial.println("Door Locked");
}

/******** BUZZER FUNCTION ********/
void buzzerBeep(int times) {
  for (int i = 0; i < times; i++) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(200);
    digitalWrite(BUZZER_PIN, LOW);
    delay(200);
  }
}

/******** CHECK IF RFID MATCHES ********/
bool checkUID(byte *uid) {
  bool match1 = true;
  bool match2 = true;

  for (byte i = 0; i < 4; i++) {
    if (uid[i] != allowedUID1[i]) match1 = false;
    if (uid[i] != allowedUID2[i]) match2 = false;
  }

  return (match1 || match2);
}

/******** CHECK RFID ********/
void checkRFID() {
  if (!rfid.PICC_IsNewCardPresent() || !rfid.PICC_ReadCardSerial())
    return;

  Serial.print("UID Tag: ");
  for (byte i = 0; i < rfid.uid.size; i++) {
    Serial.print(rfid.uid.uidByte[i], HEX);
    Serial.print(" ");
  }
  Serial.println();

  if (checkUID(rfid.uid.uidByte)) {
    Serial.println("Access Granted by RFID");
    unlockDoor();   // auto close after 10 sec
  } 
  else {
    Serial.println("Access Denied");
    buzzerBeep(3);   // 3 beeps for wrong card
  }

  rfid.PICC_HaltA();
}

/******** CHECK KEYPAD ********/
void checkKeypad() {
  char key = keypad.getKey();

  if (key) {
    Serial.print("Key Pressed: ");
    Serial.println(key);

    if (key == '#') {
      if (enteredPassword == correctPassword) {
        Serial.println("Password Correct");
        unlockDoor();  // auto close after 10 sec
      } 
      else {
        Serial.println("Wrong Password");
        buzzerBeep(2);   // 2 beeps for wrong PIN
      }
      enteredPassword = "";
    } 
    else if (key == '*') {
      enteredPassword = "";
    } 
    else {
      enteredPassword += key;
    }
  }
}

/******** SETUP ********/
void setup() {
  Serial.begin(115200);

  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);

  SPI.begin();
  rfid.PCD_Init();

  lockServo.attach(SERVO_PIN);
  lockDoor();

  Blynk.begin(BLYNK_AUTH_TOKEN, ssid, pass);

  Serial.println("Smart Lock Ready...");
}

/******** LOOP (PARALLEL + AUTO LOCK) ********/
void loop() {
  Blynk.run();
  checkRFID();
  checkKeypad();

  // ⏱️ Auto-lock after 10 seconds
  if (!doorLocked && (millis() - unlockTime >= AUTO_LOCK_DELAY)) {
    lockDoor();
  }
}
