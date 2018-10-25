//CHUCK GRANULATOR TUTORIAL -
//RANDOMIZE PARAMETERS

100 => int maxGr; 
SndBuf bufs[maxGr]; 
SndBuf envs[maxGr]; 
0 => int ix;

//Create arrays to hold different samples and envelopes
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

float r1;
fun void ramp (float dursec)
{
    Phasor r => blackhole; 
    
    ( 1.0/dursec) => r.freq;
    ( now + dursec::second ) => time later;
    
    while( now < later)
    {
        r.last()  => r1;        
        1::ms => now;
    }  
    
    dursec::second => now;  
}

float lfo1;
fun void lfosin (float dursec)
{
    SinOsc lfo => blackhole; 
    
    ( 1.0/dursec) => lfo.freq;
    ( now + dursec::second ) => time later;
    
    while( true )
    {
        (lfo.last()*0.5) + 0.5  => lfo1;
        
        <<<lfo1>>>;
        
        1::ms => now;
        
    }  
}


spork ~ ramp (40.0);
spork ~ lfosin (12.0);


while (true) 
{      
    
    //r1val => grainGap;
    
    for(0 => int i; i < maxGr; i++)
    {  
        
        //Choose sample & envelope
        samples[0] => bufs[i].read;
        envelopes[5] => envs[i].read;
        
        //Choose read position
        // 8000 => int newpos; //use this for reading from the same position each time
        Math.random2( 0, bufs[i].samples() ) => int newpos; 
        //The Math.random2 function will choose a position between the beginning and end of the sample.
        //bufs[i].samples() gives length of the current sample in samples
        //int newpos creates a local variable to pass to the function below
        
        //****USE SINE LFO TO OSCILLATE GRAIN DURATION****//
        //Choose grain duration
        Math.random2f( 100 - ( 95*lfo1), 200 - ( 150*lfo1) ) $ int => int grainDur;
        //300 => int grainDur; //use this for fixed grain duration
        
        
        //****USE PHASOR RAMP TO INCREASE CLOUD DENSITY****//
        //Choose grain gap
        Math.random2f( 85 - (80*r1),  150 - (135*r1) ) => float grainGap;
        
        
        //Choose amplitude
        Math.random2f( 0.01, 1 ) => float grainGain;
        //1 => float grainGain; 
        
        //Choose panning
        Math.random2f( -1, 1 ) => float grainPan;
        //0 => float grainPan; 
        
        spork ~ grain( bufs[i], envs[i], newpos, grainDur, grainGain, grainPan );
        
        grainGap::ms => now; //this is the space between grains
        
    }
    
    1::samp => now;     
}

1::day => now;


fun void grain( SndBuf buf, SndBuf envbuf, int pos, int gdur, float grainGain, float grainPan )
{  
    Gain g;
    g => Pan2 p => dac; //added panning ugen
    buf => g;
    envbuf => g;
    3 => g.op;
    
    
    grainGain => g.gain; //made gain a variable
    grainPan => p.pan; //for panning
    pos => buf.pos;
    1 => buf.rate;
    1 => buf.loop;
    0 => envbuf.pos;
    (envbuf.length() / (ms*gdur)) => envbuf.rate; 
    gdur::ms => now; 
}









