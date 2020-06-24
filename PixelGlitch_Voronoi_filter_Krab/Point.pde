// Daniel Shiffman, modified and improved by Volfegan
// http://codingtra.in
// http://patreon.com/codingtrain
//Videos
//Part 1:
//https://www.youtube.com/watch?v=OJxEcs0w_kE
//Part 2: 
//https://www.youtube.com/watch?v=QQx_NmCIuCY
//Part 3: 
//https://www.youtube.com/watch?v=z0YFFg_nBjw

public class Point implements Comparable<Point>  {
  public double x;
  public double y;
  public P data; //the P point data from the voronoi
/*
  public Point (double x, double y) {
    this.x = x;
    this.y = y;
  }
  */
  public Point (double x, double y, P p) {
    this.x = x;
    this.y = y;
    this.data = p;
  }

  public double getX() {
    return this.x;
  }
  
  public double getY() {
    return this.y;
  }
  
  public P getData() {
    return this.data;
  }
  
  public boolean equals(Point p) {
    if (this.x == p.x && this.y == p.y)
      return true;
    else
      return false;
  }
  
  public int compareTo(Point p) {
    if (this.x * width + this.y > p.x * width + p.y) {
      return 1;
    }
    if (this.x * width + this.y < p.x * width + p.y) {
      return -1;
    }
    return 0;
  }
}
