/*  //<>// //<>// //<>// //<>//
 Wonseok Cho, February 2017

 Basic feed-forward network model with back propagation capability for training.
 Basically all the work for this network is done by Scott C, from http://arduinobasics.blogspot.com
 */

NeuralNetwork nNetwork;
ArrayList <float[]> inputs = new ArrayList<float[]>();
ArrayList outputs = new ArrayList();
Table trainingData1;
Table trainingData2;
Table testData;
int stopwatch;
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
  nNetwork = new NeuralNetwork();
  nNetwork.addLayer(784, 784);
  nNetwork.addLayer(784, 512);
  nNetwork.addLayer(512, 10);

  startStopwatch();
  println("Loading tables");
  testData = loadTable("Training_Data/mnist_test.csv");
  trainingData1 = loadTable("Training_Data/mnist_train1.csv");
  trainingData2 = loadTable("Training_Data/mnist_train2.csv");
  println("  Tables loaded\nAdding inputs");
  addInputs(trainingData1);
  //addInputs(trainingData2);
  println("  Inputs added \nAdding outputs");
  addOutputs(trainingData1);
  //addOutputs(trainingData2);
  println("  Outputs added");
  stopStopwatch();
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
  startStopwatch();
  println("  ______           _       _            \n /_  __/________ _(_)___  (_)___  ____ _\n  / / / ___/ __ `/ / __ \\/ / __ \\/ __ `\n / / / /  / /_/ / / / / / / / / / /_/ / \n/_/ /_/   \\__,_/_/_/ /_/_/_/ /_/\\__, /  \n                               /____/   ");
  println("=================================================================================================");
  nNetwork.autoTrainNetwork(inputs, outputs, 0.01, 1000);
  stopStopwatch();
  //    ______          __  _
  //   /_  __/__  _____/ /_(_)___  ____ _
  //    / / / _ \/ ___/ __/ / __ \/ __ `/
  //   / / /  __(__  ) /_/ / / / / /_/ /
  //  /_/  \___/____/\__/_/_/ /_/\__, /
  //                            /____/
  println("  ______          __  _            \n /_  __/__  _____/ /_(_)___  ____ _\n  / / / _ \\/ ___/ __/ / __ \\/ __ `/\n / / /  __(__  ) /_/ / / / / /_/ / \n/_/  \\___/____/\\__/_/_/ /_/\\__, /  \n                          /____/   ");
  println("=================================================================================================");
  startStopwatch();
  testNetwork(testData, 100);
  stopStopwatch();

  //      ______                      __  _                ____        __
  //     / ____/  ______  ____  _____/ /_(_)___  ____ _   / __ \____ _/ /_____ _
  //    / __/ | |/_/ __ \/ __ \/ ___/ __/ / __ \/ __ `/  / / / / __ `/ __/ __ `/
  //   / /____>  </ /_/ / /_/ / /  / /_/ / / / / /_/ /  / /_/ / /_/ / /_/ /_/ /
  //  /_____/_/|_/ .___/\____/_/   \__/_/_/ /_/\__, /  /_____/\__,_/\__/\__,_/
  //            /_/                           /____/
  println("    ______                      __  _                ____        __       \n   / ____/  ______  ____  _____/ /_(_)___  ____ _   / __ \\____ _/ /_____ _\n  / __/ | |/_/ __ \\/ __ \\/ ___/ __/ / __ \\/ __ `/  / / / / __ `/ __/ __ `/\n / /____>  </ /_/ / /_/ / /  / /_/ / / / / /_/ /  / /_/ / /_/ / /_/ /_/ / \n/_____/_/|_/ .___/\\____/_/   \\__/_/_/ /_/\\__, /  /_____/\\__,_/\\__/\\__,_/  \n          /_/                           /____/                            ");
  println("=================================================================================================");
  startStopwatch();
  exportData();
  stopStopwatch();
}

//function to add inputs for training
void addInputs(Table t) {
  float[] input = {};

  //784 neurons
  input = expand(input, 784);

  //should use t.getRowCount, but it takes too long to train (20,000 samples)..
  for (int i = 0; i < 1000/*t.getRowCount()*/; i++) {
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
  for (int i = 0; i < 1000/*t.getRowCount()*/; i++) {
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
void testNetwork(Table t, int testCount) {
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
    if (i < 5) {
      println("First five tests:");
      println("  Input: " + expectedOutput);
      nNetwork.netCalculate(input);
      outputRawData = nNetwork.getOutputs();
      outputCertainty = outputRawData[0];
      for (int k = 1; k < 10; k++) {
        if (outputRawData[k] > outputCertainty) {
          outputCertainty = outputRawData[k];
          actualOutput = k;
        }
      }
      println("  Output: " + actualOutput);
    } else {
      nNetwork.netCalculate(input);
      outputRawData = nNetwork.getOutputs();
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

void stopStopwatch() {
  stopwatch = (millis() - stopwatch)/1000;
  println("Elapsed time: " + stopwatch + " seconds");
}

void exportData() {
  for (int k = 0; k < nNetwork.layers.length; k++) {
    for (int i = 0; i < nNetwork.layers[k].getNeuronCount(); i++) {
      exportData.setFloat(0, i, nNetwork.layers[k].neurons[i].nBias);
      //setting nbias
      for (int j = 1; j < nNetwork.layers[0].neurons[j].getConnectionCount(); j++) {
        exportData.setFloat(j, i, nNetwork.layers[k].neurons[i].connections[j].cWeight);
      }
    }
  }
  saveTable(exportData, "Export/exportData.csv");
}
