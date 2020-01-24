// Copyright 2010 -  AIAI, School of Informatics, University of Edinburgh 
// SP Pizzicato - http://www.vue.ed.ac.uk & http://www.inf.ed.ac.uk
// last updated: 2010-02-11

integer DISPLAY_ON_SIDE = 1;
//key BLANK = TEXTURE_BLANK;

default
{
    link_message(integer sender_num, integer num, string message, key id) { 
        llSay(0, "Screen heard "+message);
        if(message == "power_on"){
             llSetPrimitiveParams([PRIM_BUMP_SHINY,DISPLAY_ON_SIDE,PRIM_SHINY_NONE,PRIM_BUMP_NONE,PRIM_COLOR,DISPLAY_ON_SIDE,<1,1,1>,1.0,PRIM_MATERIAL,PRIM_MATERIAL_PLASTIC,PRIM_TEXTURE,DISPLAY_ON_SIDE,TEXTURE_BLANK,llGetTextureScale(DISPLAY_ON_SIDE),llGetTextureOffset(DISPLAY_ON_SIDE),llGetTextureRot(DISPLAY_ON_SIDE)]);
        }
        else if(message == "power_off"){
             llSetPrimitiveParams([PRIM_BUMP_SHINY,DISPLAY_ON_SIDE,PRIM_SHINY_LOW,PRIM_BUMP_NONE,PRIM_COLOR,DISPLAY_ON_SIDE,<0.1,0.1,0.1>,1.0,PRIM_MATERIAL,PRIM_MATERIAL_PLASTIC,PRIM_TEXTURE,DISPLAY_ON_SIDE,TEXTURE_BLANK,llGetTextureScale(DISPLAY_ON_SIDE),llGetTextureOffset(DISPLAY_ON_SIDE),llGetTextureRot(DISPLAY_ON_SIDE)]);
        }
        else if(message == "set_texture"){
            llSetTexture(id,DISPLAY_ON_SIDE);
        }
    }
    
}
