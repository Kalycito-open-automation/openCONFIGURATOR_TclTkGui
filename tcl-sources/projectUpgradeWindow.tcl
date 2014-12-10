################################################################################
# \file   ProjectUpgradeWindow.tcl
#
# \brief  The project upgrade window and its procedures.
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

namespace eval ProjectUpgradeWindow {

}

#-------------------------------------------------------------------------------
#  ProjectUpgradeWindow::InitConversion
#  Description: Initiates the project upgrade process.
#               octProjectFile - Path of the project file.
#-------------------------------------------------------------------------------
proc ProjectUpgradeWindow::InitConversion { octProjectFile } {

    set result [tk_messageBox -message "It is detected that this project has been created with old versions of openCONFIGURATOR.\nDo you want to upgrade it to the new format?" -type yesno -icon question -title "Question" -parent .]
    switch -- $result {
         yes {
            set result [openConfProjectUpgradeLib::ImportProjectFile $octProjectFile]
            openConfProjectUpgradeLib::ShowErrorMessage [lindex $result 0]
            if { ![ProjectUpgrade_Result_IsSuccessful [lindex $result 0]] } {
                return
            }
            ## Open the converter window
            ProjectUpgradeWindow::OpenConverterWindow $octProjectFile
        }
         no  {
            Console::DisplayInfo "Project upgrade has been cancelled" info
            return
        }
    }
}

#-------------------------------------------------------------------------------
#  ProjectUpgradeWindow::OpenConverterWindow
#  Description: Opens the conversion windows with the list of nodes and path.
#               octProjectFile - Path of the project file.
#-------------------------------------------------------------------------------
proc ProjectUpgradeWindow::OpenConverterWindow { octProjectFile } {
    global rootDir
    global converterWindow
    global btnConvert
    global footerFrame
    global upgradePath
    global image_dir

    set upgradePath [file dirname $octProjectFile]

    set converterWindow .converterWindow
    catch "destroy $converterWindow"
    toplevel     $converterWindow
    wm title     .converterWindow "Project converter window"
    wm resizable $converterWindow 1 1
    wm deiconify $converterWindow

    wm minsize .converterWindow 800 400

    grab $converterWindow

    #
    # Create the font TkFixedFont if not yet present
    #
    catch {font create TkFixedFont -family Courier -size -12}

    #
    # Create an image to be displayed in buttons embedded in a tablelist widget
    #
    image create photo openImg -file "$image_dir/folder.gif"

    catch "font delete custom1"
    font create custom1 -size 9 -family TkDefaultFont

    #
    # Create a vertically scrolled tablelist widget with 5
    # dynamic-width columns and interactive sort capability
    #
    set tf [ttk::frame $converterWindow.tf -class ScrollArea]
    set tbl $tf.tbl
    set vsb $tf.vsb
    set hsb $tf.hsb
    tablelist::tablelist $tbl \
        -columns {0 "Node ID"        center
                  0 "Name"           center
                  0 "Current Configuration (.octx) Path"      center
                  0 "Select the factory configuration file(XDD/XDC) instead"   center } \
        -yscrollcommand [list $vsb set] -width 0 \
        -xscrollcommand [list $hsb set] -width 0 \
        -spacing 10 \
        -showseparators 1 \
        -stripebackground gray98 \
        -setgrid 0 -width 0 \
        -resizable 1 -movablecolumns 0 -movablerows 0 \
        -font custom1

    $tbl columnconfigure 0 -name nodeId -sortmode integer
    $tbl columnconfigure 1 -name name
    $tbl columnconfigure 2 -name octxPath
    $tbl columnconfigure 3 -name xddPath
    ttk::scrollbar $vsb -orient vertical -command [list $tbl yview]
    ttk::scrollbar $hsb -orient horizontal -command [list $tbl xview]

    #
    # Manage the widgets
    #
    grid $tbl -row 0 -rowspan 2 -column 0 -sticky news
    grid $vsb -row 0 -rowspan 2 -column 1 -sticky ns
    grid $hsb -row 2 -column 0 -columnspan 2 -sticky ew

    $tbl configure -height 4 -width 40 -stretch all

    grid rowconfigure    $tf 1 -weight 1
    grid columnconfigure $tf 0 -weight 1
    pack $tf -side top -expand yes -fill both

    set footerFrame [ttk::frame $converterWindow.footer]
    set btnClose [ttk::button $footerFrame.btnClose -text "Close" -command { catch { destroy .converterWindow } }]
    set btnConvert [ttk::button $footerFrame.btnConvert -text "Convert" -command ProjectUpgradeWindow::ConvertProjectFile]
    pack $btnConvert -side left -pady 10
    pack $btnClose -side left -pady 10 -padx 10
    pack $footerFrame -padx 10 -pady 10

    ProjectUpgradeWindow::AddRows $tbl

    wm protocol .converterWindow WM_DELETE_WINDOW "$btnClose invoke"
    bind $converterWindow <KeyPress-Return> "$btnConvert invoke"
    bind $converterWindow <KeyPress-Escape> "$btnClose invoke"
    # Operations::centerW $converterWindow
    BWidget::place . 0 0 center
}

#-------------------------------------------------------------------------------
#  ProjectUpgradeWindow::ConvertProjectFile
#  Description: Performs the conversion of the project file .
#-------------------------------------------------------------------------------
proc ProjectUpgradeWindow::ConvertProjectFile { } {
    global converterWindow
    global upgradePath
    global lastOpenPjt

    catch "destroy $converterWindow"

    thread::send  [tsv::set application importProgress] "StartProgress"

    set result [openConfProjectUpgradeLib::UpgradeProject $upgradePath]

    thread::send  [tsv::set application importProgress] "StopProgress"

    openConfProjectUpgradeLib::ShowErrorMessage $result
    if { [ProjectUpgrade_Result_IsSuccessful $result] } {

        set projectUpgradeMessage "Project has been successfully converted."
        tk_messageBox -message "$projectUpgradeMessage" -title Info -icon info -parent .
        Console::DisplayInfo "$projectUpgradeMessage"

        set newProjectResult [openConfProjectUpgradeLib::GetNewProjectFilePath]
        if { [ProjectUpgrade_Result_IsSuccessful [lindex $newProjectResult 0]] } {
            set newProjectPath [lindex $newProjectResult 1]

            if { [string length $newProjectPath] != 0  } {
                set logfileName [file join [file dirname $newProjectPath] "upgrade.log"]

                if { [file exists $logfileName] } {
                    set result [tk_messageBox -message "Do you want to have a look at the upgrade log?" -type yesno -icon question -title "Question" -parent .]
                    switch -- $result {
                         yes {
                            ProjectUpgradeWindow::ShowFile $logfileName "Project upgrade log"
                        }
                         no  {
                            Console::DisplayInfo "Project upgrade log present at $logfileName" info
                            return
                        }
                    }
                }
                openConfProjectUpgradeLib::ResetProjectUpgradeLib
                ## Clear the project upgrade memory and continue open project
                set lastOpenPjt $newProjectPath
                set lastOpenDir [file dirname $lastOpenPjt]
                Operations::openProject $lastOpenPjt
            } else {
                # Clear the project upgrade memory
                openConfProjectUpgradeLib::ResetProjectUpgradeLib
            }

        } else {
            # error in fetching the new project file path.
            # Clear the project upgrade memory
        }
    } else {
        set resultYesNo [tk_messageBox -message "Do you want to revert the project changes?" -type yesno -icon question -title "Question" -parent .]
        switch -- $resultYesNo {
             yes {
                thread::send  [tsv::set application importProgress] "StartProgress"
                set result [openConfProjectUpgradeLib::RevertUpgradeProject]
                thread::send  [tsv::set application importProgress] "StopProgress"
                openConfProjectUpgradeLib::ShowErrorMessage $result
            }
             no  {
                Console::DisplayInfo "The original project is present in the location $upgradePath_<version>" info
                return
            }
        }
    }
}

#-------------------------------------------------------------------------------
#  ProjectUpgradeWindow::ShowFile
#  Description: Reads the upgrade log and displays to the user in a separate window.
#               fileName    - log file name
#               windowTitle - Title for the log window.
#-------------------------------------------------------------------------------
proc ProjectUpgradeWindow::ShowFile { fileName windowTitle } {

    catch "destroy .topLog"

    set top .topLog
    toplevel $top
    update
    wm title $top $windowTitle
    wm minsize $top 10 10
    wm maxsize $top 640 480
    wm resizable $top 1 1
    wm deiconify $top

    # Create a vertically scrolled text widget as a child of the toplevel
    set tf $top.tf
    frame $tf -class ScrollArea
    set txt $tf.txt
    set vsb $tf.vsb
    set hsb $tf.hsb
    text $txt -background white -font TkFixedFont -setgrid yes -wrap word\
              -width 640 \
              -yscrollcommand [list $vsb set] \
              -xscrollcommand [list $hsb set]

    # catch {$txt configure -tabstyle wordprocessor}; # for Tk 8.5 and above
    ttk::scrollbar $vsb -orient vertical -command [list $txt yview]
    ttk::scrollbar $hsb -orient horizontal -command [list $txt xview]

    # Insert the file's contents into the text widget
    set fileRefence [open $fileName]
    $txt insert end [read $fileRefence]
    close $fileRefence

    set btnClose [button $top.btn -text "Close" -command [list destroy $top]]

    # Manage the widgets
    grid $txt -row 0 -column 0 -sticky news
    grid $vsb -row 0 -rowspan 2 -column 1 -sticky ns
    grid $hsb -row 2 -column 0 -columnspan 2 -sticky ew

    $txt configure -width 40 -height 100

    grid rowconfigure    $tf 0 -weight 1
    grid columnconfigure $tf 0 -weight 1
    pack $btnClose -side bottom -pady 10
    pack $tf -side top -expand yes -fill both

    wm protocol .topLog WM_DELETE_WINDOW "$btnClose invoke"
    bind $top <KeyPress-Return> "$btnClose invoke"
    bind $top <KeyPress-Escape> "$btnClose invoke"
    Operations::centerW $top
}

#-------------------------------------------------------------------------------
#  ProjectUpgradeWindow::AddRows
#  Description: Add new rows for each nodes in the project.
#               tbl - Table path
#-------------------------------------------------------------------------------
proc ProjectUpgradeWindow::AddRows { tbl } {

    set result [openConfProjectUpgradeLib::GetNodes]
    openConfProjectUpgradeLib::ShowErrorMessage [lindex $result 0]
    if { [ProjectUpgrade_Result_IsSuccessful [lindex $result 0]] } {
        foreach nodeId [lindex $result 2] {
            # Get node name and octx path then create the row
            set nodeName ""
            set octxPath ""

            set result [openConfProjectUpgradeLib::GetNodeName $nodeId]
            openConfProjectUpgradeLib::ShowErrorMessage [lindex $result 0]
            if { [ProjectUpgrade_Result_IsSuccessful [lindex $result 0]] } {
                set nodeName [lindex $result 1]
            }

            set result [openConfProjectUpgradeLib::GetOctxPath $nodeId]
            openConfProjectUpgradeLib::ShowErrorMessage [lindex $result 0]
            if { [ProjectUpgrade_Result_IsSuccessful [lindex $result 0]] } {
                set octxPath [lindex $result 1]
            }

            $tbl insert end [list $nodeId $nodeName $octxPath "" ""]
        }
    }

    set rowCount [$tbl size]
    for {set row 0} {$row < $rowCount} {incr row} {
        $tbl cellconfigure $row,3 -window ProjectUpgradeWindow::CreateXddSelectFrame -stretchwindow yes
    }
}

#-------------------------------------------------------------------------------
#  ProjectUpgradeWindow::CreateXddSelectFrame
#  Description: Adds the new frame with a button and an entry.
#               tbl - table path.
#               row - row.
#               col - column.
#               w   - window path.
#-------------------------------------------------------------------------------
proc ProjectUpgradeWindow::CreateXddSelectFrame { tbl row col w } {
    set key [$tbl getkeys $row]

    ttk::frame $w -height 35
    bindtags $w [lreplace [bindtags $w] 1 1 TablelistBody]

    ttk::entry $w.entry$row -width 80 -justify left -state readonly
    # bindtags $w.entry [lreplace [bindtags $w] 1 1 TablelistBody]

    ttk::button $w.btn -text "Browse..." -image openImg -compound left -takefocus 0 \
          -command [list ProjectUpgradeWindow::ChooseInputXdd $tbl $row $col $w $key]

    grid $w.btn $w.entry$row -padx 4 -pady 4
    grid $w.btn -sticky e
    grid $w.entry$row -sticky ew
}

#-------------------------------------------------------------------------------
#  ProjectUpgradeWindow::ChooseInputXdd
#  Description: Gets the path for the input XDD/XDC and sets the path to the
#               project upgrade library.
#               tbl - table path.
#               row - row.
#               col - column.
#               w   - window path.
#               key - key.
#-------------------------------------------------------------------------------
proc ProjectUpgradeWindow::ChooseInputXdd { tbl row col w key } {
    global rootDir

    set nodeId [$tbl cellcget $row,0 -text]
    set nodeName [$tbl cellcget $row,1 -text]

    $w.entry$row delete 0 end

    set types {
        {"XML Device Description Files"     {*.xdd } }
        {"XML Device Configuration Files"   {*.xdc } }
    }

    set inputXdd [tk_getOpenFile -title "Choose the XDD for $nodeName\($nodeId\) " -initialdir $rootDir -filetypes $types -parent .]

    # Validate input XDD inside the library
    set result [openConfProjectUpgradeLib::SetXddPath $nodeId $inputXdd]
    openConfProjectUpgradeLib::ShowErrorMessage $result
    if { [ProjectUpgrade_Result_IsSuccessful $result] } {
        $w.entry$row configure -state normal
        $w.entry$row insert 0 "$inputXdd"
        $w.entry$row configure -state readonly
        update
    }
}
