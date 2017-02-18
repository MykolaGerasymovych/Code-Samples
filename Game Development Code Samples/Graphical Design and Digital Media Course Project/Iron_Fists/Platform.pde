// Define platform class
class Platform {
  // Declare variables
  PImage image;
  float x, y, w, h, leftBorder, rightBorder, upBorder;
  
  // Constructor
  Platform(PImage image_, float x_, float y_, float w_, float h_) {
    image = image_;
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    leftBorder = x - w * 0.48;
    rightBorder = x + w * 0.48;
    upBorder = y - h * 0.235;
  }
  
  // Define display method
  void display() {
    image(image, x, y, w, h);
  }
}