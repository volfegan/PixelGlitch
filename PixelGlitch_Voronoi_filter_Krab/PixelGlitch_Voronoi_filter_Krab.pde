//Original code at:
//https://gist.github.com/KrabCode/d7f2c6c938e1acd2320062a3f842d3f7

import java.util.UUID;
import java.util.TreeSet;

//Options
boolean lessChecking = false; //increase speed animation by checking only half the pixel, but pixelates
boolean useQuadtree = true;
boolean showQuadtree = false; //show Quadtree structure and mouse hover can scan the voronoi points 
//useQuadtree MUST be true to show Quadtree 
boolean showBothIMGs = true; //to show both sources or only sorted source. Press 'i' for on|off
int div = 15; // Divides the screen in a small rectangle to search points using Quadtree
/*The more points, the more we can divide the screen to increase performance, but this only work 
 to a point where the search sector is big enough to intersect a few quadree sectors.
 */
boolean showFrameRate = true;
boolean showOriginalsource = true; //allows to show original image for 2s at the start of animation
//How many points to create Voronoi stuff
int pointCount = 500; //original = 500 (number of voronoi cells)
private int framesToCapture = 1; // to make gifs, original = 300


Quadtree qtree;
int countChecks = 0; //counts how many checks is necessary to find the closest voronoi point
ArrayList<P> ps = new ArrayList<P>();
PImage source;
private float t;
private int captureStart = -1;
String id = "";
boolean pause = false;


public void keyPressed() {
  if (key == 'k') {
    //saveFrame("capture/####.jpg");
    id = UUID.randomUUID().toString();
    captureStart = frameCount+1;
  }
  if (key == '+') {
    if (div < 50) {
      div++;
    }
  }
  if (key == '-') {
    if (div > 10) {
      div--;
    }
  }
  //Perform less checking on pixels to find Voronoi point, but pixelates
  if (key == 'c') {
    if (lessChecking) {
      lessChecking = false;
    } else {
      lessChecking = true;
    }
  }
  if (key == 's') {
    if (showQuadtree) {
      showQuadtree = false;
    } else {
      showQuadtree = true;
    }
  }
  if (key == 'q') {
    if (useQuadtree) {
      useQuadtree = false;
    } else {
      useQuadtree = true;
    }
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
  //show/hide frame rate
  if (key == 'f') {
    if (showFrameRate) {
      showFrameRate = false;
    } else {
      showFrameRate = true;
    }
  }
  //show/hide both images
  if (key == 'i') {
    if (showBothIMGs) { 
      showBothIMGs = false;
    } else {
      showBothIMGs = true;
    }
  }
}

String filename;
//there is no file validation, so any non-source selected will crash the program
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
    source = loadImage(filepath);
  }
}

void interrupt() { 
  while (source==null) delay(200);
}

public void settings() {
  selectInput("Select an image file to process:", "fileSelected");
  interrupt(); //interrupt process until source is selected

  //for testing
  //source = loadImage("sunflower400.jpg");
  //source = loadImage("https://picsum.photos/600/600.jpg");
  width = source.width;
  height = source.height;
  //the canvas window size will be according to the source size
  //if the source is bigger, it will be resized to 80% of display
  if (width > displayWidth) {
    float resizer = width / (displayWidth * 0.8);
    width = (int)((float)displayWidth * 0.8);
    height = (int)((float)height / resizer); 
    source.resize(width, height);
  }
  if (height > displayHeight) {
    float resizer = height / (displayHeight * 0.8);
    height = (int)((float)displayHeight * 0.8);
    width = (int)((float)width / resizer);
    source.resize(width, height);
  }
  size(width, height);
}

public void setup() {
  textSize(18);
  background(0);
  while (ps.size() < pointCount) {
    ps.add(new P());
  }

  if (useQuadtree) {
    //Create the Quadtree AND insert/reference the voronoi P point
    Rectangle boundary =new Rectangle (width/2, height/2, width/2, height/2);
    qtree = new Quadtree (boundary, 4);
    for (P p : ps) {
      Point point = new Point (p.pos.x, p.pos.y, p);
      qtree.insert(point);
    }
  }
  //show Original source
  background(0);
  image(source, 0, 0);
  //voronoiFilter();
}

public void draw() {
  //show frame rate and current step size
  println("FrameRate: " +String.format("%.2f", frameRate) + " Div = "+div+"\tCounting checks: " + countChecks);
  countChecks = 0;

  if (showOriginalsource) {
    delay(2000);
    showOriginalsource = false;
  }

  if (useQuadtree) {
    //Create the Quadtree AND insert/reference the voronoi P point
    Rectangle boundary =new Rectangle (width/2, height/2, width/2, height/2);
    qtree = new Quadtree (boundary, 4);
    for (P p : ps) {
      Point point = new Point (p.pos.x, p.pos.y, p);
      qtree.insert(point);
    }
  }

  t = map(frameCount, 0, framesToCapture, 0, TWO_PI);
  for (P p : ps) {
    p.myPixels.clear();
    p.update();
  }
  voronoiFilter();
  if (captureStart > 0 && frameCount > captureStart && frameCount <= captureStart + framesToCapture) {
    println((frameCount - captureStart) + " / " + framesToCapture);
    saveFrame("capture/"+id+"/####.jpg");
  }


  if (useQuadtree && showQuadtree) {
    //show Quadtree structure and Voronoi points with mouse
    double rangeWidth = width/div;
    double rangeHeight = height/div;
    Rectangle range = new Rectangle (mouseX, mouseY, rangeWidth, rangeHeight);
    TreeSet<Point> points = qtree.query(range);

    rectMode(CENTER);
    rect((float)range.x, (float) range.y, (float) range.width * 2, (float)range.height * 2);
    for (Point p : points) {
      strokeWeight(4);
      stroke(0);
      point((float)p.getData().pos.x, (float)p.getData().pos.y);
    }
    qtree.show();
  }
  //Show framerate on display
  if (showFrameRate) 
    text("FrameRate=" +String.format("%.1f", frameRate) + " / Voronoi="+pointCount+
    " / Divider="+div+" / Checks=" + countChecks, 5, 18);


  if (showBothIMGs) {
    tint(255, 190);  // Apply transparency without changing color
    image(source, 0, 0.8* source.height, 0.2* source.width, 0.2* source.height);
    noTint();
  }
}

public P findNearestPoint(int x, int y) {
  P result = null;
  float smallestDistanceFound = width;

  if (useQuadtree) {
    //Finding the points in a retangular range of 1/div width 1/div height using the Quadtree
    double rangeWidth = width/div;
    double rangeHeight = height/div;
    Rectangle range = new Rectangle ((double)x, (double)y, rangeWidth, rangeHeight);
    TreeSet<Point> points = qtree.query(range);

    for (Point point : points) {
      P p = point.getData();
      countChecks++;
      float d = dist(p.pos.x, p.pos.y, x, y);
      if (d < smallestDistanceFound) {
        smallestDistanceFound = d;
        result = p;
      }
    }
  }
  //Checking without using Quadtree (or in case of qtree fail to find points)
  if (result == null) {
    for (P p : ps) {
      countChecks++;
      float d = dist(p.pos.x, p.pos.y, x, y);
      if (d < smallestDistanceFound) {
        smallestDistanceFound = d;
        result = p;
      }
    }
  }
  return result;
}

private void voronoiFilter() {
  image(source, 0, 0, width, height);
  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      P nearest = findNearestPoint(x, y);
      nearest.myPixels.add(new PVector(x, y));

      if (lessChecking) {
        //To increase the animation rate, the x and y loop to increase x+=2 and y+=2
        //But that will make the structure pixelated
        if (x>1 && y>1) {
          nearest.myPixels.add(new PVector(x-1, y));
          nearest.myPixels.add(new PVector(x, y-1));
          nearest.myPixels.add(new PVector(x-1, y-1));
        }
        y++;
      }
    }
    if (lessChecking) x++;
  }
  for (P p : ps) {
    int count = p.myPixels.size();
    int r = 0;
    int g = 0;
    int b = 0;
    for (PVector px : p.myPixels) {
      int c = pixels[floor(px.x) + floor(px.y) * width];
      r += c >> 16 & 0xFF;
      g += c >> 8 & 0xFF;
      b += c & 0xFF;
    }
    int averageColor = 0;
    if (count > 0) {
      averageColor = color(r / count, g / count, b / count);
    }
    for (PVector px : p.myPixels) {
      pixels[floor(px.x) + floor(px.y) * width] = color(averageColor);
    }
  }
  updatePixels();
  filter(BLUR, .5f);
}

class P {
  PVector origPos = new PVector(random(width), random(height));
  PVector pos = new PVector(origPos.x, origPos.y);
  ArrayList<PVector> myPixels = new ArrayList<PVector>();

  public void update() {
    //simplex noise implementation: https://github.com/SRombauts/SimplexNoise/blob/master/references/SimplexNoise.java
    pos.x = (float) (origPos.x + 5 * (1-2*SimplexNoise.noise(origPos.x, cos(t), sin(t))));
    pos.y = (float) (origPos.y + 5 * (1-2*SimplexNoise.noise(origPos.y, cos(t), sin(t))));
  }
}
