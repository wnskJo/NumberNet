boolean resultsAnimate;
UIBox guessedResult = new UIBox(175, 140, 280, 140, 3, 255);
UIBox guessedDataChart = new UIBox(175, 358, 280, 260, 3, 255);
UIBox againButton = new UIBox(175, 540, 280, 70, 3, true, #ffd500, #ffe47e, #ffaa00);

// slide up for results screen
void resultsSlideUp() {
  if (resultsAnimate) {
    // decelerates rect size
    rectSize *= 0.9;
    
    rectMode(CORNERS);
    
    //color of the rect element
    fill(#0090e9);
    
    rect(0, 0, width, rectSize);
    if (rectSize < 1) {
      //reset rectSize
      rectSize = 800;
      resultsAnimate = false;
    }
  }
}

// displays results screen
void drawResults() {
  resultsCursor();
  guessedResult.drawElement();
  guessedResult.drawText("Four", 52, 0, robotoSlab52);
  guessedDataChart.drawElement();
  drawDataTable();
  againButton.drawElement();
  againButton.drawText("Again", 42, 255, robotoSlab);
}

// displays data table with guess number and its certainty
void drawDataTable() {
  float dataRightX = 50 + (guessedDataChart.getX() - (guessedDataChart.getWidth()/2));
  float dataLeftX = 210 + (guessedDataChart.getX() - (guessedDataChart.getWidth()/2));
  float dataY = 40 + (guessedDataChart.getY() - (guessedDataChart.getHeight()/2));
  textAlign(CENTER);
  textFont(robotoSlab, 24);
  fill(0);
  text("Guess", dataRightX, dataY);
  text("Certainty", dataLeftX, dataY);
  for(int i = 1; i < 6; i++ ) {
    text(i, dataRightX, dataY + (i * 38));
    text(i * 20 + "%", dataLeftX, dataY + (i * 38));
  }
}

// changes cursor shape and color when mouse is over a clickable element
void resultsCursor() {
  if(againButton.mouseOverElement()) {
    againButton.setColor(againButton.highlightColor);
    cursor(HAND);
  } else {
    cursor(ARROW);
    againButton.setColor(againButton.normalColor);
  }
}

// Enlarging circle animation and transition to canvas screen from Again Button
void backToBeginning() {
  //accelerates the circle expansion
  circleSize *= 1.3;
  
  fill(#f40056);
  ellipse(mousePosX, mousePosY, circleSize, circleSize);
  
  //checks to see if the circle covered the whole screen
  if (circleSize > 1200) {
    //plays the logo animation
    playAnimation(logoAnimationRed);
    
    // When the animation finishes
    if (logoAnimationRed.time() >= logoAnimationRed.duration()) { 
      logoAnimationRed.stop();
      
      // reset circle size
      circleSize = 1;
      
      // slide up transition color set to red
      guessIntroColor = #f40056;
      
      // slide up transition
      slideUp = true;
      
      // pass to canvas screen
      programState = "GUESS";
    }
  }
}