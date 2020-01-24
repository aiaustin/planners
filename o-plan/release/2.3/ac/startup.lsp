;;; startup file to read in .lsp file in name of drawing
;;; 21-Feb-90 Austin Tate

(defun S::STARTUP ( / s f)
   (setq s (getvar "dwgname"))
   (setq f (open (strcat s ".lsp") "r"))
   (cond ((/= f nil) (progn (close f)
                   (princ "Loading lisp ") (princ s)
                   (load s)
            )
         )
   )
   (setvar "MENUECHO" 3)
   (setvar "CMDECHO" 0)
   (setvar "UCSICON" 0)
   (setvar "BLIPMODE" 0)
   (princ)
)

(princ)
