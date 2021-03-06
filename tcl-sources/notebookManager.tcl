################################################################################
# \file   notebookManager.tcl
#
# \brief  Creates the windows (tablelist, console, tabs, tree)
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
#  namespace: NoteBookManager
#-------------------------------------------------------------------------------
namespace eval NoteBookManager {
    variable _pageCounter 0
    variable _consoleCounter 0
}

#-------------------------------------------------------------------------------
#  NoteBookManager::create_tab
#
#  Arguments: nbpath - frame path to create
#             choice - choice for index or subindex to create frame
#
#  Results: outerFrame - Basic frame
#           tabInnerf0 - frame containing widgets describing the object (index id, Object name, subindex id )
#           tabInnerf1 - frame containing widgets describing properties of object
#
#  Description: Creates the GUI for index and subindex
#-------------------------------------------------------------------------------
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
    set tabTitlef0 [TitleFrame $uf.tabTitlef0 -text "Sub-object" ]
    set tabInnerf0 [$tabTitlef0 getframe]
    set tabTitlef1 [TitleFrame $uf.tabTitlef1 -text "Properties" ]
    set tabInnerf1 [$tabTitlef1 getframe]
    set tabInnerf0_1 [frame $tabInnerf0.frame1 ]

    label $tabInnerf0.la_idx     -text "Object ID  "
    label $tabInnerf0.la_empty1 -text ""
    label $tabInnerf0.la_empty2 -text ""
    label $tabInnerf0.la_nam     -text "Name           "
    label $tabInnerf0.la_empty3 -text ""
    label $tabInnerf0_1.la_generate -text ""
    label $tabInnerf1.la_obj     -text "Object type"
    label $tabInnerf1.la_empty4 -text ""
    label $tabInnerf1.la_data    -text "Data type"
    label $tabInnerf1.la_empty5 -text ""
    label $tabInnerf1.la_access  -text "Access type"
    label $tabInnerf1.la_empty6 -text ""
    label $tabInnerf1.la_value   -text "Value"
    label $tabInnerf1.la_default -text "Default value"
    label $tabInnerf1.la_upper   -text "Upper limit"
    label $tabInnerf1.la_lower   -text "Lower limit"
    label $tabInnerf1.la_pdo   -text "PDO mapping"

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
        $tabTitlef0 configure -text "Object"
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
        $tabTitlef0 configure -text "Sub-object"
        $tabTitlef1 configure -text "Properties"

        label $tabInnerf0.la_sidx -text "Sub-object ID"
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

#-------------------------------------------------------------------------------
#  NoteBookManager::create_nodeFrame
#
#  Arguments: nbpath - frame path to create
#             choice - choice for pdo to create frame
#
#  Results: basic frame on which all widgets are created
#           tablelist widget path
#
#  Description: Creates the tablelist for TPDO and RPDO
#-------------------------------------------------------------------------------
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
    label $tabInnerf0.cycleframe.la_ms           -text "�s"
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

    grid config $tabTitlef0 -row 0 -column 0 -sticky ew -ipady 7

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
        $tabInnerf0.la_time  configure -text "Cycle time"

        $tabInnerf0.tabTitlef1 configure -text "Advanced"
        $tabInnerf0.en_nodeNo configure -state disabled
        $tabInnerf1.la_advOption4 configure  -text "Loss of SoC tolerance"
        $tabInnerf1.la_advOptionUnit4 configure -text "�s"
        $tabInnerf1.la_advOption1 configure -text "Asynchronous MTU size"
        $tabInnerf1.la_advOptionUnit1 configure -text "Bytes"
        $tabInnerf1.la_advOption2 configure -text "Asynchronous timeout"
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
        $tabInnerf0.la_time  configure -text "PollResponse timeout"
        $tabInnerf0.tabTitlef1 configure -text "Type of station"

        set tabTitlef2 [TitleFrame $tabInnerf1.tabTitlef2 -text "Advanced" ]
        set tabInnerf2 [$tabTitlef2 getframe]
        set ch_adv [checkbutton $tabInnerf2.ch_adv -onvalue 1 -offvalue 0 -command "NoteBookManager::forceCycleChecked $tabInnerf2 ch_advanced" -variable ch_advanced -text "Force cycle"]
        spinbox $tabInnerf2.sp_cycleNo -state normal -textvariable spCycleNoList$_pageCounter \
            -bg white -width $spinWidth \
            -from 1 -to 239 -increment 1 -justify center

        grid config $ra_StNormal          -row 0 -column 0 -sticky w -padx 5
        grid config $tabInnerf1.la_empty4 -row 1 -column 0
        grid config $ra_StChain           -row 2 -column 0 -sticky w -padx 5
        grid config $tabInnerf1.la_empty5 -row 3 -column 0
        grid config $ra_StMulti           -row 4 -column 0 -sticky w -padx 5
        grid config $tabTitlef2           -row 5 -column 0 -sticky e -columnspan 2 -padx 20
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

#-------------------------------------------------------------------------------
#  NoteBookManager::create_table
#
#  Arguments: nbpath - frame path to create
#             choice - choice for pdo to create frame
#
#  Results: basic frame on which all widgets are created
#           tablelist widget path
#
#  Description: Creates the tablelist for TPDO and RPDO
#-------------------------------------------------------------------------------
proc NoteBookManager::create_table {nbpath choice} {
    variable _pageCounter
    incr _pageCounter

    global tableSaveBtn

    set nbname "page$_pageCounter"
    set outerFrame [frame $nbpath.$nbname -relief raised -borderwidth 1 ]
    set frmPath [frame $outerFrame.frmPath -relief flat -borderwidth 10  ]
    pack $frmPath -expand yes -fill both

    set scrollWin11 [ScrolledWindow $frmPath.scrollWin11 -auto horizontal -scrollbar horizontal]
    pack $scrollWin11 -fill x -side top
    #-expand yes

    set sf1 [ScrollableFrame $scrollWin11.sf1]
    $sf1 configure -height 120
    $scrollWin11 setwidget $sf1

    set uf [$sf1 getframe]
    $uf configure -height 20 -width 800
    set propertyFrame [TitleFrame $uf.propertyFrame -text "Properties" ]
    set propInFrm [ $propertyFrame getframe ]
    pack $propertyFrame -side top -fill x -expand true
    # -expand yes

    ttk::label $propInFrm.la_empty -text "  "
    ttk::label $propInFrm.la_emptyrow1 -text "  "
    ttk::label $propInFrm.la_emptyrow2 -text "  "
    ttk::label $propInFrm.la_emptycol1 -text "      "
    ttk::label $propInFrm.la_emptycol3 -text "      "
    ttk::label $propInFrm.la_comparam -text "Communication parameter"
    ttk::label $propInFrm.la_mapparam -text "Mapping parameter"
    ttk::label $propInFrm.la_sendto -text "Send to (Node ID)"
    ttk::label $propInFrm.la_numberofentries -text "Number of valid entries"
    ttk::label $propInFrm.la_mapver -text "Mapping version "
    ttk::label $propInFrm.la_totalbytes -text "Total bytes  "
    ttk::label $propInFrm.la_empty3 -text "  "

    ttk::combobox $propInFrm.com_sendto
    ttk::entry $propInFrm.en_numberofentries -width 23 -justify left -validate key -textvariable pdo_en_numberofentries  -validatecommand "NoteBookManager::PDO_NumberOfEntries_EditingFinished %P $propInFrm %d %i UNSIGNED8"
    ttk::entry $propInFrm.en_mapver -width 20 -textvariable pdo_en_mapver -justify left -validate key -validatecommand "Validation::IsHex %P %s $propInFrm.en_mapver %d %i integer8"
    ttk::entry $propInFrm.en_comparam -state disabled -width 20
    ttk::entry $propInFrm.en_mapparam -state disabled -width 20
    ttk::entry $propInFrm.en_totalbytes -state disabled -width 20 -textvariable pdo_en_totalbytes

    tooltip::tooltip $propInFrm.en_numberofentries "Number of valid entries"
    tooltip::tooltip $propInFrm.en_totalbytes "Total number of bytes that will be used for mapping."

    grid config $propInFrm.la_empty -row 0 -column 0 -padx 5
    grid config $propInFrm.la_emptyrow1 -row 1 -column 0 -padx 5 -pady 4
    grid config $propInFrm.la_comparam -row 0 -column 1 -sticky w
    grid config $propInFrm.en_comparam -row 0 -column 2 -sticky w
    grid config $propInFrm.la_mapparam -row 2 -column 1 -sticky w
    grid config $propInFrm.en_mapparam -row 2 -column 2 -sticky w
    grid config $propInFrm.la_emptycol1 -row 0 -column 3 -sticky w -rowspan 2
    grid config $propInFrm.la_sendto -row 0 -column 5 -sticky w
    grid config $propInFrm.com_sendto -row 0 -column 6 -sticky w
    grid config $propInFrm.la_numberofentries -row 2 -column 5 -sticky w
    grid config $propInFrm.en_numberofentries -row 2 -column 6 -sticky w
    grid config $propInFrm.la_emptycol3 -row 0 -column 7 -sticky w -rowspan 2
    grid config $propInFrm.la_mapver -row 0 -column 9 -sticky w
    grid config $propInFrm.en_mapver -row 0 -column 10 -sticky w
    grid config $propInFrm.la_totalbytes -row 2 -column 9 -sticky w
    grid config $propInFrm.en_totalbytes -row 2 -column 10 -sticky w
    grid config $propInFrm.la_empty3 -row 0 -column 11 -padx 10 -sticky we
    grid config $propInFrm.la_emptyrow2 -row 3 -column 0 -padx 5 -pady 4

    pack $propInFrm -side top -fill x -expand true
    # -expand true

    set scrollWin [ScrolledWindow $frmPath.scrollWin  ]
    pack $scrollWin -fill both -side top -expand true
    set st $frmPath.st

    catch "font delete custom1"
    font create custom1 -size 9 -family TkDefaultFont

    if {$choice == "pdo"} {
        set st [tablelist::tablelist $st \
            -columns {0 "No" left
            0 "Object" center
            0 "Sub-object" center
            0 "Length (bits)" center
            0 "Offset" center} \
            -setgrid 0 -width 0 \
            -stripebackground gray98 \
            -resizable 1 -movablecolumns 0 -movablerows 0 \
            -showseparators 1 -spacing 10 -font custom1 \
            -editstartcommand NoteBookManager::StartEdit -editendcommand NoteBookManager::EndEdit ]

        $st columnconfigure 0 -editable no
        $st columnconfigure 1 -editable yes -editwindow entry
        $st columnconfigure 2 -editable yes -editwindow entry
        $st columnconfigure 3 -editable yes -editwindow entry
        $st columnconfigure 4 -editable yes -editwindow entry

    } elseif {$choice == "AUTOpdo"} {
        set st [tablelist::tablelist $st \
            -columns {0 "S.No" left
            0 "Object" center
            0 "Sub-object" center
            0 "Length" center
            0 "Offset" center} \
            -setgrid 0 -width 0 \
            -stripebackground gray98 \
            -resizable 1 -movablecolumns 0 -movablerows 0 \
            -showseparators 1 -spacing 10 -font custom1 \
            -editstartcommand NoteBookManager::StartEditCombo \
            -editendcommand NoteBookManager::EndEditCombo]

            $st columnconfigure 0 -editable no
            $st columnconfigure 1 -editable no -editwindow ComboBox
            $st columnconfigure 2 -editable no -editwindow ComboBox
            $st columnconfigure 3 -editable no
            $st columnconfigure 4 -editable no
    } else {
        #invalid choice
        return
    }

    $scrollWin setwidget $st
    pack $st -fill both -expand true -side top
    $st configure -height 4 -width 40 -stretch {1 2}

    set fram [ frame $frmPath.f1 ]
    label $fram.la_empty -text "  " -height 1
    set tableSaveBtn [ button $fram.bt_sav -text " Save " -width 8 -command "NoteBookManager::SaveTable $st $propInFrm" ]
    label $fram.la_empty1 -text "  "
    button $fram.bt_dis -text "Discard" -width 8 -command "NoteBookManager::DiscardTable $st"
    grid config $fram.la_empty -row 0 -column 0 -columnspan 2
    grid config $fram.bt_sav -row 1 -column 0 -sticky s
    grid config $fram.la_empty1 -row 1 -column 1 -sticky s
    grid config $fram.bt_dis -row 1 -column 2 -sticky s
    pack $fram -side top

    return  [list $outerFrame $st $propInFrm]
}

#-------------------------------------------------------------------------------
#  NoteBookManager::create_infoWindow
#
#  Arguments: nbpath - path of the notebook
#             tabname - title for the created tab
#             choice - choice to create information, error and warning windows
#
#  Results: Path of the inserted frame in notebook
#
#  Description: Creates information, error and warning message windows
#-------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------
#  NoteBookManager::create_treeBrowserWindow
#
#  Arguments: nbpath - path of the notebook
#
#  Results: path of the inserted frame in notebook
#           path of the tree widget
#
#  Description: Creates the tree widget in notebook
#-------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------
#  NoteBookManager::ConvertDec
#
#  Arguments: framePath - Path of the frame containing value and default entry widget
#
#  Results: -
#
#  Description: Converts value into decimal and changes validation for entry
#-------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------
#  NoteBookManager::InsertDecimal
#
#  Arguments: entryPath - Path of the entry widget
#
#  Results: -
#
#  Description: Convert the value into decimal and inserts it into the entry widget
#-------------------------------------------------------------------------------
proc NoteBookManager::InsertDecimal {entryPath dataType} {
    set entryValue [$entryPath get]
    if { [string match -nocase "0x*" $entryValue] } {
        set entryValue [string range $entryValue 2 end]
    }

    $entryPath delete 0 end
    set entryValue [lindex [Validation::InputToDec $entryValue $dataType] 0]
    $entryPath insert 0 $entryValue
}

#-------------------------------------------------------------------------------
#  NoteBookManager::ConvertHex
#
#  Arguments: framePath - Path containing the value and default entry widget
#
#  Results: -
#
#  Description: Converts the value to hexadecimal and changes validation for entry
#-------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------
#  NoteBookManager::InsertHex
#
#  Arguments: entryPath - Path of the entry widget
#
#  Results: -
#
#  Description: Convert the value into hexadecimal and inserts it into the entry widget
#-------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------
#  NoteBookManager::AppendZero
#
#  Arguments: input - string to be append with zero
#             reqLength - length upto zero needs to be appended
#  Results: -
#
#  Description: Append zeros to the input until the required length is reached
#-------------------------------------------------------------------------------
proc NoteBookManager::AppendZero {input reqLength} {
    while {[string length $input] < $reqLength} {
        set input 0$input
    }
    return $input
}

#-------------------------------------------------------------------------------
#  NoteBookManager::CountLeadZero
#
#  Arguments: input - string
#
#  Results: loopCount - number of leading zeros in input
#
#  Description: Count the leading zeros of the input
#-------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------
#  NoteBookManager::SaveValue
#
#  Arguments: frame0 - frame containing the widgets describing the object (index id, Object name, subindex id )
#             frame1 - frame containing the widgets describing properties of object
#
#  Results:  -
#
#  Description: Save the entered value for index and subindex
#-------------------------------------------------------------------------------
proc NoteBookManager::SaveValue { frame0 frame1 {objectType ""} } {
    global nodeSelect
    global treePath
    global savedValueList
    global status_save

    #gets the nodeId and Type of selected node
    set result [Operations::GetNodeIdType $nodeSelect]
    if {$result != -1 } {
        set nodeId $result
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

        set forceCDC_state [$frame0.frame1.ch_gen cget -state]
        if {[string match "disabled" $forceCDC_state]} {
            # Force CDC export option is already disabled.
        } else {
            set chkGen [$frame0.frame1.ch_gen cget -variable]
            global $chkGen

            set checkBoxValue [subst $[subst $chkGen]]
            # puts "$nodeId $indexId $subIndexId CHECKBOX VALUE: $checkBoxValue --- $::FORCETOCDC"
            set result [openConfLib::SetSubIndexAttribute $nodeId $indexId $subIndexId $::FORCETOCDC $checkBoxValue]
            openConfLib::ShowErrorMessage $result
            if { [Result_IsSuccessful $result] != 1 } {
                return
            }
        }
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

        set forceCDC_state [$frame0.frame1.ch_gen cget -state]
        if {[string match "disabled" $forceCDC_state]} {
            # Force CDC export option is already disabled.
        } else {
            set chkGen [$frame0.frame1.ch_gen cget -variable]
            global $chkGen
            set checkBoxValue [subst $[subst $chkGen]]
            # puts "$nodeId $indexId CHECKBOX VALUE: $checkBoxValue --- $::FORCETOCDC"
            set result [openConfLib::SetIndexAttribute $nodeId $indexId $::FORCETOCDC $checkBoxValue]
            openConfLib::ShowErrorMessage $result
            if { [Result_IsSuccessful $result] != 1 } {
                return
            }
        }
    } else {
        return
    }

    if { [expr $indexId > 0x1fff] } {
        set lastFocus [focus]
        if { $lastFocus == "$frame1.en_lower1" || $lastFocus == "$frame1.en_upper1" } {
            NoteBookManager::LimitFocusChanged $frame1 $lastFocus
        }
    }

    Validation::ResetPromptFlag

    if { [lsearch $savedValueList $nodeSelect] == -1 } {
        lappend savedValueList $nodeSelect
    }
    $frame1.en_value1 configure -bg #fdfdd4
    Operations::SingleClickNode $nodeSelect
}

#-------------------------------------------------------------------------------
#  NoteBookManager::DiscardValue
#
#  Arguments: frame0 - frame containing widgets describing the object (index id, Object name, subindex id )
#             frame1 - frame containing widgets describing properties of object
#
#  Results: -
#
#  Description: Discards the entered values and displays last saved values
#-------------------------------------------------------------------------------
proc NoteBookManager::DiscardValue {frame0 frame1} {
    global nodeSelect
    global userPrefList

    set userPrefList [Operations::DeleteList $userPrefList $nodeSelect 1]
    Validation::ResetPromptFlag
    Operations::SingleClickNode $nodeSelect
    return
}

#-------------------------------------------------------------------------------
#  NoteBookManager::SaveMNValue
#
#  Arguments: frame0 - frame containing the widgets describing the object (index id, Object name, subindex id )
#             frame1 - frame containing the widgets describing properties of object
#
#  Results: -
#
#  Description: save the entered value for MN property window
#-------------------------------------------------------------------------------
proc NoteBookManager::SaveMNValue { frame0 frame1 } {
    global nodeSelect
    global treePath
    global status_save
    global MNDatalist

    #gets the nodeId and Type of selected node
    set result [Operations::GetNodeIdType $nodeSelect]
    if {$result != -1 } {
        set nodeId $result
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
                    #it is a sub-index
                    set saveCmd "openConfLib::SetSubIndexActualValue $nodeId [lindex $objectList 0] [lindex $objectList 1] $validValue"
                }

                set result [eval $saveCmd]
                openConfLib::ShowErrorMessage $result
                if { [Result_IsSuccessful $result] != 1 } {
                    Validation::ResetPromptFlag
                    return
                }

                #value for MN property is edited need to change
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

#-------------------------------------------------------------------------------
#  NoteBookManager::SaveCNValue
#
#  Arguments: frame0 - frame containing the widgets describing the object (index id, Object name, subindex id )
#             frame1 - frame containing the widgets describing properties of object
#
#  Results:  -
#
#  Description: Saves the entered value for CN property window
#-------------------------------------------------------------------------------
proc NoteBookManager::SaveCNValue {nodeId frame0 frame1 frame2 {multiPrescalDatatype ""}} {
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
        #check that the node id is not an existing node id
        set result [openConfLib::IsExistingNode $newNodeId]
        if { [lindex $result 1] } {
            tk_messageBox -message "The node number \"$newNodeId\" already exists" -title Warning -icon warning -parent .
            Validation::ResetPromptFlag
            return
        }
        set result [openConfLib::SetNodeParameter $nodeId $::NODEID $newNodeId]
        openConfLib::ShowErrorMessage $result
        if { [Result_IsSuccessful $result] == 0 } {
            Validation::ResetPromptFlag
            return
        }
    }

    set newNodeName [$frame0.en_nodeName get]
    set result [openConfLib::SetNodeParameter $newNodeId $::NAME $newNodeName]
    openConfLib::ShowErrorMessage $result
    if { [Result_IsSuccessful $result] == 0 } {
        Validation::ResetPromptFlag
        return
    }

    #save is success reconfigure tree, cnSaveButton and nodeIdlist
    set schDataRes [lsearch $nodeIdList $nodeId]
    set nodeIdList [lreplace $nodeIdList $schDataRes $schDataRes $newNodeId]
    set nodeId $newNodeId
    $treePath itemconfigure $nodeSelect -text "$newNodeName\($nodeId\)"

    set stationType [NoteBookManager::RetStationEnumValue]
    set result [openConfLib::SetNodeParameter $nodeId $::STATIONTYPE $stationType]
    openConfLib::ShowErrorMessage $result
    if { [Result_IsSuccessful $result] == 0 } {
        Validation::ResetPromptFlag
        return
    }

    #validate whether the entered cycle reponse time is greater than 1F98 03 value
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


    set CNDatatypeObjectPathList [list \
        [list presponseCycleTimeDatatype $Operations::PRES_TIMEOUT_OBJ $frame0.cycleframe.en_time] ]

    set validValue ""
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

    if { $validValue != "" } {
        set result [openConfLib::SetSubIndexActualValue 240 [lindex $Operations::PRES_TIMEOUT_OBJ 0] $nodeId $validValue]
        openConfLib::ShowErrorMessage $result
        if { [Result_IsSuccessful $result] == 0 } {
            Validation::ResetPromptFlag
            return
        }
    }

    set saveSpinVal ""
    #if the check button is enabled and a valid value is obtained from spin box call the API
    set chkState [$frame2.ch_adv cget -state]
    set chkVar [$frame2.ch_adv cget -variable]
    global $chkVar
    set chkVal [subst $[subst $chkVar] ]
    #check the state and if it is selected.
    if { ($chkState == "normal") && ($chkVal == 1) && ($multiPrescalDatatype != "") } {
        #check wheather a valid data is set or not
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

    # puts "SaveSpin:$saveSpinVal"
    if { $saveSpinVal != "" } {
        set result [openConfLib::SetNodeParameter $nodeId $::FORCEDMULTIPLEXEDCYCLE 0x$saveSpinVal]
        openConfLib::ShowErrorMessage $result
        if { [Result_IsSuccessful $result] == 0 } {
            Validation::ResetPromptFlag
            return
        }
    }

    set status_save 1

    $cnPropSaveBtn configure -command "NoteBookManager::SaveCNValue $nodeId $frame0 $frame1 $frame2 $multiPrescalDatatype"

    Validation::ResetPromptFlag
}

#-------------------------------------------------------------------------------
#  NoteBookManager::StartEdit
#
#  Arguments: tablePath   - Path of the tablelist widget
#             rowIndex    - Row of the edited cell
#             columnIndex - Column of the edited cell
#             text        - Entered value
#
#  Results: text - To be displayed in tablelist
#
#  Description: To validate the entered value
#-------------------------------------------------------------------------------
proc NoteBookManager::StartEdit {tablePath rowIndex columnIndex text} {

    set win [$tablePath editwinpath]
    switch -- $columnIndex {
        1 {
            $win configure -invalidcommand bell -validate key  -validatecommand "Validation::IsTableHex %P %s %d %i 4 $tablePath $rowIndex $columnIndex $win"
        }
        2 {
            $win configure -invalidcommand bell -validate key  -validatecommand "Validation::IsTableHex %P %s %d %i 2 $tablePath $rowIndex $columnIndex $win"
        }
        3 {
            $win configure -invalidcommand bell -validate key  -validatecommand "Validation::IsTableHex %P %s %d %i 4 $tablePath $rowIndex $columnIndex $win"
        }
        4 {
            $win configure -invalidcommand bell -validate key  -validatecommand "Validation::IsTableHex %P %s %d %i 4 $tablePath $rowIndex $columnIndex $win"
        }
    }
    return $text
}

#-------------------------------------------------------------------------------
#  NoteBookManager::EndEdit
#
#  Arguments: tablePath   - Path of the tablelist widget
#             rowIndex    - Row of the edited cell
#             columnIndex - Column of the edited cell
#             text        - Entered value
#
#  Results: text - To be displayed in tablelist
#
#  Description: To validate the entered value when the focus goes out of the cell
#-------------------------------------------------------------------------------
proc NoteBookManager::EndEdit {tablePath rowIndex columnIndex text} {
    return $text
}

#-------------------------------------------------------------------------------
#  NoteBookManager::StartEditCombo
#
#  Arguments:  tablePath   - path of the tablelist widget
#              rowIndex    - row of the edited cell
#              columnIndex - column of the edited cell
#              text        - entered value
#
#  Results: text - To be displayed in tablelist
#
#  Description: To validate the entered value
#-------------------------------------------------------------------------------
proc NoteBookManager::StartEditCombo {tablePath rowIndex columnIndex text} {
    global treePath

    set idxidVal [$tablePath cellcget $rowIndex,1 -text]

    set result [regexp {[\(]0[xX][0-9a-fA-F]+[\)]} $idxidVal match]
    set locIdxId [string range $match 1 end-1]


    set selectedNode [$treePath selection get]
    set tempList "[split [$treePath itemcget $selectedNode -text ] -]"
    set pdoType  [lindex $tempList 0]
    # puts "tempList:$tempList pdoType:$pdoType"
    set result [Operations::GetNodeIdType $selectedNode]
    set locNodeId [lindex $result 0]

    set win [$tablePath editwinpath]
    $win configure -editable no
    switch -- $columnIndex {
        1 {
            set idxList [Operations::GetIndexListWithName $locNodeId $pdoType]
            set idxList [lappend idxList "Default\(0x0000\)"]
            set idxList [lsort $idxList]
            $win configure -values "$idxList"
            $win configure -invalidcommand bell -validate key  -validatecommand "Validation::SetTableComboValue %P $tablePath $rowIndex $columnIndex $win"
        }
        2 {
            set sidxList [Operations::GetSubIndexlistWithName $locNodeId $locIdxId $pdoType]
            set sidxList [lappend sidxList "Default\(0x00\)"]
            set sidxList [lsort $sidxList]
            $win configure -values "$sidxList"
            $win configure -invalidcommand bell -validate key  -validatecommand "Validation::SetTableComboValue %P $tablePath $rowIndex $columnIndex $win"
        }
        3 {
            # Length disabled.
        }
        4 {
            # puts "Offset Loading"
            # Nothing to do for offset. Entry greyed out.
        }
    }
    return $text
}

#-------------------------------------------------------------------------------
#  NoteBookManager::EndEditCombo
#
#  Arguments: tablePath   - Path of the tablelist widget
#             rowIndex    - Row of the edited cell
#             columnIndex - Column of the edited cell
#             text        - Entered value
#
#  Results: text - To be displayed in tablelist
#
#  Description: To validate the entered value when the focus goes out of the cell
#-------------------------------------------------------------------------------
proc NoteBookManager::EndEditCombo {tablePath rowIndex columnIndex text} {

    # Update the parsing of the table and set the number of entries here!!!
    # puts "EndEdit text : $text OldValue: [$tablePath cellcget $rowIndex,$columnIndex -text]"
    switch -- $columnIndex {
          0 {
              # Do nothing for Sno

          }
          1 {
                # TODO see object type and sub-object for VAR objects a tweak is needed.
                set objectId [Operations::GetIdFromFullText $text 2]
                puts "Object: $objectId "
                if { $objectId > 0 } {
                    set numberofentries [$tablePath cellcget $rowIndex,0 -text]
                    NoteBookManager::PDO_SetNumberOfEntries $numberofentries $tablePath
                }
          }
          2 {
                set objectId [$tablePath cellcget $rowIndex,1 -text]
                set objectId [Operations::GetIdFromFullText $objectId 2]
                set subobjectId [Operations::GetIdFromFullText $text 3]

                puts "Object: $objectId SubobjectId: $subobjectId"
                if { $objectId > 0 && $subobjectId > 0 } {
                    set numberofentries [$tablePath cellcget $rowIndex,0 -text]
                    NoteBookManager::PDO_SetNumberOfEntries $numberofentries $tablePath
                }
          }
    }
    return $text
}

#-------------------------------------------------------------------------------
#  NoteBookManager::PDO_SetNumberOfEntries
#  Arguments: numberOfEntries - Value to be updated in the numberof entries box.
#             tablePath       - Path of the table to fetch and update totalBytes
#  Description : Sets the number of entries value and total bytes for number of entries.
#-------------------------------------------------------------------------------
proc NoteBookManager::PDO_SetNumberOfEntries { numberOfEntries tablePath } {
    global pdo_en_numberofentries
    global pdo_en_totalbytes

    set pdo_en_numberofentries $numberOfEntries
    set rowIndex [expr $numberOfEntries - 1]
    set length [$tablePath cellcget $rowIndex,3 -text]
    set offset [$tablePath cellcget $rowIndex,4 -text]

    set pdo_en_totalbytes [expr [expr $offset + $length] / 8]
}

proc NoteBookManager::AutoSetOffset { tablePath rowIndex columnIndex } {

    set maxRow [$tablePath size]
    # puts "maxRow: $maxRow"
    set counter 1
    for {set indRow 0} {$indRow < $maxRow} {incr indRow} {
        # puts "x is $indRow"
        # while 1a00 has one index
        if { $counter == 1 } {
            #puts "counter == 1"
            # 1st subindex in an channel for which offset is 0x0000
            $tablePath cellconfigure $indRow,4 -text "0x0000"
            set offsetVal [$tablePath cellcget $indRow,4 -text]
            set lengthVal [$tablePath cellcget $indRow,3 -text]
            # puts "offsetVal: $offsetVal, lengthVal: $lengthVal"
        } elseif { $counter == $maxRow } {
            #puts "counter == maxRow"
            #no need to manipulate and set offset value to next row if it is a last row
            set totalOffset [expr $offsetVal+$lengthVal]
            #puts "totalOffset: $totalOffset"
            set totalOffsethex 0x[NoteBookManager::AppendZero [string toupper [format %x $totalOffset]] 4]
            #puts "totalOffsethex: $totalOffsethex"
            $tablePath cellconfigure $indRow,4 -text "$totalOffsethex"
        } elseif { $indRow == $rowIndex } {
            #puts "indRow == rowIndex"
            set totalOffset [expr $offsetVal+$lengthVal]
            #puts "totalOffset: $totalOffset"
            set totalOffsethex 0x[NoteBookManager::AppendZero [string toupper [format %x $totalOffset]] 4]
            $tablePath cellconfigure $indRow,4 -text "$totalOffsethex"
            set offsetVal [$tablePath cellcget $indRow,4 -text]
            #puts "offsetVal: $offsetVal"
            set lengthVal [$tablePath cellcget $indRow,3 -text]
            # puts "inputlengthval: $lengthVal"
        } else {
            #puts "Else"
            set totalOffset [expr $offsetVal+$lengthVal]
            #puts "totalOffset: $totalOffset"
            set totalOffsethex 0x[NoteBookManager::AppendZero [string toupper [format %x $totalOffset]] 4]
            #puts "totalOffsethex: $totalOffsethex"
            $tablePath cellconfigure $indRow,4 -text "$totalOffsethex"
            set offsetVal [$tablePath cellcget $indRow,4 -text]
            set lengthVal [$tablePath cellcget $indRow,3 -text]
            #puts "offsetVal: $offsetVal, lengthVal: $lengthVal"
        }

        if { [ string length $lengthVal ] == 0 } {
            set lengthVal "0x0000"
        }
        incr counter
        Validation::SetPromptFlag
    }
}


#-------------------------------------------------------------------------------
#  NoteBookManager::PDO_NumberOfEntries_EditingFinished
#  Description: Handles the editing finished event from NumberOfEntries textbox
#               in a PDO table.
#  Arguments: input           -
#             parentFrame     -
#             mode            -
#             idx             -
#             dataType        -
#-------------------------------------------------------------------------------
proc NoteBookManager::PDO_NumberOfEntries_EditingFinished { input parentFrame mode idx {dataType ""} } {
    global nodeSelect
    global pdo_en_numberofentries
    global pdo_en_totalbytes

    # puts "!!!! $input $mode $idx $dataType"

    set retVal [Validation::IsDec $input $parentFrame.en_numberofentries $mode $idx $dataType]

    if { $retVal == 1} {
        set numberOfEntries $input
    } else {
        set numberOfEntries [NoteBookManager::GetEntryValue $parentFrame.en_numberofentries]
    }

    # set totalNumberOfBytes [NoteBookManager::GetEntryValue $parentFrame.en_totalbytes]
    set mappingIndexId [NoteBookManager::GetEntryValue $parentFrame.en_mapparam]
    # puts "Act: $numberOfEntries :::: $retVal"
    if { $numberOfEntries == "" || $numberOfEntries == 0 } {
        set numberOfEntries 0
        set pdo_en_totalbytes 0
        return $retVal
    }
    set numberOfEntries [lindex [Validation::InputToHex $numberOfEntries "UNSIGNED8"] 0]

    set result [Operations::GetNodeIdType $nodeSelect]
    if {$result == -1} {
        return $retVal
    } else {
        set nodeId $result
    }
    # puts "##$nodeId $mappingIndexId $numberOfEntries $::ACTUALVALUE"

    set result [openConfLib::GetSubIndexAttribute $nodeId $mappingIndexId $numberOfEntries $::ACTUALVALUE ]
    # openConfLib::ShowErrorMessage [lindex $result 0]
    if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
        set pdo_en_totalbytes 0
        return 0
    }

    set mappActualValue [lindex $result 1]
    if {[string match -nocase "0x*" $mappActualValue] } {
        #remove appended 0x
        set mappActualValue [string range $mappActualValue 2 end]
    } else {
        # no 0x no need to do anything
    }

    set length [string range $mappActualValue 0 3]
    set offset [string range $mappActualValue 4 7]
    set length 0x[NoteBookManager::AppendZero $length 4]
    set offset 0x[NoteBookManager::AppendZero $offset 4]

    # puts "%% $length : $offset"
    set pdo_en_totalbytes "[expr [expr $length + $offset] / 8]"

    Validation::SetPromptFlag

    return $retVal
}

#-------------------------------------------------------------------------------
#  NoteBookManager::SaveTable
#
#  Arguments: tableWid - Path of the tablelist widget
#             propertyFrame - Path of the property frame
#  Results: -
#
#  Description: To validate and save the validated values in tablelist widget
#-------------------------------------------------------------------------------
proc NoteBookManager::SaveTable {tableWid propertyFrame} {
    global nodeSelect
    global treePath
    global status_save
    global st_autogen

    set result [$tableWid finishediting]
    if {$result == 0} {
        Validation::ResetPromptFlag
        return
    } else {
    }
    # should save entered values to corresponding subindex
    set nodeId [Operations::GetNodeIdType $nodeSelect]
    set rowCount 0
    set flag 0
    set match ""
    set result [openConfLib::IsExistingNode $nodeId]
    openConfLib::ShowErrorMessage [lindex $result 0]
    if {[lindex $result 1] == 0 && [Result_IsSuccessful [lindex $result 0]] != 1} {
        Validation::ResetPromptFlag
        return
    }

    set commParamIndexId [string trim [$propertyFrame.en_comparam get]]
    set mappParamIndexId [string trim [$propertyFrame.en_mapparam get]]

    set targetNodeId [string trim [$propertyFrame.com_sendto get]]
    # puts "targetNodeId:$targetNodeId"
    set result [regexp {[\(][0-9]+[\)]} $targetNodeId match]
    if { $result == 0} {
        #TODO remove this after fixing nodeid always integetr in singleclicknode
        set result [regexp {[\(]0[xX][0-9a-fA-F]+[\)]} $targetNodeId match]
    }

    # puts "result:$result match:$match"
    set targetNodeId [string range $match 1 end-1]
    # puts "targetNodeId:$targetNodeId"

    set mappingVersion [string trim [$propertyFrame.en_mapver get]]

    set numberOfValidEntries 0
    set numberOfEntries [string trim [$propertyFrame.en_numberofentries get]]

    set totalBytes [string trim [$propertyFrame.en_totalbytes get]]

    set result [openConfLib::SetSubIndexActualValue $nodeId $commParamIndexId "0x01" $targetNodeId]
    openConfLib::ShowErrorMessage $result
    # if { [Result_IsSuccessful $result] == 0 } {
    # }

    set result [openConfLib::SetSubIndexActualValue $nodeId $commParamIndexId "0x02" $mappingVersion]
    openConfLib::ShowErrorMessage $result
    # if { [Result_IsSuccessful $result] == 0 } {
    # }

    #sort the tablelist based on the No column
    $tableWid sortbycolumn 0 -increasing
    update

    set result [openConfLib::GetSubIndices $nodeId $mappParamIndexId]
    if { [Result_IsSuccessful [lindex $result 0]] != 1 } {
        set subIndexList ""
    } else {
        set subIndexList [lindex $result 2]
    }
    # puts "subIndexList:$subIndexList"
    foreach subIndex $subIndexList {
        if { $subIndex == 0 } {
            continue
        }
        set offset [string range [$tableWid cellcget $rowCount,4 -text] 2 end]
        set length [string range [$tableWid cellcget $rowCount,3 -text] 2 end]
        set reserved 00

        if {$st_autogen == 1 } {
            set sidxVal [$tableWid cellcget $rowCount,2 -text]
            set result [regexp {[\(]0[xX][0-9a-fA-F]+[\)]} $sidxVal match]
            set locSidxId [string range $match 3 end-1]

            set idxVal [$tableWid cellcget $rowCount,1 -text]
            set result [regexp {[\(]0[xX][0-9a-fA-F]+[\)]} $idxVal match]
            set locIdxId [string range $match 3 end-1]
        } else {
            set locIdxId [string range [$tableWid cellcget $rowCount,1 -text] 2 end]
            set locSidxId [string range [$tableWid cellcget $rowCount,2 -text] 2 end]
        }

        set value $length$offset$reserved$locSidxId$locIdxId
        # puts "value:::: $value"
        if { [string length $value] != 16 } {
            set flag 1
            incr rowCount
            continue
        } else {
            set value 0x$value
        }
        set result [openConfLib::IsExistingSubIndex $nodeId $mappParamIndexId $subIndex]
        if { [lindex $result 1] } {
            set result [openConfLib::SetSubIndexActualValue $nodeId $mappParamIndexId $subIndex $value]
            # TODO handle result

            if { [expr [expr 0x$locIdxId > 0x0000 ] && [expr 0x$length > 0x0000 ]]} {
                set numberOfValidEntries [$tableWid cellcget $rowCount,0 -text]
            }
        }
        incr rowCount
    }

    if { $flag == 1} {
        Console::DisplayInfo "Only the PDO mapping table entries that are completely filled(Offset, Length, Index and Sub Index) are saved"
    }

    if { [expr $numberOfEntries != $numberOfValidEntries] } {
        set result [tk_messageBox -message "The last valid entry is $numberOfValidEntries. You have enabled only $numberOfEntries entry(s) enabled. Do you want to enable till the last valid entry($numberOfValidEntries)?" -parent . -type yesno -icon question]
        switch -- $result {
            yes {
                #save the value
                set result [openConfLib::SetSubIndexActualValue $nodeId $mappParamIndexId "0x00" $numberOfValidEntries]
                openConfLib::ShowErrorMessage $result
                if { [Result_IsSuccessful $result] == 0 } {
                    puts "SetSubIndexActualValue $nodeId $mappParamIndexId "0x00" $numberOfValidEntries"
                }
                NoteBookManager::PDO_SetNumberOfEntries $numberOfValidEntries $tableWid
                Console::DisplayInfo "Number of valid entries updated to $numberOfValidEntries." info
            }
            no  {
                #continue
                set result [openConfLib::SetSubIndexActualValue $nodeId $mappParamIndexId "0x00" $numberOfEntries]
                openConfLib::ShowErrorMessage $result
                if { [Result_IsSuccessful $result] == 0 } {
                    puts "SetSubIndexActualValue $nodeId $mappParamIndexId "0x00" $numberOfEntries"
                }
            }
        }
    }

    set result [openConfLib::SetSubIndexActualValue $nodeId $mappParamIndexId "0x00" $numberOfEntries]
    openConfLib::ShowErrorMessage $result
    # if { [Result_IsSuccessful $result] == 0 } {
    # }

    #PDO entries value is changed need to save
    set status_save 1
    #set populatedPDOList ""
    Validation::ResetPromptFlag
}

#-------------------------------------------------------------------------------
#  NoteBookManager::DiscardTable
#
#  Arguments: tableWid - Path of the tablelist widget
#
#  Results: -
#
#  Description: Discards the entered values and displays last saved values
#-------------------------------------------------------------------------------
proc NoteBookManager::DiscardTable {tableWid} {

    global nodeSelect

    Validation::ResetPromptFlag

    Operations::SingleClickNode $nodeSelect
}

#-------------------------------------------------------------------------------
#  NoteBookManager::GetComboValue
#
#  Arguments: comboPath - Path of the Combobox widget
#
#  Results: Selected value
#
#  Description: Gets the selected index and returns the corresponding value
#-------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------
#  NoteBookManager::GetEntryValue
#
#  Arguments: entryPath - Path of the entry box widget
#
#  Results: Selected value
#
#  Description: Gets the value entered in entry box widget
#-------------------------------------------------------------------------------
proc NoteBookManager::GetEntryValue {entryPath} {
    set entryState [$entryPath cget -state]
    set entryValue [$entryPath get]
    $entryPath configure -state $entryState
    return $entryValue
}

#-------------------------------------------------------------------------------
#  NoteBookManager::SetEntryValue
#
#  Arguments: entryPath - Path of the entry box widget
#
#  Results: Selected value
#
#  Description: Gets the value entered in entry widget
#-------------------------------------------------------------------------------
proc NoteBookManager::SetEntryValue {entryPath insertValue} {
    set entryState [$entryPath cget -state]
    $entryPath configure -state normal
    $entryPath delete 0 end
    $entryPath insert 0 $insertValue
    $entryPath configure -state $entryState
    Validation::SetPromptFlag
}

#-------------------------------------------------------------------------------
#  NoteBookManager::GenerateCnNodeList
#
#  Arguments: comboPath  - Path of the Combobox widget
#             value      - Value to set into the Combobox widget
#
#  Results: Selected value
#
#  Description: Gets the selected value and sets it into the Combobox widget
#-------------------------------------------------------------------------------
proc NoteBookManager::GenerateCnNodeList {} {
    set cnNodeList ""
    for { set inc 1 } { $inc < 240 } { incr inc } {
        lappend cnNodeList $inc
    }
    return $cnNodeList
}

#-------------------------------------------------------------------------------
#  NoteBookManager::StationRadioChanged
#
#  Arguments: framePath - Path of frame containing the check button
#             radioVal  - Variable of the radio buttons
#
#  Results: -
#
#  Description: Enables or disables the spinbox based on the selection of check button
#-------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------
#  NoteBookManager::forceCycleChecked
#
#  Arguments: framePath - Path of frame containing the check button
#             check_var - Variable of the check box
#
#  Results: -
#
#  Description: Enables or disasbles the spinbox based on the selection of check button
#-------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------
#  NoteBookManager::RetStationEnumValue
#
#  Arguments: -
#
#  Results: -
#
#  Description: Enables or disasbles the spinbox based on the selection of check button
#-------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------
#  NoteBookManager::LimitFocusChanged
#
#  Arguments: -
#
#  Results: -
#
#  Description: It validates value with upper limit or lower limit based on the entry path
#-------------------------------------------------------------------------------
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
           # puts "Returning focus changed"
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
