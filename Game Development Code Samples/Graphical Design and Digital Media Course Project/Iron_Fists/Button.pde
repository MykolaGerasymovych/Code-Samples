// Define button class
class Button {
  // Declare variables
  String text;
  float x, y, textSize, w, h;
  boolean pressed;
  
  // Constructor 
  Button(String text_, float x_, float y_, float textSize_, float h_) {
    text = text_;
    x = x_;
    y = y_;
    textSize = textSize_;
    textSize(textSize);
    w = textWidth(text) * 1.1; // let the width of button be a bit bigger than the text width 
    h = h_;
  }
  
  // Define display method
  void display() {
    textSize(textSize);
    textAlign(CENTER);
    
    if (pressCheck()) {
      stroke(255);
      fill(175, 150, 0);
    } else {
      stroke(0);
      fill(255, 225, 0);
    }
    rect(x, y, w, h, h * 0.2);
    
    if (pressCheck()) {
      fill(255);
    } else {
      fill(255, 50, 0);
    }
    text(text, x, y + h * 0.3);
  }
  
  // Define method to check whether the button is pressed
  boolean pressCheck() {
    if (mousePressed & mouseX < x + w * 0.5 & mouseX > x - w * 0.5 & mouseY > y - h * 0.5 & mouseY < y + h * 0.5) {
      return true;  
    } else {
      return false;
    }
  }
  
}