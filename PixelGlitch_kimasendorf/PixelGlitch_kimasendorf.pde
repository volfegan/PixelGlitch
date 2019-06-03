//based on: https://github.com/kimasendorf/ASDFPixelSort

//options
//mode = sortPixelMethod-> 0: getFirstNotBlackX; 1: getFirstBrightX (brightness; 2: getFirstNotWhiteX
int mode = 3; //any number above 2 will be replace randomly by 0|1|2

// threshold values to determine sorting start and end pixels
int blackValue = -16000000; //original -16000000
int brightnessValue = 60; //original 60
int whiteValue = -13000000; //original -13000000

/* Direction of the glitch:
 * 0: 2x pass -> vertical + horizontal
 * 1: 2x pass -> horizontal + vertical
 * 2: 1x pass -> horizontal
 * 3: 1x pass -> vertical
 */
int glitch = 4; //any number above 3 will be replace randomly by 0|1|2|3
//used to control speed of sorting process.
int multiStep = 10;



PImage img;
int loops = 0;
int row = 0;
int column = 0;
boolean loopRow = true;
boolean loopColumn = false;
String filename;
String[] glitchMode = new String[] {"V+H", "H+V", "H", "V"};
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
  //img = loadImage("https://picsum.photos/800/800.jpg"); //random from internet
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
  size(width, height);
}
void setup() {
  //initial canvas size is set on settings
  textSize(18);

  if (mode > 2) mode = round(random(2)); //to avoid freezing, mode = 0|1|2
  if (glitch > 3) glitch = round(random(3)); //to avoid error, glitch = 0|1|2|3

  //horizontal or vertical glitch
  if (glitch == 0) {
    //vertical+horizontal
    loopRow = false;
    loopColumn = true;
  } else if (glitch == 1) {
    //horizontal+vertical
    loopRow = true;
    loopColumn = false;
  } else if (glitch == 2) {
    //horizontal only
    column = img.width-1;
    loopRow = true;
    loopColumn = false;
  } else if (glitch == 3) {
    //vertical only
    row = img.height-1;
    loopRow = false;
    loopColumn = true;
  }


  // load image into display
  background(0);
  image(img, 0, 0);
}


void draw() {

  if (loops == 0) { 
    delay(3000); //to have time to show the original img
    loops++;
  }

  //multiStep during each loop for faster sort
  for (int n = 0; n < multiStep; n++) {

    // loop through columns
    if (column < img.width-1 && loopColumn) {
      img.loadPixels(); 
      sortColumn();
      column++;
      img.updatePixels();

      if (column >= img.width-1) {
        loopRow = true;
      }
    }
    if (row > img.height-1) loopRow = false;

    // loop through rows
    if (row < img.height-1 && loopRow) {
      img.loadPixels(); 
      sortRow();
      row++;
      img.updatePixels();
      if (row >= img.height-1) {
        loopColumn = true;
      }
    }
    if (column > img.width-1) loopColumn = false;
    //end multiStep
  }

  //show original and sorted imgs
  background(0);
  image(img, 0, 0);

  //show frame rate and current sorting step
  println("Sorting Row=" + row + " Column=" + column + " / "
    + String.format("%.2f", frameRate) 
    + " frameRate / Glitch " + glitchMode[glitch] + " / SortMode = " + mode);

  //Show framerate on display || END
  if (column < img.width-1 || row < img.height-1) {
    text("Pixel Sorting: Row = "+ row + " / Column = " + column + " / "
      + String.format("%.2f", frameRate) 
      + " frameRate / Glitch " + glitchMode[glitch] + " SortMode = " + mode, 0, 18);
  } else {
    noLoop();
    //SAVE IMG
    save(filename+"_PixelGlitch_ASDF_SortMode"+mode+glitchMode[glitch]+".jpg");

    println("Saved "+filename+"_PixelGlitch_ASDF_SortMode"+mode+glitchMode[glitch]+".jpg");
  }
}

void keyPressed() {
  if (key == ESC) System.exit(0);
}

void sortRow() {
  // current row
  int y = row;

  // where to start sorting
  int x = 0;

  // where to stop sorting
  int xend = 0;

  while (xend < img.width-1) {
    switch(mode) {
    case 0:
      x = getFirstNotBlackX(x, y);
      xend = getNextBlackX(x, y);
      break;
    case 1:
      x = getFirstBrightX(x, y);
      xend = getNextDarkX(x, y);
      break;
    case 2:
      x = getFirstNotWhiteX(x, y);
      xend = getNextWhiteX(x, y);
      break;
    default:
      break;
    }

    if (x < 0) break;

    int sortLength = xend-x;

    color[] unsorted = new color[sortLength];
    color[] sorted = new color[sortLength];

    for (int i=0; i<sortLength; i++) {
      unsorted[i] = img.pixels[x + i + y * img.width];
    }

    sorted = sort(unsorted);

    for (int i=0; i<sortLength; i++) {
      img.pixels[x + i + y * img.width] = sorted[i];
    }

    x = xend+1;
  }
}


void sortColumn() {
  // current column
  int x = column;

  // where to start sorting
  int y = 0;

  // where to stop sorting
  int yend = 0;

  while (yend < img.height-1) {
    switch(mode) {
    case 0:
      y = getFirstNotBlackY(x, y);
      yend = getNextBlackY(x, y);
      break;
    case 1:
      y = getFirstBrightY(x, y);
      yend = getNextDarkY(x, y);
      break;
    case 2:
      y = getFirstNotWhiteY(x, y);
      yend = getNextWhiteY(x, y);
      break;
    default:
      break;
    }

    if (y < 0) break;

    int sortLength = yend-y;

    color[] unsorted = new color[sortLength];
    color[] sorted = new color[sortLength];

    for (int i=0; i<sortLength; i++) {
      unsorted[i] = img.pixels[x + (y+i) * img.width];
    }

    sorted = sort(unsorted);

    for (int i=0; i<sortLength; i++) {
      img.pixels[x + (y+i) * img.width] = sorted[i];
    }

    y = yend+1;
  }
}


// black x
int getFirstNotBlackX(int x, int y) {

  while (img.pixels[x + y * img.width] < blackValue) {
    x++;
    if (x >= img.width) 
      return -1;
  }

  return x;
}

int getNextBlackX(int x, int y) {
  x++;

  while (img.pixels[x + y * img.width] > blackValue) {
    x++;
    if (x >= img.width) 
      return img.width-1;
  }

  return x-1;
}

// brightness x
int getFirstBrightX(int x, int y) {

  while (brightness(img.pixels[x + y * img.width]) < brightnessValue) {
    x++;
    if (x >= img.width)
      return -1;
  }

  return x;
}

int getNextDarkX(int _x, int _y) {
  int x = _x+1;
  int y = _y;

  while (brightness(img.pixels[x + y * img.width]) > brightnessValue) {
    x++;
    if (x >= img.width) return img.width-1;
  }
  return x-1;
}

// white x
int getFirstNotWhiteX(int x, int y) {

  while (img.pixels[x + y * img.width] > whiteValue) {
    x++;
    if (x >= img.width) 
      return -1;
  }
  return x;
}

int getNextWhiteX(int x, int y) {
  x++;

  while (img.pixels[x + y * img.width] < whiteValue) {
    x++;
    if (x >= img.width) 
      return img.width-1;
  }
  return x-1;
}


// black y
int getFirstNotBlackY(int x, int y) {

  if (y < img.height) {
    while (img.pixels[x + y * img.width] < blackValue) {
      y++;
      if (y >= img.height)
        return -1;
    }
  }

  return y;
}

int getNextBlackY(int x, int y) {
  y++;

  if (y < img.height) {
    while (img.pixels[x + y * img.width] > blackValue) {
      y++;
      if (y >= img.height)
        return img.height-1;
    }
  }

  return y-1;
}

// brightness y
int getFirstBrightY(int x, int y) {

  if (y < img.height) {
    while (brightness(img.pixels[x + y * img.width]) < brightnessValue) {
      y++;
      if (y >= img.height)
        return -1;
    }
  }

  return y;
}

int getNextDarkY(int x, int y) {
  y++;

  if (y < img.height) {
    while (brightness(img.pixels[x + y * img.width]) > brightnessValue) {
      y++;
      if (y >= img.height)
        return img.height-1;
    }
  }
  return y-1;
}

// white y
int getFirstNotWhiteY(int x, int y) {

  if (y < img.height) {
    while (img.pixels[x + y * img.width] > whiteValue) {
      y++;
      if (y >= img.height)
        return -1;
    }
  }

  return y;
}

int getNextWhiteY(int x, int y) {
  y++;

  if (y < img.height) {
    while (img.pixels[x + y * img.width] < whiteValue) {
      y++;
      if (y >= img.height) 
        return img.height-1;
    }
  }

  return y-1;
}
