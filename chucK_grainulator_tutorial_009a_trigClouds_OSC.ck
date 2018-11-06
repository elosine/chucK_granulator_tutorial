OscRecv meosc;
12321 => meosc.port;
meosc.listen();
meosc.event( "/1/toggle1, f" ) @=> OscEvent tog1;
0 => int playtog;
int id[99];

while ( true )
{
    tog1 => now;
    while (tog1.nextMsg() != 0 )
    {
        tog1.getFloat() $ int => playtog;
        if( playtog == 1 )
        {
            Machine.add( "/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/sampleCloud1a.ck" ) =>  id[0]; 
        }
        else
        {
            Machine.remove( id[0] ); 
        }
    } 
    1::ms => now;
}
1::day => now;




