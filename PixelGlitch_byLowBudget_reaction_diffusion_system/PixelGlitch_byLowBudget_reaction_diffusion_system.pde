//author Volfegan: https://twitter.com/VolfeganGeist
//resources:
//threshold filter https://processing.org/tutorials/pixels/
//low-pass filter (Blur) https://processing.org/examples/blur.html
//high-pass filter (Sharpening)  https://processing.org/examples/edgedetection.html

import java.util.UUID;

PImage img;
PImage sortedPixels; //image processed
int width = 0;
int height = 0;
int step = 0;
float time=0;
boolean showBothIMGs = false; //show both the original image as a thumbnail
boolean overlayBothIMGs = false; //show both the original image overlay in the processed image
boolean showTitleTxt = true;
boolean saveImg = false;
boolean pause = true;
boolean showOriginalImageAtStart = true;

//used to control speed of the process
int multiStep = 1; //use: '+' or '-' to control the speed

public void keyPressed() {
  if (key == 'i') {
    if (showBothIMGs) {
      showBothIMGs = false; //show the original image in the corner
    } else {
      showBothIMGs = true;
      overlayBothIMGs = false;
    }
  }
  if (key == 'o') {
    if (overlayBothIMGs) {
      overlayBothIMGs = false; //show both the original image overlay in the processed image
    } else {
      overlayBothIMGs = true;
      showBothIMGs = false;
    }
  }
  if (key == 'p') {
    if (pause == false) pause=true;
    else pause = false;
  }
  if (key == 's') {
    saveImg = true; //snapshot of the image
  }
  if (key == 't') {
    if (showTitleTxt == false) showTitleTxt=true;
    else showTitleTxt = false;
  }
  if (key == '+') {
    if (multiStep<=3) multiStep++;
  }
  if (key == '-') {
    if (multiStep>1) multiStep--;
  }
}

String filename;
//there is no file validation, so any non-img selected will crash the program
void fileSelected(File selection) {
  if (selection == null) {
    println("No image file selected.");
    exit();
  } else {
    String filepath = selection.getAbsolutePath();
    filename = selection.getName();
    int pos = filename.lastIndexOf(".");
    if (pos != -1) filename = filename.substring(0, pos);
    println("File selected " + filepath);
    // load file here
    img = loadImage(filepath);
  }
}

void interrupt() { 
  while (img==null) delay(200);
}

void settings() {
  selectInput("Select an image file to process:", "fileSelected");
  interrupt(); //interrupt process until img is selected

  //for testing
  //img = loadImage("test.jpg");
  width = img.width;
  height = img.height;

  if (width > 1920) {
    int resizer = width / 1200;
    width = 1200;
    height = height / resizer; 
    img.resize(width, height);
  }
  if (height > 1080) {
    int resizer = height / 900;
    height = 900;
    width = width / resizer;
    img.resize(width, height);
  }

  //the canvas window size will be according to the img size
  size(width, height);
}

void setup() {
  fill(0);
  noStroke();
  textSize(16);
  // Create an opaque image of the same size as the original
  sortedPixels = createImage(img.width, img.height, RGB);
  sortedPixels = img.get();

  time = millis();
}

void draw() {
  step++;
  step %= 6;

  if (millis() > time + 2000 && showOriginalImageAtStart) {
    //show the orginal image for  2s
    pause = false;
    showOriginalImageAtStart = false;
  }

  if (!pause) {
    for (int repeat=0; repeat < multiStep; repeat++) {

      //1.High Pass (Sharpening)
      if (step >= 0 && step < round(random(.5, 2.5))) {
        sortedPixels = highPassFilter(sortedPixels);
      }

      //2.Threshold
      if (step >= 2 && step < 4) {
        sortedPixels = thresholdFilter(sortedPixels, random(.48, .59));
        //sortedPixels = thresholdFilter(sortedPixels, .9);
      }

      //3.Blur
      if (step >= round(random(2.5, 4))) {
        sortedPixels = lowPassFilter(sortedPixels);
      }

      //remove aberration on edges by painting the edges with white
      sortedPixels.loadPixels();
      for (int y = 0; y < sortedPixels.height-1; y++) {
        for (int x = 0; x < sortedPixels.width-1; x++) {
          if (x<=8 || y<=8 || x>=sortedPixels.width-8 || y>=sortedPixels.height-8) {
            sortedPixels.pixels[y*sortedPixels.width + x] = color(255);
          }
        }
      }
      sortedPixels.updatePixels();
    }
  }

  background(0);
  if (showBothIMGs) {
    image(sortedPixels, 0, 0);
    //original img 20% in the corner
    if (saveImg == false) {
      tint(255, 190);  // Apply transparency without changing color
      image(img, 0, 0.8* img.height, 0.2* img.width, 0.2* img.height);
      noTint();
    }
  } else if(overlayBothIMGs) {
    image(sortedPixels, 0, 0);
    //overlay the original img into the processed image
    if (saveImg == false) {
      tint(255, 120);  // Apply transparency without changing color
      image(img, 0, 0);
      noTint();
    }
  } else {
    image(sortedPixels, 0, 0);
  }

  //show frame rate and title
  println("Reaction Diffusion System by: 1.High Pass 2.Threshold 3.Blur _>" +
    String.format("%.2f", frameRate) + "frameRate");

  //Show framerate on display
  if (saveImg == false) {
    if (showTitleTxt) {
      fill(0, 120);
      rectMode(CORNERS);
      rect(5, 10, 670, 35);
      fill(-1);
      text("Reaction Diffusion System by: 1.High Pass 2.Threshold 3.Blur _>"+
        String.format("%.2f", frameRate) + " frameRate", 20, 30);
    }
  } else {
    //save the image with a random id
    save("reaction_diffusion_"+UUID.randomUUID().toString().replace("-", "")+".png");
    saveImg = false;
  }
}

//return a threshold brightness PImage by a level parameter. The parameter = [0.0 (black) ~ 1.0 (white)]
public PImage thresholdFilter(PImage image, float parameter) {
  if (parameter > 1 || parameter < 0) return null;

  float threshold = 255*parameter;

  // We are going to look at both image's pixels
  image.loadPixels();
  // Create an opaque image of the same size as the original
  PImage processedImg = createImage(image.width, image.height, RGB);
  processedImg.loadPixels();

  for (int x = 0; x < image.width-1; x++) {
    for (int y = 0; y < image.height-1; y++ ) {
      int loc = x + y*image.width;
      // Test the brightness against the threshold
      if (brightness(image.pixels[loc]) > threshold) {
        processedImg.pixels[loc] = color(255);  // White
      } else {
        processedImg.pixels[loc] = color(0);    // Black
      }
    }
  }
  // State that there are changes to processedImg.pixels[]
  processedImg.updatePixels();
  return processedImg;
}

//return a sharp edge PImage 
public PImage highPassFilter(PImage image) {
  //high-pass matrix
  float[][] kernel = {
    { -1, -1, -1}, 
    { -1, 9, -1}, 
    { -1, -1, -1}};
  image.loadPixels();
  // Create an opaque image of the same size as the original
  PImage processedImg = createImage(image.width, image.height, RGB);
  // Loop through every pixel in the image.
  for (int y = 0; y < image.height-1; y++) {
    for (int x = 0; x < image.width-1; x++) {

      //Skip left and right, top and bottom edges to avoid aberations
      if (x==0 || y==0 || x==image.width-1 || y==image.height-1) continue;

      float sum = 0; // Kernel sum for this pixel
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          // Calculate the adjacent pixel for this kernel point
          int pos = (y + ky)*image.width + (x + kx);
          // Image is grayscale, red/green/blue are identical
          float val = red(image.pixels[pos]);
          // Multiply adjacent pixels based on the kernel values
          sum += kernel[ky+1][kx+1] * val;
        }
      }
      // For this pixel in the new image, set the gray value
      // based on the sum from the kernel
      processedImg.pixels[y*image.width + x] = color(sum, sum, sum);
    }
  }
  // State that there are changes to processedImg.pixels[]
  processedImg.updatePixels();
  return processedImg;
}

//return a blur PImage
public PImage lowPassFilter(PImage image) {
  //low-pass matrix
  //float v = 1.0 / 9; //original blur value
  float v = 1.0 / random(9.0, 9.21); //for better diffusion
  float[][] kernel = {
    {v, v, v}, 
    {v, v, v}, 
    {v, v, v}};
  image.loadPixels();
  // Create an opaque image of the same size as the original
  PImage processedImg = createImage(image.width, image.height, RGB);
  for (int y = 0; y < image.height-1; y++) {
    for (int x = 0; x < image.width-1; x++) {

      //Skip left and right, top and bottom edges to avoid aberations
      if (x==0 || y==0 || x==image.width-1 || y==image.height-1) continue;

      float sum = 0; // Kernel sum for this pixel
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          // Calculate the adjacent pixel for this kernel point
          int pos = (y + ky)*image.width + (x + kx);
          // Image is grayscale, red/green/blue are identical
          float val = red(image.pixels[pos]);
          // Multiply adjacent pixels based on the kernel values
          sum += kernel[ky+1][kx+1] * val;
        }
      }
      // For this pixel in the new image, set the gray value
      // based on the sum from the kernel
      processedImg.pixels[y*image.width + x] = color(sum);
    }
  }
  // State that there are changes to processedImg.pixels[]
  processedImg.updatePixels();
  return processedImg;
}
