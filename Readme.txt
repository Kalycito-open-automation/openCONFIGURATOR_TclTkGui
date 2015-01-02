
                      openCONFIGURATOR v1.4.0 

  openCONFIGURATOR is an open-source tool for easy setup and configuration of 
  any POWERLINK network. It ideally complements openPOWERLINK, the open-source 
  POWERLINK protocol stack for master and slave

----------------------------------------------------------
                        License
----------------------------------------------------------
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


----------------------------------------------------------
                     RELEASE NOTE
----------------------------------------------------------
openCONFIGURATOR 1.4.0 is a major release and introduces a lot of new 
features and enhancements. These changes include the introduction of 
a new C++ based API, a project file format and project folder structure.
A tool for upgrading old projects to the new format is provided as well.
Boost logging mechanism is introduced to make debugging easier.

--------------------------------------------------------
                     FEATURES
--------------------------------------------------------
- New C++ based API and API documentation.
- New schema-validated project file.
- New project folder structure.
- Configuration files are saved as valid XDCs.
- Introduce boost logging mechanism.
- Add the source code for the TXT2CDC tool.
- New PDO mapping properties section for PDO mapping table.
- The binary packaging process is automated with CMake to generate 
platform dependent packages.
- Pre v1.4.0 project upgrade tool.
- Validate the XDDs for new nodes before import.
- Support for IP_ADDRESS data type.
- Populate object 0x1F9B from MN to all CNs.
- Force object/sub-object values to CDC.
- Enable PDO mapping in the simple view.
- Auto calculates the number of valid mapping entries.
- Many stability enhancements.

--------------------------------------------------------
                     BUG FIXES
--------------------------------------------------------
- Remove the possibility to Add / Delete / change the properties of a 
Object/Sub-object to avoid unwanted side effects.
- Avoid sub-object deletion for 1C09,1F26,1F8B,1F8D,1F27,1F84 Objects in 
the library.
- Fix incorrectly calculated PResTimeOut value.
- Fix incorrectly calculated number of days in configuration date (0x1F26).
- Fix MN mapping generation of non existing mapping indices.
- Bound the limit of number of cross-traffic channels for a CN to the feature 
'SPDORPDOChannels' value.
- Fix application-crash for configurations with large process-images.
- Fix handling MN PDO generation for non supported data types.
- Fix objects with defaultValue not equal actualValue are not exported.
- Validate non-hex actualValues according to their high/lowLimit.
- Avoid renaming of project file names.
- Fix Non-Unique channel names in xap.xml.
- Many small stability fixes and help informations.

--------------------------------------------------------
              BACKWARD COMPATIBILITY
--------------------------------------------------------
- The API is not backward compatible to older versions of openCONFIGURATOR.
- The projects created with v1.4.0 cannot be opened by older version of 
openCONFIGURATOR.

--------------------------------------------------------
                 LIBRARY UPGRADES
--------------------------------------------------------
- Upgrade the linked TCL library version to 8.6.x on Windows and Ubuntu 
14.04 32 and 64 bit platforms.
- Upgrade libxml2 and tablelist packages to the latest stable version.
- Add Boost v1.54.0 library dependency.

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
- Refer the user-manual inside the package 'docs' directory.
- For more information and help on using openCONFIGURATOR, please post us on the 
  help forum at http://sourceforge.net/p/openconf/discussion/help/
