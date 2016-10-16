// Code Example – Using an Interrupt pin to capture an R/C pulse length
// Connect signal from R/C receiver into Arduino digital pin 2
// Turn On R/C transmitter ed when using the Arduinos two external interrupts is that 
// If valid signal is received, you should see the LED on pin 13 turn On.
// If no valid signal is received, you will see the LED turned Off.

int my_led = 13; 

volatile long servo_startPulse;   
volatile unsigned int pulse_val; 
int servo_val;  

void setup() { 
  Serial.begin(9600); 
  pinMode(servo_val, INPUT); 
 
  attachInterrupt(0, rc_begin, RISING);     // initiate the interrupt for a rising signal
}

// set up the rising interrupt 
void rc_begin() {          
  servo_startPulse = micros();    
  detachInterrupt(0);  // turn Off the rising interrupt
  attachInterrupt(0, rc_end, FALLING); // turn On the falling interrupt
} 

// set up the falling interrupt
void rc_end() { 
  pulse_val = micros() - servo_startPulse; 
  detachInterrupt(0);  // turn Off the falling interrupt
  attachInterrupt(0, rc_begin, RISING); // turn On the rising interrupt
      }

void loop() { 
  servo_val = pulse_val; // record the value that the Interrupt Service Routine calculated
  if (servo_val > 600 && servo_val < 2400){
	digitalWrite(my_led, HIGH);   // if the value is within R/C range, turn the LED On
      Serial.println(servo_val);
  }
  else {
      	digitalWrite(my_led, LOW);  // If the value is not within R/C range, turn the LED Off.
  }
      }
