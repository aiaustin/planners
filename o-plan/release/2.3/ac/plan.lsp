; O-Plan/Nonlin AutoCAD Interface lisp package
; 21-Feb-90: Austin Tate, AIAI
; 14-Feb-94: BAT - added load-plan function
; 21-Feb-95: BAT - name of oplan-plan-in-file internal variable altered.

; first introduce a dummy TFIN function in case of errors in loading world file

(defun C:TFIN ()
   (princ "Must have C:TFIN function in tfin.lsp file")
   (princ)
)

; the main routine to load a plan - tied to the Load Plan viewer menu
; this version is compatible with O-Plan version 2.1 plan viewing
; loads from current directory, which will normally be $OPLANTMPDIR if
; viewer is entered via oplan-acad-plan-view script

(setq oplan-plan-in-file "tfin.lsp")

(defun C:LOAD-PLAN ( / f)
   (setq f (open oplan-plan-in-file "r"))
   (if (/= f nil)
     ;then
     (progn
        (close f)
        (princ "Loading Plan ")
        (princ oplan-plan-in-file)
        (princ " ...") (terpri)
        (load oplan-plan-in-file)
        (c:tfin)
     )
     ;else
     (progn
        (princ "No" oplan-plan-in-file "file exists")
     )
   )
   (princ)
)

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
  (setq sl (ssget "X" (list (cons bore btype))))
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
              (setq e (entnext e)) ; ename of next sub-entity (ATTRIB or SEQEND)
              (setq d (entget e))  ; actual sub-entity descriptor
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

(defun polyout (f / sl slen e d i lastd)
  (setq sl (ssget "X" (list (cons 0 "POLYLINE"))))
  (setq slen (if sl (sslength sl) 0))
  (setq i 0)
  (while (< i slen)
     (setq e (ssname sl i))
     (setq d (entget e))
     (print "LINE" f)
     (write-char 32 f)   ;sp
     (setq e (entnext e)) ; ename of first VERTEX
     (setq d (entget e))  ; actual VERTEX descriptor
     (attxyout 10 d f) ; polyline start position
     (setq lastd d)
     (setq et "VERTEX")
     (while (/= et "SEQEND")
        (setq e (entnext e)) ; ename of next sub-entity (VERTEX or SEQEND)
        (setq d (entget e))  ; actual sub-entity descriptor
        (setq et (cdr (assoc 0 d))) ;VERTEX or SEQEND
        (if (= et "VERTEX") (setq lastd d))
     )
     (attxyout 10 lastd f) ; x,y of last point in polyline
     (setq i (1+ i))
  )
)

(defun C:TFOUT (/ f)
  (setq f (open "tfout.txt" "w")) ; could replace with "a" to append to file
  (blocksout "SCHEMA" 2 t f)
  (blocksout "NODE" 2 t f)
  (blocksout "DUMMY" 2 nil f)
  (blocksout "LINE" 0 nil f)
  (polyout f)
  (blocksout "CONDITIONS" 2 t f)
  (blocksout "EFFECTS" 2 t f)
  (print "END" f)
  (write-char 10 f) ; crlf on any system from acad
  (close f)
  (prin1) ;prints and returns null string, so exits quietly
)

(defun C:PICK-ITEM ( / pt1 pt2 sl slen i ent e d et att)
  (setq pt1 (getpoint      "\nPick item first corner: "))
  (setq pt2 (getcorner pt1 "\n         second corner: "))
  (princ "\n")
  (setq sl (ssget "C" pt1 pt2))
  (setq slen (if sl (sslength sl) 0))
  (setq i 0)
  (setq att "nothing")
  (if (= slen 1)
     (progn
        (setq ent (ssname sl i))
        (setq e ent)
        (setq d (entget e))
        (redraw ent 3) ;highlight
        (if (= (cdr (assoc 0 d)) "INSERT")
           (setq att (cdr (assoc 2 d))) ;block name
         (setq att (cdr (assoc 0 d))) ;else entity type
        )
        (if (= (cdr (assoc 66 d)) 1)
           (progn
             (setq et att)
             (while (/= et "SEQEND")
               (setq e (entnext e)) ; ename of next sub-ent (ATTRIB or SEQEND)
               (setq d (entget e))  ; actual sub-entity descriptor
               (setq et (cdr (assoc 0 d))) ;ATTRIB or SEQEND
               (if (= et "ATTRIB")
                  (progn
                     (setq att (strcat att " "))
                     (setq att (strcat att (cdr (assoc 1 d))))
                  )
               )
             )
           )
        )
;       (command "delay" 500) ' half a second
;       (redraw ent 4) ;de-highlight
     )
   (princ "\nMore than one item picked") ; else do nothing
  )
  (princ "\nPicked ") (princ att) ; could replace with a (command "sh" att)
  (princ)   
)

; call Initialise from Nonlin/O-Plan menu in AUTOCAD to get same effect
(defun startup ()
   (setvar "MENUECHO" 3)
   (setvar "CMDECHO" 0)
   (setvar "UCSICON" 0)
   (setvar "BLIPMODE" 0)
   (princ)
)

(princ "\nO-Plan/Nonlin AUTOCAD Interface")
(princ)
