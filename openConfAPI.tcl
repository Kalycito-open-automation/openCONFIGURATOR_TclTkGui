# API for openCONFIGURATOR

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result AddNode(const UINT32 nodeId, const std::string nodeName, const std::string xddFile = "");
namespace eval openConfLib {

}

proc openConfLib::ShowErrorMessage { result } {
    PrintResult $result

    if { [Result_IsSuccessful $result] != 1 } {
        if { [ string is ascii [Result_GetErrorString $result] ] } {
            tk_messageBox -message "Code:[Result_GetErrorCode $result]\nMsg:[Result_GetErrorString $result]" -title Error -icon error -parent .
        } else {
            tk_messageBox -message "Code:[Result_GetErrorCode $result]\nMsg:Unknown Error" -title Error -icon error -parent .
        }
    }
}

proc openConfLib::PrintText { arg } {
    puts "$arg"
}

proc openConfLib::PrintResult { result } {
    PrintText "SucS:[Result_IsSuccessful $result] ercode: [Result_GetErrorCode $result] erstr: [Result_GetErrorString $result]"
}

proc openConfLib::AddNode { nodeId nodename xddFilePath } {
    PrintText "::AddNode $nodeId $nodename $xddFilePath "
    set result [::AddNode $nodeId $nodename $xddFilePath ]
    ShowErrorMessage $result
    return result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result DeleteNode(const UINT32 nodeId);
proc openConfLib::DeleteNode { nodeId } {
    PrintText "::DeleteNode $nodeId"
    set result [::DeleteNode $nodeId]
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result ReplaceXdd(const UINT32 nodeId, const std::string path, const std::string xddFile);
proc openConfLib::ReplaceXdd { nodeId path xddFile } {
    PrintText "::ReplaceXdd $nodeId $path $xddFile"
    set result [::ReplaceXdd $nodeId $path $xddFile]
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result IsExistingNode(const UINT32 nodeId, bool& exists);
proc openConfLib::IsExistingNode { nodeId exists} {
    upvar $exists existsTemp

    PrintText "::IsExistingNode $nodeId"
    set result [::IsExistingNode $nodeId $existsTemp]
    PrintText "exists:$exists"
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result GetNodeCount(UINT32& nodeCount);
proc openConfLib::GetNodeCount { nodeCount } {
    upvar $nodeCount nodeCountTemp

    PrintText "::GetNodeCount"
    set result [::GetNodeCount $nodeCountTemp]
    PrintText "nodeCount:$nodeCountTemp"
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result SetNodeParameter(const UINT32 nodeId, const openCONFIGURATOR::Library::NodeParameter::NodeParameter param, const std::string value);
proc openConfLib::SetNodeParameter { nodeId param value } {
    PrintText "::SetNodeParameter $nodeId $param $value"
    set result [::SetNodeParameter $nodeId $param $value]
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result GetNodeParameter(const UINT32 nodeId, const openCONFIGURATOR::Library::NodeParameter::NodeParameter param, std::string& value);
proc openConfLib::GetNodeParameter { nodeId param value } {
    upvar $value valueTemp
    PrintText "::GetNodeParameter $nodeId $param"
    set result [::GetNodeParameter $nodeId $param $valueTemp]
    PrintText "value_loc: $valueTemp"
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result NewProject(const std::string projectName, const std::string projectPath, const std::string pathToMNXdd = "");
proc openConfLib::NewProject { nodeId param value } {
    PrintText "::NewProject: $nodeId $param $value"
    set result [::NewProject $nodeId $param $value]
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result SaveProject();
proc openConfLib::SaveProject { } {
    set result [::SaveProject]
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result CloseProject();
proc openConfLib::CloseProject { } {
    set result [::CloseProject]
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result OpenProject(const std::string projectFile);
proc openConfLib::OpenProject { projectFile } {
    PrintText "::OpenProject $projectFile"
    set result [::OpenProject $projectFile]
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result AddPath(const std::string id, const std::string path);
proc openConfLib::AddPath { id path } {
    PrintText "::AddPath $id $path"
    set result [::AddPath $id $path]
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result GetPath(const std::string id, std::string& path);
proc openConfLib::GetPath { id path } {
    upvar $path pathTemp
    PrintText "::GetPath $id "
    set result [::GetPath $id $pathTemp]
    PrintText "pathTemp:$pathTemp"
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result DeletePath(const std::string id);
proc openConfLib::DeletePath { id } {
    set result [::DeletePath $id]
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result SetActiveAutoCalculationConfig(const std::string id);
proc openConfLib::SetActiveAutoCalculationConfig { id } {
    set result [::SetActiveAutoCalculationConfig $id]
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result GetActiveAutoCalculationConfig(std::string& id);
proc openConfLib::GetActiveAutoCalculationConfig { id } {
    upvar $id idTemp
    PrintText "::GetActiveAutoCalculationConfig"
    set result [::GetActiveAutoCalculationConfig $idTemp]
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result AddViewSetting(const openCONFIGURATOR::Library::ProjectFile::ViewType::ViewType viewType, const std::string name, const std::string value);
proc openConfLib::AddViewSetting { viewType name value } {
    PrintText "::AddViewSetting $viewType $name $value"
    set result [::AddViewSetting $viewType $name $value]
    #ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result GetViewSetting(const openCONFIGURATOR::Library::ProjectFile::ViewType::ViewType viewType, const std::string name, std::string& value);
proc openConfLib::GetViewSetting { viewType name valueStr} {
    upvar $valueStr tempValueStr
    set result [::GetViewSetting $viewType $name $tempValueStr]
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result DeleteViewSetting(const openCONFIGURATOR::Library::ProjectFile::ViewType::ViewType viewType, const std::string name);
proc openConfLib::DeleteViewSetting { viewType name} {
    set result [::DeleteViewSetting $viewType $name]
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result SetActiveView(const openCONFIGURATOR::Library::ProjectFile::ViewType::ViewType viewType);
proc openConfLib::SetActiveView { viewType } {
    set result [::SetActiveView $viewType]
    ShowErrorMessage $result
    return $result
}

#DLLEXPORT openCONFIGURATOR::Library::ErrorHandling::Result GetActiveView(openCONFIGURATOR::Library::ProjectFile::ViewType::ViewType& viewType);
proc openConfLib::GetActiveView { viewType } {
    upvar $viewType viewTypeTemp
    set result [::GetActiveView $viewTypeTemp]
    ShowErrorMessage $result
    return $result
}
