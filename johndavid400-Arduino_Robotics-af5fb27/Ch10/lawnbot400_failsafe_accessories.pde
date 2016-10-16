// This is the failsafe sketch to decode several more R/C signals and drive external circuitry
// Failsafe INPUT goes into pin 2
// Lawnmower kill-switch INPUT goes into pin 3
// Head-lights INPUT goes into pin 4
// Bucket-lift motor INPUT goes into pin 5
// OUTPUTs are listed by function
// you will need a Relay interface board for each output and an H-bridge or DPDT relay to control the lift-motor UP/DOWN
// JD Warren 2010

int ppm1 = 2; // R/C input for failsafe channel
int ppm2 = 3; // R/C input for lights
int ppm3 = 4; // R/C input for mower kill-switch
int ppm4 = 5; // R/C input for dump-bucket lift motor - or anything else you like.

int failsafe_Pin = 6; // pin used to switch Failsafe relay
int mower_kill = 7;   // pin used to switch lawnmower kill switch relay

int lights_Pin = 8;  // pin used to switch headlights relay or PWM H-bridge for brighness control.
int bucket_lift_up = 9; // pin used to raise dump-bucket via H-bridge
int bucket_lift_down = 10; // pin used to lower dump-bucket via H-bridge 

int ledPin1 = 13;

// variables to hold the raw R/C readings
unsigned int ppm1_val;
unsigned int ppm2_val;
unsigned int ppm3_val;
unsigned int ppm4_val;

// variables to hold the tested R/C values
unsigned int failsafe_val;
unsigned int lights_val;
unsigned int mower_kill_val;
unsigned int bucket_lift_val;

int update = 20;  // sets the update interval to 20 milliseconds


void setup() {

  Serial.begin(9600);

  // Declare the OUTPUTS
  pinMode(failsafe_Pin, OUTPUT);
  pinMode(mower_kill, OUTPUT);

  pinMode(lights_Pin, OUTPUT);
  pinMode(bucket_lift_up, OUTPUT);
  pinMode(bucket_lift_down, OUTPUT);

  //Failsafe LED
  pinMode(ledPin1, OUTPUT);

  //PPM inputs from RC receiver
  pinMode(ppm1, INPUT); 
  pinMode(ppm2, INPUT);	

  // The failsafe should be OFF by default  
  digitalWrite(failsafe_Pin, LOW);

}

void pulse() {

  // decode and test the value for ppm1
  ppm1_val = pulseIn(ppm1, HIGH, 20000);
  if (ppm1 < 600 || ppm1 > 2400) {
    failsafe_val = 1500; 
  }
  else {
    failsafe_val = ppm1_val; 
  }

  // decode and test the value for ppm2
  ppm2_val = pulseIn(ppm2, HIGH, 20000);
  if (ppm2 < 600 || ppm2 > 2400) {
    mower_kill = 1500;
  }
  else {
    mower_kill = ppm2_val; 
  }

  // decode and test the value for ppm3
  ppm3_val = pulseIn(ppm3, HIGH, 20000);
  if (ppm3 < 600 || ppm3 > 2400) {
    lights_val = 1500;
  }
  else {
    lights_val  = ppm3_val; 
  } 

  // decode and test the value for ppm4
  ppm4_val = pulseIn(ppm4, HIGH, 20000);
  if (ppm4 < 600 || ppm4 > 2400) {
    bucket_lift_val = 1500;
  }
  else {
    bucket_lift_val = ppm4_val; 
  } 

}

void loop() {

  // Use pulseIn() to check the value of each R/C input using the function above  
  pulse();


  // Failsafe relay

  if (failsafe_val > 1750 && failsafe_val < 2000) {
    digitalWrite(failsafe_Pin, LOW); 
    digitalWrite(ledPin1, HIGH);
  }
  else {
    digitalWrite(failsafe_Pin, HIGH);
    digitalWrite(ledPin1, LOW);
  }

  // Lawnmower kill-switch relay

  if (mower_kill_val > 1750 && mower_kill_val < 2000) {
    digitalWrite(mower_kill, LOW); 
  }
  else {
    digitalWrite(mower_kill, HIGH);
  }

  // Lights

  if (lights_val > 1750 && lights_val < 2000) {
    digitalWrite(lights_Pin, LOW); 
  }
  else {
    digitalWrite(lights_Pin, HIGH);
  }

  // Lift motor for dump-bucket

   // Map the value from a pulse value of 1000 - 2000, to a PWM value of (0 - 511) / 2 directions (UP/DOWN).
  bucket_lift_val = map(bucket_lift_val, 1000, 2000, 0, 511);
  bucket_lift_val = constrain(bucket_lift_val, 0, 511);

  // make sure the value does not go above 511 or below 0.
  if (bucket_lift_val > 511) {
    bucket_lift_val = 511; 
  }
  if (bucket_lift_val < 0) {
    bucket_lift_val = 0; 
  }
  
  // center the value at 255, above this value is UP
  if (bucket_lift_val > 260) {
    digitalWrite(bucket_lift_down, LOW); 
    analogWrite(bucket_lift_up, bucket_lift_val - 256);
  }
  // center the value at 255, below this value is DOWN  
  else if (bucket_lift_val < 250) {
    digitalWrite(bucket_lift_up, LOW);
    analogWrite(bucket_lift_down, 255 - bucket_lift_val);
  }
  
  // otherwise, turn the motor OFF
  else {
    digitalWrite(bucket_lift_up, LOW);
    digitalWrite(bucket_lift_down, LOW);
  }

  // print the values for each R/C channel

  Serial.print(" Failsafe:  ");
  Serial.print(failsafe_val);
  Serial.print("  ");
  Serial.print(" Mower kill-switch:  ");
  Serial.print(mower_kill_val);
  Serial.print("  ");
  Serial.print(" Lights:  ");
  Serial.print(lights_val);
  Serial.print("  ");
  Serial.print(" Bucket lift:  ");
  Serial.print(bucket_lift_val);
  Serial.println("  ");

  delay(update);

}


