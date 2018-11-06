100 => int maxGr;
SndBuf bufs[maxGr];
SndBuf envs[maxGr];
0 => int newpos;
0 => float lfo1;
0 => float ramp1;

OscRecv meosc;
12321 => meosc.port;
meosc.listen();
meosc.event( "/1/xy1, f, f" ) @=> OscEvent xy1;
1.0 => float x1val;
1.0 => float y1val;


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
spork ~ xy1fun ();

while (true) 
{
    for ( 0 => int i; i < maxGr; i++ )
    {
        <<< x1val + " : " + y1val>>>;
        //Choose sample & envelope
        samples[1] => bufs[i].read;
        envelopes[5] => envs[i].read;
        
        //Choose read position
        //Math.random2( 0, bufs[i].samples() ) => int newpos;
        ( newpos + ( 5 * ( ms / samp ) ) ) $ int => newpos;
        
        //Choose grain duration
        Math.random2f( 5 + (200*x1val) , 15 + (400*x1val) ) $ int => int gDur;
        //300 => int grainDur; //use this for fixed grain duration
        
        //Choose gap duration
      //  Math.random2( 50, 150 ) => int gGap;
        //300 => int gGap;
        
        5 => float gGapminMin;
        50 => float gGapminMax;
        (gGapminMax - gGapminMin) => float gGapminDif;
        15 => float gGapmaxMin;
        85 => float gGapmaxMax;
        (gGapmaxMax - gGapmaxMin) => float gGapmaxDif;

        //Math.random2f( gGapminMin + (gGapminDif*lfo1),  gGapmaxMin + (gGapmaxDif*lfo1) ) => float gGap; //uses lfo
        Math.random2f( gGapminMin + (gGapminDif*y1val),  gGapmaxMin + (gGapmaxDif*y1val) ) => float gGap; //uses osc fader
        
        //Choose amplitude
        //Math.random2f( 0.2, 1.0 ) => float gGain;
        1 => float gGain; 
        //lfo1 => float gGain;
        
        //Choose panning
        Math.random2f( -1.0, 1.0 ) => float grainPan;
        //0 => float grainPan; 
        
        //Playback Speed
        // Math.random2f( -2.0, 2.0 ) => float gRate;
       // 1 => float gRate; 
        //0.5 + (2.5*lfo1) => float gRate;
        5 - (4.7*ramp1) => float gRate;

        
                
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

fun void xy1fun ()
{
    while ( true )
    {
        xy1 => now;
        while (xy1.nextMsg() != 0 )
        {
            xy1.getFloat() => x1val;
            xy1.getFloat() => y1val;
        } 
        1::ms => now;
    }
}