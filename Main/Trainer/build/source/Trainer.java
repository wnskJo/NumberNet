import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Trainer extends PApplet {

/*  //<>//
    Wonseok Cho, February 2017

    Basic feed-forward network model with back propagation capability for training.
    Basically all the work for this network is done by Scott C, from http://arduinobasics.blogspot.com
*/

NeuralNetwork nNetwork; //<>// //<>//
float[] input = {};
float[] output = {};
ArrayList inputs = new ArrayList();
ArrayList outputs = new ArrayList();
Table trainingData;
Table exportData;

public void setup() {
  nNetwork = new NeuralNetwork();
  nNetwork.addLayer(784, 784);
  nNetwork.addLayer(784, 512);
  nNetwork.addLayer(512, 10);

  println("loading tables");
  trainingData = loadTable("Training_Data/mnist_test.csv");
  println("Table 1 loaded");
  trainingData = loadTable("Training_Data/mnist_train.csv");
  println("Table loaded");
  //for() {

  //}

   //<>// //<>// //<>//
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
    randomWeight();    
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
  public float nCalculate(float[] cInputs) {
    //Checker for right number of connections
    if (getConnectionCount() != cInputs.length) {
      println("Neuron Error: nCalculate() : Wrong number of nInputs");
      exit();
    }
    
    nInput = 0;
    
    for (int i = 0; i < getConnectionCount(); i++) {
      nInput += connections[i].cCalculate(cInputs[i]);
    }

    nInput += nBias;
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
  Layer(int connectionNum, int neuronNum) { //<>//
    for (int i = 0; i < neuronNum; i++) {
      Neuron newNeuron = new Neuron(connectionNum); //<>//
      addNeuron(newNeuron);
      addLOutput();
    }
  } //<>//

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
    lOutputs = (float[]) expand(lOutputs, lOutputs.length+1);
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
  public void addLayer(int connectionNum, int neuronNum) { //<>//
    layers = (Layer[]) append(layers, new Layer(connectionNum, neuronNum)); //<>//
  } //<>//

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
  public float[] getOutputs() { //<>//
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
        dataIndex = (int)(random(trainingInputData.size()));
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
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Trainer" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
