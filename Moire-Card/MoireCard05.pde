////////////////////////////////////////////////////
//
// Moiré Card by Karl D.D. Willis.
//
// This source code is released under the GNU General Public License
// Copyright © 2012 Karl D.D. Willis. 
// Please see the 'COPYING' file for the full license.
//
// INSTRUCTIONS
// + Add your images to the data folder
// + List their names in the files array
// + Choose a slitSize
// + Run
// + Left/right keys move the mask
// + Space key exports the card to the sketch folder
//
////////////////////////////////////////////////////

import processing.pdf.*;


// Business card size (3.5" x 2") at 300 dpi
int cardWidth = 1050;
int cardHeight = 600;

// Size of the slits when slicing the image and creating the mask
// This needs to be a multiple of the cardWidth
int slitSize = 5; 
float slitSizeSlant = slitSize * sqrt(2);
float slitOffset = 1.0 * slitSizeSlant + 1.95;

// The input images
// Three are used here but it can be more
String[] files = {
  "01.png", 
  "02.png", 
  "03.png"
};

PImage[] images = new PImage[files.length];
// The cut up image
PImage backgroundImage; 
boolean record = false;



void setup() {
  size(1050, 600);
  backgroundImage = createBackgroundImage();
}

void draw() {

  image(backgroundImage, 0, 0);

  if (record) {
    beginRecord(PDF, "foreground.pdf"); 
  }

  pushMatrix();  
  translate(slitOffset, 0);
  drawForeground();

  popMatrix();
  
  if (record) {
    endRecord();
    record = false;
  }
}

/* Draw the foreground mask */
void drawForeground() {

  int repeat = (cardWidth / slitSize)  / files.length+1;
  repeat *= 1.25;

  noStroke();
  fill(0);

  float x = 0;
  float maskWidth = slitSize * (files.length-1);
  for (int i=0; i<repeat; i++) {  
    pushMatrix();
    translate(x, 0); 
    rotate(HALF_PI*0.5);    
    rect(0, -10, maskWidth, height*1.5);    
    x += slitSizeSlant * (files.length);
    popMatrix();
  }
}

/* Create and return the cut up background image */
PImage createBackgroundImage() {

  for (int i=0; i<images.length; i++) {
    images[i] = loadImage(files[i]);
  }

  PImage moireImage = createImage(images[0].width, images[0].height, RGB);

  int count = 0;
  int xStep = 0;

  for (int y=0; y<moireImage.height; y++) {
    for (int x=0; x<moireImage.width; x++) {

      int index = (int)((x + xStep) / slitSizeSlant) % images.length;
      moireImage.pixels[count] = images[index].pixels[count];
      count++;
      
    }
    xStep = y;
  }

  moireImage.updatePixels();
  return  moireImage;
}


/* Export the background image */
void exportCard() {
 backgroundImage.save("background.png");
 record = true;
}

void keyPressed() {
  if (keyCode == RIGHT) {
    slitOffset += slitSizeSlant;
  } 
  else if (keyCode == LEFT) {
    slitOffset -= slitSizeSlant;
  }
   else if (key == ' ') {
     exportCard();
   }
}