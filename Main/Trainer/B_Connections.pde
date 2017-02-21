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
  void setWeight(float newWeight) {
    cWeight = newWeight;
  }

  //Function that randomly assigns weight
  void randomWeight() {
    cWeight = random(-1, 1);
  }

  //Function that calculuates the connection input and returns an output to a neuron
  float cCalculate(float input) {
    cInput = input;
    cOutput = cInput * cWeight;
    return cOutput;
  }
}