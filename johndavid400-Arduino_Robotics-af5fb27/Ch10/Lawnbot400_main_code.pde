// This is the main code, it should run on the main processor.
// Read PPM signals from 2 channels of an RC reciever and convert the values to PWM in either direction.
// digital pins 5 & 9 control motor1, digital pins 6 & 10 control motor2. 
// DP 12 and 13 are neutral indicator lights. 
// DP 2 and 3 are inputs from the R/C receiver. 
// All analog pins are open. 
// When motor pin is HIGH, bridge is open.
// JDW 2010

// leave pins 0 and 1 open for serial communication

int ppm1 = 2; 
int ppm2 = 3;

int motor1_BHI = 4; 
int motor1_BLI = 5;  // PWM pin
int motor1_ALI = 6;  // PWM pin
int motor1_AHI = 7; 

int motor2_BHI = 8; 
int motor2_BLI = 9;   //PWM pin
int motor2_ALI = 10;  //PWM pin
int motor2_AHI = 11;

int ledPin1 = 12;
int ledPin2 = 13;


unsigned int servo1_val; 
int adj_val1;  
int servo1_Ready;

unsigned int servo2_val; 
int adj_val2;  
int servo2_Ready;

int deadband_high = 275; 
int deadband_low = 235;  

int pwm_ceiling = 256; 
int pwm_floor = 255;  


// You can adjust these values to calibrate the code to your specific radio - check the Serial Monitor to see your values.
int low = 1000;
int high = 2000;

void setup() {

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
  pinMode(ppm1, INPUT); //Pin 2 as input
  pinMode(ppm2, INPUT); //Pin 3 as input

  delay(100);

}

void pulse(){

  servo1_val = pulseIn(2, HIGH, 20000);
  servo2_val = pulseIn(3, HIGH, 20000);

  if (servo1_val > 1000 && servo1_val < 2000){	
    servo1_Ready = true;
  }
  else {
    servo1_Ready = false;
    servo1_val = 1500;
  }

  if (servo2_val > 1000 && servo2_val < 2000){	
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
    adj_val1 = map(servo1_val, low, high, 0, 511);
    adj_val1 = constrain(adj_val1, 0, 511);

    if (adj_val1 > 511) {
      adj_val1 = 511; 
    }
    if (adj_val1 < 0) {
      adj_val1 = 0; 
    }

    if (adj_val1 > deadband_high) {
      digitalWrite(motor1_AHI, LOW);
      digitalWrite(motor1_BLI, LOW);
      digitalWrite(motor1_BHI, HIGH);
      analogWrite(motor1_ALI, adj_val1 - pwm_ceiling);
      digitalWrite(ledPin1, LOW);    
    }
    else if (adj_val1 < deadband_low) {
      digitalWrite(motor1_BHI, LOW);
      digitalWrite(motor1_ALI, LOW);
      digitalWrite(motor1_AHI, HIGH);
      analogWrite(motor1_BLI, pwm_floor - adj_val1); 
      digitalWrite(ledPin1, LOW);        
    }
    else {
      digitalWrite(ledPin1, HIGH);    
      digitalWrite(motor1_BHI, LOW);
      digitalWrite(motor1_ALI, LOW);
      digitalWrite(motor1_AHI, LOW);
      digitalWrite(motor1_BLI, LOW);
    }  
  }
  if (servo2_Ready) {
    // channel 2 
    adj_val2 = map(servo2_val, low, high, 0, 511);
    adj_val2 = constrain(adj_val2, 0, 511);

    if (adj_val2 > 511) {
      adj_val2 = 511; 
    }
    if (adj_val2 < 0) {
      adj_val2 = 0; 
    }

    if (adj_val2 > deadband_high) {
      digitalWrite(motor2_AHI, LOW);
      digitalWrite(motor2_BLI, LOW);
      digitalWrite(motor2_BHI, HIGH);
      analogWrite(motor2_ALI, adj_val2 - pwm_ceiling);   
      digitalWrite(ledPin2, LOW); 
    }
    else if (adj_val2 < deadband_low) {
      digitalWrite(motor2_BHI, LOW);
      digitalWrite(motor2_ALI, LOW);
      digitalWrite(motor2_AHI, HIGH);
      analogWrite(motor2_BLI, pwm_floor - adj_val2);  
      digitalWrite(ledPin2, LOW); 
    }
    else {
      digitalWrite(ledPin2, HIGH);    
      digitalWrite(motor2_BHI, LOW);
      digitalWrite(motor2_ALI, LOW);
      digitalWrite(motor2_AHI, LOW);
      digitalWrite(motor2_BLI, LOW);
    }  
  }
  ///////////////////  print values


  Serial.print("channel 1:  ");
  Serial.print(servo1_val);
  Serial.print("  ");
  Serial.print("PWM1 value:  ");
  Serial.print(adj_val1);
  Serial.print("  ");  

  Serial.print("channel 2:  ");
  Serial.print(servo2_val);
  Serial.print("  ");
  Serial.print("PWM2 value:  ");
  Serial.print(adj_val2);
  Serial.println("  ");    

}





