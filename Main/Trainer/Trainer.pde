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

void setup() {
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
