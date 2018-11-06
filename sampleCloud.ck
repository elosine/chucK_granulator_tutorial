100 => int maxGr;
SndBuf bufs[maxGr];
SndBuf envs[maxGr];
0 => int newpos;
0 => float lfo1;
0 => float ramp1;
0 => float lfotri1;
0 => int lfopulse1;
float gRate;

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

spork ~ lfosin ( 8 );
spork ~ ramp ( 5 );
spork ~ lfotri ( 180 );
spork ~ lfopulse ( 8 );

while (true) 
{
    for ( 0 => int i; i < maxGr; i++ )
    {
        <<< lfopulse1>>>;
        //Choose sample & envelope
        samples[3] => bufs[i].read;
        envelopes[5] => envs[i].read;
        
        //Choose read position
        //Math.random2( 0, bufs[i].samples() ) => int newpos;
        ( newpos + ( ( 2.0 + ( 48.0*lfotri1) ) * ( ms / samp ) ) ) $ int => newpos;
        newpos % 165000 => newpos; //trim tail of sample
        
        //Choose grain duration
        Math.random2( 20, 50 ) => int gDur;
        //300 => int grainDur; //use this for fixed grain duration
        
        //Choose gap duration
        // Math.random2( 15, 180 ) => int gGap;
        //150 => int gGap;
        
        8 => float gGapminMin;
        130 => float gGapminMax;
        (gGapminMax - gGapminMin) => float gGapminDif;
        17 => float gGapmaxMin;
        180 => float gGapmaxMax;
        (gGapmaxMax - gGapmaxMin) => float gGapmaxDif;
        
        Math.random2f( gGapminMin + (gGapminDif*lfo1),  gGapmaxMin + (gGapmaxDif*lfo1) ) => float gGap;
        
        
        //Choose amplitude
        //Math.random2f( 0.2, 1.0 ) => float gGain;
        //0.3 + ( 0.7 * (1.0 - lfo1) ) => float gGain; 
        //lfo1 => float gGain;
        1 => float gGain;
        
        
        //Choose panning
        Math.random2f( -1.0, 1.0 ) => float grainPan;
        //0 => float grainPan; 
        
        //Playback Speed
        // Math.random2f( 0.2, 8.0 ) =>  gRate;
        1.0 + ( 1.3*lfotri1 )  =>  gRate; 
        //0.5 + (2.5*lfo1) =>  gRate;
        // 5 - (4.7*ramp1) =>  gRate;
        
        //0.2 + ( 8.0 - ( 8.0 * lfo1 ) ) =>  gRate;
        /*
        if ( lfopulse1 ==1 )
        {
            0.3 => gRate;
        } else {
            6 => gRate;
        }
        */
        
        spork ~ grain( bufs[i], envs[i], newpos, gGain, grainPan, gRate, gDur );
        
        gGap::ms => now;
        
    }
    
    15::ms => now;
    
}

1::day => now;


fun void lfosin ( float dursec )
{
    SinOsc lfo => blackhole;
    ( 1.0 / dursec ) => lfo.freq;
    
    while ( true )
    {
        ( lfo.last() * 0.5 ) + 0.5 => lfo1;
        1::ms => now;
    }
}


fun void lfotri ( float dursec )
{
    TriOsc lfo => blackhole;
    ( 1.0 / dursec ) => lfo.freq;
    0.75 => lfo.phase;
    
    while ( true )
    {
        ( lfo.last() * 0.5 ) + 0.5 => lfotri1;
        1::ms => now;
    }
}

fun void lfopulse ( float dursec )
{
    PulseOsc lfo => blackhole;
    ( 1.0 / dursec ) => lfo.freq;
    //0.75 => lfo.phase;
    
    while ( true )
    {
        (( lfo.last() * 0.5 ) + 0.5 ) $ int=> lfopulse1;
        1::ms => now;
    }
}



fun void ramp ( float dursec )
{
    Phasor r => blackhole;
    ( 1.0 / dursec ) => r.freq;
    now + dursec::second => time later;
    
    while ( now < later )
    {
        r.last()  => ramp1;
        1::ms => now;
    }
    dursec::second => now;
}


fun void grain ( SndBuf buf, SndBuf envbuf, int pos, float ggain, float gpan, float rate, float gdur)
{
    Gain g => Pan2 p => dac; //set up an audio chain
    buf => g; //send source to g
    envbuf => g; //send our envelope buffer to g
    3 => g.op; //multiply the source by the envelope
    
    ggain => g.gain;
    pos => buf.pos; //starting playback position of source
    rate => buf.rate; //speed of the source playback
    1 => buf.loop;
    0 => envbuf.pos; //start the envelope playback at sample 0
    (envbuf.length() / (ms*gdur)) => envbuf.rate; //calculate rate to read through grain envelope to make grain last the grain dur
    gdur::ms => now; //move time ahead for single grain duration  
}