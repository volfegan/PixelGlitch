PImage img;
PImage sorted;
int steps = 0;
int width = 0;
int height = 0;


//options
int glitchLevel = 10; //[0, 1, 2, 3, ... 10] intensity of the glitch sorting pass
float glitch;
boolean showBothIMGs = false; //to show both imgs side by side, only sorted img
//select how to sort the pixels by hue or brightness (select on and comment the other)
String sortPixelMethod = "hue";
//String sortPixelMethod = "brightness";

//used to control speed of sorting process
int multiStep = 2000;



boolean started = false; //to mark if it started sorting
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
    //2 img side by side
    image(img, 0, 0);
    image(sorted, img.width, 0);
  } else {
    //original img 20% in the corner
    image(sorted, 0, 0);
    if (steps > multiStep+1) {
      tint(255, 130);  // Apply transparency without changing color
      image(img, 0, 0.8* img.height, 0.2* img.width, 0.2* img.height);
      noTint();
    }
  }

  if (glitchLevel < 10) {
    steps = sorted.pixels.length -1;
    if (glitchLevel > 0) glitch = (10-(glitchLevel*1.1))/10;
    else glitch = 0.98;
  } else {
    glitch = 0.999;
  }
}

void draw() {
  //show frame rate and current index/pixels size
  println("Heap sort: " + String.format("%.2f", frameRate) + "frameRate\t GlitchLevel: " + glitchLevel + " \t "
    + steps + "/" + sorted.pixels.length);

  sorted.loadPixels();

  //multiStep during each loop for faster sort
  for (int n = 0; n < multiStep; n++) {

    //Heap sort!
    if (steps == 0 && !started && glitchLevel >= 10) {
      started = true;
      //1st heapify pass
      for (int i = (sorted.pixels.length - 2)/2; i >= 0; i--) {
        heapify(sorted.pixels, i, sorted.pixels.length - 1);
      }
      steps = 0;
      
    } else if (steps != 0 && steps > (sorted.pixels.length - 1)*glitch) {
      exchangePixel(sorted.pixels, 0, steps);
      heapify(sorted.pixels, 0, steps - 1);
    }

    if (steps > 0) {
      steps--;
    } else {
      break;
    }
  }

  sorted.updatePixels();
  //show original and sorted imgs
  background(0);  
  if (showBothIMGs && 2 * img.width < displayWidth) {
    //2 img side by side
    image(img, 0, 0);
    image(sorted, img.width, 0);
  } else {
    //original img 20% in the corner
    image(sorted, 0, 0);
    if (steps > multiStep+1) {
      tint(255, 190);  // Apply transparency without changing color
      image(img, 0, 0.8* img.height, 0.2* img.width, 0.2* img.height);
      noTint();
    }
  }
  //SAVE IMG when finish
  if (steps == 0) {
    noLoop();
    save(filename+"_PixelsSortedBy_"+sortPixelMethod+"_L"+glitchLevel+".jpg");
    println("pixels sorting complete");
  }
  //Show framerate on display
  if (steps > multiStep+1) {
    text("Heap sort: " + String.format("%.2f", frameRate) + 
      " frameRate / steps: " + (steps) + " / GlitchLevel: " + glitchLevel + " / sort by " + sortPixelMethod, 0, 18);
  }
}

//http://www.algostructure.com/sorting/heapsort.php
void heapify(int[] array, int i, int m) {
  int j;
  while ( 2 * i + 1 <= m ) {
    j = 2 * i + 1;

    //sort either by hue or brightness;
    if ( j < m ) {
      if ( 
        (sortPixelMethod.equals("hue") && hue(array[ j ]) > hue(array[ j + 1 ]))
        || 
        (sortPixelMethod.equals("brightness") && brightness(array[ j ]) > brightness(array[ j + 1 ]))
        ) {
        j++;
      }
    }
    if (
      (sortPixelMethod.equals("hue") && hue(array[ i ]) > hue(array[ j ]))
      ||
      (sortPixelMethod.equals("brightness") && brightness(array[ i ]) > brightness(array[ j ]))
      ) {
      exchangePixel( array, i, j );
      i = j;
    } else i = m;
  }
}

void exchangePixel(int[] pixarray, int i, int j) {
  color temp = pixarray[i];
  pixarray[i] = pixarray[j];
  pixarray[j] = temp;
}
