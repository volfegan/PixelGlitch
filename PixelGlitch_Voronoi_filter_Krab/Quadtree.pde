// Daniel Shiffman //<>// //<>//
// http://codingtra.in
// http://patreon.com/codingtrain
//Videos
//Part 1:
//https://www.youtube.com/watch?v=OJxEcs0w_kE
//Part 2: 
//https://www.youtube.com/watch?v=QQx_NmCIuCY

//This code is only part 1 video of the challenge. 

import java.util.ArrayList;

class Quadtree {
  Rectangle boundary;
  int capacity; // max no. of points
  ArrayList <Point> points ;
  boolean divide = false;
  Quadtree northeast; 
  Quadtree northwest;
  Quadtree southeast;
  Quadtree southwest;

  public Quadtree(Rectangle rect, int cap) {
    this.boundary = rect;
    this.capacity = cap;
    points = new ArrayList<Point>();
  }

  public boolean contains(Point p) {
    return  p.x <= this.boundary.x+this.boundary.width &&
      p.x >= this.boundary.x-this.boundary.width &&
      p.y <= this.boundary.y+this.boundary.height &&
      p.y >= this.boundary.y-this.boundary.height ;
  }

  public boolean insert(Point p) {
    if (!this.contains(p)) return false;
    if (this.points.size() < this.capacity ) {
      this. points.add(p); 
      return true;
    } else {
      if (!this.divide) {
        subDivide();
      }
      if (this.northeast.insert(p)) {
        return true;
      } else if (this.northwest.insert(p)) {
        return true;
      } else if (this.southeast.insert(p)) {
        return true;
      } else if (this.southwest.insert(p)) {
        return true;
      } else return false;
    }
  }

  public void  subDivide() {
    double x = this.boundary.x;
    double y = this.boundary.y;
    double w = this.boundary.width;
    double h = this.boundary.height;
    this.northeast = new Quadtree(new Rectangle (x+w/2, y-h/2, w/2, h/2), capacity);
    this.northwest = new Quadtree(new Rectangle (x-w/2, y-h/2, w/2, h/2), capacity);
    this.southeast = new Quadtree(new Rectangle (x+w/2, y+h/2, w/2, h/2), capacity);
    this.southwest = new Quadtree(new Rectangle (x-w/2, y+h/2, w/2, h/2), capacity);
    this.divide = true;
  }
  public void query(Rectangle range, ArrayList<Point> points) {
    if (range.intersects(this.boundary)) {
      for (int i = 0; i < this.points.size(); i++) {
        if (range.contains (this.points.get(i)))
          points.add(this.points.get(i));
      }
      if (this.divide) {
        this.northeast.query(range, points); 
        this.northwest.query(range, points); 
        this.southeast.query(range, points); 
        this.southwest.query(range, points);
      }
    }
  }

  public ArrayList<Point> query(Rectangle range) {
    ArrayList<Point> points = new ArrayList <Point>();
    if (range.intersects(this.boundary)) {
      for (int i = 0; i < this.points.size(); i++) {
        if (range.contains (this.points.get(i)))
          points.add(this.points.get(i));
      }
      if (this.divide) {
        this.northeast.query(range, points); 
        this.northwest.query(range, points); 
        this.southeast.query(range, points); 
        this.southwest.query(range, points);
      }
    }
    return points;
  }

  public void show() {
    stroke(255);
    strokeWeight(1);
    noFill();
    rectMode(CENTER);
    rect ((float)this.boundary.x, (float)this.boundary.y, (float)this.boundary.width *2, (float)this.boundary.height*2);
    if (this.divide) {
      this.northeast.show();
      this.northwest.show();
      this.southeast.show();
      this.southwest.show();
    }
    /* (for showing points)
     for (Point p:points){
     strokeWeight(4);
     point(p.x , p.y);
     }
     */
  }
}
