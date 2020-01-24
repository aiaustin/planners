; O-Plan Default World Viewer in AutoCAD - world.lsp
; Use as a basis for user provided viewers
; Austin Tate, AIAI, University of Edinburgh
; Created: 11-Feb-94, Austin Tate
; Updated: Tue Feb 21 08:59:00 1995
; 21-Feb-95: BAT - name of oplan-world-in-file internal variable altered.

; first introduce a dummy TFIN function in case of errors in loading world file

(defun C:TFIN ()
   (princ "Must have C:TFIN function in tfin.lsp file")
   (princ)
)

; the main routine to load a world - tied to the Load World viewer menu
; this version is compatible with O-Plan version 2.1 world viewing
; it loads a file of AutoLisp and runs the C:TFIN routine expected to
; be included in it.  Hence display is posible via the instructions in C:TFIN

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
  (princ)
)

(setup)
(princ "\nO-Plan World Viewer")
(princ)
