//This is a basic GUI library created in order to efficiently organize the GUI for this program. 
//I wrote this because I couldn't find a GUI library that had features that I wanted, so I wrote my own.

class UIBox {
  int posX;
  int posY;
  int elementWidth;
  int elementHeight;
  int shadowDepth;
  color elementColor;
  color normalColor;
  color highlightColor;
  color pressedColor;
  boolean clickable = false;

  /* Default Constructor */
  UIBox(int newPosX, int newPosY, int newElementWidth, int newElementHeight, int newShadowDepth, int newElementColor) {
    posX = newPosX;
    posY = newPosY;
    elementWidth = newElementWidth;
    elementHeight = newElementHeight;
    elementColor = newElementColor;
    shadowDepth = newShadowDepth;
  }
  /* Button Constructor */
  UIBox(int newPosX, int newPosY, int newElementWidth, int newElementHeight, int newShadowDepth, boolean newClickable, color newNormalColor, color newHighlightColor, color newPressedColor) {
    posX = newPosX;
    posY = newPosY;
    elementWidth = newElementWidth;
    elementHeight = newElementHeight;
    elementColor = newNormalColor;
    shadowDepth = newShadowDepth;
    clickable = newClickable;
    normalColor = newNormalColor;
    highlightColor = newHighlightColor;
    pressedColor = newPressedColor;
  }

  //returns X position of the element
  int getX() {
    return posX;
  }
  //returns Y position of the element
  int getY() {
    return posY;
  }
  //returns width of the element
  int getWidth() {
    return elementWidth;
  }
  //returns height of the element
  int getHeight() {
    return elementHeight;
  }
  
  //Sets the color of the element, in order to change the color of buttons
  //if the mouse is hovering or clicked on the element.
  void setColor(color newColor) {
    elementColor = newColor;
  }

  // function that displays a custom text in the center of the element
  void drawText(String text, int textSize, color textColor, PFont font) {
    textAlign(CENTER);
    fill(textColor);
    textFont(font, textSize);
    text(text, posX, posY + (textSize/3));
  }

  // function to drop shadow
  void drawShadow() {
    for (int i = 5 * shadowDepth; i > 0; i--) {
      rectMode(CENTER);
      fill(0, 2);
      rect(posX, posY + (shadowDepth), elementWidth + i + (shadowDepth*0.1), elementHeight + i + (shadowDepth*0.1), 8);
    }
  }

  // function that returns a relative position value from the box.
  int getRelativePosition(String axis) {
    if (axis == "x") {
      return int(mouseX - (posX - (elementWidth/2)));
    } else if (axis == "y") {
      return int(mouseY - (posY - (elementHeight/2)));
    } else {
      println("Error: getRelativePosition(): Error in input data");
      return 0;
    }
  }

  // function to check if the mouse is over the element
  boolean mouseOverElement() {
    if (mouseX > (posX - elementWidth/2) && 
      mouseX < (posX + elementWidth/2) && 
      mouseY > (posY - elementHeight/2) && 
      mouseY < (posY + elementHeight/2)) {
      return true;
    } else {
      return false;
    }
  }

  // function that draws the element
  void drawElement() {
    rectMode(CENTER);
    drawShadow();
    fill(elementColor);
    rect(posX, posY, elementWidth, elementHeight, 3);
  }
}