//Code found here:
//https://github.com/elosine/chucK_granulator_tutorial

//Same as tutorial 001 but repeating a loop
//sounding more like a granulator
SndBuf buf;
"/Users/yangj14/Documents/chucK/samples/004_glassbreak.wav" => buf.read;
buf => dac;

repeat(20)
{
0 => buf.pos; //where in the buffer we sample
1 => buf.rate; //speed of playback
200::ms => now; //grain duration
}

//We already can adjust:
////where in the buffer it reads from
////the rate of playback
////the duration of the grain
//Try the below:
////Comment out the repeat above and uncomment the repeat below 

/*
repeat(40)
{
    Math.random2(0, buf.samples()) => buf.pos; 
    //buf.samples() gives an int equal to the number of samples in the buffer
    //remember that 
    Math.random2f(0.5, 4) => buf.rate;
    Math.random2(80, 300)::ms => now;
    //Notice the use of random number generators
    //A well-used technique in granular synthesis
    //which will be tackled more in depth later
}
*/