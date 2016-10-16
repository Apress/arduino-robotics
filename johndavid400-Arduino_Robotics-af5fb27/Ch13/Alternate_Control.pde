// Alternate Control - Chapter 13
// Use XBee radios to communicate with 
// Read Serial string 
// digital pins 5 & 9 control motor1, digital pins 6 & 10 control motor2. 
// DP 12 and 13 are neutral indicator lights. 
// DP 2 and 3 are inputs from the R/C receiver. 
// All analog pins are open. 
// When motor pin is HIGH, bridge is open.
// JDW 2010

// leave pins 0 and 1 open for serial communication


// These values are used to control the H-bridge of the Explorer-Bot in Chapter 8

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

/// These values are received from the Processing sketch
int left;
int right;

int deadband = 5;

String readString;
char command_end = 'Z';
char command_begin = '$';

char current_char;



void setup() {
  TCCR1B = TCCR1B & 0b11111000 | 0x01;
  TCCR2B = TCCR2B & 0b11111000 | 0x01;

  Serial.begin(19200);

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

  // turn motors OFF at startup
  m1_stop();
  m2_stop();

  delay(1000);

  readString = "";

}


void loop() {

  ////////// use Serial
  while (Serial.available()) {
    current_char = Serial.read();  //gets one byte from serial buffer

    if(current_char == command_begin){ // when we get a begin character, start reading
      readString = "";
      while(current_char != command_end){ // stop reading when we get the end character
        current_char = Serial.read();  //gets one byte from serial buffer
        if(current_char != command_end){
          //Serial.println(current_char);
          readString += current_char;
        }
      }
      if(current_char == command_end){ // since we have the end character, send the whole command to the command handler and reset readString.
        //Serial.println("foo");
        handle_command(readString);
        readString = "";
      }
    } 
  } 
  //makes the string readString


  // Test values to make sure they are not above 255 or below -255, as these values will be sent as an analogWrite() command (0-255)

  if(left > 255){
    left = 255;
  }
  if(left < -255){
    left = -255;
  }
  if(right > 255){
    right = 255;
  }
  if(right < -255){
    right = -255;
  }

  // Here we decide whether the motors should go forward or reverse.
  // if the value is positive, go forward - if the value is negative, go reverse
  // We use a deadband to allow for some "Neutral" space around the center - I set deadband = 5, you can change this, though I wouldn't really go any lower.
  // If no deadband is used, a sporadic signal could cause movement of the bot even with no user input.

  // first determine direction for the left motor
  if(left > deadband){
    m1_forward(left);
  } 
  else if(left < -deadband){
    m1_reverse(left * -1);
  }
  else {
    m1_stop();
  }

  // then determine direction for the  right motor
  if(right > deadband){
    m2_forward(right);
  } 
  else if(right < -deadband){
    m2_reverse(right * -1);
  }
  else {
    m2_stop();
  }

  // add a small Delay to give the Xbee some time between readings
  delay(25); 

  // end of loop

}



void set_left_value(String the_string){
  if(the_string.substring(0,1) == "L"){
    char temp[20];
    the_string.substring(1).toCharArray(temp, 19);
    int l_val = atoi(temp);
    left = l_val;
  }
}

void set_right_value(String the_string){
  if(the_string.substring(0,1) == "R"){
    char temp[20];
    the_string.substring(1).toCharArray(temp, 19);
    int r_val = atoi(temp);
    right = r_val;
  }
}


void handle_command(String readString){

  set_left_value(readString);
  set_right_value(readString);


  // Here you can send the values back to your Computer and read them on the Processing terminal.
  // Sending these values over Xbee can take slow the sketch down, so I comment them out after testing. 
  /*
  Serial.print("left: ");
   Serial.print(left);
   Serial.print("     ");
   Serial.print("right: ");
   Serial.print(right);
   Serial.println("     ");
   */

}


// From here down are motor-controller functions only.

void m1_forward(int val){
  digitalWrite(motor1_AHI, LOW);
  digitalWrite(motor1_BLI, LOW);
  digitalWrite(motor1_BHI, HIGH);
  analogWrite(motor1_ALI, val);
  digitalWrite(ledPin1, LOW);    
}

void m1_reverse(int val){
  digitalWrite(motor1_BHI, LOW);
  digitalWrite(motor1_ALI, LOW);
  digitalWrite(motor1_AHI, HIGH);
  analogWrite(motor1_BLI, val); 
  digitalWrite(ledPin1, LOW);
}

void m2_forward(int val){
  digitalWrite(motor2_AHI, LOW);
  digitalWrite(motor2_BLI, LOW);
  digitalWrite(motor2_BHI, HIGH);
  analogWrite(motor2_ALI, val);   
  digitalWrite(ledPin2, LOW); 
}

void m2_reverse(int val){
  digitalWrite(motor2_BHI, LOW);
  digitalWrite(motor2_ALI, LOW);
  digitalWrite(motor2_AHI, HIGH);
  analogWrite(motor2_BLI, val);  
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

// end of sketch














