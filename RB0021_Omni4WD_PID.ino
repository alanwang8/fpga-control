#include <Wire.h>
#include <MPU6050.h>
#include <PinChangeInt.h>
#include <PinChangeIntConfig.h>
#include <EEPROM.h>
#define _NAMIKI_MOTOR
#include <fuzzy_table.h>
#include <PID_Beta6.h>
#include <MotorWheel.h>
#include <Omni4WD.h>

irqISR(irq1,isr1);
MotorWheel wheel1(3,2,4,5,&irq1);

irqISR(irq2,isr2);
MotorWheel wheel2(11,12,14,15,&irq2);

irqISR(irq3,isr3);
MotorWheel wheel3(9,8,16,17,&irq3);

irqISR(irq4,isr4);
MotorWheel wheel4(10,7,18,19,&irq4);

Omni4WD Omni(&wheel1,&wheel2,&wheel3,&wheel4);

// Constants
#define ROT_SPEED_RAD_S 0.05236*2.0f  // 30 deg/s in radians
#define DEG_PER_SEC 6.0

// State
float currentHeadingDeg = 0.0;

void setup() {
  Serial.begin(9600);

  TCCR1B = TCCR1B & 0xf8 | 0x01;
  TCCR2B = TCCR2B & 0xf8 | 0x01;

  Omni.PIDEnable(0.31, 0.01, 0, 10);

  Serial.println("Ready. Enter target heading in degrees (e.g., 90, -45, 270):");
}

void loop() {
  static String inputString = "";
  static bool gotCommand = false;
  static float targetHeadingDeg = 0;

  while (Serial.available()) {
    char inChar = (char)Serial.read();
    if (inChar == '\n' || inChar == '\r') {
      if (inputString.length() > 0) {
        targetHeadingDeg = normalizeAngle(inputString.toFloat());
        gotCommand = true;
        inputString = "";
      }
    } else {
      inputString += inChar;
    }
  }

  if (gotCommand) {
    rotateToHeading(targetHeadingDeg);
    gotCommand = false;
  }
}

void rotateToHeading(float targetDeg) {
  float delta = targetDeg - currentHeadingDeg;

  // Wrap to [-180, 180]
  if (delta > 180.0) delta -= 360.0;
  if (delta < -180.0) delta += 360.0;

  float direction = (delta >= 0) ? 1.0 : -1.0;
  float durationMs = abs(delta) / DEG_PER_SEC * 1000.0;

  Serial.print("Rotating from ");
  Serial.print(currentHeadingDeg);
  Serial.print("° to ");
  Serial.print(targetDeg);
  Serial.print("° (");
  Serial.print(delta);
  Serial.println("°)");

  Omni.setCarRotate(direction * ROT_SPEED_RAD_S);
  Omni.delayMS(durationMs);  // ← blocking delay
  Omni.setCarStop();            // ← actually stops now
  Omni.delayMS(durationMs);  // ← blocking delay

  currentHeadingDeg = normalizeAngle(targetDeg);

  Serial.print("Done. Current heading = ");
  Serial.print(currentHeadingDeg);
  Serial.println("°");
}

float normalizeAngle(float angle) {
  while (angle >= 360.0) angle -= 360.0;
  while (angle < 0.0) angle += 360.0;
  return angle;
}
