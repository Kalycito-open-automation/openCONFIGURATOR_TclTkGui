:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: \file   openCONFIGURATOR.bat
::
:: \brief  Main file converted into openCONFIGURATOR.exe
::         which invokes the openCONFIGURATOR TCL script with the wish executable.
::
:: \copyright (c) 2014, Kalycito Infotech Private Limited
::                    All rights reserved.
::
:: Redistribution and use in source and binary forms, with or without
:: modification, are permitted provided that the following conditions are met:
::   * Redistributions of source code must retain the above copyright
::     notice, this list of conditions and the following disclaimer.
::   * Redistributions in binary form must reproduce the above copyright
::     notice, this list of conditions and the following disclaimer in the
::     documentation and/or other materials provided with the distribution.
::   * Neither the name of the copyright holders nor the
::     names of its contributors may be used to endorse or promote products
::     derived from this software without specific prior written permission.
::
:: THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
:: ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
:: WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
:: DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDERS BE LIABLE FOR ANY
:: DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
:: (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
:: LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
:: ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
:: (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF

:: Check for the OS version 64 bit or 32 bit.
IF NOT EXIST "%PROGRAMFILES(X86)%" (
SET Key=HKLM\SOFTWARE\ActiveState\ActiveTcl
)ELSE (
SET Key=HKLM\SOFTWARE\Wow6432Node\ActiveState\ActiveTcl
)


REG QUERY "%Key%" /v CurrentVersion
IF ERRORLEVEL 1 GOTO Error

FOR /F "tokens=2* delims=	 " %%A IN ('REG QUERY "%Key%" /v CurrentVersion') DO SET TclVersion=%%B
FOR /F "DELIMS=. TOKENS=1,2" %%i IN ("%TclVersion%") DO SET vs=%%i%%j

IF NOT %VS% == 86 GOTO ERRORTCLVersion

SET SubKey=%Key%\%TclVersion%

:: FOR /F "tokens=3* delims=	 " %%A IN ('REG QUERY "%SubKey%" /v ""') DO SET TclPath=%%A

tclsh86 openCONFIGURATOR


GOTO:EOF

:Error
START windows\tools\displayErrorMsg.bat 1
GOTO:EOF

:ERRORTCLVersion
START windows\tools\displayErrorMsg.bat 2 %TclVersion%
GOTO:EOF
