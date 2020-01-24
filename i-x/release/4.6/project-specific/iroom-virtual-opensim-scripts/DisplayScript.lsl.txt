// Copyright 2010 - AIAI, School of Infrmatics, University of Edinburgh
// Davie Munro, SP Pizzicato, Ai Austin - http://vue.ed.ac.uk & http://www.aiai.ed.ac.uk
// last updated: 2011-07-28 to support OpenSim

// ===========================================
// PARAMETERS
// ===========================================

// ===========================================
// you will probably need to edit these....
// ===========================================

string base_url = "http://openvce.net/tmp/";
// string base_url = "http://easdale.aiai.ed.ac.uk/tmp/";
string upload_url = "http://openvce.net/presentation-upload";
// string upload_url = "http://easdale.aiai.ed.ac.uk/presentation-upload";

// ===========================================
// you probably should not edit these....
// ===========================================

string get_presentations_script = "get-available-presentations.php";
string get_details_script = "get-presentation-details.php";
string html_wrap_script = "html-wrap.php";

key VIDEO_DEFAULT = TEXTURE_MEDIA;
//key BLANK = TEXTURE_BLANK;

integer chan = -93; // for Dialog
integer configchan = -94;
integer set_urlchan = 6; // for Set URL command only
integer setavatarchan = 7; // for Set Avatar command only

integer LOOP_TIMER = 15;   //In whole seconds

string notecardname = "OpenVCE Presenter Information";

// ===========================================
// menu texts
// ===========================================

string RESET = "Reset";
string UPLOAD = "Upload";
string SETUP = "Setup";
string GO_TO_SLIDE = "Go to slide";
string SET_URL = "Set URL";
string POWER_ON = "Power on";
string POWER_OFF = "Power off";
string SET_SLIDESET = "Set slides";
string ALLOW_ALL_USERS = "All users";
string ALLOW_GROUP_ONLY = "Group only";
string SAY_URL_ON = "Say URL on";
string SAY_URL_OFF = "Say URL off";
string ALT_AVATAR = "Set avatar";
string LOOP_ON = "Loop";
string LOOP_OFF = "Unloop";
string LOOP_RATE = "Loop rate";
list LOOP_RATES = ["30s", "45s", "60s", "10s", "15s", "20s"];
string INFO = "Information";

// ===========================================
// VARIABLES
// ===========================================

integer mode = 0;           //mode: 0 = Power off; 1 = Power on
                            
integer permslevel = 0;     //permslevel: 0 = owner/group only; 1 = anyone
integer sayURL = FALSE; 

list contents;
list presents;
key http_request_id;
key avatar_request_id;
key avatarkey;
string avatarname;

string rel_path = "";
string extension = "";
                            
integer currentURL = 0;
integer totalURL = 0;

integer listenUrl = -1;
integer listenHandle = -1;
integer listenTimer = -1;
integer loopSlides = FALSE;     //Are we looping pictures with a timer?

key video_texture;

integer deeded = FALSE;

// ===========================================
// FUNCTIONS
// ===========================================

// ===========================================
// power
// ===========================================

power_off(){
    
    // To diagnose issues with Media UUIDs
    // llSay(0, "VIDEO_DEFAULT="+ VIDEO_DEFAULT);
    // string video_texture = llList2Key(llParcelMediaQuery([PARCEL_MEDIA_COMMAND_TEXTURE]),0);
    // llSay(0, "video texture is:"+ (string) video_texture);
    
    mode=0;
    llMessageLinked(LINK_ROOT, -1, "power_off", "");
}

power_on(){
    mode=1;
    if(totalURL>0){
        llMessageLinked(LINK_ROOT, -1, "power_on", "");
        set_video_texture();
    }
    else llSay(0, "Use the touch menu to select an image source for display.");
}

reset(){
    // turn off, reset media texture, set media url to empty, reset perms to defaults
    power_off();
    llParcelMediaCommandList([PARCEL_MEDIA_COMMAND_TYPE,"",PARCEL_MEDIA_COMMAND_URL,""]);
    permslevel = 0;
    totalURL = 0;
    presents = [];
    loopSlides = FALSE;
    sayURL = FALSE;
    LOOP_TIMER = 15;
}


// ===========================================
// display
// ===========================================

set_slide_url(integer n){
    string slideurl = base_url + rel_path + (string) n + "."+ extension;
    string mimetype = get_mimetype(extension);
    if(mimetype == "image/*"){
        slideurl = base_url + html_wrap_script + "?target=" + slideurl;
        mimetype = "text/html";
    }
    llParcelMediaCommandList([PARCEL_MEDIA_COMMAND_TYPE,mimetype,PARCEL_MEDIA_COMMAND_URL,slideurl]);
    if(sayURL) llSay(0,"Now showing "+slideurl);
}

set_url(string url){
    currentURL = 0;
    totalURL = 1;
    string mimetype = get_mimetype(llList2String(llParseString2List(url,["."],[]),-1));
    if(mimetype == "image/*"){
        url = base_url + html_wrap_script + "?target=" + url;
        mimetype = "text/html";
    }
    llParcelMediaCommandList([PARCEL_MEDIA_COMMAND_TYPE,mimetype,PARCEL_MEDIA_COMMAND_URL,url]);
    power_on();
    //mode=2;
    if(llSubStringIndex(url, "://") == -1) url = "http://"+url;
    if(sayURL) llSay(0,"Now showing "+url);
}

next_slide(){
    if(currentURL<(totalURL-1)){
        currentURL = currentURL+1;
        set_slide_url(currentURL);
    }
    else if(loopSlides){
        currentURL = 0;
        set_slide_url(currentURL);
    }
}

   
previous_slide(){
    if(currentURL > 0){
        currentURL = currentURL-1;
        set_slide_url(currentURL);
    }
}      

display_slide(integer slideNumber){
    if((slideNumber-1) < totalURL && (slideNumber-1)>=0){
         currentURL = slideNumber-1;
         set_slide_url(currentURL);
    }              
}

set_video_texture(){
    video_texture = llList2Key(llParcelMediaQuery([PARCEL_MEDIA_COMMAND_TEXTURE]),0);
    // llSay(0, "video texture is:"+ (string) video_texture);
    if(video_texture == NULL_KEY)
    {
        video_texture = VIDEO_DEFAULT;
        llParcelMediaCommandList([PARCEL_MEDIA_COMMAND_TEXTURE,VIDEO_DEFAULT]);
        llSay(0,"No parcel media texture found. Setting texture to default: "+(string)VIDEO_DEFAULT);
        if(llGetLandOwnerAt(llGetPos()) != llGetOwner())
            llSay(0,"Error: Cannot modify parcel media settings. "+llGetObjectName()+" is not owned by parcel owner.");
    }
    //llSetTexture(video_texture,DISPLAY_ON_SIDE);
    llMessageLinked(LINK_ROOT, -1, "set_texture", video_texture);     
}

string get_mimetype(string ext)    //Returns a string stating the filetype of a file based on file extension
{
    ext = llToLower(ext);
    if(ext == "mov" || ext == "avi" || ext == "mpg" || ext == "mpeg" || ext == "smil" || ext == "mp4" || ext == "m4v" || ext == "sdp")
        return "video/*";
    if(ext == "jpg" || ext == "mpeg" || ext == "gif" || ext == "png" || ext == "pict" || ext == "tga" || ext == "tiff" || ext == "sgi" || ext == "bmp")
        return "image/*";
    if(ext == "mp3" || ext == "wav")
        return "audio/*";
    return "text/html";
}

string left(string src, string divider) {
    integer index = llSubStringIndex( src, divider );
    if(~index)
        return llDeleteSubString( src, index, -1);
    return src;
}

string str_replace(string str, string search, string replace) {
    return llDumpList2String(llParseStringKeepNulls(str, [search], []), replace);
    // for SL was return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}


// ===========================================
// menus
// ===========================================

presentation_menu(key id){
    if(presents!=[]){
       presentation_submenu(id, 0);
    }
    else{
        llInstantMessage(id,"You do not seem to have any presentations uploaded.");
        llLoadURL(id, "You do not seem to have any presentations uploaded.\nClick the link to visit the website and upload a presentation.", upload_url);
    }
}

presentation_submenu(key id, integer start){
    // horrific code to re-present the default menu options...
    integer showmax = 5;
    integer npres = llGetListLength(presents);
    list optl = [];
    string opts = "";
    integer i = 0;
    integer rc = 0;
    integer show = showmax;
    if((npres-start)>showmax){
        while (i<showmax){
            i = i+1;
            opts = opts + "\n"+(string)(start+i+1)+". "+llList2String(presents,start+i);
            if(rc==0) optl = optl + [(string)(3+(start+i+1))];
            else optl = optl + [(string)(start+i-1)];
            
            if(i==1){
                integer nend = npres;
                if(nend>(start+2*showmax)) nend = (start+2*showmax); 
                
                optl = optl + ["("+(string)(showmax+start+1)+"-"+(string)nend+")"];
                rc++;
            }
        }
    }   
    else{
        show = npres-start;
        i = 0; 
        rc = 0;
        integer nr = (show/3)+1;
        
        while (i<show){
            i = i+1;
            opts = opts+"\n"+(string)(start+i+1)+". "+llList2String(presents,start+i);
            if(rc==0) optl = optl + [(string)(((nr-1)*(show-2))+(start+1+i))];
            else optl = optl + [(string)(start+i-1)];

            
            if(i==1 || show==1){
                if(npres>showmax){
                    optl = optl + ["(1-"+(string)(showmax)+")"];
                }
                rc++;
            }
        } 
    }
    
    llDialog(id,"You have a total of "+(string)npres+" presentations available. Please select one:"+opts,optl,chan);
}

basic_menu(key id){
    llListen(configchan,"","","");
    list opts = [];
            
    opts = opts + [UPLOAD,SET_URL,SET_SLIDESET]; 
    
    if(mode==0) {
        opts = opts + [POWER_ON];
    }
    else {
        opts = opts + [POWER_OFF];
        if((mode==1) && (totalURL>0))
            opts = opts + [GO_TO_SLIDE];
    }
    opts = opts + [SETUP, INFO]; 
    
    llDialog(id,"Please select:",opts,configchan);
}

setup_menu(key id){
    llListen(configchan,"","","");
    list opts = [];
    
    if(sayURL) opts = opts + [SAY_URL_OFF];
    else opts = opts + [SAY_URL_ON];
    
    if(permslevel == 0) opts = opts + [ALLOW_ALL_USERS, RESET];
    else 
        // only allow group member to restrict to group/reset!
        if(llSameGroup(id)) opts = opts + [ALLOW_GROUP_ONLY, RESET];
            
    opts = opts + [ALT_AVATAR];
    
    opts = opts + [LOOP_RATE];
    
    if(!loopSlides){
        if(totalURL>1) opts = opts + [LOOP_ON];
    }
    else opts = opts + [LOOP_OFF];
        
    llDialog(id,"Please select:",opts,configchan);
}

looprate_menu(key id){
    llListen(configchan,"","","");
        
    llDialog(id,"Current loop rate is "+(string) LOOP_TIMER+" seconds.\nPlease select:",LOOP_RATES,configchan);
}


// ===========================================
// helper functions
// ===========================================

extend_timer() {      
    //Add another 2 minute to the Listen Removal timer (use when a Listen event is triggered)
    if(listenHandle == -1){
        listenHandle = llListen(chan,"","","");
    }
    listenTimer = (integer)llGetTime() + 120;
    if(loopSlides==FALSE) llSetTimerEvent(45);
}               
                                              
integer is_allowed(key id){
    key owner = llGetOwner();
    integer result = 1;
    // returns true if avatar id is allowed to access menus etc.
    if(permslevel == 0){
    // is avatar owner or in group? 
        if(!llSameGroup(id)){
            if(id != owner){
                // In SL was
                // llInstantMessage(id, "Sorry, you do not have permission to control the screen. You must be acting as a member of this group: secondlife:///app/group/"+llList2String(llGetObjectDetails(llGetKey(),[OBJECT_GROUP]),0)+"/about");
                llInstantMessage(id, "Sorry, you do not have permission to control the screen. You must be acting as a member of the group for this area");
                result = 0;
            }
                //else llSay(0,"Owner!");
        }
            //else llSay(0, "Group!");
    }
    if (result == 1) return TRUE; else return FALSE; 
}
                                
// ===========================================
// behaviour
// ===========================================
       
default
{
    link_message(integer sender_num, integer num, string message, key id) {
        llSay(0, "heard "+message); // previously also included + "from "+llKey2Name(id)
        if(!is_allowed(id)) return;
        
        if(message == "next"){
            next_slide();
        }
        else if(message == "previous"){
            previous_slide();
        }
        else if(message == "reset"){
            llSay(0, "Rogue reset command!");
            //reset();
            //display_slide(1);
        }
        else if(message == "configure"){
            //config
            //avatarkey = id;
            //avatarkey = configavatarkey;
            //avatarname = llKey2Name(avatarkey);
            llSay(0, "Rogue configure command!");
            //configure_menu(id);     
        }
        else if(message == "display_slide"){
            //display_slide(num);
            llSay(0, "Rogue display command!");
        }             
    }

    
    state_entry(){
        power_off();
    }

    touch_start(integer total_number){   
        //list pdetails = llGetParcelDetails(llGetPos(), [PARCEL_DETAILS_GROUP]);
        //llSay(0, llDumpList2String(pdetails,", "));
        //llSay(0, llGetOwner());
        //key id = llDetectedKey(0);
        
        if(deeded == FALSE){
            list pdetails = llGetParcelDetails(llGetPos(), [PARCEL_DETAILS_NAME, PARCEL_DETAILS_GROUP]);
            if(llGetOwner() != llList2String(pdetails,1)){
                    llSay(0, "Screen not yet functional (owner needs to deed it to group)");
                    llInstantMessage(llGetOwner(), "You need to deed the screen in "
                      +llList2String(pdetails,0)+" to the group!");
                    return;
                }
                else deeded = TRUE;    
        }
        
        key id = llDetectedKey(0);
        if(is_allowed(id)){
            avatarkey = id;
            avatarname = llDetectedName(0);
            //llSay(0, (string) avatarkey+" you are: "+avatarname);
            basic_menu(avatarkey);
        }

    }
        
    on_rez(integer foobar){
        llResetScript();
        reset();
    }
        
    http_response(key request_id, integer status, list metadata, string body){
        if (request_id == http_request_id)
        {
            if(body == "") 
                llInstantMessage(avatarkey, "Presentation not found! Please try again");
            else{
                // format is: relative file base\n file type extension\n number of slides\n
                contents = llParseString2List(body,["\n","|"],[]);
                currentURL = -1;
                rel_path = llList2String(contents,0);
                extension = llList2String(contents,1);
                totalURL = llList2Integer(contents,2);
                llInstantMessage(avatarkey, "Found "+(string)totalURL+" slides");
                next_slide(); 
                //if(mode==0){
                //    power_on();
                //}
                //set_video_texture();
                power_on();
            }
            
        }
        else if(request_id == avatar_request_id){
            if(body == ""){
                //llInstantMessage(avatarkey, "No presentations found! Please try again");
            }
            else{
                presents = llParseString2List(body,["\n","|"],[]);
            }
            presentation_menu(avatarkey);
        }
    }
 
    listen(integer channel, string name, key id, string message){
        //llSay(0, "heard: "+message+" on "+(string)channel+" from "+avatarname);            
        if(channel == chan) //Incoming data from menu
        {
            integer bi = llSubStringIndex(message,"(");
            if(bi != -1){
                presentation_submenu(id,(integer)(llGetSubString(message,1,llSubStringIndex(message,"-")-1)) -1);
            }
            else{
                string choice = llList2String(presents,((integer)message)-1);
                llInstantMessage(avatarkey,choice+" selected. Fetching details.");
                llListenRemove(listenUrl);
                listenUrl = -1;
                http_request_id = llHTTPRequest(base_url+get_details_script,
                    [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"],
                        "avatar="+str_replace(avatarname," ","_")+"&present="+choice); 
            }
        }
        else if(listenUrl != -1 && channel == set_urlchan) //Incoming data from "Set URL" command
        {
            llListenRemove(listenUrl);
            listenUrl = -1;
            //tempmoviename = "";
            if (llGetSubString(llToLower(message),11,17)=="youtube"){
                string yturl=".youtube.com/watch?v=";
                integer ytl=llStringLength(yturl);
                integer i=llSubStringIndex(message,yturl);
                if (i > 7) {
                    message="http://www.youtubemp4.com/video/"+left(llGetSubString(message,i+ytl,-1),"&")+".mp4";
                }
            }
            set_url(message);
            return;
        }
        else if(listenUrl != -1 && channel == setavatarchan) //Incoming data from "Set Avatar" command
        {
                llListenRemove(listenUrl);
                listenUrl = -1;
                presents = [];
                avatarname = message;
                avatar_request_id = llHTTPRequest(base_url+get_presentations_script,
                    [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"],
                        "avatar="+str_replace(avatarname," ","_")); 
            
                extend_timer();
                return;
        }
        else if(channel == configchan){ 
            integer index = llSubStringIndex(message, "s");
            if(message == POWER_OFF){
                
                power_off();
                return;
            }
            else if(message == POWER_ON){
                power_on();
                return;
            }
            else if(message == UPLOAD){
                llLoadURL(avatarkey,"Follow the link to the OpenVCE website to upload a presentation.", upload_url);
                return;
            }
            else if(message == SET_URL){
                loopSlides = FALSE;
                listenUrl = llListen(set_urlchan,"",id,"");
                llDialog(id,"Please type into local chat the URL of your choice with /"+(string)set_urlchan+" at the beginning. For example:\n   /"+(string)set_urlchan+" openvce.net",["Ok"],938);
                return;
            }
            else if(message == GO_TO_SLIDE){
                loopSlides = FALSE;
                list opts = [];
                integer i=1;
                integer last=0;
                integer inc = totalURL/5;
                if(totalURL<6) inc = 1;
                while(i<=totalURL){
                    i=i+inc;
                    opts = opts + (string) i;
                    last = i;
                }
                if(last<totalURL) opts = opts + (string)totalURL;
                
                llDialog(avatarkey,"Select slide (currently showing slide "+(string)(currentURL+1)+" of a total of "+(string)totalURL+")", opts, configchan);
                return;
            }
            else if(message == ALT_AVATAR){
                listenUrl = llListen(setavatarchan,"",id,"");
                llDialog(id,"Please type into local chat the Avatar name of your choice with /"+(string) setavatarchan+" at the beginning. For example:\n   /"+(string) setavatarchan+" Ai Austin",["Ok"],938);
                return;
            }
            else if(message == SAY_URL_ON){
                sayURL = TRUE;
                return;
            }
            else if(message == SAY_URL_OFF){
                sayURL = FALSE;    
                return;
            }
            else if(message == RESET){
                reset();
                return;
            }
            else if(message == SETUP){
                setup_menu(avatarkey);
                return;
            }
            else if(message == ALLOW_ALL_USERS){
                permslevel = 1;
                return;
            }
            else if(message == ALLOW_GROUP_ONLY){
                permslevel = 0;
                return; 
            }
            else if(message == SET_SLIDESET){
            //avatarkey = llDetectedKey(0);
            //avatarname = llDetectedName(0);
            //llInstantMessage(avatarkey,"you are: "+avatarname);
            // look up what presentations this avatar has uploaded:
                loopSlides = FALSE;
                presents = [];
                avatar_request_id = llHTTPRequest(base_url+get_presentations_script,
                    [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"],
                        "avatar="+str_replace(avatarname," ","_")); 
            
                extend_timer();   
            }
            else if(message == LOOP_ON){
                llSetTimerEvent(LOOP_TIMER);
                loopSlides = TRUE;
                llSay(0, "Slide will change every "+(string)LOOP_TIMER+" seconds.");
                return;
            }
            else if(message == LOOP_OFF){
                loopSlides = FALSE;
                llSay(0, "Slide loop disabled.");
                return;
            }
            else if(message == LOOP_RATE){
                looprate_menu(avatarkey);
                return;    
            }
            else if(message == INFO){
                llGiveInventory(avatarkey, notecardname);
                return;    
            }
            else if(index > 0){
                // ie contains "s" (seconds):
                LOOP_TIMER = (integer) llGetSubString(message,0,index);
                llSay(0, "Loop rate set to "+(string) LOOP_TIMER+" seconds.");
                if(loopSlides){
                    llSetTimerEvent(0.0);
                    llSetTimerEvent(LOOP_TIMER);
                }
            }
            else {
                loopSlides = FALSE;
                // assume message is a (slide) number:
                display_slide((integer)message);
            }
        } 
    }
    
    timer()
    {
        if(llGetTime() > listenTimer)       //If listener time expired...
        {
            llListenRemove(listenHandle);   //Remove listeners.
            llListenRemove(listenUrl);
            listenHandle = -1;
            listenUrl = -1;
            listenTimer = -1;
            if(loopSlides == FALSE) 
                llSetTimerEvent(0.0);   //Remove timer
        }
        
        if(loopSlides == TRUE && mode == 1) 
            next_slide();
    }
}

