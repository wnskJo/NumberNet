import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.awt.MouseInfo; 
import java.awt.Point; 
import processing.video.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Main extends PApplet {

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




//Fonts
PFont coolvetica;
PFont roboto;
PFont robotoSlab;
PFont robotoSlab52;

//Animation videos
Movie logoAnimationRed;
Movie logoAnimationBlue;

//Layout
UIBox frame = new UIBox(175, 25, 370, 50, 2, 0xff0090e9);
UIBox exit = new UIBox(320, 25, 60, 50, 0, true, 0xff0090e9, 0xfff40056, 0xffc41061);

//Misc
String programState = "GUESSSTART";

// These are used for transitions
float rectSize = 800;
float circleSize = 1;
int mousePosX = mouseX;
int mousePosY = mouseY;
// Slide up animation elements
boolean slideUp;
int guessIntroColor;

//Neural Network
NeuralNetwork nNetwork;
float[] networkInputs = {};
float[][] inputValues = new float[28][28];


public void setup() {
  background(0xff0090e9);
  // load font
  roboto = loadFont("Fonts/Roboto-Regular-48.vlw");
  robotoSlab = loadFont("Fonts/RobotoSlab.vlw");
  robotoSlab52 = loadFont("Fonts/RobotoSlab52.vlw");
  coolvetica = loadFont("Fonts/Coolvetica.vlw");

  // borderless window
  
  surface.setSize(350, 600);
  surface.setLocation(500, 150);

  // load animations
  logoAnimationRed = new Movie(this, "Videos/RedLogo.mp4");
  logoAnimationBlue = new Movie(this, "Videos/BlueLogo.mp4");

  // Miscellaneous
  noStroke();
  textFont(roboto);
  frameRate(60);

  // allow slide up animation in the beginning
  slideUp = true;

  // initialize inputValues for canvas; 0 means white 1 means black
  for (int i = 0; i < 28; i++) {
    for (int j = 0; j < 28; j++) {
      inputValues[i][j] = 0;
    }
  }

}

public void draw() {
  // program organized in different 'states'
  switch(programState) {
    // plays the animation in the beginning
    case "GUESSSTART":
      playAnimation(logoAnimationBlue);
      // checking to see if the animation ended
      if (logoAnimationBlue.time() == logoAnimationBlue.duration()) {
        logoAnimationBlue.stop();
        // setting slide up animation color to blue
        guessIntroColor = 0xff0090e9;
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
      background(0xff0090e9);
      delay(300);
      programState = "FEEDOUTTRO";
      break;

    // Feeding text goes away
    case "FEEDOUTTRO":
      background(0xff0090e9);
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


public void mouseDragged() {
  // Drag the window of the program
  Point mouse;
  mouse = MouseInfo.getPointerInfo().getLocation();
  if (mouseY < 50) {
    surface.setLocation(mouse.x, mouse.y);
  }

  // Draw on canvas and inputValues receives input
  if (programState == "GUESS") {
    if (canvas.mouseOverElement()) {
      inputValues[PApplet.parseInt(canvas.getRelativePosition("y")/10)][PApplet.parseInt(canvas.getRelativePosition("x")/10)] = 1;
    }
  }
}

//When the mouse clicks on an element
public void mouseReleased() {
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
public void mousePressed() {
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
public void mouseMoved() {
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
public void drawFrame() {
  //Background
  background(0xffeceff1);
  frame.drawShadow();
  frame.drawElement();
  frame.drawText("NumberNet", 32, 255, coolvetica);
  exit.drawElement();
  exit.drawText("X", 24, 255, coolvetica);

}

// Plays animations
//    Should be noted that for some weird reasons, the AVI format plays flipped horizontally.
//    It has to be scaled and flipped manually to play correctly.
public void playAnimation(Movie m) {
   //m.play();
   //pushMatrix();
   //scale(1, -1);
   //image(m, 0, -m.height);
   //popMatrix();
   m.play();
   image(m, 0, 0);
}

// Required in order to use Movie library
public void movieEvent(Movie m) {
  m.read();
}
/* 
 Connections control the input values with weights that goes 
 into the neuron
 */
class Connection {
  float cInput, 
    cOutput, 
    cWeight;

  /* Constructors */
  Connection() {
    //default constructor
  }
  Connection(float newWeight) {
    setWeight(newWeight);
  }

  //Function that sets the weight of the connection
  public void setWeight(float newWeight) {
    cWeight = newWeight;
  }

  //Function that randomly assigns weight
  public void randomWeight() {
    cWeight = random(-1, 1);
  }

  //Function that calculuates the connection input and returns an output to a neuron
  public float cCalculate(float input) {
    cInput = input;
    cOutput = cInput * cWeight;
    return cOutput;
  }
}
/* 
 Neuron class controls over the neurons by receiving inputs from connections, then 
 adds all values to pass it to next connection.
 */
class Neuron {
  Connection[] connections = {};
  float nInput, 
    nOutput, 
    nBias, 
    deltaError;
  /* Constructors */
  Neuron() {
    //Default constructor
  }
  //Constructor to assign connections accordingly
  Neuron(int connectionNum) {
    randomBias();
    for (int i = 0; i < connectionNum; i++) {
      Connection newConnection = new Connection();
      addConnections(newConnection);
    }
  }

  /* Methods */
  //Function to add a new connection to the neuron
  public void addConnections(Connection newValue) {
    connections = (Connection[]) append(connections, newValue);
  }

  //Function to randomly assign a bias value
  public void randomBias() {
    setBias(random(1));
  }

  //Function to make sure all connections are connected to the neuron
  public int getConnectionCount() {
    return connections.length;
  }

  //Function to manually assign a new bias value
  public void setBias(float newBias) {
    nBias = newBias;
  }

  //A sigmoid activation function
  public float activate(float nValue) {
    float activation = 1 / (1 + exp(-1 * nValue));
    return activation;
  }

  //The function that calculates the inputs from connections and returns an output after adding and activating them.
  public float nCalculate(float[] nInputs) {
    //Checker for right number of connections
    if (getConnectionCount() != nInputs.length) {
      println("Neuron Error: nCalculate() : Wrong number of nInputs");
      exit();
    }
    for (int i = 0; i < getConnectionCount(); i++) {
      nInput += connections[i].cCalculate(nInputs[i]);
    }

    nInput = nBias + nInput;
    nOutput = activate(nInput);
    return nOutput;
  }
}
class Layer {
  Neuron[] neurons = {};
  float[] lInputs = {};
  float[] lOutputs = {};
  float[] lExpectedOutputs = {};
  float lError;
  float learningRate;

  /* Constructor */
  Layer(int connectionNum, int neuronNum) {
    for (int i = 0; i < neuronNum; i++) {
      Neuron newNeuron = new Neuron(connectionNum);
      addNeuron(newNeuron);
      addLOutput();
    }
  }

  /* Methods */

  // Function to add arrays of neuron classes
  public void addNeuron(Neuron newNeuron) {
    neurons = (Neuron[]) append(neurons, newNeuron);
  }

  // Function to check the amount of neurons
  public int getNeuronCount() {
    return neurons.length;
  }

  //Function that allows expansion of number of layer outputs
  public void addLOutput() {
    lOutputs = expand(lOutputs, lOutputs.length+1);
  }

  //Function to assign expected outputs
  public void setExpectedOutputs(float[] newlExpectedOutputs) {
    lExpectedOutputs = newlExpectedOutputs;
  }

  //Function to reset expected outputs by clearing the whole array
  public void resetExpectedOutputs() {
    lExpectedOutputs = expand(lExpectedOutputs, 0);
  }

  //Function that sets the learning rate of training
  public void setLearningRate(float newLearningRate) {
    learningRate = newLearningRate;
  }

  //Function that receives outputs from previous layer and assigns them as current layer input
  public void setInputs(float[] newInputs) {
    lInputs = newInputs;
  }

  // Function to retrieve the layer error
  public float getLError() {
    return lError;
  }

  // Function to set a new layer error value
  public void setLError(float newlError) {
    lError = newlError;
  }

  // Function to add the error values
  public void increaseLError(float newlError) {
    lError += newlError;
  }

  // Function to set delta error
  public void setDeltaError(float[] expectedOutputs) {
    setExpectedOutputs(expectedOutputs);
    int neuronCount = getNeuronCount();

    setLError(0);
    for (int i = 0; i < neuronCount; i++) {
      neurons[i].deltaError = lOutputs[i]*(1 - lOutputs[i])*(lExpectedOutputs[i]-lOutputs[i]);

      increaseLError(abs(lExpectedOutputs[i] - lOutputs[i]));
    }
  }

  // Function to train the layer by changing the bias and weights
  public void trainLayer(float newLearningRate) {
    setLearningRate(newLearningRate);

    for (int i = 0; i < getNeuronCount(); i++) {
      neurons[i].nBias += (learningRate * 1 * neurons[i].deltaError);

      for (int j = 0; j < neurons[i].getConnectionCount(); j++) {
        neurons[i].connections[j].cWeight += (learningRate * neurons[i].connections[j].cInput * neurons[i].deltaError);
      }
    }
  }

  // Function to get the Neuron outputs from previous layer and pass on new neuron outputs
  public void lCalculate() {
    if (getNeuronCount() > 0) {
      if (lInputs.length != neurons[0].getConnectionCount()) {
        println("Error in Layer: lCalculate: The number of inputs do NOT match the number of Neuron connections in this layer");
        println("lInputs.length = " + lInputs.length + " | Neurons[0].getConnectionCount() = " + neurons[0].getConnectionCount());
        exit();
      } else {
        for (int i = 0; i < getNeuronCount(); i++) {
          lOutputs[i] = neurons[i].nCalculate(lInputs);
        }
      }
    } else {
      println("Error in Layer: lCalculate: There are no Neurons in this layer");
      exit();
    }
  }
}
/* 
 This class is a container for the whole neural network, and the way to access other neural classes 
 */
class NeuralNetwork {
  Layer[] layers = {};
  float[] netInputs = {};
  float[] netOutputs = {};
  float learningRate, 
    networkError, 
    trainingError;
  int retrainChances;

  NeuralNetwork() {
    learningRate = 0.1f; // default learning rate
  }


  // Methods

  // Function to add the right number of layers
  public void addLayer(int connectionNum, int neuronNum) { //<>// //<>//
    layers = (Layer[]) append(layers, new Layer(connectionNum, neuronNum)); //<>// //<>//
  } //<>// //<>//

  // Function to check the amount of layers created
  public int getLayerCount() {
    return layers.length;
  }

  // Function to set a learning rate
  public void setLearningRate(float newLearningRate) {
    learningRate = newLearningRate;
  }

  // Function to set network inputs
  public void setInputs(float[] newNetInputs) {
    netInputs = newNetInputs;
  }

  // Function to manually set input for a specific layer
  public void setLayerInputs(float[] newInputs, int layerIndex) {
    if (layerIndex > getLayerCount() - 1) {
      println("NN Error: setLayerInputs: layerIndex=" + layerIndex + " exceeded limits= " + (getLayerCount()-1));
    } else {
      layers[layerIndex].setInputs(newInputs);
    }
  }

  // Function to save the output from the layers as netOutputs
  public void setOutputs(float[] newOutputs) {
    netOutputs = newOutputs;
  }

  // Function to return netOutputs
  public float[] getOutputs() { //<>// //<>//
    return netOutputs;
  }

  // Function to process the net inputs through the network and save the outputs
  public void netCalculate(float[] newInputs) {
    setInputs(newInputs);

    if (getLayerCount() > 0) {
      if (netInputs.length != layers[0].neurons[0].getConnectionCount()) {
        println("NN Error: netCalculate: The number of inputs do NOT match the NN");
        exit();
      } else {
        for (int i = 0; i < getLayerCount(); i++) {
          if (i == 0) {
            setLayerInputs(netInputs, i);
          } else {
            setLayerInputs(layers[i - 1].lOutputs, i);
          }

          layers[i].lCalculate();
        }

        //Retrieves the last layer's output to the network outputs
        setOutputs(layers[getLayerCount() - 1].lOutputs);
      }
    } else {
      println("Error: There are no layers in this Neural Network");
      exit();
    }
  }

  // Function to train the network
  public void trainNetwork(float[] inputData, float[] expectedOutputData) {
    netCalculate(inputData);

    //Back propagation
    for (int i = getLayerCount() - 1; i >= 0; i--) {
      if (i == getLayerCount() - 1) {
        layers[i].setDeltaError(expectedOutputData);
        layers[i].trainLayer(learningRate);
        networkError = layers[i].getLError();
      } else {
        for (int j = 0; j < layers[i].getNeuronCount(); j++) {
          layers[i].neurons[j].deltaError = 0;

          for (int k = 0; k < layers[i+1].getNeuronCount(); k++) {
            layers[i].neurons[j].deltaError += (layers[i + 1].neurons[k].connections[j].cWeight * layers[i + 1].neurons[k].deltaError);
          }
          //equation for derivative of activation function 
          layers[i].neurons[j].deltaError *= (layers[i].neurons[j].nOutput * (1 - layers[i].neurons[j].nOutput));
        }

        layers[i].trainLayer(learningRate);
        layers[i].resetExpectedOutputs();
      }
    }
  }

  public void trainingCycle(ArrayList trainingInputData, ArrayList trainingExpectedData, Boolean trainRandomly) {
    int dataIndex;

    // reset training error every cycle
    trainingError = 0;

    for (int i = 0; i < trainingInputData.size(); i++) {
      if (trainRandomly) {
        dataIndex = PApplet.parseInt((random(trainingInputData.size())));
      } else {
        dataIndex = i;
      }

      trainNetwork((float[]) trainingInputData.get(dataIndex), (float[]) trainingExpectedData.get(dataIndex));
    }

    trainingError += abs(networkError);
  }

  // Function to train the network until the Error is below a specific threshold
  public void autoTrainNetwork(ArrayList trainingInputData, ArrayList trainingExpectedData, float trainingErrorTarget, int cycleLimit) {
    trainingError = 9999;
    int trainingCounter = 0;

    while (trainingError>trainingErrorTarget && trainingCounter<cycleLimit) {

      /* re-initialise the training Error with every cycle */
      trainingError=0;

      /* Cycle through the training data randomly */
      trainingCycle(trainingInputData, trainingExpectedData, true);

      /* increment the training counter to prevent endless loop */
      trainingCounter++;
    }

    /* Due to the random nature in which this neural network is trained. There may be occasions when the training error may drop below the threshold. To check if this is the case, we will go through one more cycle (but sequentially this time), and check the trainingError for that cycle. If the training error is still below the trainingErrorTarget, then we will end the training session. If the training error is above the trainingErrorTarget, we will continue to train. It will do this check a  Maximum of 9 times. */
    if (trainingCounter<cycleLimit) {
      trainingCycle(trainingInputData, trainingExpectedData, false);
      trainingCounter++;

      if (trainingError>trainingErrorTarget) {
        if (retrainChances<10) {
          retrainChances++;
          autoTrainNetwork(trainingInputData, trainingExpectedData, trainingErrorTarget, cycleLimit);
        }
      }
    } else {
      println("CycleLimit has been reached. Has been retrained " + retrainChances + " times.  Error is = " + trainingError);
    }
  }
}
int feedingTextSpace = 50;
float accelerator = 0.8f;
float resultsTextSpace = 1;

// circle animation when Guess Button is pressed
public void feedAnimate() {
  circleSize *= 1.3f;
  fill(0xff0090e9);
  ellipse(mousePosX, mousePosY, circleSize, circleSize);
  if (circleSize > 1200) {
    // draws feeding intro
    feedingIntroText();
  }
}

// "Feeding" text intro animation
public void feedingIntroText() {
  // set the cursor to arrow so it doesn't get stuck on HAND cursor
  cursor(ARROW);
  
  // accelerates the "Feeding" text position
  feedingTextSpace *= accelerator;
  accelerator += 0.01f;
  fill(255);
  textFont(robotoSlab, 32);
  text("Feeding...", width/2, (height/2) + feedingTextSpace);
  
  // checks to see if the animation is over
  if (feedingTextSpace < 1) {
     //reset accelerator and feedingTextSpace
     accelerator = 0.8f;
     feedingTextSpace = 50;
     
     //circle size has to reset here because this function is called inside circle animation
     circleSize = 1;
     
     programState = "FEEDING";
  }
}

// "Feeding" text goes away
public void feedingOuttro() {
  resultsTextSpace *= 1.3f;
  fill(255);
  textFont(robotoSlab, 32);
  text("Feeding...", width/2, (height/2) + resultsTextSpace);
  if (resultsTextSpace > 20) {
    resultsAnimate = true;
    rectSize = 800;
    programState = "RESULTS";
  }
}
UIBox canvas = new UIBox(175, 210, 280, 280, 3, 255);
UIBox guessButton = new UIBox(175, 540, 280, 70, 3, true, 0xffffd500, 0xffffe47e, 0xffffaa00);
UIBox clearButton = new UIBox(175, 460, 280, 70, 3, true, 0xfff40056, 0xffff3f80, 0xffc41061);

//Slide up transition for canvas screen
public void guessSlideUp(int newColor) {
  if (slideUp) {
    // decelerates rect size
    rectSize *= 0.9f;
    
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
public void drawGuessLayout() {
  guessCursor();
  canvas.drawElement();
  clearButton.drawElement();
  clearButton.drawText("Clear", 42, 255, roboto);
  guessButton.drawElement();
  guessButton.drawText("Feed", 42, 255, roboto);
}

// Change mouse cursor and button color
public void guessCursor() {
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
public void clearInputValues() {
  for(int i = 0; i < 28; i++) {
    for(int j = 0; j < 28; j++) {
      inputValues[i][j] = 0;
    }
  }
}

// Display drawn input on canvas
public void drawInputsOnCanvas() {
  for(int i = 0; i < 28; i++) {
    for(int j = 0; j < 28; j++) {
      if(inputValues[i][j] == 1) {
        fill(0);
        rectMode(CENTER);
        rect((j * 10) + (canvas.getX() + 8 - (canvas.getWidth()/2)), (i * 10) + (canvas.getY() + 8 - (canvas.getHeight()/2)), 10, 10);
      }
    }
  }
}
//This is a basic GUI library created in order to efficiently organize the GUI for this program. 
//I wrote this because I couldn't find a GUI library that had features that I wanted, so I wrote my own.

class UIBox {
  int posX;
  int posY;
  int elementWidth;
  int elementHeight;
  int shadowDepth;
  int elementColor;
  int normalColor;
  int highlightColor;
  int pressedColor;
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
  UIBox(int newPosX, int newPosY, int newElementWidth, int newElementHeight, int newShadowDepth, boolean newClickable, int newNormalColor, int newHighlightColor, int newPressedColor) {
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
  public int getX() {
    return posX;
  }
  //returns Y position of the element
  public int getY() {
    return posY;
  }
  //returns width of the element
  public int getWidth() {
    return elementWidth;
  }
  //returns height of the element
  public int getHeight() {
    return elementHeight;
  }
  
  //Sets the color of the element, in order to change the color of buttons
  //if the mouse is hovering or clicked on the element.
  public void setColor(int newColor) {
    elementColor = newColor;
  }

  // function that displays a custom text in the center of the element
  public void drawText(String text, int textSize, int textColor, PFont font) {
    textAlign(CENTER);
    fill(textColor);
    textFont(font, textSize);
    text(text, posX, posY + (textSize/3));
  }

  // function to drop shadow
  public void drawShadow() {
    for (int i = 5 * shadowDepth; i > 0; i--) {
      rectMode(CENTER);
      fill(0, 2);
      rect(posX, posY + (shadowDepth), elementWidth + i + (shadowDepth*0.1f), elementHeight + i + (shadowDepth*0.1f), 8);
    }
  }

  // function that returns a relative position value from the box.
  public int getRelativePosition(String axis) {
    if (axis == "x") {
      return PApplet.parseInt(mouseX - (posX - (elementWidth/2)));
    } else if (axis == "y") {
      return PApplet.parseInt(mouseY - (posY - (elementHeight/2)));
    } else {
      println("Error: getRelativePosition(): Error in input data");
      return 0;
    }
  }

  // function to check if the mouse is over the element
  public boolean mouseOverElement() {
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
  public void drawElement() {
    rectMode(CENTER);
    drawShadow();
    fill(elementColor);
    rect(posX, posY, elementWidth, elementHeight, 3);
  }
}
boolean resultsAnimate;
UIBox guessedResult = new UIBox(175, 140, 280, 140, 3, 255);
UIBox guessedDataChart = new UIBox(175, 358, 280, 260, 3, 255);
UIBox againButton = new UIBox(175, 540, 280, 70, 3, true, 0xffffd500, 0xffffe47e, 0xffffaa00);

// slide up for results screen
public void resultsSlideUp() {
  if (resultsAnimate) {
    // decelerates rect size
    rectSize *= 0.9f;
    
    rectMode(CORNERS);
    
    //color of the rect element
    fill(0xff0090e9);
    
    rect(0, 0, width, rectSize);
    if (rectSize < 1) {
      //reset rectSize
      rectSize = 800;
      resultsAnimate = false;
    }
  }
}

// displays results screen
public void drawResults() {
  resultsCursor();
  guessedResult.drawElement();
  guessedResult.drawText("Four", 52, 0, robotoSlab52);
  guessedDataChart.drawElement();
  drawDataTable();
  againButton.drawElement();
  againButton.drawText("Again", 42, 255, robotoSlab);
}

// displays data table with guess number and its certainty
public void drawDataTable() {
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
public void resultsCursor() {
  if(againButton.mouseOverElement()) {
    againButton.setColor(againButton.highlightColor);
    cursor(HAND);
  } else {
    cursor(ARROW);
    againButton.setColor(againButton.normalColor);
  }
}

// Enlarging circle animation and transition to canvas screen from Again Button
public void backToBeginning() {
  //accelerates the circle expansion
  circleSize *= 1.3f;
  
  fill(0xfff40056);
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
      guessIntroColor = 0xfff40056;
      
      // slide up transition
      slideUp = true;
      
      // pass to canvas screen
      programState = "GUESS";
    }
  }
}
public void dataReader() {
  
}
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Main" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
