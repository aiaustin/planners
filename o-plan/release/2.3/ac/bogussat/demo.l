     /* 
        File: soay:/usr/skye3/kwc/C/demo.l
        Contains: 
        Author: Ken Currie (kwc@soay)
        Created: Fri Jun 23 15:18:46 1989
        Updated: Mon Jun 26 09:37:48 1989
        Print: tbl  demo.l | ptroff -ms &
     */


B [ \t]+
I [A-Za-z][\-A-Za-z0-9]*
O [ \t]*\([ \t]*
C [ \t]*\)[ \t]*\n
    
%Start AR CL
%a 6000
%p 5000
%o 5000


%{
#include <stdio.h>
#include <suntool/sunview.h>
#include <suntool/canvas.h>
#include <ctype.h>
#include <string.h>

#define WINWIDTH	976
#define WINHEIGHT	500

#define NAVMAG 		0
#define SUNSENSOR	1
#define HORIZONSENSOR	2
#define SPACEDUST	3
#define DIGITALKER	4
#define CCD		5
#define PARTICLEWAVE	6
#define TELEMETRY	7
#define TRANSMITTER	8
#define DSR		9
#define DCE		10
#define GROUNDBUFFER	11
#define LINE0		12
#define LINE1		13
#define LINE2		14
#define LINE3		15
#define LINE4		16
#define LINE5		17
#define LINE6		18
#define LINE7		19
#define LINE8		20
#define LINE9		21
#define LINE10		22
#define LINE11		23
#define LINE12		24
#define LINE13		25
#define LINE14		26
#define LINE15		27
#define LINE16		28
#define ANT70CM		29
#define ANT2M		30
#define DOWNLINK	31
#define MESSAGE		42

#define TRANSFER	32
#define ACTIVE		33
#define STORAGE		34
#define EMPTY		35
#define FULL		36
#define READ		37
#define WRITE		38
#define ON		39
#define OFF		40
#define CONNECTED	41

#define MAXARGS		2

#define LATCH0		0
#define LATCH1		1
#define LATCH2		2
#define LATCH3		3
#define LATCH4		4
#define LATCH5		5

#define X1              0
#define Y1              1
#define X2              2
#define Y2              3

#define LINEWIDTH	5
#define SWITCHWIDTH	1

Notify_client me = (Notify_client)&me;
Notify_value  handle_input();

static Frame  frame;
static Canvas canvas;
static Pixwin *pw;
static int    routine;
static int    args_expected;
static int    args[MAXARGS];
static int    latches[6][4];

%}


%%

{O}STORAGE-DEVICE{B} {
    routine = STORAGE;
    args_expected = 1;
    BEGIN AR;
}
{O}ACTIVE-DEVICE{B} {
    routine = ACTIVE;
    args_expected = 1;
    BEGIN AR;
}
{O}TRANSFER-DEVICE{B} {
    routine = TRANSFER;
    args_expected = 1;
    BEGIN AR;
}
{O}EMPTY{B} {
    routine = EMPTY;
    args_expected = 1;
    BEGIN AR;
}
{O}FULL{B} {
    routine = FULL;
    args_expected = 2;
    BEGIN AR;
}
{O}READ-MODE{B} {
    routine = READ;
    args_expected = 1;
    BEGIN AR;
}
{O}WRITE-MODE{B} {
    routine = WRITE;
    args_expected = 1;
    BEGIN AR;
}
{O}ON{B} {
    routine = ON;
    args_expected = 1;
    BEGIN AR;
}
{O}OFF{B} {
    routine = OFF;
    args_expected = 1;
    BEGIN AR;
}
{O}CONNECTED{B} {
    routine = CONNECTED;
    args_expected = 2;
    BEGIN AR;
}
<AR>{I}/{C} {
    if (args_expected == 1) {
	args[0] = internalize(yytext);
	update_picture();
	BEGIN 0;
	return(0);
    }
    else {
	fprintf(stderr, "Too many args: %s\n", yytext);
    }
}
<AR>{I} {
    if (--args_expected > 0) args[args_expected] = internalize(yytext);
    else {
	fprintf(stderr, "Too few args: %s\n", yytext);
	BEGIN 0;
    }
}
GRID\n {
    draw_grid();
    return(0);
}
CLEAR\n {
    erase_grid();
    return(0);
}
DRAW\n {
    draw_permanent_stuff();
    return(0);
}
(BYE\n|QUIT\n) {
    printf("Cheerio\n");
    fflush(stdout);
    exit(0);
}
([^ ]) {
    return(0);
}
\b ;

%%


main(argc, argv)
int  argc;
char **argv;
{
    /* The start signal */
    printf("*\n"); fflush(stdout);

    /* Initialise overall frame, internal canvas, and pixwin structure */
    frame  = window_create(0,
			   FRAME,
			   FRAME_LABEL, "BogusSat: wiring harness diagram",
			   WIN_X,  100, WIN_Y, 100,
			   WIN_WIDTH,  WINWIDTH, WIN_HEIGHT, WINHEIGHT,
			   0);
    canvas = window_create(frame, CANVAS, 0);
    pw     = canvas_pixwin(canvas);

    /* Initialise function to be called whenever there's input */
    notify_set_input_func(me, handle_input, 0);

    /* The latches must be somewhere to start with (assumed later on) */
    initialize_latches();

    /* This is the place to draw the basic wiring diagram... */
    draw_permanent_stuff();

    /* Hang about like a spare dick at a wedding... */
    window_main_loop(frame);

    exit(0);
}


/*
Function to be called to process characters from Standard Input 
*/
Notify_value handle_input(client, fd)
Notify_client client;
int fd;
{
    yylex();
    return NOTIFY_DONE;
}

    
/*
A routine to redraw the picture
*/
update_picture()
{
    switch (routine) {
      case TRANSFER: 	transfer_device(args[0]);	break;
      case ACTIVE:   	active_device(args[0]);		break;
      case STORAGE:  	storage_device(args[0]);	break;
      case EMPTY:    	empty_device(args[0]);		break;
      case FULL:     	full_device(args[1],args[0]);	break;
      case READ:     	read_mode(args[0]);		break;
      case WRITE:    	write_mode(args[0]);		break;
      case ON:       	activate(args[0]);		break;
      case OFF:     	deactivate(args[0]);		break;
      case CONNECTED:	connected(args[1],args[0]);	break;
      default:
	fprintf(stderr, "Error: switch in update_picture!\n");
	break;
    }
}


/*
A routine to put in place the unchanging portion of the diagram
*/
draw_permanent_stuff()
{
    int device;

    for (device = NAVMAG; device <= GROUNDBUFFER; device++) {
	deactivate(device);
    }

    activate(DSR);
    activate(DCE);
    activate(GROUNDBUFFER);

    line(75,   45, 160, 45, LINEWIDTH);		/* from navmag 		*/
    line(105,  80, 160, 80, LINEWIDTH);		/* from sun sensor	*/
    line(135, 115, 160, 115, LINEWIDTH);	/* from horizon sensor	*/
    line(105, 150, 160, 150, LINEWIDTH);	/* from space dust	*/
    line(105, 185, 160, 185, LINEWIDTH);	/* from digitalker	*/
    line(50,  220, 415, 220, LINEWIDTH);	/* from ccd		*/
    line(130, 255, 415, 255, LINEWIDTH);	/* from particle wave	*/
    line(100, 290, 575, 290, LINEWIDTH);	/* from telemetry	*/
    line(115, 325, 505, 325, LINEWIDTH);	/* from transmitter	*/       

    line(220, 115, 290, 115, LINEWIDTH);	/* line 5		*/
    line(465, 220, 505, 220, LINEWIDTH);	/* into DSR		*/
    line(535, 220, 575, 220, LINEWIDTH);	/* from DSR		*/
    line(330, 185, 415, 185, LINEWIDTH);	/* line 7		*/
    line(330,  45, 525, 45, LINEWIDTH);		/* line 6, first horiz	*/
    line(525,  45, 525, 185, LINEWIDTH);	/* line 6, vertical	*/
    line(525, 185, 575, 185, LINEWIDTH);	/* line 6, second horiz	*/
    line(540, 325, 575, 325, LINEWIDTH);	/* from DCE		*/

    line(635, 255, 700, 255, LINEWIDTH);	/* line 16 		*/
    line(740, 200, 800, 200, LINEWIDTH);	/* 70cm antenna		*/
    line(740, 310, 800, 310, LINEWIDTH);	/* 2m   antenna		*/
    line(840, 255, 895, 255, LINEWIDTH);	/* into ground buffer	*/

    text(200, 410, "DSR:");		/* Table of memory devices */
    text(200, 430, "DCE:");		/* and their contents and  */
    text(178, 450, "BUFFER:");		/* modes		   */
    text(250, 380, "Mode");
    text(340, 380, "Contents");
    
    text(750, 195, "70 cm");		/* Labels for two antenna  */
    text(750, 330, " 2 m");		/* lines                   */

    empty_device(DSR);			/* All storage devices are */
    empty_device(DCE);			/* assumed to be initially */
    empty_device(GROUNDBUFFER);		/* empty                   */

    read_mode(DSR);			/* Also assumed to be in   */
    read_mode(DCE);			/* read mode               */
    read_mode(GROUNDBUFFER);

    update_latches();			/* Draw current latches     */

    text(150, 40,  "0");		/* Line labels              */
    text(150, 75,  "1");
    text(150, 110, "2");
    text(150, 145, "3");
    text(150, 180, "4");
    text(150, 215, "8");
    text(150, 250, "9");
    text(150, 285, "13");
    text(150, 320, "14");
    text(250, 110, "5");
    text(535, 110, "6");
    text(370, 180, "7");
    text(560, 215, "12");
    text(560, 320, "15");
    text(655, 250, "16");
    text(465, 215, "10");
}


/*
A routine to draw a grid with interline spacing of 10 screen units
*/
draw_grid()
{
    put_grid(10, PIX_SRC);
}


/*
A routine to erase a grid with interline spacing of 10 screen units
*/
erase_grid()
{
    put_grid(10, PIX_NOT(PIX_SRC) & PIX_DST);
}


/*
A routine to dump out a grid on the image.
Single parameter indicates amount of inter-line spacing.
*/
put_grid(increment, operation)
int increment, operation;
{
    int i, j;

    /* Horizontal lines */
    for (i = 0; i < WINHEIGHT; i = i + increment) {
	pw_vector(pw, 0, i, WINWIDTH, i, operation, 1);
    }

    /* Vertical lines */
    for (j = 0; j < WINWIDTH; j = j + increment) {
	pw_vector(pw, j, 0, j, WINHEIGHT, operation, 1);
    }
}


/*
Declaration of a transfer device
*/
transfer_device(device)
int device;
{
    fprintf(stderr, "Transfer device declared\n");
}


/*
Declaration of an active device
*/
active_device(device)
int device;
{
    fprintf(stderr, "Active device declared\n");
}


/*
Declaration of a storage device
*/
storage_device(device)
int device;
{
    fprintf(stderr, "Storage device declared\n");
}


/*
A routine to turn on each of the specified devices
*/
activate(device)
int device;
{
    switch (device) {
      case NAVMAG:	 text(20,   50, "NAVMAG"); 		break;
      case SUNSENSOR:	 text(20,   85, "SUN SENSOR"); 		break;
      case HORIZONSENSOR:text(20,  120, "HORIZON SENSOR"); 	break;
      case SPACEDUST:	 text(20,  155, "SPACE DUST"); 		break;
      case DIGITALKER:	 text(20,  190, "DIGITALKER"); 		break;
      case CCD: 	 text(20,  225, "CCD"); 		break;
      case PARTICLEWAVE: text(20,  260, "PARTICLE WAVE"); 	break;
      case TELEMETRY: 	 text(20,  295, "TELEMETRY"); 		break;
      case TRANSMITTER:	 text(20,  330, "TRANSMITTER"); 	break;
      case DSR: 	 text(510, 225, "DSR"); 		break;
      case DCE: 	 text(510, 330, "DCE"); 		break;
      case GROUNDBUFFER: text(900, 260, "BUFFER"); 		break;
      default: fprintf(stderr, "Error: switch in activate!\n");	break;
    }
}


deactivate(device)
int device;
{
    switch (device) {
      case NAVMAG:	 text(20,   50, "navmag"); 		break;
      case SUNSENSOR:	 text(20,   85, "sun sensor"); 		break;
      case HORIZONSENSOR:text(20,  120, "horizon sensor"); 	break;
      case SPACEDUST:	 text(20,  155, "space dust"); 		break;
      case DIGITALKER:	 text(20,  190, "digitalker"); 		break;
      case CCD: 	 text(20,  225, "ccd"); 		break;
      case PARTICLEWAVE: text(20,  260, "particle wave"); 	break;
      case TELEMETRY: 	 text(20,  295, "telemetry"); 		break;
      case TRANSMITTER:	 text(20,  330, "transmitter"); 	break;
      case DSR: 	 text(510, 225, "dsr"); 		break;
      case DCE: 	 text(510, 330, "dce"); 		break;
      case GROUNDBUFFER: text(900, 260, "buffer"); 		break;
      default: fprintf(stderr, "Error: switch in deactivate!");	break;
    }
}


empty_device(device)
int device;
{
    switch (device) {
      case DSR: 	 text(340, 410, "nil                  "); break;
      case DCE: 	 text(340, 430, "nil                  "); break;
      case GROUNDBUFFER: text(340, 450, "nil                  "); break;
      default:
	fprintf(stderr, "Error: impossible device in empty_device!\n");
	break;
    }
}


full_device(device, stuff)
int device, stuff;
{
    char *string;

    switch (stuff) {
      case NAVMAG:		string = "Navigation data     "; break;
      case SUNSENSOR: 		string = "Sun sensor data     "; break;
      case HORIZONSENSOR: 	string = "Horizon sensor data "; break;
      case SPACEDUST: 		string = "Space dust data     "; break;
      case DIGITALKER:		string = "Digital speech      "; break;
      case CCD:	       		string = "CCD Camera picture  "; break;
      case PARTICLEWAVE:	string = "Particle wave data  "; break;
      case TELEMETRY:		string = "Spacecraft telemetry"; break;
      case MESSAGE:		string = "Message from ground "; break;
      case TRANSMITTER:		string = "Message from ground "; break;
      default:
	fprintf(stderr, "Error: impossible memory contents in full_device\n");
	break;
    }

    switch (device) {
      case DSR: 	 text(340, 410, string);		break;
      case DCE: 	 text(340, 430, string);		break;
      case GROUNDBUFFER: text(340, 450, string);		break;
      default:
	fprintf(stderr, "Error: impossible device in full_device!\n");
	break;
    }
}


read_mode(device)
int device;
{
    switch (device) {
      case DSR: 	 text(250, 410, "read "); 		break;
      case DCE: 	 text(250, 430, "read "); 		break;
      case GROUNDBUFFER: text(250, 450, "read "); 		break;
      default:
	fprintf(stderr, "Error: impossible device in read_mode!\n");
	break;
    }
}


write_mode(device)
int device;
{
    switch (device) {
      case DSR: 	 text(250, 410, "write"); 		break;
      case DCE: 	 text(250, 430, "write"); 		break;
      case GROUNDBUFFER: text(250, 450, "write"); 		break;
      default:
	fprintf(stderr, "Error: impossible device in write_mode!\n");
	break;
    }
}


connected(lineA, lineB)
int lineA, lineB;
{
    if (lineB == LINE5) switch (lineA) {
      case LINE0:
	refresh_latch(LATCH0, X1, 160, Y1, 45);
	break;
      case LINE1:
	refresh_latch(LATCH0, X1, 160, Y1,  80);
        break;
      case LINE2:
	refresh_latch(LATCH0, X1, 160, Y1, 115);
        break;
      case LINE3:
	refresh_latch(LATCH0, X1, 160, Y1, 150);
        break;
      case LINE4:
	refresh_latch(LATCH0, X1, 160, Y1, 185);
        break;
      default:
	fprintf(stderr, "Impossible connection to line5 requested!\n");
	break;
    }
    else if (lineA == LINE5) switch (lineB) {
      case LINE6:
	refresh_latch(LATCH1, X2, 330, Y2,  45);
        break;
      case LINE7:
	refresh_latch(LATCH1, X2, 330, Y2, 185);
        break;
      default:
	fprintf(stderr, "Impossible connection from line5 requested!\n");
	break;
    }
    else if (lineB == LINE10) switch (lineA) {
      case LINE7:
	refresh_latch(LATCH2, X1, 415, Y1, 185);
        break;
      case LINE8:
	refresh_latch(LATCH2, X1, 415, Y1, 220);
        break;
      case LINE9:
	refresh_latch(LATCH2, X1, 415, Y1, 255);
        break;
      default:
	fprintf(stderr, "Impossible connection to line10 requested!\n");
	break;
    }
    else if (lineB == LINE16) switch (lineA) {
      case LINE6:
	refresh_latch(LATCH3, X1, 575, Y1, 185);
        break;
      case LINE12:
	refresh_latch(LATCH3, X1, 575, Y1, 220);
        break;
      case LINE13:
	refresh_latch(LATCH3, X1, 575, Y1, 290);
        break;
      case LINE15:
	refresh_latch(LATCH3, X1, 575, Y1, 325);
        break;
      default:
	fprintf(stderr, "Impossible connection to line16 requested!\n");
	break;
    }
    else if (lineA == LINE16) switch (lineB) {
      case ANT70CM:
	refresh_latch(LATCH4, X2, 740, Y2, 200);
	break;
      case ANT2M:
	refresh_latch(LATCH4, X2, 740, Y2, 310);
	break;
      default:
	fprintf(stderr, "Impossible connection from line16 requested!\n");
	break;
    }
    else if (lineB == DOWNLINK) switch (lineA) {
      case ANT70CM:
	refresh_latch(LATCH5, X1, 800, Y1, 200);
	break;
      case ANT2M:
	refresh_latch(LATCH5, X1, 800, Y1, 310);
	break;
      default:
	fprintf(stderr, "Impossible connection to downlink requested!\n");
	break;
    }
    else fprintf(stderr, "Impossible connection requested!\n");
}


refresh_latch(latch, indexA, valueA, indexB, valueB)
int latch, indexA, valueA, indexB, valueB;
{
    erase(latches[latch][X1], latches[latch][Y1],
	  latches[latch][X2], latches[latch][Y2], SWITCHWIDTH);
    
    latches[latch][indexA] = valueA;
    latches[latch][indexB] = valueB;

    line(latches[latch][X1], latches[latch][Y1],
	 latches[latch][X2], latches[latch][Y2], SWITCHWIDTH);    
}


update_latches()
{
    int latch;

    for (latch = LATCH0; latch <= LATCH5; latch++) {
	erase(latches[latch][X1], latches[latch][Y1],
	     latches[latch][X2], latches[latch][Y2], SWITCHWIDTH);

	line(latches[latch][X1], latches[latch][Y1],
	     latches[latch][X2], latches[latch][Y2], SWITCHWIDTH);
    }
}


/*
Defines initial latch states
*/
initialize_latches()
{
    latches[LATCH0][X1] = 160;		/* Latch0: line0 -> line5  */
    latches[LATCH0][Y1] =  45;		
    latches[LATCH0][X2] = 220;		
    latches[LATCH0][Y2] = 115;		

    latches[LATCH1][X1] = 290;		/* Latch1: line5 -> line7  */
    latches[LATCH1][Y1] = 115;
    latches[LATCH1][X2] = 330;
    latches[LATCH1][Y2] = 185;

    latches[LATCH2][X1] = 415;		/* Latch2: line7 -> line10 */
    latches[LATCH2][Y1] = 185;
    latches[LATCH2][X2] = 465;
    latches[LATCH2][Y2] = 220;

    latches[LATCH3][X1] = 575;		/* Latch3: line13 -> line16 */
    latches[LATCH3][Y1] = 290;
    latches[LATCH3][X2] = 635;
    latches[LATCH3][Y2] = 255;

    latches[LATCH4][X1] = 700;		/* Latch4: line16 -> 70cm   */
    latches[LATCH4][Y1] = 255;
    latches[LATCH4][X2] = 740;
    latches[LATCH4][Y2] = 200;

    latches[LATCH5][X1] = 800;		/* Latch6: 70cm -> buffer   */
    latches[LATCH5][Y1] = 200;
    latches[LATCH5][X2] = 840;
    latches[LATCH5][Y2] = 255;
}


internalize(device)
char *device;
{
    if      ( strcmp(device, "NAVMAG") == 0 ) 	 	return(NAVMAG);
    else if ( strcmp(device, "SUN-SENSOR") == 0 ) 	return(SUNSENSOR);
    else if ( strcmp(device, "HORIZON-SENSOR") == 0 ) 	return(HORIZONSENSOR);
    else if ( strcmp(device, "SPACE-DUST") == 0 ) 	return(SPACEDUST);
    else if ( strcmp(device, "DIGITALKER") == 0 ) 	return(DIGITALKER);
    else if ( strcmp(device, "CCD") == 0 ) 		return(CCD);
    else if ( strcmp(device, "PARTICLE-WAVE") == 0 )	return(PARTICLEWAVE);
    else if ( strcmp(device, "TELEMETRY") == 0 ) 	return(TELEMETRY);
    else if ( strcmp(device, "TRANSMITTER") == 0 ) 	return(TRANSMITTER);
    else if ( strcmp(device, "DSR") == 0 )		return(DSR);
    else if ( strcmp(device, "DCE") == 0 ) 		return(DCE);
    else if ( strcmp(device, "BUFFER") == 0 )   	return(GROUNDBUFFER);
    else if ( strcmp(device, "LINE0") == 0 )		return(LINE0);
    else if ( strcmp(device, "LINE1") == 0 )		return(LINE1);
    else if ( strcmp(device, "LINE2") == 0 )		return(LINE2);
    else if ( strcmp(device, "LINE3") == 0 )		return(LINE3);
    else if ( strcmp(device, "LINE4") == 0 )		return(LINE4);
    else if ( strcmp(device, "LINE5") == 0 )		return(LINE5);
    else if ( strcmp(device, "LINE6") == 0 )		return(LINE6);
    else if ( strcmp(device, "LINE7") == 0 )		return(LINE7);
    else if ( strcmp(device, "LINE8") == 0 )		return(LINE8);
    else if ( strcmp(device, "LINE9") == 0 )		return(LINE9);
    else if ( strcmp(device, "LINE10") == 0 )		return(LINE10);
    else if ( strcmp(device, "LINE11") == 0 )		return(LINE11);
    else if ( strcmp(device, "LINE12") == 0 )		return(LINE12);
    else if ( strcmp(device, "LINE13") == 0 )		return(LINE13);
    else if ( strcmp(device, "LINE14") == 0 )		return(LINE14);
    else if ( strcmp(device, "LINE15") == 0 )		return(LINE15);
    else if ( strcmp(device, "LINE16") == 0 )		return(LINE16);
    else if ( strcmp(device, "70CM") == 0 )	        return(ANT70CM);
    else if ( strcmp(device, "2M") == 0 )	        return(ANT2M);
    else if ( strcmp(device, "DOWN-LINK") == 0 )	return(DOWNLINK);
    else if ( strcmp(device, "MESSAGE") == 0 )		return(MESSAGE);
    else fprintf(stderr, "Bad argument to internalize: %s\n", device);
}


/*
A routine to draw a line, using pw_vector
*/
line(x1, y1, x2, y2, thickness)
int x1, y1, x2, y2, thickness;
{
    pw_vector(pw, x1, y1, x2, y2, PIX_SRC, 1);

    while (--thickness > 0) {
	pw_vector(pw, x1+thickness, y1+thickness,
		  x2+thickness, y2+thickness, PIX_SRC, 1);
    }
    
}


/*
A routine to dump some text, using pw_text
*/
text(x, y, string)
int x, y;
char *string;
{
    pw_text(pw, x, y, PIX_SRC, 0, string);
}


/*
A routine to erase a line, using pw_vector
*/
erase(x1, y1, x2, y2, thickness)
int x1, y1, x2, y2, thickness;
{
    pw_vector(pw, x1, y1, x2, y2, PIX_NOT(PIX_SRC) & PIX_DST, 1);

    while (--thickness > 0) {
	pw_vector(pw, x1+thickness, y1+thickness,
		  x2+thickness, y2+thickness, PIX_NOT(PIX_SRC) & PIX_DST, 1);
    }


}
