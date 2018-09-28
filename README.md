# NumberNet


https://i.imgur.com/h8K172M.gifv


NumberNet is a basic fully connected neural network built on Processing 3. The goal of the project is to be able to recognize handwritten numbers through the neural network with MNIST dataset.
The back-end algorithm is a minor modification of Scott C's work: https://arduinobasics.blogspot.com/2011/08/neural-network-part-1-connection.html
## Front-end:
https://i.imgur.com/UI0JCDK.gifv

The front end part of the program has two main functions, which is to run a trained neural network and receive user's input. All of the design elements are made with Processing's default library.
## Back-end:
https://i.imgur.com/9cZRkAE.gifv

This network has 28 x 28 input, which becomes 784 input array. This network uses Scott C's simple backpropagation to compute the dataset. It uses a sigmoid activation

## Notes
This project is an archive of my high school project, and is no longer being worked on, but feel free to look around the files.
I wasn't able to train the network well, due to limitations of Processing. Training a shallow 3-layer fully connected network took about 10 hours, and I wasn't able to get a significant result from it.
