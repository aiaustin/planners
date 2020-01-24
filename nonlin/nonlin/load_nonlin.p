;;; for version 15.5 onwards

global vars
    nlversion     = 'Poplog V15.5 1-Dec-2002',
    nonlinprefix  = 'nonlin/',
    nonlinpostfix = nullstring,
    libprefix     = 'poplib/',
    libpostfix    = '.p',
    tfprefix      = 'nonlin/tf/',
    tfpostfix     = '.tf';

;;; this is used in showfile in nonlin.p
;;; should be able to get it from stty
;;; This value will be OK if you have been in an out of ved. Default 24
global vars screenlength = vedscreenlength;
screenlength=>

true -> pop_longstrings;
2500000 -> popmemlim;

compile_mode :pop11 +oldvar;
;;; prevent input and output locals defaulting to lvars

;;; stop autoloading of symbols used in TF files in Poplog 15.5
global vars syntax ---> <: :> ;

lib pop2;
sysunprotect("&&");
compile('nonlin/nonlin.p');
compile('nonlin/tfinfo.p');
nonmac tfinfo -> nonmac prinfo;
false -> draw_flag;
false -> context_flag;
;;;    compile('poplib/saver.p');
