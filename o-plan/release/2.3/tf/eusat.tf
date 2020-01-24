;;;
;;;                TF for the EUSAT Satellite Control Problem
;;;                ------------------------------------------    
;;;
;;; RBK  9-Dec-91 : Adjusted to load into O-Plan.
;;; BD   8-Jan-92 : Adjusted to be a correct version of the application.
;;; RBK  9-Jan-92 : Moved begin_of keywords into contrib list for supervised
;;;                 conditions;
;;; BD   7-May-92 : Moved to ~oplan/release/demonstrations/tf as base file 
;;;                 for release
;;; BD  14-May-92 : Functional relationships and new switch connecting
;;;                 schema added to reduce the search space traversed
;;; BAT 10-Jul-92 : Debugging performed
;;; BAT 29-Mar-94 : Comments added
;;; BAT  5-Jul-94 : spelling mistakes corrected (swicth -> switch twice)
;;;               : schema Receive_Message, last supervised from 3 mot 2

types data_device = (nav_mag sun_sensor horizon_sensor space_dust 
                     digitalker CCD p_w telemetry transmitter),

      storage_device = (DSR DCE ground_buffer),

      antenna = (antenna_70cm antenna_2m),
 
      line = (line0  line1 line2  line3  line4  line5  line6  line7 
              line8  line9 line10 line11 line12 line13 line14 line15 
              line16 antenna_2m antenna_70cm ground_buffer),
  
      switch = (switch1 switch2 switch3 switch4 switch5 switch6);

;;;
;;; World statements can be:
;;;     {contents <storage_device>} = <actual-data or empty>
;;;     {mode <storage_device>} = <read or write>
;;;     {status <data_device>} = <on or off>
;;;
;;; It is assumed that the ground_buffer is an "infinite" storage device
;;; and that any amount of data can be transferred to it, so long as the
;;; mode and status are set correctly.
;;;
;;; This TF assumes a "tidy" arrangement, whereby someone who alters a mode,
;;; changes it back again.
;;;
   
;;;
;;; Always defines statements which can never be undone by action effects
;;;

always  {switch_input_can_be switch1 line0},
        {switch_input_can_be switch1 line1},
        {switch_input_can_be switch1 line2},
        {switch_input_can_be switch1 line3},
        {switch_input_can_be switch1 line4},
        {switch_output_can_be switch1 line5},

        {switch_input_can_be switch2 line5},
        {switch_output_can_be switch2 line6},
        {switch_output_can_be switch2 line7},

        {switch_input_can_be switch3 line7},
        {switch_input_can_be switch3 line8},
        {switch_input_can_be switch3 line9},
        {switch_output_can_be switch3 line10},

        {switch_input_can_be switch4 line6},
        {switch_input_can_be switch4 line12},
        {switch_input_can_be switch4 line13},
        {switch_input_can_be switch4 line15},
        {switch_output_can_be switch4 line16},

        {switch_input_can_be switch5 line16},
        {switch_output_can_be switch5 antenna_70cm},
        {switch_output_can_be switch5 antenna_2m},

        {switch_input_can_be switch6 antenna_70cm},
        {switch_input_can_be switch6 antenna_2m},
        {switch_output_can_be switch6 ground_buffer};


task mission_objectives_1;
  nodes 1 start,
        2 finish,
        3 action {monitor_spacecraft_health},
        4 action {capture CCD},
        5 action {capture p_w},
        6 action {capture space_dust},
        7 action {DCE_communicate};
  orderings 1 ---> 3, 3 ---> 4, 4 ---> 5, 5 ---> 6, 6 ---> 7, 7 ---> 2;
  effects {contents DSR} = empty at 1,
          {contents DCE} = empty at 1,
          {contents ground_buffer} = empty at 1,  

          {mode DSR} = read at 1,
          {mode DCE} = read at 1,
          {mode ground_buffer} = read at 1,

          {status nav_mag} = off at 1,
          {status sun_sensor} = off at 1, 
          {status horizon_sensor} = off at 1,
          {status space_dust} = off at 1, 
          {status telemetry} = off at 1,
          {status digitalker} = off at 1, 
          {status CCD} = off at 1,
          {status p_w} = off at 1, 
          {status transmitter} = off at 1, 

          {input switch1} = line0 at 1,  {output switch1} = line5 at 1,
          {input switch2} = line5 at 1,  {output switch2} = line7 at 1,
          {input switch3} = line7 at 1,  {output switch3} = line10 at 1,
          {input switch4} = line13 at 1, {output switch4} = line16 at 1,
          {input switch5} = line16 at 1, {output switch5} = antenna_70cm at 1,
          {input switch6} = antenna_70cm at 1,
                                         {output switch6} = ground_buffer at 1;
end_task;

task mission_objectives_2;
  nodes 1 start,
        2 finish,
        3 action {monitor_spacecraft_health},
        4 action {capture CCD},
        5 action {capture p_w},
        6 action {capture space_dust},
        7 action {DCE_communicate};
  orderings 1 ---> 3, 1 ---> 4, 1 ---> 5, 1 ---> 6, 1 ---> 7,
            3 ---> 2, 4 ---> 2, 5 ---> 2, 6 ---> 2, 7 ---> 2;
  effects {contents DSR} = empty at 1,
          {contents DCE} = empty at 1,
          {contents ground_buffer} = empty at 1,  

          {mode DSR} = read at 1,
          {mode DCE} = read at 1,
          {mode ground_buffer} = read at 1,

          {status nav_mag} = off at 1,
          {status sun_sensor} = off at 1, 
          {status horizon_sensor} = off at 1,
          {status space_dust} = off at 1, 
          {status telemetry} = off at 1,
          {status digitalker} = off at 1, 
          {status CCD} = off at 1,
          {status p_w} = off at 1, 
          {status transmitter} = off at 1, 

          {input switch1} = line0 at 1,  {output switch1} = line5 at 1,
          {input switch2} = line5 at 1,  {output switch2} = line7 at 1,
          {input switch3} = line7 at 1,  {output switch3} = line10 at 1,
          {input switch4} = line13 at 1, {output switch4} = line16 at 1,
          {input switch5} = line16 at 1, {output switch5} = antenna_70cm at 1,
          {input switch6} = antenna_70cm at 1,
                                         {output switch6} = ground_buffer at 1;
end_task;

schema Capture;
;;;------------
  vars ?data_device = ?{type data_device};
  expands {capture ?data_device};
  nodes   1 action {load_DSR ?data_device},
          2 action {dump_DSR ?data_device};
  orderings 1 ---> 2;
  conditions supervised {contents DSR} = ?data_device at 2 from [1];
end_schema;

schema Load_DSR_CCD;
;;;-----------------
  expands {load_DSR CCD};
  nodes 1 action {connect switch3 line8 line10},
        2 action {set_to DSR write},
        3 action {turn_on CCD},
        4 action {fill_up DSR CCD},
        5 action {turn_off CCD};
  orderings 1 ---> 3, 2 ---> 3, 3 ---> 4, 4 ---> 5;
  conditions supervised {input switch3} = line8 at end_of 4 from [1],
             supervised {output switch3} = line10 at end_of 4 from [1],
             supervised {mode DSR} = write at end_of 4 from [2], 
             supervised {status CCD} = on at end_of 4 from [3];
end_schema;

schema Load_DSR_p_w;
;;;-----------------
  expands {load_DSR p_w};
  nodes 1 action {connect switch3 line9 line10},
        2 action {set_to DSR write},
        3 action {turn_on p_w},
        4 action {fill_up DSR p_w},
        5 action {turn_off p_w};
  orderings 1 ---> 3, 2 ---> 3, 3 ---> 4, 4 ---> 5;
  conditions supervised {input switch3} = line9 at end_of 4 from [1],
             supervised {output switch3} = line10 at end_of 4 from [1],
             supervised {mode DSR} = write at end_of 4 from [2], 
             supervised {status p_w} = on at end_of 4 from [3];
end_schema;

schema Load_DSR_Nav_Mag;
;;;---------------------
  expands {load_DSR nav_mag};
  nodes 1 action {connect switch1 line0 line5},
        2 action {connect switch2 line5 line7},
        3 action {connect switch3 line7 line10},
        4 action {set_to DSR write},
        5 action {turn_on nav_mag},
        6 action {fill_up DSR nav_mag},
        7 action {turn_off nav_mag};
  orderings 1 ---> 5, 2 ---> 5, 3 ---> 5, 4 ---> 5, 5 ---> 6, 6 ---> 7;
  conditions supervised {input switch1} = line0 at end_of 6 from [1],
             supervised {output switch1} = line5 at end_of 6 from [1],
             supervised {input switch2} = line5 at end_of 6 from [2],
             supervised {output switch2} = line7 at end_of 6 from [2],
             supervised {input switch3} = line7 at end_of 6 from [3],
             supervised {output switch3} = line10 at end_of 6 from [3],
             supervised {mode DSR} = write at end_of 6 from [4],
             supervised {status nav_mag} = on at end_of 6 from [5];
end_schema;

;;; may also go directly via line0 -> line6 -> line 16 and an antenna to ground

schema Load_DSR_Sun_Sensor;
;;;------------------------
  expands {load_DSR sun_sensor};
  nodes 1 action {connect switch1 line1 line5},
        2 action {connect switch2 line5 line7},
        3 action {connect switch3 line7 line10},
        4 action {set_to DSR write},
        5 action {turn_on sun_sensor},
        6 action {fill_up DSR sun_sensor},
        7 action {turn_off sun_sensor};
  orderings 1 ---> 5, 2 ---> 5, 3 ---> 5, 4 ---> 5, 5 ---> 6, 6 ---> 7;
  conditions supervised {input switch1} = line1 at end_of 6 from [1],
             supervised {output switch1} = line5 at end_of 6 from [1],
             supervised {input switch2} = line5 at end_of 6 from [2],
             supervised {output switch2} = line7 at end_of 6 from [2],
             supervised {input switch3} = line7 at end_of 6 from [3],
             supervised {output switch3} = line10 at end_of 6 from [3],
             supervised {mode DSR} = write at end_of 6 from [4],
             supervised {status sun_sensor} = on at end_of 6 from [5];
end_schema;

;;; may also go directly via line1 -> line6 -> line 16 and an antenna to ground

schema Load_DSR_Horizon_Sensor;
;;;----------------------------
  expands {load_DSR horizon_sensor};
  nodes 1 action {connect switch1 line2 line5},
        2 action {connect switch2 line5 line7},
        3 action {connect switch3 line7 line10},
        4 action {set_to DSR write},
        5 action {turn_on horizon_sensor},
        6 action {fill_up DSR horizon_sensor},
        7 action {turn_off horizon_sensor};
  orderings 1 ---> 5, 2 ---> 5, 3 ---> 5, 4 ---> 5, 5 ---> 6, 6 ---> 7;
  conditions supervised {input switch1} = line2 at end_of 6 from [1],
             supervised {output switch1} = line5 at end_of 6 from [1],
             supervised {input switch2} = line5 at end_of 6 from [2],
             supervised {output switch2} = line7 at end_of 6 from [2],
             supervised {input switch3} = line7 at end_of 6 from [3],
             supervised {output switch3} = line10 at end_of 6 from [3],
             supervised {mode DSR} = write at end_of 6 from [4],
             supervised {status horizon_sensor} = on at end_of 6 from [5];
end_schema;

;;; may also go directly via line2 -> line6 -> line 16 and an antenna to ground

schema Load_DSR_Space_Dust;
;;;------------------------
  expands {load_DSR space_dust};
  nodes 1 action {connect switch1 line3 line5},
        2 action {connect switch2 line5 line7},
        3 action {connect switch3 line7 line10},
        4 action {set_to DSR write},
        5 action {turn_on space_dust},
        6 action {fill_up DSR space_dust},
        7 action {turn_off space_dust};
  orderings 1 ---> 5, 2 ---> 5, 3 ---> 5, 4 ---> 5, 5 ---> 6, 6 ---> 7;
  conditions supervised {input switch1} = line3 at end_of 6 from [1],
             supervised {output switch1} = line5 at end_of 6 from [1],
             supervised {input switch2} = line5 at end_of 6 from [2],
             supervised {output switch2} = line7 at end_of 6 from [2],
             supervised {input switch3} = line7 at end_of 6 from [3],
             supervised {output switch3} = line10 at end_of 6 from [3],
             supervised {mode DSR} = write at end_of 6 from [4],
             supervised {status space_dust} = on at end_of 6 from [5];
end_schema;

;;; may also go directly via line3 -> line6 -> line 16 and an antenna to ground

schema Load_DSR_Digitalker;
;;;------------------------
  expands {load_DSR digitalker};
  nodes 1 action {connect switch1 line4 line5},
        2 action {connect switch2 line5 line7},
        3 action {connect switch3 line7 line10},
        4 action {set_to DSR write},
        5 action {turn_on digitalker},
        6 action {fill_up DSR digitalker},
        7 action {turn_off digitalker};
  orderings 1 ---> 5, 2 ---> 5, 3 ---> 5, 4 ---> 5, 5 ---> 6, 6 ---> 7;
  conditions supervised {input switch1} = line4 at end_of 6 from [1],
             supervised {output switch1} = line5 at end_of 6 from [1],
             supervised {input switch2} = line5 at end_of 6 from [2],
             supervised {output switch2} = line7 at end_of 6 from [1],
             supervised {input switch3} = line7 at end_of 6 from [3],
             supervised {output switch3} = line10 at end_of 6 from [3],
             supervised {mode DSR} = write at end_of 6 from [4],
             supervised {status digitalker} = on at end_of 6 from [5];
end_schema;

;;; may also go directly via line4 -> line6 -> line 16 and an antenna to ground

schema Dump_DSR;
;;;-------------
  vars ?data = ?{type data_device};
  expands {dump_DSR ?data};
  nodes 1 action {package_down antenna_70cm line12},
        2 action {set_to DSR read},
        3 action {read_from DSR ?data},
        4 action {fill_up ground_buffer ?data};
  orderings 1 ---> 3, 2 ---> 3, 3 ---> 4;
  conditions supervised {input switch4} = line12 at 4 from [1],
             supervised {output switch4} = line16 at 4 from [1],
             supervised {input switch5} = line16 at 4 from [1],
             supervised {output switch5} = antenna_70cm at 4 from [1],
             supervised {input switch6} = antenna_70cm at 4 from [1],
             supervised {output switch6} = ground_buffer at 4 from [1],
             supervised {mode ground_buffer} = write at 4 from [1],
             supervised {mode DSR} = read at end_of 3 from [2];
end_schema;

schema Monitor_Spacecraft_Health;
;;;------------------------------
  expands {monitor_spacecraft_health};
  nodes 1 action {package_down antenna_70cm line13},
        2 action {turn_on telemetry},
        3 action {fill_up ground_buffer telemetry},
        4 action {turn_off telemetry};
  orderings 1 ---> 2, 2 ---> 3, 3 ---> 4;
  conditions supervised {input switch4} = line13 at 4 from [1],
             supervised {output switch4} = line16 at 4 from [1],
             supervised {input switch5} = line16 at 4 from [1],
             supervised {output switch5} = antenna_70cm at 4 from [1],
             supervised {input switch6} = antenna_70cm at 4 from [1],
             supervised {output switch6} = ground_buffer at 4 from [1],
             supervised {mode ground_buffer} = write at 4 from [1],
             supervised {status telemetry} = on at 4 from [2];
end_schema;

schema DCE_Communicate;
;;;--------------------
  expands {DCE_communicate};
  nodes 1 action {receive_message},
        2 action {transmit_message};
  orderings 1 ---> 2;
  conditions supervised {contents DCE} = message at 2 from [1];
end_schema;

schema Receive_Message;
;;;--------------------
  expands {receive_message};
  nodes 1 action {set_to DCE write},
        2 action {set_to ground_buffer read},
        3 action {turn_on transmitter},
        4 action {read_from ground_buffer message},
        5 action {fill_up DCE message},
        6 action {turn_off transmitter};
  orderings 1 ---> 3, 2 ---> 3, 3 ---> 4, 4 ---> 5, 5 ---> 6;
  conditions supervised {mode DCE} = write at 5 from [1],
             supervised {mode ground_buffer} = read at 5 from [2],
             supervised {status transmitter} = on at 5 from [3];
end_schema;

schema Transmit_Message;
;;;---------------------
  expands {transmit_message};
  nodes 1 action {package_down antenna_70cm line15},
        2 action {set_to DCE read},
        3 action {read_from DCE message},
        4 action {fill_up ground_buffer message};
  orderings 1 ---> 3, 2 ---> 3, 3 ---> 4;
  conditions supervised {input switch4} = line15 at 4 from [1],
             supervised {output switch4} = line16 at 4 from [1],
             supervised {input switch5} = line16 at 4 from [1],
             supervised {output switch5} = antenna_70cm at 4 from [1],
             supervised {input switch6} = antenna_70cm at 4 from [1],
             supervised {output switch6} = ground_buffer at 4 from [1],
             supervised {mode ground_buffer} = write at 4 from [1],
             supervised {mode DCE} = read at 4 from [2];

end_schema;

schema Capture_Nav_Mag;
;;;--------------------
  expands {capture nav_mag};
  nodes 1 action {connect switch1 line0 line5},
        2 action {connect switch2 line5 line6},
        3 action {data_dump antenna_70cm nav_mag};
  orderings 1 ---> 3, 2 ---> 3;
  conditions supervised {input switch1} = line0 at 3 from [1],
             supervised {output switch1} = line5 at 3 from [1],
             supervised {input switch2} = line5 at 3 from [2],
             supervised {output switch2} = line6 at 3 from [2];
end_schema;

schema Capture_Sun_Sensor;
;;;-----------------------
  expands {capture sun_sensor};
  nodes 1 action {connect switch1 line1 line5},
        2 action {connect switch2 line5 line6},
        3 action {data_dump antenna_70cm sun_sensor};
  orderings 1 ---> 3, 2 ---> 3;
  conditions supervised {input switch1} = line1 at 3 from [1],
             supervised {output switch1} = line5 at 3 from [1],
             supervised {input switch2} = line5 at 3 from [2],
             supervised {output switch2} = line6 at 3 from [2];
end_schema;

schema Capture_Horizon_Sensor;
;;;---------------------------
  expands {capture sun_sensor};
  nodes 1 action {connect switch1 line2 line5},
        2 action {connect switch2 line5 line6},
        3 action {data_dump antenna_70cm horizon_sensor};
  orderings 1 ---> 3, 2 ---> 3;
  conditions supervised {input switch1} = line2 at 3 from [1],
             supervised {output switch1} = line5 at 3 from [1],
             supervised {input switch2} = line5 at 3 from [2],
             supervised {output switch2} = line6 at 3 from [2];
end_schema;

schema Capture_Space_Dust;
;;;-----------------------
  expands {capture space_dust};
  nodes 1 action {connect switch1 line3 line5},
        2 action {connect switch2 line5 line6},
        3 action {data_dump antenna_70cm space_dust};
  orderings 1 ---> 3, 2 ---> 3;
  conditions supervised {input switch1} = line3 at 3 from [1],
             supervised {output switch1} = line5 at 3 from [1],
             supervised {input switch2} = line5 at 3 from [2],
             supervised {output switch2} = line6 at 3 from [2];
end_schema;

schema Capture_Digitalker;
;;;-----------------------
  expands {capture digitalker};
  nodes 1 action {connect switch1 line4 line5},
        2 action {connect switch2 line5 line6},
        3 action {data_dump antenna_2m digitalker};
  orderings 1 ---> 3, 2 ---> 3;
  conditions supervised {input switch1} = line4 at 3 from [1],
             supervised {output switch1} = line5 at 3 from [1],
             supervised {input switch2} = line5 at 3 from [2],
             supervised {output switch2} = line6 at 3 from [2];
end_schema;

schema Data_Dump;
;;;--------------
  vars ?antenna = ?{type antenna}, 
       ?device = ?{type data_device};
  expands {data_dump ?antenna ?device};
  nodes 1 action {package_down ?antenna line6},
        2 action {turn_on ?device},
        3 action {fill_up ground_buffer ?device},
        4 action {turn_off ?device};
  orderings 1 ---> 2, 2 ---> 3, 3 ---> 4;
  conditions supervised {input switch4} = line6 at 4 from [1],
             supervised {output switch4} = line16 at 4 from [1],
             supervised {input switch5} = line16 at 4 from [1],
             supervised {output switch5} = ?antenna at 4 from [1],
             supervised {input switch6} = ?antenna at 4 from [1],
             supervised {output switch6} = ground_buffer at 4 from [1],
             supervised {mode ground_buffer} = write at 4 from [1],
             supervised {status ?device} = on at 4 from [2];
end_schema;

schema Package_Down;
;;;-----------------
  vars ?antenna = ?{type antenna},
       ?line = ?{type line};
  expands {package_down ?antenna ?line};
  nodes 1 action {connect switch4 ?line line16},
        2 action {connect switch5 line16 ?antenna},
        3 action {connect switch6 ?antenna ground_buffer},
        4 action {set_to ground_buffer write};
  ;;; no orderings
end_schema;

schema Turn_On;
;;;------------
  vars ?data_device = ?{type data_device};
  expands {turn_on ?data_device};
  only_use_for_effects {status ?data_device} = on;
  conditions unsupervised {status ?data_device} = off;
end_schema;

schema Turn_Off;
;;;-------------
  vars ?data_device = ?{type data_device};
  expands {turn_off ?data_device};
  only_use_for_effects {status ?data_device} = off;
  conditions unsupervised {status ?data_device} = on;
end_schema;

schema Fill_Up_Ground;
;;;-------------------
  vars ?data = ?{not empty};
  expands {fill_up ground_buffer ?data};
  only_use_for_effects {contents ground_buffer} = ?data;
  conditions unsupervised {mode ground_buffer} = write;
end_schema;

schema Fill_Up_On_Board;
;;;---------------------
  vars ?storage_device = ?{and ?{type storage_device} ?{not ground_buffer}},
       ?data = ?{not empty};
  expands {fill_up ?storage_device ?data};
  only_use_for_effects {contents ?storage_device} = ?data;
  conditions unsupervised {contents ?storage_device} = empty,
             unsupervised {mode ?storage_device} = write;
end_schema;

schema Read_From_Ground;
;;;---------------------
  vars ?data = ?{not empty};
  expands {read_from ground_buffer ?data};
  only_use_for_effects {contents ground_buffer} = empty;
  ;;; should not be used for effect - only for expands
  ;;; ?data is assumed to be available at any time
  conditions unsupervised {mode ground_buffer} = read;
end_schema;

schema Read_From_On_Board;
;;;-----------------------
  vars ?storage_device = ?{and ?{type storage_device} ?{not ground_buffer}},
       ?data = ?{not empty};
  expands {read_from ?storage_device ?data};
  conditions unsupervised {mode ?storage_device} = read;
  effects {contents ?storage_device} = empty;
end_schema;

schema Set_To_Write_Ground;
;;;------------------------
  expands {set_to ground_buffer write};
  only_use_for_effects {mode ground_buffer} = write;
end_schema;

schema Set_To_Write_On_Board;
;;;--------------------------
  vars ?storage_device = ?{and ?{type storage_device} ?{not ground_buffer}};
  expands {set_to ?storage_device write};
  only_use_for_effects {mode ?storage_device} = write;
  conditions unsupervised {contents ?storage_device} = empty,
             unsupervised {mode ?storage_device} = read;
end_schema;

schema Set_To_Read_Ground;
;;;-----------------------
  expands {set_to ground_buffer read};
  only_use_for_effects {mode ground_buffer} = read;
end_schema;

schema Set_To_Read_On_Board;
;;;-------------------------
  vars ?storage_device = ?{and ?{type storage_device} ?{not ground_buffer}};
  expands {set_to ?storage_device read};
  only_use_for_effects {mode ?storage_device} = read;
  conditions unsupervised {mode ?storage_device} = write;
end_schema;

;;;
;;; The following schema is used to connect a pathway across the satellite
;;; through the switches. The representation of "connectedness" hopefully
;;; cuts down the amount of search required.
;;;

schema Connected_One_Switch;
;;;------------------------
;;; 
;;; Primitive for one step connect
;;;
  vars ?x = ?{and ?{type line} ?{bound}},
       ?y = ?{and ?{type line} ?{bound}},
       ?sw = ?{type switch};
  expands {connect ?sw ?x ?y};   
  only_use_for_effects {input ?sw} = ?x,
                       {output ?sw} = ?y;
  conditions only_use_for_query {switch_input_can_be ?sw ?x},
             only_use_for_query {switch_output_can_be ?sw ?y};
             ;;; note these two should be able to be only_use_if when more
             ;;; flexible handling is allowed by the O-Plan implementation
end_schema;

