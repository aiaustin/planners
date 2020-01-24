// Copyright 2009 -  University of Edinburgh School of Informatics 
// Davie Munro - www.vue.ed.ac.uk & www.inf.ed.ac.uk
//
// SlideShow Keynote System
//
default
{
    touch_start(integer total_number)
    {
        llMessageLinked(LINK_SET, -1, "next", llDetectedKey(0));
    }
}