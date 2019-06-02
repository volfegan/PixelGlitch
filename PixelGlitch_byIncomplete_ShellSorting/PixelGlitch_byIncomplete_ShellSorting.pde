import java.util.Queue;
import java.util.LinkedList;

PImage img;
PImage sorted;
PImage dummy; //copy of sorted.pixels and used to get each step of pixel sorting
int gap = 0;
int width = 0;
int height = 0;


int glitchLevel = 10; //[0, 1, 2, 3, ... ] intensity of the glitch sorting pass
int glitch; // the maximum gap size allowed to sort created by the glitch level
boolean showBothIMGs = false; //to show both imgs side by side, only sorted img
//select how to sort the pixels by hue or brightness
String sortPixelMethod = "hue";
//String sortPixelMethod = "brightness";


//used to control speed of sorting process
int multiStep = 1000;

//Create a queue stack to hold the exchanged pixel indexes & colours from the while loop dummy calls
Queue<int[]> stackcalls = new LinkedList();

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
  //img = loadImage("d.jpg");
  width = img.width;
  height = img.height;

  //the canvas window size will be according to the img size
  //if the img is bigger, it will be resized to 80% of display
  if (width > displayWidth) {
    float resizer = width / (displayWidth * 0.8);
    width = (int)((float)displayWidth * 0.8);
    height = (int)((float)height / resizer); 
    img.resize(width, height);
  }
  if (height > displayHeight) {
    float resizer = height / (displayHeight * 0.8);
    height = (int)((float)displayHeight * 0.8);
    width = (int)((float)width / resizer);
    img.resize(width, height);
  }


  //the canvas window size will be according to the img size
  if (showBothIMGs && 2 * img.width < displayWidth)
    width = img.width * 2; //show both original and sorted pics if display is big enough
  size(width, height);
}

void setup() {
  textSize(18);
  sorted = createImage(img.width, img.height, HSB);
  sorted = img.get();

  //show original and sorted imgs
  background(0);
  if (showBothIMGs && 2 * img.width < displayWidth) {
    image(img, 0, 0);
    image(sorted, img.width, 0);
  } else {
    image(sorted, 0, 0);
  }

  gap = sorted.pixels.length/2; //replaced on draw() --> for (int gap = arrayLength / 2; gap > 0; gap /= 2)
  //dummy image to be sorted and steps extracted to be recreated on draw loop
  dummy = createImage(img.width, img.height, HSB);
  dummy = img.get();
  
  glitch = Math.round((sorted.pixels.length-1)/(pow(2,glitchLevel)));
}

void draw() {
  //show frame rate and current gap/pixels size
  println("Shell sort: " +String.format("%.2f", frameRate) + "frameRate GlitchLevel: " + glitchLevel + 
  " \t gap: " + gap + " / steps: " + stackcalls.size());

  sorted.loadPixels();

  //just to have some time to show the img
  if (gap == sorted.pixels.length/2) {
    delay(2000);
  }

  //multiStep during each loop for faster sort
  for (int n = 0; n < multiStep; n++) {

    if (stackcalls.isEmpty()) {

      // Shell sort!
      //https://www.code2bits.com/shell-sort-algorithm-in-java/
      if (gap < glitch) break;
      
      for (int i = gap; i < dummy.pixels.length; i++) {
        color temp_pix = dummy.pixels[i];
        float tempValue = 0;

        int j = i;

        //sort either by hue or brightness;
        if (sortPixelMethod.equals("brightness")) {
          tempValue = brightness(temp_pix);

          while (j >= gap && brightness(dummy.pixels[j - gap]) < tempValue) {

            //we will call these pixels exchanges during the draw loop for the real sorted.pixels array
            stackcalls.add(new int[]{j, color(dummy.pixels[j - gap])});

            dummy.pixels[j] = dummy.pixels[j - gap];
            j -= gap;
          }
        } else if (sortPixelMethod.equals("hue")) {
          tempValue = hue(temp_pix);

          while (j >= gap && hue(dummy.pixels[j - gap]) < tempValue) {

            //we will call these pixels exchanges during the draw loop for the real sorted.pixels array
            stackcalls.add(new int[]{j, color(dummy.pixels[j - gap])});

            dummy.pixels[j] = dummy.pixels[j - gap];
            j -= gap;
          }
        }
        dummy.pixels[j] = temp_pix;
        //we will call these pixels exchanges during the draw loop for the real sorted.pixels array
        stackcalls.add(new int[]{j, temp_pix});
      }
      gap /= 2; //replaced --> for (int gap = arrayLength / 2; gap > 0; gap /= 2)
    } else {
      //use the stackcalls queue to do the pixel changes in the canvas display
      int[] pix = stackcalls.remove();
      int index = pix[0];
      color pixcolor = pix[1];
      sorted.pixels[index] = pixcolor;
    }
  }

  //show sorted pixels img so far
  sorted.updatePixels();
  //show original and sorted imgs
  background(0);
  if (showBothIMGs && 2 * img.width < displayWidth) {
    image(img, 0, 0);
    image(sorted, img.width, 0);
  } else {
    image(sorted, 0, 0);
    if (gap > glitch) {
      tint(255, 190);  // Apply transparency without changing color
      image(img, 0, 0.8* img.height, 0.2* img.width, 0.2* img.height);
      noTint();
    }
  }
  //Show framerate on display || SAVE
  if (!stackcalls.isEmpty()) {
    text("Shell sort: " + String.format("%.2f", frameRate) + 
      " frameRate / GlitchLevel: " + glitchLevel + " / gap: " + gap + 
      " / steps: "+ stackcalls.size() + " / sort by " + sortPixelMethod, 0, 18);
  } else if (gap <= glitch && stackcalls.isEmpty()) {
    noLoop();
    save(filename+"_PixelsSortedBy_"+sortPixelMethod+"_L"+glitchLevel+".jpg");
    println("pixels sorting complete");
  }
}
