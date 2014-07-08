####################################################################################################
#
#
# NAME:     wrapperInteractions.tcl
#
# PURPOSE:  populates the object in GUI in sorted order
#
# AUTHOR:   Kalycito Infotech Pvt Ltd
#
# COPYRIGHT NOTICE:
#
#***************************************************************************************************
# (c) Kalycito Infotech Private Limited
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
# $Log:      $
####################################################################################################
#---------------------------------------------------------------------------------------------------
#  NameSpace Declaration
#
#  namespace : WrapperInteractions
#---------------------------------------------------------------------------------------------------
namespace eval WrapperInteractions {

}

#---------------------------------------------------------------------------------------------------
#  WrapperInteractions::SortNode
#
#  Arguments : nodeID   - id of the nodes
#              choice   - sorts based on the given choice
#              indexPos - index position in the object created
#              indexId  - id of the index
#  Results : sorted list
#
#  Description : Sorts the index and sub index of the objects
#---------------------------------------------------------------------------------------------------
proc WrapperInteractions::SortNode {nodeID choice {indexPos ""} {indexId ""}} {
    global treePath

    set errorString []
    if { $choice == "ind" } {
        set count [new_intp]
        set catchErrCode [GetIndexCount $nodeID $count]
        set count [intp_value $count]
        set sortRange 4
    } elseif { $choice == "sub" } {
        set count [new_intp]
        set catchErrCode [GetSubIndexCount $nodeID $indexId $count]
        set count [intp_value $count]
        set sortRange 2
    } else {
        return
    }

    #if count is zero no need to proceed
    set cntLen [string length $count]
    if {$count == 0} {
        if { $choice == "ind" } {
            return [list "" "" ""]
        } elseif { $choice == "sub" } {

            return ""
        } else {
            #invalid choice
        }
    }
    set sortList ""
    for { set inc 0 } { $inc < $count } { incr inc } {
        set appZero [expr [string length $count]-[string length $inc]]
        set tmpInc $inc
        for {set incZero 0} {$incZero < $appZero} {incr incZero} {
            #appending zeros
            set tmpInc 0$tmpInc
        }
        if { $choice == "ind" } {
            set catchErrCode [GetIndexIDbyPositions $inc]
            set indexId [lindex $catchErrCode 1]
            lappend sortList $indexId$tmpInc
        } elseif { $choice == "sub" } {
            set catchErrCode [GetSubIndexIDbyPositions $indexPos $inc]
            set subIndexId [lindex $catchErrCode 1]
            lappend sortList $subIndexId$tmpInc
        } else {
            return
        }

    }
    set sortList [lsort -ascii $sortList]

    if { $choice == "ind"} {
        set sortListIdx ""
        set sortListTpdo ""
        set sortListRpdo ""
        for { set inc 0 } { $inc < $count } { incr inc } {

            set sortInc [lindex $sortList $inc]

            if {[string match "18*" $sortInc] || [string match "1A*" $sortInc]} {
                #it must a TPDO object
                set corrList sortListTpdo
            } elseif {[string match "14*" $sortInc] || [string match "16*" $sortInc]} {
                #it must a RPDO object
                set corrList sortListRpdo
            } else {
                set corrList sortListIdx
            }

            set sortInc [string range $sortInc $sortRange end]
            set sortInc [string trimleft $sortInc 0]
            if {$sortInc == ""} {
                set sortInc 0
            } else {
                #got the exact value
            }
            lappend $corrList $sortInc
        }
        return [list $sortListIdx $sortListTpdo $sortListRpdo]
    } elseif {$choice == "sub"} {
        set corrList ""
        for { set inc 0 } { $inc < $count } { incr inc } {

            set sortInc [lindex $sortList $inc]
            set sortInc [string range $sortInc $sortRange end]
            set sortInc [string trimleft $sortInc 0]
            if {$sortInc == ""} {
                set sortInc 0
            } else {
                #got the exact value
            }
            lappend corrList $sortInc

        }
        return $corrList
    } else {
        return
    }
}

#---------------------------------------------------------------------------------------------------
#  WrapperInteractions::Import
#
#  Arguments : parentNode - parent node in tree window
#              nodeId     - id of the node
#
#  Results : pass or fail
#
#  Description : Populates the node on to the tree window
#---------------------------------------------------------------------------------------------------
proc WrapperInteractions::Import { parentNode nodeId } {
    global treePath
    global cnCount
    global image_dir
    global LocvarProgbar

    set LocvarProgbar 0
    #check for view if simple exit else advanced continue
    if { [string match "SIMPLE" $Operations::viewType ] == 1 } {
        return pass
    }

    set result [openConfLib::IsExistingNode $nodeId]
    openConfLib::ShowErrorMessage [lindex $result 0]
    if { [lindex $result 0] == 0 && [Result_IsSuccessful [lindex $result 0]] != 1 } {
        Operations::CloseProject
        return fail
    }

    set parentId [split $parentNode -]
    set parentId [lrange $parentId 1 end]
    set parentId [join $parentId -]

    image create photo img_pdo -file "$image_dir/pdo.gif"
    image create photo img_index -file "$image_dir/index.gif"
    image create photo img_subindex -file "$image_dir/subindex.gif"

    $treePath insert end $parentNode PDO-$parentId -text "PDO" -open 0 -image img_pdo
    $treePath insert end PDO-$parentId TPDO-$parentId -text "TPDO" -open 0 -image img_pdo
    $treePath insert end PDO-$parentId RPDO-$parentId -text "RPDO" -open 0 -image img_pdo

    set indexCount 0
    set indexList [WrapperInteractions::GetIndexId $nodeId 3]
    foreach index $indexList {
        set indexName ""
        set result [openConfLib::GetIndexAttribute $nodeId $index $::NAME]
        if { [Result_IsSuccessful [lindex $result 0]] } {
            set indexName [lindex $result 1]
        }
        $treePath insert $indexCount $parentNode IndexValue-$parentId-$indexCount -text $indexName\($index\) -open 0 -image img_index
        set result [openConfLib::GetSubIndices $nodeId $index]
        if { [Result_IsSuccessful [lindex $result 0]] } {
            set subIndexCount 0
            foreach sidx [lindex $result 2] {
                set subIndexIdHex "0x[format %2.2X $sidx]"
                set subIndexName ""
                set result [openConfLib::GetSubIndexAttribute $nodeId $index $subIndexIdHex $::NAME]
                if { [Result_IsSuccessful [lindex $result 0]] } {
                    set subIndexName [lindex $result 1]
                }

                $treePath insert end IndexValue-$parentId-$indexCount SubIndexValue-$parentId-$indexCount-$subIndexCount -text $subIndexName\($subIndexIdHex\) -open 0 -image img_subindex
                incr subIndexCount
            }
        }
        incr indexCount
        update idletasks
    }

    set tpdoIndexCount 0
    set indexList [WrapperInteractions::GetIndexId $nodeId 1]
    foreach index $indexList {
        set indexName ""
        set result [openConfLib::GetIndexAttribute $nodeId $index $::NAME]
        if { [Result_IsSuccessful [lindex $result 0]] } {
            set indexName [lindex $result 1]
        }
        $treePath insert $tpdoIndexCount TPDO-$parentId TPdoIndexValue-$parentId-$tpdoIndexCount -text $indexName\($index\) -open 0 -image img_index
        set result [openConfLib::GetSubIndices $nodeId $index]
        if { [Result_IsSuccessful [lindex $result 0]] } {
            set subIndexCount 0
            foreach sidx [lindex $result 2] {
                set subIndexIdHex "0x[format %2.2X $sidx]"
                set subIndexName ""
                set result [openConfLib::GetSubIndexAttribute $nodeId $index $subIndexIdHex $::NAME]
                if { [Result_IsSuccessful [lindex $result 0]] } {
                    set subIndexName [lindex $result 1]
                }

                $treePath insert end TPdoIndexValue-$parentId-$tpdoIndexCount TPdoSubIndexValue-$parentId-$tpdoIndexCount-$subIndexCount -text $subIndexName\($subIndexIdHex\) -open 0 -image img_subindex
                incr subIndexCount
            }
        }
        incr tpdoIndexCount
        update idletasks
    }

    set rpdoIndexCount 0
    set indexList [WrapperInteractions::GetIndexId $nodeId 2]
    foreach index $indexList {
        set indexName ""
        set result [openConfLib::GetIndexAttribute $nodeId $index $::NAME]
        if { [Result_IsSuccessful [lindex $result 0]] } {
            set indexName [lindex $result 1]
        }

        $treePath insert $rpdoIndexCount RPDO-$parentId RPdoIndexValue-$parentId-$rpdoIndexCount -text $indexName\($index\) -open 0 -image img_index
        set result [openConfLib::GetSubIndices $nodeId $index]
        if { [Result_IsSuccessful [lindex $result 0]] } {
            set subIndexCount 0
            foreach sidx [lindex $result 2] {
                set subIndexIdHex "0x[format %2.2X $sidx]"
                set subIndexName ""
                set result [openConfLib::GetSubIndexAttribute $nodeId $index $subIndexIdHex $::NAME]
                if { [Result_IsSuccessful [lindex $result 0]] } {
                    set subIndexName [lindex $result 1]
                }

                $treePath insert end RPdoIndexValue-$parentId-$rpdoIndexCount RPdoSubIndexValue-$parentId-$rpdoIndexCount-$subIndexCount -text $subIndexName\($subIndexIdHex\) -open 0 -image img_subindex
                incr subIndexCount
            }
        }
        incr rpdoIndexCount
        update idletasks
    }

    return pass
}

################################################################################
# Returns the list of index id with 0x based on the type
# type shall be 0 - all
#               1 - TPDO
#               2 - RPDO
#               3 - NonPDOnodes
################################################################################
proc WrapperInteractions::GetIndexId {nodeId type} {
    set returnList ""
    set result [openConfLib::GetIndices $nodeId]
    if { [Result_IsSuccessful [lindex $result 0]] } {
        set indexList [lsort -ascii [lindex $result 2]]
        foreach index $indexList {
            set indexIdHex "[format %4.4X $index]"
            switch $type {
                0 {
                    lappend returnList "0x$indexIdHex"
                }
                1 {
                    if {[string match "18*" $indexIdHex] || [string match "1A*" $indexIdHex]} {
                        lappend returnList "0x$indexIdHex"
                    }
                }
                2 {
                    if {[string match "14*" $indexIdHex] || [string match "16*" $indexIdHex]} {
                        lappend returnList "0x$indexIdHex"
                    }
                }
                3 {
                    if {[string match "18*" $indexIdHex] || [string match "1A*" $indexIdHex] || [string match "14*" $indexIdHex] || [string match "16*" $indexIdHex]} {

                    } else {
                        lappend returnList "0x$indexIdHex"
                    }
                }
                default {
                    puts "default"
                }
            }
        }
    }
    return $returnList
}

#---------------------------------------------------------------------------------------------------
#  WrapperInteractions::RebuildNode
#
#  Arguments : Node - node in tree window
#
#  Results : pass or fail
#
#  Description : rebuilds the node on to the tree window
#---------------------------------------------------------------------------------------------------
proc WrapperInteractions::RebuildNode {{Node ""}} {
    global treePath
    global nodeSelect
    global image_dir

    if {$Node == ""} {
        set Node $nodeSelect
    }
    if {[$treePath exists $Node] == 1}  {
        #node exists continue the function
    } else {
        return
    }

    #gets the nodeId and Type of selected node
    set result [Operations::GetNodeIdType $Node]
    if {$result != "" } {
        set nodeID [lindex $result 0]
    } else {
        return
    }
    set nodePosition [split $Node -]
    set nodePosition [lrange $nodePosition 1 end]
    set nodePosition [join $nodePosition -]

    set ExistfFlag [new_boolp]
    set catchErrCode [IfNodeExists $nodeID $ExistfFlag]
    set ExistfFlag [boolp_value $ExistfFlag]
    set ErrCode [ocfmRetCode_code_get $catchErrCode]
    if { $ErrCode == 0 && $ExistfFlag == 1 } {
        #the node exist continue
    } else {
        if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
            tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -parent . -title Error -icon error
        } else {
            tk_messageBox -message "Unknown Error" -parent . -title Error -icon error
        }
        return
    }

    set IndexValue [string range [$treePath itemcget $Node -text] end-4 end-1]

    set indexPos [new_intp]
    set catchErrCode [IfIndexExists $nodeID $IndexValue $indexPos]
    if { [ocfmRetCode_code_get $catchErrCode] != 0 } {
        if { [ string is ascii [ocfmRetCode_errorString_get $catchErrCode] ] } {
            tk_messageBox -message "[ocfmRetCode_errorString_get $catchErrCode]" -title Error -icon error -parent .
        } else {
            tk_messageBox -message "Unknown Error" -title Error -icon error -parent .
        }
        return
    }
    set indexPos [intp_value $indexPos]

    set childNodeList [$treePath nodes $Node]
    if {[llength $childNodeList] > 0} {
        $treePath itemconfigure $Node -open 0
    }
    foreach childNode $childNodeList {
        $treePath delete $childNode
    }

    set sidxCorrList [WrapperInteractions::SortNode $nodeID sub $indexPos $IndexValue]

    set SIdxCount [new_intp]
    set catchErrCode [GetSubIndexCount $nodeID $IndexValue $SIdxCount]
    set SIdxCount [intp_value $SIdxCount]
    for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
        set sortedSubIndexPos [lindex $sidxCorrList $tmpCount]
        set SIdxValue [GetSubIndexIDbyPositions $indexPos $sortedSubIndexPos]
        if { [ocfmRetCode_code_get [lindex $SIdxValue 0]] != 0 } {
            if { [ string is ascii [ocfmRetCode_errorString_get [lindex $SIdxValue 0]] ] } {
                tk_messageBox -message "[ocfmRetCode_errorString_get [lindex $SIdxValue 0] ]\nClosing the project" -title Error -icon error -parent .
            } else {
                tk_messageBox -message "Unknown Error" -title Error -icon error -parent .
            }
            return fail
        }
        set SIdxValue [lindex $SIdxValue 1]
        set catchErr [GetSubIndexAttributesbyPositions $indexPos $sortedSubIndexPos 0 ]
        set SIdxName [lindex $catchErr 1]
        if { [ocfmRetCode_code_get [lindex $catchErr 0]] != 0 } {
            if { [ string is ascii [ocfmRetCode_errorString_get [lindex $catchErr 0]] ] } {
                tk_messageBox -message "[ocfmRetCode_errorString_get [lindex $catchErr 0]]\nClosing the project" -title Error -icon error -parent .
            } else {
                tk_messageBox -message "Unknown Error" -title Error -icon error -parent .
            }
            return fail
        }
        image create photo img_subindex -file "$image_dir/subindex.gif"
        $treePath insert end $Node SubIndexValue-$nodePosition-$tmpCount -text $SIdxName\(0x$SIdxValue\) -open 0 -image img_subindex
    }
    update idletasks
}
