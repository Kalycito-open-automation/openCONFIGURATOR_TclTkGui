@ECHO OFF

IF _%~1_==_1_ GOTO Error
IF _%~1_==_2_ GOTO ERRORTCLVersion

GOTO:EOF

:Error
@echo on
@echo Error! ActiveTcl 8.6 not installed
@echo ActiveTcl 8.6 can be downloaded at http://www.activestate.com/activetcl
@echo NOTE: You always need to install the 32 bit variant in order to run openCONFIGURATOR!
@echo For Windows 7/8 users: start the TCL/TK setup with Run as Administrator... 
@echo off
PAUSE
GOTO:EOF


:ERRORTCLVersion
@echo on
@ECHO Current TCL version installed is %2%. Install ActiveTCL 8.6.x
@ECHO ActiveTcl 8.6 can be downloaded at http://www.activestate.com/activetcl
@ECHO NOTE: Download only 32 bit variant in order to run openCONFIGURATOR!
@echo off
PAUSE

