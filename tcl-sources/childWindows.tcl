################################################################################
# \file   childWindows.tcl
#
# \brief  Contains the child window displayed in application.
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

#-------------------------------------------------------------------------------
#  NameSpace Declaration
#
#  namespace: ChildWindows
#-------------------------------------------------------------------------------
namespace eval ChildWindows {

}

#-------------------------------------------------------------------------------
#  ChildWindows::StartUp
#
#  Arguments: -
#
#  Results: -
#
#  Description: Creates the GUI during startup
#-------------------------------------------------------------------------------
proc ChildWindows::StartUp {} {
    global startVar
    global frame2
    set winStartUp .startUp
    catch "destroy $winStartUp"
    catch "font delete custom2"
    font create custom2 -size 9 -family TkDefaultFont
    toplevel     $winStartUp -takefocus 1
    wm title     $winStartUp "openCONFIGURATOR"
    wm resizable $winStartUp 0 0
    wm transient $winStartUp .
    wm deiconify $winStartUp
    grab $winStartUp

    set frame1 [frame $winStartUp.fram1]
    set frame2 [frame $frame1.fram2]

    label $frame1.la_empty1 -text ""
    label $frame1.la_empty2 -text ""
    label $frame1.la_empty3 -text ""
    label $frame1.la_desc -text "Description"

    text $frame1.t_desc -height 5 -width 40 -state disabled -background white

    radiobutton $frame1.ra_newProj  -text "Create New Project"    -variable startVar -value 1 -font custom2 -command "ChildWindows::StartUpText $frame1.t_desc 1"
    radiobutton $frame1.ra_openProj -text "Open Existing Project" -variable startVar -value 2 -font custom2 -command "ChildWindows::StartUpText $frame1.t_desc 2"
    $frame1.ra_newProj select
    ChildWindows::StartUpText $frame1.t_desc 1

    button $frame2.bt_ok -width 8 -text "  Ok  " -command {
        if {$startVar == 1} {
            destroy .startUp
            ChildWindows::NewProjectWindow
        } elseif {$startVar == 2} {
            destroy .startUp
            Operations::OpenProjectWindow
        }
        catch {
            unset startVar
            unset frame2
        }
    }
    button $frame2.bt_cancel -width 8 -text "Cancel" -command {
        catch {
            unset startVar
            unset frame2
        }
        catch { destroy .startUp }
    }

    grid config $frame1 -row 0 -column 0 -padx 35 -pady 10

    grid config $frame1.ra_newProj -row 1 -column 0 -sticky w  -padx 5 -pady 5
    grid config $frame1.ra_openProj -row 2 -column 0 -sticky w -padx 5 -pady 5
    grid config $frame1.la_desc -row 3 -column 0 -sticky w -padx 5 -pady 5
    grid config $frame1.t_desc -row 4 -column 0 -sticky w -padx 5 -pady 5
    grid config $frame2 -row 5 -column 0  -padx 5 -pady 5
    grid config $frame2.bt_ok -row 0 -column 0
    grid config $frame2.bt_cancel -row 0 -column 1

    wm protocol .startUp WM_DELETE_WINDOW "$frame2.bt_cancel invoke"
    bind $winStartUp <KeyPress-Return> "$frame2.bt_ok invoke"
    bind $winStartUp <KeyPress-Escape> "$frame2.bt_cancel invoke"

    focus $winStartUp
    $winStartUp configure -takefocus 1
    Operations::centerW $winStartUp
}

#-------------------------------------------------------------------------------
#  ChildWindows::StartUpText
#
#  Arguments : t_desc - path of the text widget
#              choice - based on choice message is displayed
#
#  Results : -
#
#  Description : Displays description message for StartUp window
#-------------------------------------------------------------------------------
proc ChildWindows::StartUpText {t_desc choice} {
    $t_desc configure -state normal
    $t_desc delete 1.0 end
    if { $choice == 1 } {
        $t_desc insert end "Create a new Project"
    } else {
        $t_desc insert end "Open Existing Project"
    }
    $t_desc configure -state disabled
}

#-------------------------------------------------------------------------------
#  ChildWindows::ProjectSettingWindow
#
#  Arguments: -
#
#  Results: -
#
#  Description: Displays description message for StartUp window
#-------------------------------------------------------------------------------
proc ChildWindows::ProjectSettingWindow {} {
    global projectName
    global projectDir
    global st_save
    global st_autogen
    global st_viewType
    global nodeSelect

    if {$projectDir == "" || $projectName == "" } {
        return
    }
# TODO remove viewtype in project settings window. There is no UI for this.

    set result [openConfLib::GetActiveView]
    set st_viewType [lindex $result 1]
# TODO if errror set st_viewtype to 0

    set st_save 1

    set result [openConfLib::GetActiveAutoCalculationConfig]
    set tempautoGen [lindex $result 1]
    if { [string match "all" $tempautoGen] } {
        set st_autogen 1
    } elseif { [string match "none" $tempautoGen] } {
        set st_autogen 0
    } else {
        set st_autogen 2
    }

    set winProjSett .projSett
    catch "destroy $winProjSett"
    toplevel     $winProjSett
    wm title     $winProjSett "Project Settings"
    wm resizable $winProjSett 0 0
    wm transient $winProjSett .
    wm deiconify $winProjSett
    grab $winProjSett

    set framea [frame $winProjSett.framea]
    set frameb [frame $winProjSett.frameb]
    set frame1 [frame $framea.frame1]
    set frame2 [frame $frameb.frame2]
    set frame3 [frame $winProjSett.frame3]

    label $framea.la_save -text "Project Settings"
    label $frameb.la_auto -text "Auto Generate"
    label $winProjSett.la_empty1 -text ""
    label $winProjSett.la_empty2 -text ""
    label $winProjSett.la_empty3 -text ""

    text $winProjSett.t_desc -height 4 -width 40 -state disabled -background white

    radiobutton $frame1.st_autogenSave -variable temp_st_save -value 0 -text "Auto Save" -command "ChildWindows::ProjectSettText $winProjSett.t_desc"
    radiobutton $frame1.ra_prompt -variable temp_st_save -value 1 -text "Prompt" -command "ChildWindows::ProjectSettText $winProjSett.t_desc"
    radiobutton $frame1.ra_discard -variable temp_st_save -value 2 -text "Discard" -command "ChildWindows::ProjectSettText $winProjSett.t_desc"

    radiobutton $frame2.ra_genYes -variable st_autogen -value 1 -text Yes -command "ChildWindows::ProjectSettText $winProjSett.t_desc"
    radiobutton $frame2.ra_genNo -variable st_autogen -value 0 -text No -command "ChildWindows::ProjectSettText $winProjSett.t_desc"

    ChildWindows::ProjectSettText $winProjSett.t_desc

    button $frame3.bt_ok -width 8 -text "Ok" -command {
        if { $Operations::viewType == "EXPERT" } {
            set viewType 1
            Operations::SingleClickNode $nodeSelect
        } else {
            set viewType 0
        }
        set result [openConfLib::SetActiveView $viewType]
        set st_viewtype $viewType
        openConfLib::ShowErrorMessage $result

        if { $st_autogen == 1 } {
            set autogen "all"
        } else {
            set autogen "none"
        }
        set result [openConfLib::SetActiveAutoCalculationConfig $autogen]
        openConfLib::ShowErrorMessage $result

        set st_save $temp_st_save

        destroy .projSett
    }

    button $frame3.bt_cancel -width 8 -text "Cancel" -command {
        #if cancel is called project settings for existing project is called
        global st_save
        global st_autogen
        global st_viewType

        set result [openConfLib::GetActiveView]
        set st_viewType [lindex $result 1]

        set result [openConfLib::GetActiveAutoCalculationConfig]
        set tempautoGen [lindex $result 1]
        if { [string match "all" $tempautoGen] } {
            set st_autogen 1
        } elseif { [string match "none" $tempautoGen] } {
            set st_autogen 0
        } else {
            set st_autogen 2
        }

        destroy .projSett
    }

    grid config $framea -row 0 -column 0 -sticky w -padx 10 -pady 10
    grid config $framea.la_save -row 0 -column 0 -sticky w
    grid config $frame1 -row 1 -column 0 -padx 10 -sticky w
    grid config $frame1.st_autogenSave -row 0 -column 0
    grid config $frame1.ra_prompt -row 0 -column 1 -padx 5
    grid config $frame1.ra_discard -row 0 -column 2

    grid config $frameb -row 1 -column 0 -sticky w -padx 10 -pady 10
    grid config $frameb.la_auto -row 0 -column 0 -sticky w
    grid config $frame2 -row 1 -column 0 -padx 10 -sticky w
    grid config $frame2.ra_genYes -row 0 -column 0 -padx 2
    grid config $frame2.ra_genNo -row 0 -column 1 -padx 2

    grid config $winProjSett.t_desc -row 2 -column 0 -padx 10 -pady 10 -sticky news
    grid config $frame3 -row 8 -column 0 -pady 10
    grid config $frame3.bt_ok -row 0 -column 0
    grid config $frame3.bt_cancel -row 0 -column 1

    wm protocol .projSett WM_DELETE_WINDOW "$frame3.bt_cancel invoke"
    bind $winProjSett <KeyPress-Return> "$frame3.bt_ok invoke"
    bind $winProjSett <KeyPress-Escape> "$frame3.bt_cancel invoke"
    Operations::centerW $winProjSett

}

#-------------------------------------------------------------------------------
#  ChildWindows::ProjectSettText
#
#  Arguments: t_desc - path of the text widget
#
#  Results: -
#
#  Description: Displays description message for project settings
#-------------------------------------------------------------------------------
proc ChildWindows::ProjectSettText {t_desc} {
    global st_save
    global st_autogen

    switch -- $st_save {
        0 {
            set msg1 "Edited data are saved automatically"
        }
        1 {
            set msg1 "Prompts the user for saving the edited data"
        }
        2 {
            set msg1 "Edited data is discarded unless user saves it"
        }
    }

    if { $st_autogen == 1 } {
        set msg2 "Autogenerates MN object dictionary during build"
    } else {
        set msg2 "User imported xdd or xdc file will be built"
    }

    $t_desc configure -state normal
    $t_desc delete 1.0 end
    $t_desc insert 1.0 "$msg1\n\n$msg2"
    $t_desc configure -state disabled
}

#-------------------------------------------------------------------------------
#  ChildWindows::AddCNWindow
#
#  Arguments: -
#
#  Results: -
#
#  Description: Creates the child window for creating CN
#-------------------------------------------------------------------------------
proc ChildWindows::AddCNWindow {} {
    global cnName
    global nodeId
    global tmpImpCnDir
    global lastXD
    global frame1
    global frame3

    set winAddCN .addCN
    catch "destroy $winAddCN"
    toplevel     $winAddCN
    wm title     $winAddCN "Add New Node"
    wm resizable $winAddCN 0 0
    wm transient $winAddCN .
    wm deiconify $winAddCN
    grab $winAddCN

    label $winAddCN.la_empty -text ""

    set frame1 [frame $winAddCN.frame1]
    set frame2 [frame $frame1.frame2]
    set frame3 [frame $winAddCN.frame3]

    label $frame2.la_name -text "Name :   " -justify left
    label $frame2.la_node -text "Node ID :" -justify left
    label $frame1.la_cn -text "CN Configuration"

    radiobutton $frame1.ra_def -text "Default" -variable confCn -value on  -command {
        $frame1.en_imppath config -state disabled
        $frame1.bt_imppath config -state disabled
    }
    radiobutton $frame1.ra_imp -text "Import XDC/XDD" -variable confCn -value off -command {
        $frame1.en_imppath config -state normal
        $frame1.bt_imppath config -state normal
    }
    $frame1.ra_def select

    set autoGen [ChildWindows::GenerateCNname]

    entry $frame2.en_name -textvariable cnName -background white -relief ridge -validate key -vcmd "Validation::IsValidName %P"
    set cnName [lindex $autoGen 0]
    $frame2.en_name selection range 0 end
    $frame2.en_name icursor end
    entry $frame2.en_node -textvariable nodeId -background white -relief ridge -validate key -vcmd "Validation::IsInt %P %V"
    set nodeId [lindex $autoGen 1]
    entry $frame1.en_imppath -textvariable tmpImpCnDir -background white -relief ridge -width 25
    if {![file isdirectory $lastXD] && [file exists $lastXD] } {
        set tmpImpCnDir $lastXD
    } else {
        set tmpImpCnDir ""
    }
    $frame1.en_imppath config -state disabled

    button $frame1.bt_imppath -width 8 -text Browse -command {
        set types {
                {{XDC/XDD Files} {.xd*} }
                {{XDD Files}     {.xdd} }
            {{XDC Files}     {.xdc} }
        }
        if {![file isdirectory $lastXD] && [file exists $lastXD] } {
            set tmpImpCnDir [tk_getOpenFile -title "Import XDC/XDD" -initialfile $lastXD -filetypes $types -parent .addCN]
        } else {
            set tmpImpCnDir [tk_getOpenFile -title "Import XDC/XDD" -filetypes $types -parent .addCN]
        }
    }
    $frame1.bt_imppath config -state disabled
    button $frame3.bt_ok -width 8 -text "  Ok  " -command {
        set cnName [string trim $cnName]
        if {$cnName == "" } {
            tk_messageBox -message "Enter CN name (free form text without space)" -parent .addCN -icon error
            focus .addCN
            return
        }
        if {$nodeId == "" } {
            tk_messageBox -message "Enter Node id (1 to 239)" -parent .addCN -icon error
            focus .addCN
            return
        }
        if {$nodeId < 1 || $nodeId > 239 } {
            tk_messageBox -message "Node id should be between 1 to 239" -parent .addCN -icon error
            focus .addCN
            return
        }
        if {$confCn=="off"} {
            if {![file isfile $tmpImpCnDir]} {
                tk_messageBox -message "Entered path to Import XDC/XDD file does not exist" -icon error -parent .addCN
                focus .addCN
                return
            }
            set ext [file extension $tmpImpCnDir]
            if { $ext == ".xdc" || $ext == ".xdd" } {
                #file is of correct type
            } else {
                tk_messageBox -message "Import files only of type XDC/XDD" -icon error -parent .addCN
                focus .addCN
                return
            }
            set lastXD $tmpImpCnDir
        }

        if {$confCn == "off"} {
                catch { destroy .addCN }
            #import the user selected xdc/xdd file for cn
            set chk [Operations::AddCN $cnName $tmpImpCnDir $nodeId]
        } else {
            #import the default cn xdd file
            global resourcesDir
            set tmpImpCnDir [file join $resourcesDir openPOWERLINK_CN.xdd]
            if {[file exists $tmpImpCnDir]} {
                    catch { destroy .addCN }
                set chk [Operations::AddCN $cnName $tmpImpCnDir $nodeId]
            } else {
                #there is no default xdd file in required path
                tk_messageBox -message "Default xdd file for CN not found" -icon error -parent .addCN
                focus .addCN
                return
            }
        }
        catch { $frame3.bt_cancel invoke }
    }

    button $frame3.bt_cancel -width 8 -text Cancel -command {
        catch {
            unset cnName
            unset nodeId
            unset tmpImpCnDir
            unset frame1
            unset frame3
        }
        catch { destroy .addCN }
    }

    grid config $frame1 -row 0 -column 0 -padx 15 -pady 15

    grid config $frame2 -row 0 -column 0 -columnspan 2 -sticky w
    grid config $frame2.la_name -row 0 -column 0 -sticky w
    grid config $frame2.en_name -row 0 -column 1 -sticky w -pady 5
    grid config $frame2.la_node -row 1 -column 0 -sticky w
    grid config $frame2.en_node -row 1 -column 1 -sticky w -pady 5

    grid config $frame1.la_cn -row 1 -column 0 -sticky w -pady 5
    grid config $frame1.ra_def -row 2 -column 0 -sticky w -pady 5
    grid config $frame1.ra_imp -row 3 -column 0 -sticky w
    grid config $frame1.en_imppath -row 3 -column 1 -padx 5 -pady 5 -sticky w
    grid config $frame1.bt_imppath -row 3 -column 2 -sticky w

    grid config $frame3 -row 4 -column 0 -columnspan 3 -pady 5
    grid config $frame3.bt_ok -row 0 -column 0 -padx 3
    grid config $frame3.bt_cancel -row 0 -column 1 -padx 3

    wm protocol .addCN WM_DELETE_WINDOW "$frame3.bt_cancel invoke"
    bind $winAddCN <KeyPress-Return> "$frame3.bt_ok invoke"
    bind $winAddCN <KeyPress-Escape> "$frame3.bt_cancel invoke"

    focus $frame2.en_name
    Operations::centerW $winAddCN
}

#-------------------------------------------------------------------------------
#  ChildWindows::GenerateCNname
#
#  Arguments: -
#
#  Results: -
#
#  Description: Generates unique  name and node id for CN
#-------------------------------------------------------------------------------
proc ChildWindows::GenerateCNname {} {
    global nodeIdList
    global treePath

    for {set inc 1} {$inc < 240} {incr inc} {
        if {[lsearch -exact $nodeIdList $inc] == -1 } {
            break;
        }
    }
    if {$inc == 240} {
        #239 cn are created
    } else {
        return [list CN_$inc $inc]
    }
}

#-------------------------------------------------------------------------------
#  ChildWindows::SaveProjectWindow
#
#  Arguments: -
#
#  Results: -
#
#  Description: Creates the child window for save project
#-------------------------------------------------------------------------------
proc ChildWindows::SaveProjectWindow {} {
    global projectDir
    global projectName
    global treePath
    global status_save

    if {$projectDir == "" || $projectName == "" } {
        Console::DisplayInfo "No project present to save" info
        return
    } else {
        #check whether project has changed from last saved
        if {$status_save} {
            set result [tk_messageBox -message "Save Project $projectName?" -type yesnocancel -icon question -title "Question" -parent .]
            switch -- $result {
                yes {
                    Operations::Saveproject
                    Console::DisplayInfo "Project $projectName at location $projectDir is saved" info
                    return yes
                }
                no {
                    Console::DisplayInfo "Project $projectName not saved" info
                    if { ![file exists [file join $projectDir $projectName].xml ] } {
                        catch { file delete -force -- $projectDir }
                    }
                    return no
                }
                cancel {
                    return cancel
                }
            }
        }
    }
}

#-------------------------------------------------------------------------------
#  ChildWindows::SaveProjectAsWindow
#
#  Arguments: -
#
#  Results: -
#
#  Description: Creates the child window for save as project
#-------------------------------------------------------------------------------
proc ChildWindows::SaveProjectAsWindow {} {

    global projectName
    global projectDir

    set tempPreviousProjectName $projectName

    if {$projectDir == "" || $projectName == "" } {
        Console::DisplayInfo "No Project present to save" info
        return
    } else {
        set saveProjectAs [tk_getSaveFile -parent . -title "Save Project As" -initialdir $projectDir -initialfile $projectName]
        if { $saveProjectAs == "" } {
            return
        }
        set tempProjectDir [file dirname $saveProjectAs]
        set tempProjectName [file tail $saveProjectAs]
        set tempProjectNameNoExtn [string range $tempProjectName 0 end-[string length [file extension $tempProjectName]]]

        #puts "saveProjectAs:$saveProjectAs tempProjectDir:$tempProjectDir tempProjectName:$tempProjectName tempProjectNameNoExtn:$tempProjectNameNoExtn"
        thread::send [tsv::set application importProgress] "StartProgress"
        set result [openConfLib::SaveProjectAs $tempProjectName $saveProjectAs]

        if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
            thread::send [tsv::set application importProgress] "StopProgress"
            openConfLib::ShowErrorMessage [lindex $result 0]
            Console::DisplayErrMsg "Error in saving project $saveProjectAs"
            return
        } else {
            #since the .oct file will be saved with same name as folder variable 'tempProjectNameNoExtn' is used twice
            set openResult [Operations::openProject [file join $saveProjectAs $tempProjectName].xml]
            if {$openResult == 1} {
                Console::ClearMsgs
                Console::DisplayInfo "project $tempPreviousProjectName is saved as $saveProjectAs and opened"
            }
            thread::send  [tsv::set application importProgress] "StopProgress"
        }
    }
}

#-------------------------------------------------------------------------------
#  ChildWindows::NewProjectWindow
#
#  Arguments: -
#
#  Results: -
#
#  Description: Creates the child window for new project creation
#-------------------------------------------------------------------------------
proc ChildWindows::NewProjectWindow {} {
    global tmpPjtName
    global tmpPjtDir
    global tmpImpDir
    global winNewProj
    global st_save
    global st_autogen
    global newProjectFrame2
    global frame1_1
    global frame1_4
    global frame2_1
    global frame2_2
    global frame2_3

    global treePath
    global nodeIdList
    global projectName
    global projectDir
    global defaultProjectDir
    global status_save
    global lastXD
    global tcl_platform

    set winNewProj .newprj
    catch "destroy $winNewProj"
    toplevel $winNewProj
    wm title     $winNewProj    "Project Wizard"
    wm resizable $winNewProj 0 0
    wm transient $winNewProj .
    wm deiconify $winNewProj
    wm minsize   $winNewProj 50 200
    grab $winNewProj

    set newProjectFrame2 [frame $winNewProj.frame2 -width 650 -height 470 ]
    grid configure $newProjectFrame2 -row 0 -column 0 -sticky news -sticky news -padx 15 -pady 15

    set frame2_1 [frame $newProjectFrame2.frame2_1]
    set frame2_2 [frame $newProjectFrame2.frame2_2]
    set frame2_3 [frame $frame2_1.frame2_3]

    label $frame2_1.la_mn -text "MN Configuration"
    label $frame2_1.la_generate -text "Auto Generate"
    label $frame2_1.la_desc -text "Description"

    entry $frame2_1.en_imppath -textvariable tmpImpDir -background white -relief ridge -width 28 -state disabled
    if {![file isdirectory $lastXD] && [file exists $lastXD] } {
        set tmpImpDir $lastXD
    } else {
        set tmpImpDir ""
    }

    if {"$tcl_platform(platform)" == "windows"} {
            set text_width 45
            set text_padx 37
    } else {
            set text_width 55
            set text_padx 27
    }

    text $frame2_1.t_desc -height 5 -width 40 -state disabled -background white

    radiobutton $frame2_1.ra_def -text "Default" -variable conf -value on -command {
        ChildWindows::NewProjectMNText $frame2_1.t_desc
        $frame2_1.en_imppath config -state disabled
        $frame2_1.bt_imppath config -state disabled
    }
    radiobutton $frame2_1.ra_imp -text "Import XDC/XDD" -variable conf -value off -command {
        ChildWindows::NewProjectMNText $frame2_1.t_desc
        $frame2_1.en_imppath config -state normal
        $frame2_1.bt_imppath config -state normal
    }
    $frame2_1.ra_def select

    set st_autogen 1

    radiobutton $frame2_1.ra_yes -text "Yes" -variable st_autogen -value 1 -command "ChildWindows::NewProjectMNText  $frame2_1.t_desc"
    radiobutton $frame2_1.ra_no -text "No" -variable st_autogen -value 0 -command "ChildWindows::NewProjectMNText  $frame2_1.t_desc"
    $frame2_1.ra_yes select
    ChildWindows::NewProjectMNText $frame2_1.t_desc

    button $frame2_1.bt_imppath -state disabled -width 8 -text Browse -command {
        set types {
                {{XDC/XDD Files} {.xd*} }
                {{XDD Files}     {.xdd} }
            {{XDC Files}     {.xdc} }
        }
        if {![file isdirectory $lastXD] && [file exists $lastXD] } {
            set tmpImpDir [tk_getOpenFile -title "Import XDC/XDD" -initialfile $lastXD -filetypes $types -parent .newprj]
        } else {
            set tmpImpDir [tk_getOpenFile -title "Import XDC/XDD" -filetypes $types -parent .newprj]
        }
        if {$tmpImpDir == ""} {
            focus .newprj
            return
        }
    }

    button $frame2_2.bt_back -width 8 -text " Back " -command {
        grid remove $winNewProj.frame2
        grid $winNewProj.frame1
        bind $winNewProj <KeyPress-Return> "$frame1_4.bt_next invoke"
    }

    button $frame2_2.bt_next -width 8 -text "  Ok  " -command {
        if {$conf=="off" } {
            if {![file isfile $tmpImpDir]} {
                tk_messageBox -message "Entered path to Import XDC/XDD file does not exist" -icon warning -parent .newprj
                focus .newprj
                return
            }
            set ext [file extension $tmpImpDir]
            if { $ext == ".xdc" || $ext == ".xdd" } {
                #correct type continue
            } else {
                tk_messageBox -message "Import files only of type XDC/XDD" -icon warning -parent .newprj
                focus .newprj
                return
            }
            set lastXD $tmpImpDir
        } else {
            global resourcesDir
            set tmpImpDir [file join $resourcesDir openPOWERLINK_MN.xdd]
            if {![file isfile $tmpImpDir]} {
                tk_messageBox -message "Default xdd file for MN is not found" -icon warning -parent .newprj
                focus .newprj
                return
            }
        }

        catch { destroy .newprj }
        #all new projects have "SIMPLE" type
        set Operations::viewType "SIMPLE"
        set ::st_save $temp_st_save
        ChildWindows::NewProjectCreate $tmpPjtDir $tmpPjtName $tmpImpDir $st_autogen
        catch {
            unset tmpPjtName
            unset tmpPjtDir
            unset tmpImpDir
            unset newProjectFrame2
            unset frame1_1
            unset frame1_4
            unset frame2_1
            unset frame2_2
            unset frame2_3
            unset winNewProj
        }
    }

    button $frame2_2.bt_cancel -width 8 -text "Cancel" -command {
        set st_autogen 1
        catch { $frame1_4.bt_cancel invoke }
    }

    grid config $frame2_1 -row 0 -column 0 -sticky w
    grid config $frame2_1.la_mn -row 0 -column 0 -sticky w
    grid config $frame2_1.ra_def -row 1 -column 0 -sticky w
    grid config $frame2_1.ra_imp -row 2 -column 0 -sticky w
    grid config $frame2_1.en_imppath -row 2 -column 1 -sticky w -padx 5 -pady 10
    grid config $frame2_1.bt_imppath -row 2 -column 2 -sticky w
    grid config $frame2_1.la_generate -row 3 -column 0 -columnspan 2 -sticky w
    grid config $frame2_1.ra_yes -row 4 -column 0 -sticky w -pady 2 -padx 5
    grid config $frame2_1.ra_no -row 5 -column 0 -sticky w -pady 3 -padx 5
    grid config $frame2_1.la_desc -row 6 -column 0 -sticky w
    grid config $frame2_1.t_desc -row 7 -column 0 -columnspan 3 -pady 10 -sticky news
    grid config $frame2_2 -row 8 -column 0
    grid config $frame2_2.bt_back -row 0 -column 0
    grid config $frame2_2.bt_next -row 0 -column 1
    grid config $frame2_2.bt_cancel -row 0 -column 2

    grid remove $winNewProj.frame2

    set newProjectFrame1 [frame $winNewProj.frame1 -width 650 -height 470 ]
    grid configure $newProjectFrame1 -row 0 -column 0 -sticky news -padx 15 -pady 15


    set frame1_1 [frame $newProjectFrame1.frame1_1]
    set frame1_4 [frame $newProjectFrame1.frame1_4]


    label $winNewProj.la_empty -text "               "
    label $winNewProj.la_empty1 -text "               "
    label $frame1_1.la_pjname -text "Project Name" -justify left
    label $frame1_1.la_pjpath -text "Choose Path" -justify left
    label $frame1_1.la_saveoption -text "Choose Save Option" -justify left
    label $frame1_1.la_desc -text "Description"
    label $frame1_1.la_empty1 -text ""
    label $frame1_1.la_empty2 -text ""
    label $frame1_1.la_empty3 -text ""
    label $frame1_1.la_empty4 -text ""

    entry $frame1_1.en_pjname -textvariable tmpPjtName -background white -relief ridge -validate key -vcmd "Validation::IsValidName %P" -width 35
    set tmpPjtName  [Operations::GenerateAutoName $defaultProjectDir Project ""]

    $frame1_1.en_pjname selection range 0 end
    $frame1_1.en_pjname icursor end

    entry $frame1_1.en_pjpath -textvariable tmpPjtDir -background white -relief ridge -width 35
    set tmpPjtDir $defaultProjectDir

    text $frame1_1.t_desc -height 5 -width 40 -state disabled -background white

    set st_save 1
    radiobutton $frame1_1.ra_save -text "Auto Save" -variable temp_st_save -value 0 -command "ChildWindows::NewProjectText $frame1_1.t_desc 0"
    radiobutton $frame1_1.ra_prompt -text "Prompt" -variable temp_st_save -value 1 -command "ChildWindows::NewProjectText $frame1_1.t_desc 1"
    radiobutton $frame1_1.ra_discard -text "Discard" -variable temp_st_save -value 2 -command "ChildWindows::NewProjectText $frame1_1.t_desc 2"
    $frame1_1.ra_prompt select
    ChildWindows::NewProjectText $frame1_1.t_desc 1

    button $frame1_1.bt_pjpath -width 8 -text Browse -command {
        set tmpPjtDir [tk_chooseDirectory -title "Project Location" -initialdir $defaultProjectDir -parent .newprj]
        if {$tmpPjtDir == ""} {
            focus .newprj
            return
        }
    }

    button $frame1_4.bt_back -state disabled -width 8 -text "Back"
    button $frame1_4.bt_next -width 8 -text " Next " -command {
        set tmpPjtName [string trim $tmpPjtName]
        if {$tmpPjtName == "" } {
            tk_messageBox -message "Enter Project Name" -icon warning -parent .newprj
            focus .newprj
            return
        }
        if {![file isdirectory $tmpPjtDir]} {
            tk_messageBox -message "Entered path for Project is not a directory" -icon warning -parent .newprj
            focus .newprj
            return
        }
        if {![file writable $tmpPjtDir]} {
            tk_messageBox -message "Entered path for Project is write protected\nChoose another path" -icon info -parent .newprj
            focus .newprj
            return
        }
        if {[file exists [file join $tmpPjtDir $tmpPjtName]]} {
            set result [tk_messageBox -message "Folder $tmpPjtName already exists.\nDo you want to overwrite it?" -type yesno -icon question -parent .newprj]
             switch -- $result {
                yes {
                    #continue with process
                }
                    no  {
                    focus $frame1_1.en_pjname
                    return
                }
             }
        }
        grid remove $winNewProj.frame1
        grid $winNewProj.frame2
        bind $winNewProj <KeyPress-Return> "$frame2_2.bt_next invoke"
    }

    button $frame1_4.bt_cancel -width 8 -text Cancel -command {
        global projectName
        global projectDir
        global st_save
        global st_autogen
        global st_viewType
        set st_save 1
        catch {
            if { $projectDir != "" && $projectName != "" } {

                set result [openConfLib::GetActiveView]
                set st_viewType [lindex $result 1]

                set result [openConfLib::GetActiveAutoCalculationConfig]
                if { [lindex $result 1] == 1 } {
                    set st_autogen "all"
                } else {
                    set st_autogen "none"
                }
            }
        }

        catch {
            unset tmpPjtName
            unset tmpPjtDir
            unset tmpImpDir
            unset newProjectFrame2
            unset frame1_1
            unset frame1_4
            unset frame2_1
            unset frame2_2
            unset frame2_3
            unset winNewProj
        }
        catch { destroy .newprj }
        return
    }

    grid config $frame1_1 -row 0 -column 0 -sticky w
    grid config $frame1_1.la_pjname -row 0 -column 0 -sticky w
    grid config $frame1_1.en_pjname -row 0 -column 1 -sticky w -padx 5
    grid config $frame1_1.la_pjpath -row 2 -column 0 -sticky w
    grid config $frame1_1.en_pjpath -row 2 -column 1 -sticky w -padx 5 -pady 10
    grid config $frame1_1.bt_pjpath -row 2 -column 2 -sticky w
    grid config $frame1_1.la_saveoption -row 4 -column 0 -columnspan 2 -sticky w
    grid config $frame1_1.ra_save -row 5 -column 1 -sticky w -pady 2
    grid config $frame1_1.ra_prompt -row 6 -column 1 -sticky w
    grid config $frame1_1.ra_discard -row 7 -column 1 -sticky w -pady 2
    grid config $frame1_1.la_desc -row 8 -column 0 -sticky w
    grid config $frame1_1.t_desc -row 9 -column 0 -columnspan 3 -pady 10 -sticky news
    grid config $frame1_4 -row 11 -column 0
    grid config $frame1_4.bt_back -row 0 -column 0
    grid config $frame1_4.bt_next -row 0 -column 1
    grid config $frame1_4.bt_cancel -row 0 -column 2

    wm protocol .newprj WM_DELETE_WINDOW "$frame1_4.bt_cancel invoke"
    bind $winNewProj <KeyPress-Return> "$frame1_4.bt_next invoke"
    bind $winNewProj <KeyPress-Escape> "$frame1_4.bt_cancel invoke"

    focus $frame1_1.en_pjname
    Operations::centerW $winNewProj
}

#-------------------------------------------------------------------------------
#  ChildWindows::NewProjectText
#
#  Arguments: t_desc - path of the text widget
#              choice - message displayed based on choice
#
#  Results: -
#
#  Description : Displays description message for project settings
#-------------------------------------------------------------------------------
proc ChildWindows::NewProjectText {t_desc choice} {
    $t_desc configure -state normal
    switch -- $choice {
        0 {
            $t_desc delete 1.0 end
            $t_desc insert end "Edited data are saved automatically"
        }
        1 {
            $t_desc delete 1.0 end
            $t_desc insert end "Prompts the user for saving the edited data"
        }
        2 {
            $t_desc delete 1.0 end
            $t_desc insert end "Edited data is discarded unless user saves it"
        }
    }
    $t_desc configure -state disabled
}

#-------------------------------------------------------------------------------
#  ChildWindows::NewProjectMNText
#
#  Arguments: t_desc - path of the text widget
#
#  Results: -
#
#  Description : Displays description message for imported file for mn and autogenerate
#-------------------------------------------------------------------------------
proc ChildWindows::NewProjectMNText {t_desc} {
    global conf
    global st_autogen

    if { $conf == "on" } {
        set msg1 "Imports default xdd file designed by Kalycito for openPOWERLINK MN"
    } else {
        set msg1 "Imports user selected xdd or xdc file for openPOWERLINK MN"
    }

    if { $st_autogen == 1 } {
        set msg2 "Autogenerates MN object dictionary during build"
    } else {
        set msg2 "User imported xdd or xdc file will be build"
    }

    $t_desc configure -state normal
    $t_desc delete 1.0 end
    $t_desc insert 1.0 "$msg1\n\n$msg2"
    $t_desc configure -state disabled
}

#-------------------------------------------------------------------------------
#  ChildWindows::NewProjectCreate
#
#  Arguments: tmpPjtDir   - project location
#              tmpPjtName  - project name
#              tmpImpDir   - file to be imported
#              tempst_autogen - Auto generate ?(1 - all or 0 - none)
#  Results: -
#
#  Description : creates the new project
#-------------------------------------------------------------------------------
proc ChildWindows::NewProjectCreate {tmpPjtDir tmpPjtName tmpImpDir tempst_autogen} {
    global rootDir
    global treePath
    global mnCount
    global projectName
    global projectDir
    global nodeIdList
    global status_save
    global st_save
    global st_autogen
    global st_viewType
    global image_dir
    global lastVideoModeSel

    #CloseProject is called to delete node and insert tree
    Operations::CloseProject

    set projectName $tmpPjtName
    set pjtName [string range $projectName 0 end-[string length [file extension $projectName]] ]
    set projectDir [file join $tmpPjtDir $pjtName]

    $treePath itemconfigure ProjectNode -text $tmpPjtName

    image create photo img_mn -file "$image_dir/mn.gif"
    image create photo img_pdo -file "$image_dir/pdo.gif"

    $treePath insert end ProjectNode Network-1 -text "openPOWERLINK_Network" -open 1 -image img_mn
    thread::send [tsv::get application importProgress] "StartProgress"

    set mnName "MN"
    set mnNodeId 240
    $treePath insert end Network-1 MN-$mnNodeId -text "$mnName\($mnNodeId\)" -open 1 -image img_mn
    lappend nodeIdList $mnNodeId

    set result [openConfLib::NewProject $pjtName $projectDir $tmpImpDir]
    openConfLib::ShowErrorMessage $result
    if { [Result_IsSuccessful $result] != 1 } {
        thread::send  [tsv::set application importProgress] "StopProgress"
        return
    }

#puts "importing wrapper $Operations::viewType"

    set result [WrapperInteractions::Import MN-$mnNodeId $mnNodeId]
    thread::send  [tsv::set application importProgress] "StopProgress"
    if { $result == "fail" } {
        return
    }

    #New project is created need to save
    set status_save 1

    Console::DisplayInfo "Imported file $tmpImpDir for MN"

    file mkdir [file join $projectDir ]

    #By default {output path is projectdir/output} and {viewtype is "0/SIMPLE"}
    set outputpath [file join $projectDir output]

    set result [openConfLib::AddViewSetting 0 "default" "SIMPLE"]
    set result [openConfLib::AddViewSetting 1 "default" "EXPERT"]

    set viewType 0

    set result [openConfLib::SetActiveView $viewType]

    set st_autogen $tempst_autogen
    #By default the autocalculation is all
    if { $st_autogen == 1 } {
        set result [openConfLib::SetActiveAutoCalculationConfig "all"]
    } else {
        set result [openConfLib::SetActiveAutoCalculationConfig "none"]
    }

    set result [openConfLib::GetViewSetting $viewType "default"]
    set returnedViewType [lindex $result 1]

    set st_viewType $viewType
    set Operations::viewType $returnedViewType
    set lastVideoModeSel $viewType

    Console::ClearMsgs

    if { [$Operations::projMenu index 2] != "2" } {
        $Operations::projMenu insert 2 command -label "Close Project" -command "Operations::InitiateCloseProject"
    }
    if { [$Operations::projMenu index 3] != "3" } {
        $Operations::projMenu insert 3 command -label "Properties..." -command "ChildWindows::PropertiesWindow"
    }

    #puts "$Operations::viewType :: viwe: $st_viewType"
}

#-------------------------------------------------------------------------------
#  ChildWindows::CloseProjectWindow
#
#  Arguments: -
#
#  Results: -
#
#  Description: Creates the child window to close project
#-------------------------------------------------------------------------------
proc ChildWindows::CloseProjectWindow {} {
    global projectDir
    global projectName
    global treePath
    global status_save

    if {$projectDir == "" || $projectName == "" } {
        Console::DisplayInfo "No Project present to close" info
        Operations::CloseProject
        return
    } else {
        set result [tk_messageBox -message "Close Project $projectName?" -type okcancel -icon question -title "Question" -parent .]
         switch -- $result {
            ok {
                Operations::CloseProject
                return ok
            }
            cancel {
                return cancel
            }
        }
    }
}

#-------------------------------------------------------------------------------
#  ImportProgress
#
#  Arguments: stat - change the status of progressbar
#
#  Results: -
#
#  Description: Creates the child window displaying progress bar
#-------------------------------------------------------------------------------
proc ImportProgress {stat} {
    if {$stat == "start"} {
        wm deiconify .
        raise .
        focus .
        set winImpoProg .
        wm title     $winImpoProg   "In Progress"
        wm resizable $winImpoProg 0 0
        wm deiconify $winImpoProg
        grab $winImpoProg

        if {![winfo exists .prog]} {
            set prog [ttk::progressbar .prog -mode indeterminate -orient horizontal -length 200 ]
            grid config $prog -row 0 -column 0 -padx 10 -pady 10
        }
        catch { .prog start 10 }
        catch { BWidget::place $winImpoProg 0 0 center }
        update idletasks
        return
    } elseif {$stat == "stop" } {
        catch { .prog stop }
        wm withdraw .
    } else {
    }
}

#-------------------------------------------------------------------------------
#  ChildWindows::PropertiesWindow
#
#  Arguments: -
#
#  Results: -
#
#  Description: Creates the child window and adds the pdo index
#-------------------------------------------------------------------------------
proc ChildWindows::PropertiesWindow {} {
    global treePath
    global projectDir

    set node [$treePath selection get]

    set winProp .prop
    catch "destroy $winProp"
    toplevel $winProp
    wm resizable $winProp 0 0
    wm transient $winProp .
    wm deiconify $winProp
    wm minsize   $winProp 200 100
    grab $winProp

    set frame1 [frame $winProp.frame -padx 5 -pady 5 ]

    if {$node == "ProjectNode"} {
        wm title $winProp "Project Properties"
        set title "Project Properties"
        set title1 "Name"
        set display1 [$treePath itemcget $node -text]
        set title2 "Location"
        set display2 $projectDir
        set message "$title1$display1\n$title2$display2"
    } else {
        return
    }

    label $frame1.la_title1 -text $title1
    label $frame1.la_sep1 -text ":"
    label $frame1.la_display1 -text $display1
    label $frame1.la_title2 -text $title2
    label $frame1.la_sep2 -text ":"
    label $frame1.la_display2 -text $display2
    label $frame1.la_empty1 -text ""
    label $frame1.la_empty2 -text ""

    button $winProp.bt_ok -text "  Ok  " -width 8 -command {
        destroy .prop
    }

    pack configure $frame1
    grid config $frame1.la_empty1 -row 0 -column 0 -columnspan 2

    grid config $frame1.la_title1 -row 1 -column 0 -sticky w
    grid config $frame1.la_sep1 -row 1 -column 1
    grid config $frame1.la_display1 -row 1 -column 2 -sticky w
    grid config $frame1.la_title2 -row 2 -column 0  -sticky w
    grid config $frame1.la_sep2 -row 2 -column 1
    grid config $frame1.la_display2 -row 2 -column 2 -sticky w
    if { $node == "ProjectNode" } {
        grid config $frame1.la_empty2 -row 3 -column 0 -columnspan 1
        pack configure $winProp.bt_ok -pady 10
    } else {
        #should not occur
    }

    wm protocol .prop WM_DELETE_WINDOW "$winProp.bt_ok invoke"
    bind $winProp <KeyPress-Return> "$winProp.bt_ok invoke"
    bind $winProp <KeyPress-Escape> "$winProp.bt_ok invoke"
    Operations::centerW $winProp
    focus $winProp
}
