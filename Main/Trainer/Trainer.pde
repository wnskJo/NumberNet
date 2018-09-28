/*  //<>// //<>// //<>// //<>// //<>//
 Wonseok Cho, February 2017

 Basic feed-forward network model with back propagation capability for training.
 Basically all the work for this network is done by Scott C, from http://arduinobasics.blogspot.com
 */

NeuralNetwork nNetwork1;
NeuralNetwork nNetwork2;
NeuralNetwork nNetwork3;
NeuralNetwork nNetwork4;
NeuralNetwork nNetwork5;
NeuralNetwork nNetwork6;
ArrayList <float[]> inputs = new ArrayList<float[]>();
ArrayList outputs = new ArrayList();
Table trainingData1;
Table trainingData2;
Table testData;
Table exportDataNBias;
Table exportDataConnections;
int stopwatch, stopwatch1, stopwatch2, stopwatch3, stopwatch4, stopwatch5, stopwatch6;
int trainingStopwatch;

void setup() {
  //     _____      __
  //    / ___/___  / /___  ______
  //    \__ \/ _ \/ __/ / / / __ \
  //   ___/ /  __/ /_/ /_/ / /_/ /
  //  /____/\___/\__/\__,_/ .___/
  //                     /_/
  println("   _____      __            \n  / ___/___  / /___  ______ \n  \\__ \\/ _ \\/ __/ / / / __ \\\n ___/ /  __/ /_/ /_/ / /_/ /\n/____/\\___/\\__/\\__,_/ .___/ \n                   /_/      ");
  println("=================================================================================================");
  nNetwork1 = new NeuralNetwork();
  nNetwork1.addLayer(784, 784);
  nNetwork1.addLayer(784, 512);
  nNetwork1.addLayer(512, 10);

  nNetwork2 = new NeuralNetwork();
  nNetwork2.addLayer(784, 784);
  nNetwork2.addLayer(784, 512);
  nNetwork2.addLayer(512, 10);

  nNetwork3 = new NeuralNetwork();
  nNetwork3.addLayer(784, 784);
  nNetwork3.addLayer(784, 512);
  nNetwork3.addLayer(512, 10);

  nNetwork4 = new NeuralNetwork();
  nNetwork4.addLayer(784, 784);
  nNetwork4.addLayer(784, 512);
  nNetwork4.addLayer(512, 10);
  
  nNetwork5 = new NeuralNetwork();
  nNetwork5.addLayer(784, 784);
  nNetwork5.addLayer(784, 512);
  nNetwork5.addLayer(512, 10);

  nNetwork6 = new NeuralNetwork();
  nNetwork6.addLayer(784, 784);
  nNetwork6.addLayer(784, 512);
  nNetwork6.addLayer(512, 10);

  startStopwatch();
  println("Loading tables");
  testData = loadTable("Training_Data/mnist_test.csv");
  trainingData1 = loadTable("Training_Data/mnist_train1.csv");
  trainingData2 = loadTable("Training_Data/mnist_train2.csv");
  println("  Tables loaded\nAdding inputs");
  addInputs(trainingData1);
  addInputs(trainingData2);
  println("  Inputs added \nAdding outputs");
  addOutputs(trainingData1);
  addOutputs(trainingData2);
  println("  Outputs added");
  stopStopwatch(stopwatch);
  println("Input size: " + inputs.size() + " Output size: " + outputs.size());
  println("Input float size: " + inputs.get(0).length);
  println("First input: " + inputs.get(0)[0]);
  println("Second to last input: " + inputs.get(0)[782]);
  println("Last input: " + inputs.get(0)[783]);

  //    ______           _       _
  //   /_  __/________ _(_)___  (_)___  ____ _
  //    / / / ___/ __ `/ / __ \/ / __ \/ __ `/
  //   / / / /  / /_/ / / / / / / / / / /_/ /
  //  /_/ /_/   \__,_/_/_/ /_/_/_/ /_/\__, /
  //                                 /____/
  //startStopwatch();
  println("  ______           _       _            \n /_  __/________ _(_)___  (_)___  ____ _\n  / / / ___/ __ `/ / __ \\/ / __ \\/ __ `\n / / / /  / /_/ / / / / / / / / / /_/ / \n/_/ /_/   \\__,_/_/_/ /_/_/_/ /_/\\__, /  \n                               /____/   ");
  println("=================================================================================================");
  if(!train1){
    thread("trainNetwork1");
    thread("trainNetwork2");
    thread("trainNetwork3");
    thread("trainNetwork4");
    thread("trainNetwork5");
    thread("trainNetwork6");
  }
  //stopStopwatch();
  //    ______          __  _
  //   /_  __/__  _____/ /_(_)___  ____ _
  //    / / / _ \/ ___/ __/ / __ \/ __ `/
  //   / / /  __(__  ) /_/ / / / / /_/ /
  //  /_/  \___/____/\__/_/_/ /_/\__, /
  //                            /____/
  //println("  ______          __  _            \n /_  __/__  _____/ /_(_)___  ____ _\n  / / / _ \\/ ___/ __/ / __ \\/ __ `/\n / / /  __(__  ) /_/ / / / / /_/ / \n/_/  \\___/____/\\__/_/_/ /_/\\__, /  \n                          /____/   ");
  //println("=================================================================================================");
  //startStopwatch();
  //stopStopwatch();


  //      ______                      __  _                ____        __
  //     / ____/  ______  ____  _____/ /_(_)___  ____ _   / __ \____ _/ /_____ _
  //    / __/ | |/_/ __ \/ __ \/ ___/ __/ / __ \/ __ `/  / / / / __ `/ __/ __ `/
  //   / /____>  </ /_/ / /_/ / /  / /_/ / / / / /_/ /  / /_/ / /_/ / /_/ /_/ /
  //  /_____/_/|_/ .___/\____/_/   \__/_/_/ /_/\__, /  /_____/\__,_/\__/\__,_/
  //            /_/                           /____/
  //println("    ______                      __  _                ____        __       \n   / ____/  ______  ____  _____/ /_(_)___  ____ _   / __ \\____ _/ /_____ _\n  / __/ | |/_/ __ \\/ __ \\/ ___/ __/ / __ \\/ __ `/  / / / / __ `/ __/ __ `/\n / /____>  </ /_/ / /_/ / /  / /_/ / / / / /_/ /  / /_/ / /_/ / /_/ /_/ / \n/_____/_/|_/ .___/\\____/_/   \\__/_/_/ /_/\\__, /  /_____/\\__,_/\\__/\\__,_/  \n          /_/                           /____/                            ");
  //println("=================================================================================================");
  //startStopwatch();
  ////exportData();
  //stopStopwatch();
}

// Train networks
boolean train1 = false;
void trainNetwork1() {
  startStopwatch1();
  nNetwork1.autoTrainNetwork(inputs, outputs, 0.01, 10);
  train1 = true;
  println("train1 complete");
  testNetwork(testData, 100, nNetwork1);
  stopStopwatch(stopwatch1);
}
void trainNetwork2() {
  startStopwatch2();
  nNetwork2.autoTrainNetwork(inputs, outputs, 0.001, 10);
  println("train2 complete");
  testNetwork(testData, 100, nNetwork2);
  stopStopwatch(stopwatch2);
}
void trainNetwork3() {
  startStopwatch3();
  nNetwork3.autoTrainNetwork(inputs, outputs, 0.0001, 10);
  println("train3 complete");
  testNetwork(testData, 100, nNetwork3);
  stopStopwatch(stopwatch3);
}
void trainNetwork4() {
  startStopwatch4();
  nNetwork4.autoTrainNetwork(inputs, outputs, 0.001, 10);
  println("train4 complete");
  testNetwork(testData, 100, nNetwork4);
  stopStopwatch(stopwatch4);
}
void trainNetwork5() {
  startStopwatch5();
  nNetwork5.autoTrainNetwork(inputs, outputs, 0.001, 100);
  println("train5 complete");
  testNetwork(testData, 100, nNetwork5);
  stopStopwatch(stopwatch5);
}
void trainNetwork6() {
  startStopwatch6();
  nNetwork6.autoTrainNetwork(inputs, outputs, 0.001, 1000);
  println("train6 complete");
  testNetwork(testData, 100, nNetwork6);
  stopStopwatch(stopwatch6);
}

//function to add inputs for training
void addInputs(Table t) {
  float[] input = {};

  //784 neurons
  input = expand(input, 784);

  //should use t.getRowCount, but it takes too long to train (20,000 samples)..
  for (int i = 0; i < 3000/*t.getRowCount()*/; i++) {
    for (int j = 0; j < 784; j++) {
      //Converting the anti-aliased image to black and white only image
      input[j] = map(t.getInt(i, j+1), 0, 255, 0, 1);
    }
    inputs.add(input);
  }
}

//function to add outputs for training
void addOutputs(Table t) {
  int input;
  float[] output = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  for (int i = 0; i < 3000/*t.getRowCount()*/; i++) {
    input = t.getInt(i, 0);

    //initializing training output array
    for (int j = 0; j < output.length; j++) {
      output[j] = 0;
    }

    //converting into raw data
    switch(input) {
    case 0:
      output[0] = 1;
      break;
    case 1:
      output[1] = 1;
      break;
    case 2:
      output[2] = 1;
      break;
    case 3:
      output[3] = 1;
      break;
    case 4:
      output[4] = 1;
      break;
    case 5:
      output[5] = 1;
      break;
    case 6:
      output[6] = 1;
      break;
    case 7:
      output[7] = 1;
      break;
    case 8:
      output[8] = 1;
      break;
    case 9:
      output[9] = 1;
      break;
    }
    outputs.add(output);
  }
}

//function that tests the network and returns an accuracy percentage
void testNetwork(Table t, int testCount, NeuralNetwork netInput) {
  float accuracy = 0;
  float[] input = {};
  float[] outputRawData;
  float outputCertainty;
  int expectedOutput;
  int actualOutput = 999;

  input = expand(input, 784);

  //test loop
  for (int i = 0; i < testCount; i++) {
    expectedOutput = t.getInt(i, 0);

    //displays inputs and outputs of first five tests
    if (i < 10) {
      println("First ten tests:");
      println("  Input: " + expectedOutput);
      netInput.netCalculate(input);
      outputRawData = netInput.getOutputs();
      outputCertainty = outputRawData[0];
      for (int k = 1; k < 10; k++) {
        if (outputRawData[k] > outputCertainty) {
          outputCertainty = outputRawData[k];
          actualOutput = k;
        }
      }
      println("  Output: " + actualOutput);
    } else {
      netInput.netCalculate(input);
      outputRawData = netInput.getOutputs();
      outputCertainty = outputRawData[0];
      for (int k = 1; k < 10; k++) {
        if (outputRawData[k] > outputCertainty) {
          outputCertainty = outputRawData[k];
          actualOutput = k;
        }
      }
    }
    if (expectedOutput == actualOutput) {
      accuracy++;
    }
    actualOutput = 999;
  }
  accuracy = (accuracy/testCount) * 100;
  println("Testing complete! Accuracy is " + accuracy + "%.");
}

void startStopwatch() {
  stopwatch = millis();
}

void startStopwatch1() {
  stopwatch1 = millis();
}
void startStopwatch2() {
  stopwatch2 = millis();
}
void startStopwatch3() {
  stopwatch3 = millis();
}
void startStopwatch4() {
  stopwatch4 = millis();
}
void startStopwatch5() {
  stopwatch5 = millis();
}
void startStopwatch6() {
  stopwatch6 = millis();
}

void stopStopwatch(int time) {
  int hour = 0;
  int minute = 0;
  int second = 0;
  time = (millis() - time)/1000;
  
  second = time % 60;
  time -= second;
  minute = time / 60;
  hour = minute % 60;
  minute = minute - hour * 60;
  
  println("Elapsed time: " + hour + " hour(s) " + minute + " minutes(s) " + second + " second(s).");
}
/*
void exportData() {
  for (int i = 0; i < nNetwork.layers.length; i++) {
    // Setting nBias
    for (int j = 0; j < nNetwork.layers[i].getNeuronCount(); j++) {
      exportDataNBias.setFloat(i, j, nNetwork.layers[i].neurons[j].nBias);
      // Setting Connections
      for (int k = 1; k < nNetwork.layers[i].neurons[j ].getConnectionCount(); k++) {
        exportDataConnections.setFloat(k, j, nNetwork.layers[i].neurons[j].connections[k].cWeight);
      }
    }
  }
  saveTable(exportDataNBias, "Export/exportDataNBias.csv");
  saveTable(exportDataConnections, "Export/exportDataConnections.csv");

}
*/