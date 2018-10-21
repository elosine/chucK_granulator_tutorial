//Declare a SndBuf Variable
//See chucK reference: http://chuck.cs.princeton.edu/doc/program/ugen_full.html#sndbuf
//Example: http://chuck.cs.princeton.edu/doc/examples/basic/sndbuf.ck
SndBuf buf;
//Read a soundfile into the buffer
"/Users/yangj14/Documents/chucK/samples/004_glassbreak.wav" => buf.read;
//This is the basic patch: the buffer is chucked to the dac
buf => dac;
//These are functions within the SndBuf ugen. 
//.pos setting initial read position in number of samples
//.rate setting playback speed
0 => buf.pos;
1 => buf.rate;
//As with all things in chucK you need to advance time
//In this case, the buffer is being played back for 200 milliseconds
200::ms => now;  
