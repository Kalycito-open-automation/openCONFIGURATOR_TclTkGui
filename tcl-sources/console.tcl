################################################################################
# \file   console.tcl
#
# \brief  Contains the procedures for Information, Warning and Error window
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
#  namespace : Console
#-------------------------------------------------------------------------------
namespace eval Console {

}

#-------------------------
#   Global variables
#-------------------------
global infoWindow
global warWindow
global errWindow

#-------------------------------------------------------------------------------
#  Console::InitInfoWindow
#
#  Arguments: win - path of the window where the text widget is created
#             width - width of the text widget
#             height - height of the text widget
#
#  Results: textwidget - path of the text widget
#
#  Description: Creates the information window and returns the path of the text widget
#-------------------------------------------------------------------------------
proc Console::InitInfoWindow {win {width 60} {height 5}} {
    set windowPath $win
    set promptChar $

    if {$windowPath == "."} {
        set windowPath ""
    }

    text $windowPath.t -width $width -height $height -bg white

    $windowPath.t tag configure output -foreground blue
    $windowPath.t tag configure promptChar -foreground grey40
    $windowPath.t tag configure error -foreground red
    $windowPath.t insert end "$promptChar " promptChar
    $windowPath.t mark set promptChar insert
    $windowPath.t mark gravity promptChar left
    $windowPath.t configure -state disabled
    pack $windowPath.t -fill both -expand yes
    return $windowPath.t
}

#-------------------------------------------------------------------------------
#  Console::DisplayInfo
#
#  Arguments: var - string to be displayed
#             tag - tag binded with text widget
#             win - path of text widget
#             see - to view the inserted text
#
#  Results: -
#
#  Description: Display the information message
#-------------------------------------------------------------------------------
proc Console::DisplayInfo {var {tag output} {win {}} {see 1}} {
    global infoWindow

    set promptChar $

    if {$win == {}} {
        set win [lindex $infoWindow 0]
    }
    $win configure -state normal
    $win mark gravity promptChar right
    $win insert end $var $tag
    if {[string index $var [expr [string length $var]-1]] != "\n"} {
        $win insert end "\n"
    }

    $win insert end "$promptChar " promptChar
    $win mark gravity promptChar left
    if $see {$win see insert}
    update
    $win configure -state disabled
    [lindex $infoWindow 1] raise [lindex $infoWindow 2]
    return
}

#-------------------------------------------------------------------------------
#  Console::InitErrorWindow
#
#  Arguments: win - path of the window where the text widget is created
#             width - width of the text widget
#             height - height of the text widget
#
#  Results: textwidget - path of the text widget
#
#  Description: Creates the error window and returns the path of the text widget
#-------------------------------------------------------------------------------
proc Console::InitErrorWindow {win {width 60} {height 5}} {
    set windowPath $win
    set promptChar $

    if {$windowPath == "."} {
        set windowPath ""
    }

    text $windowPath.t -width $width -height $height -bg white

    $windowPath.t tag configure output -foreground blue
    $windowPath.t tag configure promptChar -foreground grey40
    $windowPath.t tag configure error -foreground red
    $windowPath.t insert end "$promptChar " promptChar
    $windowPath.t mark set promptChar insert
    $windowPath.t mark gravity promptChar left
    $windowPath.t configure -state disabled

    pack $windowPath.t -fill both -expand yes
    return $windowPath.t
}

#-------------------------------------------------------------------------------
#  Console::DisplayErrMsg
#
#  Arguments: var - string to be displayed
#             tag - tag binded with text widget
#             win - path of text widget
#             see - to view the inserted text
#
#  Results: -
#
#  Description:  Display the error message
#-------------------------------------------------------------------------------
proc Console::DisplayErrMsg {var {tag output} {win {}} {see 1}} {
    global errWindow

    set promptChar $

    if {$win == {}} {
        set win [lindex $errWindow 0]
    }
    $win configure -state normal
    $win mark gravity promptChar right
    $win insert end $var $tag
    if {[string index $var [expr [string length $var]-1]] != "\n"} {
        $win insert end "\n"
    }

    $win insert end "$promptChar " promptChar
    $win mark gravity promptChar left
    if $see {$win see insert}
    update
    $win configure -state disabled
    [lindex $errWindow 1] raise [lindex $errWindow 2]
    return
}

#-------------------------------------------------------------------------------
#  Console::InitWarnWindow
#
#  Arguments: win - path of the window where the text widget is created
#             width - width of the text widget
#             height - height of the text widget
#
#  Results: textwidget - path of the text widget
#
#  Description: Creates the warning window and returns the path of the text widget
#-------------------------------------------------------------------------------
proc Console::InitWarnWindow {win {width 60} {height 5}} {
    set windowPath $win
    set promptChar $

    if {$windowPath == "."} {
        set windowPath ""
    }

    text $windowPath.t -width $width -height $height -bg white

    $windowPath.t configure -foreground blue
    $windowPath.t tag configure output -foreground blue
    $windowPath.t tag configure promptChar -foreground grey40
    $windowPath.t tag configure error -foreground red
    $windowPath.t insert end "$promptChar " promptChar
    $windowPath.t mark set promptChar insert
    $windowPath.t mark gravity promptChar left
    $windowPath.t configure -state disabled

    pack $windowPath.t -fill both -expand yes
    return $windowPath.t
}

#-------------------------------------------------------------------------------
#  Console::DisplayWarning
#
#  Arguments: var - string to be displayed
#             tag - tag bound with text widget
#             win - path of text widget
#             see - to view the inserted text
#
#  Results: -
#
#  Description: Display the warning message
#-------------------------------------------------------------------------------
proc Console::DisplayWarning {var {tag output} {win {}} {see 1}} {

    global warWindow

    set promptChar $
    if {$win == {}} {
        set win [lindex $warWindow 0]
    }
    $win configure -state normal
    $win mark gravity promptChar right
    $win insert end $var $tag
    if {[string index $var [expr [string length $var]-1]] != "\n"} {
        $win insert end "\n"
    }

    $win insert end "$promptChar " promptChar
    $win mark gravity promptChar left
    [lindex $warWindow 1] raise [lindex $warWindow 2]
    if $see {$win see insert}
    update

    $win configure -state disabled

    return
}

#-------------------------------------------------------------------------------
#  Console::ClearMsgs
#
#  Arguments: -
#
#  Results: -
#
#  Description: Clears information, error and warning messages
#-------------------------------------------------------------------------------
proc Console::ClearMsgs {} {
    global infoWindow
    global warWindow
    global errWindow

    set promptChar $
    foreach windowPath [list [lindex $infoWindow 0] [lindex $warWindow 0]  [lindex $errWindow 0] ] {
        $windowPath configure -state normal
        $windowPath delete 1.0 end
        $windowPath insert end "$promptChar " promptChar
        $windowPath configure -state disabled
    }
}
