UIBox canvas = new UIBox(175, 210, 280, 280, 3, 255);
UIBox guessButton = new UIBox(175, 540, 280, 70, 3, true, #ffd500, #ffe47e, #ffaa00);
UIBox clearButton = new UIBox(175, 460, 280, 70, 3, true, #f40056, #ff3f80, #c41061);

//Slide up transition for canvas screen
void guessSlideUp(color newColor) {
  if (slideUp) {
    // decelerates rect size
    rectSize *= 0.9;
    
    rectMode(CORNERS);
    
    //color of the rect element
    fill(newColor);
    
    rect(0, 0, width, rectSize);
    if (rectSize < 1) {
      //reset rect size
      rectSize = 800;
      
      slideUp = false;
    }
  }
}

// Draw guess screen
void drawGuessLayout() {
  guessCursor();
  canvas.drawElement();
  clearButton.drawElement();
  clearButton.drawText("Clear", 42, 255, roboto);
  guessButton.drawElement();
  guessButton.drawText("Feed", 42, 255, roboto);
}

// Change mouse cursor and button color
void guessCursor() {
  if(clearButton.mouseOverElement()) {
    clearButton.setColor(clearButton.highlightColor);
    cursor(HAND);
  } else if (guessButton.mouseOverElement()) {
    guessButton.setColor(guessButton.highlightColor);
    cursor(HAND);
  } else if (canvas.mouseOverElement()) {
    cursor(CROSS);
  } else {
    // set back to normal color of buttons and cursor shape
    cursor(ARROW);
    clearButton.setColor(clearButton.normalColor);
    guessButton.setColor(guessButton.normalColor);
  }
  
  
}

// Clear canvas
void clearInputValues() {
  for(int i = 0; i < 25; i++) {
    for(int j = 0; j < 25; j++) {
      inputValues[i][j] = 0;
    }
  }
}

// Display drawn input on canvas
void drawInputsOnCanvas() {
  for(int i = 0; i < 25; i++) {
    for(int j = 0; j < 25; j++) {
      if(inputValues[i][j] == 1) {
        fill(0);
        rectMode(CENTER);
        rect((j * 11) + (canvas.getX() + 8 - (canvas.getWidth()/2)), (i * 11) + (canvas.getY() + 8 - (canvas.getHeight()/2)), 11, 11);
      }
    }
  }
}