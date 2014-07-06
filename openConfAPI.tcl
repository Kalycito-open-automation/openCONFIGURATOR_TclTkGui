# API for openCONFIGURATOR

namespace eval openConfLib {

}

proc openConfLib::ShowErrorMessage { result } {
    if { [Result_IsSuccessful $result] != 1 } {
        if { [ string is ascii [Result_GetErrorString $result] ] } {
            tk_messageBox -message "Code:[Result_GetErrorCode $result]\nMsg:[Result_GetErrorString $result]" -title Error -icon error -parent .
        } else {
            tk_messageBox -message "Code:[Result_GetErrorCode $result]\nMsg:Unknown Error" -title Error -icon error -parent .
        }

        PrintResult $result
    }
}

proc openConfLib::PrintText { arg } {
    puts "$arg"
}

proc openConfLib::PrintResult { result } {
    PrintText "SucS:[Result_IsSuccessful $result] ercode: [Result_GetErrorCode $result] erstr: [Result_GetErrorString $result]"
}

#Result  AddNode(const UINT32 nodeId, const std::string nodeName, const std::string xddFile = "");
proc openConfLib::AddNode { nodeId nodename xddFilePath } {
    PrintText "::AddNode $nodeId $nodename $xddFilePath "
    set result [::AddNode $nodeId $nodename $xddFilePath ]
    return $result
}

#Result  DeleteNode(const UINT32 nodeId);
proc openConfLib::DeleteNode { nodeId } {
    PrintText "::DeleteNode $nodeId"
    set result [::DeleteNode $nodeId]
    return $result
}

#Result  ReplaceXdd(const UINT32 nodeId, const std::string path, const std::string xddFile);
proc openConfLib::ReplaceXdd { nodeId path xddFile } {
    PrintText "::ReplaceXdd $nodeId $path $xddFile"
    set result [::ReplaceXdd $nodeId $path $xddFile]
    return $result
}

#Result  IsExistingNode(const UINT32 nodeId, bool& exists);
proc openConfLib::IsExistingNode { nodeId } {
    set existsTemp [new_boolpointer]

    PrintText "::IsExistingNode $nodeId"
    set result [::IsExistingNode $nodeId $existsTemp]

    set retVal ""
    set value [boolpointer_value $existsTemp]
    lappend retVal $result
    lappend retVal $value

    PrintText "value: $value"

    return $retVal
}

#Result  GetNodeCount(UINT32& nodeCount);
proc openConfLib::GetNodeCount { } {
    set nodeCountTemp [new_uintpointer]

    PrintText "::GetNodeCount"
    set result [::GetNodeCount $nodeCountTemp]

    set retVal ""
    set value [uintpointer_value $nodeCountTemp]
    lappend retVal $result
    lappend retVal $value

    PrintText "value: $value"

    return $retVal
}

#Result  SetNodeParameter(const UINT32 nodeId, const openCONFIGURATOR::Library::NodeParameter::NodeParameter param, const std::string value);
proc openConfLib::SetNodeParameter { nodeId param value } {
    PrintText "::SetNodeParameter $nodeId $param $value"
    set result [::SetNodeParameter $nodeId $param $value]
    return $result
}

#Result  GetNodeParameter(const UINT32 nodeId, const openCONFIGURATOR::Library::NodeParameter::NodeParameter param, std::string& value);
proc openConfLib::GetNodeParameter { nodeId param  } {
    set retVal ""
    set valueTemp [new_stringpointer]

    PrintText "::GetNodeParameter $nodeId $param"
    set result [::GetNodeParameter $nodeId $param $valueTemp]

    set value [stringpointer_value $valueTemp]
    lappend retVal $result
    lappend retVal $value

    PrintText "value: $value"

    return $retVal
}


#Result  GetDataTypeSize(const openCONFIGURATOR::Library::ObjectDictionary::PlkDataType::PlkDataType type, UINT32& size);
proc openConfLib::GetDataTypeSize { type } {
    set sizeTemp [new_uintpointer]

    PrintText "::GetDataTypeSize $type"
    set result [::GetDataTypeSize $type $sizeTemp]

    set retVal ""
    set value [uintpointer_value $sizeTemp]
    lappend retVal $result
    lappend retVal $value

    PrintText "value: $value"

    return $retVal
}

#Result  GetFeatureValue(const UINT32 nodeId, const openCONFIGURATOR::Library::ObjectDictionary::PlkFeature::PlkFeature feature, std::string& featureValue);
proc openConfLib::GetFeatureValue { nodeId feature  } {
    set retVal ""
    set valueTemp [new_stringpointer]

    PrintText "::GetFeatureValue $nodeId $feature"
    set result [::GetFeatureValue $nodeId $feature $valueTemp]

    set value [stringpointer_value $valueTemp]
    lappend retVal $result
    lappend retVal $value

    PrintText "value: $value"

    return $retVal
}



#Result  NewProject(const std::string projectName, const std::string projectPath, const std::string pathToMNXdd = "");
proc openConfLib::NewProject { nodeId param value } {
    PrintText "::NewProject: $nodeId $param $value"
    set result [::NewProject $nodeId $param $value]
    return $result
}

#Result  SaveProject();
proc openConfLib::SaveProject { } {
    set result [::SaveProject]
    return $result
}

#Result  CloseProject();
proc openConfLib::CloseProject { } {
    set result [::CloseProject]
    return $result
}

#Result  OpenProject(const std::string projectFile);
proc openConfLib::OpenProject { projectFile } {
    PrintText "::OpenProject $projectFile"
    set result [::OpenProject $projectFile]
    return $result
}

#Result  AddPath(const std::string id, const std::string path);
proc openConfLib::AddPath { id path } {
    PrintText "::AddPath $id $path"
    set result [::AddPath $id $path]
    return $result
}

#Result  GetPath(const std::string id, std::string& path);
proc openConfLib::GetPath { id } {
    set retVal ""
    set pathTemp [new_stringpointer]

    PrintText "::GetPath $id "
    set result [::GetPath $id $pathTemp]

    set path [stringpointer_value $pathTemp]
    lappend retVal $result
    lappend retVal $path

    PrintText "path: $path"

    return $retVal
}


#Result  DeletePath(const std::string id);
proc openConfLib::DeletePath { id } {
    PrintText "::DeletePath $id"
    set result [::DeletePath $id]
    return $result
}

#Result  SetActiveAutoCalculationConfig(const std::string id);
proc openConfLib::SetActiveAutoCalculationConfig { id } {
    PrintText "::SetActiveAutoCalculationConfig $id"
    set result [::SetActiveAutoCalculationConfig $id]
    return $result
}

#Result  GetActiveAutoCalculationConfig(std::string& id);
proc openConfLib::GetActiveAutoCalculationConfig {  } {
    set idTemp [new_stringpointer]
    PrintText "::GetActiveAutoCalculationConfig"
    set result [::GetActiveAutoCalculationConfig $idTemp]

    set retVal ""
    set value [stringpointer_value $idTemp]
    lappend retVal $result
    lappend retVal $value

    PrintText "value: $value"

    return $retVal
}

#Result  AddViewSetting(const openCONFIGURATOR::Library::ProjectFile::ViewType::ViewType viewType, const std::string name, const std::string value);
proc openConfLib::AddViewSetting { viewType name value } {
    PrintText "::AddViewSetting $viewType $name $value"
    set result [::AddViewSetting $viewType $name $value]
    return $result
}

#Result  GetViewSetting(const openCONFIGURATOR::Library::ProjectFile::ViewType::ViewType viewType, const std::string name, std::string& value);
proc openConfLib::GetViewSetting { viewType name } {
    set tempValueStr [new_stringpointer]

    PrintText "::GetViewSetting $viewType $name"
    set result [::GetViewSetting $viewType $name $tempValueStr]

    set retVal ""
    set value [stringpointer_value $tempValueStr]
    lappend retVal $result
    lappend retVal $value

    PrintText "value: $value"

    return $retVal
}

#Result  DeleteViewSetting(const openCONFIGURATOR::Library::ProjectFile::ViewType::ViewType viewType, const std::string name);
proc openConfLib::DeleteViewSetting { viewType name} {
    PrintText "::DeleteViewSetting $viewType $name"
    set result [::DeleteViewSetting $viewType $name]
    return $result
}

#Result  SetActiveView(const openCONFIGURATOR::Library::ProjectFile::ViewType::ViewType viewType);
proc openConfLib::SetActiveView { viewType } {
    PrintText "::SetActiveView $viewType"
    set result [::SetActiveView $viewType]
    return $result
}

#Result  GetActiveView(openCONFIGURATOR::Library::ProjectFile::ViewType::ViewType& viewType);
proc openConfLib::GetActiveView { } {
    PrintText "::GetActiveView"
    set retVal ""
    set viewTypeTemp [new_ViewTypep]

    set result [::GetActiveView $viewTypeTemp]

    set value [ViewTypep_value $viewTypeTemp]
    lappend retVal $result
    lappend retVal $value

    PrintText "value: $value"

    return $retVal
}

#Result GenerateProcessImageDescription(const OutputLanguage lang, const std::string outputPath, const std::string fileName);
proc openConfLib::GenerateProcessImageDescription { lang outputPath fileName} {
    PrintText "::GenerateProcessImageDescription $lang $outputPath $fileName"
    set result [::GenerateProcessImageDescription $lang $outputPath $fileName]
    return $result
}

#Result GenerateStackConfiguration(const std::string outputPath, const std::string fileName);
proc openConfLib::GenerateStackConfiguration { outputPath fileName} {
    PrintText "::GenerateStackConfiguration $outputPath $fileName"
    set result [::GenerateStackConfiguration $outputPath $fileName]
    return $result
}

#Result SetIndexActualValue(const UINT32 nodeId, const UINT32 index, const std::string actualValue);
proc openConfLib::SetIndexActualValue { nodeId index actualValue} {
    PrintText "::SetIndexActualValue $nodeId $index $actualValue"
    set result [::SetIndexActualValue $nodeId $index $actualValue]
    return $result
}

#Result SetSubIndexActualValue(const UINT32 nodeId, const UINT32 index, const UINT32 subIndex, const std::string actualValue);
proc openConfLib::SetSubIndexActualValue { nodeId index subIndex actualValue} {
    PrintText "::SetSubIndexActualValue $nodeId $index $subIndex $actualValue"
    set result [::SetSubIndexActualValue $nodeId $index $subIndex $actualValue]
    return $result
}

#Result GetIndexAttribute(const UINT32 nodeId, const UINT32 index, AttributeType attributeType, std::string& attributeValue);
proc openConfLib::GetIndexAttribute { nodeId index attributeType } {
    set tempAttributeValue [new_stringpointer]

    PrintText "::GetIndexAttribute $nodeId $index $attributeType"
    set result [::GetIndexAttribute $nodeId $index $attributeType $tempAttributeValue]

    set retVal ""
    set value [stringpointer_value $tempAttributeValue]
    lappend retVal $result
    lappend retVal $value

    PrintText "value: $value"

    return $retVal
}

#Result GetSubIndexAttribute(const UINT32 nodeId, const UINT32 index, const UINT32 subIndex, AttributeType attributeType, std::string& attributeValue);
proc openConfLib::GetSubIndexAttribute { nodeId index subIndex attributeType } {
    set tempAttributeValue [new_stringpointer]

    PrintText "::GetSubIndexAttribute $nodeId $index $subIndex $attributeType"
    set result [::GetSubIndexAttribute $nodeId $index $subIndex $attributeType $tempAttributeValue]

    set retVal ""
    set value [stringpointer_value $tempAttributeValue]
    lappend retVal $result
    lappend retVal $value

    PrintText "value: $value"

    return $retVal
}

#Result IsExistingIndex(const UINT32 nodeId, const UINT32 index, bool& exists);
proc openConfLib::IsExistingIndex { nodeId index } {
    set existsTemp [new_boolpointer]

    PrintText "::IsExistingIndex $nodeId $index"
    set result [::IsExistingIndex $nodeId $index $existsTemp]

    set retVal ""
    set value [boolpointer_value $existsTemp]
    lappend retVal $result
    lappend retVal $value

    PrintText "value: $value"

    return $retVal
}

#Result IsExistingSubIndex(const UINT32 nodeId, const UINT32 index, const UINT32 subIndex, bool& exists);
proc openConfLib::IsExistingSubIndex { nodeId index subIndex } {
    set existsTemp [new_boolpointer]

    PrintText "::IsExistingSubIndex $nodeId $index $subIndex"
    set result [::IsExistingSubIndex $nodeId $index $subIndex $existsTemp]

    set retVal ""
    set value [boolpointer_value $existsTemp]
    lappend retVal $result
    lappend retVal $value

    PrintText "value: $value"

    return $retVal
}

#Result GetIndexCount(const UINT32 nodeId, UINT32& indexCount);
proc openConfLib::IsExistingIndex { nodeId index } {
    set existsTemp [new_boolpointer]

    PrintText "::IsExistingIndex $nodeId $index"
    set result [::IsExistingIndex $nodeId $index $existsTemp]

    set retVal ""
    set value [boolpointer_value $existsTemp]
    lappend retVal $result
    lappend retVal $value

    PrintText "value: $value"

    return $retVal
}

#Result GetSubIndexCount(const UINT32 nodeId, const UINT32 index, UINT32& subIndexCount);
#Result GetNumberOfEntries(const UINT32 nodeId, const UINT32 index, const bool getDefault, UINT32& nrOfEntries);
