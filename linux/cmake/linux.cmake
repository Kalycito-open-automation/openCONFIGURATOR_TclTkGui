################################################################################
# \file   linux.cmake
#
# \brief  Linux specific CMake file for openCONFIGURATOR-TclTk package
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

SET(DESTDIR "${CMAKE_BINARY_DIR}")
SET(CPACK_SET_DESTDIR "ON")
SET(CPACK_GENERATOR "DEB")
SET(CPACK_SOURCE_GENERATOR "")

IF(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
    SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE amd64)
    #SET(CPACK_RPM_PACKAGE_ARCHITECTURE "x86_64")
ELSEIF(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i686")
    SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE i386)
    #SET(CPACK_RPM_PACKAGE_ARCHITECTURE "i386")
ENDIF(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")

SET(CPACK_PACKAGE_DEFAULT_LOCATION "/usr/share/${CPACK_PACKAGE_NAME}")
SET(CPACK_INSTALL_PREFIX "${CPACK_PACKAGE_DEFAULT_LOCATION}")

SET(OPENCONF_LINUX_CONFIG_DIR "${OPENCONF_TCL_ROOT_DIR}/linux/configurations")
SET(OPENCONF_LINUX_CMAKE_DIR "${OPENCONF_TCL_ROOT_DIR}/linux/cmake")


SET(CPACK_DEBIAN_PACKAGE_HOMEPAGE "${PROJECT_HOMEPAGE}")
SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_PACKAGE_CONTACT}") #required
SET(CPACK_DEBIAN_PACKAGE_DESCRIPTION "${CPACK_PACKAGE_DESCRIPTION_SUMMARY}")
FILE(WRITE "${OPENCONF_LINUX_CONFIG_DIR}/${ORG_PROJECT_NAME}.desktop" "\n[Desktop Entry]\n"
"Version=${CPACK_PACKAGE_VERSION}\n"
"Encoding=UTF-8\n"
"Name=openCONFIGURATOR\n"
"Type=Application\n"
"GenericName=openCONFIGURATOR\n"
"Comment=Graphical User Interface for openCONFIGURATOR\n"
"Exec=openCONFIGURATOR\n"
"Icon=flair\n"
"Categories=Development;\n"
"GenericName[en_IN]=openCONFIGURATOR\n"
"Name[en_IN]=openCONFIGURATOR")

FILE (GLOB_RECURSE desktopfile "${OPENCONF_LINUX_CONFIG_DIR}/openCONFIGURATOR.desktop")
INSTALL(FILES ${desktopfile} DESTINATION "/usr/share/applications")

FILE (GLOB_RECURSE imgfile "${OPENCONF_IMAGES_DIR}/flair.svg")
INSTALL(FILES ${imgfile} DESTINATION "/usr/share/pixmaps")

#FIXME creating desktop-links but not removing..!!
SET(CPACK_CREATE_DESKTOP_LINKS "/usr/share/applications/openCONFIGURATOR.desktop")

#TODO update copyright files according to the format
file(COPY ${OPENCONF_TCL_ROOT_DIR}/License.txt
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
FILE(RENAME "${CMAKE_CURRENT_BINARY_DIR}/License.txt" "${CMAKE_CURRENT_BINARY_DIR}/COPYRIGHT")
INSTALL(FILES "${CMAKE_CURRENT_BINARY_DIR}/COPYRIGHT" DESTINATION "/usr/share/doc/${PROJECT_NAME}")

file(COPY ${OPENCONF_LINUX_CMAKE_DIR}/postinst.in
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
    NO_SOURCE_PERMISSIONS)
FILE(RENAME "${CMAKE_CURRENT_BINARY_DIR}/postinst.in" "${CMAKE_CURRENT_BINARY_DIR}/postinst")

file(COPY ${OPENCONF_LINUX_CMAKE_DIR}/preinst.in
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
    NO_SOURCE_PERMISSIONS)
FILE(RENAME "${CMAKE_CURRENT_BINARY_DIR}/preinst.in" "${CMAKE_CURRENT_BINARY_DIR}/preinst")

file(COPY ${OPENCONF_LINUX_CMAKE_DIR}/postrm.in
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
    NO_SOURCE_PERMISSIONS)
FILE(RENAME "${CMAKE_CURRENT_BINARY_DIR}/postrm.in" "${CMAKE_CURRENT_BINARY_DIR}/postrm")

SET(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_CURRENT_BINARY_DIR}/postinst;${CMAKE_CURRENT_BINARY_DIR}/preinst;${CMAKE_CURRENT_BINARY_DIR}/postrm")

SET(PACKAGE_EXCLUDE_PLATFORM ".dll|.bat|.exe|.desktop")

SET(CPACK_STRIP_FILES "ON")

#NEEDED               openCONFIGURATOR.so
#NEEDED               libtcl8.5.so.0 / libtcl8.6.so.0
#NEEDED               libstdc++.so.6
#NEEDED               libc.so.6
#NEEDED               libxml2.so.2
#NEEDED               libgcc_s.so.1

# objdump -x /usr/share/openconfigurator-tcltk/openCONFIGURATOR.so | grep NEEDED


# Use the LSB stuff if possible
EXECUTE_PROCESS(
  COMMAND cat /etc/lsb-release
  COMMAND grep DISTRIB_ID
  COMMAND awk -F= "{ print $2 }"
  COMMAND tr "\n" " "
  COMMAND sed "s/ //"
  OUTPUT_VARIABLE LSB_ID
  RESULT_VARIABLE LSB_ID_RESULT
)

EXECUTE_PROCESS(
  COMMAND cat /etc/lsb-release
  COMMAND grep DISTRIB_RELEASE
  COMMAND awk -F= "{ print $2 }"
  COMMAND tr "\n" " "
  COMMAND sed "s/ //"
  OUTPUT_VARIABLE LSB_VER
  RESULT_VARIABLE LSB_VER_RESULT
)

string(TOLOWER ${LSB_ID} LSB_ID)
message("LSB output: ${LSB_ID_RESULT}:${LSB_ID} ${LSB_VER_RESULT}:${LSB_VER}")
#if(NOT ${LSB_ID} STREQUAL "")
#  # found some, use it :D
#  set(INSTALLER_PLATFORM "${LSB_ID}-${LSB_VER}" CACHE PATH "Installer chosen platform")
#else(NOT ${LSB_ID} STREQUAL "")
#  set(INSTALLER_PLATFORM "linux-generic" CACHE PATH "Installer chosen platform")
#endif(NOT ${LSB_ID} STREQUAL "")

SET(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}_${CPACK_PACKAGE_VERSION}-${LSB_ID}-${LSB_VER}-${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}")

IF(${LSB_VER} STREQUAL "14.04")
    SET(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6, libxss1, tcl, libtcl8.6 (>=8.6.0), tcl8.6 (>=8.6.0-2), tk8.6 (>= 8.6.0-2),  libtk8.6 (>= 8.6.0), libxml2 (>=2.7.8), tcl-thread, libstdc++6")
ELSEIF(${LSB_VER} STREQUAL "12.04")
    SET(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6, libxss1, tcl (>=8.5.0-2), tk (>=8.5.0-1), libxml2 (>=2.7.8), tclthread, libstdc++6")
ELSE()
 # TODO handle other versions of ubuntu
ENDIF()
#SET(CPACK_DEBIAN_PACKAGE_RECOMMENDS "")
#SET(CPACK_DEBIAN_PACKAGE_SUGGESTS "")


#CONFIGURE_FILE("${CMAKE_CURRENT_SOURCE_DIR}/cmake/postinst" "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/scripts/postinst" @ONLY IMMEDIATE)
#FILE(COPY ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/scripts/postinst DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}
#            FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
