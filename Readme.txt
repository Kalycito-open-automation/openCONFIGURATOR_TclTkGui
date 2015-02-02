
                      openCONFIGURATOR v1.4.1

  openCONFIGURATOR is an open-source tool for easy setup and configuration of 
  any POWERLINK network. It ideally complements openPOWERLINK, the open-source 
  POWERLINK protocol stack for master and slave

----------------------------------------------------------
                        License
----------------------------------------------------------
    Copyright © 2015 - Kalycito Infotech Private Limited.
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the copyright holders nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDERS BE LIABLE FOR ANY
  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


----------------------------------------------------------
                     RELEASE NOTE
----------------------------------------------------------
openCONFIGURATOR 1.4.1 is a minor release that includes bug fixes and 
enhancements on the library and the GUI.

--------------------------------------------------------
                     BUG FIXES
--------------------------------------------------------
- OD empty after node delete.
- Persist ForceToCDC flag.
- Process image padding var wrong format.
- SaveAs action for a converted project fails.
- Bookkeep the path of the input XDD/XDC during project upgrade.
- Other minor fixes, stability and memory leak issues.


--------------------------------------------------------
              BACKWARD COMPATIBILITY
--------------------------------------------------------
- The API is not backward compatible to older versions of openCONFIGURATOR.
- The projects created with v1.4.0 or later cannot be opened by older versions 
of openCONFIGURATOR.

------------------------------------------------------------
              KNOWN ISSUES and WORK AROUND
------------------------------------------------------------
- Currently projects created with earlier versions of openCONFIGURATOR are not supported.
- In Windows only 32 bit is supported, install only Tcl/Tk 32 bit version
- The PDO mapping table does not auto calculate datasize for the complex datatypes.
   Workaround:
   1) Set Auto Generate to 'No'.
   2) Set the datasize in the mapping entry.
   3) Set Auto Generate back to 'Yes'
- MN PRes and PReq cannot be configured for simultaneous reception by a CN.
- Skipping of offset is not allowed for PDO mapping.
   Workaround:
    1) Set Auto Generate to 'No'.
    2) Create the CN and MN mapping with the required values.
    3) Build the project to generate the CDC.

------------------------------------------------------------
                      SUPPORT
------------------------------------------------------------
- Refer the user-manual available in the below link
 http://sourceforge.net/projects/openconf/files/openCONFIGURATOR/1.4/1.4.1
- For more information and help on using openCONFIGURATOR, please post us on the 
  help forum at http://sourceforge.net/p/openconf/discussion/help/
