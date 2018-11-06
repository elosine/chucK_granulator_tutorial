Hid hi;
HidMsg msg;
int id[99];

// which keyboard
0 => int device;
// get from command line
if( me.args() ) me.arg(0) => Std.atoi => device;

// open keyboard (get device number from command line)
if( !hi.openKeyboard( device ) ) me.exit();
<<< "keyboard '" + hi.name() + "' ready", "" >>>;

// infinite event loop
while( true )
{
    // wait on event
    hi => now;
    
    // get one or more messages
    while( hi.recv( msg ) )
    {
        // check for action type
        if( msg.isButtonDown() )
        {
            <<< "down:", msg.which, "(code)", msg.key, "(usb key)", msg.ascii, "(ascii)" >>>;
            
            if( msg.ascii == 81 )
            {
                Machine.add( "/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/sampleCloud1a.ck" ) =>  id[0]; 
            }
            
            if( msg.ascii == 87 )
            {
                Machine.remove( id[0] ); 
            }
            
            if( msg.ascii == 69 )
            {
                Machine.add( "/Users/yangj14/Documents/GitHub/chucK_granulator_tutorial/sampleCloud1a.ck" ) =>  id[0]; 
            }
            
        }
        
        else
        {
            //<<< "up:", msg.which, "(code)", msg.key, "(usb key)", msg.ascii, "(ascii)" >>>;
            if( msg.ascii == 69 )
            {
                Machine.remove( id[0] ); 
            }
            
            
        }
    }
}