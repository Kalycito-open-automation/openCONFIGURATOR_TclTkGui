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

################################################################################
# Set the package specific defaults
################################################################################
SET(DESTDIR "${CMAKE_BINARY_DIR}")
SET(CPACK_SET_DESTDIR "ON")
SET(CPACK_GENERATOR "DEB")
SET(CPACK_SOURCE_GENERATOR "")

SET(OPENCONF_LINUX_DIR "${OPENCONF_TCL_ROOT_DIR}/linux/")
SET(CPACK_PACKAGE_DEFAULT_LOCATION "/opt/${CPACK_PACKAGE_NAME}")
SET(CPACK_INSTALL_PREFIX "${CPACK_PACKAGE_DEFAULT_LOCATION}")

SET(OPENCONF_LINUX_CONFIG_DIR "${OPENCONF_LINUX_DIR}/configurations")
SET(OPENCONF_LINUX_CMAKE_DIR "${OPENCONF_LINUX_DIR}/cmake")
SET(CPACK_DEBIAN_PACKAGE_HOMEPAGE "${PROJECT_HOMEPAGE}")
SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_PACKAGE_CONTACT}") #required
SET(CPACK_DEBIAN_PACKAGE_DESCRIPTION "${CPACK_PACKAGE_DESCRIPTION_SUMMARY}")

################################################################################
# Find the system version, codename and id from /etc/lsb-release
################################################################################
EXECUTE_PROCESS(
  COMMAND cat /etc/lsb-release
  COMMAND grep DISTRIB_CODENAME
  COMMAND awk -F= "{ print $2 }"
  COMMAND tr "\n" " "
  COMMAND sed "s/ //"
  OUTPUT_VARIABLE LSB_CODE_NAME
  RESULT_VARIABLE LSB_VER_RESULT
)
string(TOLOWER ${LSB_CODE_NAME} LSB_CODE_NAME)

EXECUTE_PROCESS(
  COMMAND cat /etc/lsb-release
  COMMAND grep DISTRIB_ID
  COMMAND awk -F= "{ print $2 }"
  COMMAND tr "\n" " "
  COMMAND sed "s/ //"
  OUTPUT_VARIABLE LSB_ID
  RESULT_VARIABLE LSB_ID_RESULT
)
string(TOLOWER ${LSB_ID} LSB_ID)

EXECUTE_PROCESS(
  COMMAND cat /etc/lsb-release
  COMMAND grep DISTRIB_RELEASE
  COMMAND awk -F= "{ print $2 }"
  COMMAND tr "\n" " "
  COMMAND sed "s/ //"
  OUTPUT_VARIABLE LSB_VER
  RESULT_VARIABLE LSB_VER_RESULT
)

################################################################################
# Determine the system architecture
################################################################################
IF(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
    SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE amd64)
ELSEIF(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i386")
    SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE i386)
ELSEIF(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i486")
    SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE i386)
ELSEIF(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i586")
    SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE i386)
ELSEIF(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "i686")
    SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE i386)
ELSE()
    MESSAGE(FATAL_ERROR "Architecture ${CMAKE_SYSTEM_PROCESSOR} is not supported!")
ENDIF(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")

################################################################################
# Copy the files required by openCONFIGURATOR library to resolve path.
################################################################################
FILE(COPY "${OPENCONF_LINUX_DIR}/tools/${LSB_CODE_NAME}/${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}/txt2cdc"
    DESTINATION ${OPENCONF_TCL_ROOT_DIR}/resources
    )
FILE(COPY "${OPENCONF_LINUX_DIR}/libs/${LSB_CODE_NAME}/${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}/openCONFIGURATOR.so"
    DESTINATION ${OPENCONF_TCL_ROOT_DIR}
    )

FILE(COPY "${OPENCONF_LINUX_DIR}/libs/${LSB_CODE_NAME}/${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}/openConfiguratorWrapper.so"
    DESTINATION ${OPENCONF_LINUX_DIR}/libs/
    )

FILE(COPY "${OPENCONF_LINUX_DIR}/libs/${LSB_CODE_NAME}/${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}/project_upgrade.so"
    DESTINATION ${OPENCONF_TCL_ROOT_DIR}
    )
FILE(COPY "${OPENCONF_LINUX_DIR}/libs/${LSB_CODE_NAME}/${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}/project_upgradeWrapper.so"
    DESTINATION ${OPENCONF_LINUX_DIR}/libs/
    )

################################################################################
# Excludes the files and folders from the repository to create the package
################################################################################
SET(PACKAGE_EXCLUDE_PLATFORM ".dll|.bat|.exe|.desktop|tools|configurations|precise|trusty|utopic")
SET(CPACK_STRIP_FILES "ON")

################################################################################
# Set the debian output package file name
################################################################################
string(TOLOWER ${CMAKE_PROJECT_NAME} CMAKE_PROJECT_NAME_LOWER)
SET(CPACK_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME_LOWER}_${CPACK_PACKAGE_VERSION}-${LSB_ID}${LSB_VER}_${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}")


################################################################################
# Set all the dependencies for openCONFIGURATOR
################################################################################
IF((${LSB_VER} STREQUAL "14.04") OR (${LSB_VER} STREQUAL "14.10"))
    SET(CPACK_DEBIAN_PACKAGE_DEPENDS "libboost-filesystem1.54.0, libboost-system1.54.0, tcl, libtcl8.6 (>=8.6.0), tcl8.6 (>=8.6.0-2), tk8.6 (>= 8.6.0-2), libtk8.6 (>= 8.6.0), tcllib, tklib, libxml2 (>=2.7.8), libxml2-utils, tcl-thread, libstdc++6, libc6, libxss1")
ELSEIF((${LSB_VER} STREQUAL "12.04") OR (${LSB_VER} STREQUAL "10.04"))
    SET(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6, libxss1, tcl8.5 (>=8.5.0-2), tk8.5 (>=8.5.0-1), libxml2 (>=2.7.8), libxml2-utils, tclthread, libstdc++6, tcllib, tklib")
ELSE()
    MESSAGE(FATAL_ERROR "${LSB_ID} - ${LSB_CODE_NAME} - version ${LSB_VER} is not supported!")
ENDIF()

################################################################################
# Configure and install the configuration and license informations for the package
################################################################################
CONFIGURE_FILE(${OPENCONF_LINUX_CONFIG_DIR}/openCONFIGURATOR_unversioned.desktop
            ${CMAKE_CURRENT_BINARY_DIR}/openCONFIGURATOR.desktop)
INSTALL(FILES "${CMAKE_CURRENT_BINARY_DIR}/openCONFIGURATOR.desktop"
    DESTINATION "/usr/share/applications")
SET(CPACK_CREATE_DESKTOP_LINKS "/usr/share/applications/openCONFIGURATOR.desktop")

CONFIGURE_FILE(${OPENCONF_LINUX_CONFIG_DIR}/package.info.conf ${OPENCONF_TCL_ROOT_DIR}/package.info)

INSTALL(FILES "${OPENCONF_IMAGES_DIR}/flair.svg" DESTINATION "/usr/share/pixmaps")

FILE(COPY ${OPENCONF_TCL_ROOT_DIR}/License.txt
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
FILE(RENAME "${CMAKE_CURRENT_BINARY_DIR}/License.txt" "${CMAKE_CURRENT_BINARY_DIR}/COPYRIGHT")

INSTALL(FILES "${CMAKE_CURRENT_BINARY_DIR}/COPYRIGHT"
    DESTINATION "/usr/share/doc/${PROJECT_NAME}")


################################################################################
# Copy and configure the control files for the debian package
################################################################################
FILE(COPY ${OPENCONF_LINUX_CMAKE_DIR}/postinst.in
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
    NO_SOURCE_PERMISSIONS)
FILE(RENAME "${CMAKE_CURRENT_BINARY_DIR}/postinst.in" "${CMAKE_CURRENT_BINARY_DIR}/postinst")

FILE(COPY ${OPENCONF_LINUX_CMAKE_DIR}/preinst.in
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
    NO_SOURCE_PERMISSIONS)
FILE(RENAME "${CMAKE_CURRENT_BINARY_DIR}/preinst.in" "${CMAKE_CURRENT_BINARY_DIR}/preinst")

FILE(COPY ${OPENCONF_LINUX_CMAKE_DIR}/postrm.in
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
    NO_SOURCE_PERMISSIONS)
FILE(RENAME "${CMAKE_CURRENT_BINARY_DIR}/postrm.in" "${CMAKE_CURRENT_BINARY_DIR}/postrm")

FILE(COPY "${OPENCONF_LINUX_DIR}/configurations/openCONFIGURATOR.sh"
    DESTINATION ${OPENCONF_TCL_ROOT_DIR}
    )

SET(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_CURRENT_BINARY_DIR}/postinst;${CMAKE_CURRENT_BINARY_DIR}/preinst;${CMAKE_CURRENT_BINARY_DIR}/postrm")
