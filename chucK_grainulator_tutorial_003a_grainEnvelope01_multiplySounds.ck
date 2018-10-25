//CHUCK GRANULATOR TUTORIAL -
//GRAIN ENVELOPES, PART 1: MULTIPLY SOUNDS
//An important consideration in granular synthesis
//is how individual grains are enveloped
//In this project we will be using small sound files
//that represent various envelopes.
//These are adapted from Curtis Roads' book Microsound.
//(see the grain envelope plots in the 'grainEnv' folder)
//They will be loaded into bufffers and
//multiplied by the grain to create an enveloped grain.

//STEP 1 - HOW TO MULTIPLY SOUNDS
//The Gain ugen is used to multiply several inputs.
//Here is a classic ring modulator,
//multiplying microphone input by a sine wave.

//Declare a Gain ugen and put it in the audio chain
Gain g;
g => dac;
//Now we can chuck various inputs to the gain ugen.
adc => g; //microphone input
SinOsc a => g; //sine wave oscillator
//Most ugens have some universal functions.
//The .op function allows you to perform 
//certain operations on inputs to the ugen.
3 => g.op;
/*
op(int) (of type int): set/get operation at the UGen. Values:
0 : stop - always output 0
1 : normal operation, add all inputs (default)
2 : normal operation, subtract inputs starting from the earliest connected
3 : normal operation, multiply all inputs
4 : normal operation, divide inputs starting from the earlist connected
-1 : passthru - all inputs to the ugen are summed and passed directly to output
*/
1::day => now; //advance time

