################################################################################
# \file   windows.cmake
#
# \brief  Windows specific CMake file for openCONFIGURATOR-TclTk package
#
# \copyright (c) 2014, Kalycito Infotech Private Limited
#                    All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#   * Neither the name of the copyright holders nor the
#     names of its contributors may be used to endorse or promote products
#     derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDERS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
################################################################################

SET(CPACK_GENERATOR "NSIS")

SET(OPENCONF_WINDOWS_DIR "${OPENCONF_TCL_ROOT_DIR}/windows/")

SET(PACKAGE_EXCLUDE_PLATFORM "openCONFIGURATOR.so|x86") #|/*.so
SET(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}-win32-x86")
SET(CPACK_NSIS_INSTALLER_ICON_CODE "!define MUI_HEADERIMAGE_BITMAP \\\".\\\\${CPACK_PACKAGE_FILE_NAME}\\\\images\\\\openConfig.bmp\\\"")
SET(CPACK_CREATE_DESKTOP_LINKS "${CMAKE_PROJECT_NAME}.exe")

SET(CPACK_PACKAGE_INSTALL_DIRECTORY "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}")
SET(CPACK_PACKAGE_INSTALL_REGISTRY_KEY "${CMAKE_PROJECT_NAME}")

SET(CPACK_NSIS_DISPLAY_NAME "${CMAKE_PROJECT_NAME}")
SET(CPACK_NSIS_INSTALLED_ICON_NAME "\\\\${CMAKE_PROJECT_NAME}.exe")
SET(CPACK_NSIS_PACKAGE_NAME "${CMAKE_PROJECT_NAME} ${CPACK_PACKAGE_VERSION}")
SET(CPACK_NSIS_CREATE_ICONS "CreateShortCut \\\"$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\${CMAKE_PROJECT_NAME}.lnk\\\" \\\"$INSTDIR\\\\${CMAKE_PROJECT_NAME}.exe\\\"")
SET(CPACK_NSIS_CREATE_ICONS_EXTRA "CreateShortCut  \\\"$DESKTOP\\\\${CMAKE_PROJECT_NAME}.lnk\\\" \\\"$INSTDIR\\\\${CMAKE_PROJECT_NAME}.exe\\\"")
SET(CPACK_NSIS_DELETE_ICONS_EXTRA "Delete \\\"$SMPROGRAMS\\\\$MUI_TEMP\\\\${CMAKE_PROJECT_NAME}.lnk\\\" \\n Delete \\\"$DESKTOP\\\\${CMAKE_PROJECT_NAME}.lnk\\\"")
SET(CPACK_NSIS_HELP_LINK "http://sourceforge.net/p/openconf/discussion/")
SET(CPACK_NSIS_URL_INFO_ABOUT "http://www.kalycito.com")
SET(CPACK_NSIS_CONTACT "powerlink-team@kalycito.com")
SET(CPACK_NSIS_MUI_FINISHPAGE_RUN "..\\\\${CMAKE_PROJECT_NAME}.exe")
SET(CPACK_PACKAGE_DEFAULT_LOCATION ".")
SET(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL "ON")
SET(CPACK_NSIS_MUI_ICON "${CMAKE_CURRENT_SOURCE_DIR}/images/openConfig.ico")

FILE(COPY "${OPENCONF_WINDOWS_DIR}/tools/x86/txt2cdc.exe"
        DESTINATION ${OPENCONF_TCL_ROOT_DIR}/resources
        )
