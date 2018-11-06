//CHUCK GRANULATOR TUTORIAL -
//AUTOMATION

100 => int maxGr; 
SndBuf bufs[maxGr]; 
SndBuf envs[maxGr]; 

string samples [4];
"/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/samples/004_glassbreak.wav" => samples[0];
"/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/samples/000_tanpura.wav" => samples[1];
"/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/samples/001_musicbox.aif" => samples[2];
"/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/samples/018_low-glass-bow_stereo.aif" => samples[3];
string envelopes [10];
"/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/grainEnv/gEnv_blackman.aif" => envelopes[0];
"/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/grainEnv/gEnv_expodec.aif" => envelopes[1];
"/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/grainEnv/gEnv_gauss.aif" => envelopes[2];
"/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/grainEnv/gEnv_hamming.aif" => envelopes[3];
"/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/grainEnv/gEnv_hanning.aif" => envelopes[4];
"/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/grainEnv/gEnv_pulse.aif" => envelopes[5];
"/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/grainEnv/gEnv_quasiGauss.aif" => envelopes[6];
"/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/grainEnv/gEnv_rexpodec.aif" => envelopes[7];
"/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/grainEnv/gEnv_threeStageLinear.aif" => envelopes[8];
"/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/grainEnv/gEnv_tri.aif" => envelopes[9];

//Use ugens to create variables that will change over time

//Ramp Generator
float r1; //global variable to store the ramp value
//A function to generate the ramp
fun void ramp (float dursec)
{
    Phasor r => blackhole; //send phasor to blackhole which ticks ugens without generating audio
    
    ( 1.0/dursec ) => r.freq; //converts duration in seconds to a phasor frequency
    //To generate a onetime ramp,
    //calculate a time dursec from now,
    //and create a loop that will last until then.
    ( now + dursec::second ) => time later; 
    
    while( now < later)
    //while( true ) //for infinite loop
    {
        r.last()  => r1;        
        1::ms => now;
    }  
    
    dursec::second => now;  //moves time ahead for the duration of ramp; comment out for infinite loop
}

float lfo1;
fun void lfosin (float dursec)
{
    SinOsc lfo => blackhole; 
    ( 1.0/dursec) => lfo.freq;
    
    while( true )
    {
        (lfo.last()*0.5) + 0.5  => lfo1; 
        //SinOsc generates numbers from -1 to 1.
        //Above normalizes it to 0 - 1 
               
        1::ms => now; //frame rate
    }  
}

//Run ramps/lfos on root level of patch
//These will run as independant shreds, concurrently with grains
spork ~ ramp (40.0);
spork ~ lfosin (12.0);
//You can create several different versions of these
//Look at various oscillators: 
//http://chuck.cs.princeton.edu/doc/program/ugen_full.html

while (true) 
{          
    for(0 => int i; i < maxGr; i++)
    {  
        
        //Choose sample & envelope
        samples[0] => bufs[i].read;
        envelopes[5] => envs[i].read;
        
        //Choose read position
        // 8000 => int newpos; //use this for reading from the same position each time
        Math.random2( 0, bufs[i].samples() ) => int newpos; 
                
        //****USE SINE LFO TO OSCILLATE GRAIN DURATION****//
        //Choose grain duration
        
        //Use some basic math to change both max and min grain duration.
        //This uses the sine lfo to oscillate from min:500ms-5ms & max:1000ms-15ms
        5 => float gdurminMin;
        500 => float gdurminMax;
        (gdurminMax - gdurminMin) => float gdurminDif;
        15 => float gdurmaxMin;
        1000 => float gdurmaxMax;
        (gdurmaxMax - gdurmaxMin) => float gdurmaxDif;
        
        Math.random2f( gdurminMax - ( gdurminDif*lfo1), 1000 - ( gdurmaxDif*lfo1) ) $ int => int grainDur; //$ int casts the float as an integer
       // 30 => int grainDur; //use this for fixed grain duration
        
        
        //****USE PHASOR RAMP TO INCREASE CLOUD DENSITY****//
        //Choose grain gap
        
        //This uses the ramp to increase grain density
        3 => float gGapminMin;
        150 => float gGapminMax;
        (gGapminMax - gGapminMin) => float gGapminDif;
        5 => float gGapmaxMin;
        300 => float gGapmaxMax;
        (gGapmaxMax - gGapmaxMin) => float gGapmaxDif;

        Math.random2f( gGapminMax - (gGapminDif*r1),  gGapmaxMax - (gGapmaxDif*r1) ) => float grainGap;
        //80.0 => float grainGap; //use this for fixed grain gap

        
        //Choose amplitude
        Math.random2f( 0.01, 0.85 ) => float grainGain;
        //1 => float grainGain; 
        
        //Choose panning
        Math.random2f( -1, 1 ) => float grainPan;
        //0 => float grainPan;  
        
        //Playback Speed
        Math.random2f( -2.0, 2.0 ) => float gRate;
        //1 => float gRate; 
        
        spork ~ grain( bufs[i], envs[i], newpos, grainDur, grainGain, grainPan, gRate );
        
        grainGap::ms => now; //this is the space between grains
        
    }
    
    15::ms => now;     
}

1::day => now;

fun void grain( SndBuf buf, SndBuf envbuf, int pos, int gdur, float grainGain, float grainPan, float grainRate )
{  
    Gain g;
    g => Pan2 p => dac; //added panning ugen
    buf => g;
    envbuf => g;
    3 => g.op;
     
    grainGain => g.gain; //made gain a variable
    grainPan => p.pan; //for panning
    pos => buf.pos;
    grainRate => buf.rate;
    1 => buf.loop;
    0 => envbuf.pos;
    (envbuf.length() / (ms*gdur)) => envbuf.rate; 
    gdur::ms => now; 
}









