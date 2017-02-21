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
  void addNeuron(Neuron newNeuron) {
    neurons = (Neuron[]) append(neurons, newNeuron);
  }

  // Function to check the amount of neurons
  int getNeuronCount() {
    return neurons.length;
  }

  //Function that allows expansion of number of layer outputs
  void addLOutput() {
    lOutputs = (float[]) expand(lOutputs, lOutputs.length+1);
  }

  //Function to assign expected outputs
  void setExpectedOutputs(float[] newlExpectedOutputs) {
    lExpectedOutputs = newlExpectedOutputs;
  }

  //Function to reset expected outputs by clearing the whole array
  void resetExpectedOutputs() {
    lExpectedOutputs = expand(lExpectedOutputs, 0);
  }

  //Function that sets the learning rate of training
  void setLearningRate(float newLearningRate) {
    learningRate = newLearningRate;
  }

  //Function that receives outputs from previous layer and assigns them as current layer input
  void setInputs(float[] newInputs) {
    lInputs = newInputs;
  }

  // Function to retrieve the layer error
  float getLError() {
    return lError;
  }

  // Function to set a new layer error value
  void setLError(float newlError) {
    lError = newlError;
  }

  // Function to add the error values
  void increaseLError(float newlError) {
    lError += newlError;
  }

  // Function to set delta error
  void setDeltaError(float[] expectedOutputs) {
    setExpectedOutputs(expectedOutputs);
    int neuronCount = getNeuronCount();

    setLError(0);
    for (int i = 0; i < neuronCount; i++) {
      neurons[i].deltaError = lOutputs[i]*(1 - lOutputs[i])*(lExpectedOutputs[i]-lOutputs[i]);

      increaseLError(abs(lExpectedOutputs[i] - lOutputs[i]));
    }
  }

  // Function to train the layer by changing the bias and weights
  void trainLayer(float newLearningRate) {
    setLearningRate(newLearningRate);

    for (int i = 0; i < getNeuronCount(); i++) {
      neurons[i].nBias += (learningRate * 1 * neurons[i].deltaError);

      for (int j = 0; j < neurons[i].getConnectionCount(); j++) {
        neurons[i].connections[j].cWeight += (learningRate * neurons[i].connections[j].cInput * neurons[i].deltaError);
      }
    }
  }

  // Function to get the Neuron outputs from previous layer and pass on new neuron outputs
  void lCalculate() {
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