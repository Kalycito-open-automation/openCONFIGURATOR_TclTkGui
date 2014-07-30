################################################################################
#
# Project: openCONFIGURATOR-TclTk
#
# (c) 2014 Kalycito Infotech Pvt Ltd., http://kalycito.com
#
# Description: Windows specific CMake file for openconfigurator-tcltk package
#
# License:
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions
#   are met:
#
#   1. Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#
#   2. Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#
#   3. Neither the name of the copyright holders nor the names of its
#      contributors may be used to endorse or promote products derived
#      from this software without prior written permission. For written
#      permission, please contact info@kalycito.com.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
#   FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#   COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#   INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
#   BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
#   ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#   POSSIBILITY OF SUCH DAMAGE.
#
#   Severability Clause:
#
#       If a provision of this License is or becomes illegal, invalid or
#       unenforceable in any jurisdiction, that shall not affect:
#       1. the validity or enforceability in that jurisdiction of any other
#          provision of this License; or
#       2. the validity or enforceability in other jurisdictions of that or
#          any other provision of this License.
#
################################################################################

SET(CPACK_GENERATOR "NSIS")

SET(PACKAGE_EXCLUDE_PLATFORM ".desktop|${ORG_PROJECT_NAME}.so|openConfiguratorWrapper.so") #|/*.so
SET(CPACK_PACKAGE_FILE_NAME "${ORG_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}-win32-x86")
SET(CPACK_NSIS_INSTALLER_ICON_CODE "!define MUI_HEADERIMAGE_BITMAP \\\".\\\\${CPACK_PACKAGE_FILE_NAME}\\\\images\\\\openConfig.bmp\\\"")
SET(CPACK_CREATE_DESKTOP_LINKS "${ORG_PROJECT_NAME}.exe")

SET(CPACK_PACKAGE_INSTALL_DIRECTORY "${ORG_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}")
SET(CPACK_PACKAGE_INSTALL_REGISTRY_KEY "${ORG_PROJECT_NAME}")

SET(CPACK_NSIS_DISPLAY_NAME "${ORG_PROJECT_NAME}")
SET(CPACK_NSIS_INSTALLED_ICON_NAME "\\\\${ORG_PROJECT_NAME}.exe")
SET(CPACK_NSIS_PACKAGE_NAME "${ORG_PROJECT_NAME} ${CPACK_PACKAGE_VERSION}")
SET(CPACK_NSIS_CREATE_ICONS "CreateShortCut \\\"$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\${ORG_PROJECT_NAME}.lnk\\\" \\\"$INSTDIR\\\\${ORG_PROJECT_NAME}.exe\\\"")
SET(CPACK_NSIS_CREATE_ICONS_EXTRA "CreateShortCut  \\\"$DESKTOP\\\\${ORG_PROJECT_NAME}.lnk\\\" \\\"$INSTDIR\\\\${ORG_PROJECT_NAME}.exe\\\"")
SET(CPACK_NSIS_DELETE_ICONS_EXTRA "Delete \\\"$SMPROGRAMS\\\\$MUI_TEMP\\\\${ORG_PROJECT_NAME}.lnk\\\" \\n Delete \\\"$DESKTOP\\\\${ORG_PROJECT_NAME}.lnk\\\"")
SET(CPACK_NSIS_HELP_LINK "http://sourceforge.net/p/openconf/discussion/")
SET(CPACK_NSIS_URL_INFO_ABOUT "http://www.kalycito.com")
SET(CPACK_NSIS_CONTACT "powerlink-team@kalycito.com")            
SET(CPACK_NSIS_MUI_FINISHPAGE_RUN "..\\\\${ORG_PROJECT_NAME}.exe")

SET(CPACK_PACKAGE_DEFAULT_LOCATION ".")

SET(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL "ON")



#SET(CPACK_NSIS_INSTALLER_ICON_CODE "!define MUI_ICON \\\"${CMAKE_CURRENT_SOURCE_DIR}/images/openConfig.ico\\\"")
#SET(CPACK_PACKAGE_DEFAULT_LOCATION "${ORG_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}")
#SET(CPACK_NSIS_MUI_ICON "${CMAKE_CURRENT_SOURCE_DIR}/openConfig.ico")
#This only creates windows 8 menu?
#SET(CPACK_PACKAGE_EXECUTABLES "${ORG_PROJECT_NAME}" "openCONFIGURATOR executable")