//CHUCK GRANULATOR TUTORIAL -
//MULTIPLE GRAINS
//CODE: //https://github.com/elosine/chucK_granulator_tutorial

100 => int grainDur;
80 => int grainGap;
SndBuf buf, envbuf;

repeat (30)
{        
    //We fill the buffers, within the repeat loop, 
    //just before creating the grain.
    "/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/samples/001_musicbox.aif" => buf.read;
    "/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/grainEnv/gEnv_gauss.aif" => envbuf.read;
    
    spork ~ grain( buf, envbuf, 0, grainDur );
    
    grainGap::ms => now; //this is the space between grains
    
}

1::day => now;


fun void grain( SndBuf buf, SndBuf envbuf, int pos, int gdur )
{  
    Gain g;
    1 => g.gain;
    g => dac;
    buf => g;
    envbuf => g;
    3 => g.op;
    
    pos => buf.pos;
    1 => buf.rate;
    1 => buf.loop;
    0 => envbuf.pos;
    (envbuf.length() / (ms*gdur)) => envbuf.rate; 
    gdur::ms => now; 
}









