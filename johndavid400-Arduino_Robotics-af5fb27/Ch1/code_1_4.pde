// Code Example – Analog Input
// Read potentiometer from analog pin 0
// And display 10-bit value (0-1023) on the serial monitor
// After uploading, open serial monitor from Arduino IDE at 9600bps.

int pot_val;    // use variable "pot_val" to store the value of the potentiometer 

void setup(){
    Serial.begin(9600);  // start Arduino serial communication at 9600 bps
}

void loop(){
    pot_value = analogRead(0);  // use analogRead on analog pin 0
    Serial.println(pot_val);    // use the Serial.print() command to send the value to the
 monitor
}

// end code
