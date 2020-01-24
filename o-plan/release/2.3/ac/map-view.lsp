; Austin Tate, AIAI, University of Edinburgh
; Created: 14-Jan-93, Austin Tate
; 19-Jan-94: Austin Tate: Updated for dynamic layer display and multiple maps
; 10-Feb-94: Austin Tate: dynamic object drawing to state layer added
; 15-Feb-94: Brian Drabble: updated to reflect Pacfica Requirements
; 11-Mar-94: Austin Tate: topo-multiple included to give denser colour
; 30-Mar-94: Austin Tate: World Input facilities included
;  5-May-94: Austin Tate: GT and AT icons introduced
; 21-Feb-95: Austin Tate: name of oplan-world-in-file internal variable altered
; Updated: Tue Feb 21 09:00:52 1995

; layers are map topo(graphy) notes state and the base layer 0
; all routines which draw on any named layer must reset the current layer to 0
; and the current drawing colour to "bylayer"

(defun set-defaults ()
  (command "layer" "set" 0) (command "")
  (command "colour" "bylayer")
)

; state layer is cleared automatically before a new load-world

(defun erase-state-objects ( / ents)
  ; get all objects on dynamic state layer
  (setq ents (ssget "X" '((8 . "state"))))
  (if (/= ents nil)
     (progn (princ "Clearing state layer ... ") (terpri)
            (command "erase" ents)
            (command "")
     )
  )
  (princ)
)

; first introduce a dummy TFIN function in case of errors in loading world file

(defun C:TFIN ()
   (princ "Must have C:TFIN function in tfin.lsp file")
   (princ)
)

; the main routine to load a world - tied to the Load World viewer menu
; this version is compatible with O-Plan version 2.1 world viewing
; loads from current directory, which will normally be $OPLANTMPDIR if
; viewer is entered via oplan-acad-world-view script

(setq oplan-world-in-file "tfin.lsp")

(defun C:LOAD-WORLD ( / f)
   (setq f (open oplan-world-in-file "r"))
   (if (/= f nil)
     ;then
     (progn
        (close f)
        (erase-state-objects)
        (princ "Loading World ")
        (princ oplan-world-in-file)
        (princ " ...") (terpri)
        (load oplan-world-in-file)
        (c:tfin)
     )
     ;else
     (progn
        (princ "No" oplan-world-in-file "file exists")
     )
   )
   (princ)
)

;;; curently prints all objects of given block type from ANY layer.
;;; could be selective by, e.g., STATE layer only

(defun attxyout (attnum d f / x)
   (setq x (cdr (assoc attnum d)))
   (prin1 (car x) f)   ;x position
   (write-char 32 f)   ;sp
   (prin1 (cadr x) f)  ;y position
   (write-char 32 f)   ;sp
)

(defun blocksout (btype bore attflag f / sl slen i e d et)
  ; block type=string, bore=2 for block or 0 for acad simple entity
  ; attflag=t if attributes are expected, f is output file
  ; only applies to state layer with code 8
  (setq sl (ssget "X" (list (cons 8 "state") (cons bore btype))))
  (setq slen (if sl (sslength sl) 0))
  (setq i 0)
  (while (< i slen)
     (setq e (ssname sl i))
     (setq d (entget e))
     (print btype f)
     (attxyout 10 d f)
     ; startpoint is assoc 10
     (write-char 32 f)   ;sp
     ; if LINE entity output endpoint as assoc 11
     (if (= btype "LINE") (attxyout 11 d f))
     (if (and attflag (= (cdr (assoc 66 d)) 1))
        (progn
           (setq et btype)
           (while (/= et "SEQEND")
              (setq e (entnext e)) ;ename of next sub-entity (ATTRIB or SEQEND)
              (setq d (entget e))  ;actual sub-entity descriptor
              (setq et (cdr (assoc 0 d))) ;ATTRIB or SEQEND
              (if (= et "ATTRIB")
                 (progn
                    (prin1 (cdr (assoc 2 d)) f) ; attribute tag
                    (write-char 61 f)   ;=
                    (prin1 (cdr (assoc 1 d)) f) ; attribute value
                    (write-char 59 f)   ;semi-colon
                    (write-char 32 f)   ;sp
                 )
              )
           )
        )
     )
     (setq i (1+ i))
  )
)

(setq oplan-world-out-file "tfout.tf")

(defun C:SAVE-WORLD ( / f)
   (setq f (open oplan-world-out-file "w"))
   (if (/= f nil)
     ;then
     (progn
        (princ "Saving World to ")
        (princ oplan-world-out-file)
        (princ " ...") (terpri)
  (print "task acad;" f)
  (blocksout "GT" 2 t f)      ; ground transports
  (blocksout "AT" 2 t f)      ; air transports
  (blocksout "TOWN" 2 t f)    ; old version of ground transports
  (blocksout "AIRPORT" 2 t f) ; old version of air transprorts
  (print "end_schema" f)
  (write-char 10 f) ; crlf on any system from acad
        (close f)
     )
     ;else
     (progn
        (princ "cannot write to" oplan-world-out-file)
     )
   )
   (princ)
)

; global variables for colours, etc
(setq mud-brown 37)
(setq light-brown 44)
(setq dark-brown 48)
(setq grass-green 56)
(setq forest-green 98)
(setq water-blue 145)
(setq dark-grey 251)
(setq light-grey 254)
(setq rock-grey 253)
(setq sand-yellow 51)

; variables for scaling icons, etc - normally redefined as area-specific
(setq icon-x 0.05)       ; x scale factor for icons
(setq icon-y 0.05)       ; y scale factor for icons
(setq text-large 0.05)   ; units for large text
(setq text-small 0.025)  ; units for small text
(setq topo-multiple 1)   ; density of topography hatching 0.1 is 10 times
                         ;                       as dense as default of 1

(defun hi-res () (setq topo-multiple 0.1) (princ))

(defun lo-res () (setq topo-multiple 1) (princ))

; insert text notes on note layer

(defun note (text units x y)
  (command "layer" "set" "notes") (command "")
  (command "text" (list x y) units 0 text)
  (set-defaults)
  (princ)
)

; lookup tables for locations, location icons and object name icons

(setq loc-xy-table
 '(
   ; PRECiS
   ("ABYSS"       . "140.38,20.14")
   ("BARNACLE"    . "140.18,20.52")
   ("CALYPSO"     . "140.36,20.82")
   ("DELTA"       . "140.80,20.58")
   ("EXODUS"      . "140.85,20.23")
   ("BAY_BRIDGE"  . "140.69,20.51")
   ("ROAD_AB"     . "140.24,20.26")
   ("ROAD_BC"     . "140.20,20.78")
   ("ROAD_CD"     . "140.69,20.78")
   ("ROAD_BD"     . "140.33,20.36")
   ("ROAD_AE"     . "140.61,20.17")
   ("ROAD_AD"     . "140.40,20.30")
   ; IFD-3
   ("COLUMBO"     . "245,275")
   ("JAFFNA"      . "260,325")
   ("KANDY"       . "255,275")
   ("BADULLA"     . "270,265")
   ("GALLE"       . "255,250")
   ("TRINCOMALEE" . "285,300")
   ; shared
   ("HONOLULU"    . "141.00,20.90")
  )
)

(defun location (loc / ass) ; get x,y position of location
   (setq ass (assoc (strcase loc) loc-xy-table))
   (cond ((/= ass nil) (cdr ass))
         (t "0,0"    )
   )
)

(setq loc-icon-table
 '(
   ; PRECiS
   ("ABYSS"       . "town")
   ("BARNACLE"    . "town")
   ("CALYPSO"     . "airport")
   ("DELTA"       . "airport")
   ("EXODUS"      . "town")
   ("BAY_BRIDGE"  . "none")
   ; IFD-3
   ("COLUMBO"     . "airport")
   ("JAFFNA"      . "town")
   ("KANDY"       . "town")
   ("BADULLA"     . "town")
   ("GALLE"       . "town")
   ("TRINCOMALEE" . "town")
   ; shared
   ("HONOLULU"    . "airport")
  )
)

(defun icon-loc (loc / ass) ; get drawing block name for location
   (setq ass (assoc (strcase loc) loc-icon-table))
   (cond ((/= ass nil) (cdr ass))
         (t "none"    )
   )
)

(setq obj-icon-table
 '(
   ("GT" . "gt")
   ("TR" . "gt")
   ("BU" . "gt")
   ("B7" . "at")
   ("C1" . "at")
   ("C5" . "at")
   ("KC" . "at")
   ("AT" . "at")
   ("HE" . "at")
   ("AH" . "at")
   ("MH" . "at")
  )
)

(defun icon-name (obj / st ass) ; get drawing block name for object
   (if (>= (strlen obj) 2)
       ; then
       (progn (setq st (strcase (substr obj 1 2)))
              (setq ass (assoc st obj-icon-table))
              (cond ((/= ass nil) (cdr ass))
                    (t "none"    )
              )
       )
    ;else
    "none"
   )
)

; draw an object at a given location on state layer

(defun at (obj loc / icon)
  (setq icon (icon-name obj))
  (command "layer" "set" "state") (command "")
  (if (eq icon "none")
     (command "text" (location loc) text-small 0 obj)
     ; else
     (command "insert" icon (location loc) icon-x icon-y 0 obj)
  )
  (set-defaults)
  (princ)
)

(defun at-loc (loc / icon rot)
  ; no rotation at present - could parameterise
  (setq rot 0)
  (setq icon (icon-loc loc))
  (command "layer" "set" "map") (command "")
  (if (eq icon "none")
     (command "text" (location loc) text-small rot loc)
     ; else
     (command "insert" icon (location loc) icon-x icon-y rot loc)
  )
  (set-defaults)
  (princ)
)

(defun get-area-1 ()
  ; IFD-2 Scenario
  (command "limits" "0,0" "1000,1000")
  (setq icon-x 1)
  (setq icon-y 1)
  (setq text-large 3)
  (setq text-small 1)
  ; viewports
  ; map
  ; topography
  ; area details

  (set-defaults)
  (princ)
)

(defun get-area-2 ()
  ; IFD-3 Scenario
  (command "limits" "0,0" "1200,1000")
  (setq icon-x 1)
  (setq icon-y 1)
  (setq text-large 8)
  (setq text-small 3)

  ; viewports
  (command "zoom" "all")
  ; map
  (command "layer" "set" "map") (command "")
  (command "insert" "map" "0,0" 1 1 0)
  (set-defaults)

  ; area details
  (at-loc "Columbo")
  (at-loc "Jaffna")
  (at-loc "Kandy")
  (at-loc "Badulla")
  (at-loc "Galle")
  (at-loc "Trincomalee")
  (note "Sri Lanka" text-small 220 240)
  (note "Singapore" text-large 1000 125)
  (set-defaults)
  (princ)
)

(defun get-area-3 ( / last lake crater-rim)
  ; PRECiS/Pacifica
  (command "limits" "140.00,20.00" "141.00,21.00")
  (setq icon-x 0.01)
  (setq icon-y 0.01)
  (setq text-large 0.03)
  (setq text-small 0.015)

  ; viewports

  ; topography
  (command "layer" "set" "topo") (command "")
  ; marsh
  (command "colour" grass-green)
  (command "pline" "140.60,20.54" "arc" 
                                   "sec" "140.65,20.54" "140.69,20.52"
                                   "sec" "140.71,20.50" "140.73,20.50"
                                   "sec" "140.72,20.46" "140.76,20.45"
                                   "sec" "140.82,20.42" "140.83,20.37"
                                   "sec" "140.80,20.34" "140.73,20.31"
                                   "sec" "140.66,20.33" "140.62,20.35"
                                   "sec" "140.57,20.41" "140.57,20.50"
                                   "sec" "140.60,20.50" "140.60,20.54"
                                   "close")
  (setq last (entlast))
  (command "hatch" "grass" (* topo-multiple 0.001) 0 last "")
  (command "erase" last) (command "") ; erase outline pline
(princ "marsh ")
  ; lake
  (command "colour" water-blue)
  (command "pline" "140.46,20.73" "arc" 
                                   "sec" "140.48,20.76" "140.50,20.77"
                                   "sec" "140.54,20.77" "140.55,20.75"
                                   "sec" "140.55,20.73" "140.53,20.71"
                                   "sec" "140.49,20.71" "140.46,20.73"
                                   "close")

  (setq lake (entlast))
  (command "hatch" "net" (* topo-multiple 0.005) 45 lake "")
(princ "lake ")
  ; river
  (command "pline" "140.51,20.70"  "arc" 
                                   "sec" "140.52,20.68" "140.51,20.64"
                                   "sec" "140.51,20.61" "140.53,20.58" 
                                   "sec" "140.56,20.54" "140.60,20.54" 
                                   "sec" "140.65,20.54" "140.69,20.52" 
                                   "sec" "140.71,20.50" "140.73,20.50"
                                   "")
(princ "river ")
  ; crater rim
   (command "colour" dark-brown)
   (command "pline" "140.49,20.67"   "140.54,20.67" "arc"
                                    "sec" "140.59,20.70" "140.62,20.74"
                                    "sec" "140.59,20.80" "140.52,20.82"
                                    "sec" "140.45,20.81" "140.39,20.77"
                                    "sec" "140.40,20.73" "140.43,20.70"
                                    "line" "close")
  (setq crater-rim (entlast))
  (command "hatch" "net,o" (* topo-multiple 0.005) 0 crater-rim lake "")
(princ "rim ")
  ; high ground of volcano
  (command "colour" light-brown)
  (command "pline" "140.67,20.77" "arc" 
                                   "sec" "140.62,20.69" "140.48,20.66"
                                   "sec" "140.44,20.66" "140.40,20.67"
                                   "sec" "140.36,20.68" "140.35,20.72"
                                   "sec" "140.38,20.80" "140.49,20.84"
                                   "sec" "140.60,20.82" "140.67,20.77"
                                   "close")
  (setq last (entlast))
  (command "hatch" "dots,o" (* topo-multiple 0.005) 0 last crater-rim "")
                              ; "o" to hatch outer ring only
(princ "high ")

  ; mud flats and volcanic area
  (command "colour" mud-brown)
  (command "pline" "140.44,20.65" "arc" 
                                   "sec" "140.42,20.61" "140.42,20.57"
                                   "sec" "140.44,20.54" "140.45,20.50"
                                   "sec" "140.42,20.44" "140.37,20.41"
                                   "sec" "140.31,20.39" "140.28,20.42"
;                                   "sec" "140.25,20.48" "140.21,20.56"
                                   "sec" "140.16,20.59" "140.13,20.60"
                                   "sec" "140.13,20.65" "140.17,20.69"
                                   "sec" "140.25,20.70" "140.34,20.71"
                                   "sec" "140.35,20.67" "140.40,20.65"
                                   "line" "close")
  (setq last (entlast))
  (command "hatch" "net" (* topo-multiple 0.005) 45 last "")
  (command "erase" last) (command "") ; erase outline pline
(princ "mud ")
  ; Abysian Forest
  (command "colour" forest-green)
  (command "pline" "140.50,20.38" "arc" 
                                   "sec" "140.63,20.31" "140.66,20.27"
                                   "sec" "140.66,20.21" "140.62,20.19"
                                   "sec" "140.56,20.21" "140.52,20.25"
                                   "sec" "140.47,20.29" "140.46,20.35"
                                   "sec" "140.47,20.37" "140.50,20.38"
                                   "close")
  (setq last (entlast))
  (command "hatch" "grass" (* topo-multiple 0.0005) 0 last "")
  (command "erase" last) (command "") ; erase outline pline
(princ "forest ")
  ; cliffs
  (command "colour" dark-grey)
  (command "pline" "140.51,20.93" "arc"
                                  "sec" "140.59,20.91" "140.66,20.88"
                                  "sec" "140.73,20.83" "140.83,20.76"
                                  "sec" "140.87,20.70" "140.86,20.64"
                                  "")
  (setq last (entlast))
;  (command "hatch" "net" (* topo-multiple 0.005) 0 last "")
;  (command "erase" last) (command "") ; erase outline pline 
                   
  (set-defaults)

  ; map
  (command "layer" "set" "map") (command "")
  (command "pline" "140.51,20.93" "arc"
                                   "sec" "140.35,20.86" "140.22,20.86"
                                   "sec" "140.18,20.85" "140.17,20.82"
                                   "sec" "140.15,20.78" "140.16,20.76"
                                   "sec" "140.13,20.69" "140.09,20.63"
                                   "sec" "140.10,20.57" "140.10,20.54"
                                   "sec" "140.09,20.50" "140.10,20.50"
                                   "sec" "140.18,20.41" "140.16,20.31"
				   "sec" "140.25,20.15" "140.32,20.10"
				   "sec" "140.36,20.10" "140.41,20.08"
				   "sec" "140.60,20.12" "140.75,20.16"
				   "sec" "140.88,20.19" "140.91,20.24"
				   "sec" "140.88,20.27" "140.85,20.29"
				   "sec" "140.87,20.32" "140.83,20.37"
				   "sec" "140.91,20.41" "140.94,20.45"
				   "sec" "140.90,20.49" "140.76,20.45"
				   "sec" "140.72,20.46" "140.73,20.50"
				   "sec" "140.83,20.56" "140.85,20.60"
                                   "sec" "140.86,20.66" "140.80,20.74"
;                                  "sec" "140.69,20.86" "140.61,20.88"
				   "sec" "140.57,20.90" "140.53,20.92"
                                   "close")

  (command "pline" "140.35,20.13"  "arc"
                                   "sec" "140.23,20.28" "140.20,20.42"
                                   "sec" "140.15,20.52" "140.15,20.63"
                                   "sec" "140.20,20.78" "140.22,20.80"
                                   "sec" "140.27,20.82" "140.35,20.84"
                                   "sec" "140.45,20.87" "140.50,20.88"
                                   "sec" "140.51,20.88" "140.65,20.81"
                                   "sec" "140.72,20.75" "140.77,20.68"
                                   "sec" "140.83,20.62" "140.81,20.58"
                                   "sec" "140.77,20.55" "140.71,20.51"
                                   "sec" "140.66,20.52" "140.60,20.51"
                                   "sec" "140.56,20.49" "140.48,20.42"
                                   "sec" "140.42,20.37" "140.41,20.25"
                                   "close")

  (command "pline" "140.35,20.13"  "arc"
                                   "sec" "140.49,20.14" "140.56,20.16"
                                   "sec" "140.69,20.18" "140.86,20.22"
                                   "")

  (command "pline" "140.20,20.40"  "arc"
                                   "sec" "140.27,20.37" "140.37,20.37"
                                   "sec" "140.46,20.46" "140.57,20.50"
                                   "")
  (set-defaults)

  ; area details
  (at-loc "Abyss")
  (at-loc "Barnacle")
  (at-loc "Calypso")
  (at-loc "Delta")
  (at-loc "Exodus")
  (note "Pacifica" text-large 140.05 20.07)

  (set-defaults)
  (princ)
)

(defun get-area-4 ()
  ; Scotland
  (command "limits" "0,500" "1000,1000")
  (setq icon-x 1)
  (setq icon-y 1)
  (setq text-large 8)
  (setq text-small 3)
  ; viewports
  ; map
  ; topography
  ; area details

  (set-defaults)
  (princ)
)

(defun get-area-5 ()
  ; UK - uses Scotland as sub-part
  (get-area-4)
  (command "limits" "0,0" "1000,1000")
  (setq icon-x 1)
  (setq icon-y 1)
  (setq text-large 8)
  (setq text-small 3)
  ; viewports
  ; map
  ; topography
  ; area details

  (set-defaults)
  (princ)
)

(defun get-area-6 ()
  ; World
  ; map on -180,-90 .. 180,90 with half a hemisphere added on to right and top
  ; making it -180,-90 .. 360,180
  ; then there is a notes/icons area off the main map of size 100 X 100
  ; at 400,0 .. 500,100
  (command "limits" "-180,-90" "500,180")
  (setq icon-x 1)
  (setq icon-y 1)
  (setq text-large 8)
  (setq text-small 3)
  ; viewports
  ; map
  ; topography
  ; area details

  (set-defaults)
  (princ)
)

(defun setup ()
  (setvar "MENUECHO" 3)
  (setvar "CMDECHO" 0)
  (setvar "UCSICON" 0)
  (setvar "BLIPMODE" 0)
  (command "setvar" "aperture" 2)
  (command "pickbox" 2)
  ; set osnap aperture and pickbox smaller than 5
  ;to avoid picking wrong line in revsurf
  (command "fill" "off")

  ; set up drawing environment and layers for map display
  ; layer 0 is default drawing layer with colour black ("white" in AutoCAD)
  (command "layer" "new" "map" "colour" "white" "map") (command "")
  (command "layer" "new" "topo" "colour" light-brown "topo") (command "")
  (command "layer" "new" "notes" "colour" "blue" "notes") (command "")
  (command "layer" "new" "state" "colour" "red" "state") (command "")

  (set-defaults)
  (princ)
)

(setup)
(princ "\nMap World Viewer")
(princ)
