# Smart Door Lock System (IoT + Embedded)

## 📌 Description
This project is a multi-factor IoT-based smart door lock system built using ESP32. It integrates RFID authentication, keypad password entry, and remote access via Blynk mobile application.

The system supports parallel input handling and automatic door locking using non-blocking timing (`millis()`), making it suitable for real-time embedded applications.

---

## 🚀 Features
- RFID-based authentication (RC522)
- Keypad PIN access system
- Remote unlocking via Blynk mobile app
- Servo-based locking mechanism
- Buzzer alert for unauthorized access
- Auto-lock after 10 seconds
- Non-blocking firmware design

---

## 🛠️ Components Used
- ESP32  
- RFID RC522 Module  
- 4x4 Keypad  
- Servo Motor  
- Buzzer  
- Wi-Fi Network  

---

## ⚙️ Working
- User can unlock door using:
  - RFID card  
  - Keypad PIN  
  - Mobile app (Blynk)  
- On successful authentication:
  - Servo unlocks door  
  - System auto-locks after 10 seconds  
- Invalid attempts trigger buzzer alert  

---

## 📊 Circuit Connections

| Component | ESP32 Pin |
|----------|----------|
| RFID SDA | 5 |
| RFID RST | 4 |
| Servo    | 15 |
| Buzzer   | 22 |

---

## 💻 Code
Located in `src/main.ino`

---

## 🎥 Demo
youtube
https://youtube.com/shorts/eOjs51uieIM?feature=share
---

## 🔧 Future Improvements
- OTP-based authentication  
- Face recognition integration  
- Mobile notifications  
- Data logging  

---

## 👤 Author
Akash T
