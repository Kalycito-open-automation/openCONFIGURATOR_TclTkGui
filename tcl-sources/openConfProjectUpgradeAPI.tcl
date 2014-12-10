################################################################################
# \file   openConfProjectUpgradeAPI.tcl
#
# \brief  The is the main API file to interact with the
#         openCONFIGURATOR-ProjectUpgrade-TCL wrapper library
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

# API for openCONFIGURATOR project upgrade library

namespace eval openConfProjectUpgradeLib {

}

#-------------------------------------------------------------------------------
#  openConfProjectUpgradeLib::ShowErrorMessage
#  Description: Displays the error message from the result object in a messagebox
#  ARG 0 - result - The openCONFIGURATOR::ProjectUpgrade::Result obj
#-------------------------------------------------------------------------------
proc openConfProjectUpgradeLib::ShowErrorMessage { result } {
    if { [ProjectUpgrade_Result_IsSuccessful $result] != 1 } {

        if { [ string is ascii [ProjectUpgrade_Result_GetErrorString $result] ] } {
            set projectUpgradeMessage "Code:[ProjectUpgrade_Result_GetErrorCode $result]\nMessage:[ProjectUpgrade_Result_GetErrorString $result]"
        } else {
            set projectUpgradeMessage "Code:[ProjectUpgrade_Result_GetErrorCode $result]\nMessage:Unknown Error"
        }
        tk_messageBox -message "$projectUpgradeMessage" -title Error -icon error -parent .
        Console::DisplayErrMsg "$projectUpgradeMessage"
        openConfProjectUpgradeLib::PrintText "$projectUpgradeMessage"
    }
}

#-------------------------------------------------------------------------------
#  openConfProjectUpgradeLib::PrintText
#  Description: Prints the message string to the std output.
#-------------------------------------------------------------------------------
proc openConfProjectUpgradeLib::PrintText { messageStr } {
    # puts "$messageStr"
}

#-------------------------------------------------------------------------------
#  openConfProjectUpgradeLib::GetNodes
#  Description: Returns the result in a list using following format.
#               List arg 0 - The openCONFIGURATOR::ProjectUpgrade::Result obj
#               List arg 1 - Total number of elements returned
#               List arg 2 - A list of id's of the node available.
#               sampleretun: _50a29b06_p_openCONFIGURATOR__ProjectUpgrade__Result 5 {240 1 2 4 3}
#-------------------------------------------------------------------------------
proc openConfProjectUpgradeLib::GetNodes { } {
    set nodeIdlistTemp [new_ProjectUpgradeUIntVector]

    openConfProjectUpgradeLib::PrintText "::ProjectUpgrade_GetNodes "
    set result [::ProjectUpgrade_GetNodes $nodeIdlistTemp]

    set retVal ""
    lappend retVal $result

    set noOfElements [ProjectUpgradeUIntVector_size $nodeIdlistTemp]
    lappend retVal $noOfElements

    set nodeidlist ""
    for {set inc 0} {$inc < $noOfElements} {incr inc} {
        lappend nodeidlist [ProjectUpgradeUIntVector_get $nodeIdlistTemp $inc]
    }
    lappend retVal $nodeidlist

    delete_ProjectUpgradeUIntVector $nodeIdlistTemp
    openConfProjectUpgradeLib::PrintText "No:$noOfElements value:$nodeidlist"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfProjectUpgradeLib::GetNodeName
#  Description: Get name of the node from the openCONFIGURATOR project upgrade library.
#               List arg 0 - openCONFIGURATOR::ProjectUpgrade::Result obj
#               List arg 1 - name of the node.
#-------------------------------------------------------------------------------
proc openConfProjectUpgradeLib::GetNodeName { id } {
    set retVal ""
    set nameTemp [new_ProjectUpgradeStringpointer]

    openConfProjectUpgradeLib::PrintText "::ProjectUpgrade_GetNodeName $id "
    set result [::ProjectUpgrade_GetNodeName $id $nameTemp]

    set name [ProjectUpgradeStringpointer_value $nameTemp]
    delete_ProjectUpgradeStringpointer $nameTemp
    lappend retVal $result
    lappend retVal $name

    openConfProjectUpgradeLib::PrintText "name: $name"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfProjectUpgradeLib::GetOctxPath
#  Description: Get path of the octx file from the openCONFIGURATOR project upgrade library.
#               List arg 0 - openCONFIGURATOR::ProjectUpgrade::Result obj
#               List arg 1 - octx path of the node.
#-------------------------------------------------------------------------------
proc openConfProjectUpgradeLib::GetOctxPath { id } {
    set retVal ""
    set pathTemp [new_ProjectUpgradeStringpointer]

    openConfProjectUpgradeLib::PrintText "::ProjectUpgrade_GetOctxPath $id "
    set result [::ProjectUpgrade_GetOctxPath $id $pathTemp]

    set path [ProjectUpgradeStringpointer_value $pathTemp]
    delete_ProjectUpgradeStringpointer $pathTemp
    lappend retVal $result
    lappend retVal $path

    openConfProjectUpgradeLib::PrintText "path: $path"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfProjectUpgradeLib::SetXddPath
#  Description: Set path of the input XDD file to the openCONFIGURATOR project upgrade library.
#               List arg 0 - openCONFIGURATOR::ProjectUpgrade::Result obj
#-------------------------------------------------------------------------------
proc openConfProjectUpgradeLib::SetXddPath { nodeId inputXddPath } {
    openConfProjectUpgradeLib::PrintText "::ProjectUpgrade_SetXddPath $nodeId $inputXddPath "
    set result [::ProjectUpgrade_SetXddPath $nodeId $inputXddPath]
    return $result
}

#-------------------------------------------------------------------------------
#  openConfProjectUpgradeLib::ImportProjectFile
#  Description: Import the old(v1.3.1 or earlier) openCONFIGURATOR project file to
#               the openCONFIGURATOR project upgrade library.
#               List arg 0 - openCONFIGURATOR::ProjectUpgrade::Result obj
#-------------------------------------------------------------------------------
proc openConfProjectUpgradeLib::ImportProjectFile { projectFilePath } {
    openConfProjectUpgradeLib::PrintText "::ProjectUpgrade_ImportProjectFile $projectFilePath "
    set result [::ProjectUpgrade_ImportProjectFile $projectFilePath]
    return $result
}

#-------------------------------------------------------------------------------
#  openConfProjectUpgradeLib::UpgradeProject
#  Description: Upgrade the old openCONFIGURATOR project to the new project format.
#               List arg 0 - openCONFIGURATOR::ProjectUpgrade::Result obj
#-------------------------------------------------------------------------------
proc openConfProjectUpgradeLib::UpgradeProject { outputProjectPath } {
    openConfProjectUpgradeLib::PrintText "::ProjectUpgrade_UpgradeProject $outputProjectPath "
    set result [::ProjectUpgrade_UpgradeProject $outputProjectPath]
    return $result
}

#-------------------------------------------------------------------------------
#  openConfProjectUpgradeLib::GetNewProjectFilePath
#  Description: Get path of the octx file from the openCONFIGURATOR project upgrade library.
#               List arg 0 - openCONFIGURATOR::ProjectUpgrade::Result obj
#               List arg 1 - new project file path.
#-------------------------------------------------------------------------------
proc openConfProjectUpgradeLib::GetNewProjectFilePath { } {
    set retVal ""
    set pathTemp [new_ProjectUpgradeStringpointer]

    openConfProjectUpgradeLib::PrintText "ProjectUpgrade_GetNewProjectFilePath"
    set result [::ProjectUpgrade_GetNewProjectFilePath $pathTemp]

    set path [ProjectUpgradeStringpointer_value $pathTemp]
    delete_ProjectUpgradeStringpointer $pathTemp
    lappend retVal $result
    lappend retVal $path

    openConfProjectUpgradeLib::PrintText "path: $path"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfProjectUpgradeLib::ResetProjectUpgradeLib
#  Description: Resets the project upgrade library to its initial state.
#               List arg 0 - openCONFIGURATOR::ProjectUpgrade::Result obj
#-------------------------------------------------------------------------------
proc openConfProjectUpgradeLib::ResetProjectUpgradeLib { } {
    openConfProjectUpgradeLib::PrintText "::ProjectUpgrade_ResetProjectUpgradeLib "
    set result [::ProjectUpgrade_ResetProjectUpgradeLib]
    return $result
}

#-------------------------------------------------------------------------------
#  openConfProjectUpgradeLib::RevertUpgradeProject
#  Description: Reverts the project upgrade changes.
#               List arg 0 - openCONFIGURATOR::ProjectUpgrade::Result obj
#-------------------------------------------------------------------------------
proc openConfProjectUpgradeLib::RevertUpgradeProject { } {
    openConfProjectUpgradeLib::PrintText "::ProjectUpgrade_RevertUpgradeProject "
    set result [::ProjectUpgrade_RevertUpgradeProject]
    return $result
}
