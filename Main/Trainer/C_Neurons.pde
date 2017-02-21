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
  void addConnections(Connection newValue) {
    connections = (Connection[]) append(connections, newValue);
  }

  //Function to randomly assign a bias value
  void randomBias() {
    setBias(random(1));
  }

  //Function to make sure all connections are connected to the neuron
  int getConnectionCount() {
    return connections.length;
  }

  //Function to manually assign a new bias value
  void setBias(float newBias) {
    nBias = newBias;
  }

  //A sigmoid activation function
  float activate(float nValue) {
    float activation = 1 / (1 + exp(-1 * nValue));
    return activation;
  }

  //The function that calculates the inputs from connections and returns an output after adding and activating them.
  float nCalculate(float[] cInputs) {
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