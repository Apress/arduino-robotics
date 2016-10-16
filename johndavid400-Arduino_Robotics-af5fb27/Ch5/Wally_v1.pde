// Wally the wall-bot. 
// Follow a right-hand wall and traverse obstacles, using 3 ultrasonic sensors
// Connect Maxbotics ultrasonic sensors to Arduino analog inputs A0, A1, and A2.
// H-bridge motor pins are listed below and shown in Figure 5-14

// create variables for each sensor reading
int front_right_sensor = 0;
int back_right_sensor = 0;
int center_sensor = 0;

// define pins for motor 1
int m1_AHI = 2;
int m1_ALI = 11;  
int m1_BLI = 3;   // 12 on Ardiuno Mega
int m1_BHI = 4; 

// define pins for motor 2
int m2_AHI = 8;
int m2_ALI = 9;  
int m2_BLI = 10;  
int m2_BHI = 7;

// variables to hold upper and lower limits
int threshold = 20;  // Use this to adjust the center sensor threshold. 
int right_upper_limit = 10; // Use this to adjust the upper right sensor limit. 
int right_lower_limit = 8;  // Use this to adjust the lower right sensor limit. 

// speed variables
int speed1 = 64;  // setting for 1/4 speed
int speed2 = 128; // setting for 1/2 speed
int speed3 = 192; // setting for 3/4 speed
int speed4 = 255; // setting for full speed

// end of variables 

void setup(){

  // change the PWM frequency for Timer 1 of Arduino 
  // pins 9 & 10 on standard Arduino or pins 11 and 12 on Arduino Mega
  TCCR1B = TCCR1B & 0b11111000 | 0x01;
  // change the PWM frequency for Timer 2 of Arduino 
  // pins 3 & 11 on standard Arduino or pins 9 & 10 on Arduino Mega 
  TCCR2B = TCCR2B & 0b11111000 | 0x01; 

  Serial.begin(9600);

  // set motor pins as outputs

  pinMode(m1_AHI, OUTPUT);
  pinMode(m1_ALI, OUTPUT);
  pinMode(m1_BHI, OUTPUT);
  pinMode(m1_BLI, OUTPUT);

  pinMode(m2_AHI, OUTPUT);
  pinMode(m2_ALI, OUTPUT);
  pinMode(m2_BHI, OUTPUT);
  pinMode(m2_BLI, OUTPUT);

}

void gather(){
  // function for updating all sensor values
  // Divide each sensor by 2.54 to get the reading in Inches.
  back_right_sensor = analogRead(0) / 2.54; 
  front_right_sensor = analogRead(1) / 2.54;
  center_sensor = analogRead(2) / 2.54;
}

void loop(){

  gather();  // call function to update sensors

  // first, check to see if the center sensor is above its threshold:
  if (center_sensor > threshold) {

    // is the Front Right Sensor (FRS) below the lower threshold value?
    if (front_right_sensor < right_lower_limit){
      // if so, check to see if the Back Right Sensor (BRS) is also below lower threshold:
      if (back_right_sensor < right_lower_limit){
        // Wally is too close to wall, go back:
        m1_stop();
        m2_forward(speed3);
      }
      // otherwise, see if BRS is above the upper threshold:
      else if (back_right_sensor > right_upper_limit){
        // Wally is heading toward wall - correct this:
        m1_stop();
        m2_forward(speed3);
      }
      // (else) If BRS is not above upper threshold or below lower threshold, it must be within range:
      else{ 
        // Wally is just slightly off track, make minor adjustment away from wall:
        m1_forward(speed2);
        m2_forward(speed3);
      }
    }

    // else, if FRS is not below the lower threshold, see if it is above the upper threshold:
    else if (front_right_sensor > right_upper_limit){
      // FRS is above upper threshold, make sure it can still detect a wall nearby (use center sensor threshold value):
      if (front_right_sensor > threshold){
        // Wally might be reading an outside corner wall, check BRS:
        if (back_right_sensor < right_upper_limit){
          // If BRS is still within range, make minor adjustment:
          m1_forward(speed3);
          m2_forward(speed2);
        }
        // Otherwise, check to see if BRS is also above the threshold: 
        else if (back_right_sensor > threshold){
          // Wally has found an outside corner! Turn right:
          m1_forward(speed4);
          m2_reverse(speed1);
        }
      }
      // FRS is above upper threshold, see if BRS is below lower threshold:
      else if (back_right_sensor < right_lower_limit){
        // if so, bring Wally back toward the wall
        m1_forward(speed3);
        m2_forward(speed1);
      }
      // if not, check to see if BRS is also above the upper threshold:
      else if (back_right_sensor > right_upper_limit){
        // if so, bring Wally back towards wall:
        m1_forward(speed2);
        m2_stop();
      }
      // Otherwise,  
      else{
        // else, make minor adjustments to bring Wally back on track
        m1_forward(speed3);
        m2_forward(speed2);
      }
    }

    // else; FRS is within both side thresholds, so we can proceed to check the BRS.
    else {
      // see if BRS is above the upper threshold:
      if (back_right_sensor > right_upper_limit){
        // is so, make adjusment:
        m1_forward(speed1);
        m2_forward(speed3);
      }
      // if BRS is within upper threshold, check to see if it is below lower threshold:
      else if (back_right_sensor < right_lower_limit) {
        // if so, make opposite adjustment:
        m1_forward(speed3);
        m2_forward(speed1);
      }
      // otherwise, BOTH side sensors are within range:
      else {
        // So drive straight ahead!
        m1_forward(speed2);
        m2_forward(speed2);
      }
    }

  }

  // If center sensor is not above the upper threshold, it must be below it, time to STOP!
  else {
    // If center sensor is BELOW threshold, turn left and re-evaluate walls

    // Stop Wally
    m1_stop();
    m2_stop();
    delay(200);
    // Turn Wally left (for 500 milliseconds)
    m1_reverse(speed4);
    m2_forward(speed4);
    delay(500);
    // Stop again
    m1_stop();
    m2_stop();
    delay(200);
  }

  // Now print sensor values on the Serial monitor
  Serial.print(back_right_sensor);
  Serial.print("          ");
  Serial.print(front_right_sensor);
  Serial.print("          ");
  Serial.print(center_sensor);
  Serial.println("          ");

  // End of loop

}


// Create functions for motor-controller actions

void m1_reverse(int x){
  // function for motor 1 reverse
  digitalWrite(m1_BHI, LOW);
  digitalWrite(m1_ALI, LOW);
  digitalWrite(m1_AHI, HIGH);
  analogWrite(m1_BLI, x);  
}


void m1_forward(int x){
  // function for motor 1 forward
  digitalWrite(m1_AHI, LOW);
  digitalWrite(m1_BLI, LOW);
  digitalWrite(m1_BHI, HIGH);
  analogWrite(m1_ALI, x);  
}


void m1_stop(){
  // function for motor 1 stop
  digitalWrite(m1_ALI, LOW);
  digitalWrite(m1_BLI, LOW);  
  digitalWrite(m1_AHI, HIGH); // electric brake using high-side fets
  digitalWrite(m1_BHI, HIGH); // electric brake using high-side fets
}


void m2_forward(int y){
  // function for motor 2 forward
  digitalWrite(m2_AHI, LOW);
  digitalWrite(m2_BLI, LOW);
  digitalWrite(m2_BHI, HIGH);
  analogWrite(m2_ALI, y);
}


void m2_reverse(int y){
  // function for motor 2 reverse
  digitalWrite(m2_BHI, LOW);
  digitalWrite(m2_ALI, LOW);
  digitalWrite(m2_AHI, HIGH);
  analogWrite(m2_BLI, y);  
}


void m2_stop(){
  // function for motor 2 stop
  digitalWrite(m2_ALI, LOW);
  digitalWrite(m2_BLI, LOW);  
  digitalWrite(m2_AHI, HIGH);  // electric brake using high-side fets
  digitalWrite(m2_BHI, HIGH);  // electric brake using high-side fets
}


void motors_release(){
  // function to release both motors (no electric brake)
  // release all motors by opening every switch. The bot will coast or roll if on a hill.
  digitalWrite(m1_AHI, LOW);
  digitalWrite(m1_ALI, LOW);
  digitalWrite(m1_BHI, LOW);
  digitalWrite(m1_BLI, LOW); 

  digitalWrite(m2_AHI, LOW);
  digitalWrite(m2_ALI, LOW);
  digitalWrite(m2_BHI, LOW);
  digitalWrite(m2_BLI, LOW);  
}
