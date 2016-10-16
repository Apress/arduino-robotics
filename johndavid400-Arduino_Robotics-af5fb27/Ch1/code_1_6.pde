//Code Example – Pseudo-PWM example (home-made Pulse Width Modulation code)
// Blink the LED on pin 13 with varying duty-cycle 
// Duty-cycle is determined by potentiometer value read from Analog pin 0
// Change frequency of PWM by lowering of variable "cycle_val" to the following
 millisecond values:
// 10 milliseconds = 100 Hz frequency (fast switching)
// 16 milliseconds = 60 Hz (normal lighting frequency)
// 33 milliseconds = 30 Hz  (medium switching)
// 100 milliseconds = 10 Hz  (slow switching)
// 1000 milliseconds = 1 Hz  (extremely slow switching) -  unusable, but try it anyways.

int my_led = 13;   // declare the variable my_led
int pot_val;       // use variable "pot_val" to store the value of the potentiometer 
int adj_val;       // use this variable to adjust the pot_val into a variable frequency value
int cycle_val = 33;  // Use this value to manually adjust the frequency of the pseudo-PWM
 signal

void setup() {
  pinMode(my_led, OUTPUT);    // use the pinMode() command to set my_led as an OUTPUT
}

void loop() {
  pot_val = analogRead(0); // read potentiometer value from A0 (returns a value from 0 - 1023)
  adj_val = map(pot_val, 0, 1023, 0, cycle_val); // map 0 - 1023 analog input from
 0 - cycle_val

  digitalWrite(my_led, HIGH);    // set my_led HIGH (turn it On)
  delay(adj_val);                // stay turned on for this amount of time
  digitalWrite(my_led, LOW);     // set my_led LOW (turn it Off)
  delay(cycle_val - adj_val);    // stay turned off for this amount of time
 
}

// end code
