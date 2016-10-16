import processing.serial.*;

import procontroll.*;
import java.io.*;

ControllIO controll;
ControllDevice device;
ControllStick stick1;
ControllStick stick2;
ControllButton button;

float left_raw;
float right_raw;

float m_left = 0;
float m_right = 0;

float mapped_left = 0;
float mapped_right = 0;

String incoming_serial = "";

Serial myPort;

void setup() {
  
  println(Serial.list());  // will show all Com ports

  myPort = new Serial(this, Serial.list()[0], 19200);

  size(20,20);

  controll = ControllIO.getInstance(this);

  device = controll.getDevice(0);
  device.printSticks();

  stick1 = device.getStick(1);
  stick1.setTolerance(0.05f);

  stick2 = device.getStick(0);
  stick2.setTolerance(0.05f);

  //button = device.getButton(0);

  fill(0);
  rectMode(CENTER);
}





void draw() {
  background(255);

  get_values();
  
  map_motor_values();
  
  while(myPort.available() > 0){
    incoming_serial = myPort.readString();
  }
  debug();

  myPort.write("$L" + (int)m_left + "Z");
  delay(50);
  myPort.write("$R" + (int)m_right + "Z");
  delay(50);
  
}





void get_values() {
  left_raw = stick2.getX() * 100.0;
  right_raw = stick1.getY() * 100.0;
  
}





void map_motor_values() {
  // First, set m_left and m_right both to the mapping
  // from -255 to 255 of the y component.
  m_left  = map(left_raw, 100, -100, 128, -128);
  m_right = map(right_raw, 100, -100, 128, -128);

 
  // Constrain the max/min values of the m_left and m_right variables
  // so that they can't bleed into each other after being mapped.
  if(m_left > 255){
    m_left = 255;
  }
  if(m_left < -255){
    m_left = -255;
  }
  if(m_right > 255){
    m_right = 255;
  }
  if(m_right < -255){
    m_right = -255;
  }


}

void debug() {
  // show what m_left and m_right do
  /*
  print("m_left: ");
  print(m_left);
  print("   "); 
  print("m_right: ");
  print(m_right);
  print("   "); 
  */
  if(incoming_serial != null){
    println((String)incoming_serial);
  }
}

