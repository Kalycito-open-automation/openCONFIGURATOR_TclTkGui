
                      openCONFIGURATOR v1.4.0 

  openCONFIGURATOR is an open-source tool for easy setup and configuration of 
  any POWERLINK network. It ideally complements openPOWERLINK, the open-source 
  POWERLINK protocol stack for master and slave

----------------------------
      License
----------------------------
    Copyright © 2014 - Kalycito Infotech Private Limited.
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


----------------------------
    RELEASE NOTE
----------------------------
This release V-1.4.0 includes major changes in the GUI and the library on top 
of version V-1.3.1 in compliance with the openPOWERLINK Specification 
EPSG DS-301 v1.2.0

----------------------------
       BEHAVIOR
----------------------------
- Currently openCONFIGURATOR version 1.4.0 does not support projects 
created with earlier versions of openCONFIGURATOR.
- The API's of openCONFIGURATOR v1.4.0 library are updated and will not support 
backward compatibility. 
- Disabled the possibility of adding object / sub-object. The user is not 
expected to change the XDD/XDC as it should be provided by the device manufacturer.
- In Windows, it is recommended to use only 32 bit binaries of ActiveTCL 
version 8.6.

----------------------------
      FEATURES
----------------------------
- New PDO mapping properties section for PDO mapping table.
- Auto calculates the number of valid entries.
- PDO mapping is made visible in the simple view.
- The API functions has been updated with new signatures.
- The binary packaging process is automated with CMake to generate platform dependent packages.
- Upgrade libxml2 and tablelist packages to the latest stable version.
- Validate the XDDs for new nodes before import.
- Support for IP_ADDRESS data type
- Application-crash with large process-image
- Populate object 0x1F9B from MN to all CNs
- Force to CDC feature

----------------------------
      BUG FIXES
----------------------------
- Avoid deleting sub-object deletion for 1C09,1F26,1F8B,1F8D,1F27,1F84 Objects.
- Incorrectly calculated PResTimeOut value.
- Incorrectly calculated number of days in configuration date (0x1F26).
- MN mapping generation of non existing mapping indices
- Limit the no. of cross-traffic channels for a CN to feature SPDORPDOChannels value
- Handle MN PDO generation for non supported DTs
- Objects with defaultValue != actualValue are not exported
- Validate non-hex actualValues acc. to their high-/lowLimit
- Avoid renaming of project file names
- Non-Unique channel names in xap.xml
- other stability fixes and help informations.

------------------------------
  KNOWN ISSUES and WORK AROUND
------------------------------
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

------------------------------
          SUPPORT
------------------------------
- Refer the user-manual inside the package 'docs' directory.
- For more information and help on using openCONFIGURATOR, please post us on the 
  help forum at http://sourceforge.net/p/openconf/discussion/help/
