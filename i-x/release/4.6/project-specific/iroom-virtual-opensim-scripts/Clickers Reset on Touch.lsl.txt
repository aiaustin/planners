default
{
    state_entry()
    {
        llSetText("Clear Clickers",<0,0,0>,1.0);
    }

    touch_start(integer total_number)
    {
        llSay(34, "clear");
        llSay(0, "All clickers cleared");
    }
}
