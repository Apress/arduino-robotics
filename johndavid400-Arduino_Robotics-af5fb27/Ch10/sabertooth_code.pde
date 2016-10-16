// This is the main code, it should run on the Arduino.
// Read PPM signals from 2 channels of an RC reciever and convert the values to PWM in either direction.
// PWM pins 9 and 10 from Arduino should connect to Sabertooth S1 and S2.
// DP 12 and 13 are neutral indicator lights. 
// DP 2 and 3 are inputs from the R/C receiver
// leave pins 0 and 1 open for serial communication
// JDW 2010

// R/C inputs to Arduino
int ppm1 = 2;   
int ppm2 = 3;

// Arduino outputs to Sabertooth
int motor1 = 9;  // PWM pin
int motor2 = 10;  // PWM pin

// Neutral indicator LED pins (optional)
int ledPin1 = 12;
int ledPin2 = 13;

// variables for PPM signals
unsigned int servo1_val; 
int adj_val1;  
int servo1_Ready;

unsigned int servo2_val; 
int adj_val2;  
int servo2_Ready;

// You can adjust these values to calibrate the code to your specific radio - check the Serial Monitor to see your values.
int low1 = 1100;
int high1 = 1900;
int low2 = 1100;
int high2 = 1900;

void setup() {

  Serial.begin(9600);

  // Sabertooth recommends using a PWM speed that is higher than 1kHz - this raises the speed to 4kHz
  TCCR1B = TCCR1B & 0b11111000 | 0x02;

  //motor pins
  pinMode(motor1, OUTPUT);
  pinMode(motor2, OUTPUT);

  //led's
  pinMode(ledPin1, OUTPUT);
  pinMode(ledPin2, OUTPUT);

  //PPM inputs from RC receiver
  pinMode(ppm1, INPUT);
  pinMode(ppm2, INPUT); 

  analogWrite(motor1, 128);
  analogWrite(motor2, 128);

  delay(2000);

}

void pulse(){

  // read the pulses from the R/C receiver and make sure they are within range

    servo1_val = pulseIn(ppm1, HIGH, 20000);

  if (servo1_val > 800 && servo1_val < 2200){	
    servo1_Ready = true;
  }
  else {
    servo1_Ready = false;
    servo1_val = 1500;
  }

  servo2_val = pulseIn(ppm2, HIGH, 20000);

  if (servo2_val > 800 && servo2_val < 2200){	
    servo2_Ready = true;
  }
  else {
    servo2_Ready = false;
    servo2_val = 1500;
  }

}

void loop() {

  pulse();

  if (servo1_Ready) {  

    // channel 1 
    adj_val1 = map(servo1_val, low1, high1, 0, 255);
    adj_val1 = constrain(adj_val1, 0, 255);

    if (adj_val1 > 255) {
      adj_val1 = 255; 
    }
    if (adj_val1 < 0) {
      adj_val1 = 0; 
    }

    analogWrite(motor1, adj_val1);

    if (adj_val1 > 124 && adj_val1 < 132){
      digitalWrite(ledPin1, HIGH);
    }
    else{
      digitalWrite(ledPin1, LOW);
    }

  }

  if (servo2_Ready) {

    // channel 2 
    adj_val2 = map(servo2_val, low2, high2, 0, 255);
    adj_val2 = constrain(adj_val2, 0, 255);

    if (adj_val2 > 255) {
      adj_val2 = 255; 
    }
    if (adj_val2 < 0) {
      adj_val2 = 0; 
    }

    analogWrite(motor2, adj_val2);      

    if (adj_val2 > 124 && adj_val2 < 132){
      digitalWrite(ledPin2, HIGH);
    }
    else{
      digitalWrite(ledPin2, LOW);
    }

  }

  Serial.print(" Servo1: ");
  Serial.print(servo1_val);
  Serial.print("     ");
  Serial.print(" Servo2: ");
  Serial.println(servo2_val);

}















