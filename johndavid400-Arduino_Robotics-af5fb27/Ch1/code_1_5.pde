// Code Example – Analog Input – PWM Output 
// Read potentiometer from analog pin 0
// PWM output on pin 3 will be proportional to potentiometer input (check with voltage meter).

int pot_val;     // use variable "pot_val" to store the value of the potentiometer 
int pwm_pin = 3; // name pin Arduino PWM 3 = "pwm_pin"

void setup(){
    pinMode(pwm_pin, OUTPUT);
}

void loop(){

    pot_value = analogRead(0);  // read potentiometer value on analog pin 0

    pwm_value = pot_value / 4;  // pot_value max = 1023 / 4 = 255

    if (pwm_value > 255){       // filter to make sure pwm_value does not exceed 255
        pwm_value = 255;
    }
    if (pwm_value < 0){         // filter to make sure pwm_value does not go below 0
        pwm_value = 0;
    }

    analogWrite(pwm_pin, pwm_value);  // write pwm_value to pwm_pin
}
// end code
