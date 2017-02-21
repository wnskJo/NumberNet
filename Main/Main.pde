/*
 Wonseok Cho
 Feb 2017
 This program guesses the number you've drawn through the use of neural networks.

 It uses a basic feed-forward network model with back propagation capability for training using sigmoid activation function.
 This program specifically has 784 neuron inputs with the drawing canvas resolution of 28 by 28, with
 10 neuron outputs in order to guess the correct number ranging from 0 to 9.

 Most of the credit for creating this neural network template goes to Scott C, from http://arduinobasics.blogspot.com
 I have re-written his code in order to understand how it works, so there are minor differences from his original work.
 */
import java.awt.MouseInfo;
import java.awt.Point;
import processing.video.*;

//Fonts
PFont coolvetica;
PFont roboto;
PFont robotoSlab;
PFont robotoSlab52;

//Animation videos
Movie logoAnimationRed;
Movie logoAnimationBlue;

//Layout
UIBox frame = new UIBox(175, 25, 370, 50, 2, #0090e9);
UIBox exit = new UIBox(320, 25, 60, 50, 0, true, #0090e9, #f40056, #c41061);

//Misc
String programState = "GUESSSTART";

// These are used for transitions
float rectSize = 800;
float circleSize = 1;
int mousePosX = mouseX;
int mousePosY = mouseY;
// Slide up animation elements
boolean slideUp;
color guessIntroColor;

//Neural Network
NeuralNetwork nNetwork;
float[] networkInputs = {};
float[][] inputValues = new float[25][25];


void setup() {
  background(#0090e9);
  // load font
  roboto = loadFont("Fonts/Roboto-Regular-48.vlw");
  robotoSlab = loadFont("Fonts/RobotoSlab.vlw");
  robotoSlab52 = loadFont("Fonts/RobotoSlab52.vlw");
  coolvetica = loadFont("Fonts/Coolvetica.vlw");

  // borderless window
  fullScreen();
  surface.setSize(350, 600);
  surface.setLocation(500, 150);

  // load animations
  logoAnimationRed = new Movie(this, "Videos/RedLogo.avi");
  logoAnimationBlue = new Movie(this, "Videos/BlueLogo.avi");
  
  // Miscellaneous
  noStroke();
  textFont(roboto);
  frameRate(60);

  // allow slide up animation in the beginning
  slideUp = true;

  // initialize inputValues for canvas; 0 means white 1 means black
  for (int i = 0; i < 25; i++) {
    for (int j = 0; j < 25; j++) {
      inputValues[i][j] = 0;
    }
  }

}

void draw() {
  // program organized in different 'states'
  switch(programState) {
    // plays the animation in the beginning
    case "GUESSSTART":
      playAnimation(logoAnimationBlue);
      println(logoAnimationBlue.time());
      // checking to see if the animation ended
      if (logoAnimationBlue.time() == logoAnimationBlue.duration()) {
        logoAnimationBlue.stop();
        println("Animation Stopped");
        // setting slide up animation color to blue
        guessIntroColor = #0090e9;
        programState = "GUESS";
      }
      break;

    // canvas page animation from pressing "Again" button from results page
    case "BACKTOBEGINNING":
      //call slide up animation
      backToBeginning();
      break;
    case "GUESS":
      //background has to be inside switch statement or else it messes up with animations
      background(0);
      drawFrame();
      drawGuessLayout();
      drawInputsOnCanvas();
      guessSlideUp(guessIntroColor);
      break;

    //draws enlarging circles from clicking "feed" and brings up Feeding animation
    case "FEEDANIMATE":
      feedAnimate();
      break;

    // Actual forward propagation happens here
    case "FEEDING":
      background(#0090e9);
      delay(300);
      programState = "FEEDOUTTRO";
      break;

    // Feeding text goes away
    case "FEEDOUTTRO":
      background(#0090e9);
      feedingOuttro();
      break;

    // Results page
    case "RESULTS":
      drawFrame();
      drawResults();
      resultsSlideUp();
      break;

    default:
      println("programState Error: Invalid State");
      exit();
  }
}


void mouseDragged() {
  // Drag the window of the program
  Point mouse;
  mouse = MouseInfo.getPointerInfo().getLocation();
  if (mouseY < 50) {
    surface.setLocation(mouse.x, mouse.y);
  }

  // Draw on canvas and inputValues receives input
  if (programState == "GUESS") {
    if (canvas.mouseOverElement()) {
      inputValues[int(canvas.getRelativePosition("y")/11.2)][int(canvas.getRelativePosition("x")/11.2)] = 1;
    }
  }
}

//When the mouse clicks on an element
void mouseReleased() {
  //exit button
  if (exit.mouseOverElement()) {
    exit();
  }
  switch(programState) {
    //Guess Button
    case "GUESS":
      if (guessButton.mouseOverElement()) {
        mousePosX = mouseX;
        mousePosY = mouseY;
        programState = "FEEDANIMATE";
      }
      if(clearButton.mouseOverElement()) {
        clearInputValues();
      }
      break;
    //Again Button
    case "RESULTS":
      if (againButton.mouseOverElement()) {
        clearInputValues();
        mousePosX = mouseX;
        mousePosY = mouseY;
        programState = "BACKTOBEGINNING";
    }
    break;
  }
}

// button color change for exit button
void mousePressed() {
  if (exit.mouseOverElement()) {
    exit.setColor(exit.pressedColor);
  } else {
    exit.setColor(exit.normalColor);
  }

  switch(programState) {
    case "GUESS":
      if(clearButton.mouseOverElement()) {
        clearButton.setColor(clearButton.pressedColor);
      } else if (guessButton.mouseOverElement()) {
        guessButton.setColor(guessButton.pressedColor);
      } else {
        // set back to normal color of buttons and cursor shape
        cursor(ARROW);
        clearButton.setColor(clearButton.normalColor);
        guessButton.setColor(guessButton.normalColor);
      }
      break;
  }
}

// button color change for exit button
void mouseMoved() {
  if (exit.mouseOverElement()) {
    exit.setColor(exit.highlightColor);
  } else {
    exit.setColor(exit.normalColor);
  }
  switch(programState) {
    case "GUESS":
      if(clearButton.mouseOverElement()) {
        clearButton.setColor(clearButton.pressedColor);
      } else if (guessButton.mouseOverElement()) {
        guessButton.setColor(guessButton.pressedColor);
      break;
      }
  }
}

// Draws NumberNet frame
void drawFrame() {
  //Background
  background(#eceff1);
  frame.drawShadow();
  frame.drawElement();
  frame.drawText("NumberNet", 32, 255, coolvetica);
  exit.drawElement();
  exit.drawText("X", 24, 255, coolvetica);

}

// Plays animations
//    Should be noted that for some weird reasons, the video plays flipped horizontally.
//    It has to be scaled and flipped manually to play correctly.
void playAnimation(Movie m) {
   m.play();
   pushMatrix();
   scale(1, -1);
   image(m, 0, -m.height);
   popMatrix();
  //m.play();
  //image(m, 0, 0);
}

// Required in order to use Movie library
void movieEvent(Movie m) {
  m.read();
}