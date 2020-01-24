// mods by Ai Austin 12-Jan-2010
// Voting script, only allows one vote per avi
// @author JB Kraft
// ------------------------------------------------------------------------
// Feb 16, 2008  v1.1  - one avi, one vote
// Feb 14, 2008  v1.0  - simple voting, orig code
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// this message will be given to the voter after they vote
string g_THANKS_MSG = "Acknowledged";

// -- dont need to edit anything below here probably unless you want to change 
// how the message is delivered when someone votes. see: touch_start --
integer g_VOTES = 0;
integer chatChannel = 34;
// list of avis that voted
list g_VOTERS;
 
// ------------------------------------------------------------------------
update()
{
 if (g_VOTES == 0) {
            llSetText("", <1,1,1>, 1.0);
            llSetColor(<0.3,0.3,0.3>,ALL_SIDES);
        }
 else {
            llSetText(g_THANKS_MSG,<1,1,1>, 1.0);
            llSetColor(<0.0,1.0,0.0>,ALL_SIDES);
    };
 // llSetText( llGetObjectDesc() + "\n" + (string)g_VOTES + " votes", <1,1,1>, 1.0 );
}
 
// ------------------------------------------------------------------------
integer addVote( key id )
{
    // check memory and purge the list if we are getting full
    if( llGetFreeMemory() < 1000 ) {
        g_VOTERS = [];
    }
 
    // see if they have voted already
    if( llListFindList( g_VOTERS, [id] ) == -1 ) {
        g_VOTES++;
        // LSL in SL was g_VOTERS = (g_VOTERS=[]) + g_VOTERS + [id];
        g_VOTERS = g_VOTERS + [id];
        update();
        return TRUE;
    } else

    return FALSE;
}
 
// ------------------------------------------------------------------------
// D E F A U L T
// ------------------------------------------------------------------------
default
{
    // --------------------------------------------------------------------
    state_entry()
    {
        update();
        llListen(chatChannel, "", "", "");
    }
 
    // --------------------------------------------------------------------
    touch_start(integer total_number)
    {
        integer i;
        for( i = 0; i < total_number; i++ ) {
            if( addVote( llDetectedKey(i))) {
                if( g_THANKS_MSG != "" ) {
                    // uncomment one and only one of these next 3 lines
                    // llWhisper( 0, g_THANKS_MESSAGE );
                    // llSay( 0, g_THANKS_MSG );        
                    llInstantMessage( llDetectedKey(i), g_THANKS_MSG );
                }
            }
        }
    }
    
    
    listen(integer channel, string name, key id, string message) {
  
        if ((message == "clear") | (message == "reset")) {
            llResetScript();
        }      
    }
    
}
