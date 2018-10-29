//CHUCK GRANULATOR TUTORIAL -
//GRAIN ENVELOPES, PART 3: PUTTING IT TOGETHER
//CODE: //https://github.com/elosine/chucK_granulator_tutorial

//Here we will choose a source soundfile,
//an envelope soundfile,
//and multiple them together to create a sound grain
repeat(10)
{
    SndBuf buf; //source soundfile to buffer
    "/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/samples/004_glassbreak.wav" => buf.read;
    SndBuf envbuf; //envelope soundfile to buffer
    "/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/grainEnv/gEnv_gauss.aif" => envbuf.read;
    Gain g => dac; //set up an audio chain
    buf => g; //send source to g
    envbuf => g; //send our envelope buffer to g
    3 => g.op; //multiply the source by the envelope
    0 => buf.pos; //starting playback position of source
    1 => buf.rate; //speed of the source playback
    0 => envbuf.pos; //start the envelope playback at sample 0
    700 => int gdur; //grain dur
    (envbuf.length() / (ms*gdur)) => envbuf.rate; //calculate rate to read through grain envelope to make grain last the grain dur
    gdur::ms => now; //move time ahead for single grain duration
}




