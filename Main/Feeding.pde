int feedingTextSpace = 50;
float accelerator = 0.8;
float resultsTextSpace = 1;

// circle animation when Guess Button is pressed
void feedAnimate() {
  circleSize *= 1.3;
  fill(#0090e9);
  ellipse(mousePosX, mousePosY, circleSize, circleSize);
  if (circleSize > 1200) {
    // draws feeding intro
    feedingIntroText();
  }
}

// "Feeding" text intro animation
void feedingIntroText() {
  // set the cursor to arrow so it doesn't get stuck on HAND cursor
  cursor(ARROW);
  
  // accelerates the "Feeding" text position
  feedingTextSpace *= accelerator;
  accelerator += 0.01;
  fill(255);
  textFont(robotoSlab, 32);
  text("Feeding...", width/2, (height/2) + feedingTextSpace);
  
  // checks to see if the animation is over
  if (feedingTextSpace < 1) {
     //reset accelerator and feedingTextSpace
     accelerator = 0.8;
     feedingTextSpace = 50;
     
     //circle size has to reset here because this function is called inside circle animation
     circleSize = 1;
     
     programState = "FEEDING";
  }
}

// "Feeding" text goes away
void feedingOuttro() {
  resultsTextSpace *= 1.3;
  fill(255);
  textFont(robotoSlab, 32);
  text("Feeding...", width/2, (height/2) + resultsTextSpace);
  if (resultsTextSpace > 20) {
    resultsAnimate = true;
    rectSize = 800;
    programState = "RESULTS";
  }
}