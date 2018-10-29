//CHUCK GRANULATOR TUTORIAL -
//GRAIN ENVELOPES, PART 2: READ ENVELOPE BUFFER;
//SET ENVELOPE DURATION
//CODE: //https://github.com/elosine/chucK_granulator_tutorial

//Read the envelope sound file just like any other sf.
//(see part 1 of the tutorial)
SndBuf envbuf;
//You will need to change the path.
//Just drag the actual soundfile to this document
//and it will present the path.
"/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/grainEnv/gEnv_gauss.aif" => envbuf.read;
Gain g => dac; //set up an audio chain
SinOsc a => g; //send a sine wave to g for demo purposes
envbuf => g; //send our envelope buffer to g
3 => g.op; //multiply the envelope by the sine wave
0 => envbuf.pos; //start the envelope playback at sample 0
//The envelope soundfiles are 512 samples long.
//To play an envelope back over a certain duration,
//we have to do some calculations.
//The .rate function of SndBuf (envbuf.rate) controls how fast we read through the buffer.
//If the rate is 1, SndBuf will read through 512 samples, in the time it takes to read through 512 samples.
//IOW at regular speed.
//For a soundfile of 512 samples long, this is a very short duration.
//To make the envelope last, say a second,
//the rate will be the number of samples in the sound file, 512,
//divided by the number of samples in a second, 44100.
//The rate for our envbuf will be 512/44100.
//We will be declaring the envbuf/grain duration in milliseconds.
//So the equation we will use will be:
//length of buffer in samples/ number of samples in 1 millisecond * duration in milliseconds
//.length() gives the length of a SndBuf in samples
//The function/reserved variable 'ms' gives the number of samples in a millisecond.
//And the variable gdur will be the desired length of the grain in milliseconds
700 => int gdur;
 (envbuf.length() / (ms*gdur)) => envbuf.rate;
 1::day => now; //move time


