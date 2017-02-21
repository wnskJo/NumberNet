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
    learningRate = 0.1; // default learning rate
  }


  // Methods

  // Function to add the right number of layers
  void addLayer(int connectionNum, int neuronNum) { //<>// //<>//
    layers = (Layer[]) append(layers, new Layer(connectionNum, neuronNum)); //<>// //<>//
  } //<>// //<>//

  // Function to check the amount of layers created
  int getLayerCount() {
    return layers.length;
  }

  // Function to set a learning rate
  void setLearningRate(float newLearningRate) {
    learningRate = newLearningRate;
  }

  // Function to set network inputs
  void setInputs(float[] newNetInputs) {
    netInputs = newNetInputs;
  }

  // Function to manually set input for a specific layer
  void setLayerInputs(float[] newInputs, int layerIndex) {
    if (layerIndex > getLayerCount() - 1) {
      println("NN Error: setLayerInputs: layerIndex=" + layerIndex + " exceeded limits= " + (getLayerCount()-1));
    } else {
      layers[layerIndex].setInputs(newInputs);
    }
  }

  // Function to save the output from the layers as netOutputs
  void setOutputs(float[] newOutputs) {
    netOutputs = newOutputs;
  }

  // Function to return netOutputs
  float[] getOutputs() { //<>// //<>//
    return netOutputs;
  }

  // Function to process the net inputs through the network and save the outputs
  void netCalculate(float[] newInputs) {
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
  void trainNetwork(float[] inputData, float[] expectedOutputData) {
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

  void trainingCycle(ArrayList trainingInputData, ArrayList trainingExpectedData, Boolean trainRandomly) {
    int dataIndex;

    // reset training error every cycle
    trainingError = 0;

    for (int i = 0; i < trainingInputData.size(); i++) {
      if (trainRandomly) {
        dataIndex = int((random(trainingInputData.size())));
      } else {
        dataIndex = i;
      }

      trainNetwork((float[]) trainingInputData.get(dataIndex), (float[]) trainingExpectedData.get(dataIndex));
    }

    trainingError += abs(networkError);
  }

  // Function to train the network until the Error is below a specific threshold
  void autoTrainNetwork(ArrayList trainingInputData, ArrayList trainingExpectedData, float trainingErrorTarget, int cycleLimit) {
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