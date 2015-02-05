################################################################################
# \file   openConfAPI.tcl
#
# \brief  The is the main API file to interact with the openCONFIGURATOR-TCL
#        wrapper library
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

# API for openCONFIGURATOR

namespace eval openConfLib {

}

#-------------------------------------------------------------------------------
#  openConfLib::ShowErrorMessage
#  Description: Displays the error message from the result object in a messagebox
#  ARG 0 - result - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
proc openConfLib::ShowErrorMessage { result } {
    if { [Result_IsSuccessful $result] != 1 } {
        if { [ string is ascii [Result_GetErrorString $result] ] } {
            tk_messageBox -message "Code:[Result_GetErrorCode $result]\nMsg:[Result_GetErrorString $result]" -title Error -icon error -parent .
        } else {
            tk_messageBox -message "Code:[Result_GetErrorCode $result]\nMsg:Unknown Error" -title Error -icon error -parent .
        }

        openConfLib::PrintText "Result: [Result_IsSuccessful $result] Err-code: [Result_GetErrorCode $result] Err-str: [Result_GetErrorString $result]"
    }
}

#-------------------------------------------------------------------------------
#  openConfLib::PrintText
#  Description: Prints the message string to the std output.
#-------------------------------------------------------------------------------
proc openConfLib::PrintText { messageStr } {
    # puts "$messageStr"
}

#-------------------------------------------------------------------------------
#  openConfLib::AddNode
#  Description: Delete a node from the network.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result  AddNode(const UINT32 nodeId, const std::string nodeName, const std::string xddFile = "");
proc openConfLib::AddNode { nodeId nodeName xddFilePath } {
    openConfLib::PrintText "::AddNode $nodeId $nodeName $xddFilePath "
    set result [::AddNode $nodeId $nodeName $xddFilePath ]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::DeleteNode
#  Description: Delete a node from the network.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result  DeleteNode(const UINT32 nodeId);
proc openConfLib::DeleteNode { nodeId } {
    openConfLib::PrintText "::DeleteNode $nodeId"
    set result [::DeleteNode $nodeId]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::ReplaceXdd
#  Description: Replace the XDD of a node.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result  ReplaceXdd(const UINT32 nodeId, const std::string path, const std::string xddFile);
proc openConfLib::ReplaceXdd { nodeId path xddFile } {
    openConfLib::PrintText "::ReplaceXdd $nodeId $path $xddFile"
    set result [::ReplaceXdd $nodeId $path $xddFile]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::IsExistingNode
#  Description: Check if a node exists in the POWERLINK network.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - 1 if the node exists, 0 otherwise.
#-------------------------------------------------------------------------------
#Result  IsExistingNode(const UINT32 nodeId, bool& exists);
proc openConfLib::IsExistingNode { nodeId } {
    set existsTemp [new_boolpointer]

    openConfLib::PrintText "::IsExistingNode $nodeId"
    set result [::IsExistingNode $nodeId $existsTemp]

    set retVal ""
    set value [boolpointer_value $existsTemp]
    lappend retVal $result
    lappend retVal $value

    delete_boolpointer $existsTemp
    openConfLib::PrintText "value: $value"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::GetNodeCount
#  Description: Return the number of nodes in the network.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - Overall no. of nodes in the POWERLINK network.
#-------------------------------------------------------------------------------
#Result  GetNodeCount(UINT32& nodeCount);
proc openConfLib::GetNodeCount { } {
    set nodeCountTemp [new_uintpointer]

    openConfLib::PrintText "::GetNodeCount"
    set result [::GetNodeCount $nodeCountTemp]

    set retVal ""
    set value [uintpointer_value $nodeCountTemp]
    lappend retVal $result
    lappend retVal $value

    delete_uintpointer $nodeCountTemp
    openConfLib::PrintText "value: $value"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::SetNodeParameter
#  Description: Set a POWERLINK parameter value of an existing node.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result  SetNodeParameter(const UINT32 nodeId, const openCONFIGURATOR::Library::NodeParameter::NodeParameter param, const std::string value);
proc openConfLib::SetNodeParameter { nodeId param value } {
    openConfLib::PrintText "::SetNodeParameter $nodeId $param $value"
    set result [::SetNodeParameter $nodeId $param $value]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::GetNodeParameter
#  Description: Get a POWERLINK parameter value of an existing node.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - value to be returned.
#-------------------------------------------------------------------------------
#Result  GetNodeParameter(const UINT32 nodeId, const openCONFIGURATOR::Library::NodeParameter::NodeParameter param, std::string& value);
proc openConfLib::GetNodeParameter { nodeId param  } {
    set retVal ""
    set valueTemp [new_stringpointer]

    openConfLib::PrintText "::GetNodeParameter $nodeId $param"
    set result [::GetNodeParameter $nodeId $param $valueTemp]

    set value [stringpointer_value $valueTemp]
    lappend retVal $result
    lappend retVal $value

    delete_stringpointer $valueTemp
    openConfLib::PrintText "value: $value"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::GetDataTypeSize
#  Description: Return size in bytes of a POWERLINK data type.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - Byte size of the data type.
#-------------------------------------------------------------------------------
#Result  GetDataTypeSize(const openCONFIGURATOR::Library::ObjectDictionary::PlkDataType::PlkDataType type, UINT32& size);
proc openConfLib::GetDataTypeSize { type } {
    set sizeTemp [new_uintpointer]

    openConfLib::PrintText "::GetDataTypeSize $type"
    set result [::GetDataTypeSize $type $sizeTemp]

    set retVal ""
    set value [uintpointer_value $sizeTemp]
    lappend retVal $result
    lappend retVal $value

    delete_uintpointer $sizeTemp
    openConfLib::PrintText "value: $value"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::GetFeatureValue
#  Description: Return the string-representation of the value of a device description entry.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - String-representation of a feature's value.
#-------------------------------------------------------------------------------
#Result  GetFeatureValue(const UINT32 nodeId, const openCONFIGURATOR::Library::ObjectDictionary::PlkFeature::PlkFeature feature, std::string& featureValue);
proc openConfLib::GetFeatureValue { nodeId feature  } {
    set retVal ""
    set valueTemp [new_stringpointer]

    openConfLib::PrintText "::GetFeatureValue $nodeId $feature"
    set result [::GetFeatureValue $nodeId $feature $valueTemp]

    set value [stringpointer_value $valueTemp]
    lappend retVal $result
    lappend retVal $value

    delete_stringpointer $valueTemp
    openConfLib::PrintText "value: $value"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::NewProject
#  Description: Create a new openCONFIGURATOR project.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result  NewProject(const std::string projectName, const std::string projectPath, const std::string pathToMNXdd = "");
proc openConfLib::NewProject { nodeId param value } {
    openConfLib::PrintText "::NewProject: $nodeId $param $value"
    set result [::NewProject $nodeId $param $value]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::SaveProject
#  Description: Save openCONFIGURATOR project in a new folder.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result  SaveProject();
proc openConfLib::SaveProject { } {
    set result [::SaveProject]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::SaveProjectAs
#  Description: Save openCONFIGURATOR project in a new folder.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result SaveProjectAs(const std::string, const std::string);
proc openConfLib::SaveProjectAs { newProjectName newProjectPath} {
    openConfLib::PrintText "::SaveProjectAs: $newProjectName $newProjectPath"
    set result [::SaveProjectAs $newProjectName $newProjectPath]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::CloseProject
#  Description: Close project and free allocated resources.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result  CloseProject();
proc openConfLib::CloseProject { } {
    set result [::CloseProject]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::OpenProject
#  Description: Open existing openCONFIGURATOR project.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result  OpenProject(const std::string projectFile);
proc openConfLib::OpenProject { projectFile } {
    openConfLib::PrintText "::OpenProject $projectFile"
    set result [::OpenProject $projectFile]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::AddPath
#  Description: Add a path setting to the openCONFIGURATOR project.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result  AddPath(const std::string id, const std::string path);
proc openConfLib::AddPath { id path } {
    openConfLib::PrintText "::AddPath $id $path"
    set result [::AddPath $id $path]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::GetPath
#  Description: Get a path setting from the openCONFIGURATOR project.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - path to be retrieved.
#-------------------------------------------------------------------------------
#Result  GetPath(const std::string id, std::string& path);
proc openConfLib::GetPath { id } {
    set retVal ""
    set pathTemp [new_stringpointer]

    openConfLib::PrintText "::GetPath $id "
    set result [::GetPath $id $pathTemp]

    set path [stringpointer_value $pathTemp]
    lappend retVal $result
    lappend retVal $path

    delete_stringpointer $pathTemp
    openConfLib::PrintText "path: $path"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::DeletePath
#  Description: Delete a path setting from the openCONFIGURATOR project.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result  DeletePath(const std::string id);
proc openConfLib::DeletePath { id } {
    openConfLib::PrintText "::DeletePath $id"
    set result [::DeletePath $id]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::SetActiveAutoCalculationConfig
#  Description: Set the active auto calculation configuration.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result  SetActiveAutoCalculationConfig(const std::string id);
proc openConfLib::SetActiveAutoCalculationConfig { id } {
    openConfLib::PrintText "::SetActiveAutoCalculationConfig $id"
    set result [::SetActiveAutoCalculationConfig $id]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::GetActiveAutoCalculationConfig
#  Description: Get the active auto calculation configuration.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - id of the configuration to be retrieved.
#-------------------------------------------------------------------------------
#Result  GetActiveAutoCalculationConfig(std::string& id);
proc openConfLib::GetActiveAutoCalculationConfig {  } {
    set idTemp [new_stringpointer]
    openConfLib::PrintText "::GetActiveAutoCalculationConfig"
    set result [::GetActiveAutoCalculationConfig $idTemp]

    set retVal ""
    set value [stringpointer_value $idTemp]
    lappend retVal $result
    lappend retVal $value

    delete_stringpointer $idTemp
    openConfLib::PrintText "value: $value"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::AddViewSetting
#  Description: Add a view setting to the openCONFIGURATOR project configuration.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result  AddViewSetting(const openCONFIGURATOR::Library::ProjectFile::ViewType::ViewType viewType, const std::string name, const std::string value);
proc openConfLib::AddViewSetting { viewType name value } {
    openConfLib::PrintText "::AddViewSetting $viewType $name $value"
    set result [::AddViewSetting $viewType $name $value]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::GetViewSetting
#  Description: Get a view setting value from the openCONFIGURATOR project configuration.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - value to be retrieved.
#-------------------------------------------------------------------------------
#Result  GetViewSetting(const openCONFIGURATOR::Library::ProjectFile::ViewType::ViewType viewType, const std::string name, std::string& value);
proc openConfLib::GetViewSetting { viewType name } {
    set tempValueStr [new_stringpointer]

    openConfLib::PrintText "::GetViewSetting $viewType $name"
    set result [::GetViewSetting $viewType $name $tempValueStr]

    set retVal ""
    set value [stringpointer_value $tempValueStr]
    lappend retVal $result
    lappend retVal $value

    delete_stringpointer $tempValueStr
    openConfLib::PrintText "value: $value"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::DeleteViewSetting
#  Description: Delete a view setting from the openCONFIGURATOR project configuration.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result  DeleteViewSetting(const openCONFIGURATOR::Library::ProjectFile::ViewType::ViewType viewType, const std::string name);
proc openConfLib::DeleteViewSetting { viewType name} {
    openConfLib::PrintText "::DeleteViewSetting $viewType $name"
    set result [::DeleteViewSetting $viewType $name]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::SetActiveView
#  Description: Set the active view type in the openCONFIGURATOR project configuration.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result  SetActiveView(const openCONFIGURATOR::Library::ProjectFile::ViewType::ViewType viewType);
proc openConfLib::SetActiveView { viewType } {
    openConfLib::PrintText "::SetActiveView $viewType"
    set result [::SetActiveView $viewType]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::GetActiveView
#  Description: Get the active view type in the openCONFIGURATOR project configuration.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - active View Type to be retrieved.
#-------------------------------------------------------------------------------
#Result  GetActiveView(openCONFIGURATOR::Library::ProjectFile::ViewType::ViewType& viewType);
proc openConfLib::GetActiveView { } {
    openConfLib::PrintText "::GetActiveView"
    set retVal ""
    set viewTypeTemp [new_ViewTypep]

    set result [::GetActiveView $viewTypeTemp]

    set value [ViewTypep_value $viewTypeTemp]
    lappend retVal $result
    lappend retVal $value

    openConfLib::PrintText "value: $value"

    delete_ViewTypep $viewTypeTemp
    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::GenerateProcessImageDescription
#  Description: Generate the process image description for a POWERLINK network.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result GenerateProcessImageDescription(const OutputLanguage lang, const std::string outputPath, const std::string fileName);
proc openConfLib::GenerateProcessImageDescription { lang outputPath fileName} {
    openConfLib::PrintText "::GenerateProcessImageDescription $lang $outputPath $fileName"
    set result [::GenerateProcessImageDescription $lang $outputPath $fileName]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::GenerateStackConfiguration
#  Description: Generate the stack configuration file for a POWERLINK network.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result GenerateStackConfiguration(const std::string outputPath, const std::string fileName);
proc openConfLib::GenerateStackConfiguration { outputPath fileName} {
    openConfLib::PrintText "::GenerateStackConfiguration $outputPath $fileName"
    set result [::GenerateStackConfiguration $outputPath $fileName]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::SetIndexActualValue
#  Description: Set the actual value of an index of a node.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result SetIndexActualValue(const UINT32 nodeId, const UINT32 index, const std::string actualValue);
proc openConfLib::SetIndexActualValue { nodeId index actualValue} {
    openConfLib::PrintText "::SetIndexActualValue $nodeId $index $actualValue"
    set result [::SetIndexActualValue $nodeId $index $actualValue]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::SetSubIndexActualValue
#  Description: Set the actual value of a sub-index of an index.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result SetSubIndexActualValue(const UINT32 nodeId, const UINT32 index, const UINT32 subIndex, const std::string actualValue);
proc openConfLib::SetSubIndexActualValue { nodeId index subIndex actualValue} {
    openConfLib::PrintText "::SetSubIndexActualValue $nodeId $index $subIndex $actualValue"
    set result [::SetSubIndexActualValue $nodeId $index $subIndex $actualValue]
    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::GetIndexAttribute
#  Description: Return the value of an attribute of a node's index.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - Attribute value.
#-------------------------------------------------------------------------------
#Result GetIndexAttribute(const UINT32 nodeId, const UINT32 index, AttributeType attributeType, std::string& attributeValue);
proc openConfLib::GetIndexAttribute { nodeId index attributeType } {
    set tempAttributeValue [new_stringpointer]

    openConfLib::PrintText "::GetIndexAttribute $nodeId $index $attributeType"
    set result [::GetIndexAttribute $nodeId $index $attributeType $tempAttributeValue]

    set retVal ""
    set value [stringpointer_value $tempAttributeValue]
    lappend retVal $result
    lappend retVal $value

    delete_stringpointer $tempAttributeValue
    openConfLib::PrintText "value: $value"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::GetSubIndexAttribute
#  Description: Get the attribute value of a sub-index of a node.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - Attribute value.
#-------------------------------------------------------------------------------
#Result GetSubIndexAttribute(const UINT32 nodeId, const UINT32 index, const UINT32 subIndex, AttributeType attributeType, std::string& attributeValue);
proc openConfLib::GetSubIndexAttribute { nodeId index subIndex attributeType } {
    set tempAttributeValue [new_stringpointer]

    openConfLib::PrintText "::GetSubIndexAttribute $nodeId $index $subIndex $attributeType"
    set result [::GetSubIndexAttribute $nodeId $index $subIndex $attributeType $tempAttributeValue]

    set retVal ""
    set value [stringpointer_value $tempAttributeValue]
    lappend retVal $result
    lappend retVal $value

    delete_stringpointer $tempAttributeValue
    openConfLib::PrintText "value: $value"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::IsExistingIndex
#  Description: Check if an index exists in the object dictionary of a node.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - 1 if the Index exists, 0 otherwise.
#-------------------------------------------------------------------------------
#Result IsExistingIndex(const UINT32 nodeId, const UINT32 index, bool& exists);
proc openConfLib::IsExistingIndex { nodeId index } {
    set existsTemp [new_boolpointer]

    openConfLib::PrintText "::IsExistingIndex $nodeId $index"
    set result [::IsExistingIndex $nodeId $index $existsTemp]

    set retVal ""
    set value [boolpointer_value $existsTemp]
    lappend retVal $result
    lappend retVal $value

    delete_boolpointer $existsTemp
    openConfLib::PrintText "value: $value"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::IsExistingSubIndex
#  Description: Check if a subindex exists in the object dictionary of a node.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - 1 if the SubIndex exists, 0 otherwise.
#-------------------------------------------------------------------------------
#Result IsExistingSubIndex(const UINT32 nodeId, const UINT32 index, const UINT32 subIndex, bool& exists);
proc openConfLib::IsExistingSubIndex { nodeId index subIndex } {
    set existsTemp [new_boolpointer]

    openConfLib::PrintText "::IsExistingSubIndex $nodeId $index $subIndex"
    set result [::IsExistingSubIndex $nodeId $index $subIndex $existsTemp]

    set retVal ""
    set value [boolpointer_value $existsTemp]
    lappend retVal $result
    lappend retVal $value

    delete_boolpointer $existsTemp
    openConfLib::PrintText "value: $value"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::GetIndexCount
#  Description: Returns the result in a list using following format.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - Return the no. of indices on a Node.
#-------------------------------------------------------------------------------
#Result GetIndexCount(const UINT32 nodeId, UINT32& indexCount);
proc openConfLib::GetIndexCount { nodeId } {
    set indexCountTemp [new_uintpointer]

    openConfLib::PrintText "::GetIndexCount $nodeId"
    set result [::GetIndexCount $nodeId $indexCountTemp]

    set retVal ""
    set value [uintpointer_value $indexCountTemp]
    lappend retVal $result
    lappend retVal $value

    delete_uintpointer $indexCountTemp
    openConfLib::PrintText "value: $value"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::GetSubIndexCount
#  Description: Returns the result in a list using following format.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - Return the no. of subIndices within an Index on a Node.
#-------------------------------------------------------------------------------
#Result GetSubIndexCount(const UINT32 nodeId, const UINT32 index, UINT32& subIndexCount);
proc openConfLib::GetSubIndexCount { nodeId index } {
    set subIndexCountTemp [new_uintpointer]

    openConfLib::PrintText "::GetSubIndexCount $nodeId $index"
    set result [::GetSubIndexCount $nodeId $index $subIndexCountTemp]

    set retVal ""
    set value [uintpointer_value $subIndexCountTemp]
    lappend retVal $result
    lappend retVal $value

    delete_uintpointer $subIndexCountTemp
    openConfLib::PrintText "value: $value"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::GetNumberOfEntries
#  Description: Returns the result in a list using following format.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - Return the actualValue or defaultValue of subIndex 0x00 (NrOfEntries) of an given Index.
#-------------------------------------------------------------------------------
#Result GetNumberOfEntries(const UINT32 nodeId, const UINT32 index, const bool getDefault, UINT32& nrOfEntries);
proc openConfLib::GetNumberOfEntries { nodeId index getDefault } {
    set nrOfEntriesTemp [new_uintpointer]

    openConfLib::PrintText "::GetNumberOfEntries $nodeId $index $getDefault"
    set result [::GetNumberOfEntries $nodeId $index $getDefault $nrOfEntriesTemp]

    set retVal ""
    set value [uintpointer_value $nrOfEntriesTemp]
    lappend retVal $result
    lappend retVal $value

    openConfLib::PrintText "value: $value"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::GetNodes
#  Description: Returns the result in a list using following format.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - Total number of elements returned
#               List arg 2 - A list of id's of the node available.
#               sampleretun: _50a29b06_p_openCONFIGURATOR__Library__ErrorHandling__Result 5 {240 1 2 4 3}
#-------------------------------------------------------------------------------
#Result GetNodes(std::vector<unsigned int>& nodeIds);
proc openConfLib::GetNodes { } {
    set nodeIdlistTemp [new_UIntVector]

    openConfLib::PrintText "::GetNodes "
    set result [::GetNodes $nodeIdlistTemp]

    set retVal ""
    lappend retVal $result

    set noOfElements [UIntVector_size $nodeIdlistTemp]
    lappend retVal $noOfElements

    set nodeidlist ""
    for {set inc 0} {$inc < $noOfElements} {incr inc} {
        lappend nodeidlist [UIntVector_get $nodeIdlistTemp $inc]
    }
    lappend retVal $nodeidlist

    delete_UIntVector $nodeIdlistTemp
    openConfLib::PrintText "No:$noOfElements value:$nodeidlist"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::GetIndices
#  Description: Returns the result in a list using following format.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - Total number of elements returned
#               List arg 2 - A list of index id's for the given nodeid.
#               sampleretun: _50a29b06_p_openCONFIGURATOR__Library__ErrorHandling__Result 3 {1000 1006 1009}
#-------------------------------------------------------------------------------
#Result GetIndices(const unsigned int nodeId, std::vector<unsigned int>& indices);
proc openConfLib::GetIndices { nodeId } {
    set indexListTemp [new_UIntVector]

    openConfLib::PrintText "::GetIndices $nodeId"
    set result [::GetIndices $nodeId $indexListTemp]

    set retVal ""
    lappend retVal $result

    set noOfElements [UIntVector_size $indexListTemp]
    lappend retVal $noOfElements

    set indexList ""
    for {set inc 0} {$inc < $noOfElements} {incr inc} {
        lappend indexList [UIntVector_get $indexListTemp $inc]
    }
    lappend retVal $indexList

    delete_UIntVector $indexListTemp
    openConfLib::PrintText "No:$noOfElements value:$indexList"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::GetSubIndices
#  Description: Returns the result in a list using following format.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#               List arg 1 - Total number of elements returned
#               List arg 2 - A list of sub-index id's for the given nodeid and indexid.
#               sampleretun: _50a29b06_p_openCONFIGURATOR__Library__ErrorHandling__Result 3 {1 2 3}
#-------------------------------------------------------------------------------
#Result GetSubIndices(const unsigned int nodeId, const unsigned int index, std::vector<unsigned int>& subIndices);
proc openConfLib::GetSubIndices { nodeId indexId } {
    set subIndexListTemp [new_UIntVector]

    openConfLib::PrintText "::GetSubIndices $nodeId $indexId"
    set result [::GetSubIndices $nodeId $indexId $subIndexListTemp]

    set retVal ""
    lappend retVal $result

    set noOfElements [UIntVector_size $subIndexListTemp]
    lappend retVal $noOfElements

    set indexList ""
    for {set inc 0} {$inc < $noOfElements} {incr inc} {
        lappend indexList [UIntVector_get $subIndexListTemp $inc]
    }
    lappend retVal $indexList

    delete_UIntVector $subIndexListTemp
    openConfLib::PrintText "No:$noOfElements value:$indexList"

    return $retVal
}

#-------------------------------------------------------------------------------
#  openConfLib::SetIndexAttribute
#  Description: Set the attribute value of an index of a node.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result SetIndexAttribute(const UINT32 nodeId, const UINT32 index, AttributeType attributeType, const std::string attributeValue);
proc openConfLib::SetIndexAttribute { nodeId index attributeType attributeValue} {
    openConfLib::PrintText "::SetIndexAttribute $nodeId $index $attributeType $attributeValue"
    set result [::SetIndexAttribute $nodeId $index $attributeType $attributeValue]

    return $result
}

#-------------------------------------------------------------------------------
#  openConfLib::SetSubIndexAttribute
#  Description: Set the attribute value of a sub-index of an index.
#               List arg 0 - The openCONFIGURATOR::Library::ErrorHandling::Result obj
#-------------------------------------------------------------------------------
#Result SetSubIndexAttribute(const UINT32 nodeId, const UINT32 index, const UINT32 subIndex, AttributeType attributeType, const std::string attributeValue);
proc openConfLib::SetSubIndexAttribute { nodeId index subIndex attributeType attributeValue} {
    openConfLib::PrintText "::SetSubIndexAttribute $nodeId $index $subIndex $attributeType $attributeValue"
    set result [::SetSubIndexAttribute $nodeId $index $subIndex $attributeType $attributeValue]

    return $result
}
