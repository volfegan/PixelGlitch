// Modified from Daniel Shiffman
// Code from: https://youtu.be/JUDYkxU6J0o

PImage img;
PImage sorted;
int index = 0;
int width = 0;
int height = 0;


//options
//select how to sort the pixels by hue or brightness (select on and comment the other)
String sortPixelMethod = "hue";
//String sortPixelMethod = "brightness";

//used to control speed of sorting process
int multiStep = 200;



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
  //img = loadImage("sunflower400.jpg");
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
  textSize(18);
  sorted = createImage(img.width, img.height, HSB);
  sorted = img.get();
}

void draw() {
  //show frame rate and current index/pixels size
  println("Selection sort: " + String.format("%.2f", frameRate) + "frameRate\t " 
  + index + "/" + sorted.pixels.length);

  sorted.loadPixels();

  //multiStep during each loop for faster sort
  for (int n = 0; n < multiStep; n++) {
  
  
    //broken Selection sort!
    float record = -1;
    int selectedPixel = index;
    for (int j = index+1; j < sorted.pixels.length; j++) {
      color pix = sorted.pixels[j];
      
      //sort either by hue or brightness;
      float pixValue = 0;
      if (sortPixelMethod.equals("brightness")) pixValue = brightness(pix);
      else if (sortPixelMethod.equals("hue")) pixValue = hue(pix);
      
      if (pixValue > record) {
        selectedPixel = j;
        record = pixValue;
      }

      // Swap selectedPixel with i
      color temp = sorted.pixels[index];
      sorted.pixels[index] = sorted.pixels[selectedPixel];
      sorted.pixels[selectedPixel] = temp;
    } //<=since the swap part is still inside the for j loop, this will be incomplete
    // sorted and look glitched
    
    if (index < sorted.pixels.length -1) {
      index++;
    } else {
      noLoop();
      save(filename+"_PixelsGlitchBy_"+sortPixelMethod+".jpg");
      println("pixels glitch sorting complete");
    }
  }


  sorted.updatePixels();

  background(0);
  //image(img, width, 0);
  image(sorted, 0, 0);
  //Show framerate on display
  if (sorted.pixels.length - index > multiStep+1) {
    text("Selection sort: " + String.format("%.2f", frameRate) + 
    " frameRate / steps: " + (sorted.pixels.length - index) + " / glitch by " + sortPixelMethod, 0, 18);
  }
}
