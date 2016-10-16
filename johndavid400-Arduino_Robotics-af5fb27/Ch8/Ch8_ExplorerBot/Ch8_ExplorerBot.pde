// This is the main code, it should run on the Arduino. 
// Read PPM signals from 2 channels of an RC reciever and convert the values to PWM in either direction. 
// digital pins 3 & 11 provide PWM control motor1, digital pins 9 & 10 provide PWM control motor2. 
// DP 12 and 13 are neutral indicator lights. 
// DP 2 and 6 are inputs from the R/C receiver. 
// JDW 2010

// leave pins 0 and 1 open for serial communication 

int ppm1 = 2; 
int ppm2 = 6; 

int motor1_BHI = 7; 
int motor1_BLI = 3;  // PWM pin 
int motor1_ALI = 11;  // PWM pin 
int motor1_AHI = 8; 

int motor2_BHI = 5; 
int motor2_BLI = 10;   //PWM pin 
int motor2_ALI = 9;  //PWM pin 
int motor2_AHI = 4; 

int ledPin1 = 12; 
int ledPin2 = 13; 

int current_sense_1; 
int current_sense_2; 

int current_limit = 25;  // sets the amperage limit that when exceeded on either motor, tells the motor driver to cut power to both motors for 1 second. 

unsigned int servo1_val; 
int adj_val1;  
int servo1_Ready; 

unsigned int servo2_val; 
int adj_val2;  
int servo2_Ready; 

unsigned int servo3_val; 
int adj_val3;  
int servo3_Ready; 

int deadband_high = 275; 
int deadband_low = 235;  

int pwm_ceiling = 256; 
int pwm_floor = 255;  

// You can adjust these values to calibrate the code to your specific radio - check the Serial Monitor to see your values. 
int low1 = 1100; 
int high1 = 1900; 
int low2 = 1100; 
int high2 = 1900; 

void setup() { 

  TCCR1B = TCCR1B & 0b11111000 | 0x01; // change PWM frequency on pins 9 and 10 to 32kHz 
  TCCR2B = TCCR2B & 0b11111000 | 0x01; // change PWM frequency on pins 3 and 11 to 32kHz 

  Serial.begin(9600); 

  //motor1 pins 
  pinMode(motor1_ALI, OUTPUT); 
  pinMode(motor1_AHI, OUTPUT); 
  pinMode(motor1_BLI, OUTPUT); 
  pinMode(motor1_BHI, OUTPUT); 

  //motor2 pins 
  pinMode(motor2_ALI, OUTPUT); 
  pinMode(motor2_AHI, OUTPUT); 
  pinMode(motor2_BLI, OUTPUT); 
  pinMode(motor2_BHI, OUTPUT);  

  //led's 
  pinMode(ledPin1, OUTPUT); 
  pinMode(ledPin2, OUTPUT); 

  //PPM inputs from RC receiver 
  pinMode(ppm1, INPUT); 
  pinMode(ppm2, INPUT); 

} 

void pulse(){ 

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

  // read current sensors on motor-controller 
  current_sense_1 = analogRead(1); 
  current_sense_2 = analogRead(2); 

  //////// determine which direction each motor is spinning 

  if (current_sense_1 > 512){ 
    current_sense_1 = current_sense_1 - 512; 
  } 
  else { 
    current_sense_1 = 512 - current_sense_1; 
  } 

  if (current_sense_2 > 512){ 
    current_sense_2 = current_sense_2 - 512; 
  } 
  else { 
    current_sense_2 = 512 - current_sense_2; 
  }  

  //////// adjust the directional value into Amperes by dividing by 13.8

  current_sense_1 = current_sense_1 / 13.8; 
  current_sense_2 = current_sense_2 / 13.8; 

  //////// if either Ampere value is above the threshold, stop both motors for 1 second 

  if (current_sense_1 > current_limit || current_sense_2 > current_limit){ 
    m1_stop(); 
    m2_stop(); 
    delay(1000); 
  } 

  pulse(); // gather pulses from the R/C

  if (servo1_Ready) {  

    // channel 1 
    adj_val1 = map(servo1_val, low1, high1, 0, 511); 
    adj_val1 = constrain(adj_val1, 0, 511); 

    if (adj_val1 > 511) { 
      adj_val1 = 511; 
    } 
    else if (adj_val1 < 0) { 
      adj_val1 = 0; 
    } 
    else { 
    } 

    if (adj_val1 > deadband_high) { 
      m1_forward(adj_val1 - pwm_ceiling); 
    } 
    else if (adj_val1 < deadband_low) { 
      m1_reverse(pwm_floor - adj_val1); 
    } 
    else { 
      m1_stop(); 
    }  
  } 
  else { 
    m1_stop(); 
  } 

  if (servo2_Ready) { 

    // channel 2 
    adj_val2 = map(servo2_val, low2, high2, 0, 511); 
    adj_val2 = constrain(adj_val2, 0, 511); 

    if (adj_val2 > 511) { 
      adj_val2 = 511; 
    } 
    else if (adj_val2 < 0) { 
      adj_val2 = 0; 
    } 
    else { 
    } 

    if (adj_val2 > deadband_high) { 
      m2_forward(adj_val2 - pwm_ceiling); 
    } 
    else if (adj_val2 < deadband_low) { 
      m2_reverse(pwm_floor - adj_val2); 
    } 
    else { 
      m2_stop(); 
    }  

  } 
  else { 
    m2_stop(); 
  } 

  Serial.print("M1 Amps =   "); 
  Serial.print(current_sense_1); 
  Serial.print("  "); 

  Serial.print("M2 Amps =   "); 
  Serial.print(current_sense_2); 
  Serial.print("  "); 


  Serial.print("channel 1:  "); 
  Serial.print(adj_val1); 
  Serial.print("  "); 

  Serial.print("channel 2:  "); 
  Serial.print(adj_val2); 
  Serial.print("  "); 

  Serial.print("Switch Value:  "); 
  Serial.print(servo3_val); 
  Serial.println("  "); 

} 





void m1_forward(int m1_speed){ 
  digitalWrite(motor1_AHI, LOW); 
  digitalWrite(motor1_BLI, LOW); 
  digitalWrite(motor1_BHI, HIGH); 
  analogWrite(motor1_ALI, m1_speed); 
  digitalWrite(ledPin1, LOW);    
} 

void m1_reverse(int m1_speed){ 
  digitalWrite(motor1_BHI, LOW); 
  digitalWrite(motor1_ALI, LOW); 
  digitalWrite(motor1_AHI, HIGH); 
  analogWrite(motor1_BLI, m1_speed); 
  digitalWrite(ledPin1, LOW); 
} 

void m2_forward(int m2_speed){ 
  digitalWrite(motor2_AHI, LOW); 
  digitalWrite(motor2_BLI, LOW); 
  digitalWrite(motor2_BHI, HIGH); 
  analogWrite(motor2_ALI, m2_speed);   
  digitalWrite(ledPin2, LOW); 
} 

void m2_reverse(int m2_speed){ 
  digitalWrite(motor2_BHI, LOW); 
  digitalWrite(motor2_ALI, LOW); 
  digitalWrite(motor2_AHI, HIGH); 
  analogWrite(motor2_BLI, m2_speed);  
  digitalWrite(ledPin2, LOW); 
} 

void m1_stop(){    
  digitalWrite(motor1_BHI, LOW); 
  digitalWrite(motor1_ALI, LOW); 
  digitalWrite(motor1_AHI, LOW); 
  digitalWrite(motor1_BLI, LOW); 
  digitalWrite(ledPin1, HIGH); 
} 

void m2_stop(){ 
  digitalWrite(motor2_BHI, LOW); 
  digitalWrite(motor2_ALI, LOW); 
  digitalWrite(motor2_AHI, LOW); 
  digitalWrite(motor2_BLI, LOW); 
  digitalWrite(ledPin2, HIGH);  
} 

