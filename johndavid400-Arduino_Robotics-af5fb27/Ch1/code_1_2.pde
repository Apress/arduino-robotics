// Code Example: Input and Output 
// This code will set up a digital input on Arduino pin 2 and a digital output on Arduino pin 13.
// If the input is HIGH the output LED will be LOW 

int switch_pin = 2;    // this tells the Arduino that we want to name digital pin 2 "switch_pin"
int switch_value;      // we need a variable to store the value of switch_pin, so we make "switch_value"
int my_led = 13;       // tell Arduino to name digital pin 13 = "my_led"

void setup(){
    pinMode(switch_pin, INPUT);                    // let Arduino know to use switch_pin (pin 2) as an Input
    pinMode(my_led, OUTPUT);                       // let Arduino know to use my_led (pin 13) as an Output
}

void loop(){
    switch_value = digitalRead(switch_pin);        // read switch_pin and record the value to switch_value

    if (switch_value == HIGH){                     // if that value "is equal to (==)"  HIGH...
        digitalWrite(my_led, LOW);                 // ... then turn the LED off
    }
    else {                                         // otherwise...
        digitalWrite(my_led, HIGH);                // ...turn the LED on.   
    }
}
// end code
