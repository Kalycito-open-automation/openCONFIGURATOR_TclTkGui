################################################################################
# \file   operations.tcl
#
# \brief  Contains the major functionality of the tool
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
#  namespace: Validation
#-------------------------------------------------------------------------------
namespace eval Operations {
    variable mnMenu
    variable cnMenu
    variable networkMenu
    variable cnMenuIndex
    variable projMenu
    variable obdMenu
    variable mnCount
    variable cnCount
    variable notebook
    variable tree_notebook
    variable infotabs_notebook
    variable pannedwindow1
    variable pannedwindow2
    variable mainframe
    variable progressmsg
    variable prgressindicator
    variable showtoolbar  1
    variable viewType
    variable CYCLE_TIME_OBJ
    variable ASYNC_MTU_SIZE_OBJ
    variable ASYNC_TIMEOUT_OBJ
    variable MULTI_PRESCAL_OBJ
    variable PRES_TIMEOUT_OBJ
    variable PRES_TIMEOUT_LIMIT_OBJ
    variable LOSS_SOC_TOLERANCE
}

#Initiating thread for progress bar
package require Thread

tsv::set application main [thread::id]
tsv::set application importProgress [thread::create -joinable {
    package require Tk
    set rootDir [tsv::get application rootDir]
    set rootDir "$rootDir/tcl-sources"
    set path_to_BWidget [file join $rootDir BWidget-1.2.1]
    lappend auto_path $path_to_BWidget
    package require -exact BWidget 1.2.1
    source [file join $rootDir childWindows.tcl]

    wm withdraw .
    if {"$tcl_platform(platform)" != "windows"} {
        . config -bg #d7d5d3
    }
    wm protocol . WM_DELETE_WINDOW dont_exit
    wm title . "progress"
    BWidget::place . 0 0 center
    update idletasks

    if {"$tcl_platform(platform)" == "unix"} {
    catch {
        set element [image create photo -file [file join $rootDir openConfig.gif] ]
        wm iconphoto . -default $element
    }
    }
    proc StartProgress {} {
        ImportProgress start
    }
    proc StopProgress {} {
        ImportProgress stop
    }
    proc exit_thread {} {
        wm protocol . WM_DELETE_WINDOW ""
    }
    proc dont_exit {} {
        return
    }
    thread::wait
}]


set dir [file dirname [info script]]
source [file join $dir option.tcl]

#-------------------------
#   Initializing global variables
#-------------------------
global projectDir
global projectName
global build_nodesList
global image_dir

set build_nodesList 0
set cnCount 0
set mnCount 0
set nodeIdList ""
set savedValueList ""
set nodeSelect ""
set lastXD ""
set lastOpenPjt ""
set LastTableFocus ""
set status_save 0
Validation::ResetPromptFlag

## see Operations::MNProperties, NoteBookManager::SaveMNValue, Operations::CN**
set Operations::CYCLE_TIME_OBJ 0x1006
set Operations::LOSS_SOC_TOLERANCE 0x1C14
set Operations::ASYNC_MTU_SIZE_OBJ [list 0x1F98 0x08]
set Operations::ASYNC_TIMEOUT_OBJ [list 0x1F8A 0x02]
set Operations::MULTI_PRESCAL_OBJ [list 0x1F98 0x07]
set Operations::PRES_TIMEOUT_LIMIT_OBJ [list 0x1F98 0x03]

#-------------------------------------------------------------------------------
#  Operations::about
#
#  Arguments : -
#
#  Results : -
#
#  Description : Information about tool developer
#-------------------------------------------------------------------------------
proc Operations::about {} {\
    global version
    global rootDir

    set aboutWindow .about
    catch "destroy $aboutWindow"
    toplevel $aboutWindow
    wm resizable $aboutWindow 0 0
    wm transient $aboutWindow .
    wm deiconify $aboutWindow
    grab $aboutWindow
    wm title     $aboutWindow   "About openCONFIGURATOR"
    wm protocol $aboutWindow WM_DELETE_WINDOW "destroy $aboutWindow"
    set urlFont [font create -family TkDefaultFont -size 9 -underline 0]
    set titleFont [font create -family TkDefaultFont -weight bold -size 13 ]
    set framea [frame $aboutWindow.framea]

    label $framea.title -text "openCONFIGURATOR" -font $titleFont
    label $framea.sub -text "An open-source Ethernet POWERLINK configuration tool"
    label $framea.01 -text "Version:" -justify left
    label $framea.02 -text "$version" -justify left
    label $framea.11 -text "Designed by:" -justify left
    label $framea.12 -text "Kalycito Infotech Pvt Ltd" -foreground blue -activeforeground blue -font $urlFont -justify left
    label $framea.21 -text "Contact us:" -justify left
    label $framea.22 -text "info@kalycito.com" -foreground blue -activeforeground blue -font $urlFont -justify left
    bind $framea.12 <1> "Operations::LocateUrl www.kalycito.com"
    bind $framea.22 <1> "Operations::LocateUrl mailto:info@kalycito.com"


    set fullPath "$rootDir/License.txt"
    if { [file isfile $fullPath] } {

    label $framea.31 -text "License:" -justify left
    label $framea.32 -text "BSD License" -foreground blue -activeforeground blue -font $urlFont -justify left
    bind $framea.32 <1> "Operations::openFILE 1 License.txt"

    grid config $framea.31 -row 5 -column 0 -sticky w
    grid config $framea.32 -row 5 -column 1 -sticky w
    #set fp [open $fullPath r]
       # set file_data [read $fp]
       # close $fp

    #set frameb [frame $aboutWindow.frameb]

    #label $frameb.title -text "License Information"
    #text $frameb.txt -height 10 -width 42 -state disabled -background white

    #$frameb.txt configure -state normal
    #$frameb.txt delete 1.0 end
    #$frameb.txt insert 1.0 "$file_data"
    #$frameb.txt configure -state disabled

    #grid config $frameb -row 1 -column 0 -sticky w -padx 10 -pady 10
    #grid config $frameb.title -row 0 -column 0 -columnspan 2
    #grid config $frameb.txt -row 1 -column 0
    }

    grid config $framea -row 0 -column 0 -sticky w -padx 10 -pady 10
    grid config $framea.title -row 0 -column 0 -columnspan 2
    grid config $framea.sub -row 1 -column 0 -columnspan 2
    grid config $framea.01 -row 2 -column 0 -sticky w
    grid config $framea.02 -row 2 -column 1 -sticky w
    grid config $framea.11 -row 3 -column 0 -sticky w
    grid config $framea.12 -row 3 -column 1 -sticky w
    grid config $framea.21 -row 4 -column 0 -sticky w
    grid config $framea.22 -row 4 -column 1 -sticky w

    button $aboutWindow.bt_ok -text Ok -command "destroy $aboutWindow ; font delete $urlFont; font delete $titleFont" -width 8
    grid config $aboutWindow.bt_ok -row 6 -column 0
    bind $aboutWindow <KeyPress-Return> "destroy $aboutWindow"
    bind $aboutWindow <KeyPress-Escape> "destroy $aboutWindow"
    wm protocol $aboutWindow WM_DELETE_WINDOW "destroy $aboutWindow"
    focus $aboutWindow.bt_ok
    Operations::centerW .about
}

#-------------------------------------------------------------------------------
#  Operations::openFILE
#
#  Arguments: path      - Path where the file resides
#             file name - File name to be opened
#
#  Results: -
#
#  Description: Opens the file in a new window (read only)
#-------------------------------------------------------------------------------
proc Operations::openFILE { path filename } {\
    global rootDir
    global projectDir
    global projectName

    if {$path == 1 } {
    set path $rootDir
    #puts "rootDir: $rootDir"
    } elseif { $path == 2 } {
    #puts "$projectDir"
    set path "$projectDir/output"
    }

    set openFileWindow .openFILE
    catch "destroy $openFileWindow"
    toplevel $openFileWindow
    wm resizable $openFileWindow 0 0
    wm transient $openFileWindow .
    wm deiconify $openFileWindow
    wm title     $openFileWindow    "$filename"
    wm protocol $openFileWindow WM_DELETE_WINDOW "destroy $openFileWindow"

    set framea [frame $openFileWindow.framea]

    label $framea.21 -text "Path:"
    label $framea.22 -text "$path"
    $framea.22 configure -wraplength 430

    set file_path "$path/"
    append file_path "$filename"
    if { [file isfile $file_path] } {

        set fp [open $file_path r]
        set file_data [read $fp]
        close $fp

        set framec [frame $openFileWindow.framec -borderwidth 1 ]
        set tabTitlef0 [TitleFrame $framec.tabTitlef0 -text "$filename" ]
        set tabInnerf0 [$tabTitlef0 getframe]
        set scrollWin [ScrolledWindow $tabInnerf0.scrollWin]
        pack $scrollWin -fill both -expand 1
        set sf [ScrollableFrame $scrollWin.sf -height 400 -width 450 -background white]
        $scrollWin setwidget $sf
        set uf [$sf getframe]

        label $uf.word -text "$file_data" -justify left -background white
        grid config $framec -row 2 -column 0 -columnspan 5 -sticky w -padx 10 -pady 10
        grid config $tabTitlef0 -row 0 -column 0 -columnspan 5 -sticky w -padx 10 -pady 10
        grid config $uf.word -row 2 -rowspan 5 -column 0

    } else {
        set frameb [frame $openFileWindow.frameb]
        label $frameb.title -text "Error"
        text $frameb.txt -height 3 -width 50 -state disabled -background white
        $frameb.txt configure -state normal
        $frameb.txt delete 1.0 end
        $frameb.txt insert 1.0 "File not found. Please contact the project support team"
        $frameb.txt configure -state disabled
        grid config $frameb.txt -row 1 -column 0
        grid config $frameb -row 1 -column 0 -sticky w -padx 10 -pady 10
        grid config $frameb.title -row 0 -column 0 -columnspan 2
    }

    grid config $framea -row 0 -column 0 -sticky w -padx 10 -pady 10
    grid config $framea.21 -row 4 -column 0
    grid config $framea.22 -row 4 -column 1 -sticky w


    button $openFileWindow.bt_ok -text Ok -command "destroy $openFileWindow;" -width 8
    grid config $openFileWindow.bt_ok -row 5 -column 0 -columnspan 5
    bind $openFileWindow <KeyPress-Return> "destroy $openFileWindow"
    bind $openFileWindow <KeyPress-Escape> "destroy $openFileWindow"
    wm protocol $openFileWindow WM_DELETE_WINDOW "destroy $openFileWindow"
    focus $openFileWindow.bt_ok
    Operations::centerW .openFILE
    grab $openFileWindow
}

#-------------------------------------------------------------------------------
#  Operations::LocateUrl
#
#  Arguments: -
#
#  Results: -
#
#  Description: Opens the web browser
#-------------------------------------------------------------------------------
proc Operations::LocateUrl {webAddress} {
    global tcl_platform
    set browser ""
    if {$tcl_platform(platform)=="unix"} {
        set browser ""
        if { [file exists /usr/bin/firefox] } {
            set browser "firefox"
        }
        if {$browser==""} {
            tk_messageBox -message "Please visit the site $webAddress for more information." -title Info -icon info
        } else {
            exec $browser $webAddress &
        }

    } elseif {$tcl_platform(platform)=="windows"} {
        eval exec [auto_execok start] $webAddress &
    }
}

#-------------------------------------------------------------------------------
#  Operations::OpenDocument
#
#  Arguments: path     -  1 - Points to the root directory.
#                         2 - Points to the docs directory.
#                         3 - Points to the output folder in the projects.
#  Arguments: filename - filename of the document with extension.
#
#  Results: -
#
#  Description: Opens the document in appropriate tool
#-------------------------------------------------------------------------------
proc Operations::OpenDocument { path filename } {
    global tcl_platform
    global rootDir
    global docsDir
    global projectDir

    if {$path == 1 } {
        set path $rootDir
    } elseif { $path == 2 } {
        set path $docsDir
    } elseif { $path == 3 } {
        set path "$projectDir/output"
    }

    set fullPath [file join $path $filename]
    if {![file isfile $fullPath] } {
        set msg "The file $filename is missing cannot open the document."
        tk_messageBox -message $msg -title Info -icon error
        Console::DisplayErrMsg $msg error
        return
    }

    if {$tcl_platform(platform)=="unix"} {
        exec xdg-open $path/$filename &
    } elseif {$tcl_platform(platform)=="windows"} {
        set path [file nativename $fullPath]
        eval exec [auto_execok start] [list "" "$path" ] &
    }
}

#-------------------------------------------------------------------------------
#  Operations::centerW
#
#  Arguments: windowPath - path of toplevel window
#
#  Results: -
#
#  Description: Place the toplevel window center to application
#-------------------------------------------------------------------------------
proc Operations::centerW windowPath {
    BWidget::place $windowPath 0 0 center
}

#-------------------------------------------------------------------------------
#  Operations::tselectright
#
#  Arguments: x    - x position
#             y    - y position
#             node - selected node in tree widget
#  Results: -
#
#  Description: Displays the 'right click' menu for appropriate node
#-------------------------------------------------------------------------------
proc Operations::tselectright {x y node} {
    variable treeWindow

    $treeWindow selection clear
    $treeWindow selection set $node
    Operations::SingleClickNode $node

    if { [string match "ProjectNode" $node] == 1 } {
        tk_popup $Operations::projMenu $x $y
    } elseif { [string match "MN-*" $node] == 1 } {
        tk_popup $Operations::mnMenu $x $y
    } elseif { [string match "CN-*" $node] == 1 } {
            tk_popup $Operations::cnMenu $x $y
    } elseif { [string match "Network-*" $node] == 1 } {
            tk_popup $Operations::networkMenu $x $y
    } else {
        return
    }
}

#-------------------------------------------------------------------------------
#  Operations::DisplayConsole
#
#  Arguments: option - User selected preference
#
#  Results: -
#
#  Description: Displays or hides console window according to selected option
#-------------------------------------------------------------------------------
proc Operations::DisplayConsole {option} {
    variable infotabs_notebook

    set window [winfo parent $infotabs_notebook]
    set window [winfo parent $window]
    set pannedWindow [winfo parent $window]
    update idletasks
    if {$option} {
        grid configure $pannedWindow.f0 -rowspan 1
        grid $pannedWindow.sash1
        grid $window
        grid rowconfigure $pannedWindow 2 -minsize 100
    } else  {
        grid remove $window
        grid remove $pannedWindow.sash1
        grid configure $pannedWindow.f0 -rowspan 3
    }
}

#-------------------------------------------------------------------------------
#  Operations::DisplayTreeWin
#
#  Arguments: option - User selected preference
#
#  Results: -
#
#  Description: Displays or hides the tree window according to selected option
#-------------------------------------------------------------------------------
proc Operations::DisplayTreeWin {option} {
    variable tree_notebook

    set window [winfo parent $tree_notebook]
    set window [winfo parent $window]
    set pannedWindow [winfo parent $window]
    update idletasks
    if {$option} {
        grid configure $pannedWindow.f1 -column 2 -columnspan 1
        grid $pannedWindow.sash1
        grid $window
        grid columnconfigure $pannedWindow 0 -minsize 250
        #enable the view menu
        $Operations::mainframe setmenustate tag_SimpleView normal
        $Operations::mainframe setmenustate tag_AdvancedView normal
    } else  {
        grid remove $window
        grid remove $pannedWindow.sash1
        grid configure $pannedWindow.f1 -column 0 -columnspan 3
        grid configure $pannedWindow.f0 -rowspan 3
        #disable the view menu
        $Operations::mainframe setmenustate tag_SimpleView disable
        $Operations::mainframe setmenustate tag_AdvancedView disable
    }
}

#-------------------------------------------------------------------------------
#  Operations::exit_app
#
#  Arguments: -
#
#  Results: -
#
#  Description: Prompts to save project when application is exited
#-------------------------------------------------------------------------------
proc Operations::exit_app {} {
    variable notebook
    variable index

    global rootDir
    global projectDir
    global projectName
    global status_save

    if { $projectDir != ""} {
    #check whether project has changed
    if {$status_save} {
        #Prompt for Saving the Existing Project
        set result [tk_messageBox -message "Save Project $projectName?" -type yesnocancel -icon question -title "Question" -parent .]
        switch -- $result {
            yes {
                Operations::Saveproject
                Console::DisplayInfo "Project $projectName is saved" info
            }
            no  {
                Console::DisplayInfo "Project $projectName not saved" info
                if { ![file exists [file join $projectDir $projectName].xml] } {
                    catch { file delete -force -- $projectDir }
                }
            }
            cancel {
                Console::DisplayInfo "Exit Cancelled" info
                return
            }
        }
    }
        Operations::CloseProject
    }
    thread::send [tsv::get application importProgress] "exit_thread"
    exit
}

#-------------------------------------------------------------------------------
#  Operations::OpenProjectWindow
#
#  Arguments: -
#
#  Results: -
#
#  Description : Prompts to save the current project gets an already existing project
#-------------------------------------------------------------------------------
proc Operations::OpenProjectWindow { } {
    global projectDir
    global projectName
    global status_save
    global lastOpenPjt
    global defaultProjectDir
    global resourcesDir

# TODO Check for the availability of the dependent files.
    if { $projectDir != "" && $projectName != "" } {
        #check whether project has changed
        if {$status_save} {
            #Prompt for Saving the Existing Project
            set result [tk_messageBox -message "Save Project $projectName?" -type yesnocancel -icon question -title "Question" -parent .]
            switch -- $result {
                 yes {
                    Console::DisplayInfo "Project $projectName saved" info
                    Operations::Saveproject
                }
                 no  {
                    Console::DisplayInfo "Project $projectName not saved" info
                    if { ![file exists [file join $projectDir $projectName].xml ] } {
                        catch { file delete -force -- $projectDir }
                    }
                }
                 cancel {
                    Console::DisplayInfo "Open Project cancelled" info
                    return
                }
            }
        }
    }

    set types {
        {"openCONFIGURATOR Project Files"     {*.xml *.oct} }
        {"New Project Files"     {*.xml} }
        {"Old Project Files"     {*.oct } }
        {"All Files"     {*} }
    }

    if { ![file isdirectory $lastOpenPjt] && [file exists $lastOpenPjt] } {
        set lastOpenFile [file tail $lastOpenPjt]
        set lastOpenDir [file dirname $lastOpenPjt]
        set projectfilename [tk_getOpenFile -title "Open Project" -initialdir $lastOpenDir -initialfile $lastOpenFile -filetypes $types -parent .]
    } else {
        set projectfilename [tk_getOpenFile -title "Open Project" -initialdir $defaultProjectDir -filetypes $types -parent .]
    }

    # Validate filename
    if { $projectfilename == "" } {
            return
    }

    set tempPjtName [file tail $projectfilename]
    set ext [file extension $projectfilename]
    if { ![string compare $ext ".xml"] && ![string compare $ext ".oct"]} {
        set projectDir ""
        tk_messageBox -message "Extension $ext not supported" -title "Open Project Error" -icon error -parent .
        return
    }


    if {[string compare $ext ".oct"] == 0 } {
        ProjectUpgradeWindow::InitConversion $projectfilename
    } else {
        #save the path of opened project
        set lastOpenPjt $projectfilename

        Operations::openProject $projectfilename
    }
}

#-------------------------------------------------------------------------------
#  Operations::openProject
#
#  Arguments: projectfilename - Path of project to be opened
#
#  Results: -
#
#  Description: Opens the project and populates the GUI
#-------------------------------------------------------------------------------
proc Operations::openProject {projectfilename} {
    global projectDir
    global projectName
    global st_save
    global st_autogen
    global lastVideoModeSel
    global st_viewType

    #Operations::CloseProject is called to delete node and insert tree
    Operations::CloseProject

    set tempPjtDir [file dirname $projectfilename]
    set tempPjtName [file tail $projectfilename]

    thread::send [tsv::get application importProgress] "StartProgress"
    set result [openConfLib::OpenProject $projectfilename]
    openConfLib::ShowErrorMessage $result
    if { [Result_IsSuccessful $result] != 1 } {
        thread::send  [tsv::set application importProgress] "StopProgress"
        return 0
    }

    set projectDir $tempPjtDir
    set projectName [string range $tempPjtName 0 end-[string length [file extension $tempPjtName]]]

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

    set result [openConfLib::GetActiveView]
    openConfLib::ShowErrorMessage [lindex $result 0]
    set st_viewType [lindex $result 1]
    # puts "st_viewType:$st_viewType"
    if {$st_viewType} {
        set Operations::viewType "EXPERT"
    } else {
        set Operations::viewType "SIMPLE"
    }
# TODO if errror set st_viewtype to 0

    set result [ Operations::RePopulate $projectDir $projectName ]

    thread::send [tsv::set application importProgress] "StopProgress"

    if { $result == 1 } {
        Console::DisplayInfo "Project $projectName at $projectDir is successfully opened"
    } else {
        Console::DisplayErrMsg "Error in opening project $tempPjtName at $tempPjtDir"
    }

    return 1
}

#-------------------------------------------------------------------------------
#  Operations::RePopulate
#
#  Arguments: projectDir  - Path of the project
#             projectName - Name of the project
#
#  Results: -
#
#  Description: Rebuilds the tree with updated values for all nodes
#-------------------------------------------------------------------------------
proc Operations::RePopulate { projectDir projectName } {
    global treePath
    global nodeIdList
    global mnCount
    global cnCount
    global image_dir

    #reset the nodeIdList
    set nodeIdList ""

    set mnCount 1
    set cnCount 1

    catch {$treePath delete ProjectNode}

    image create photo img_network -file "$image_dir/network.gif"
    image create photo img_mn -file "$image_dir/mn.gif"
    image create photo img_pdo -file "$image_dir/pdo.gif"
    image create photo img_cn -file "$image_dir/cn.gif"

    $treePath insert end root ProjectNode -text $projectName -open 1 -image img_network
    $treePath insert end ProjectNode Network-1 -text "POWERLINK" -open 1 -image img_mn

    set result [openConfLib::GetNodes]
    openConfLib::ShowErrorMessage [lindex $result 0]
    if { [Result_IsSuccessful [lindex $result 0]] } {
        foreach node [lindex $result 2] {
            set l_NodeId $node
            # 0 for nodename
            set aResult [openConfLib::GetNodeParameter $l_NodeId $::NAME]
    # TODO handle result and report error message.
            set l_NodeName [lindex $aResult 1]

            if {$l_NodeId == 240} {
                set treeNode MN-$mnCount
                $treePath insert end Network-1 $treeNode -text "$l_NodeName\($l_NodeId\)" -open 1 -image img_mn
            #insert the OBD icon only if the view is in EXPERT mode
                #if {[string match "EXPERT" $Operations::viewType ] == 1} {
                #    $treePath insert end MN-$mnCount $treeNode -text "OBD" -open 0 -image img_pdo
                #}
            } elseif {$l_NodeId > 0} {
                set treeNode CN-$mnCount-$cnCount
                set child [$treePath insert end Network-1 $treeNode -text "$l_NodeName\($l_NodeId\)" -open 0 -image img_cn]
            } else {
                continue
            }
            if { [ catch { set result [WrapperInteractions::Import $treeNode $l_NodeId] } errormessage ] } {
                # error has occured
                Console::DisplayErrMsg "$l_NodeId.$l_NodeName Internal error occurred\n Err: $errormessage" error
                Operations::CloseProject
                return 0
            }
            if { $result == "fail" } {
                return 0
            }
            incr cnCount
            lappend nodeIdList $l_NodeId
        }

        if { [$Operations::projMenu index 2] != "2" } {
            $Operations::projMenu insert 2 command -label "Close Project" -command "Operations::InitiateCloseProject"
        }
        if { [$Operations::projMenu index 3] != "3" } {
            $Operations::projMenu insert 3 command -label "Properties..." -command "ChildWindows::PropertiesWindow"
        }
    }

    return 1
}

#-------------------------------------------------------------------------------
#  Operations::BasicFrames
#
#  Arguments: -
#
#  Results: -
#
#  Description: Creates the GUI for application when launched
#-------------------------------------------------------------------------------
proc Operations::BasicFrames { } {
    global tcl_platform
    global rootDir
    global f0
    global f1
    global f2
    global f3
    global f4
    global f5
    global LastTableFocus
    global lastVideoModeSel
    global image_dir
    global imagesDir

    variable notebook
    variable tree_notebook
    variable infotabs_notebook
    variable pannedwindow2
    variable pannedwindow1
    variable treeWindow
    variable mainframe
    variable progressmsg
    variable prgressindicator
    variable options
    variable Button
    variable cnMenu
    variable mnMenu
    variable networkMenu

    set image_dir "$rootDir/images"

    set progressmsg "Please wait while loading ..."
    set prgressindicator -1
    set ImageKalycito $imagesDir/Splash

    set prgressindicator 2
    Operations::_tool_intro $ImageKalycito
    update
    Operations::Sleep 1000
    # Menu description
    set descmenu {
    "&File" {} {} 0 {
            {command "New &Project..." {} "New Project" {Ctrl n}  -command { Operations::InitiateNewProject } }
            {command "&Open Project..." {}  "Open Project" {Ctrl o} -command { Operations::OpenProjectWindow } }
            {command "&Save Project" {noFile}  "Save Project" {Ctrl s} -command Operations::Saveproject}
            {command "Save Project As..." {noFile}  "Save Project As..." {} -command ChildWindows::SaveProjectAsWindow }
            {command "&Close Project" {}  "Close Project" {} -command Operations::InitiateCloseProject }
            {separator}
            {command "E&xit" {}  "Exit openCONFIGURATOR" {Alt x} -command Operations::exit_app}
        }
        "&Project" {} {} 0 {
            {command "&Build Project    F7" {noFile} "Generate CDC and XAP" {} -command Operations::BuildProject }
            {command "&Clean Project" {noFile} "Clean" {} -command Operations::CleanProject }
            {separator}
            {command "Project &Settings..." {}  "Project Settings" {} -command ChildWindows::ProjectSettingWindow }
        }
        "&View" all options 0 {
            {radiobutton "Simple View" {tag_SimpleView} "Simple View Mode" {}
                -variable Operations::viewType -value "SIMPLE"
                -command {
                    Operations::ViewModeChanged
                }
            }
            {radiobutton "Advanced View" {tag_AdvancedView} "Advanced View Mode" {}
                -variable Operations::viewType -value "EXPERT"
                -command {
                    Operations::ViewModeChanged
                }
            }
        {separator}
            {checkbutton "Show Output Console" {tag_OutputConsole} "Show Console Window" {}
                -variable Operations::options(DisplayConsole)
                -command  {
                    Operations::DisplayConsole $Operations::options(DisplayConsole)
                    update idletasks
                }
            }
            {checkbutton "Show Network Browser" {tag_NetworkBrowser} "Show Code Browser" {}
                -variable Operations::options(showTree)
                -command  {
                    Operations::DisplayTreeWin $Operations::options(showTree)
                    update idletasks
                }
            }
        }
        "&Help" {} {} 0 {
       {command "&Getting Started" {noFile} "Quick start guide" {} -command "Operations::OpenDocument 2 QuickStartGuide.pdf" }
       {command "User &Manual       F1" {noFile} "User manual    F1" {} -command "Operations::OpenDocument 2 UserManual.pdf" }
       {command "&Release Note" {noFile} "Release note" {} -command "Operations::openFILE 1 Readme.txt" }
       {separator}
       {command "&Online Support" {noFile} "Online Support" {} -command "Operations::LocateUrl http://sourceforge.net/p/openconf/discussion/" }
       {separator}
       {command "&About" {} "About" {F1} -command Operations::about }
        }
    }

    # to select the required check button in View menu
    set Operations::options(showTree) 1
    set Operations::options(DisplayConsole) 1
    set Operations::viewType "SIMPLE"
    set lastVideoModeSel 0
    #shortcut keys for project
    bind . <Key-F7> "Operations::BuildProject"
    # short cut key for help
    bind . <Key-F1> "Operations::OpenDocument 2 UserManual.pdf"
     #to prevent BuildProject called
    bind . <Control-Key-F7> ""
    bind . <Control-Key-f> { FindSpace::FindDynWindow }
    bind . <Control-Key-F> { FindSpace::FindDynWindow }
    bind . <KeyPress-Escape> { FindSpace::EscapeTree }

    # Menu for the Controlled Nodes
    set Operations::cnMenu [menu  .cnMenu -tearoff 0]
    $Operations::cnMenu add command -label "Replace with XDC/XDD..." -command {Operations::ReImport}
    $Operations::cnMenu add separator
    $Operations::cnMenu add command -label "Delete Node" -command {Operations::DeleteTreeNode}

    set Operations::networkMenu [menu .networkMenu -tearoff 0]
    $Operations::networkMenu add command -label "Add CN..." -command "ChildWindows::AddCNWindow"

    # Menu for the Managing Nodes
    set Operations::mnMenu [menu  .mnMenu -tearoff 0]
    $Operations::mnMenu add command -label "Replace with XDC/XDD..." -command "Operations::ReImport"
    #$Operations::mnMenu add separator
    #$Operations::mnMenu add command -label "Auto Generate" -command {Operations::AutoGenerateMNOBD}

    # Menu for the Project
    set Operations::projMenu [menu  .projMenu -tearoff 0]
    $Operations::projMenu insert 0 command -label "New Project..." -command { Operations::InitiateNewProject}
    $Operations::projMenu insert 1 command -label "Open Project..." -command {Operations::OpenProjectWindow}

    set Operations::prgressindicator 6
    set mainframe [MainFrame::create .mainframe -menu $descmenu  ]

    # toolbar  creation
    set toolbar  [MainFrame::addtoolbar $mainframe]
    pack $toolbar -expand yes -fill x

    image create photo img_page_white -file "$image_dir/page_white.gif"
    image create photo img_disk -file "$image_dir/disk.gif"
    image create photo img_disk_multiple -file "$image_dir/disk_multiple.gif"
    image create photo img_openfolder -file "$image_dir/folder.gif"
    image create photo img_find -file "$image_dir/find.gif"
    image create photo img_build -file "$image_dir/build.gif"
    image create photo img_clean -file "$image_dir/clean.gif"
    image create photo img_kalycito_icon -file "$image_dir/kalycito_icon.gif"

    set bbox [ButtonBox::create $toolbar.bbox1 -spacing 0 -padx 1 -pady 1]
    set Buttons(new) [ButtonBox::add $bbox -image img_page_white \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Create New Project" -command { Operations::InitiateNewProject }]
    set Buttons(save) [ButtonBox::add $bbox -image img_disk \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Save Project" -command Operations::Saveproject]
    set Buttons(saveAll) [ButtonBox::add $bbox -image img_disk_multiple \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Save Project As" -command ChildWindows::SaveProjectAsWindow]
    pack $bbox -side left -anchor w

    set sep0 [Separator::create $toolbar.sep0 -orient vertical]
    pack $sep0 -side left -fill y -padx 4 -anchor w

    set bbox [ButtonBox::create $toolbar.bbox11 -spacing 0 -padx 1 -pady 1]
    set toolbarButtons(Operations::OpenProjectWindow) [ButtonBox::add $bbox -image img_openfolder \
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Open Project" -command Operations::OpenProjectWindow]
    pack $bbox -side left -anchor w

    set prgressindicator 8
    set sep1 [Separator::create $toolbar.sep1 -orient vertical]
    pack $sep1 -side left -fill y -padx 4 -anchor w

    set bbox [ButtonBox::create $toolbar.bbox2 -spacing 1 -padx 1 -pady 1]
    pack $bbox -side left -anchor w
    set bb_find [ButtonBox::add $bbox -image img_find \
            -height 21\
            -width 21\
            -helptype balloon\
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Search In Network Browser"\
            -command "FindSpace::ToggleFindWin"]
    pack $bb_find -side left -padx 4
    set sep4 [Separator::create $toolbar.sep4 -orient vertical]
    pack $sep4 -side left -fill y -padx 4 -anchor w

    set bbox [ButtonBox::create $toolbar.bbox5 -spacing 6 -padx 1 -pady 1]
    set bb_build [ButtonBox::add $bbox -image img_build \
            -height 21\
            -width 21\
            -helptype balloon\
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Build Project"\
            -command "Operations::BuildProject"]

    set bb_clean [ButtonBox::add $bbox -image img_clean \
            -height 21\
            -width 21\
            -helptype balloon\
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Clean Project"\
            -command "Operations::CleanProject"]
    pack $bbox -side left -anchor w
    set sep2 [Separator::create $toolbar.sep2 -orient vertical]
    pack $sep2 -side left -fill y -padx 4 -anchor w

    set bbox [ButtonBox::create $toolbar.bbox7 -spacing 1 -padx 1 -pady 1]
    pack $bbox -side right
    set bb_kaly [ButtonBox::add $bbox -image img_kalycito_icon \
            -height 21\
            -width 40\
            -helptype balloon\
            -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
            -helptext "Kalycito Infotech Pvt Ltd" \
            -command Operations::about ]
    pack $bb_kaly -side right  -padx 4

    $Operations::mainframe showtoolbar 0 $Operations::showtoolbar
    set temp [MainFrame::addindicator $mainframe -textvariable Operations::connect_status ]
    $temp configure -relief flat

    # NoteBook creation
    set framePath [$mainframe getframe]
    set pannedwindow1 [PanedWindow::create $framePath.pannedwindow1 -side left]
    set pane [PanedWindow::add $pannedwindow1 ]
    set pannedwindow2 [PanedWindow::create $pane.pannedwindow2 -side top]
    set pane1 [PanedWindow::add $pannedwindow2 -minsize 250]
    set pane2 [PanedWindow::add $pannedwindow2 -minsize 100]
    set pane3 [PanedWindow::add $pannedwindow1 -minsize 100]

    set tree_notebook [NoteBook::create $pane1.nb]
    set notebook [NoteBook::create $pane2.nb]
    set infotabs_notebook [NoteBook::create $pane3.nb]

    set pf1 [NoteBookManager::create_treeBrowserWindow $tree_notebook]
    set treeWindow [lindex $pf1 1]
    # Binding on tree widget
    $treeWindow bindText <ButtonPress-1> Operations::SingleClickNode
    $treeWindow bindText <Double-1> Operations::DoubleClickNode
    $treeWindow bindText <ButtonPress-3> {Operations::tselectright %X %Y}
    if {"$tcl_platform(platform)" == "unix"} {
        bind $treeWindow <Button-4> {
            global treePath
            $treePath yview scroll -5 units
        }
        bind $treeWindow <Button-5> {
            global treePath
            $treePath yview scroll 5 units
        }
    }
    bind $treeWindow <Enter> { Operations::BindTree }
    bind $treeWindow <Leave> { Operations::UnbindTree }

    set cf0 [NoteBookManager::create_infoWindow $infotabs_notebook "Info" 1]
    set cf1 [NoteBookManager::create_infoWindow $infotabs_notebook "Error" 2]
    set cf2 [NoteBookManager::create_infoWindow $infotabs_notebook "Warning" 3]

    NoteBook::compute_size $infotabs_notebook
    $infotabs_notebook configure -height 80
    pack $infotabs_notebook -side bottom -fill both -expand yes -padx 4 -pady 4

    pack $pannedwindow1 -fill both -expand yes
    NoteBook::compute_size $tree_notebook
    $tree_notebook configure -width 350
    $tree_notebook configure -height 390
    pack $tree_notebook -side left -fill both -expand yes -padx 2 -pady 4
    catch {font create TkFixedFont -family Courier -size -12 -weight bold}

    set alignFrame [frame $pane2.alignframe -width 750]
    pack $alignFrame -expand yes -fill both

    set f0 [NoteBookManager::create_tab $alignFrame index ]
    bind [lindex $f0 0] <Enter> {
        bind . <KeyPress-Return> {
            global indexSaveBtn
            $indexSaveBtn invoke
        }
    }
    bind [lindex $f0 0] <Leave> {
        bind . <KeyPress-Return> ""
    }
    bind [lindex $f0 3] <Enter> {
        global f0
        if {"$tcl_platform(platform)" == "unix"} {
        bind . <Button-4> "[lindex $f0 3] yview scroll -5 units"
            bind . <Button-5> "[lindex $f0 3] yview scroll 5 units"
        } elseif {"$tcl_platform(platform)" == "windows"} {
            #bind . <MouseWheel> "[lindex $f0 3] yview scroll [expr -%D/24] units"
        }
    }
    bind [lindex $f0 3] <Leave> {
        if {"$tcl_platform(platform)" == "unix"} {
        bind . <Button-4> ""
            bind . <Button-5> ""
        } elseif {"$tcl_platform(platform)" == "windows"} {
            bind . <MouseWheel> ""
        }
    }

    set f1 [NoteBookManager::create_tab $alignFrame subindex ]
    bind [lindex $f1 0] <Enter> {
        bind . <KeyPress-Return> {
            global subindexSaveBtn
        $subindexSaveBtn invoke
        }
    }
    bind [lindex $f1 0] <Leave> {
        bind . <KeyPress-Return> ""
    }
    bind [lindex $f1 3] <Enter> {
    global f1
        if {"$tcl_platform(platform)" == "unix"} {
        bind . <Button-4> "[lindex $f1 3] yview scroll -5 units"
            bind . <Button-5> "[lindex $f1 3] yview scroll 5 units"
        } elseif {"$tcl_platform(platform)" == "windows"} {
            #bind . <MouseWheel> "[lindex $f1 3] yview scroll [expr -%D/24] units"
        }
    }
    bind [lindex $f1 3] <Leave> {
        if {"$tcl_platform(platform)" == "unix"} {
        bind . <Button-4> ""
            bind . <Button-5> ""
        } elseif {"$tcl_platform(platform)" == "windows"} {
             bind . <MouseWheel> ""
        }
    }

    set f2 [NoteBookManager::create_table $alignFrame  "pdo"]
    [lindex $f2 1] columnconfigure 0 -background #e0e8f0 -width 6 -sortmode integer
    [lindex $f2 1] columnconfigure 1 -background #e0e8f0 -width 11
    [lindex $f2 1] columnconfigure 2 -background #e0e8f0 -width 11
    [lindex $f2 1] columnconfigure 3 -background #e0e8f0 -width 11
    [lindex $f2 1] columnconfigure 4 -background #e0e8f0 -width 11

    #binding for tablelist widget
    bind [lindex $f2 0] <Enter> {
    #puts "f2 0 Enter"
        bind . <KeyPress-Return> {
                global tableSaveBtn
                $tableSaveBtn invoke
        }
    }
    bind [lindex $f2 0] <Leave> {
    #puts "f2 0 Leave"
        bind . <KeyPress-Return> ""
    }
    bind [lindex $f2 1] <Enter> {
    #puts "f2 1 Enter"
        global LastTableFocus
        if { [ winfo exists $LastTableFocus ] && [ string match "[lindex $f2 1]*" $LastTableFocus ] } {
            focus $LastTableFocus
        } else {
            focus [lindex $f2 1]
        }

        bind . <Motion> {
            global LastTableFocus
            set LastTableFocus [focus]
        }
    }
    bind [lindex $f2 1] <Leave> {
        bind . <Motion> {}
        global LastTableFocus
        global treeFrame
        if { "$LastTableFocus" == "$treeFrame.en_find" } {
                focus $treeFrame.en_find
        } else {
                focus .
        }
    }
    bind [lindex $f2 1] <FocusOut> {
        bind . <Motion> {}
        global LastTableFocus
        set LastTableFocus [focus]
    }

    set f3 [NoteBookManager::create_nodeFrame $alignFrame  "mn"]
    bind [lindex $f3 0] <Enter> {
        bind . <KeyPress-Return> {
            global mnPropSaveBtn
            $mnPropSaveBtn invoke
        }
    }
    bind [lindex $f3 0] <Leave> {
        bind . <KeyPress-Return> ""
    }
    bind [lindex $f3 3] <Enter> {
    global f3
        if {"$tcl_platform(platform)" == "unix"} {
        bind . <Button-4> "[lindex $f3 3] yview scroll -5 units"
            bind . <Button-5> "[lindex $f3 3] yview scroll 5 units"
        } elseif {"$tcl_platform(platform)" == "windows"} {
            #bind . <MouseWheel> "[lindex $f3 3] yview scroll [expr -%D/24] units"
        }
    }
    bind [lindex $f3 3] <Leave> {
        if {"$tcl_platform(platform)" == "unix"} {
        bind . <Button-4> ""
            bind . <Button-5> ""
        } elseif {"$tcl_platform(platform)" == "windows"} {
            bind . <MouseWheel> ""
        }
    }
    set f4 [NoteBookManager::create_nodeFrame $alignFrame  "cn"]
    bind [lindex $f4 0] <Enter> {
        bind . <KeyPress-Return> {
            global cnPropSaveBtn
            $cnPropSaveBtn invoke
        }
    }
    bind [lindex $f4 0] <Leave> {
        bind . <KeyPress-Return> ""
    }
    bind [lindex $f4 3] <Enter> {
    global f4
        if {"$tcl_platform(platform)" == "unix"} {
        bind . <Button-4> "[lindex $f4 3] yview scroll -5 units"
            bind . <Button-5> "[lindex $f4 3] yview scroll 5 units"
        } elseif {"$tcl_platform(platform)" == "windows"} {
            #bind . <MouseWheel> "[lindex $f4 3] yview scroll [expr -%D/24] units"
        }
    }
    bind [lindex $f4 3] <Leave> {
        if {"$tcl_platform(platform)" == "unix"} {
        bind . <Button-4> ""
            bind . <Button-5> ""
        } elseif {"$tcl_platform(platform)" == "windows"} {
            bind . <MouseWheel> ""
        }
    }

    #######Combobox implementation########
    set f5 [NoteBookManager::create_table $alignFrame  "AUTOpdo"]
    [lindex $f5 1] columnconfigure 0 -background #e0e8f0 -width 6 -sortmode integer
    [lindex $f5 1] columnconfigure 1 -background #e0e8f0 -width 11
    [lindex $f5 1] columnconfigure 2 -background #e0e8f0 -width 11
    [lindex $f5 1] columnconfigure 3 -background #e0e8f0 -width 11
    [lindex $f5 1] columnconfigure 4 -background #e0e8f0 -width 11 -foreground #606060

    #binding for tablelist widget
    bind [lindex $f5 0] <Enter> {
    focus -force [lindex $f5 0]
    #puts "Key 0 press enter"
        bind . <KeyPress-Return> {
                global tableSaveBtn
                $tableSaveBtn invoke
        }
    set temppath "[lindex $f5 1]"
    bind . <KeyPress-Escape> {
        #puts "keypress 0 escape enter"
        set result [$temppath finishediting]
        #puts "result:$result"
    }
    bind . <Double-1> {
    #puts "Double clicking tablelist f50"
    }
    }
    bind [lindex $f5 0] <Leave> {
    #puts "keypress 0 leave"
        bind . <KeyPress-Return> ""
    bind . <Double-1> ""
    bind . <Motion> {}
    focus $LastTableFocus
    }
    bind [lindex $f5 1] <Enter> {
    #puts "keypress 1 Enter"
    focus -force [lindex $f5 1]
        bind . <KeyPress-Escape> {
        #puts "keypress 0 escape enter"
        set result [[lindex $f5 1] finishediting]
        #puts "result:$result"
        }
    }
    bind [lindex $f5 1] <Leave> {
    #puts "keypress 1 Leave"
      focus -force [lindex $f5 0]
      bind . <KeyPress-Escape>
    }
    bind [lindex $f5 1] <FocusOut> {
    #puts "keypress 1 FocusOut"
    }
    bind [lindex $f5 1] <Double-1> {
    #puts "Double clicking tablelist f51"
    }

    bind [lindex $f5 1] <KeyPress-Escape> {
    #puts "KEypress esc"
    }

    ##########Combobox implementation#############
    pack $pannedwindow2 -fill both -expand yes

    $tree_notebook raise objectTree
    $infotabs_notebook raise Console1
    pack $mainframe -fill both -expand yes
    set prgressindicator 10
    Operations::Sleep 100
    destroy .intro
    set prgressindicator 0
    wm protocol . WM_DELETE_WINDOW Operations::exit_app
    update idletasks
    FindSpace::EscapeTree
    Operations::ResetGlobalData
    return 1
}

#-------------------------------------------------------------------------------
#  Operations::_tool_intro
#
#  Arguments: -
#
#  Results: -
#
#  Description: Displays image during launch of application
#-------------------------------------------------------------------------------
proc Operations::_tool_intro {ImageName} {
    global rootDir

    set top [toplevel .intro -relief raised -borderwidth 0]
    wm withdraw $top
    wm overrideredirect $top 1

    set image [image create photo -file [file join $rootDir $ImageName.gif] ]

    set splashscreen  [label $top.x -image $image]
    set framePath [frame $splashscreen.f ]
    set prg   [ProgressBar $framePath.prg -width 300 -height 7 -foreground aquamarine2 -background  yellow \
        -variable Operations::prgressindicator -maximum 10]
    pack $prg
    place $framePath -x 80 -y 170 -anchor nw
    pack $splashscreen
    BWidget::place $top 0 0 center
    wm deiconify $top
    update
    update idletasks
    after 100
}

#-------------------------------------------------------------------------------
#  Operations::BindTree
#
#  Arguments: -
#
#  Results: -
#
#  Description: Binds various functions to tree widget
#-------------------------------------------------------------------------------
proc Operations::BindTree {} {
    global treePath
    global tcl_platform

    bind . <Delete> Operations::DeleteTreeNode
    bind . <Up> Operations::ArrowUp
    bind . <Down> Operations::ArrowDown
    bind . <Left> Operations::ArrowLeft
    bind . <Right> Operations::ArrowRight
    bind . <KeyPress-Return> {
        global treePath
        set node [$treePath selection get]
        Operations::SingleClickNode $node
    }
    if {"$tcl_platform(platform)" == "windows"} {
        bind . <MouseWheel> {global treePath; $treePath yview scroll [expr -%D/24] units }
    }
    $treePath configure -selectbackground #678db2
}

#-------------------------------------------------------------------------------
#  Operations::UnbindTree
#
#  Arguments: -
#
#  Results: -
#
#  Description: Unbinds various functions bound to tree widget
#-------------------------------------------------------------------------------
proc Operations::UnbindTree {} {
    global tcl_platform
    global treePath

    bind . <Delete> ""
    bind . <Up> ""
    bind . <Down> ""
    bind . <Left> ""
    bind . <Right> ""
    bind . <KeyPress-Return> ""
    if {"$tcl_platform(platform)" == "windows"} {
        bind . <MouseWheel> ""
    }
    $treePath configure -selectbackground gray
}

#-------------------------------------------------------------------------------
#  Operations::SingleClickNode
#
#  Arguments: node - Selected node from tree widget
#
#  Results: -
#
#  Description: Displays required properties when corresponding nodes are clicked
#-------------------------------------------------------------------------------
proc Operations::SingleClickNode {node} {
    variable notebook

    global treePath
    global nodeIdList
    global f0
    global f1
    global f2
    global f3
    global f4
    global f5
    global nodeSelect
    global savedValueList
    global lastConv
    global populatedPDOList
    global populatedCommParamList
    global userPrefList
    global LastTableFocus
    global chkPrompt
    global st_save
    global st_autogen
    global indexSaveBtn
    global subindexSaveBtn
    global tableSaveBtn
    global mnPropSaveBtn
    global cnPropSaveBtn
    global LOWER_LIMIT
    global UPPER_LIMIT

    if { $nodeSelect == "" || ![$treePath exists $nodeSelect] || [string match "root" $nodeSelect] || [string match "ProjectNode" $nodeSelect] || [string match "OBD-*" $nodeSelect] || [string match "?PDO-*" $nodeSelect] } {
        #should not check for project settings option
    } else {
        if { $st_save == "0"} {
            if { $chkPrompt == 1 } {
                if { [string match "TPDONode-*" $nodeSelect] || [string match "RPDONode-*" $nodeSelect] } {
                    $tableSaveBtn invoke
                } elseif { [string match "*SubIndex*" $nodeSelect] } {
                    $subindexSaveBtn invoke
                } elseif { [string match "*Index*" $nodeSelect] } {
                    $indexSaveBtn invoke
                } elseif { [string match "MN*" $nodeSelect] } {
                    $mnPropSaveBtn invoke
                } elseif { [string match "CN*" $nodeSelect] } {
                    $cnPropSaveBtn invoke
                } else {
                    #must be root, ProjectNode, MN, OBD or CN
                }
            }
            Validation::ResetPromptFlag
        } elseif { $st_save == "1" } {
            if { $chkPrompt == 1 } {
                set result [tk_messageBox -message "Do you want to save?" -parent . -type yesno -icon question]
                switch -- $result {
                    yes {
                        #save the value
                        if { [string match "TPDONode-*" $nodeSelect] || [string match "RPDONode-*" $nodeSelect] } {
                            $tableSaveBtn invoke
                        } elseif { [string match "*SubIndex*" $nodeSelect] } {
                            $subindexSaveBtn invoke
                        } elseif { [string match "*Index*" $nodeSelect] } {
                            $indexSaveBtn invoke
                        } elseif { [string match "MN*" $nodeSelect] } {
                            $mnPropSaveBtn invoke
                        } elseif { [string match "CN*" $nodeSelect] } {
                            $cnPropSaveBtn invoke
                        } else {
                            #must be root, ProjectNode, MN, OBD or CN
                        }
                    }
                    no  {#continue}
                }
            }
            Validation::ResetPromptFlag
        } elseif { $st_save == "2" } {
            puts "Any changes made are discarded"
        } else {
            Validation::ResetPromptFlag
            return
        }
    }
    Validation::ResetPromptFlag
    $indexSaveBtn configure -state normal
    $subindexSaveBtn configure -state normal

    $treePath selection set $node
    set nodeSelect $node

    if {[string match "root" $node] || [string match "ProjectNode" $node] || [string match "OBD-*" $node] || [string match "?PDO-*" $node] || [string match "Mapping*" $node]} {
        Operations::RemoveAllFrames
        return
    }

    #getting Id and Type of node
    set result [Operations::GetNodeIdType $node]
    if {$result == -1} {
        #the node is not an index, subindex, TPDO or RPDO do nothing
        Operations::RemoveAllFrames
        return
    } else {
        # it is index or subindex
        set nodeId $result
    }

    set result [openConfLib::IsExistingNode $nodeId]
    openConfLib::ShowErrorMessage [lindex $result 0]
    if { [lindex $result 1] == 0 && [Result_IsSuccessful [lindex $result 0]] != 1 } {
        Operations::RemoveAllFrames
        return
    }

    if {[string match "MN-*" $node]} {
        pack forget [lindex $f0 0]
        pack forget [lindex $f1 0]
        pack forget [lindex $f2 0]
        [lindex $f2 1] cancelediting
        [lindex $f2 1] configure -state disabled
        pack forget [lindex $f5 0]
        [lindex $f5 1] cancelediting
        [lindex $f5 1] configure -state disabled
        pack [lindex $f3 0] -expand yes -fill both -padx 2 -pady 4
        pack forget [lindex $f4 0]

        Operations::MNProperties $node $nodeId
        return
    } elseif {[string match "CN-*" $node]} {
        pack forget [lindex $f0 0]
        pack forget [lindex $f1 0]
        pack forget [lindex $f2 0]
        [lindex $f2 1] cancelediting
        [lindex $f2 1] configure -state disabled
        pack forget [lindex $f5 0]
        [lindex $f5 1] cancelediting
        [lindex $f5 1] configure -state disabled
        pack forget [lindex $f3 0]
        pack [lindex $f4 0] -expand yes -fill both -padx 2 -pady 4

        Operations::CNProperties $node $nodeId
        return
    }

    if {[string match "TPDONode-*" $node] || [string match "RPDONode-*" $node]} {
        #the LastTableFocus is cleared to avoid potential bugs
        set LastTableFocus ""

        if {$st_autogen == 1 } {
            set propertyFrame [lindex $f5 2]
            set tableFrame [lindex $f5 1]
        } else {
            set propertyFrame [lindex $f2 2]
            set tableFrame [lindex $f2 1]
        }

        if {[string match "TPDONode-*" $node] } {
            set commParam "18"
            set mappParam "1A"
            $propertyFrame.la_sendto configure -text "Send to (Node ID)"
        } else {
            #must be RPDO
            set commParam "14"
            set mappParam "16"
            $propertyFrame.la_sendto configure -text "Receive from (Node ID)"
        }
        set commParamList ""
        set mappParamList ""

        set subStr [lindex [split $node -] 2]
        set commParam "$commParam$subStr"
        set mappParam "$mappParam$subStr"

        # puts "node:$node commParam:$commParam mappParam:$mappParam"

        $propertyFrame.en_comparam configure -state disabled
        NoteBookManager::SetEntryValue $propertyFrame.en_comparam 0x$commParam

        $propertyFrame.en_mapparam configure -state disabled
        NoteBookManager::SetEntryValue $propertyFrame.en_mapparam 0x$mappParam

        set result [ openConfLib::GetSubIndexAttribute $nodeId 0x$mappParam 0x00 $::ACTUALVALUE ]
        if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
            $propertyFrame.en_numberofentries configure -state disabled
            NoteBookManager::SetEntryValue $propertyFrame.en_numberofentries 0
        } else {
            if { [string match -nocase "0x*" [lindex $result 1]] } {
                set tempVal [string range [lindex $result 1] 2 end]
                set val [lindex [Validation::InputToDec $tempVal "UNSIGNED8"] 0]
            } else {
                set val [lindex $result 1]
            }
            # puts "en_numberofentries- val:$val"
            NoteBookManager::SetEntryValue $propertyFrame.en_numberofentries $val
        }

        set locNodeIdList [Operations::GetNodelistWithName]
        $propertyFrame.com_sendto configure -values "$locNodeIdList"

        set value  ""
        set result [ openConfLib::GetSubIndexAttribute $nodeId 0x$commParam 0x01 $::ACTUALVALUE ]
        if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
            ## TODO
        } else {
            set tempTargetNodeId [lindex $result 1]
            if { [string match -nocase "0x*" $tempTargetNodeId] } {
                set tempVal [string range $tempTargetNodeId 2 end]
                set tempTargetNodeId [lindex [Validation::InputToDec $tempVal "UNSIGNED8"] 0]
            }
            if { $tempTargetNodeId == 0 } {
                set value "Default\(0\)"
            } else {
                set result [openConfLib::GetNodeParameter $tempTargetNodeId $::NODENAME]
                if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
                    ## TODO Handle err
                    set value "\($tempTargetNodeId\)"
                } else {
                    set value "[lindex $result 1]\($tempTargetNodeId\)"
                }
            }
            set nodeidEditableFlag 1
            NoteBookManager::SetEntryValue $propertyFrame.com_sendto $value
        }

        set result [ openConfLib::GetSubIndexAttribute $nodeId 0x$commParam 0x02 $::ACTUALVALUE ]
        if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
            NoteBookManager::SetEntryValue $propertyFrame.en_mapver 0
            $propertyFrame.en_mapver configure -state disabled
        } else {
            if { [string match -nocase "0x*" [lindex $result 1]] == 1} {
                set val [lindex $result 1]
            } else {
                set val [lindex [Validation::InputToHex [lindex $result 1] "INTEGER8"] 0]
            }
            # puts "en_mapver- val:$val"
            NoteBookManager::SetEntryValue $propertyFrame.en_mapver $val
        }

        if {$st_autogen == 1 } {
            [lindex $f2 1] configure -state disabled
            [lindex $f5 1] configure -state normal
            [lindex $f5 1] delete 0 end
        } else {
            [lindex $f5 1] configure -state disabled
            [lindex $f2 1] configure -state normal
            [lindex $f2 1] delete 0 end
        }

        # Get the number of valid entries
        set noOfValidEntries [NoteBookManager::GetEntryValue $propertyFrame.en_numberofentries]
        # Re set the total bytes
        NoteBookManager::SetEntryValue $propertyFrame.en_totalbytes 0

        set popCount 0
        set result [openConfLib::GetSubIndices $nodeId 0x$mappParam]
        if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
            set subIndexList ""
        } else {
            set subIndexList [lindex $result 2]
        }
        # puts "subIndexList:$subIndexList"
        foreach subIndex $subIndexList {

            if { $subIndex != 0 } {

                # puts "subIndex:$subIndex"
                set result [openConfLib::GetSubIndexAttribute $nodeId 0x$mappParam $subIndex $::ACCESSTYPE]
                if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
                    $tableFrame insert $popCount [list "" "" "" "" "" ""]
                    foreach col [list 1 2 3 4 ] {
                        $tableFrame cellconfigure $popCount,$col -editable no
                    }
                    incr popCount 1
                    continue
                }

                set accessType [lindex $result 1]

                set result [openConfLib::GetSubIndexAttribute $nodeId 0x$mappParam $subIndex $::ACTUALVALUE]
                if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
                    $tableFrame insert $popCount [list "" "" "" "" "" ""]
                    foreach col [list 1 2 3 4 ] {
                        $tableFrame cellconfigure $popCount,$col -editable no
                    }
                    incr popCount 1
                    continue
                }

                set IndexActualValue [lindex $result 1]
                if {[string match -nocase "0x*" $IndexActualValue] } {
                    #remove appended 0x
                    set IndexActualValue [string range $IndexActualValue 2 end]
                } else {
                    # no 0x no need to do anything
                }

                set length [string range $IndexActualValue 0 3]
                set offset [string range $IndexActualValue 4 7]
                set reserved [string range $IndexActualValue 8 9]
                set listSubIndex [string range $IndexActualValue 10 11]
                set listIndex [string range $IndexActualValue 12 15]
                foreach tempPdo [list offset length listIndex listSubIndex] {
                    if {[subst $[subst $tempPdo]] != ""} {
                        set $tempPdo 0x[subst $[subst $tempPdo]]
                    } else {
                        set $tempPdo 0x0
                    }
                }

                if {$st_autogen == 1 } {
                    set result [openConfLib::GetSubIndexAttribute $nodeId $listIndex $listSubIndex $::NAME]
                    if {[Result_IsSuccessful [lindex $result 0]]} {
                        set listSubIndex "[lindex $result 1]\($listSubIndex\)"
                    } else {
                        set listSubIndex "\($listSubIndex\)"
                    }

                    set result [openConfLib::GetIndexAttribute $nodeId $listIndex $::NAME]
                    if {[Result_IsSuccessful [lindex $result 0]]} {
                        set listIndex "[lindex $result 1]\($listIndex\)"
                    } else {
                        set listIndex "\($listIndex\)"
                    }

                    # puts "insert $popCount [list [expr $popCount + 1] $listIndex $listSubIndex $length $offset ]"
                    $tableFrame insert $popCount [list [expr $popCount + 1] $listIndex $listSubIndex $length $offset ]
                } else {
                    $tableFrame insert $popCount [list [expr $popCount + 1] $listIndex $listSubIndex $length $offset ]
                }

                lappend popCountList $popCount

                if { $accessType == "ro" || $accessType == "const" } {
                    foreach col [list 1 2 3 4 ] {
                        $tableFrame cellconfigure $popCount,$col -editable no
                    }
                } else {
                # as a default the first cell is always non editable, adding it to the list only when made editable
                    foreach col [list 1 2 ] {
                        # puts "pblm. $popCount,$col"
                        $tableFrame cellconfigure $popCount,$col -editable yes
                    }
                    if { $nodeidEditableFlag == 1} {
                        $tableFrame cellconfigure $popCount,1 -editable yes
                    }
                }
                incr popCount 1

                if {$noOfValidEntries == $popCount} {
                    NoteBookManager::SetEntryValue $propertyFrame.en_totalbytes [expr [expr $offset + $length] / 8]
                }
            }
        }
        #the populatedCommParamList contains the index id of the displayed mapping parameter
        #the tree node of the communication parameter and the cells in which they are  inserted
        # lappend populatedCommParamList [list 0x$mappParam [lindex $finalMappList $count]  $popCountList]

        pack forget [lindex $f0 0]
        pack forget [lindex $f1 0]
        if {$st_autogen == 1 } {
            pack forget [lindex $f2 0]
            pack [lindex $f5 0] -expand yes -fill both -padx 2 -pady 4
        } else {
            pack [lindex $f2 0] -expand yes -fill both -padx 2 -pady 4
            pack forget [lindex $f5 0]
        }
        pack forget [lindex $f3 0]
        pack forget [lindex $f4 0]

        #puts "populatedCommParamList: $populatedCommParamList"
        #puts "populatedPDOList: $populatedPDOList"
        Validation::ResetPromptFlag
        return
    }

    #checking whether value has changed using save. changing the background accordingly
    if {[lsearch $savedValueList $node] != -1} {
        set savedBg #fdfdd4
    } else {
        set savedBg white
    }

    if {[string match "*SubIndex*" $node]} {
        set tmpInnerf0 [lindex $f1 1]
        set tmpInnerf1 [lindex $f1 2]
        set subIndexId [string range [$treePath itemcget $node -text] end-2 end-1]
        set parent [$treePath parent $node]
        set indexId [string range [$treePath itemcget $parent -text] end-4 end-1]

        set indexId "0x$indexId"
        set subIndexId "0x$subIndexId"

        set result [openConfLib::IsExistingSubIndex $nodeId $indexId $subIndexId]
        openConfLib::ShowErrorMessage [lindex $result 0]
        if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
            return
        }
        set subIndexExists [lindex $result 1]

        set IndexProp []
        for {set cnt 0 } {$cnt <= 9} {incr cnt} {
            set result [openConfLib::GetSubIndexAttribute $nodeId $indexId $subIndexId $cnt]
            if { [Result_IsSuccessful [lindex $result 0]] } {
                lappend IndexProp [lindex $result 1]
            } else {
                lappend IndexProp []
            }
        }

        $tmpInnerf0.en_idx1 configure -state normal
        $tmpInnerf0.en_idx1 delete 0 end
        $tmpInnerf0.en_idx1 insert 0 $indexId
        $tmpInnerf0.en_idx1 configure -state disabled

        $tmpInnerf0.en_sidx1 configure -state normal
        $tmpInnerf0.en_sidx1 delete 0 end
        $tmpInnerf0.en_sidx1 insert 0 $subIndexId
        $tmpInnerf0.en_sidx1 configure -state disabled

        pack forget [lindex $f0 0]
        pack [lindex $f1 0] -expand yes -fill both -padx 2 -pady 4
        pack forget [lindex $f2 0]
        [lindex $f2 1] cancelediting
        [lindex $f2 1] configure -state disabled
        pack forget [lindex $f3 0]
        pack forget [lindex $f4 0]
        pack forget [lindex $f5 0]
        [lindex $f5 1] cancelediting
        [lindex $f5 1] configure -state disabled
        set saveButton $subindexSaveBtn
    } elseif {[string match "*Index*" $node]} {
        set tmpInnerf0 [lindex $f0 1]
        set tmpInnerf1 [lindex $f0 2]

        set indexId [string range [$treePath itemcget $node -text] end-4 end-1]
        set indexId "0x$indexId"

        set result [openConfLib::IsExistingIndex $nodeId $indexId]
        openConfLib::ShowErrorMessage [lindex $result 0]
        if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
            return
        }
        set indexExists [lindex $result 1]

        set IndexProp []
        for {set cnt 0 } {$cnt <= 9} {incr cnt} {
            set result [openConfLib::GetIndexAttribute $nodeId $indexId $cnt]
            if { [Result_IsSuccessful [lindex $result 0]] } {
                lappend IndexProp [lindex $result 1]
            } else {
                lappend IndexProp []
            }
        }

        $tmpInnerf0.en_idx1 configure -state normal
        $tmpInnerf0.en_idx1 delete 0 end
        $tmpInnerf0.en_idx1 insert 0 $indexId
        $tmpInnerf0.en_idx1 configure -state disabled

        pack [lindex $f0 0] -expand yes -fill both -padx 2 -pady 4
        pack forget [lindex $f1 0]
        pack forget [lindex $f2 0]
        [lindex $f2 1] cancelediting
        [lindex $f2 1] configure -state disabled
        pack forget [lindex $f3 0]
        pack forget [lindex $f4 0]
        pack forget [lindex $f5 0]
        [lindex $f5 1] cancelediting
        [lindex $f5 1] configure -state disabled
        set saveButton $indexSaveBtn
    }

    #configuring the index and subindex save buttons with object type
    $saveButton configure -command "NoteBookManager::SaveValue $tmpInnerf0 $tmpInnerf1 [lindex $IndexProp 1]"
    if { ([expr $indexId > 0x1fff]) && ( ([lindex $IndexProp 1] == "VAR") || ([lindex $IndexProp 1] == "") ) } {
        set entryState normal
    } else {
        set entryState disabled
    }

    #for index starting with A and their subobjects all the fileds cannot be edited
    #for object type ro or const should not be added to CDC generation
    $tmpInnerf0.frame1.ch_gen deselect
    if { [string match -nocase "0xA???" $indexId] || [string match -nocase "const" [lindex $IndexProp 3]] == 1 || [string match -nocase "ro" [lindex $IndexProp 3]] == 1 } {
        $tmpInnerf0.frame1.ch_gen configure -state disabled
    } else {
        $tmpInnerf0.frame1.ch_gen configure -state normal
        if { [lindex $IndexProp 9] == "1" } {
            $tmpInnerf0.frame1.ch_gen select
        } else {
            $tmpInnerf0.frame1.ch_gen deselect
        }
    }

    if { [string match -nocase "ARRAY" [lindex $IndexProp 1] ] ||  [string match -nocase "RECORD" [lindex $IndexProp 1] ] } {
        $tmpInnerf0.frame1.ch_gen configure -state disabled
    }

    #for index less than 2000 only name and value can be edited
    $tmpInnerf0.en_nam1 configure -validate none -state normal
    $tmpInnerf0.en_nam1 delete 0 end
    $tmpInnerf0.en_nam1 insert 0 [lindex $IndexProp 0]
    $tmpInnerf0.en_nam1 configure -bg $savedBg -validate key
    $tmpInnerf0.en_nam1 configure -state disabled -bg white

    # default value will always be disabled
    $tmpInnerf1.en_default1 configure -state normal -validate none
    $tmpInnerf1.en_default1 delete 0 end
    $tmpInnerf1.en_default1 insert 0 [lindex $IndexProp 4]
    $tmpInnerf1.en_default1 configure -state disabled -bg white

#Actual value will be enabled
    $tmpInnerf1.en_value1 configure -state normal -validate none -bg $savedBg
    $tmpInnerf1.en_value1 delete 0 end
    $tmpInnerf1.en_value1 insert 0 [lindex $IndexProp 5]

    $tmpInnerf1.en_lower1 configure -state normal -validate none
    $tmpInnerf1.en_lower1 delete 0 end
    $tmpInnerf1.en_lower1 insert 0 [lindex $IndexProp 7]
    $tmpInnerf1.en_lower1 configure -state $entryState -bg white -validate key
    set LOWER_LIMIT [lindex $IndexProp 7]
    $tmpInnerf1.en_lower1 configure -state disabled -bg white

    $tmpInnerf1.en_upper1 configure -state normal -validate none
    $tmpInnerf1.en_upper1 delete 0 end
    $tmpInnerf1.en_upper1 insert 0 [lindex $IndexProp 8]
    $tmpInnerf1.en_upper1 configure -state $entryState -bg white -validate key
    set UPPER_LIMIT [lindex $IndexProp 8]
    $tmpInnerf1.en_upper1 configure -state disabled -bg white

    $tmpInnerf1.en_obj1 configure -state normal
    $tmpInnerf1.en_obj1 delete 0 end
    $tmpInnerf1.en_obj1 insert 0 [lindex $IndexProp 1]
    $tmpInnerf1.en_obj1 configure -state disabled -bg white

    $tmpInnerf1.en_data1 configure -state normal
    $tmpInnerf1.en_data1 delete 0 end
    $tmpInnerf1.en_data1 insert 0 [lindex $IndexProp 2]
    $tmpInnerf1.en_data1 configure -state disabled -bg white

    $tmpInnerf1.en_access1 configure -state normal
    $tmpInnerf1.en_access1 delete 0 end
    $tmpInnerf1.en_access1 insert 0 [lindex $IndexProp 3]
    $tmpInnerf1.en_access1 configure -state disabled -bg white

    $tmpInnerf1.en_pdo1 configure -state normal
    $tmpInnerf1.en_pdo1 delete 0 end
    $tmpInnerf1.en_pdo1 insert 0 [lindex $IndexProp 6]
    $tmpInnerf1.en_pdo1 configure -state disabled -bg white

    #The object less than 1FFF and object greater than 1FFF having object type
    #other than VAR only name and values are editable
    # The object types starting with A are validated in the else case those should be excluded
    set exp1 [string match -nocase "0xA???" $indexId]
    set exp2 [expr $indexId <= 0x1fff]
    set exp3 [expr $indexId > 0x1fff]
    set exp4 [lindex $IndexProp 1]

    grid $tmpInnerf1.en_obj1
    grid $tmpInnerf1.en_data1
    grid $tmpInnerf1.en_access1
    grid $tmpInnerf1.en_pdo1

    if {  ( $exp1 != 1 ) && ( ( $exp2 == 1) || ( ($exp3 == 1) && !($exp4 == "VAR" || $exp4 == "") ) ) } {

        #fields are editable only for VAR type and acess type other than ro const or empty
        #NOTE: also refer to the else part below
        if { [lindex $IndexProp 3] == "const" || [lindex $IndexProp 3] == "ro" \
        || [lindex $IndexProp 3] == "" || [ string match -nocase "VAR" [lindex $IndexProp 1] ] != 1 } {
            #the field is non editable
            $tmpInnerf1.en_value1 configure -state "disabled"
        } else {
            $tmpInnerf1.en_value1 configure -state "normal"
        }
    } else {
        #these must be objects greater than 1FFF without object type VAR or objects starting with A
        grid $tmpInnerf1.frame1.ra_dec
        grid $tmpInnerf1.frame1.ra_hex

        $tmpInnerf1.en_value1 configure -validate key -vcmd "Validation::IsValidEntryData %P"
        if { [string match -nocase "0xA???" $indexId] == 1 } {
            grid remove $tmpInnerf1.frame1.ra_dec
            grid remove $tmpInnerf1.frame1.ra_hex
            set widgetState disabled
            set comboState disabled
        } else {
            set widgetState normal
            set comboState normal
        }

        #make the save button disabled
        $indexSaveBtn configure -state $widgetState
        $subindexSaveBtn configure -state $widgetState

        $tmpInnerf1.en_value1 configure -state disabled

        #fields are editable only for VAR type and acess type other than ro const
            #it is also mot editable for index starting with "A"
            #NOTE: also refer to the if part above
        if { [lindex $IndexProp 3] == "const" || [lindex $IndexProp 3] == "ro" \
            || [ string match -nocase "VAR" [lindex $IndexProp 1] ] != 1 \
            || [string match -nocase "0xA???" $indexId] == 1} {
                #the field is non editable
            $tmpInnerf1.en_value1 configure -state "disabled"
        } else {
            $tmpInnerf1.en_value1 configure -state "normal"
        }
    }
    # disable the object type combobox of sub objects
    if { [string match "*SubIndex*" $node] && ([expr $indexId > 0x1fff]) } {
        #subobjects of index greater than 1fff exists only for index of type
        #ARRAY datatype is not editable
        if { ($subIndexId == "0x00") } {
            #$tmpInnerf1.en_lower1 configure -state disabled
            #$tmpInnerf1.en_upper1 configure -state disabled

            if { [ string match -nocase "ARRAY" [lindex $IndexProp 1] ] } {
                $tmpInnerf1.en_value1 configure -state normal
                $subindexSaveBtn configure -state normal
            } else {
                $tmpInnerf1.en_value1 configure -state disabled
                $subindexSaveBtn configure -state disabled
            }
        }
    }

    if { [lindex $IndexProp 2] == "IP_ADDRESS" } {
        set lastConv ""
        grid remove $tmpInnerf1.frame1.ra_dec
        grid remove $tmpInnerf1.frame1.ra_hex
        $tmpInnerf1.en_value1 configure -validate key -vcmd "Validation::IsIP %P %V" -bg $savedBg
    } elseif { [lindex $IndexProp 2] == "MAC_ADDRESS" } {
        set lastConv ""
        grid remove $tmpInnerf1.frame1.ra_dec
        grid remove $tmpInnerf1.frame1.ra_hex
        $tmpInnerf1.en_value1 configure -validate key -vcmd "Validation::IsMAC %P %V" -bg $savedBg
    } elseif { [lindex $IndexProp 2] == "Visible_String" } {
        set lastConv ""
        grid remove $tmpInnerf1.frame1.ra_dec
        grid remove $tmpInnerf1.frame1.ra_hex
        $tmpInnerf1.en_value1 configure -validate key -vcmd "Validation::IsValidStr %P" -bg $savedBg
    } elseif { [lindex $IndexProp 2] == "Octet_String" } {
        set lastConv ""
        grid remove $tmpInnerf1.frame1.ra_dec
        grid remove $tmpInnerf1.frame1.ra_hex
        $tmpInnerf1.en_value1 configure -validate key -vcmd "Validation::IsValidStr %P" -bg $savedBg
    } elseif { [ string match -nocase "BIT" [lindex $IndexProp 2] ] == 1 } {
        set state [$tmpInnerf1.en_value1 cget -state]
        if { [Validation::CheckBitNumber[lindex $IndexProp 5]] == 1 } {
            # it is a bit of 8 character
        } else {
            $tmpInnerf1.en_value1 configure -state normal
            $tmpInnerf1.en_value1 delete 0 end

            if { [string match -nocase "0x*" [lindex $IndexProp 5]] } {
                #check whether it is hex
                set bitInput [string range [lindex $IndexProp 5] 2 end]
                if { [Validation::CheckHexaNumber $bitInput ] == 1 && [string length $bitInput] <= 8  && $bitInput != "" } {
                    #it is a hex number of required length covert to bit
                    set bitInput [Validation::HextoBin $bitInput]
                    $tmpInnerf1.en_value1 insert 0 $bitInput
                }
            }
        }
        set lastConv ""
        grid remove $tmpInnerf1.frame1.ra_dec
        grid remove $tmpInnerf1.frame1.ra_hex
        $tmpInnerf1.en_value1 configure -validate key -vcmd "Validation::CheckBitNumber %P" -bg $savedBg -state $state
    } elseif { [string match -nocase "REAL*" [lindex $IndexProp 2]] } {
        set lastConv hex
        grid remove $tmpInnerf1.frame1.ra_dec
        grid remove $tmpInnerf1.frame1.ra_hex
        $tmpInnerf1.en_value1 configure -validate key -vcmd "Validation::IsHex %P %s $tmpInnerf1.en_value1 %d %i [lindex $IndexProp 2]" -bg $savedBg
    } elseif { [string match -nocase "INTEGER*" [lindex $IndexProp 2]] || [string match -nocase "UNSIGNED*" [lindex $IndexProp 2]] || [string match -nocase "BOOLEAN" [lindex $IndexProp 2]] } {
        grid $tmpInnerf1.frame1.ra_dec
        grid $tmpInnerf1.frame1.ra_hex
        #puts "node->$node Dt [lindex $IndexProp 2]"
        set schRes [lsearch $userPrefList [list $nodeSelect *]]
        if { $schRes != -1 } {
            if { [lindex [lindex $userPrefList $schRes] 1] == "dec" } {
                set lastConv dec
                $tmpInnerf1.frame1.ra_dec select
            } elseif { [lindex [lindex $userPrefList $schRes] 1] == "hex" } {
                set lastConv hex
                $tmpInnerf1.frame1.ra_hex select
            } else {
                return
            }
        } else {
            if {[string match -nocase "0x*" [lindex $IndexProp 5]]} {
                set lastConv hex
                $tmpInnerf1.frame1.ra_hex select
            } else {
                set lastConv dec
                $tmpInnerf1.frame1.ra_dec select
            }
        }
        Operations::CheckConvertValue $tmpInnerf1.en_lower1 [lindex $IndexProp 2] $lastConv
        Operations::CheckConvertValue $tmpInnerf1.en_upper1 [lindex $IndexProp 2] $lastConv
        Operations::CheckConvertValue $tmpInnerf1.en_value1 [lindex $IndexProp 2] $lastConv
        Operations::CheckConvertValue $tmpInnerf1.en_default1 [lindex $IndexProp 2] $lastConv
    } else {
        set lastConv ""
        grid remove $tmpInnerf1.frame1.ra_dec
        grid remove $tmpInnerf1.frame1.ra_hex
        $tmpInnerf1.en_value1 configure -validate key -vcmd { return 0 } -bg $savedBg
    }
    return
}

#-------------------------------------------------------------------------------
#  Operations::MNProperties
#
#  Arguments: node       - Select tree node path
#             nodeId     - Id of the node
#
#  Results:  -
#
#  Description: Displays the properties of selected MN
#-------------------------------------------------------------------------------
proc Operations::MNProperties {node nodeId} {
    global f3
    global savedValueList
    global lastConv
    global userPrefList
    global nodeSelect
    global MNDatalist
    global mnPropSaveBtn

    set tmpInnerf0 [lindex $f3 1]
    set tmpInnerf1 [lindex $f3 2]

    set result [openConfLib::GetNodeParameter $nodeId $::NODENAME ]
    openConfLib::ShowErrorMessage [lindex $result 0]
    if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
        return
    }
    set locNodeName [lindex $result 1]

    set result [openConfLib::GetNodeParameter $nodeId $::STATIONTYPE ]
    openConfLib::ShowErrorMessage [lindex $result 0]
    if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
        return
    }
    set locStationType [lindex $result 1]

    set result [openConfLib::GetNodeParameter $nodeId $::FORCED_MULTIPLEXED_CYCLE ]
    openConfLib::ShowErrorMessage [lindex $result 0]
    if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
        return
    }
    set locForcedMultiplexedCycle [lindex $result 1]

    #configure the save button
    $mnPropSaveBtn configure -command "NoteBookManager::SaveMNValue $tmpInnerf0 $tmpInnerf1"

    if {[lsearch $savedValueList $node] != -1} {
        set savedBg #fdfdd4
    } else {
        set savedBg white
    }

    # insert node name
    $tmpInnerf0.en_nodeName delete 0 end
    $tmpInnerf0.en_nodeName insert 0 $locNodeName
    $tmpInnerf0.en_nodeName configure -bg $savedBg

    # insert node number
    $tmpInnerf0.en_nodeNo configure -state normal -validate none
    $tmpInnerf0.en_nodeNo delete 0 end
    $tmpInnerf0.en_nodeNo insert 0 $nodeId
    $tmpInnerf0.en_nodeNo configure -state disabled

    set MNDatalist ""

    # value from 1006 for Cycle time
    set result [openConfLib::GetIndexAttribute $nodeId $Operations::CYCLE_TIME_OBJ $::ACTUALVALUE]
    if { [Result_IsSuccessful [lindex $result 0]] } {
        $tmpInnerf0.cycleframe.en_time configure -state normal -validate none -bg $savedBg
        $tmpInnerf0.cycleframe.en_time delete 0 end
        $tmpInnerf0.cycleframe.en_time insert 0 [lindex $result 1]

        set result [openConfLib::GetIndexAttribute $nodeId $Operations::CYCLE_TIME_OBJ $::DATATYPE]
        if { [Result_IsSuccessful [lindex $result 0]] } {
            set locCycleTimeDatatype [lindex $result 1]
        } else {
            set locCycleTimeDatatype ""
        }

        Operations::CheckConvertValue $tmpInnerf0.cycleframe.en_time $locCycleTimeDatatype "dec"
        lappend MNDatalist [list cycleTimeDatatype $locCycleTimeDatatype]
    } else {
        #fail
        $tmpInnerf0.cycleframe.en_time configure -state normal -validate none
        $tmpInnerf0.cycleframe.en_time delete 0 end
        $tmpInnerf0.cycleframe.en_time configure -state disabled
        Console::DisplayErrMsg "ERR: [Result_GetErrorString [lindex $result 0]]" error
    }

    set result [Operations::GetObjectValueData $nodeId $Operations::LOSS_SOC_TOLERANCE]
    if { [lindex $result 0] } {
        # the value of loss of SoC Tolerance is in nanoseconds divide it by 1000 to display it as microseconds
        if { [ catch { set locSoCToleranceActVal [expr [lindex $result 2] / 1000] } ] } {
        #if error has occurred set it to default 10 milliseconds i.e., 100 microseconds as per specification
            set locSoCToleranceActVal 100
        }
        set locSoCToleranceDatatype [lindex $result 1]
        $tmpInnerf1.en_advOption4 configure -state normal -validate none -bg $savedBg
        $tmpInnerf1.en_advOption4 delete 0 end
        $tmpInnerf1.en_advOption4 insert 0 $locSoCToleranceActVal
        Operations::CheckConvertValue $tmpInnerf1.en_advOption4 $locSoCToleranceDatatype "dec"
        lappend MNDatalist [list lossSoCToleranceDatatype $locSoCToleranceDatatype]
    } else {
        #fail
        $tmpInnerf1.en_advOption4 configure -state normal -validate none
        $tmpInnerf1.en_advOption4 delete 0 end
        $tmpInnerf1.en_advOption4 configure -state disabled
        Console::DisplayErrMsg "[lindex $result 3]" error
    }

    # value from 0x1F98/08 for Asynchronous MTU size
    set result [Operations::GetObjectValueData $nodeId [lindex $Operations::ASYNC_MTU_SIZE_OBJ 0]  [lindex $Operations::ASYNC_MTU_SIZE_OBJ 1]]
    if { [lindex $result 0] } {
        set locAsynMTUSizeDataType [lindex $result 1]
        $tmpInnerf1.en_advOption1 configure -state normal -validate none -bg $savedBg
        $tmpInnerf1.en_advOption1 delete 0 end
        $tmpInnerf1.en_advOption1 insert 0 [lindex $result 2]
        Operations::CheckConvertValue $tmpInnerf1.en_advOption1 $locAsynMTUSizeDataType "dec"
        lappend MNDatalist [list asynMTUSizeDatatype $locAsynMTUSizeDataType]
    } else {
        #fail
        $tmpInnerf1.en_advOption1 configure -state normal -validate none
        $tmpInnerf1.en_advOption1 delete 0 end
        $tmpInnerf1.en_advOption1 configure -state disabled
        Console::DisplayErrMsg "[lindex $result 3]" error
    }

    # value from 0x1F8A/02 for Asynchronous Timeout
    set result [Operations::GetObjectValueData $nodeId [lindex $Operations::ASYNC_TIMEOUT_OBJ 0] [lindex $Operations::ASYNC_TIMEOUT_OBJ 1]]
    if { [lindex $result 0] } {
        set locAsynTimeoutDataType [lindex $result 1]
        $tmpInnerf1.en_advOption2 configure -state normal -validate none -bg $savedBg
        $tmpInnerf1.en_advOption2 delete 0 end
        $tmpInnerf1.en_advOption2 insert 0 [lindex $result 2]
        Operations::CheckConvertValue $tmpInnerf1.en_advOption2 $locAsynTimeoutDataType "dec"
        lappend MNDatalist [list asynTimeoutDatatype $locAsynTimeoutDataType]
    } else {
        #fail
        $tmpInnerf1.en_advOption2 configure -state normal -validate none
        $tmpInnerf1.en_advOption2 delete 0 end
        $tmpInnerf1.en_advOption2 configure -state disabled
        Console::DisplayErrMsg "[lindex $result 3]" error
    }

    # value from 0x1F98/07 for Multiplexing prescaler (MN parameter)
    set result [openConfLib::GetFeatureValue $nodeId $::DLLMNFeatureMultiplex]
    openConfLib::ShowErrorMessage [lindex $result 0]
    set MNFeatureMultiplexFlag [lindex $result 1]


    set result [Operations::GetObjectValueData $nodeId [lindex $Operations::MULTI_PRESCAL_OBJ 0] [lindex $Operations::MULTI_PRESCAL_OBJ 1]]
    if { [lindex $result 0] } {
        set locMultiPrescalerDatatype [lindex $result 1]
        set locMultiPreScalarValue [lindex $result 2]
        if { ( [string match -nocase "TRUE" $MNFeatureMultiplexFlag] == 1 )  } {
            $tmpInnerf1.en_advOption3 configure -state normal -validate none -bg $savedBg
            $tmpInnerf1.en_advOption3 delete 0 end
            $tmpInnerf1.en_advOption3 insert 0 $locMultiPreScalarValue
            Operations::CheckConvertValue $tmpInnerf1.en_advOption3 $locMultiPrescalerDatatype "dec"
            lappend MNDatalist [list multiPrescalerDatatype $locMultiPrescalerDatatype]
        } else {
            $tmpInnerf1.en_advOption3 configure -state normal -validate none
            $tmpInnerf1.en_advOption3 delete 0 end
            $tmpInnerf1.en_advOption3 insert 0 $locMultiPreScalarValue
            $tmpInnerf1.en_advOption3 configure -state disabled
        }
    } else {
        #fail
        $tmpInnerf1.en_advOption3 configure -state normal -validate none
        $tmpInnerf1.en_advOption3 delete 0 end
        $tmpInnerf1.en_advOption3 configure -state disabled
        Console::DisplayErrMsg "[lindex $result 3]" error
    }

    Validation::ResetPromptFlag
}

#-------------------------------------------------------------------------------
#  Operations::CNProperties
#
#  Arguments: node   - Select path of tree node
#             nodeId - Id of the node
#
#  Results:  -
#
#  Description: Displays the properties of selected CN
#-------------------------------------------------------------------------------
proc Operations::CNProperties {node nodeId} {
    global f4
    global savedValueList
    global nodeSelect
    global CNDatalist
    global cnPropSaveBtn
    global lastRadioVal

    set tmpInnerf0 [lindex $f4 1]
    set tmpInnerf1 [lindex $f4 2]
    set tmpInnerf2 [lindex $f4 4]

    set cnName ""
    set result [openConfLib::GetNodeParameter $nodeId $::NAME]
    openConfLib::ShowErrorMessage [lindex $result 0]
    if { [Result_IsSuccessful [lindex $result 0]] } {
        set cnName [lindex $result 1]
    }

    if {[lsearch $savedValueList $node] != -1} {
        set savedBg #fdfdd4
    } else {
        set savedBg white
    }

    $tmpInnerf0.en_nodeName delete 0 end
    $tmpInnerf0.en_nodeName insert 0 $cnName
    $tmpInnerf0.en_nodeName configure -bg $savedBg

    #configure the save button
    $cnPropSaveBtn configure -command "NoteBookManager::SaveCNValue $nodeId $tmpInnerf0 $tmpInnerf1 $tmpInnerf2"

    #insert node number
    $tmpInnerf0.sp_nodeNo set $nodeId

    # value from 1F98 03 for PResponse Cycle time
    set CNDatalist ""

    #clear the entry box and disable it
    $tmpInnerf0.cycleframe.en_time configure -state normal -validate none
    $tmpInnerf0.cycleframe.en_time delete 0 end
    $tmpInnerf0.cycleframe.en_time configure -state disabled

    set nodeIdSidx [lindex [Validation::InputToHex $nodeId INTEGER8] 0]
    # puts "nodeIdSidx:$nodeIdSidx"
    set Operations::PRES_TIMEOUT_OBJ [list 0x1F92 $nodeIdSidx]

    set pResCycleTimeLimitValue 25
    set pResCycleTimeLimitAct 25
    set result [openConfLib::GetSubIndexAttribute $nodeId [lindex $Operations::PRES_TIMEOUT_LIMIT_OBJ 0] [lindex $Operations::PRES_TIMEOUT_LIMIT_OBJ 1] $::ACTUALVALUE ]
    if { [Result_IsSuccessful [lindex $result 0]] } {
        set pResCycleTimeLimitAct [lindex $result 1]
    } else {
        set pResCycleTimeLimitDef 25
        set result [openConfLib::GetSubIndexAttribute $nodeId [lindex $Operations::PRES_TIMEOUT_LIMIT_OBJ 0] [lindex $Operations::PRES_TIMEOUT_LIMIT_OBJ 1] $::DEFAULTVALUE ]
        if { [Result_IsSuccessful [lindex $result 0]] } {
            set pResCycleTimeLimitDef [lindex $result 1]
        }
        set pResCycleTimeLimitAct $pResCycleTimeLimitDef
    }

    if { [ catch { set pResCycleTimeLimitValue [expr $pResCycleTimeLimitAct / 1000] } ] } {
        #if error has occurred set it to default 25 micro seconds
        set pResCycleTimeLimitValue 25
    }

    set mnNodeId 240
    set mnExists 0
    set result [openConfLib::IsExistingNode $mnNodeId]
    if { [Result_IsSuccessful [lindex $result 0]] } {
        set mnExists [lindex $result 1]
    }

    if {$mnExists} {
        set presTimeoutVal 0
        set presTimeoutAct 0
        set result [openConfLib::GetSubIndexAttribute $mnNodeId [lindex $Operations::PRES_TIMEOUT_OBJ 0] [lindex $Operations::PRES_TIMEOUT_OBJ 1] $::ACTUALVALUE ]
        if { [Result_IsSuccessful [lindex $result 0]] } {
            set presTimeoutAct [lindex $result 1]
        } else {
            set presTimeoutDef $pResCycleTimeLimitValue
            set result [openConfLib::GetSubIndexAttribute $mnNodeId [lindex $Operations::PRES_TIMEOUT_OBJ 0] [lindex $Operations::PRES_TIMEOUT_OBJ 1] $::DEFAULTVALUE ]
            if { [Result_IsSuccessful [lindex $result 0]] } {
                set presTimeoutDef [lindex $result 1]
            }
            set presTimeoutAct $presTimeoutDef
        }

        if { [ catch { set presTimeoutVal [expr $presTimeoutAct / 1000] } ] } {
            #if error has occurred set it to default 25 micro seconds
            set presTimeoutVal 25
            # TODO verify
        }

        set presTimeoutDataType ""
        set result [openConfLib::GetSubIndexAttribute $mnNodeId [lindex $Operations::PRES_TIMEOUT_OBJ 0] [lindex $Operations::PRES_TIMEOUT_OBJ 1] $::DATATYPE ]
        if { [Result_IsSuccessful [lindex $result 0]] } {
            set presTimeoutDataType [lindex $result 1]
        }
        $tmpInnerf0.cycleframe.en_time configure -state normal -validate none -bg white
        $tmpInnerf0.cycleframe.en_time delete 0 end
        $tmpInnerf0.cycleframe.en_time insert 0 $presTimeoutVal

        Operations::CheckConvertValue $tmpInnerf0.cycleframe.en_time $presTimeoutDataType "dec"
        # the user cannot enter value which is less than the obtained minimum value
        #NOTE:: the minimum value is shown from the vcmd cmd if vcmd then look into
        #save cnvalue to modify the same

        $tmpInnerf0.cycleframe.en_time configure -validate key -vcmd "Validation::ValidatePollRespTimeoutMinimum \
                %P $tmpInnerf0.cycleframe.en_time %d %i %V $presTimeoutVal $pResCycleTimeLimitValue $presTimeoutDataType 0"

        lappend CNDatalist [list presponseCycleTimeDatatype $presTimeoutDataType]
    }

    $tmpInnerf2.ch_adv deselect
    $tmpInnerf2.ch_adv configure -state disabled
    set spinVar [$tmpInnerf2.sp_cycleNo cget -textvariable]
    global $spinVar
    set $spinVar ""
    $tmpInnerf2.sp_cycleNo configure -state disabled

    set cnStationType ""
    set result [openConfLib::GetNodeParameter $nodeId $::STATIONTYPE]
    openConfLib::ShowErrorMessage [lindex $result 0]
    if { [Result_IsSuccessful [lindex $result 0]] } {
        set cnStationType [lindex $result 1]
    }

    set lastRadioVal "StNormal"
    $tmpInnerf1.ra_StMulti deselect
    $tmpInnerf1.ra_StMulti configure -state disabled
    $tmpInnerf1.ra_StChain deselect
    $tmpInnerf1.ra_StChain configure -state disabled
    $tmpInnerf1.ra_StNormal select
    #Normal operation always enabled


    set result [openConfLib::GetFeatureValue $mnNodeId $::DLLMNFeatureMultiplex]
    openConfLib::ShowErrorMessage [lindex $result 0]
    set MNFeatureMultiplexFlag [lindex $result 1]


    set result [openConfLib::GetFeatureValue $nodeId $::DLLCNFeatureMultiplex]
    openConfLib::ShowErrorMessage [lindex $result 0]
    set CNFeatureMultiplexFlag [lindex $result 1]

    # puts "MNFeatureMultiplexFlag:$MNFeatureMultiplexFlag CNFeatureMultiplexFlag:$CNFeatureMultiplexFlag"
    if { $MNFeatureMultiplexFlag && $CNFeatureMultiplexFlag } {
        if {$mnExists} {
            set errMultiFlag 0

            set locMultiPreScalarValue ""
            set locMultiPrescalerDatatype ""
            set result [Operations::GetObjectValueData $mnNodeId [lindex $Operations::MULTI_PRESCAL_OBJ 0] [lindex $Operations::MULTI_PRESCAL_OBJ 1] ]
            if { [lindex $result 0] } {
                set locMultiPrescalerDatatype [lindex $result 1]
                set locMultiPreScalarValue [lindex $result 2]
            } else {
                #fail
                Console::DisplayErrMsg "[lindex $result 3]" error
            }

            if {$locMultiPreScalarValue == "" } {
                #value is empty disable the multiplex radio button
                set errMultiFlag 1
            } else {
                #configure the cn save button with multiplex prescalar datatype
                $cnPropSaveBtn configure -command "NoteBookManager::SaveCNValue $nodeId \
                    $tmpInnerf0 $tmpInnerf1 $tmpInnerf2 $locMultiPreScalarValue"

                #check whether it is Hex or Dec and get the decimal value
                if { [string match -nocase "0x*" $locMultiPreScalarValue] == 1 } {
                    #it must be hex convert it to dec
                    set $locMultiPreScalarValue [string range $locMultiPreScalarValue 2 end]
                    set convResult [Validation::InputToDec $locMultiPreScalarValue $locMultiPrescalerDatatype ]
                    #check the result of conversion
                    if { [string match -nocase "pass" [lindex $convResult 1]] == 0 } {
                        #error in conversion
                        set errMultiFlag 1
                    } else {
                        #set the converted decimal no
                        set multiPrescalerDecValue [lindex $convResult 0]
                    }
                } else {
                    #check whether it is a decimal value
                    if { [Validation::CheckDecimalNumber $locMultiPreScalarValue] == 0 } {
                        set errMultiFlag 1
                    } else {
                        #value is a decimal no
                        set multiPrescalerDecValue $locMultiPreScalarValue
                    }
                }
            }
            # enable the radio button if no error flag is set and the
            #value of multiplex prescaler is greater than zero
            if { ($errMultiFlag == 0) && ($multiPrescalerDecValue > 0) } {
                #passed all validation enable the radio button
                $tmpInnerf1.ra_StMulti configure -state normal
                #configure the cycle no list
                $tmpInnerf2.sp_cycleNo configure -values [Operations::GenerateCycleNo $multiPrescalerDecValue] \
                    -validate key -vcmd "Validation::CheckForceCycleNumber %P $multiPrescalerDecValue"
                # the saved force cycle no will be in hexadecimal convert it to decimal
                set cnForcedCycleValue ""
                set result [openConfLib::GetNodeParameter $nodeId $::FORCED_MULTIPLEXED_CYCLE]
                if { [Result_IsSuccessful [lindex $result 0]] } {
                    if { [string match -nocase "0x*" [lindex $result 1]] } {
                        set cnForcedCycleValue [string range [lindex $result 1] 2 end]
                    } else {
                        set cnForcedCycleValue [lindex $result 1]
                    }
                }

                set prevSelCycleNoDec [Validation::InputToDec $cnForcedCycleValue $locMultiPrescalerDatatype ]
                if { [string match -nocase "pass" [lindex $prevSelCycleNoDec 1]] == 0 } {
                    #error in conversion
                    set prevSelCycleNoDec ""
                } else {
                    #set the converted decimal no
                    set prevSelCycleNoDec [lindex $prevSelCycleNoDec 0]
                }
                #set the previously saved force cycle number
                set $spinVar $prevSelCycleNoDec
                if {$cnStationType == 1} {
                    set lastRadioVal "StMulti"
                    # it is multiplexed operation
                    $tmpInnerf1.ra_StMulti select
                    $tmpInnerf2.ch_adv configure -state normal
                    if { [expr {"$prevSelCycleNoDec" > "0"}] } {
                        $tmpInnerf2.ch_adv select
                    }
                    $tmpInnerf2.sp_cycleNo configure -state normal
                }
                # puts "cnStationType:$cnStationType"
            }
        }
    }

    set result [openConfLib::GetFeatureValue $mnNodeId $::DLLMNPResChaining]
    openConfLib::ShowErrorMessage [lindex $result 0]
    set MNFeatureChainFlag [lindex $result 1]

    set result [openConfLib::GetFeatureValue $nodeId $::DLLCNPResChaining]
    openConfLib::ShowErrorMessage [lindex $result 0]
    set CNFeatureChainFlag [lindex $result 1]

    # puts "MNFeatureChainFlag:$MNFeatureChainFlag  CNFeatureChainFlag:$CNFeatureChainFlag"
    if { $MNFeatureChainFlag && $CNFeatureChainFlag } {
        $tmpInnerf1.ra_StChain configure -state normal
        if {$cnStationType == 2} {
            set lastRadioVal "StChain"
            # it is chained operation
            $tmpInnerf1.ra_StChain select
        }
    }

    Validation::ResetPromptFlag
}

#-------------------------------------------------------------------------------
#  Operations::GetObjectValueData
#
#  Arguments:
#              nodeId     - Id of the node
#              indexId    - Id of index object
#              subIndexId - Id of subindex object (optional)
#
#  Results: list 0 - 1/0 pass/fail
#           list 1 - Datatype
#           list 2 - value (act or default if act is empty)
#           list 3 - errormessage (if any)
#
#  Description: Returns the datatype and actualvalue/defaultvalue for index/subindex
#-------------------------------------------------------------------------------
proc Operations::GetObjectValueData {nodeId indexId {subIndexId ""} } {

    set retValList ""
    set locDataType ""
    set locActValue ""
    set errormessage "success"

    if { $subIndexId == "" } {
        #no subindex get the index
        set cmd "openConfLib::GetIndexAttribute $nodeId $indexId"
    } else {
        #get the subindex property
        set cmd "openConfLib::GetSubIndexAttribute $nodeId $indexId $subIndexId"
    }

    set result [eval $cmd $::DATATYPE ]
    if { [Result_IsSuccessful [lindex $result 0]] == 1 } {
        set locDataType [lindex $result 1]

        set result [eval $cmd $::DEFAULTVALUE ]
        if { [Result_IsSuccessful [lindex $result 0]] == 1 } {
            set locDefaultVal [lindex $result 1]

            set result [eval $cmd $::ACTUALVALUE]
            if { [Result_IsSuccessful [lindex $result 0]] == 1 } {
                set locActValue [lindex $result 1]
                if { $locActValue == "" } {
                    #if the actual is empty assign the default value
                    set locActValue $locDefaultVal
                }
                set res 1
            } else {
                set errormessage "GetACTUALVALUE $nodeId $indexId $subIndexId failed. [Result_GetErrorString [lindex $result 0]]"
                set res 0
            }
        } else {
            set errormessage "GetDEFAULTVALUE $nodeId $indexId $subIndexId failed. [Result_GetErrorString [lindex $result 0]]"
            set res 0
        }
    } else {
        set errormessage "GetDATATYPE $nodeId $indexId $subIndexId failed. [Result_GetErrorString [lindex $result 0]]"
        set res 0
    }

    lappend retValList $res $locDataType $locActValue $errormessage
    return $retValList
}

#-------------------------------------------------------------------------------
#  Operations::CheckConvertValue
#
#  Arguments: entryPath   - Position of node in collection
#             dataType    - Id of the node
#             valueFormat - Indicates the type as MN or CN
#             indexId     - Id of index object
#             subIndexId  - Id of subindex object (optional)
#
#  Results:  pass and actual, default and datatype value or fail
#
#  Description: Gets the actual, default and datatype value for index or subindex
#-------------------------------------------------------------------------------
proc Operations::CheckConvertValue { entryPath dataType valueFormat } {
    set entryState [$entryPath cget -state]
    set reqValue [$entryPath get]
    $entryPath configure -state normal -validate none
    if { $valueFormat == "dec" } {
        if {[string match -nocase "0x*" $reqValue]} {
            NoteBookManager::InsertDecimal $entryPath $dataType
        } else {
            # value already in decimal
        }
        $entryPath configure -validate key -vcmd "Validation::IsDec %P $entryPath %d %i $dataType"
    } elseif { $valueFormat == "hex" } {
        if {[string match -nocase "0x*" $reqValue]} {
            # value already in hexadecimal
        } else {
            NoteBookManager::InsertHex $entryPath $dataType
        }
        $entryPath configure -validate key -vcmd "Validation::IsHex %P %s $entryPath %d %i $dataType"
    } else {
        $entryPath configure -state $entryState
        return
    }
    $entryPath configure -state $entryState
}

#-------------------------------------------------------------------------------
#  Operations::DoubleClickNode
#
#  Arguments: node - Selected node from tree widget
#
#  Results: -
#
#  Description: Displays required properties and expands tree when corresponding nodes are clicked
#-------------------------------------------------------------------------------
proc Operations::DoubleClickNode {node} {
    global treePath

    if {[$treePath nodes $node] != "" } {
        if {[$treePath itemcget $node -open]} {
            #it is already expanded so collapse it
            $treePath itemconfigure $node -open 0
        } else {
                #it is collapsed so expand it
                $treePath itemconfigure $node -open 1
        }
    } else {
        # it has no child no need to expand
    }
    Operations::SingleClickNode $node
}

#-------------------------------------------------------------------------------
#  Operations::Saveproject
#
#  Arguments: -
#
#  Results: -
#
#  Description: Calls the API to save project
#-------------------------------------------------------------------------------
proc Operations::Saveproject {} {
    global projectName
    global projectDir
    global status_save

    if {$projectDir == "" || $projectName == "" } {
        #there is no project directory or project name no need to save
        return
    } else {
        thread::send  [tsv::set application importProgress] "StartProgress"
        set result [SaveProject]
        if { [Result_IsSuccessful $result] != 1 } {
            if { [ string is ascii [Result_GetErrorString $result] ] } {
                tk_messageBox -message "Code:[Result_GetErrorCode $result]\nMsg:[Result_GetErrorString $result]" -title Error -icon error -parent .
            } else {
                tk_messageBox -message "Code:[Result_GetErrorCode $result]\nMsg:Unknown Error" -title Error -icon error -parent .
            }
            thread::send  [tsv::set application importProgress] "StopProgress"
            return
        }
        thread::send  [tsv::set application importProgress] "StopProgress"
    }
    #project is saved so change status to zero
    set status_save 0

    Console::DisplayInfo "Project $projectName at location $projectDir is saved"
}

#-------------------------------------------------------------------------------
#  Operations::InitiateNewProject
#
#  Arguments: -
#
#  Results: -
#
#  Description: Saves the current project and creates new project
#-------------------------------------------------------------------------------
proc Operations::InitiateNewProject {} {
    global resourcesDir

    set odXML [file join $resourcesDir od.xml]
    if {![file isfile $odXML] } {
        tk_messageBox -message "The file od.xml is missing cannot proceed\nConsult the user manual to troubleshoot" -title Info -icon error
        return
    } else {
        #od.xml is present continue
    }

    set result [ChildWindows::SaveProjectWindow]
    if { $result != "cancel"} {
       ChildWindows::NewProjectWindow
    }
}

#-------------------------------------------------------------------------------
#  Operations::InitiateCloseProject
#
#  Arguments: -
#
#  Results: -
#
#  Description: Saves the current project and closes it
#-------------------------------------------------------------------------------
proc Operations::InitiateCloseProject {} {
    global status_save
    global projectName

    #before close should prompt to close
    if {$status_save} {
        set result [tk_messageBox -message "Save project $projectName before closing?" -parent . -type yesnocancel -icon question -title "Question"]
        switch -- $result {
            yes {
                Operations::Saveproject
                Console::DisplayInfo "Project $projectName is saved" info
            }
            no {
                Console::DisplayInfo "Project $projectName not saved" info
            }
            cancel {
                return
            }
        }
        Operations::CloseProject
    } else {
        set result [ChildWindows::CloseProjectWindow]
    }
}

#-------------------------------------------------------------------------------
#  Operations::CloseProject
#
#  Arguments: -
#
#  Results: -
#
#  Description: Deletes the tree widget, deletes all the nodes in current project
#               and resets global data
#-------------------------------------------------------------------------------
proc Operations::CloseProject {} {
    global treePath
    global projectDir
    global projectName

    Operations::DeleteAllNode

    if { $projectDir != "" && $projectName != "" } {
        if { ![file exists [file join $projectDir $projectName].xml ] } {
            catch { file delete -force -- $projectDir }
        }
    }

    Operations::ResetGlobalData

    catch {$treePath delete ProjectNode}

    if { [$Operations::projMenu index 3] == "3" } {
        catch {$Operations::projMenu delete 3}
    }
    if { [$Operations::projMenu index 2] == "2" } {
        catch {$Operations::projMenu delete 2}
    }

    Operations::InsertTree
}

#-------------------------------------------------------------------------------
#  Operations::ResetGlobalData
#
#  Arguments: -
#
#  Results: -
#
#  Description: Resets all the globally maintained data
#-------------------------------------------------------------------------------
proc Operations::ResetGlobalData {} {
    global projectDir
    global projectName
    global nodeIdList
    global savedValueList
    global populatedPDOList
    global userPrefList
    global nodeSelect
    global treePath
    global mnCount
    global cnCount
    global status_save
    global f0
    global f1
    global f2
    global f3
    global f4
    global lastConv
    global LastTableFocus
    global chkPrompt
    global st_save
    global st_autogen
    global lastRadioVal
    global lastVideoModeSel

    #reset all the globaly maintained values
    set nodeIdList ""
    set savedValueList ""
    set populatedPDOList ""
    set userPrefList ""
    set nodeSelect ""
    set mnCount 0
    set cnCount 0
    set status_save 0
    set projectDir ""
    set projectName ""
    set lastConv ""
    set LastTableFocus ""
    Validation::ResetPromptFlag
    set temp_st_save 2
    set st_save 2
    set st_autogen 1
    set lastRadioVal ""
    set lastVideoModeSel -1
    #no need to reset lastOpenPjt, lastXD, tableSaveBtn, indexSaveBtn and subindexSaveBtn

    #no index subindex or pdo table should be displayed
    #pack forget [lindex $f0 0]
    #pack forget [lindex $f1 0]
    #pack forget [lindex $f2 0]
    #[lindex $f2 1] cancelediting
    #[lindex $f2 1] configure -state disabled
    #pack forget [lindex $f3 0]
    #pack forget [lindex $f4 0]
    Operations::RemoveAllFrames
    update
}

#-------------------------------------------------------------------------------
#  Operations::DeleteAllNode
#
#  Arguments: -
#
#  Results: -
#
#  Description: Deletes all the nodes in current project
#-------------------------------------------------------------------------------
proc Operations::DeleteAllNode {} {

    set result openCONFIGURATOR::Library::API::CloseProject

    #TODO Handle the result
}

#-------------------------------------------------------------------------------
#  Operations::AddCN
#
#  Arguments: cnName    - Name of CN
#             tmpImpDir - File to be imported
#             nodeId    - Id for CN
#
#  Results: -
#
#  Description: Creates the CN node
#-------------------------------------------------------------------------------
proc Operations::AddCN {cnName tmpImpDir nodeId} {
    global treePath
    global cnCount
    global mnCount
    global nodeIdList
    global status_save
    global image_dir

    if {$tmpImpDir != ""} {
        thread::send  [tsv::set application importProgress] "StartProgress"
        set result [openConfLib::AddNode $nodeId $cnName $tmpImpDir]
        openConfLib::ShowErrorMessage $result
        if { [Result_IsSuccessful $result] != 1 } {
            thread::send  [tsv::set application importProgress] "StopProgress"
            return
        }
        thread::send  [tsv::set application importProgress] "StopProgress"
        Console::DisplayInfo "$cnName nodeId: $nodeId has been inserted using the configuration $tmpImpDir"

        #New CN is created need to save
        incr cnCount
        set status_save 1

        set node [$treePath selection get]
        set parentId [lrange [split $node -] 1 end]
        set parentId [join $parentId -]
        set treeNodeCN CN-$parentId-$cnCount

        lappend nodeIdList $nodeId
        #Creating the GUI for CN
        image create photo img_cn -file "$image_dir/cn.gif"
        image create photo img_pdo -file "$image_dir/pdo.gif"

        set child [$treePath insert end $node $treeNodeCN -text "$cnName\($nodeId\)" -open 0 -image img_cn]

        thread::send  [tsv::set application importProgress] "StartProgress"
        set result [WrapperInteractions::Import $treeNodeCN $nodeId]
        thread::send  [tsv::set application importProgress] "StopProgress"
        if { $result == "fail" } {
            return
        }
    }
}

#-------------------------------------------------------------------------------
#  Operations::InsertTree
#
#  Arguments: -
#
#  Results: -
#
#  Description: Inserts the initial node in tree widget
#-------------------------------------------------------------------------------
proc Operations::InsertTree { } {
    global treePath
    global cnCount
    global mnCount
    incr cnCount
    incr mnCount
    global image_dir

    image create photo img_network -file "$image_dir/network.gif"
    $treePath insert end root ProjectNode -text "POWERLINK Network" -open 1 -image img_network
}

#-------------------------------------------------------------------------------
#  Operations::GetNodelistWithName
#  Description : Returns the name list of nodes available in the format (NAME(NODE_ID))
#-------------------------------------------------------------------------------
proc Operations::GetNodelistWithName {} {
    list retNodeIdList
    set retNodeIdList ""
    lappend retNodeIdList "Default(0)"
    set result [openConfLib::GetNodes]
    openConfLib::ShowErrorMessage [lindex $result 0]
    if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
        return $retNodeIdList
    }
    set locNodeIdList [lindex $result 2]

    foreach nodeId $locNodeIdList {
        lappend retNodeIdList [Operations::GetNodeIdWithName $nodeId]
    }
    return $retNodeIdList
}

#-------------------------------------------------------------------------------
#  Operations::GetIdFromFullText
#  Arguments: fullText - Which is similar to - 'Name(Id)'.
#           : type - 0 - Invalid
#                    1 - NodeID
#                    2 - ObjectId
#                    3 - SubObjectId
#  Description : Returns the ID by parsing the fullText depending on the type supplied.
#  Returns     : The Id for the given type.
#-------------------------------------------------------------------------------
proc Operations::GetIdFromFullText { fullText type} {

    switch -- $type {
        0 { # Invalid
            puts "Invalid"
        }
        1 { # NodeId
            set result [regexp {[\(][0-9]+[\)]} $fullText match]
            #puts "Result: $result match: $match"
            set locNodeId [string range $match 1 end-1]
            return $locNodeId
        }
        2 { # Object Id
            set result [regexp {[\(]0[xX][0-9a-fA-F]+[\)]} $fullText match]
            set locIdxId [string range $match 1 end-1]
            return $locIdxId
        }
        3 { # SubObject Id
            set result [regexp {[\(]0[xX][0-9a-fA-F]+[\)]} $fullText match]
            set locSidxId [string range $match 1 end-1]
            return $locSidxId
        }
    }
    return ""
}

#-------------------------------------------------------------------------------
#  Operations::GetNodeIdWithName
#  Arguments: nodeId
#  Description : Returns the name of node for the given nodeId in the format (NAME(NODE_ID))
#-------------------------------------------------------------------------------
proc Operations::GetNodeIdWithName { nodeId } {

    set result [openConfLib::GetNodeParameter $nodeId $::NODENAME]
    if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
        return "\($nodeId\)"
    }
    set nodeName [lindex $result 1]
    return "$nodeName\($nodeId\)"
}

#-------------------------------------------------------------------------------
#  Operations::GetObjectIdWithName
#  Arguments: nodeId      - ID of the node in hex with 0x prefix (Eg: 0xF0)
#             objectId    - ID of the object(Index) in hex with 0x prefix (Eg: 0x1600)
#  Description : Returns the name of object for the given inputs in the format (NAME(ObjectId))
#-------------------------------------------------------------------------------
proc Operations::GetObjectIdWithName { nodeId objectId } {

    set result [openConfLib::GetIndexAttribute $nodeId $objectId $::NAME]
    if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
        return "\($objectId\)"
    }
    set objectName [lindex $result 1]
    return "$objectName\($objectId\)"
}

#-------------------------------------------------------------------------------
#  Operations::GetSubobjectIdWithName
#  Arguments: nodeId      - ID of the node in hex with 0x prefix (Eg: 0xF0)
#             objectId    - ID of the object(Index) in hex with 0x prefix (Eg: 0x1600)
#             subobjectId - ID of the subobject(SubIndex) in hex with 0x prefix (Eg: 0x0A)
#  Description : Returns the name of subobject for the given inputs in the format (NAME(SubobjectId))
#-------------------------------------------------------------------------------
proc Operations::GetSubobjectIdWithName { nodeId objectId subobjectId } {

    set result [openConfLib::GetSubIndexAttribute $nodeId $objectId $subobjectId $::NAME]
    if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
        return "\($subobjectId\)"
    }
    set subobjectName [lindex $result 1]
    return "$subobjectName\($subobjectId\)"
}

#-------------------------------------------------------------------------------
#  Operations::GetIndexListWithName
#
#  Arguments: nodeIdparm  - Node Id of the node for which index list is to be generated
#             pdoTypeparm - PDO mapping type
#
#  Results: mappingidxlist with index id list is returned.
#           Note: Each index id has the 0x prepended for hex notation
#
#  Description: Generates the list of index ids which can be mapped as a pdo object for the given node id in the tree widget
#
#-------------------------------------------------------------------------------
proc Operations::GetIndexListWithName {nodeIdparm pdoTypeparm} {
    global treePath

    # puts "IDX: nodeIdparm:$nodeIdparm pdoTypeparm:$pdoTypeparm"
    #puts "treePath: $treePath"
    list mappingidxlist
    set mappingidxlist ""
    set nodeId ""

    set indexList [WrapperInteractions::GetIndexId $nodeIdparm 3]
    foreach index $indexList {
        set result [openConfLib::GetIndexAttribute $nodeIdparm $index $::OBJECTTYPE]
        if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
            continue
        }
        set idxObjType [lindex $result 1]
        if {[string match -nocase $idxObjType "ARRAY"] || [string match -nocase $idxObjType "RECORD"]} {
            set result [openConfLib::GetSubIndices $nodeIdparm $index ]
            if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
                continue
            }
            set subindexList [lindex $result 2]
            # puts "index:$index  subindexList:$subindexList"
            foreach subIndex $subindexList {
                set result [openConfLib::GetSubIndexAttribute $nodeIdparm $index $subIndex $::PDOMAPPING]
                if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
                    continue
                }
                set sidxPdoMapping [lindex $result 1]

                if { [string match -nocase $pdoTypeparm $sidxPdoMapping] || [string match -nocase $sidxPdoMapping "OPTIONAL"] } {
                    #if we need to check for Access type add your code here
                    set result [openConfLib::GetSubIndexAttribute $nodeIdparm $index $subIndex $::ACCESSTYPE]
                    if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
                        continue
                    }
                    set sidxAccessType [lindex $result 1]

                    if { $sidxAccessType != "" } {
                        set result [openConfLib::GetIndexAttribute $nodeIdparm $index $::NAME]
                        if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
                            continue
                        }
                        set idxName [lindex $result 1]
                        if { [string match -nocase $pdoTypeparm "RPDO"] && ( [string match -nocase $sidxAccessType "RW"] || [string match -nocase $sidxAccessType "WO"] ) } {
                            lappend mappingidxlist "$idxName\($index\)"
                            break
                        } elseif { [string match -nocase $pdoTypeparm "TPDO"] && ( [string match -nocase $sidxAccessType "RW"] || [string match -nocase $sidxAccessType "RO"] ) } {
                            lappend mappingidxlist "$idxName\($index\)"
                            break
                        }
                    }
                } else {
                        #|| [string equal $pdoMapping "DEFAULT"]
                    # no pdo mapping & !pdoTypeparm
                }
            }
        } else {
            set result [openConfLib::GetIndexAttribute $nodeIdparm $index $::PDOMAPPING]
            if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
                continue
            }
            set idxPdoMapping [lindex $result 1]

            if { [string match -nocase $pdoTypeparm $idxPdoMapping] || [string match -nocase $idxPdoMapping "OPTIONAL"] } {
                #if we need to check for Access type add your code here
                set result [openConfLib::GetIndexAttribute $nodeIdparm $index $::ACCESSTYPE]
                if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
                    continue
                }
                set idxAccessType [lindex $result 1]
                if { $idxAccessType != "" } {
                    set result [openConfLib::GetIndexAttribute $nodeIdparm $index $::NAME]
                    if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
                        continue
                    }
                    set idxName [lindex $result 1]
                    if { [string match -nocase $pdoTypeparm "RPDO"] && ([string match -nocase $idxAccessType "RW"] || [string match -nocase $idxAccessType "WO"]) } {
                        lappend mappingidxlist "$idxName\($index\)"
                    } elseif { [string match -nocase $pdoTypeparm "TPDO"] && ([string match -nocase $idxAccessType "RW"] || [string match -nocase $idxAccessType "RO"]) } {
                        lappend mappingidxlist "$idxName\($index\)"
                    }
                }
            } else {
                ## || [string match -nocase $pdoMapping "DEFAULT"]
                # no pdo mapping, !pdoTypeparm & DEFAULT
            }
        }
    }

    #if { [string length $mappingidxlist] < 6 } {
    #    Console::DisplayWarning "No Indices are available in this node for mapping"
    #}
    return $mappingidxlist
}

#-------------------------------------------------------------------------------
#  Operations::GetSubIndexlistWithName
#
#  Arguments: nodeIdparm  - Nodeid of the node for which subindexlist to be generated
#             idxIdparm   - Indexid with 0x for which the subindexlist to be generated
#             pdoTypeparm - PDO mapping type
#
#  Results:  mappingSidxList with Subindex id list is returned.
#       Note: Each index id has the 0x prepended for hex notation
#
#  Description: Generates the list of Subindex id's which are set to pdoMapping same as the pdoTypeparm tree widget
#        for the given node id & indexid
#-------------------------------------------------------------------------------

proc Operations::GetSubIndexlistWithName {nodeIdparm idxIdparm pdoTypeparm} {
    global treePath

    # puts "SIdx: nodeIdparm:$nodeIdparm idxIdparm:$idxIdparm pdoTypeparm:$pdoTypeparm"
    #puts "treePath: $treePath"
    list mappingSidxList
    set mappingSidxList ""
    set nodeId ""

    set result [openConfLib::GetSubIndices $nodeIdparm $idxIdparm ]
    if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
        return $mappingSidxList
    }
    set subindexList [lindex $result 2]

    foreach subIndex $subindexList {
        set subIndex "0x[NoteBookManager::AppendZero [string toupper [format %x $subIndex]] 2]"

        set result [openConfLib::GetSubIndexAttribute $nodeIdparm $idxIdparm $subIndex $::PDOMAPPING]
        if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
            continue
        }
        set sidxPdoMapping [lindex $result 1]

        if { [string match $pdoTypeparm $sidxPdoMapping] || [string match -nocase $sidxPdoMapping "OPTIONAL"] } {
            #if we need to check for Access type add your code here
            set result [openConfLib::GetSubIndexAttribute $nodeIdparm $idxIdparm $subIndex $::ACCESSTYPE]
            if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
                continue
            }
            set sidxAccessType [lindex $result 1]

            if { $sidxAccessType != "" } {
                set result [openConfLib::GetSubIndexAttribute $nodeIdparm $idxIdparm $subIndex $::NAME]
                if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
                    continue
                }
                set sidxName [lindex $result 1]
                if { [string match -nocase $pdoTypeparm "RPDO"] && ( [string match -nocase $sidxAccessType "RW"] || [string match -nocase $sidxAccessType "WO"] ) } {
                    lappend mappingSidxList "$sidxName\($subIndex\)"
                } elseif { [string match -nocase $pdoTypeparm "TPDO"] && ( [string match -nocase $sidxAccessType "RW"] || [string match -nocase $sidxAccessType "RO"] ) } {
                    lappend mappingSidxList "$sidxName\($subIndex\)"
                }
            }
        } else {
                #|| [string equal $pdoMapping "DEFAULT"]
            # no pdo mapping & !pdoTypeparm
        }
    }

    #if { [string length $mappingSidxList] < 4 } {
    #    Console::DisplayWarning "No Subindex are available in the Node:$nodeIdparm Index:$idxIdparm for mapping as a $pdoTypeparm. \n Add sub-Index if not present Or check for the pdomappingtype"
    # }
    return $mappingSidxList
}

#-------------------------------------------------------------------------------
#  Operations::FuncSubIndexLength
#
#  Arguments: nodeIdparm - Nodeid of the node for which lengthlist to be generated
#             idxIdparm  - Indexid with 0x for which the lengthlist to be generated
#             sidxparm   - SubIndexid with 0x for which the lengthlist to be generated
#
#  Results: mappingSidxLength with Subindex id list is returned.
#            Note: Each length has the 0x prepended for hex notation
#
#  Description: Generates the list of Subindex id's Datatype length from the tree widget
#        for the given node id, indexid & subindexid
#-------------------------------------------------------------------------------

proc Operations::FuncSubIndexLength {nodeIdparm idxIdparm sidxparm} {
    global treePath

    # puts "Len: nodeIdparm:$nodeIdparm idxIdparm:$idxIdparm sidxparm:$sidxparm"
    #puts "treePath: $treePath"
    list mappingSidxLength
    set mappingSidxLength "0x0000"
    set nodeId ""

    set result [openConfLib::GetIndexAttribute $nodeIdparm $idxIdparm $::OBJECTTYPE]
    # openConfLib::ShowErrorMessage [lindex $result 0]
    if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
        return $mappingSidxLength
    }
    set idxObjType [lindex $result 1]

    if {[string match -nocase $idxObjType "ARRAY"] || [string match -nocase $idxObjType "RECORD"]} {
        set result [openConfLib::GetSubIndexAttribute $nodeIdparm $idxIdparm $sidxparm $::DATATYPE]
    } else {
        set result [openConfLib::GetIndexAttribute $nodeIdparm $idxIdparm $::DATATYPE]
    }

    openConfLib::ShowErrorMessage [lindex $result 0]
    if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
         return $mappingSidxLength
    }

    set sidxDataType [lindex $result 1]
    if {$sidxDataType == ""} {
        return $mappingSidxLength
    }

    set dtType -1
    switch -nocase $sidxDataType {
        BOOLEAN {set dtType $::BOOLEAN}
        INTEGER8 {set dtType $::INTEGER8}
        INTEGER16 {set dtType $::INTEGER16}
        INTEGER32 {set dtType $::INTEGER32}
        UNSIGNED8 {set dtType $::UNSIGNED8}
        UNSIGNED16 {set dtType $::UNSIGNED16}
        UNSIGNED32 {set dtType $::UNSIGNED32}
        REAL32 {set dtType $::REAL32}
        VISIBLE_STRING {set dtType $::VISIBLE_STRING}
        OCTET_STRING {set dtType $::OCTET_STRING}
        UNICODE_STRING {set dtType $::UNICODE_STRING}
        TIME_OF_DAY {set dtType $::TIME_OF_DAY}
        TIME_DIFF {set dtType $::TIME_DIFF}
        Domain {set dtType $::Domain}
        INTEGER24 {set dtType $::INTEGER24}
        REAL64 {set dtType $::REAL64}
        INTEGER40 {set dtType $::INTEGER40}
        INTEGER48 {set dtType $::INTEGER48}
        INTEGER56 {set dtType $::INTEGER56}
        INTEGER64 {set dtType $::INTEGER64}
        UNSIGNED24 {set dtType $::UNSIGNED24}
        UNSIGNED40 {set dtType $::UNSIGNED40}
        UNSIGNED48 {set dtType $::UNSIGNED48}
        UNSIGNED56 {set dtType $::UNSIGNED56}
        UNSIGNED64 {set dtType $::UNSIGNED64}
        MAC_ADDRESS {set dtType $::MAC_ADDRESS}
        IP_ADDRESS {set dtType $::IP_ADDRESS}
        NETTIME {set dtType $::NETTIME}
    }

    set result [openConfLib::GetDataTypeSize $dtType]
    openConfLib::ShowErrorMessage [lindex $result 0]
    if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
         return $mappingSidxLength
    }
    set datasize [lindex $result 1]
    set tempHexDataSizeBits [string toupper [format %x [expr $datasize * 8 ]]]
    #puts "tempHexDataSizeBits: $tempHexDataSizeBits"

    set mappingSidxLength "0x[NoteBookManager::AppendZero $tempHexDataSizeBits 4]"

    if { [string length $mappingSidxLength] < 6 } {
        Console::DisplayWarning "Length not available for the Subindex in the Node:$nodeIdparm Index:$idxIdparm. \n Add sub-Index if not present Or check for the Datatype mapped"
    }
    return $mappingSidxLength
}

#-------------------------------------------------------------------------------
#  NameSpace Declaration
#
#  namespace : FindSpace
#-------------------------------------------------------------------------------
namespace eval FindSpace {
    variable findList
    variable searchString
    variable searchCount
    variable txtFindDym
    variable findWinStatus
}

#-------------------------------------------------------------------------------
#  FindSpace::ToggleFindWin
#
#  Arguments: -
#
#  Results: -
#
#  Description: Toggles the display of Find window
#-------------------------------------------------------------------------------
proc FindSpace::ToggleFindWin {} {
    if { $FindSpace::findWinStatus == 1 } {
        #find window visible hide it
        FindSpace::EscapeTree
    } else {
        #find window not visible display it
        FindSpace::FindDynWindow
    }
}

#-------------------------------------------------------------------------------
#  FindSpace::FindDynWindow
#
#  Arguments: -
#
#  Results: -
#
#  Description: Displays GUI for Find and add binding for Next button
#-------------------------------------------------------------------------------
proc FindSpace::FindDynWindow {} {
    catch {
        global treeFrame
        pack $treeFrame -side bottom -pady 5
        focus $treeFrame.en_find
        set FindSpace::txtFindDym ""
            set FindSpace::findWinStatus 1
    }
}

#-------------------------------------------------------------------------------
#  FindSpace::EscapeTree
#
#  Arguments: -
#
#  Results: -
#
#  Description: Hides GUI for Find and remove binding for Next button
#-------------------------------------------------------------------------------
proc FindSpace::EscapeTree {} {
    catch {
        global treeFrame
        pack forget $treeFrame
            set FindSpace::findWinStatus 0
    }
}

#-------------------------------------------------------------------------------
#  FindSpace::Find
#
#  Arguments : searchStr - search string
#              node      - node to be refered while searching
#              mode      - indicate mode of searching
#
#  Results : nodes containing search string
#
#  Description : Finds nodes containing search string
#-------------------------------------------------------------------------------
proc FindSpace::Find { searchStr {node ""} {mode 0} } {
    global treePath

    set FindSpace::searchString $searchStr
    set flag 0
    set chk 0
    set prev ""
    set next ""
    if {$searchStr== ""} {
        $treePath selection clear
        return 1
    }
    set mnNode [$treePath nodes ProjectNode]
    foreach tempMn $mnNode {
        if {$tempMn == $node && $mode != 0} {
            if {$mode == "prev"} {
                return $prev
            } else {
                set flag 1
            }
        }
        set childMn [$treePath nodes $tempMn]
        foreach tempChildMn $childMn {
            if {$tempChildMn == $node && $mode != 0} {
                if {$mode == "prev"} {
                    return $prev
                } else {
                    set flag 1
                }
            }
            set idx [$treePath nodes $tempChildMn]
            foreach tempIdx $idx {
                if {$tempIdx == $node && $mode != 0} {
                    if {$mode == "prev"} {
                        return $prev
                    } else {
                        set flag 1
                        set chk 1
                    }
                }
                if {[string match -nocase "PDO*" $tempIdx]} {
                    set childPdo [$treePath nodes $tempIdx]
                    foreach tempPdo $childPdo {
                        if {$tempPdo == $node && $mode != 0} {
                            if {$mode == "prev"} {
                                return $prev
                            } else {
                                set flag 1
                            }
                        }
                        set pdoIdx [$treePath nodes $tempPdo]
                        foreach tempPdoIdx $pdoIdx {
                            if {$tempPdoIdx == $node && $mode != 0} {
                                if {$mode == "prev"} {
                                    return $prev
                                } else {
                                    set flag 1
                                    set chk 1
                                }
                            }
                            if {[string match -nocase "*$searchStr*" [$treePath itemcget $tempPdoIdx -text]] && $chk == 0} {
                                if { $mode == 0 } {
                                    FindSpace::OpenParent $treePath $tempPdoIdx
                                    return 1
                                } elseif {$mode == "prev" } {
                                    set prev $tempPdoIdx
                                } elseif {$mode == "next" } {
                                    if {$flag == 0} {
                                        #do nothing
                                    } elseif {$flag == 1} {
                                        set next $tempPdoIdx
                                        return $next
                                    }
                                }
                            } elseif {$chk == 1} {
                                set chk 0
                            }
                            set pdoSidx [$treePath nodes $tempPdoIdx]
                            foreach tempPdoSidx $pdoSidx {
                                if {$tempPdoSidx == $node && $mode != 0} {
                                    if {$mode == "prev"} {
                                        return $prev
                                    } else {
                                        set flag 1
                                        set chk 1
                                    }
                                }
                                if {[string match -nocase "*$searchStr*" [$treePath itemcget $tempPdoSidx -text]] && $chk == 0} {
                                    if { $mode == 0 } {
                                        FindSpace::OpenParent $treePath $tempPdoSidx
                                        return 1
                                    } elseif {$mode == "prev" } {
                                        set prev $tempPdoSidx
                                    } elseif {$mode == "next" } {
                                        if {$flag == 0} {
                                            #do nothing
                                        } elseif {$flag == 1} {
                                            set next $tempPdoSidx
                                            return $next
                                        }

                                    }
                                } elseif {$chk == 1} {
                                    set chk 0
                                }
                            }
                        }
                    }
                }
                if {[string match -nocase "*$searchStr*" [$treePath itemcget $tempIdx -text]] && $chk == 0} {
                    if { $mode == 0 } {
                        FindSpace::OpenParent $treePath $tempIdx
                        return 1
                    } elseif {$mode == "prev" } {
                        set prev $tempIdx
                    } elseif {$mode == "next" } {
                        if {$flag == 0} {
                            #do nothing
                        } elseif {$flag == 1} {
                            set next $tempIdx
                            return $next
                        }
                    }
                } elseif {$chk == 1} {
                    set chk 0
                }

                set sidx [$treePath nodes $tempIdx]
                foreach tempSidx $sidx {
                    if {$tempSidx == $node && $mode != 0} {
                        if {$mode == "prev"} {
                            return $prev
                        } else {
                            set flag 1
                            set chk 1
                        }
                    }
                    if {[string match -nocase "*$searchStr*" [$treePath itemcget $tempSidx -text]] && $chk == 0} {
                        if { $mode == 0 } {
                            FindSpace::OpenParent $treePath $tempSidx
                            return 1
                        } elseif {$mode == "prev" } {
                            set prev $tempSidx
                        } elseif {$mode == "next" } {
                            if {$flag == 0} {
                                #do nothing
                            } elseif {$flag == 1} {
                                set next $tempSidx
                                return $next
                            }
                        }
                    } elseif {$chk == 1} {
                        set chk 0
                }

            }
        }
            }
    }
    if {$mode == 0} {
        $treePath selection clear
        return 1
    } else {
        $treePath selection clear
        return ""
    }
}

#-------------------------------------------------------------------------------
#  FindSpace::OpenParent
#
#  Arguments: treePath - path to the tree widget
#             node     - node containing search string
#
#  Results: -
#
#  Description: Node is made visible
#-------------------------------------------------------------------------------
proc FindSpace::OpenParent { treePath node } {
    if { [$treePath exists $node ] == 1 } {
        # the node exist in tree continue
    } else {
        return
    }

    $treePath selection clear
    set tempNode $node
    while {[$treePath parent $tempNode] != "ProjectNode"} {
        set tempNode [$treePath parent $tempNode]
        $treePath itemconfigure $tempNode -open 1
    }
    $treePath selection set $node
    $treePath see $node
}

#-------------------------------------------------------------------------------
#  FindSpace::Prev
#
#  Arguments: -
#
#  Results: -
#
#  Description: Displays previous node containing search string
#-------------------------------------------------------------------------------
proc FindSpace::Prev {} {
    global treePath
    set node [$treePath selection get]
    if {![info exists FindSpace::searchString]} {
        return
    }
    if {$node == ""} {
        # if no node is selected find first match
        FindSpace::Find $FindSpace::searchString
    } else {
        set prev [FindSpace::Find $FindSpace::searchString $node prev]
        if { [$treePath exists $prev] == 1 } {
            FindSpace::OpenParent $treePath $prev
        } else {
                #value returned is not a tree node
            }
        return
    }
}

#-------------------------------------------------------------------------------
#  FindSpace::Next
#
#  Arguments: -
#
#  Results: -
#
#  Description: Displays next node containing search string
#-------------------------------------------------------------------------------
proc FindSpace::Next {} {
    global treePath
    set node [$treePath selection get]
    if {![info exists FindSpace::searchString]} {
        return
    }
    if {$node == ""} {
        # if no node is selected find first match
        FindSpace::Find $FindSpace::searchString
    } else {
        set next [FindSpace::Find $FindSpace::searchString $node next]
        if { [$treePath exists $next] == 1 } {
            FindSpace::OpenParent $treePath $next
        } else {
            #value returned is not a tree node
        }
        return
    }
}

#-------------------------------------------------------------------------------
#  Operations::BuildProject
#
#  Arguments: -
#
#  Results: -
#
#  Description: Builds the project and generate cdc and xap files
#-------------------------------------------------------------------------------
proc Operations::BuildProject {} {
    global projectDir
    global projectName
    global st_save
    global st_autogen
    global nodeIdList
    global savedValueList
    global populatedPDOList
    global userPrefList
    global nodeSelect
    global treePath
    global mnCount
    global cnCount
    global f0
    global f1
    global f2
    global f3
    global f4
    global status_save
    global chkPrompt
    global mnPropSaveBtn
    global cnPropSaveBtn
    global build_nodesList

    if {$projectDir == "" || $projectName == "" } {
        Console::DisplayErrMsg "No project to Build"
        return
    }

    if { $chkPrompt == 1 && [$treePath exists $nodeSelect] && ([string match "MN*" $nodeSelect] || [string match "CN*" $nodeSelect]) } {
        if { $st_save == "0"} {
            if { [string match "MN*" $nodeSelect] } {
                $mnPropSaveBtn invoke
            } elseif { [string match "CN*" $nodeSelect] } {
                $cnPropSaveBtn invoke
            } else {
                #must be root, ProjectNode, MN, OBD or CN
            }
            Validation::ResetPromptFlag
        } elseif { $st_save == "1" } {
            set result [tk_messageBox -message "Do you want to save [$treePath itemcget $nodeSelect -text ]?" -parent . -type yesno -icon question]
            switch -- $result {
                yes {
                    #save the value
                    if { [string match "MN*" $nodeSelect] } {
                        $mnPropSaveBtn invoke
                    } elseif { [string match "CN*" $nodeSelect] } {
                        $cnPropSaveBtn invoke
                    } else {
                        #must be root, ProjectNode, MN, OBD or CN
                    }
                }
                no  {#continue}
            }
            Validation::ResetPromptFlag
        } elseif { $st_save == "2" } {

        } else {
            Validation::ResetPromptFlag
        }
    }

    # check that 1006 object of MN actual value is greater than zero
    #API for IfNodeExists
    set mnNodeId 240
    set result [openConfLib::IsExistingNode $mnNodeId]

    set errCycleTimeFlag 0
    if { [Result_IsSuccessful [lindex $result 0]] && [lindex $result 1] } {
        #the node exist continue
        #get the actual value of 1006
        set result [openConfLib::GetIndexAttribute $mnNodeId $Operations::CYCLE_TIME_OBJ $::ACTUALVALUE]
        if {[Result_IsSuccessful [lindex $result 0]]} {
            set cycleTimeValue [lindex $result 1]
            if {$cycleTimeValue != "" } {
                if { ( [expr $cycleTimeValue > 0] == 1) } {
                    #value is greater than zero proceed in building project
                } else {
                    #value is zero
                    set errCycleTimeFlag 1
                    set msg "Value of Index 1006 in MN is 0."
                }
            } else {
                #value is empty
                set errCycleTimeFlag 1
                set msg "Value of Index 1006 in MN is empty."
            }
        } else {
            #some error in getting the actual value
            set errCycleTimeFlag 2
            set msg "Error in getting value of Index 1006 in MN.\nIndex 1006 or MN object dictonary might have been deleted"
        }
    } else {
        #mn node doesnot exist
        set errCycleTimeFlag 2
        set msg "MN node doesnot exist"
    }

    if { $errCycleTimeFlag > 0 } {
        if {$errCycleTimeFlag == 2} {
            tk_messageBox -message "$msg" -icon warning -title "Warning" -parent .
            return
        } elseif {$errCycleTimeFlag == 1} {
            # Initialize the default Cycle time to 50ms
            set defaultCycleTimeValue 50000

            # Read the default value from the library.
            set result [openConfLib::GetIndexAttribute $mnNodeId $Operations::CYCLE_TIME_OBJ $::DEFAULTVALUE]
            if {[Result_IsSuccessful [lindex $result 0]]} {
                set defaultCycleTimeValue [lindex $result 1]
                if { $defaultCycleTimeValue == "" } {
                    set defaultCycleTimeValue 50000
                }
            }

            set result [tk_messageBox -message "$msg\nDo you want to set the default value $defaultCycleTimeValue �s" -type yesno -icon info -title "Information" -parent .]
            switch -- $result {
                yes {
                        #hard code the value 50000 for 1006 object in MN
                        set result [openConfLib::SetIndexActualValue $mnNodeId $Operations::CYCLE_TIME_OBJ $defaultCycleTimeValue]
                        openConfLib::ShowErrorMessage $result
                        if { [Result_IsSuccessful $result] != 1 } {
                            return
                        }
                    }
                no  {
                        #open the 1006 object of mn which would be the first node to obtain
                        FindSpace::Find "(0x1006)"
                        set node [$treePath selection get]
                        if {[$treePath exists $node] == 1} {
                            #calll single click node
                            Operations::SingleClickNode $node
                        }
                        return
                    }
            }
        }
    }

    if { $st_autogen == 1 } {
        set result [tk_messageBox -message "Auto Generate is set to yes in project settings\nUser edited values for MN will be lost\nDo you want to Build Project?" -type yesno -icon question -title "Question" -parent .]
        switch -- $result {
            yes {
                #continue
            }
            no {
                return
            }
        }
    }

    set outputDir [file join $projectDir output]
    if { [file isdirectory $projectDir] && ![file isdirectory $outputDir] } {
        catch {file mkdir [file join $projectDir output]}
    }

    thread::send [tsv::get application importProgress] "StartProgress"
    set result [openConfLib::GenerateStackConfiguration $outputDir ""]
    openConfLib::ShowErrorMessage $result
    if { [Result_IsSuccessful $result] != 1 } {
        if { [ string is ascii [Result_GetErrorString $result] ] } {
            set msg "Code:[Result_GetErrorCode $result] Msg:[Result_GetErrorString $result]"
        } else {
            set msg "Code:[Result_GetErrorCode $result] Msg:Unknown Error"
        }
        Console::DisplayErrMsg $msg error
        thread::send [tsv::get application importProgress] "StopProgress"
        return
    } else {
        #TODO handle exception for exceeding the limit of number of channels.(ERRCODE 49)
        set build_nodesList ""
        set buildCN_result ""
        set buildCN_nodeId ""
        foreach mnNode [$treePath nodes ProjectNode] {
            set chk 1
            foreach cnNode [$treePath nodes $mnNode] {
                if {$chk == 1} {
                    if {[string match "OBD*" $cnNode]} {
                        #Nothing to do for MN
                    } else {
                        set buildCN_result [Operations::GetNodeIdType $cnNode]
                    }
                    set chk 0
                } else {
                        set buildCN_result [Operations::GetNodeIdType $cnNode]
                }
                if {$buildCN_result != -1 } {
                    set buildCN_nodeId $buildCN_result
                    #lappend build_nodesList $buildCN_nodeId
                    set build_nodesList [linsert $build_nodesList end $buildCN_nodeId]
                    #puts "Insert: $build_nodesList"
                }
            }
        }

        set tempPjtDir $projectDir
        set tempPjtName $projectName
        set tempSt_save $st_save
        set tempSt_autogen $st_autogen
        Operations::ResetGlobalData
        set projectDir $tempPjtDir
        set projectName $tempPjtName
        set st_save $tempSt_save
        set st_autogen $tempSt_autogen

        Operations::RePopulate $projectDir [string range $projectName 0 end-[string length [file extension $projectName] ] ]

        set result [openConfLib::GenerateProcessImageDescription $::C $outputDir "xap.h"]
        openConfLib::ShowErrorMessage $result
        if { [Result_IsSuccessful $result] != 1 } {
            if { [ string is ascii [Result_GetErrorString $result] ] } {
                set msg "Code:[Result_GetErrorCode $result] Msg1:[Result_GetErrorString $result]"
            } else {
                set msg "Code:[Result_GetErrorCode $result] Msg:Unknown Error"
            }
            Console::DisplayErrMsg $msg error
            thread::send [tsv::get application importProgress] "StopProgress"
            return
        }

        set result [openConfLib::GenerateProcessImageDescription $::CSHARP $outputDir "ProcessImage.cs"]
        openConfLib::ShowErrorMessage $result
        if { [Result_IsSuccessful $result] != 1 } {
            if { [ string is ascii [Result_GetErrorString $result] ] } {
                set msg "Code:[Result_GetErrorCode $result] Msg2:[Result_GetErrorString $result]"
            } else {
                set msg "Code:[Result_GetErrorCode $result] Msg:Unknown Error"
            }
            Console::DisplayErrMsg $msg error
            thread::send [tsv::get application importProgress] "StopProgress"
            return
        }

        set result [openConfLib::GenerateProcessImageDescription $::XML $outputDir "xap.xml"]
        openConfLib::ShowErrorMessage $result
        if { [Result_IsSuccessful $result] != 1 } {
            if { [ string is ascii [Result_GetErrorString $result] ] } {
                set msg "Code:[Result_GetErrorCode $result] Msg3:[Result_GetErrorString $result]"
            } else {
                set msg "Code:[Result_GetErrorCode $result] Msg:Unknown Error"
            }
            Console::DisplayErrMsg $msg error
            thread::send [tsv::get application importProgress] "StopProgress"
            return
        } else {
            Console::DisplayInfo "files mnobd.txt, mnobd.cdc, xap.xml, xap.h, ProcessImage.cs are generated at location [file join $projectDir output]"
            thread::send  [tsv::set application importProgress] "StopProgress"
        }
        #project is built need to save
        set status_save 1
    }
}

#-------------------------------------------------------------------------------
#  Operations::CleanProject
#
#  Arguments: -
#
#  Results: -
#
#  Description: Deletes cdc and xap related files in project
#-------------------------------------------------------------------------------
proc Operations::CleanProject {} {
    global projectDir
    global projectName

    if { $projectDir == "" || $projectName == "" } {
        return
    }
    set cleanMsg ""
    foreach tempFile [list mnobd.txt mnobd.cdc xap.xml xap.h ProcessImage.cs] {
        set CleanFile [file join $projectDir output $tempFile]
        if {[file exists [file join $projectDir output $tempFile]]} {
            catch {file delete -force -- $CleanFile}
            set cleanMsg "$cleanMsg $tempFile"
        }
    }
    if { $cleanMsg != "" } {
        Console::DisplayInfo "files$cleanMsg at [file join $projectDir output] are deleted"
    }
}

#-------------------------------------------------------------------------------
#  Operations::ReImport
#
#  Arguments: -
#
#  Results: -
#
#  Description: Imports XDC/XDD file for MN or CN
#-------------------------------------------------------------------------------
proc Operations::ReImport {} {
    global treePath
    global nodeIdList
    global status_save
    global lastXD
    global f0
    global f1
    global f2
    global f3
    global f4
    global image_dir

    set node [$treePath selection get]
    #gets the nodeId of selected node
    set result [Operations::GetNodeIdType $node]
    if {$result != -1 } {
        set nodeId $result
    } else {
        return
    }

    set cursor [. cget -cursor]
    set types {
            {{XDC/XDD Files} {.xd*} }
            {{XDD Files}     {.xdd} }
        {{XDC Files}     {.xdc} }
    }

    if {![file isdirectory $lastXD] && [file exists $lastXD] } {
        set tmpImpDir [tk_getOpenFile -title "Import XDC/XDD" -initialfile $lastXD -filetypes $types -parent .]
    } else {
        set tmpImpDir [tk_getOpenFile -title "Import XDC/XDD" -filetypes $types -parent .]
    }

    if {$tmpImpDir != ""} {
        set lastXD $tmpImpDir

        set result [tk_messageBox -message "Do you want to Import $tmpImpDir?" -type yesno -icon question -title "Question" -parent .]
         switch -- $result {
             yes {
               Console::DisplayInfo "Importing file $tmpImpDir for Node ID : $nodeId"
             }
             no  {
               Console::DisplayInfo "Importing $tmpImpDir is cancelled for Node ID : $nodeId"
               return
             }
        }

        set result [openConfLib::ReplaceXdd $nodeId [file dirname $tmpImpDir] [file tail $tmpImpDir]]
        openConfLib::ShowErrorMessage $result
        if { [Result_IsSuccessful $result] != 1 } {
            return
        } else {
            Console::DisplayInfo "Imported file $tmpImpDir for Node ID:$nodeId"
        }

        Operations::RemoveAllFrames
        #xdc/xdd is reimported need to save
        set status_save 1

        catch {
            #only in expert mode when there is no OBD icon then insert the it
            if { ($res == -1) && ([string match "EXPERT" $Operations::viewType ] == 1) } {
                #there can be one OBD in MN so -1 is hardcoded
                image create photo img_pdo -file "$image_dir/pdo.gif"
                $treePath insert 0 MN$tmpNode OBD$tmpNode-1 -text "OBD" -open 0 -image img_pdo
            }
        }
        Operations::RemoveAllFrames

        Operations::CleanList $node 0
        Operations::CleanList $node 1
        catch {$treePath delete [$treePath nodes $node]}
        catch {$treePath itemconfigure $node -open 0}

        thread::send  [tsv::set application importProgress] "StartProgress"
        set result [WrapperInteractions::Import $node $nodeId]
        thread::send  [tsv::set application importProgress] "StopProgress"

    }
}

#-------------------------------------------------------------------------------
#  Operations::DeleteTreeNode
#
#  Arguments: -
#
#  Results: -
#
#  Description: Deletes a node in the tree
#-------------------------------------------------------------------------------
proc Operations::DeleteTreeNode {} {
    global treePath
    global nodeIdList
    global savedValueList
    global userPrefList
    global status_save
    global build_nodesList
    global image_dir

    set node [$treePath selection get]

    if { [string match "ProjectNode" $node] || [string match "PDO*" $node]|| [string match "?PDO*" $node] \
        || [string match "MN*" $node] || [string match "OBD*" $node]} {
        #should not delete when pjt, mn, pdo, tpdo or rpdo is selected
        return
    }
    #gets the nodeId and Type of selected node
    set result [Operations::GetNodeIdType $node]
    if {$result != -1 } {
        set nodeId $result
    } else {
        return
    }

    set nodeList ""
    set nodeList [Operations::GetNodeList]
    # puts "nodeList:$nodeList"
    if { ([lsearch -exact $nodeList $node ]!= -1) } {
        set result [tk_messageBox -message "Do you want to delete node?" -type yesno -icon question -title "Question" -parent .]
        switch -- $result {
             yes {
                 #continue with process
            }
             no {
                 return
            }
        }

        thread::send [tsv::get application importProgress] "StartProgress"
        #it is a CN so delete the node entirely
        set result [openConfLib::DeleteNode $nodeId]
        openConfLib::ShowErrorMessage $result
        if { [Result_IsSuccessful $result] == 0 } {
            thread::send [tsv::get application importProgress] "StopProgress"
            return
        }

        #node is deleted need to save
        set status_save 1

        set nodeIdList [Operations::DeleteList $nodeIdList $nodeId 0]
        #    #to clear the list from child of the node from saved value list
        Operations::CleanList $node 0
        Operations::CleanList $node 1
    } else {
        return
    }

    #clear the savedValueList of the deleted node
    catch { set savedValueList [Operations::DeleteList $savedValueList $node 0] }
    catch { set userPrefList [Operations::DeleteList $userPrefList $node 1] }

    #index or subindex is deleted need to save
    set status_save 1

    set parent [$treePath parent $node]
    set nxtSelList [$treePath nodes $parent]
# puts "parent:$parent  nxtSelList:$nxtSelList"
    # to highlight the next logical node after the deleted node
# puts "llenth: [llength $nxtSelList]"

    if {[llength $nxtSelList] == 1} {
        #it is the only node so select parent
        $treePath selection set $parent
        catch {$treePath delete $node}
        Validation::ResetPromptFlag
        Operations::SingleClickNode $parent
    } else {
        set nxtSelCnt [expr [lsearch $nxtSelList $node]+1]
#puts "nxtSelCnt:$nxtSelCnt"
        if {$nxtSelCnt >= [llength $nxtSelList]} {
            #it is the last node select previous node
            set nxtSelCnt [expr $nxtSelCnt-2]
        } elseif { $nxtSelCnt > 0 } {
            #select next node since nxtSelCnt already incremented do nothing
        } else {
        }

        catch {set nxtSel [lindex $nxtSelList $nxtSelCnt] }
        # puts "nxtSel:$nxtSel"
        catch {$treePath selection set $nxtSel}
        catch {$treePath delete $node}
        #should display logical next node after deleting currently highlighted node
        Validation::ResetPromptFlag
        Operations::SingleClickNode $nxtSel
    }
    thread::send [tsv::get application importProgress] "StopProgress"
}

#-------------------------------------------------------------------------------
#  Operations::DeleteList
#
#  Arguments: tempList  - List in which value to be deleted
#             deleteVar - Value to be deleted
#             choice    - To indicate sent list
#
#  Results: list with deleted value
#
#  Description: Deletes variable if present in list
#-------------------------------------------------------------------------------
proc Operations::DeleteList {tempList deleteVar choice} {
    if { $choice == 0 } {
        set res [lsearch $tempList $deleteVar]
    } elseif { $choice == 1 } {
        set res [lsearch $tempList [list $deleteVar *]]
    } else {

    }
    if {$res != -1} {
        if {$res == 0} {
            set resList [lrange $tempList 1 end]
            return $resList
        } else {
            set resList [lrange $tempList 0 [expr $res-1] ]
            foreach tempVar [lrange $tempList [expr $res+1] end ] {
                lappend resList $tempVar
            }
            return $resList
        }
    }
    return $tempList
}

#-------------------------------------------------------------------------------
#  Operations::CleanList
#
#  Arguments: node   - Node to be deleted
#             choice - To indicate sent list
#
#  Results: -
#
#  Description: Deletes node in savedValueList and userPrefList according to choice
#-------------------------------------------------------------------------------
proc Operations::CleanList {node choice} {
    global savedValueList
    global userPrefList

    if { $choice == 0 } {
        set tempList $savedValueList
    } elseif { $choice == 1 } {
        set tempList $userPrefList
    } else {
        #invalid choice
        return
    }
    set tempFinalList ""
    set matchNode [split $node -]
    set matchNode [lrange $matchNode 1 end]
    set matchNode [join $matchNode -]
    foreach tempValue $tempList {
        if { $choice == 0 } {
            set testValue $tempValue
        } else {
            set testValue [lindex $tempValue 0]
        }

        if {[string match "*SubIndexValue*" $testValue]} {
            set tempMatchNode *-$matchNode-*-*
        } elseif {[string match "*IndexValue*" $testValue]} {
            set tempMatchNode *-$matchNode-*
        } else {
            #other than IndexValue and SubIndexValue no node should occur
            continue
        }
        if {[string match $tempMatchNode $testValue]} {
            #matched so dont copy it
        } else {
            lappend tempFinalList $tempValue
        }
    }

    if { $choice == 0 } {
        set savedValueList $tempFinalList

    } else {
        set userPrefList $tempFinalList
    }
}

#-------------------------------------------------------------------------------
#  Operations::GetNodeList
#
#  Arguments: -
#
#  Results: list containing nodes of MN and CN from tree widget
#
#  Description: Creates a node with given data
#-------------------------------------------------------------------------------
proc Operations::GetNodeList {} {
    global treePath

    set nodeList ""
    foreach treeObj [$treePath nodes Network-1] {
        lappend nodeList $treeObj
    }
    return $nodeList
}

#-------------------------------------------------------------------------------
#  Operations::GetNodeIdType
#
#  Arguments: node - Node of tree widget for which id and type is to be found
#
#  Results: node id and node type
#
#  Description: Returns the node id and node type for the node from tree widget
#-------------------------------------------------------------------------------
proc Operations::GetNodeIdType {nodeTree} {
    global treePath

    if {[string match "Network-1" $nodeTree] || [string match "ProjectNode" $nodeTree] } {
        return -1
    } elseif {[string match "MN-*" $nodeTree] || [string match "CN-*" $nodeTree]} {
        set parent $nodeTree
    } elseif {[string match "Mapping*" $nodeTree] || [string match "OBD-*" $nodeTree]} {
        set parent [$treePath parent $nodeTree]
    } elseif {[string match "?PDO-*" $nodeTree]} {
        set parent [$treePath parent $nodeTree]
        set parent [$treePath parent $parent]
    } elseif {[string match "?PDONode-*" $nodeTree]} {
        set parent [$treePath parent $nodeTree]
        set parent [$treePath parent $parent]
        set parent [$treePath parent $parent]
    } elseif {[string match "IndexValue-*" $nodeTree] } {
        set parent [$treePath parent $nodeTree]
        set parent [$treePath parent $parent]
    } elseif { [string match "SubIndexValue-*" $nodeTree]} {
        set parent [$treePath parent $nodeTree]
        set parent [$treePath parent $parent]
        set parent [$treePath parent $parent]
    } else {
        return -1
    }

    set name [$treePath itemcget $parent -text]
    # puts "name:$name"
    set result [regexp {[\(][0-9]+[\)]} $name match]
    # puts "Result: $result match: $match"
    set locNodeId [string range $match 1 end-1]
    # puts "$locNodeId"
    return $locNodeId
}

#-------------------------------------------------------------------------------
#  Operations::ArrowUp
#
#  Arguments: -
#
#  Results: -
#
#  Description: Traverse the tree widget for up arrow key
#-------------------------------------------------------------------------------
proc Operations::ArrowUp {} {
    global treePath
    set node [$treePath selection get]
    if { $node == "" || $node == "root" || $node == "ProjectNode" } {
        $treePath selection set "ProjectNode"
        $treePath see "ProjectNode"
        return
    }
    set parent [$treePath parent $node]
    set siblingList [$treePath nodes $parent]
    set cnt [lsearch -exact $siblingList $node]
    if { $cnt == 0} {
        #there is no node before it so select parent
        $treePath selection set $parent
        $treePath see $parent
    } else {
        set sibling  [lindex $siblingList [expr $cnt-1] ]
        if {[$treePath itemcget $sibling -open] == 0 || ( [$treePath itemcget $sibling -open] == 1 && [$treePath nodes $sibling] == "" )} {
            $treePath selection set $sibling
            $treePath see $sibling
            return
        } else {
            set siblingList [$treePath nodes $sibling]
            if {[$treePath itemcget [lindex $siblingList end] -open] == 1 && [$treePath nodes [lindex $siblingList end] ] != "" } {
                Operations::_ArrowUp [lindex $siblingList end]
            } else {
                $treePath selection set [lindex $siblingList end]
                $treePath see [lindex $siblingList end]
                return
            }
        }
    }
}

#-------------------------------------------------------------------------------
#  Operations::_ArrowUp
#
#  Arguments: node - Parent node of node to be highlighted
#
#  Results: -
#
#  Description: Highlights the node for up arrow key
#-------------------------------------------------------------------------------
proc Operations::_ArrowUp {node} {
    global treePath

    if {[$treePath itemcget $node -open] == 0 || ( [$treePath itemcget $node -open] == 1 && [$treePath nodes $node] == "" )} {
        $treePath selection set $node
        $treePath see $node
        return
    } else {
        set siblingList [$treePath nodes $node]
        if {[$treePath itemcget [lindex $siblingList end] -open] == 1 && [$treePath nodes [lindex $siblingList end] ] != "" } {
            Operations::_ArrowUp [lindex $siblingList end]
        } else {
            $treePath selection set [lindex $siblingList end]
            $treePath see [lindex $siblingList end]
            return
        }
    }
}

#-------------------------------------------------------------------------------
#  Operations::ArrowDown
#
#  Arguments: -
#
#  Results: -
#
#  Description: Traverse the tree widget for down arrow key
#-------------------------------------------------------------------------------
proc Operations::ArrowDown {} {
    global treePath

    set node [$treePath selection get]
    if { $node == "" || $node == "root" } {
        return
    }
    if {[$treePath itemcget $node -open] == 0 || ( [$treePath itemcget $node -open] == 1 && [$treePath nodes $node] == "" )} {
        set parent [$treePath parent $node]
        set siblingList [$treePath nodes $parent]
        set cnt [lsearch -exact $siblingList $node]
        if { $cnt == [expr [llength $siblingList]-1 ]} {
            Operations::_ArrowDown $parent $node
        } else {
            $treePath selection set [lindex $siblingList [expr $cnt+1] ]
            $treePath see [lindex $siblingList [expr $cnt+1] ]
            return
        }
    } else {
        set siblingList [$treePath nodes $node]
        $treePath selection set [lindex $siblingList 0]
        $treePath see [lindex $siblingList 0]
        return
    }
}

#-------------------------------------------------------------------------------
#  Operations::_ArrowDown
#
#  Arguments: node     - Parent node of node to be highlighted
#             origNode - Selected node
#  Results: -
#
#  Description: Highlights the node for down arrow key
#-------------------------------------------------------------------------------
proc Operations::_ArrowDown {node origNode} {
    global treePath
    if { $node == "root" } {
        $treePath selection set $origNode
        $treePath see $origNode
        return
    }
    set parent [$treePath parent $node]

    set siblingList [$treePath nodes $parent]
    set cnt [lsearch -exact $siblingList $node]
    if { $cnt == [expr [llength $siblingList]-1 ] } {
        Operations::_ArrowDown $parent $origNode
    } else {
        $treePath selection set [lindex $siblingList [expr $cnt+1] ]
        $treePath see [lindex $siblingList [expr $cnt+1] ]
        return
    }
}

#-------------------------------------------------------------------------------
#  Operations::ArrowLeft
#
#  Arguments: -
#
#  Results: -
#
#  Description: Collapse the highlighted node
#-------------------------------------------------------------------------------
proc Operations::ArrowLeft {} {
    global treePath
    set node [$treePath selection get]
    if { ([$treePath exists $node]) && ([$treePath nodes $node] != "") } {
        $treePath itemconfigure $node -open 0
    } else {
        # it has no child no need to collapse
    }
}

#-------------------------------------------------------------------------------
#  Operations::ArrowRight
#
#  Arguments: -
#
#  Results: -
#
#  Description: Expands the highlighted node
#-------------------------------------------------------------------------------
proc Operations::ArrowRight {} {
    global treePath
    set node [$treePath selection get]
    if { ([$treePath exists $node]) && ([$treePath nodes $node] != "") } {
        $treePath itemconfigure $node -open 1
    } else {
        # it has no child no need to expand
    }
}

#-------------------------------------------------------------------------------
#  Operations::AutoGenerateMNOBD ---- This function is currently deprecated shall
#                                      be used for AutoGenerate MN obd sub menu
#  Arguments: -
#  Results: -
#  Description: Auto generates object dictionary for MN and populates the tree.
#-------------------------------------------------------------------------------
#proc Operations::AutoGenerateMNOBD {} {
#    global treePath
#    global nodeIdList
#    global status_save
#    global f0
#    global f1
#    global f2
#    global image_dir
#
#    set node [$treePath selection get]
#    if {[string match "MN*" $node]} {
#        set child [$treePath nodes $node]
#        set tmpNode [string range $node 2 end]
#        set node OBD$tmpNode-1
#        set res [lsearch $child "OBD$tmpNode-1*"]
#        set nodeId 240
#        set nodeType 0
#        set result [tk_messageBox -message "Do you want to Auto Generate object dictionary for MN?" -type yesno -icon question -title "Question" -parent .]
#        switch -- $result {
#            yes {
#              Console::DisplayInfo "Auto Generating object dictionary for MN"
#            }
#            no  {
#              Console::DisplayInfo "Auto Generation of object dictionary is cancelled for MN"
#              return
#            }
#        }
#        set catchErrCode [GenerateMNOBD]
#        set ErrCode [ocfmRetCode_code_get $catchErrCode]
#        if { $ErrCode != 0 } {
#            if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
#                tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error -parent .
#            } else {
#                tk_messageBox -message "Unknown Error" -title Error -icon error -parent .
#            }
#            return
#        }
#
#        #OBD for MN is auto generated need to save
#        set status_save 1
#
#        catch {
#            if { ($res == -1) && ( [string match "EXPERT" $Operations::viewType ] == 1 ) } {
#                #there can be one OBD in MN so -1 is hardcoded insert the OBD icon only for expert view
#                image create photo img_pdo -file "$image_dir/pdo.gif"
#                $treePath insert 0 MN$tmpNode OBD$tmpNode-1 -text "OBD" -open 0 -image img_pdo
#            }
#        }
#        catch {$treePath delete [$treePath nodes OBD$tmpNode-1]}
#        catch {$treePath itemconfigure $node -open 0}
#
#        thread::send  [tsv::set application importProgress] "StartProgress"
#        set result [WrapperInteractions::Import $node $nodeId]
#        thread::send  [tsv::set application importProgress] "StopProgress"
#        if { $result == "fail" } {
#            return
#        }
#        #to clear the list from child of the node from savedvaluelist and userpreflist
#        Operations::CleanList $node 0
#        Operations::CleanList $node 1
#
#    }
#}

#-------------------------------------------------------------------------------
#  Operations::GenerateAutoName
#
#  Arguments: dir  - Directory in which name of file is auto generated
#             name - Default file name for which unique file name is generated
#             ext  - Extension of the file
#
#  Results: auto generated file name
#
#  Description: Generates unique file name in the path
#-------------------------------------------------------------------------------
proc Operations::GenerateAutoName {dir name ext} {
    #should check for extension but should send back unique name without extension
    for {set loopCount 1} {1} {incr loopCount} {
        set autoName $name$loopCount$ext
        if {![file exists [file join $dir $autoName]]} {
            break;
        }
    }
    return $name$loopCount
}

#-------------------------------------------------------------------------------
#  Operations::GenerateCycleNo
#
#  Arguments: prescalLimit - Upper limit of prescaler value
#
#  Results: auto generated file name
#
#  Description: Generates unique file name in the path
#-------------------------------------------------------------------------------
proc Operations::GenerateCycleNo {prescalLimit} {
    #should check for extension but should send back unique name without extension
    set cycleNoList ""
    for {set loopCount 1} {$loopCount <= $prescalLimit} {incr loopCount} {
        lappend cycleNoList $loopCount
    }
    return $cycleNoList
}

#-------------------------------------------------------------------------------
#  Operations::Uniqkey
#
#  Arguments: -
#
#  Results: -
#
#  Description: Calculates clock seconds
#-------------------------------------------------------------------------------
proc Operations::Uniqkey { } {
     set key   [ expr { pow(2,31) + [ clock clicks ] } ]
     set key   [ string range $key end-8 end-3 ]
     set key   [ clock seconds ]$key
     return $key
}

#-------------------------------------------------------------------------------
#  Operations::Sleep
#
#  Arguments : ms - time to sleep
#
#  Results : -
#
#  Description : Provides a sleep functionality to tcl
#-------------------------------------------------------------------------------
proc Operations::Sleep { ms } {
     set uniq [ Operations::Uniqkey ]
     set ::__sleep__tmp__$uniq 0
     after $ms set ::__sleep__tmp__$uniq 1
     vwait ::__sleep__tmp__$uniq
     unset ::__sleep__tmp__$uniq
}

#-------------------------------------------------------------------------------
#  Operations::ViewModeChanged
#
#  Arguments: -
#
#  Results: -
#
#  Description: Rebuilds the tree when view is changed
#-------------------------------------------------------------------------------
proc Operations::ViewModeChanged {} {
    global projectDir
    global projectName
    global lastVideoModeSel
    global st_viewType
    global status_save

    # puts "projectDir:$projectDir projectName:$projectName lastVideoModeSel:$lastVideoModeSel st_viewType:$st_viewType"

    if { $projectDir == "" || $projectName == "" } {
        return
    }

    if { $Operations::viewType == "EXPERT" } {
        set tempViewType 1
    } else {
        set tempViewType 0
    }
    #check if the view is toggled
    if {$lastVideoModeSel == $tempViewType} {
        return
    }

    if { ($st_viewType == 0) && ($tempViewType == 1) } {
        set result [ tk_messageBox -message "Internal know-how of POWERLINK is recommended when using advanced mode.\
        \nAre you sure you want to change view?" -type yesno -icon info -title "Information" -parent . ]
        switch -- $result {
            yes {
                set Operations::viewType "EXPERT"
            }
            no {
                set Operations::viewType "SIMPLE"
                return
            }
        }
    }

    set st_viewType $tempViewType

    set result [openConfLib::SetActiveView $st_viewType]
    openConfLib::ShowErrorMessage $result
    if { [Result_IsSuccessful $result] != 1 } {
        if { $tempViewType == 1 } {
            set Operations::viewType "SIMPLE"
        } else {
            set Operations::viewType "EXPERT"
        }

        set st_viewType $lastVideoModeSel
        return
    } else {
        set lastVideoModeSel $tempViewType
    }

    set status_save 1
    #remove all the frames
    Operations::RemoveAllFrames
    #rebuild the tree
    thread::send [tsv::set application importProgress] "StartProgress"
    Operations::RePopulate $projectDir [string range $projectName 0 end-[string length [file extension $projectName] ] ]
    thread::send  [tsv::set application importProgress] "StopProgress"
}


#-------------------------------------------------------------------------------
#  Operations::SetVideoType
#
#  Arguments: videoMode - Pointer of enum ViewMode
#
#  Results: -
#
#  Description: Sets the view radio buttons based on the viewmode value from API
#-------------------------------------------------------------------------------
proc Operations::SetVideoType {videoMode} {

    if { $videoMode == 1} {
        set Operations::viewType "EXPERT"
    } else {
        set Operations::viewType "SIMPLE"
    }
}

#-------------------------------------------------------------------------------
#  Operations::RemoveAllFrames
#
#  Arguments: -
#
#  Results: -
#
#  Description: Removes all the property frames
#-------------------------------------------------------------------------------
proc Operations::RemoveAllFrames {} {
    global f0
    global f1
    global f2
    global f3
    global f4
    global f5

    #focusing the name entry box while removing all the frames
    #as a fix due to triggerring of focusout events of entry boxes
    catch { focus [lindex $f0 1].en_nam1 }
    catch { focus [lindex $f1 1].en_nam1 }

    pack forget [lindex $f0 0]
    pack forget [lindex $f1 0]
    pack forget [lindex $f2 0]
    [lindex $f2 1] cancelediting
    [lindex $f2 1] configure -state disabled
    pack forget [lindex $f3 0]
    pack forget [lindex $f4 0]
    pack forget [lindex $f5 0]
    [lindex $f5 1] cancelediting
    [lindex $f5 1] configure -state disabled
}
