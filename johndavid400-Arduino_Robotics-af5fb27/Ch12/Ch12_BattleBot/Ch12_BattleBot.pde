// Chapter 12 – The Battle-bot
// Controls 2 Sabertooth motor controllers using R/C pulse signal
// Controls battle-bot weapon using OSMC (open-source motor=controller)
// Decodes 2 R/C servo signals for the Left and Right drive channels (Sabertooth 2x25 in R/C mode)
// Decodes 1 R/C servo signal for weapon (OSMC)
//
//
// Create names for R/C pulse input pins D14 - D17
int RC_1 = 14;
int RC_2 = 15;
int RC_3 = 16;
int RC_4 = 17;
// Create names for R/C pulse output pins D18 and D19
int Left_OUT = 18;
int Right_OUT = 19;
// Name LEDs and attach to pins D12 and D13
int LED_1 = 12;
int LED_2 = 13;
// Name weapon motor controller output pins and attach to D8 - D11
int OSMC_BHI = 8;
int OSMC_BLI = 11; // PWM pin
int OSMC_ALI = 10; // PWM pin
int OSMC_AHI = 9;
// create variables for weapon deadband and arming weapon
int deadband = 10;
int weapon_armed = false;
// Variables to store R/C values
// values for R/C channel 1
int servo1_val;
int adj_val1;
int servo1_Ready;
// values for R/C channel 2
int servo2_val;
int adj_val2;
int servo2_Ready;
// values for R/C channel 3
int servo3_val;
int adj_val3;
int servo3_Ready;
// values for R/C channel 4
int servo4_val;
int adj_val4;
int servo4_Ready;
// End of Variables
// Begin Setup() function
void setup() {
// changes PWM frequency on pins 9 & 10 to 32kHz for weapon
TCCR1B = TCCR1B & 0b11111000 | 0x01;
//motor pins
pinMode(OSMC_ALI, OUTPUT);
pinMode(OSMC_AHI, OUTPUT);
pinMode(OSMC_BLI, OUTPUT);
pinMode(OSMC_BHI, OUTPUT);
//led's
pinMode(LED_1, OUTPUT);
pinMode(LED_2, OUTPUT);
// R/C signal outputs
pinMode(Left_OUT, OUTPUT);
pinMode(Right_OUT, OUTPUT);
//PPM inputs from RC receiver
pinMode(RC_1, INPUT);
pinMode(RC_2, INPUT);
pinMode(RC_3, INPUT);
pinMode(RC_4, INPUT);
// Set all OSMC pins LOW during Setup
digitalWrite(OSMC_BHI, LOW); // AHI and BHI should be HIGH for electric brake
digitalWrite(OSMC_ALI, LOW);
digitalWrite(OSMC_AHI, LOW); // AHI and BHI should be HIGH for electric brake
digitalWrite(OSMC_BLI, LOW);
// blink LEDs to verify setup
digitalWrite(LED_1, HIGH);
digitalWrite(LED_2, LOW);
delay(1000);
digitalWrite(LED_2, HIGH);
digitalWrite(LED_1, LOW);
delay(1000);
digitalWrite(LED_2, LOW);
// Write OSMC Hi-side pins HIGH, enabling electric-brake for weapon motor when not being used
digitalWrite(OSMC_AHI, HIGH);
digitalWrite(OSMC_BHI, HIGH);
}
// End of Setup()
// Begin Loop() function
void loop() {
// Read R/C signals from receiver
servo1_val = pulseIn(RC_1, HIGH, 20000); // weapon channel
servo2_val = pulseIn(RC_2, HIGH, 20000); // left drive channel
servo3_val = pulseIn(RC_3, HIGH, 20000); // right drive channel
servo4_val = pulseIn(RC_4, HIGH, 20000); // weapon disable switch
// Failsafe check - Check to see if BOTH drive channels are valid before processing anything else
if (servo2_val > 0 && servo3_val > 0) {
// turn on Neutral LEDs for the drive channels if they are centered (individually).
// LED 1 for left drive channel
if (servo2_val < 1550 && servo2_val > 1450){
digitalWrite(LED_1, HIGH);
}
else{
digitalWrite(LED_1, LOW);
}
// LED 2 for right drive channel
if (servo3_val < 1550 && servo3_val > 1450){
digitalWrite(LED_2, HIGH);
}
else{
digitalWrite(LED_2, LOW);
}
// Check to see if Toggle switch is engaged (R/C ch5), before enabling Weapon
if (servo4_val > 1550){
// arm weapon
weapon_armed = true;
// Then, go ahead and process the Weapon value
if (servo1_val > 800 && servo1_val < 2200){
// Map bi-directional value from R/C Servo pulse centered at 1500 milliseconds,
// to a forward/reverse value centered at 0.
// 255 = full forward, 0 = Neutral, -255 = full reverse
adj_val1 = map(servo1_val, 1000, 2000, -255, 255);
// Limit the values to +/- 255
if (adj_val1 > 255){
adj_val1 = 255;
}
if (adj_val1 < -255){
adj_val1 = -255;
}
// Check signal for direction of motor (positive or negative value)
if (adj_val1 > deadband){
// if value is positive, write forward value to motor
weapon_forward(adj_val1);
}
else if (adj_val1 < -deadband){
// if value is negative, convert to positive (*-1) then write reverse value to motor
adj_val1 = adj_val1 * -1;
weapon_reverse(adj_val1);
}
else {
// otherwise, weapon signal is neutral, stop weapon motor.
weapon_stop();
adj_val1 = 0;
}
}
else {
// else, if the weapon toggle switch is disengaged, stop weapon (from above)
weapon_stop();
}
}
else{
// else, if Drive signals are not valid disable weapon - extra failsafe
weapon_armed = false;
weapon_stop();
}
}
// If drive signals are not valid, stop using Neutral LEDs and make them blink
// back and forth until the signal is restored - see the acquiring() function.
else {
servo2_val = 1500;
servo3_val = 1500;
weapon_armed = false;
acquiring();
}
// Lastly, send the R/C pulses to the Sabertooth
Send_Pulses();
}
// End Loop
// Begin extra functions
void acquiring(){
// while R/C receiver is searching for a signal, blink LEDs
digitalWrite(LED_1, HIGH);
digitalWrite(LED_2, LOW);
delay(200);
digitalWrite(LED_2, HIGH);
digitalWrite(LED_1, LOW);
delay(200);
digitalWrite(LED_2, LOW);
}
void Send_Pulses(){
// send Left R/C pulse to left Sabertooth S1 and S2
digitalWrite(Left_OUT, HIGH);
delayMicroseconds(servo2_val);
digitalWrite(Left_OUT, LOW);
// send Right R/C pulse to right Sabertooth S1 and S2
digitalWrite(Right_OUT, HIGH);
delayMicroseconds(servo3_val);
digitalWrite(Right_OUT, LOW);
}
// motor forward function for OSMC
void weapon_forward(int speed_val1){
digitalWrite(OSMC_BLI, LOW);
analogWrite(OSMC_ALI, speed_val1);
}
// motor reverse function for OSMC
void weapon_reverse(int speed_val2){
digitalWrite(OSMC_ALI, LOW);
analogWrite(OSMC_BLI, speed_val2);
}
// motor stop function for OSMC
void weapon_stop() {
digitalWrite(OSMC_ALI, LOW);
digitalWrite(OSMC_BLI, LOW);
}
// End of extra functions
// End of Code

