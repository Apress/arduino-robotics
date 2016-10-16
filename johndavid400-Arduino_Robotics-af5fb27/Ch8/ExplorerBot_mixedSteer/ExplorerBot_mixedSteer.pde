// Decode 2 r/c signals using interrupts and 1 failsafe channel using pulseIn.
// The 2 motor channels have full 0-100% high-resolution pwm speed control
// The failsafe channel is polled, and outputs a digital HIGH/LOW. Suitable as a failsafe or auxillary channel.
//   Quadrants of the joystick shown: Q1 = forward right, Q2 = forward left, Q3 = reverse left, Q4 = reverse right
//                |       
//                |      
//          Q2    |    Q1 
//                |
//      __________|___________
//                |
//          Q3    |    Q4
//                |
//                |
//
//  JD Warren 1-8-2010
//  www.rediculouslygoodlooking.com
// failsafe channel is currently used to toggle speed mode fast/slow.
// THIS CODE USES CHANNEL MIXING -- you need to use channel 1 up/down, and channel 2 left/right.

// Inputs from RC receiver
int ppm1 = 17; 
int ppm2 = 18;
int ppm3 = 19;

// Attach motor inputs to Arduino digital output pins
int motor1_BHI = 7; 
int motor1_BLI = 3;  // PWM pin
int motor1_ALI = 11;  // PWM pin
int motor1_AHI = 8; 

int motor2_BHI = 5; 
int motor2_BLI = 10;   //PWM pin
int motor2_ALI = 9;  //PWM pin
int motor2_AHI = 4;

int ledPin1 = 13; // attach LED 1 to pin 13
int ledPin2 = 12; // attach LED 1 to pin 12

int current_sense_1; // variable to hold current sensor value
int current_sense_2;

int current_limit = 25;  // sets the amperage limit that when exceeded on either motor, tells the motor driver to cut power to both motors for 1 second.

int cool_off = 1000; // number of milliseconds to stop motors if current limit is reached

unsigned int servo1_val; // unsigned integer simply means that it cannot be negative... makes sense
int adj_val1;  
int servo1_Ready;

unsigned int servo2_val; 
int adj_val2;  
int servo2_Ready;

unsigned int servo3_val; 
int adj_val3;  
int servo3_Ready;

////////////////////////////////

int deadband = 10; // sets the total deadband - this number is divided by 2 to get the deadband for each direction. Higher value will yield larger neutral band.
int deadband_high = deadband / 2; // sets deadband_high to be half of deadband (ie. 10/2 = 5)
int deadband_low = deadband_high * -1; // sets deadband_low to be negative half of deadband (ie. 5 * -1 = -5)

// You can adjust these values to calibrate the code to your specific radio - check the Serial Monitor to see your values.
int low1 = 1100;
int high1 = 1900;
int low2 = 1100;
int high2 = 1900;

int x; // this will represent the x coordinate
int y; // this will represent the y coordinate

int left; // X and y will be converted into left and right values
int right; // X and y will be converted into left and right values

int speed_low; 
int speed_high;

int speed_limit = 255;

int speed_max = 255;
int speed_min = 0;


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
  pinMode(ppm3, INPUT);

  delay(1000);

}


void pulse(){

  servo1_val = pulseIn(ppm1, HIGH, 20000); // read pulse from channel 1
  // make sure servo 1 value is within range (between 800 and 2200 microseconds)
  if (servo1_val > 800 && servo1_val < 2200){	
    servo1_Ready = true;
  }
  else {
    servo1_Ready = false;
    servo1_val = 1500;
  }

  servo2_val = pulseIn(ppm2, HIGH, 20000); // read pulse from channel 2
  if (servo2_val > 800 && servo2_val < 2200){	
    servo2_Ready = true;
  }
  else {
    servo2_Ready = false;
    servo2_val = 1500;
  }

  servo3_val = pulseIn(ppm3, HIGH, 20000); // read pulse from channel 3
  if (servo3_val > 1600){
    speed_limit = 255;
  }
  else{
    speed_limit = 128;
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

  //////// adjust the directional value into Amperes

  current_sense_1 = current_sense_1 / 13.5;
  current_sense_2 = current_sense_2 / 13.5;

  //////// if either Ampere value is above the threshold, stop both motors for 1 second
  // remember that the "||" used in the "if" statement below is like saying "or"

  if (current_sense_1 > current_limit || current_sense_2 > current_limit){
    m1_stop();
    m2_stop();
    digitalWrite(ledPin2, HIGH);
    delay(cool_off);
    digitalWrite(ledPin2, LOW);
  }



  ///////////////////////////////

  pulse(); // read pulses

  ///////////////////////////////

  if (servo1_Ready) {

    servo1_Ready = false;  
    // map servo value from 1500 microseconds (neutral) to a value of 0. 
    //If pulse is above neutral (forward) value will be 0 to 255, otherwise it will be 0 to -255 for reverse
    adj_val1 = map(servo1_val, low1, high1, -speed_limit, speed_limit); 
    adj_val1 = constrain(adj_val1, -speed_limit, speed_limit);

    x = adj_val1;

  }
  if (servo2_Ready) {

    servo2_Ready = false;

    adj_val2 = map(servo2_val ,low2, high2, -speed_limit, speed_limit); 
    adj_val2 = constrain(adj_val2, -speed_limit, speed_limit);

    y = adj_val2;

  }



  if (x > deadband_high) {  // if the Up/Down R/C input is above the upper threshold, go FORWARD 

    // now check to see if left/right input from R/C is to the left, to the right, or centered.

    if (y > deadband_high) { // go forward while turning right proportional to the R/C left/right input
      left = x;
      right = x - y;
      test(); // make sure signal stays within range of the Arduino capable values
      m1_forward(left);
      m2_forward(right);
      // quadrant 1
    }

    else if (y < deadband_low) {   // go forward while turning left proportional to the R/C left/right input
      left = x - (y * -1);  // remember that in this case, y will be a negative number
      right = x;
      test(); 
      m1_forward(left);
      m2_forward(right);
      // quadrant 2
    }

    else {   // left/right stick is centered, go straight forward
      left = x;
      right = x;
      test();
      m1_forward(left);
      m2_forward(right);
    }
  }

  else if (x < deadband_low) {    // otherwise, if the Up/Down R/C input is below lower threshold, go BACKWARD

    // remember that x is below deadband_low, it will always be a negative number, we need to multiply it by -1 to make it positive.
    // now check to see if left/right input from R/C is to the left, to the right, or centered.

    if (y > deadband_high) { // // go backward while turning right proportional to the R/C left/right input
      left = (x * -1);
      right = (x * -1) - y;
      test();
      m1_reverse(left);
      m2_reverse(right);
      // quadrant 4
    }

    else if (y < deadband_low) {   // go backward while turning left proportional to the R/C left/right input
      left = (x * -1) - (y * -1);
      right = x * -1;
      test();
      m1_reverse(left);
      m2_reverse(right);   
      // quadrant 3
    }			

    else {   // left/right stick is centered, go straight backwards
      left = x * -1; 
      right = x * -1; 
      test();
      m1_reverse(left);
      m2_reverse(right);
    }

  }

  else {     // if neither of the above 2 conditions is met, the Up/Down R/C input is centered (neutral)

    if (y > deadband_high) {

      left = y / 2;
      right = y / 2;
      test();
      m1_reverse(left);
      m2_forward(right);

    }  

    else if (y < deadband_low) {

      left = (y * -1) / 2;
      right = (y * -1) / 2;
      test();
      m1_forward(left);
      m2_reverse(right);

    }  

    else {

      left = 0;
      right = 0;
      m1_stop();
      m2_stop();
    }

  }

  Serial.print(left);
  Serial.print("   ");
  Serial.print(right);
  Serial.print("    ");

  Serial.print(servo1_val);
  Serial.print("   ");
  Serial.print(servo2_val);
  Serial.print("    ");
  Serial.print(servo3_val);
  Serial.println("   ");


}


int test() {

  // make sure we don't try to write any invalid PWM values to the h-bridge, ie. above 255 or below 0.

  if (left > 254) {
    left = 255;
  }
  if (left < 1) {
    left = 0; 
  }
  if (right > 254) {
    right = 255;
  }
  if (right < 1) {
    right = 0; 
  } 

}


// Create single instances for each motor direction, so we don't accidentally write a shoot-through condition to the H-bridge.

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
  digitalWrite(ledPin1, LOW); 
}

void m2_reverse(int m2_speed){
  digitalWrite(motor2_BHI, LOW);
  digitalWrite(motor2_ALI, LOW);
  digitalWrite(motor2_AHI, HIGH);
  analogWrite(motor2_BLI, m2_speed);  
  digitalWrite(ledPin1, LOW); 
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
  digitalWrite(ledPin1, HIGH);  
}






