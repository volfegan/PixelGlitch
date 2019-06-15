//https://gist.github.com/KrabCode/6fe0048fb471b099563dac857b53aa32
import java.util.UUID;

PImage src;
PImage partial; //used to replace thumbnail image with correct section of the img
PGraphics img;
int width = 0;
int height = 0;
int alpha = 0;
boolean reset = false;
boolean pause = false;
PVector[] directions;


boolean showBothIMGs = false; //to show both imgs or only sorted img. Press 'i' for on|off


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
    if (pos != -1) filename = filename.substring(0, pos); //remove extension
    println("File selected " + filepath);
    // load file here
    src = loadImage(filepath);
  }
}

void interrupt() { 
  while (src==null) delay(200);
}

public void settings() {
  selectInput("Select an image file to process:", "fileSelected");
  interrupt(); //interrupt process until img is selected

  //for testing
  //src = loadImage("sunflower400.jpg");
  //src = loadImage("Colorful1.jpg");
  //src = loadImage("https://picsum.photos/800/800.jpg");
  width = src.width;
  height = src.height;

  //the canvas window size will be according to the img size
  //if the img is bigger, it will be resized to 80% of display
  if (width > displayWidth) {
    float resizer = width / (displayWidth * 0.8);
    width = (int)((float)displayWidth * 0.8);
    height = (int)((float)height / resizer); 
    src.resize(width, height);
  }
  if (height > displayHeight) {
    float resizer = height / (displayHeight * 0.8);
    height = (int)((float)displayHeight * 0.8);
    width = (int)((float)width / resizer);
    src.resize(width, height);
  }
  size(width, height);
}

public void setup() {
  //initial canvas size is set on settings
  textSize(18);

  directions = new PVector[8];
  directions[0] = new PVector(1, 0);
  directions[1] = new PVector(1, -1);
  directions[2] = new PVector(0, -1);
  directions[3] = new PVector(-1, -1);
  directions[4] = new PVector(-1, 0);
  directions[5] = new PVector(-1, 1);
  directions[6] = new PVector(0, 1);
  directions[7] = new PVector(1, 1);

  background(0);
  image(src, 0, 0);
  //get the 20% corner of the image 
  partial = src.get(0, round(0.8* src.height), round(0.2* src.width), round(0.2* src.height));

  img = createGraphics(width, height);
}

public void draw() {
  //show frame rate
  println("FrameRate = " +String.format("%.2f", frameRate));

  float t = radians(frameCount);
  float scl = .002f;
  loadPixels();
  img.beginDraw();
  img.loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      if (nearEdge(x, y)) {
        continue;
      }
      int here = get(x, y);
      float angle = 2 * TWO_PI * noise(x * scl, y * scl, t);
      angle = abs(angle % TWO_PI);
      int i = floor(map(angle, 0, TWO_PI, 0, 8));
      i = constrain(i, 0, 7);
      PVector dir = directions[i];
      int thereX = x + (int) dir.x;
      int thereY = y + (int) dir.y;
      int there = get(thereX, thereY);
      if (here > there) {
        put(here, thereX, thereY);
        put(there, x, y);
      } else {
        put(here, x, y);
        put(there, thereX, thereY);
      }
    }
  }
  img.updatePixels();
  img.endDraw();
  image(img, 0, 0);

  //show original img 20% in the corner
  if (showBothIMGs) {
    tint(255, 150);  // Apply transparency without changing color
    image(src, 0, 0.8* src.height, 0.2* src.width, 0.2* src.height);
    noTint();
  }

  if (reset) reset();

}

private void reset() {

  tint(255, alpha);  // Apply transparency without changing color
  image(src, 0, 0, src.width, src.height);
  noTint();
  if (alpha < 100) alpha += 10;
  else if (alpha >= 100 && alpha < 150) alpha += 25;
  else if (alpha >= 150 && alpha <= 255) alpha += 50;
  else if (alpha > 255) alpha = 255;
  if (reset && alpha == 255) {
    alpha = 0;
    partial = src.get(0, round(0.8* src.height), round(0.2* src.width), round(0.2* src.height));
    image(src, 0, 0, src.width, src.height);
    reset = false;
  }
}

public void keyPressed() {
  //save image
  if (key == 'k') {
    save("/capture/"+filename+"_" + UUID.randomUUID().toString() + ".jpg");
  }
  //reset to original img
  if (key == 'r') {
    reset = true;
  }
  //pause animation
  if (key == 'p') {
    if (pause) {
      loop();
      pause = false;
    } else {
      noLoop();
      pause = true;
    }
  }
  //show both images
  if (key == 'i') {
    if (showBothIMGs) { 
      showBothIMGs = false;
      //replace the thumbnail img with previous copied section
      image(partial, 0, 0.8* src.height, 0.2* src.width, 0.2* src.height);
    } else {
      //copy the covered part of img before applying the thumbnail 
      partial = get(0, round(0.8* src.height), round(0.2* src.width), round(0.2* src.height));
      showBothIMGs = true;
    }
  }
}

private boolean nearEdge(int x, int y) {
  return (x - 1 <= 0 || x + 1 >= width || y - 1 <= 0 || y + 1 >= height);
}

void put(int c, int x, int y) {
  img.pixels[y * width + x] = c;
}

public float getRed(int c) {
  return c >> 16 & 0xFF;
}

public float getGreen(int c) {
  return c >> 8 & 0xFF;
}

public float getBlue(int c) {
  return c & 0xFF;
}

public int get(int x, int y) {
  return pixels[y * width + x];
}
