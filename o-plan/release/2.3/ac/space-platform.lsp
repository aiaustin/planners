; Space Platform Domain Display
; Austin Tate, AIAI
; Created: 16-Feb-90
; Updated: Tue Feb 21 08:56:23 1995
; 12-Dec-92 modified to use proper entity/pick points in entsel format
;           within revsurf for version 11 of AutoCAD
; 30-Mar-94 load-plan routine is added.
; 21-Feb-95 name of oplan-world-in-file internal variable altered.

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

(defun module (len x y z rot / pt1 pt2 pt3 pt4 pt5 pt6 pt7 sel1 sel2
                                    lent plent rent rotpoint)
  ; draw a module of length len units with joint point at x y z
  ; draw horizontal to right and rotate as required (if rot /= 0)
  (setq rotpoint (list x y z))
  (setq x (+ x 10))
  (setq pt1 (list (- x 20) y z)) ; origin of axis of revolution
  ; overhang to ensure we can pick up this line later
  (setq pt2 (list (+ x len) y z))  ; temporary axis of revolution end point
  (command "line" pt1 pt2) (command "")
  (setq lent (entlast))
  (setq sel1 (list lent pt1))
  (setq pt2 (list x (+ y 5) z)) ; origin of 3dpoly for cylinder
  (setq pt3 (list (+ x 5) (+ y 5) z))
  (setq pt4 (list (+ x 10) (+ y 15) z))
  (setq pt5 (list (+ x (- len 10)) (+ y 15) z))
  (setq pt6 (list (+ x (- len 5)) (+ y 5) z))
  (setq pt7 (list (+ x len) (+ y 5) z))
  (command "3dpoly" pt2 pt3 pt4 pt5 pt6 pt7) (command "")
  (setq plent (entlast))
  (setq sel2 (list plent pt2))
  (command "revsurf" sel2 sel1 0) (command "") 
  (setq rent (entlast))
  (cond ((/= rot 0) (progn (command "rotate" rent)
                           (command "")
                           (command rotpoint rot)
                    )
        )
  )
  (command "erase" plent lent) (command "") ; erase 2 construction lines
  (princ)
)

; only tube can be drawn in 3 dimensions, rot =-1 and +1 trigger z dimension;
; z tube does not work at present as revsurf pick points are too near together

(defun z_tube (len x y z dir / pt1 pt2 lent lent2 sel1 sel2)
  ; for dir=-1 and dir=1 only
  
  (defun z_dir (i)
    (+ (* i dir) z)
  )

  (setq z (z_dir 10))
  (setq pt1 (list x y z))
  (command "line" pt1 (list x y (z_dir len))) ; axis of revolution
  (command "")
  (setq lent (entlast))
  (setq sel1 (list lent pt1))
  (setq pt2 (list (+ x 5) y z))
  ; line gives mesh, use 3dpoly for simple outlines
  (command "3dpoly" pt2 (list (+ x 5) y (z_dir len)))
  (command "")
  (setq lent2 (entlast))
  (setq sel2 (list lent2 pt2))
  (command "revsurf" sel2 sel1 0)
  ; erase 2 construction lines
  (command "erase" lent lent2) (command "")
  (princ)
)

(defun tube (len x y z rot / pt1 pt2 lent lent2 rent rotpoint sel1 sel2)
  ; draw tube of length len units with joint point at x y z
  ; draw horizontal to right and rotate as required
  (cond ((or (= rot 1) (= rot -1)) (z_tube len x y z rot))
     (t (progn
           (setq rotpoint (list x y z))
           (setq x (+ x 10))
           (setq pt1 (list (- x 20) y z))
           (command "line" pt1 (list (+ x len) y z)) ; axis of revolution
           (command "")
           (setq lent (entlast))
           (setq sel1 (list lent pt1))
           (setq pt2 (list x (+ y 5) z))
           ; line gives mesh, use 3dpoly
           (command "3dpoly" pt2 (list (+ x len) (+ y 5) z))
           (command "")
           (setq lent2 (entlast))
           (setq sel2 (list lent2 pt2))
           (command "revsurf" sel2 sel1 0)
           (command "")
           (setq rent (entlast))
           (cond ((/= rot 0) (progn (command "rotate" rent)
                                    (command "")
                                    (command rotpoint rot)
                             )
                 )
           )
           (command "erase" lent lent2) (command "")
        )
     )
  )
  (princ)
)

(defun antenna (width twist x y z rot / pt1 pt2 lent plent rent sel1 sel2
                                        rotpoint1 rotpoint2)
  ; draw an antenna with width given with joint point at x y z
  ; draw horizontal to right and rotate as required (if rot /= 0) for joint,
  ; then twist about joint point to required angle (if twist /= 0)
  (setq rotpoint1 (list x y z))
  (cond ((< rot 0) (setq rot (+ rot 360))))
  (cond ((and (>= rot   0) (< rot  90)) (setq rotpoint2 (list (+ x 10) y z)))
        ((and (>= rot  90) (< rot 180)) (setq rotpoint2 (list x (+ y 10) z)))
        ((and (>= rot 180) (< rot 270)) (setq rotpoint2 (list (- x 10) y z)))
        ((and (>= rot 270) (< rot 360)) (setq rotpoint2 (list x (- y 10) z)))
     (t (print "antenna - only rotations of -360 to nearly 360 accepted"))
  )
  (setq x (+ x 10))
  (setq pt1 (list (- x 20) y z)) ; origin of axis of revolution
  ; overhang to ensure we can pick up this line later
  (setq pt2 (list (+ x 15) y z))  ; temporary axis of revolution end point
  (command "line" pt1 pt2) (command "")
  (setq lent (entlast))
  (setq sel1 (list lent pt1))
  (setq pt2 (list x y z)) ; origin of 3dpoly for antenna outline
  (command "3dpoly" pt2
                    (list (+ x 1) (+ y 1) z)
                    (list (+ x 10) (+ y 1) z)
                    (list (+ x 12) (+ y (/ width 4)) z)
                    (list (+ x 13) (+ y (/ width 3)) z)
                    (list (+ x 15) (+ y (/ width 2)) z)
                    (list (+ x 13) (+ y (/ width 4)) z)
                    (list (+ x 12) (+ y 2) z)
                    (list (+ x 25) y z)
  )
  (command "")
  (setq plent (entlast))
  (setq sel2 (list plent pt2))
  (command "revsurf" sel2 sel1 0) (command "") 
  (setq rent (entlast))
  (cond ((/= rot 0) (progn (command "rotate" rent)
                           (command "")
                           (command rotpoint1 rot)
                    )
        )
  )
  (cond ((/= twist 0) (progn (command "rotate" rent)
                           (command "")
                           (command rotpoint2 twist)
                    )
        )
  )
  (command "erase" plent lent) (command "") ; erase 2 construction lines
  (princ)
)

(defun pallet (width x y z rot / zz ent rotpoint)
  ; pallet centred on joint point x y z with width given
  (setq rotpoint (list x y z))
  (setq x (+ x 10))
  (command "setvar" "thickness" width)
  (setq zz (- z (/ width 2)))
  (command "pline" (list x (- y 10) zz)
                   (list x (+ y 10) zz)
                   (list (+ x 5) (+ y 20) zz)
                   (list (+ x 15) (+ y 20) zz)
                   (list (+ x 15) (+ y 15) zz)
                   (list (+ x 5) (+ y 15) zz)
                   (list (+ x 5) (- y 15) zz)
                   (list (+ x 15) (- y 15) zz)
                   (list (+ x 15) (- y 20) zz)
                   (list (+ x 5) (- y 20) zz)
                   "close"
  )
  ; no (command "") needed as close properly terminates
  (setq ent (entlast))
  (cond ((/= rot 0) (progn (command "rotate" ent)
                           (command "")
                           (command rotpoint rot)
                    )
        )
  )
  (command "setvar" "thickness" 0)
  (princ)
)

(defun joint (x y z)
  (command "setvar" "thickness" 20)
  (command "solid" (list (- x 10) (- y 10) (- z 10))
                   (list (- x 10) (+ y 10) (- z 10))
                   (list (+ x 10) (- y 10) (- z 10))
                   (list (+ x 10) (+ y 10) (- z 10))
  )
  (command "")
  (command "setvar" "thickness" 0)
  (princ)
)

(defun one_truss (x y z)
  ; one unit of truss as a single polyline that can be joined to others 
  (command (list x (- y 10) (+ z 10))
           (list (+ x 20) (- y 10) (+ z 10))
           (list (+ x 20) (+ y 10) (+ z 10))
           (list x (+ y 10) (+ z 10))
           (list x (- y 10) (+ z 10))

           (list x (- y 10) (- z 10))
           (list x (+ y 10) (- z 10))
           (list (+ x 20) (+ y 10) (- z 10))
           (list x (- y 10) (+ z 10))
           (list x (- y 10) (- z 10))

           (list (+ x 20) (- y 10) (- z 10))
           (list (+ x 20) (- y 10) (+ z 10))
           (list (+ x 20) (+ y 10) (+ z 10))
           (list (+ x 20) (+ y 10) (- z 10))
           (list (+ x 20) (- y 10) (- z 10))

           (list x (- y 10) (- z 10))
           (list x (+ y 10) (- z 10))
           (list (+ x 20) (- y 10) (+ z 10))
           (list x (+ y 10) (+ z 10))
           (list (+ x 20) (+ y 10) (- z 10))

           (list x (- y 10) (- z 10))
           (list (+ x 20) (- y 10) (+ z 10))

  )
  ; do not end 3dpoly, so all unit trusses are in one 3dpoly
)

(defun truss (units x y z rot / i ent rotpoint)
  ; draw truss with joint position x y z, unit sections long
  ; rotate as required
  (setq rotpoint (list x y z))
  (setq x (+ x 10))
  (setq i 0)
  (command "3dpoly")
  (repeat units (one_truss (+ x (* i 20)) y z)
                (setq i (+ i 1))
  )
  (command "")
  (setq ent (entlast))
  (cond ((/= rot 0) (progn (command "rotate" ent)
                           (command "")
                           (command rotpoint rot)
                    )
        )
  )
  (princ)
)

(defun radiator (len width x y z rot / pt1 plent i half_w rotpoint)
  (setq rotpoint (list x y z))
  (setq x (+ x 10))
  (setq pt1 (list x y z))
  (setq half_w (/ width 2))
  (command "3dpoly" pt1
                   (list x y z)
                   (list x (+ y half_w) z)
  )
  (setq i half_w)
  (repeat half_w (command (list (+ x len) (+ y i) z)
                          (list (+ x len) (+ y (- i 2)) z)
                          (list x (+ y (- i 2)) z)
                 )
                 (setq i (- i 2))
  )
  (command (list x y z))
  (command "")
  (setq plent (entlast))
  (cond ((/= rot 0) (progn (command "rotate" plent)
                           (command "")
                           (command rotpoint rot)
                    )
        )
  )
  (princ)
)

(defun solar_panel (len width rot x y z dir / half_w ent rotpoint)
  ; solar panel with joint point at x y z
  ; projects into z dimension +ve if dir =+1, -ve if dir =-1
  ; rot is about z axis and gives panel angle from normal  

  (defun z_dir (i)
    (+ (* i dir) z)
  )

  (setq rotpoint (list x y z))
  (setq z (z_dir 10))
  (setq half_w (/ width 2))
  (command "line"  (list x y z) (list x y (z_dir 5))) (command "")
  (command "3dface" (list (- x half_w) y (z_dir 5))
                    (list (- x half_w) y (z_dir len))
                    (list (+ x half_w) y (z_dir len))
                    (list (+ x half_w) y (z_dir 5))
  )
  (command "")
  (setq ent (entlast))
  (cond ((/= rot 0) (progn (command "rotate" ent)
                           (command "")
                           (command rotpoint rot)
                    )
        )
  )

  (princ)
)

(defun note (text units x y)
  (command "layer" "set" "text") (command "")
  (command "text" (list x y) units 0 text)
  (command "layer" "set" 0) (command "")
  (princ)
)

; shuttle assumes a block with insertion point being an airbridge from the
; open shuttle bay.  Rotation is like rest of objects in the package

(defun shuttle (x y z rot)
  (command "insert"  "shuttle" (list x y z) 1 1 rot)
  (princ)
)

; joints are 20 units across centred on their x y z position
; they have 6 "ports" A is at 12 o'clock, B at 3, C at 6 and D at 9 o'clock
;                     E is on top (z +ve), F is underneath (z -ve)

(defun large_platform ()
  ; ensure setup called first

  (joint 100 150 0) ; A
  (joint 180 150 0) ; B
  (joint 300 150 0) ; C
  (joint 360 150 0) ; D
  (joint 440 150 0) ; E
  (joint 520 150 0) ; F
  (joint 300  30 0) ; G
  (joint 360  30 0) ; H

  (tube 40 300 150 0   0) ; port B of joint C
  (tube 10 300  30 0 -90) ; port C of joint G
  (tube 10 360  30 0 -90) ; port C of joint H

  (truss 3 100 150 0 0) ; 3 sections on port B of joint A
  (truss 5 180 150 0 0) ; 5 sections on port B of joint B
  (truss 3 360 150 0 0) ; 3 sections on port B of joint D
  (truss 3 440 150 0 0) ; 3 sections on port B of joint E

  (module 100 300 150 0 -90) ; port C of joint C
  (module 100 360 150 0 -90) ; port C of joint D
  (module  40 300  30 0   0) ; port B of joint G
  (module  60 300 150 0  90) ; port A of joint C
  (module  40 360 150 0  90) ; port A of joint D

  (radiator 60 20 100 150 0  90) ; port A of joint A
  (radiator 60 20 100 150 0 -90) ; port C of joint A

  (solar_panel 120 40 20 180 150 0  1) ; port E of joint B 
  (solar_panel 120 40 20 180 150 0 -1) ; port F of joint B 
  (solar_panel 120 40 20 440 150 0  1) ; port E of joint E
  (solar_panel 120 40 20 440 150 0 -1) ; port F of joint E
  (solar_panel 120 40 20 520 150 0  1) ; port E of joint F
  (solar_panel 120 40 20 520 150 0 -1) ; port F of joint F

  (antenna 80 20 520 150 0 -90) ; port C of joint F
  (antenna 20 20 180 150 0 -90) ; port C of joint B

; (note "Large Platform" 10 440 10)
  (command "redrawall")
  (princ)
)

; (shuttle 300 220 0 90) would be a typical call for large_platform shuttle

(defun small_platform ()
  ; ensure setup called first

  (joint 500 250 200) ; A

  (module 80 500 250 200 180) ; port D of joint A

  (radiator 30 10 500 250 200 90) ; port A of joint A
  (solar_panel 100 20 20 500 250  200  1) ; port E of joint A
  (solar_panel 100 20 20 500 250  200 -1) ; port F of joint A 

  (antenna 40 20 500 250 200 -90) ; port B of joint A

; (note "Small Platform" 10 440 25)
  (command "redrawall")
  (princ)
)

; (shuttle 410 250 200 180) would be a typical call for small_platform shuttle

; note vports with names "1PORT", "3PORTS1" and "3PORTS2" are available in
; "space_platform". vpoints are 0.2,-0.4,1  0,0,1 and 0,-1,0 in 3ports1 or 2

(defun setup ()
  ; set up drawing environment for space platform display
  (command "layer" "new" "text" "colour" "green" "text") (command "")
  (command "setvar" "aperture" 2)
  (command "pickbox" "aperture" 2)
  ; set osnap aperture and pickbox smaller than 5
  ;to avoid picking wrong line in revsurf
  (command "fill" "off")
  (princ)
)

(princ "\nSpace Platform Domain Simulation")
(princ)
