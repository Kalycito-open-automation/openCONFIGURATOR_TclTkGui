####################################################################################################
#
#
#  NAME:     notebookManager.tcl
#
#  PURPOSE:  Creates the windows (tablelist, console, tabs, tree)
#
#  AUTHOR:   Kalycito Infotech Pvt Ltd
#
#  Copyright :(c) Kalycito Infotech Private Limited
#
#***************************************************************************************************
#  COPYRIGHT NOTICE:
#
#  Project:      openCONFIGURATOR
#
#  License:
#
#    Redistribution and use in source and binary forms, with or without
#    modification, are permitted provided that the following conditions
#    are met:
#
#    1. Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#    2. Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
#    3. Neither the name of Kalycito Infotech Private Limited nor the names of
#       its contributors may be used to endorse or promote products derived
#       from this software without prior written permission. For written
#       permission, please contact info@kalycito.com.
#
#    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
#    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#    COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
#    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
#    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#    POSSIBILITY OF SUCH DAMAGE.
#
#    Severability Clause:
#
#        If a provision of this License is or becomes illegal, invalid or
#        unenforceable in any jurisdiction, that shall not affect:
#        1. the validity or enforceability in that jurisdiction of any other
#           provision of this License; or
#        2. the validity or enforceability in other jurisdictions of that or
#           any other provision of this License.
#
#***************************************************************************************************
#
#  REVISION HISTORY:
#
####################################################################################################


#---------------------------------------------------------------------------------------------------
#  NameSpace Declaration
#
#  namespace : NoteBookManager
#---------------------------------------------------------------------------------------------------
namespace eval NoteBookManager {
    variable _pageCounter 0
    variable _consoleCounter 0
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::create_tab
#
#  Arguments : nbpath  - frame path to create
#              choice  - choice for index or subindex to create frame
#
#  Results : outerFrame - Basic frame
#            tabInnerf0 - frame containing widgets describing the object (index id, Object name, subindex id )
#            tabInnerf1 - frame containing widgets describing properties of object
#
#  Description : Creates the GUI for Index and subindex
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::create_tab { nbpath choice } {
    variable _pageCounter
    incr _pageCounter

    global tcl_platform
    global tmpNam$_pageCounter
    global tmpValue$_pageCounter
    global tmpEntryValue
    global ra_dataType
    global ch_generate
    global indexSaveBtn
    global subindexSaveBtn

    set nbname "page$_pageCounter"

    set outerFrame [frame $nbpath.$nbname -relief raised -borderwidth 1 ]
    set frame [frame $outerFrame.frame -relief flat -borderwidth 10  ]
    pack $frame -expand yes -fill both

    set scrollWin [ScrolledWindow $frame.scrollWin]
    pack $scrollWin -fill both -expand true

    set sf [ScrollableFrame $scrollWin.sf]
    $scrollWin setwidget $sf

    set uf [$sf getframe]
    $uf configure -height 20
    set tabTitlef0 [TitleFrame $uf.tabTitlef0 -text "Sub Index" ]
    set tabInnerf0 [$tabTitlef0 getframe]
    set tabTitlef1 [TitleFrame $uf.tabTitlef1 -text "Properties" ]
    set tabInnerf1 [$tabTitlef1 getframe]
    set tabInnerf0_1 [frame $tabInnerf0.frame1 ]

    label $tabInnerf0.la_idx     -text "Index  "
    label $tabInnerf0.la_empty1 -text ""
    label $tabInnerf0.la_empty2 -text ""
    label $tabInnerf0.la_nam     -text "Name           "
    label $tabInnerf0.la_empty3 -text ""
    label $tabInnerf0_1.la_generate -text ""
    label $tabInnerf1.la_obj     -text "Object Type"
    label $tabInnerf1.la_empty4 -text ""
    label $tabInnerf1.la_data    -text "Data Type"
    label $tabInnerf1.la_empty5 -text ""
    label $tabInnerf1.la_access  -text "Access Type"
    label $tabInnerf1.la_empty6 -text ""
    label $tabInnerf1.la_value   -text "Value"
    label $tabInnerf1.la_default -text "Default Value"
    label $tabInnerf1.la_upper   -text "Upper Limit"
    label $tabInnerf1.la_lower   -text "Lower Limit"
    label $tabInnerf1.la_pdo   -text "PDO Mapping"

    entry $tabInnerf0.en_idx1 -state disabled -width 20
    entry $tabInnerf0.en_nam1 -state disabled -width 20 -textvariable tmpNam$_pageCounter -relief ridge -justify center -bg white -width 30 -validate key -vcmd "Validation::IsValidStr %P"
    entry $tabInnerf1.en_obj1 -state disabled -width 20
    entry $tabInnerf1.en_data1 -state disabled -width 20
    entry $tabInnerf1.en_access1 -state disabled -width 20
    entry $tabInnerf1.en_upper1 -state disabled -width 20
    entry $tabInnerf1.en_lower1 -state disabled -width 20
    entry $tabInnerf1.en_pdo1 -state disabled -width 20
    entry $tabInnerf1.en_default1 -state disabled -width 20
    entry $tabInnerf1.en_value1 -width 20 -textvariable tmpValue$_pageCounter  -relief ridge -bg white
    bind $tabInnerf1.en_value1 <FocusOut> "NoteBookManager::ValueFocusChanged $tabInnerf1 $tabInnerf1.en_value1"


    set frame1 [frame $tabInnerf1.frame1]
    set ra_dec [radiobutton $frame1.ra_dec -text "Dec" -variable ra_dataType -value dec -command "NoteBookManager::ConvertDec $tabInnerf0 $tabInnerf1"]
    set ra_hex [radiobutton $frame1.ra_hex -text "Hex" -variable ra_dataType -value hex -command "NoteBookManager::ConvertHex $tabInnerf0 $tabInnerf1"]

    set ch_gen [checkbutton $tabInnerf0_1.ch_gen -onvalue 1 -offvalue 0 -command { Validation::SetPromptFlag } -variable ch_generate]

    grid config $tabTitlef0 -row 0 -column 0 -sticky ew
    label $uf.la_empty -text ""
    grid config $uf.la_empty -row 1 -column 0
    grid config $tabTitlef1 -row 2 -column 0 -sticky ew

    grid config $tabInnerf0.la_idx -row 0 -column 0 -sticky w
    grid config $tabInnerf0.en_idx1 -row 0 -column 1 -padx 5 -sticky w
    grid config $tabInnerf0.la_empty1 -row 1 -column 0 -columnspan 2
    grid config $tabInnerf0.la_empty2 -row 3 -column 0 -columnspan 2

    grid config $tabInnerf1.la_data -row 0 -column 0 -sticky w
    grid config $tabInnerf1.en_data1 -row 0 -column 1 -padx 5

    grid config $tabInnerf1.la_upper -row 0 -column 2 -sticky w
    grid config $tabInnerf1.en_upper1 -row 0 -column 3 -padx 5

    grid config $tabInnerf1.la_access -row 0 -column 4 -sticky w
    grid config $tabInnerf1.en_access1 -row 0 -column 5 -padx 5

    grid config $tabInnerf1.la_empty4 -row 1 -column 0 -columnspan 2

    grid config $tabInnerf1.la_obj -row 2 -column 0 -sticky w
    grid config $tabInnerf1.en_obj1 -row 2 -column 1 -padx 5

    grid config $tabInnerf1.la_lower -row 2 -column 2 -sticky w
    grid config $tabInnerf1.en_lower1 -row 2 -column 3 -padx 5

    grid config $tabInnerf1.la_pdo -row 2 -column 4 -sticky w
    grid config $tabInnerf1.en_pdo1 -row 2 -column 5 -padx 5

    grid config $tabInnerf1.la_empty5 -row 3 -column 0 -columnspan 2

    grid config $tabInnerf1.la_value -row 4 -column 0 -sticky w
    grid config $tabInnerf1.en_value1 -row 4 -column 1 -padx 5

    grid config $frame1 -row 4 -column 3 -padx 5 -columnspan 2 -sticky w
    grid config $tabInnerf1.la_default -row 4 -column 4 -sticky w
    grid config $tabInnerf1.en_default1 -row 4 -column 5 -padx 5
    grid config $tabInnerf1.la_empty6 -row 5 -column 0 -columnspan 2

    grid config $ra_dec -row 0 -column 0 -sticky w
    grid config $ra_hex -row 0 -column 1 -sticky w
    grid remove $ra_dec
    grid remove $ra_hex
    if {$choice == "index"} {
        $tabTitlef0 configure -text "Index"
        $tabTitlef1 configure -text "Properties"
        grid config $tabInnerf0.la_idx -row 0 -column 0 -sticky w
        grid config $tabInnerf0.en_idx1 -row 0 -column 1 -sticky w -padx 0
        grid config $tabInnerf0.la_nam -row 2 -column 0 -sticky w
        grid config $tabInnerf0.en_nam1 -row 2 -column 1  -sticky w -columnspan 1

        grid config $tabInnerf0_1 -row 4 -column 0 -columnspan 2 -sticky w
        grid config $tabInnerf0_1.la_generate -row 0 -column 0 -sticky w
        grid config $tabInnerf0_1.ch_gen -row 0 -column 1 -sticky e -padx 5
        grid config $tabInnerf0.la_empty3 -row 5 -column 0 -columnspan 2
        bind $tabInnerf0_1.la_generate <1> "$tabInnerf0_1.ch_gen toggle ; Validation::SetPromptFlag"
        $tabInnerf0_1.la_generate configure -text "Force CDC export"
    } elseif { $choice == "subindex" } {
        $tabTitlef0 configure -text "Sub Index"
        $tabTitlef1 configure -text "Properties"

        label $tabInnerf0.la_sidx -text "Sub Index  "
        entry $tabInnerf0.en_sidx1 -state disabled -width 20

        grid config $tabInnerf0.la_sidx -row 0 -column 2 -sticky w
        grid config $tabInnerf0.en_sidx1 -row 0 -column 3 -padx 5
        grid config $tabInnerf0.la_nam -row 2 -column 0 -sticky w
        grid config $tabInnerf0.en_nam1 -row 2 -column 1  -sticky e -columnspan 1

        grid config $tabInnerf0_1 -row 4 -column 0 -columnspan 2 -sticky w
        grid config $tabInnerf0_1.la_generate -row 0 -column 0 -sticky w
        grid config $tabInnerf0_1.ch_gen -row 0 -column 1 -sticky e -padx 5
        grid config $tabInnerf0.la_empty3 -row 5 -column 0 -columnspan 2
        bind $tabInnerf0_1.la_generate <1> "$tabInnerf0_1.ch_gen toggle ; Validation::SetPromptFlag"
        $tabInnerf0_1.la_generate configure -text "Force CDC export"
    }

    set fram [frame $frame.f1]
    label $fram.la_empty -text "  " -height 1
    if { $choice == "index" } {
        set indexSaveBtn [ button $fram.bt_sav -text " Save " -width 8 ]
    } elseif { $choice == "subindex" } {
        set subindexSaveBtn [ button $fram.bt_sav -text " Save " -width 8 ]
    }
    label $fram.la_empty1 -text "  "
    button $fram.bt_dis -text "Discard" -width 8 -command "NoteBookManager::DiscardValue $tabInnerf0 $tabInnerf1"
    grid config $fram.la_empty -row 0 -column 0 -columnspan 2
    grid config $fram.bt_sav -row 1 -column 0 -sticky s
    grid config $fram.la_empty1 -row 1 -column 1 -sticky s
    grid config $fram.bt_dis -row 1 -column 2 -sticky s
    pack $fram -side bottom

    return [list $outerFrame $tabInnerf0 $tabInnerf1 $sf]
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::create_nodeFrame
#
#  Arguments : nbpath  - frame path to create
#              choice  - choice for pdo to create frame
#
#  Results : basic frame on which all widgets are created
#            tablelist widget path
#
#  Description : Creates the tablelist for TPDO and RPDO
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::create_nodeFrame {nbpath choice} {
    variable _pageCounter
    incr _pageCounter

    global ra_statType$_pageCounter
    global ra_nodeDataType
    global tmpNodeName$_pageCounter
    global tmpNodeNo$_pageCounter
    global tmpNodeTime$_pageCounter
    global mnPropSaveBtn
    global cnPropSaveBtn
    global tcl_platform
    global co_cnNodeList$_pageCounter
    global ch_advanced
    global spCycleNoList$_pageCounter

    set nbname "page$_pageCounter"

    set outerFrame [frame $nbpath.$nbname -relief raised -borderwidth 1 ]
    set frame [frame $outerFrame.frame -relief flat -borderwidth 10  ]
    pack $frame -expand yes -fill both

    set scrollWin [ScrolledWindow $frame.scrollWin]
    pack $scrollWin -fill both -expand true

    set sf [ScrollableFrame $scrollWin.sf]
    $scrollWin setwidget $sf

    set uf [$sf getframe]
    $uf configure -height 20
    set tabTitlef0 [TitleFrame $uf.tabTitlef0 -text "Properties" ]
    set tabInnerf0 [$tabTitlef0 getframe]
    set tabTitlef1 [TitleFrame $tabInnerf0.tabTitlef1 -text "" ]
    set tabInnerf1 [$tabTitlef1 getframe]
    set tabInnerf0_1 [frame $tabInnerf0.frame1 ]
    set cycleFrame [frame $tabInnerf0.cycleframe ]

    label $tabInnerf0.la_nodeName     -text "Node name"
    label $tabInnerf0.la_empty1       -text ""
    label $tabInnerf0.la_align1       -text ""
    label $tabInnerf0.la_align2       -text ""
    label $tabInnerf0.la_nodeNo       -text "Node number"
    label $tabInnerf0.la_empty2       -text ""
    label $tabInnerf0.la_time         -text ""
    label $tabInnerf0.cycleframe.la_ms           -text "µs"
    label $tabInnerf0.la_empty3       -text ""
    label $tabInnerf1.la_advOption1   -text ""
    label $tabInnerf1.la_advOptionUnit1   -text ""
    label $tabInnerf1.la_empty4       -text ""
    label $tabInnerf1.la_advOption2   -text ""
    label $tabInnerf1.la_advOptionUnit2   -text ""
    label $tabInnerf1.la_empty5       -text ""
    label $tabInnerf1.la_advOption3   -text ""
    label $tabInnerf1.la_advOptionUnit3   -text ""
    label $tabInnerf1.la_empty6       -text ""
    label $tabInnerf1.la_seperat1     -text ""
    label $tabInnerf1.la_empty7       -text ""
    label $tabInnerf1.la_advOption4   -text ""
    label $tabInnerf1.la_empty8       -text ""
    label $tabInnerf1.la_advOptionUnit4 -text ""

    entry $tabInnerf0.en_nodeName -width 20 -textvariable tmpNodeName$_pageCounter -relief ridge -justify center -bg white -validate key -vcmd "Validation::IsValidStr %P"
    entry $tabInnerf0.en_nodeNo   -width 20 -textvariable tmpNodeNo$_pageCounter -relief ridge -justify center -bg white
    entry $tabInnerf0.cycleframe.en_time     -width 20 -textvariable tmpNodeTime$_pageCounter -relief ridge -justify center -bg white
    entry $tabInnerf1.en_advOption1 -state disabled -width 20
    entry $tabInnerf1.en_advOption2 -state disabled -width 20
    entry $tabInnerf1.en_advOption3 -state disabled -width 20
    entry $tabInnerf1.en_advOption4 -state disabled -width 20

    set frame1 [frame $tabInnerf0.formatframe1]
    set ra_StNormal [radiobutton $tabInnerf1.ra_StNormal -text "Normal station"      -variable ra_statType$_pageCounter -value "StNormal" ]
    set ra_StMulti  [radiobutton $tabInnerf1.ra_StMulti  -text "Multiplexed station" -variable ra_statType$_pageCounter -value "StMulti" ]
    set ra_StChain  [radiobutton $tabInnerf1.ra_StChain  -text "Chained station"     -variable ra_statType$_pageCounter -value "StChain" ]

    grid config $tabTitlef0 -row 0 -column 0 -sticky ew -ipady 7 ;

    grid config $tabInnerf0.la_align1    -row 0 -column 0 -padx 5
    grid config $tabInnerf0.la_nodeNo    -row 2 -column 1 -sticky w
    grid config $tabInnerf0.en_nodeNo    -row 2 -column 2 -sticky w -padx 5
    grid config $tabInnerf0.la_align2    -row 0 -column 3 -padx 170
    grid config $tabInnerf0.la_empty1    -row 1 -column 1
    grid config $tabInnerf0.la_nodeName  -row 0 -column 1 -sticky w
    grid config $tabInnerf0.en_nodeName  -row 0 -column 2 -sticky w -padx 5
    grid config $tabInnerf0.la_empty2    -row 3 -column 1
    grid config $tabInnerf0.la_time      -row 4 -column 1 -sticky w
    grid config $tabInnerf0.cycleframe   -row 4 -column 2 -columnspan 2 -sticky w
    grid config $tabInnerf0.cycleframe.en_time      -row 0 -column 0 -sticky w -padx 5
    grid config $tabInnerf0.cycleframe.la_ms      -row 0 -column 1 -sticky w
    grid config $tabInnerf0.la_empty3    -row 5 -column 1
    grid config $frame1                  -row 6 -column 2 -padx 5

    if { $choice == "mn" } {
        $tabInnerf0.la_time  configure -text "Cycle Time"

        $tabInnerf0.tabTitlef1 configure -text "Advanced"
        $tabInnerf0.en_nodeNo configure -state disabled
        $tabInnerf1.la_advOption4 configure  -text "Loss of SoC Tolerance"
        $tabInnerf1.la_advOptionUnit4 configure -text "µs"
        $tabInnerf1.la_advOption1 configure -text "Asynchronous MTU size"
        $tabInnerf1.la_advOptionUnit1 configure -text "Bytes"
        $tabInnerf1.la_advOption2 configure -text "Asynchronous Timeout"
        $tabInnerf1.la_advOptionUnit2 configure -text "ns"
        $tabInnerf1.la_advOption3 configure -text "Multiplexing prescaler"

        grid config $tabInnerf1.la_advOption4 -row 0 -column 1 -sticky w
        grid config $tabInnerf1.en_advOption4 -row 0 -column 2 -padx 5
        grid config $tabInnerf1.la_advOptionUnit4 -row 0 -column 3 -sticky w
        grid config $tabInnerf1.la_empty8     -row 1 -column 1
        grid config $tabInnerf1.la_advOption1 -row 2 -column 1 -sticky w
        grid config $tabInnerf1.en_advOption1 -row 2 -column 2 -padx 5
        grid config $tabInnerf1.la_advOptionUnit1 -row 2 -column 3 -sticky w
        grid config $tabInnerf1.la_empty4     -row 3 -column 1
        grid config $tabInnerf1.la_advOption2 -row 4 -column 1 -sticky w
        grid config $tabInnerf1.en_advOption2 -row 4 -column 2 -padx 5
        grid config $tabInnerf1.la_advOptionUnit2 -row 4 -column 3 -sticky w
        grid config $tabInnerf1.la_empty5     -row 5 -column 1
        grid config $tabInnerf1.la_advOption3 -row 6 -column 1 -sticky w
        grid config $tabInnerf1.en_advOption3 -row 6 -column 2 -padx 5
        grid config $tabInnerf1.la_advOptionUnit3 -row 6 -column 3 -sticky w
        grid config $tabInnerf1.la_empty6     -row 7 -column 1

    } elseif { $choice == "cn" } {
        if {"$tcl_platform(platform)" == "windows"} {
            set spinWidth 19
        } else {
            set spinWidth 19
        }
        set cnNodeList [NoteBookManager::GenerateCnNodeList]
        spinbox $tabInnerf0.sp_nodeNo -state normal -textvariable co_cnNodeList$_pageCounter \
            -validate key -vcmd "Validation::CheckCnNodeNumber %P" -bg white \
            -from 1 -to 239 -increment 1 -justify center -width $spinWidth

        grid forget $tabInnerf0.en_nodeNo
        grid config $tabInnerf0.sp_nodeNo    -row 2 -column 2 -sticky w -padx 5
        $tabInnerf0.la_time  configure -text "PollResponse Timeout"
        $tabInnerf0.tabTitlef1 configure -text "Type of station"

        set tabTitlef2 [TitleFrame $tabInnerf1.tabTitlef2 -text "Advanced" ]
        set tabInnerf2 [$tabTitlef2 getframe]
        set ch_adv [checkbutton $tabInnerf2.ch_adv -onvalue 1 -offvalue 0 -command "NoteBookManager::forceCycleChecked $tabInnerf2 ch_advanced" -variable ch_advanced -text "Force Cycle"]
        spinbox $tabInnerf2.sp_cycleNo -state normal -textvariable spCycleNoList$_pageCounter \
            -bg white -width $spinWidth \
            -from 1 -to 239 -increment 1 -justify center

        grid config $ra_StNormal          -row 0 -column 0 -sticky w -padx 5
        grid config $tabInnerf1.la_empty4 -row 1 -column 0
        grid config $ra_StChain           -row 2 -column 0 -sticky w -padx 5
        grid config $tabInnerf1.la_empty5 -row 3 -column 0
        grid config $ra_StMulti           -row 4 -column 0 -sticky w -padx 5
        grid config $tabTitlef2           -row 5 -column 0 -sticky e -columnspan 2 -padx 20;# -ipadx 10
        grid config $tabInnerf1.la_empty7 -row 7 -column 0

        grid config $ch_adv                -row 0 -column 0
        grid config $tabInnerf2.sp_cycleNo -row 0 -column 1

        $ra_StNormal configure -command "NoteBookManager::StationRadioChanged $tabInnerf2 StNormal"
        $ra_StMulti configure -command "NoteBookManager::StationRadioChanged $tabInnerf2 StMulti"
        $ra_StChain configure -command "NoteBookManager::StationRadioChanged $tabInnerf2 StChain"
    }
    grid config $tabTitlef1 -row 8 -column 1 -columnspan 2 -sticky ew

    set fram [frame $frame.f1]
    label $fram.la_empty -text "  " -height 1
    if { $choice == "mn" } {
        set mnPropSaveBtn [ button $fram.bt_sav -text " Save " -width 8 -command ""]
        set resultList [list $outerFrame $tabInnerf0 $tabInnerf1 $sf ]
    } elseif { $choice == "cn" } {
        set cnPropSaveBtn [ button $fram.bt_sav -text " Save " -width 8 -command ""]
        set resultList [list $outerFrame $tabInnerf0 $tabInnerf1 $sf $tabInnerf2]
    }
    label $fram.la_empty1 -text "  "
    button $fram.bt_dis -text "Discard" -width 8 -command "NoteBookManager::DiscardValue $tabInnerf0 $tabInnerf1"
    grid config $fram.la_empty -row 0 -column 0 -columnspan 2
    grid config $fram.bt_sav -row 1 -column 0 -sticky s
    grid config $fram.la_empty1 -row 1 -column 1 -sticky s
    grid config $fram.bt_dis -row 1 -column 2 -sticky s
    pack $fram -side bottom

    return $resultList
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::create_table
#
#  Arguments : nbpath  - frame path to create
#              choice  - choice for pdo to create frame
#
#  Results : basic frame on which all widgets are created
#            tablelist widget path
#
#  Description : Creates the tablelist for TPDO and RPDO
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::create_table {nbpath choice} {
    variable _pageCounter
    incr _pageCounter

    global tableSaveBtn

    set nbname "page$_pageCounter"
    set outerFrame [frame $nbpath.$nbname -relief raised -borderwidth 1 ]
    set frmPath [frame $outerFrame.frmPath -relief flat -borderwidth 10  ]
    pack $frmPath -expand yes -fill both

    set scrollWin [ScrolledWindow $frmPath.scrollWin ]
    pack $scrollWin -fill both -expand true
    set st $frmPath.st

    catch "font delete custom1"
    font create custom1 -size 9 -family TkDefaultFont

    if {$choice == "pdo"} {
        set st [tablelist::tablelist $st \
            -columns {0 "No" left
            0 "Node Id" center
            0 "Index" center
            0 "Sub Index" center
            0 "Length" center
            0 "Offset" center} \
            -setgrid 0 -width 0 \
            -stripebackground gray98 \
            -resizable 1 -movablecolumns 0 -movablerows 0 \
            -showseparators 1 -spacing 10 -font custom1 \
            -editstartcommand NoteBookManager::StartEdit -editendcommand NoteBookManager::EndEdit ]

        $st columnconfigure 0 -editable no
        $st columnconfigure 1 -editable no
        $st columnconfigure 2 -editable yes -editwindow entry
        $st columnconfigure 3 -editable yes -editwindow entry
        $st columnconfigure 4 -editable yes -editwindow entry
        $st columnconfigure 5 -editable yes -editwindow entry

    } elseif {$choice == "AUTOpdo"} {
        set st [tablelist::tablelist $st \
            -columns {0 "S.No" left
            0 "Target Node Id" center
            0 "Index" center
            0 "Sub Index" center
            0 "Length" center
            0 "Offset" center} \
            -setgrid 0 -width 0 \
            -stripebackground gray98 \
            -resizable 1 -movablecolumns 0 -movablerows 0 \
            -showseparators 1 -spacing 10 -font custom1 \
            -editstartcommand NoteBookManager::StartEditCombo \
            -editendcommand NoteBookManager::EndEdit]

            $st columnconfigure 0 -editable no
            $st columnconfigure 1 -editable no -editwindow ComboBox
            $st columnconfigure 2 -editable no -editwindow ComboBox
            $st columnconfigure 3 -editable no -editwindow ComboBox
            $st columnconfigure 4 -editable no -editwindow ComboBox
            $st columnconfigure 5 -editable no
    } else {
        #invalid choice
        return
    }

    $scrollWin setwidget $st
    pack $st -fill both -expand true
    $st configure -height 4 -width 40 -stretch all

    set fram [ frame $frmPath.f1 ]
    label $fram.la_empty -text "  " -height 1
    set tableSaveBtn [ button $fram.bt_sav -text " Save " -width 8 -command "NoteBookManager::SaveTable $st" ]
    label $fram.la_empty1 -text "  "
    button $fram.bt_dis -text "Discard" -width 8 -command "NoteBookManager::DiscardTable $st"
    grid config $fram.la_empty -row 0 -column 0 -columnspan 2
    grid config $fram.bt_sav -row 1 -column 0 -sticky s
    grid config $fram.la_empty1 -row 1 -column 1 -sticky s
    grid config $fram.bt_dis -row 1 -column 2 -sticky s
    pack $fram -side top

    return  [list $outerFrame $st]
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::create_infoWindow
#
#  Arguments : nbpath  - path of the notebook
#              tabname - title for the created tab
#              choice  - choice to create Information, Error and Warning windows
#
#  Results : path of the inserted frame in notebook
#
#  Description : Creates displaying Information, Error and Warning messages windows
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::create_infoWindow {nbpath tabname choice} {
    global infoWindow
    global warWindow
    global errWindow
    global image_dir

    variable _consoleCounter
    incr _consoleCounter

    set nbname Console$_consoleCounter
    set frmPath [$nbpath insert end $nbname -text $tabname]

    image create photo img_error_small -file "$image_dir/error_small.gif"
    image create photo img_warning_small -file "$image_dir/warning_small.gif"

    set scrollWin [ScrolledWindow::create $frmPath.scrollWin -auto both]
    if {$choice == 1} {
        set infoWindow [Console::InitInfoWindow $scrollWin]
        set window $infoWindow
        lappend infoWindow $nbpath $nbname
        $nbpath itemconfigure $nbname -image [Bitmap::get file]
    } elseif {$choice == 2} {
        set errWindow [Console::InitErrorWindow $scrollWin]
        set window $errWindow
        lappend errWindow $nbpath $nbname
        $nbpath itemconfigure $nbname -image img_error_small
    } elseif {$choice == 3} {
        set warWindow [Console::InitWarnWindow $scrollWin]
        set window $warWindow
        lappend warWindow $nbpath $nbname
        $nbpath itemconfigure $nbname -image img_warning_small
    } else {
        #invalid selection
        return
    }

    $window configure -wrap word
    ScrolledWindow::setwidget $scrollWin $window
    pack $scrollWin -fill both -expand yes

    #raised the window after creating it
    $nbpath raise $nbname

    return $frmPath
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::create_treeBrowserWindow
#
#  Arguments : nbpath  - path of the notebook
#
#  Results : path of the inserted frame in notebook
#            path of the tree widget
#
#  Description : Creates the tree widget in notebook
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::create_treeBrowserWindow {nbpath } {
    global treeFrame
    global treePath
    global image_dir

    set nbname objectTree
    set frmPath [$nbpath insert end $nbname -text "Network Browser"]

    set scrollWin [ScrolledWindow::create $frmPath.scrollWin -auto both]
    set treeBrowser [Tree $frmPath.scrollWin.treeBrowser \
        -width 15\
        -highlightthickness 0\
        -bg white  \
        -deltay 15 \
        -padx 15 \
        -dropenabled 0 -dragenabled 0 -relief ridge
    ]
    $scrollWin setwidget $treeBrowser
    set treePath $treeBrowser

    image create photo img_right -file "$image_dir/right.gif"
    image create photo img_left -file "$image_dir/left.gif"

    pack $scrollWin -side top -fill both -expand yes -pady 1
    set treeFrame [frame $frmPath.f1]
    pack $treeFrame -side bottom -pady 5
    entry $treeFrame.en_find -textvariable FindSpace::txtFindDym -width 10 -background white -validate key -vcmd "FindSpace::Find %P"
    button $treeFrame.bt_next -text " Next " -command "FindSpace::Next" -image img_right -relief flat
    button $treeFrame.bt_prev -text " Prev " -command "FindSpace::Prev" -image img_left -relief flat
    grid config $treeFrame.en_find -row 0 -column 0 -sticky ew
    grid config $treeFrame.bt_prev -row 0 -column 1 -sticky s -padx 5
    grid config $treeFrame.bt_next -row 0 -column 2 -sticky s

    return [list $frmPath $treeBrowser]
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::ConvertDec
#
#  Arguments : framePath - path of the frame containing value and default entry widget
#
#  Results : -
#
#  Description : converts value into decimal and changes validation for entry
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::ConvertDec {framePath0 framePath1} {
    global lastConv
    global userPrefList
    global nodeSelect
    global UPPER_LIMIT
    global LOWER_LIMIT

    if { $lastConv != "dec"} {
        set lastConv dec
        set schRes [lsearch $userPrefList [list $nodeSelect *]]
        if {$schRes  == -1} {
            lappend userPrefList [list $nodeSelect dec]
        } else {
            set userPrefList [lreplace $userPrefList $schRes $schRes [list $nodeSelect dec] ]
        }
        $framePath0.en_idx1 configure -state normal
        set indexId [$framePath0.en_idx1 get]
        $framePath0.en_idx1 configure -state disabled
        if { [expr $indexId <= 0x1fff] } {
            $framePath1.en_data1 configure -state normal
            set dataType [$framePath1.en_data1 get]
            $framePath1.en_data1 configure -state disabled
        } else {
            set dataType [NoteBookManager::GetEntryValue $framePath1.en_data1]
        }

        set state [$framePath1.en_value1 cget -state]
        $framePath1.en_value1 configure -validate none -state normal
        NoteBookManager::InsertDecimal $framePath1.en_value1 $dataType
        $framePath1.en_value1 configure -validate key -vcmd "Validation::IsDec %P $framePath1.en_value1 %d %i $dataType" -state $state

        set state [$framePath1.en_default1 cget -state]
        $framePath1.en_default1 configure -validate none -state normal
        NoteBookManager::InsertDecimal $framePath1.en_default1 $dataType
        $framePath1.en_default1 configure -validate key -vcmd "Validation::IsDec %P $framePath1.en_default1 %d %i $dataType" -state $state

        set state [$framePath1.en_lower1 cget -state]
        $framePath1.en_lower1 configure -validate none -state normal
        NoteBookManager::InsertDecimal $framePath1.en_lower1 $dataType
        set LOWER_LIMIT [$framePath1.en_lower1 get]
        $framePath1.en_lower1 configure -validate key -vcmd "Validation::IsDec %P $framePath1.en_lower1 %d %i $dataType" -state $state

        set state [$framePath1.en_upper1 cget -state]
        $framePath1.en_upper1 configure -validate none -state normal
        NoteBookManager::InsertDecimal $framePath1.en_upper1 $dataType
        set UPPER_LIMIT [$framePath1.en_upper1 get]
        $framePath1.en_upper1 configure -validate key -vcmd "Validation::IsDec %P $framePath1.en_upper1 %d %i $dataType" -state $state
    } else {
        #already dec is selected
    }
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::InsertDecimal
#
#  Arguments : entryPath - path of the entry widget
#
#  Results : -
#
#  Description : Convert the value into decimal and insert into the entry widget
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::InsertDecimal {entryPath dataType} {
    set entryValue [$entryPath get]
    if { [string match -nocase "0x*" $entryValue] } {
        set entryValue [string range $entryValue 2 end]
    }

    $entryPath delete 0 end
    set entryValue [lindex [Validation::InputToDec $entryValue $dataType] 0]
    $entryPath insert 0 $entryValue
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::ConvertHex
#
#  Arguments : framePath - path containing the value and default entry widget
#
#  Results : -
#
#  Description : converts the value to hexadecimal and changes validation for entry
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::ConvertHex {framePath0 framePath1} {
    global lastConv
    global userPrefList
    global nodeSelect
    global UPPER_LIMIT
    global LOWER_LIMIT

    if { $lastConv != "hex"} {
        set lastConv hex
        set schRes [lsearch $userPrefList [list $nodeSelect *]]
        if {$schRes  == -1} {
            lappend userPrefList [list $nodeSelect hex]
        } else {
           set userPrefList [lreplace $userPrefList $schRes $schRes [list $nodeSelect hex] ]
        }
        $framePath0.en_idx1 configure -state normal
        set indexId [$framePath0.en_idx1 get]
        $framePath0.en_idx1 configure -state disabled
        if { [expr $indexId <= 0x1fff] } {
            $framePath1.en_data1 configure -state normal
            set dataType [$framePath1.en_data1 get]
            $framePath1.en_data1 configure -state disabled
        } else {
            set dataType [NoteBookManager::GetEntryValue $framePath1.en_data1]
        }
        set state [$framePath1.en_value1 cget -state]
        $framePath1.en_value1 configure -validate none -state normal
        NoteBookManager::InsertHex $framePath1.en_value1 $dataType
        $framePath1.en_value1 configure -validate key -vcmd "Validation::IsHex %P %s $framePath1.en_value1 %d %i $dataType" -state $state

        set state [$framePath1.en_default1 cget -state]
        $framePath1.en_default1 configure -validate none -state normal
        NoteBookManager::InsertHex $framePath1.en_default1 $dataType
        $framePath1.en_default1 configure -validate key -vcmd "Validation::IsHex %P %s $framePath1.en_default1 %d %i $dataType" -state $state

        set state [$framePath1.en_lower1 cget -state]
        $framePath1.en_lower1 configure -validate none -state normal
        NoteBookManager::InsertHex $framePath1.en_lower1 $dataType
        set LOWER_LIMIT [$framePath1.en_lower1 get]
        $framePath1.en_lower1 configure -validate key -vcmd "Validation::IsHex %P %s $framePath1.en_lower1 %d %i $dataType" -state $state

        set state [$framePath1.en_upper1 cget -state]
        $framePath1.en_upper1 configure -validate none -state normal
        NoteBookManager::InsertHex $framePath1.en_upper1 $dataType
        set UPPER_LIMIT [$framePath1.en_upper1 get]
        $framePath1.en_upper1 configure -validate key -vcmd "Validation::IsHex %P %s $framePath1.en_upper1 %d %i $dataType" -state $state
    } else {
        #already hex is selected
    }
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::InsertHex
#
#  Arguments : entryPath - path of the entry widget
#
#  Results : -
#
#  Description : Convert the value into hexadecimal and insert into the entry widget
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::InsertHex {entryPath dataType} {
    set entryValue [$entryPath get]
    if { $entryValue != "" } {
        $entryPath delete 0 end
        set entryValue [lindex [Validation::InputToHex $entryValue $dataType] 0]
        $entryPath insert 0 $entryValue
    } else {
        $entryPath delete 0 end
        #commented to remove insertion of 0x
        #set entryValue 0x
        $entryPath insert 0 $entryValue
    }
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::AppendZero
#
#  Arguments : input     - string to be append with zero
#              reqLength - length upto zero needs to be appended
#  Results : -
#
#  Description : Append zeros into the input until the required length is reached
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::AppendZero {input reqLength} {
    while {[string length $input] < $reqLength} {
        set input 0$input
    }
    return $input
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::CountLeadZero
#
#  Arguments : input - string
#
#  Results : loopCount - number of leading zeros in input
#
#  Description : Count the leading zeros of the input
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::CountLeadZero {input} {
    for { set loopCount 0 } { $loopCount < [string length $input] } {incr loopCount} {
        if { [string match 0 [string index $input $loopCount] ] == 1 } {
            #continue with next check
        } else {
            break
        }
    }
    return $loopCount
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::SaveValue
#
#  Arguments : frame0 - frame containing the widgets describing the object (index id, Object name, subindex id )
#              frame1 - frame containing the widgets describing properties of object
#
#  Results :  -
#
#  Description : save the entered value for index and subindex
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::SaveValue { frame0 frame1 {objectType ""} } {
    global nodeSelect
    global treePath
    global savedValueList
    global status_save

    #gets the nodeId and Type of selected node
    set result [Operations::GetNodeIdType $nodeSelect]
    if {$result != "" } {
        set nodeId [lindex $result 0]
    } else {
        #must be some other node this condition should never reach
        return
    }

    set state [$frame1.en_value1 cget -state]
    if {[string match "disabled" $state]} {
        # no need to save
        return
    }

    set tmpVar1 [$frame1.en_value1 cget -textvariable]
    global $tmpVar1
    set value [subst $[subst $tmpVar1]]

    set oldName [$treePath itemcget $nodeSelect -text]
    if {[string match "*SubIndexValue*" $nodeSelect]} {
        set subIndexId [string range $oldName end-2 end-1]
        set subIndexId "0x[string toupper $subIndexId]"
        set parent [$treePath parent $nodeSelect]
        set indexId [string range [$treePath itemcget $parent -text ] end-4 end-1]
        set indexId "0x[string toupper $indexId]"
        set idWithBrace [string range $oldName end-5 end ]
        set oldName [string range $oldName 0 end-6]

        set result [openConfLib::SetSubIndexActualValue $nodeId $indexId $subIndexId $value]
        openConfLib::ShowErrorMessage $result
        if { [Result_IsSuccessful $result] != 1 } {
            return
        }
        #value for SubIndex is edited need to change
        set status_save 1
    } elseif {[string match "*IndexValue*" $nodeSelect]} {
        set indexId [string range $oldName end-4 end-1 ]
        set indexId "0x[string toupper $indexId]"
        set idWithBrace [string range $oldName end-7 end ]
        set oldName [string range $oldName 0 end-8]

        set result [openConfLib::SetIndexActualValue $nodeId $indexId $value]
        openConfLib::ShowErrorMessage $result
        if { [Result_IsSuccessful $result] != 1 } {
            return
        }
        #value for SubIndex is edited need to change
        set status_save 1
    } else {
        return
    }

    if { [expr $indexId > 0x1fff] } {
        set lastFocus [focus]
        if { $lastFocus == "$frame1.en_lower1" || $lastFocus == "$frame1.en_upper1" } {
            NoteBookManager::LimitFocusChanged $frame1 $lastFocus
        }
    }

    #Validation::ResetPromptFlag
    if { [lsearch $savedValueList $nodeSelect] == -1 } {
        lappend savedValueList $nodeSelect
    }
    $frame1.en_value1 configure -bg #fdfdd4
    Operations::SingleClickNode $nodeSelect
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::DiscardValue
#
#  Arguments : frame0 - frame containing widgets describing the object (index id, Object name, subindex id )
#              frame1 - frame containing widgets describing properties of object
#
#  Results : -
#
#  Description : Discards the entered values and displays last saved values
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::DiscardValue {frame0 frame1} {
    global nodeSelect
    global userPrefList

    set userPrefList [Operations::DeleteList $userPrefList $nodeSelect 1]
    Validation::ResetPromptFlag
    Operations::SingleClickNode $nodeSelect
    return
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::SaveMNValue
#
#  Arguments : frame0 - frame containing the widgets describing the object (index id, Object name, subindex id )
#              frame1 - frame containing the widgets describing properties of object
#
#  Results :  -
#
#  Description : save the entered value for MN property window
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::SaveMNValue { frame0 frame1 } {
    global nodeSelect
    global treePath
    global status_save
    global MNDatalist

    #gets the nodeId and Type of selected node
    set result [Operations::GetNodeIdType $nodeSelect]
    if {$result != "" } {
        set nodeId [lindex $result 0]
    } else {
            #must be some other node this condition should never reach
            Validation::ResetPromptFlag
            return
    }

    set newNodeName [$frame0.en_nodeName get]
    set result [openConfLib::SetNodeParameter $nodeId $::NODENAME $newNodeName]
    openConfLib::ShowErrorMessage $result
    if { [Result_IsSuccessful $result] != 1 } {
        Validation::ResetPromptFlag
        return
    }

    set status_save 1

    #reconfiguring the tree
    $treePath itemconfigure $nodeSelect -text "$newNodeName\($nodeId\)"

    set MNDatatypeObjectPathList [list \
        [list cycleTimeDatatype $Operations::CYCLE_TIME_OBJ $frame0.cycleframe.en_time] \
        [list lossSoCToleranceDatatype $Operations::LOSS_SOC_TOLERANCE $frame1.en_advOption4] \
        [list asynMTUSizeDatatype $Operations::ASYNC_MTU_SIZE_OBJ $frame1.en_advOption1] \
        [list asynTimeoutDatatype $Operations::ASYNC_TIMEOUT_OBJ $frame1.en_advOption2] \
        [list multiPrescalerDatatype $Operations::MULTI_PRESCAL_OBJ $frame1.en_advOption3] ]

    set dispMsg 0
    foreach tempDatatype $MNDatalist {
        set schDataRes [lsearch $MNDatatypeObjectPathList [list [lindex $tempDatatype 0] * *]]
        if {$schDataRes  != -1 } {
            set dataType [lindex $tempDatatype 1]
            set entryPath [lindex [lindex $MNDatatypeObjectPathList $schDataRes] 2]

            # if entry is disabled no need to save it
            set entryState [$entryPath cget -state]
            if { $entryState != "normal" } {
                continue
            }

            set objectList [lindex [lindex $MNDatatypeObjectPathList $schDataRes] 1]
            set value [$entryPath get]
            set result [Validation::CheckDatatypeValue $entryPath $dataType "dec" $value]
            if { [lindex $result 0] == "pass" } {
                #get the flag and name of the object
                set validValue [lindex $result 1]
                if {$validValue == ""} {
                    #value is empty do not save it
                    set dispMsg 1
                    continue
                }

                if { [ lindex $tempDatatype 0 ] == "lossSoCToleranceDatatype" } {
                    if { [ catch { set validValue [expr $validValue * 1000] } ] } {
                        #error in conversion
                        continue
                    }
                }

                if { [lindex $objectList 1] == "" } {
                    # it is an index
                    set saveCmd "openConfLib::SetIndexActualValue $nodeId [lindex $objectList 0] $validValue"
                } else {
                    #it is a subindex
                    set saveCmd "openConfLib::SetSubIndexActualValue $nodeId [lindex $objectList 0] [lindex $objectList 1] $validValue"
                }

                set result [eval $saveCmd]
                openConfLib::ShowErrorMessage $result
                if { [Result_IsSuccessful $result] != 1 } {
                    Validation::ResetPromptFlag
                    return
                }

                #value for MN porpety is edited need to change
                set status_save 1
                Validation::ResetPromptFlag
            } else {
                continue
            }
        }
    }

    if { $dispMsg == 1 } {
        Console::DisplayWarning "Empty values in MN properties are not saved"
    }
    Validation::ResetPromptFlag
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::SaveCNValue
#
#  Arguments : frame0 - frame containing the widgets describing the object (index id, Object name, subindex id )
#              frame1 - frame containing the widgets describing properties of object
#
#  Results :  -
#
#  Description : save the entered value for MN property window
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::SaveCNValue {nodePos nodeId nodeType frame0 frame1 frame2 {multiPrescalDatatype ""}} {
    global nodeSelect
    global nodeIdList
    global treePath
    global savedValueList
    global userPrefList
    global lastConv
    global status_save
    global CNDatalist
    global cnPropSaveBtn
    global image_dir

    #save node name and node number
    set newNodeId [$frame0.sp_nodeNo get]
    set newNodeId [string trim $newNodeId]
    if {  ( $newNodeId == "" ) || ( ( [string is int $newNodeId] == 1 ) && ( [expr $newNodeId <= 0] ) && ( [expr $newNodeId <= 239] ) ) } {
        tk_messageBox -message "CN node should be in range 1 to 239" -title Warning -icon warning -parent .
        Validation::ResetPromptFlag
        return
    }
    # check whether the node is changed or not
    if { $nodeId != $newNodeId } {
        #chec k that the node id is not an existing node id
        set schDataRes [lsearch $nodeIdList $newNodeId]
        if { $schDataRes != -1 } {
            tk_messageBox -message "The node number \"$newNodeId\" already exists" -title Warning -icon warning -parent .
            Validation::ResetPromptFlag
            return
        }
    }

    #validate whether the entered cycle reponse time is greater tha 1F98 03 value
    set validateResult [$frame0.cycleframe.en_time validate]
    switch -- $validateResult {
        0 {
            #NOTE:: the minimum value is got from vcmd
            set minimumvalue [ lindex [$frame0.cycleframe.en_time cget -vcmd] end-2]
            tk_messageBox -message "The Entered value should not be less than the minimum value $minimumvalue" -parent . -icon warning -title "Error"
            Validation::ResetPromptFlag
        }
        1 {
            set validateResultConfirm [$frame0.cycleframe.en_time validate]

            switch -- $validateResultConfirm {
                0 {
                    set minimumvalue [ lindex [$frame0.cycleframe.en_time cget -vcmd] end-3]
                    set answer [tk_messageBox -message "The Entered value is less than the Set latency value $minimumvalue, Do you wish to continue? " -parent . -type yesno -icon question -title "Warning"]
                    switch -- $answer {
                        yes {
                                #continue
                        }
                        no  {
                                tk_messageBox -message "The Poll Response Timeout values are unchanged" -type ok
                                Validation::ResetPromptFlag
                                return
                        }
                    }
                }
                1 {
                    #continue
                }
            }
        }
    }
    set newNodeName [$frame0.en_nodeName get]
    set stationType [NoteBookManager::RetStationEnumValue]
    set saveSpinVal ""
    #if the check button is enabled and a valid value is obtained from spin box call the API
    set chkState [$frame2.ch_adv cget -state]
    set chkVar [$frame2.ch_adv cget -variable]
    global $chkVar
    set chkVal [subst $[subst $chkVar] ]
    #check the state and if it is selected.
    if { ($chkState == "normal") && ($chkVal == 1) && ($multiPrescalDatatype != "") } {
        #check wheteher a valid data is set or not
        set spinVar [$frame2.sp_cycleNo cget -textvariable]
        global $spinVar
        set spinVal [subst $[subst $spinVar] ]
        set spinVal [string trim $spinVal]
        if { ($spinVal != "") && ([$frame2.sp_cycleNo validate] == 1) } {
            # the entered spin box value is validated save it convert the value to hexadecimal
            # remove the 0x appended to the converted value
            set saveSpinVal [string range [lindex [Validation::InputToHex $spinVal $multiPrescalDatatype] 0] 2 end]
        } else {
            #failed the validation
            tk_messageBox -message "The entered cycle number is not valid" -title Warning -icon warning -parent .
            Validation::ResetPromptFlag
            return
        }
    }

    set CNDatatypeObjectPathList [list \
        [list presponseCycleTimeDatatype $Operations::PRES_TIMEOUT_OBJ $frame0.cycleframe.en_time] ]

    foreach tempDatatype $CNDatalist {
        set schDataRes [lsearch $CNDatatypeObjectPathList [list [lindex $tempDatatype 0] * *]]
        if {$schDataRes  != -1 } {
            set dataType [lindex $tempDatatype 1]
            set entryPath [lindex [lindex $CNDatatypeObjectPathList $schDataRes] 2]

            # if entry is disabled no need to save it
            set entryState [$entryPath cget -state]
            if { $entryState != "normal" } {
                # if entry is disabled no need to save it"
                set validValue ""
                continue
            }
            set objectList [lindex [lindex $CNDatatypeObjectPathList $schDataRes] 1]
            set value [$entryPath get]
            set result [Validation::CheckDatatypeValue $entryPath $dataType "dec" $value]
            if { [lindex $result 0] == "pass" } {
                #get the flag and name of the object
                set validValue [lindex $result 1]
                if { $validValue != "" } {
                    if { [ catch { set validValue [expr $validValue * 1000] } ] } {
                    set validValue ""
                    }
                }
            } else {
                set validValue ""
            }
        }
    }

    set catchErrCode [UpdateNodeParams $nodeId $newNodeId $nodeType $newNodeName $stationType $saveSpinVal $chkVal $validValue]
    set ErrCode [ocfmRetCode_code_get $catchErrCode]
    if { $ErrCode != 0 } {
        if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
            tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error -parent .
        } else {
            tk_messageBox -message "Unknown Error" -title Error -icon error -parent .
        }
        Validation::ResetPromptFlag
        return
    }
    set status_save 1
    #if the forced cycle no is changed and saved subobjects will be added to MN
    #based on the internal logic so need to rebuild the mn tree
    #delete the OBD node and rebuild the tree
    set MnTreeNode [lindex [$treePath nodes ProjectNode] 0]
    set tmpNode [string range $MnTreeNode 2 end]
    #there can be one OBD in MN so -1 is hardcoded
    set ObdTreeNode OBD$tmpNode-1
    catch {$treePath delete $ObdTreeNode}
    #insert the OBD ico only for expert view mode

    image create photo img_pdo -file "$image_dir/pdo.gif"
    if { [string match "EXPERT" $Operations::viewType ] == 1 } {
        $treePath insert 0 $MnTreeNode $ObdTreeNode -text "OBD" -open 0 -image img_pdo
    }
    set mnNodeId 240
    thread::send [tsv::get application importProgress] "StartProgress"
    if { [ catch { set result [WrapperInteractions::Import $ObdTreeNode $mnNodeId] } ] } {
        # error has occured
        thread::send  [tsv::set application importProgress] "StopProgress"
        Operations::CloseProject
        return 0
    }
    thread::send  [tsv::set application importProgress] "StopProgress"

    #save is success reconfigure tree, cnSaveButton and nodeIdlist
    set schDataRes [lsearch $nodeIdList $nodeId]
    set nodeIdList [lreplace $nodeIdList $schDataRes $schDataRes $newNodeId]
    set nodeId $newNodeId
    $cnPropSaveBtn configure -command "NoteBookManager::SaveCNValue $nodePos $nodeId $nodeType $frame0 $frame1 $frame2 $multiPrescalDatatype"
    $treePath itemconfigure $nodeSelect -text "$newNodeName\($nodeId\)"
    Validation::ResetPromptFlag
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::StartEdit
#
#  Arguments : tablePath   - path of the tablelist widget
#              rowIndex    - row of the edited cell
#              columnIndex - column of the edited cell
#              text        - entered value
#
#  Results : text - to be displayed in tablelist
#
#  Description : to validate the entered value
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::StartEdit {tablePath rowIndex columnIndex text} {

    set win [$tablePath editwinpath]
    switch -- $columnIndex {
        1 {
            $win configure -invalidcommand bell -validate key  -validatecommand "Validation::IsTableHex %P %s %d %i 2 $tablePath $rowIndex $columnIndex $win"
        }
        2 {
            $win configure -invalidcommand bell -validate key  -validatecommand "Validation::IsTableHex %P %s %d %i 4 $tablePath $rowIndex $columnIndex $win"
        }
        3 {
            $win configure -invalidcommand bell -validate key  -validatecommand "Validation::IsTableHex %P %s %d %i 2 $tablePath $rowIndex $columnIndex $win"
        }
        4 {
            $win configure -invalidcommand bell -validate key  -validatecommand "Validation::IsTableHex %P %s %d %i 4 $tablePath $rowIndex $columnIndex $win"
        }
        5 {
            $win configure -invalidcommand bell -validate key  -validatecommand "Validation::IsTableHex %P %s %d %i 4 $tablePath $rowIndex $columnIndex $win"
        }
    }
    return $text
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::StartEditCombo
#
#  Arguments :  tablePath   - path of the tablelist widget
#       rowIndex    - row of the edited cell
#       columnIndex - column of the edited cell
#       text        - entered value
#
#  Results : text - to be displayed in tablelist
#
#  Description : to validate the entered value
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::StartEditCombo {tablePath rowIndex columnIndex text} {
    global treePath

    # no need to get the nodeid from 18xx or 14xx
    #set nodeidVal [$tablePath cellcget $rowIndex,1 -text]
    #set result [regexp {[\(][0-9]+[\)]} $nodeidVal match]
    #puts "Result: $result match: $match"
    #set locNodeId [string range $match 1 end-1]
    #puts "$locNodeId"

    set idxidVal [$tablePath cellcget $rowIndex,2 -text]

    set result [regexp {[\(]0[xX][0-9a-fA-F]+[\)]} $idxidVal match]
    set locIdxId [string range $match 1 end-1]

    set sidxVal [$tablePath cellcget $rowIndex,3 -text]
    set result [regexp {[\(]0[xX][0-9a-fA-F]+[\)]} $sidxVal match]
    set locSidxId [string range $match 1 end-1]

    set lengthVal [$tablePath cellcget $rowIndex,4 -text]
    set offsetVal [$tablePath cellcget $rowIndex,5 -text]

    set selectedNode [$treePath selection get]
    set pdoType "[$treePath itemcget $selectedNode -text ]"
    set result [Operations::GetNodeIdType $selectedNode]
    set locNodeId [lindex $result 0]

    set win [$tablePath editwinpath]
    $win configure -editable no
    switch -- $columnIndex {
        1 {
            set locNodeIdList [Operations::GetNodelistWithName]
            $win configure -values "$locNodeIdList"
            $win configure -invalidcommand bell -validate key -validatecommand "Validation::SetTableComboValue %P $tablePath $rowIndex $columnIndex $win"
        }
        2 {
            set idxList [Operations::GetIndexListWithName $locNodeId $pdoType]
            set idxList [lappend idxList "Default\(0x0000\)"]
            set idxList [lsort $idxList]
            $win configure -values "$idxList"
            $win configure -invalidcommand bell -validate key  -validatecommand "Validation::SetTableComboValue %P $tablePath $rowIndex $columnIndex $win"
        }
        3 {
            set sidxList [Operations::GetSubIndexlistWithName $locNodeId $locIdxId $pdoType]
            set sidxList [lappend sidxList "Default\(0x00\)"]
            set sidxList [lsort $sidxList]
            $win configure -values "$sidxList"
            $win configure -invalidcommand bell -validate key  -validatecommand "Validation::SetTableComboValue %P $tablePath $rowIndex $columnIndex $win"
            }
        4 {
            set sidxLength [Operations::FuncSubIndexLength $locNodeId $locIdxId $locSidxId]
            set sidxLength [lappend sidxLength "0x0000"]
            set sidxLength [lsort $sidxLength]
            $win configure -values "$sidxLength"
            $win configure -invalidcommand bell -validate key  -validatecommand "Validation::SetTableComboValue %P $tablePath $rowIndex $columnIndex $win"
        }
        5 {
            #puts "Offset Loading"
            #Nothing to do for offset. Entry greyed out.
        }
    }
    return $text
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::EndEdit
#
#  Arguments : tablePath   - path of the tablelist widget
#              rowIndex    - row of the edited cell
#              columnIndex - column of the edited cell
#              text        - entered value
#
#  Results : text - to be displayed in tablelist
#
#  Description : to validate the entered value when focus leave the cell
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::EndEdit {tablePath rowIndex columnIndex text} {
    return $text
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::SaveTable
#
#  Arguments : tableWid - path of the tablelist widget
#
#  Results : -
#
#  Description : to validate and save the validated values in tablelist widget
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::SaveTable {tableWid} {
    global nodeSelect
    global treePath
    global status_save
    global populatedPDOList
    global populatedCommParamList
    global st_autogen

    set result [$tableWid finishediting]
    if {$result == 0} {
        Validation::ResetPromptFlag
        return
    } else {
    }
    # should save entered values to corresponding subindex
    set result [Operations::GetNodeIdType $nodeSelect]
    set nodeId [lindex $result 0]
    set rowCount 0
    set flag 0

    set result [openConfLib::IsExistingNode $nodeId]
    openConfLib::ShowErrorMessage [lindex $result 0]
    if {[lindex $result 1] == 0 && [Result_IsSuccessful [lindex $result 0]] != 1} {
        Validation::ResetPromptFlag
        return
    }

    #sort the tablelist based on the No column
    $tableWid sortbycolumn 0 -increasing
    update

    foreach childIndex $populatedPDOList {
        set indexId [string range [$treePath itemcget $childIndex -text] end-4 end-1]
        foreach childSubIndex [$treePath nodes $childIndex] {
            set subIndexId [string range [$treePath itemcget $childSubIndex -text] end-2 end-1]
            if {[string match "00" $subIndexId]} {
                # Reset the 00th subindex of a Mapping index
                set result [openConfLib::SetSubIndexActualValue $nodeId 0x$indexId "0x00" "0x00"]
            } else {
                set offset [string range [$tableWid cellcget $rowCount,5 -text] 2 end]
                set length [string range [$tableWid cellcget $rowCount,4 -text] 2 end]
                set reserved 00

                if {$st_autogen == 1 } {
                    set sidxVal [$tableWid cellcget $rowCount,3 -text]
                    set result [regexp {[\(]0[xX][0-9a-fA-F]+[\)]} $sidxVal match]
                    set locSidxId [string range $match 3 end-1]

                    set idxVal [$tableWid cellcget $rowCount,2 -text]
                    set result [regexp {[\(]0[xX][0-9a-fA-F]+[\)]} $idxVal match]
                    set locIdxId [string range $match 3 end-1]
                    #set index [string range [$tableWid cellcget $rowCount,2 -text] end-4 end-1]
                    #set subindex [string range [$tableWid cellcget $rowCount,3 -text] end-2 end-1]
                } else {
                    set locIdxId [string range [$tableWid cellcget $rowCount,2 -text] 2 end]
                    set locSidxId [string range [$tableWid cellcget $rowCount,3 -text] 2 end]
                }

                set value $length$offset$reserved$locSidxId$locIdxId
                puts "value:::: $value"
                if { [string length $value] != 16 } {
                    set flag 1
                    incr rowCount
                    continue
                } else {
                    set value 0x$value
                }
                set result [openConfLib::IsExistingSubIndex $nodeId 0x$indexId 0x$subIndexId]
                if { [lindex $result 1] } {
                    set result [openConfLib::SetSubIndexActualValue $nodeId 0x$indexId 0x$subIndexId $value]

                    if { [expr [expr 0x$locIdxId > 0x0000 ] && [expr 0x$length > 0x0000 ]]} {
                        # if The value is valid and the 00th subindex is set to the subindex id. But Spec says: Number of mapped objects.
                        # TODO Need to discuss.
                        set result [openConfLib::SetSubIndexActualValue $nodeId 0x$indexId "0x00" "0x$subIndexId"]
                    }
                }
                incr rowCount
            }
        }
    }

    #saving the nodeid to communication parameter subindex 01
    foreach childIndex $populatedCommParamList {
        set treeNode [lindex $childIndex 1]
        if {[$treePath exists $treeNode] == 0} {
            continue;
        }
        set indexId [string range [$treePath itemcget $treeNode -text] end-4 end-1]
        foreach childSubIndex [$treePath nodes $treeNode] {
            set subIndexId [string range [$treePath itemcget $childSubIndex -text] end-2 end-1]
            set name [string range [$treePath itemcget $childSubIndex -text] 0 end-6]
            set rowCount [lindex [lindex $childIndex 2] 0]
            if { [string match "01" $subIndexId] } {
                #
                if { $rowCount == ""} {
                    break
                }
                if {$st_autogen == 1 } {
                    set enteredNodeIdstr [$tableWid cellcget $rowCount,1 -text]
                    set result [regexp {[\(][0-9]+[\)]} $enteredNodeIdstr match]
                    set value [string range $match 1 end-1]
                } else {
                    set value [string range [$tableWid cellcget $rowCount,1 -text] 2 end]
                }

                puts "value: $value"

                #0x is appended when saving value to indicate it is a hexa decimal number
                #if { ([string length $value] < 1) || ([string length $value] > 2) } {
                #    #set flag 1
                #    break
                #} else {
                #    set value 0x$value
                #}

                set result [openConfLib::IsExistingSubIndex $nodeId 0x$indexId 0x$subIndexId]
                if { [lindex $result 1] } {
                    set result [openConfLib::SetSubIndexActualValue $nodeId 0x$indexId "0x$subIndexId" $value]
                    break
                }
            }
        }
    }
    if { $flag == 1} {
        Console::DisplayInfo "Only the PDO mapping table entries that are completely filled(Offset, Length, Index and Sub Index) are saved"
    }

    #PDO entries value is changed need to save
    set status_save 1
    #set populatedPDOList ""
    Validation::ResetPromptFlag
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::DiscardTable
#
#  Arguments : tableWid  - path of the tablelist widget
#
#  Results : -
#
#  Description : Discards the entered values and displays last saved values
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::DiscardTable {tableWid} {

    global nodeSelect

    Validation::ResetPromptFlag

    Operations::SingleClickNode $nodeSelect
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::GetComboValue
#
#  Arguments : comboPath - path of the Combobox widget
#
#  Results : selected value
#
#  Description : gets the selected index and returns the corresponding value
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::GetComboValue {comboPath} {
    set comboState [$comboPath cget -state]
    set value [$comboPath getvalue]
    if { $value == -1 } {
        #nothing was selected
        $comboPath configure -state $comboState
        return []
    }
    set valueList [$comboPath cget -values]
    $comboPath configure -state $comboState
    return [lindex $valueList $value]

}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::GetEntryValue
#
#  Arguments : entryPath - path of the entry box widget
#
#  Results : selected value
#
#  Description : gets the value entered in entry widget
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::GetEntryValue {entryPath} {
    set entryState [$entryPath cget -state]
    set entryValue [$entryPath get]
    $entryPath configure -state $entryState
    return $entryValue
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::SetEntryValue
#
#  Arguments : entryPath - path of the entry box widget
#
#  Results : selected value
#
#  Description : gets the value entered in entry widget
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::SetEntryValue {entryPath insertValue} {
    set entryState [$entryPath cget -state]
    $entryPath configure -state normal
    $entryPath delete 0 end
    $entryPath insert 0 $insertValue
    $entryPath configure -state $entryState
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::GenerateCnNodeList
#
#  Arguments : comboPath  - path of the Combobox widget
#              value      - value to set into the Combobox widget
#
#  Results : selected value
#
#  Description : gets the selected value and sets the value into the Combobox widget
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::GenerateCnNodeList {} {
    set cnNodeList ""
    for { set inc 1 } { $inc < 240 } { incr inc } {
        lappend cnNodeList $inc
    }
    return $cnNodeList
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::StationRadioChanged
#
#  Arguments : framePath   - path of frame containing the check button
#              radioVal   - varaible of the radio buttons
#
#  Results : -
#
#  Description : enables or disasbles the spinbox based on the check button selection
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::StationRadioChanged {framePath radioVal } {
    global lastRadioVal
    if { $lastRadioVal != $radioVal } {
        Validation::SetPromptFlag
    }
    set lastRadioVal $radioVal
    set spinVar [$framePath.sp_cycleNo cget -textvariable]
    global $spinVar
    if { $radioVal == "StNormal" } {
        $framePath.ch_adv deselect
        $framePath.ch_adv configure -state disabled
        $framePath.sp_cycleNo configure  -state disabled
    } elseif { $radioVal == "StMulti" } {
        $framePath.ch_adv configure -state normal
    } elseif { $radioVal == "StChain" } {
        $framePath.ch_adv deselect
        $framePath.ch_adv configure -state disabled
        $framePath.sp_cycleNo configure  -state disabled
    } else {

    }
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::forceCycleChecked
#
#  Arguments : framePath   - path of frame containing the check button
#              check_var   - varaible of the check box
#
#  Results : -
#
#  Description : enables or disasbles the spinbox based on the check button selection
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::forceCycleChecked { framePath check_var } {
    global $check_var
    Validation::SetPromptFlag
    set check_value [subst $[subst $check_var]]
    if { $check_value == 1 } {
        $framePath.sp_cycleNo configure -state normal -bg white
    } else {
        $framePath.sp_cycleNo configure -state disabled
    }
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::RetStationEnumValue
#
#  Arguments : -
#
#  Results : -
#
#  Description : enables or disasbles the spinbox based on the check button selection
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::RetStationEnumValue {  } {
    global f4
    set radioButtonFrame [lindex $f4 2]
    set ra_StNormal $radioButtonFrame.ra_StNormal
    set radioVar [$ra_StNormal cget -variable]

    global $radioVar
    set radioVal [subst $[subst $radioVar]]

    switch -- $radioVal {
        StNormal {
            set returnVal 0
        }
        StMulti {
            set returnVal 1
        }
        StChain {
            set returnVal 2
        }
    }

    return $returnVal
}

#---------------------------------------------------------------------------------------------------
#  NoteBookManager::LimitFocusChanged
#
#  Arguments : -
#
#  Results : -
#
#  Description : based on the entry path it validates value with upper limit or lower limit
#---------------------------------------------------------------------------------------------------
proc NoteBookManager::LimitFocusChanged {framePath entryPath} {
    catch {
        global UPPER_LIMIT
        global LOWER_LIMIT

        set dontCompareValue 0
        set valueState [$framePath.en_value1 cget -state]
        set valueInput [$framePath.en_value1 get]
        if { $valueState != "normal" || $valueInput == "" || $valueInput == "-" || [string match -nocase "0x" $valueInput] } {
            set dontCompareValue 1
        }

        set msg ""
        if {[string match "*.en_lower1" $entryPath]} {
            set lowervalueState [$framePath.en_lower1 cget -state]
            set lowervalueInput [$framePath.en_lower1 get]
            if { $lowervalueInput == "" || $lowervalueInput == "-" || [string match -nocase "0x" $lowervalueInput] } {
                set lowervalueInput ""
                set LOWER_LIMIT ""
                return 1
            }
            if { $lowervalueState != "normal" } {
                return 1
            }

            if { $lowervalueInput != "" && $UPPER_LIMIT != ""} {
                if { [ catch { set lowerlimitResult [expr $lowervalueInput <= $UPPER_LIMIT] } ] } {
                    SetEntryValue $framePath.en_lower1 ""
                    set LOWER_LIMIT ""
                    set msg "Error in comparing lowerlimit($lowervalueInput) and upperlimit($UPPER_LIMIT). lowerlimit is made empty"
                }
                if { $lowerlimitResult == 0 } {
                    SetEntryValue $framePath.en_lower1 ""
                    set LOWER_LIMIT ""
                    set msg "The entered lowerlimit($lowervalueInput) is greater than upperlimit($UPPER_LIMIT). lowerlimit is made empty"
                }

                if {$msg != ""} {
                    Console::DisplayWarning $msg
                    return 0
                }
            }

            set LOWER_LIMIT $lowervalueInput

            if { $LOWER_LIMIT != "" && $dontCompareValue == 0} {
                if { [ catch { set lowerlimitResult [expr $valueInput >= $LOWER_LIMIT] } ] } {
                    set msg "Error in comparing input($valueInput) and lowerlimit($lowervalueInput)."
                    Console::DisplayWarning $msg
                    return 1
                }
                if { $lowerlimitResult == 0 } {
                    SetEntryValue $framePath.en_value1 $LOWER_LIMIT
                    set msg "The entered input($valueInput) is lesser than lowerlimit($LOWER_LIMIT).lower limit is copied into the value"
                    Console::DisplayWarning $msg
                    return 1
                }
            }
        } elseif {[string match "*.en_upper1" $entryPath]} {
            set uppervalueState [$framePath.en_upper1 cget -state]
            set uppervalueInput [$framePath.en_upper1 get]
            if { $uppervalueInput == "" || $uppervalueInput == "-" || [string match -nocase "0x" $uppervalueInput] } {
                set uppervalueInput ""
                set UPPER_LIMIT ""
                return 1
            }
            if { $uppervalueState != "normal" } {
                return 1
            }

            if { $uppervalueInput != "" && $LOWER_LIMIT != "" } {
                if { [ catch { set upperlimitResult [expr $uppervalueInput >= $LOWER_LIMIT] } ] } {
                    SetEntryValue $framePath.en_upper1 ""
                    set UPPER_LIMIT ""
                    set msg "Error in comparing upperlimit($uppervalueInput) and lowerlimit($LOWER_LIMIT). upperlimit is made empty"
                }

                if { $upperlimitResult == 0 } {
                    SetEntryValue $framePath.en_upper1 ""
                    set UPPER_LIMIT ""
                    set msg "The entered upperlimit($uppervalueInput) is lesser than lowerlimit($LOWER_LIMIT). upperlimit is made empty"
                }
                if {$msg != ""} {
                    Console::DisplayWarning $msg
                    return 0
                }
            }
            set UPPER_LIMIT $uppervalueInput

            if { $UPPER_LIMIT != "" && $dontCompareValue == 0} {
                if { [ catch { set upperlimitResult [expr $valueInput <= $UPPER_LIMIT] } ] } {
                    set msg "Error in comparing input($valueInput) and upperlimit($UPPER_LIMIT)."
                    Console::DisplayWarning $msg
                    return 1
                }
                if { $upperlimitResult == 0 } {
                    SetEntryValue $framePath.en_value1 $UPPER_LIMIT
                    set msg "The entered input($valueInput) is greater than upperlimit($UPPER_LIMIT). upperlimit is copied into the value"
                    Console::DisplayWarning $msg
                    return 1
                }
            }
        }
    }
}

proc NoteBookManager::ValueFocusChanged {framePath entryPath} {
    catch {
        set valueState [$entryPath cget -state]
        set valueInput [$entryPath get]
        if { $valueState != "normal" || $valueInput == "" || $valueInput == "-" || [string match -nocase "0x" $valueInput] } {
            puts "returning focus changed"
            return
        }
        if { [string match "*.en_value1" $entryPath] } {
            set limitResult [Validation::CheckAgainstLimits $entryPath $valueInput ]
            if { [lindex $limitResult 0] == 0 } {
                Console::DisplayWarning [lindex $limitResult 1]
                return 0
            }
        }
        return 1
    }
}
