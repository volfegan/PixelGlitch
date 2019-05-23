import java.util.Queue;
import java.util.LinkedList;

PImage img;
PImage sorted;
PImage dummy; //copy of sorted.pixels and used to get each step of pixel sorting
int width = 0;
int height = 0;


int glitchLevel = 6; //1, 2, 3, ... control division merge
boolean showBothIMGs = false; //to show both imgs side by side, only sorted img
//select how to sort the pixels by hue or brightness
String sortPixelMethod = "hue";
//String sortPixelMethod = "brightness";


//used to control speed of sorting process
int multiStep = 100000;
long startTime = 0;

//Create a queue stack to hold the quicksort indices to control the recursive calls
Queue<int[]> stackcalls = new LinkedList();
boolean started = false; //to mark if it started using stackcalls queue

int startL, mid, stopR; // variables used for the iterative mergeSort
int division = 1; // The size of the sub-arrays . Constantly changing from 1 to n/2 (arr[0...n-1])

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
    img = loadImage(filepath);
  }
}

void interrupt() { 
  while (img==null) delay(200);
}

//set initial canvas size
void settings() {
  selectInput("Select an image file to process:", "fileSelected");
  interrupt(); //interrupt process until img is selected

  //for testing
  //img = loadImage("sunflower400.jpg");
  //img = loadImage("d.png");
  //img = loadImage("Colorful1.jpg");
  //img = loadImage("Smoke.jpg");
  //img = loadImage("tokyo.png");
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
  //initial canvas size is set on settings

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
    if (!stackcalls.isEmpty()) {
      tint(255, 130);  // Apply transparency without changing color
      image(img, 0, 0.8* img.height, 0.2* img.width, 0.2* img.height);
      noTint();
    }
  }

  //dummy image to be sorted and steps extracted to be recreated on draw loop
  dummy = createImage(img.width, img.height, HSB);
  dummy = img.get();
}

void draw() {
  //show frame rate and current recursion stack queue
  println("Merge sort: " +String.format("%.2f", frameRate) + "frameRate\t  GlitchLevel: " + glitchLevel + " \t division: " 
    + division + " / steps: " + stackcalls.size());

  sorted.loadPixels();

  //multiStep during each loop for faster sort
  for (int steps = 0; steps < multiStep; steps++) {
    //slow down for better visualization
    if (division > 2 && multiStep > 500) multiStep = multiStep/2;

    //control the Iterative mergesort calls using the stackcalls queue
    if (stackcalls.isEmpty()) {

      /* Iterative mergesort
       https://www.geeksforgeeks.org/iterative-merge-sort/
       */
      if (!started) {
        started = true;
        delay(1000); //to have time to show the original img
      }
      // Merge subarrays in bottom up manner. First merge subarrays  
      // of size 1 to create sorted subarrays of size 2, then merge 
      // subarrays of size 2 to create sorted subarrays of size 4, continue... 
      if (division < dummy.pixels.length-1) {

        // Pick starting point of different subarrays of current size 
        // startL - start index for left sub-array
        startL = 0;

        while (startL <= dummy.pixels.length-1) {

          // stopR - end index for the right sub-array
          stopR = Math.min(startL + 2*division - 1, dummy.pixels.length-1);
          mid = startL + division -1;
          if (mid > dummy.pixels.length-1)
            mid = (stopR + startL)/2;
          //System.out.printf("startL=%d, mid=%d, stopR=%d\n", startL, mid, stopR);

          //we will call these pixels indexes during the draw loop for the real sorted.pixels array
          stackcalls.add(new int[]{startL, mid, stopR});

          // Create 2x Subarrays arr[startL...mid] & arr[mid+1...stopR] and merge them
          merge(dummy.pixels, startL, mid, stopR, sortPixelMethod);

          startL += 2*division;
        }
        division *= 2;
      }
    } else if (!stackcalls.isEmpty()) {
      //use the stackcalls queue to do the pixel changes in the canvas display
      int[] indexes = stackcalls.remove();
      int lowerIndex = indexes[0];
      int middle = indexes[1];
      int higherIndex = indexes[2];

      merge(sorted.pixels, lowerIndex, middle, higherIndex, sortPixelMethod);
    }
  }

  //show sorted pixels img so far
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
    if (!stackcalls.isEmpty() && division <= Math.min(Math.pow(2, glitchLevel + 1), dummy.pixels.length-1)) {
      tint(255, 190);  // Apply transparency without changing color
      image(img, 0, 0.8* img.height, 0.2* img.width, 0.2* img.height);
      noTint();
    }
  }
  //Show framerate on display
  if (!stackcalls.isEmpty() && division <= Math.min(Math.pow(2, glitchLevel + 1), dummy.pixels.length-1)) 
    text("Merge sort: " +String.format("%.2f", frameRate) + 
      " frameRate / division: " + division + " / steps: "+ stackcalls.size()+ " / GlitchLevel: " + glitchLevel
      + " / sort by " + sortPixelMethod, 0, 18);
  else {
    println("pixels sorting complete");
    noLoop();
    save(filename+"_PixelsSortedBy_"+sortPixelMethod+"_L"+glitchLevel+".jpg");
  }
}

/* Sort and merge the two halves arr[l..m] and arr[m+1..r] of array arr[] */
void merge(int arr[], int l, int m, int r, String sortPixelMethod) { 
  int i, j, k; 
  int n1 = m - l + 1; //L[] temp arrays size
  int n2 = r - m;  //R[] temp arrays size

  /* create temp arrays */
  int L[] = new int[n1]; 
  int R[] = new int[n2]; 

  /* Copy data to temp arrays L[] 
   and R[] */
  for (i = 0; i < n1; i++) 
    L[i] = arr[l + i]; 
  for (j = 0; j < n2; j++) 
    R[j] = arr[m + 1 + j]; 

  /* Merge the temp arrays back into arr[l..r]*/
  i = 0; 
  j = 0; 
  k = l; 
  while (i < n1 && j < n2) { 
    if (
      (sortPixelMethod.equals("hue") && hue(L[i]) >= hue(R[j]))
      ||
      (sortPixelMethod.equals("brightness") && brightness(L[i]) >= brightness(R[j]))
      ) { 
      arr[k] = L[i]; 
      i++;
    } else { 
      arr[k] = R[j]; 
      j++;
    } 
    k++;
  } 

  /* Copy the remaining elements of L[], if there are any */
  while (i < n1) { 
    arr[k] = L[i]; 
    i++; 
    k++;
  } 

  /* Copy the remaining elements of R[], if there are any */
  while (j < n2) { 
    arr[k] = R[j]; 
    j++; 
    k++;
  }
}
