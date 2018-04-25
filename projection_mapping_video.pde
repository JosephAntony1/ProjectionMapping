import processing.video.*;
import themidibus.*;
import deadpixel.keystone.*;

/**
 * This is a simple example of how to use the Keystone library.
 *
 * To use this example in the real world, you need a projector
 * and a surface you want to project your Processing sketch onto.
 *
 * Simply drag the corners of the CornerPinSurface so that they
 * match the physical surface's corners. The result will be an
 * undistorted projection, regardless of projector position or 
 * orientation.
 *
 * You can also create more tharn one Surface object, and project
 * onto multiple flat surfaces using a single projector.
 *
 * This extra flexbility can comes at the sacrifice of more or 
 * less pixel resolution, depending on your projector and how
 * many surfaces you want to map. 
 */

Keystone ks; // the Keystone object
int numSurfaces = 9;
CornerPinSurface [] surfaces = new CornerPinSurface [numSurfaces]; //  surface array
int numMovies = 2;

PGraphics [] offscreenBuffers = new PGraphics [numSurfaces]; // offscreen buffer one
Movie [] mov = new Movie[numMovies];
MidiBus myBus; // The MidiBus
PImage frame;
// this is just for having something on the surfaces
int x = 0;
int y = 150;
int animation = 0;
float scale = 1;
int val = -1;
long time;
int speed = 6;
float value = 0.0;
boolean test = true;


void setup() {
  fullScreen(P3D, 2);
  // Keystone will only work with P3D or OPENGL renderers, 
  // since it relies on texture mapping to deform
  //size(1024, 768, P3D);
  myBus = new MidiBus(this, "LoopBe Internal MIDI", "Real Time Sequencer"); // Create a new MidiBus using the device names to select the Midi input and output devices respectively.
  time = millis();
  ks = new Keystone(this); // init the Keystone library
  for (int i = 0; i < numSurfaces; i++)
    surfaces[i] = ks.createCornerPinSurface(400, 300, 20); // create the first surface
  // We need an offscreen buffer to draw the surface we
  // want projected
  // note that we're matching the resolution of the
  // CornerPinSurface.
  // (The offscreen buffer can be P2D or P3D)
  for (int i = 0; i < numSurfaces; i++)
    offscreenBuffers[i] = createGraphics(400, 300, P2D);
    
    
   mov[0] = new Movie(this, 2+".mp4");
   mov[0].play();
    
 /* for (int i=0; i<numMovies; i++){
    String file = i + ".mp4";
    mov[i] = new Movie(this, file);
    mov[i].play();
  }*/
}
void draw() {
  background(0);   

  for (int i = 0; i < numSurfaces; i++) {

    offscreenBuffers[i].beginDraw();
    if (test) {
      offscreenBuffers[i].background(i*255.0/9, i*127.0/9, 255);
      offscreenBuffers[i].textSize(100);
      offscreenBuffers[i].text(i, 150, 200l);       
    } else {
      
      if (mov[animation].available()) {
        mov[animation].read();
        if (mov[animation].time() > mov[animation].duration() - 0.1)
          mov[animation].jump(0);
      }

      offscreenBuffers[i].image(mov[animation], 0, 0);
      
    }

    offscreenBuffers[i].endDraw();
  }
  for (int i = 0; i < numSurfaces; i++)  
    surfaces[i].render(offscreenBuffers[i]);
}

void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layoutcc
    ks.save();
    break;

  case 't':
    test = !test;
    break;


  case 'x':
    animation = (animation + 1) % numMovies;
    break;
  }
}

void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
  println(animation);
  if (pitch == 40 || pitch == 36) {
    animation = 0;
    if (animation == 0) {
      speed = 0;
      long temp = millis();
      while (millis() - temp < 100) {
      }
      speed = 6;
    } else if (pitch == 36) {
      animation = (animation + 1)%numMovies;
    }
  } else if (pitch == 38) {
    animation = 1;
    scale= 1;
  } else if (pitch != 42) {
    animation = 2;
    value = velocity/127.0;
  }
}

void noteOff(int channel, int pitch, int velocity) {
  // Receive a noteOff
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}

void controllerChange(int channel, int number, int value) {
  // Receive a controllerChange
  println();
  println("Controller Change:");
  println("--------");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+value);
}

void delay(int time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}
