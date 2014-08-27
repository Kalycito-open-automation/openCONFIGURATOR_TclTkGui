################################################################################
# \file   wrapperInteractions.tcl
#
# \brief  Populates the object in GUI in sorted order
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
#  namespace: WrapperInteractions
#-------------------------------------------------------------------------------
namespace eval WrapperInteractions {

}

#-------------------------------------------------------------------------------
#  WrapperInteractions::Import
#
#  Arguments: parentNode - parent node in tree window
#             nodeId     - id of the node
#
#  Results: pass or fail
#
#  Description: Populates the node onto the tree window
#-------------------------------------------------------------------------------
proc WrapperInteractions::Import { parentNode nodeId } {
    global treePath
    global image_dir

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

    set treeNode Mapping-$nodeId
    set insertMappingNode 0


    set TPDOTreeNode TPDO-$nodeId
    set insertPdoNodeOnce 0
    set indexList [WrapperInteractions::GetIndexId $nodeId 4]
    foreach index $indexList {
        set mappingIdxId [WrapperInteractions::GetMappingParamIndex $index ]
        if {[string length $mappingIdxId]} {
            #puts ":: $mappingIdxId"
            set result [openConfLib::IsExistingIndex $nodeId $mappingIdxId ]
            if { [Result_IsSuccessful [lindex $result 0]] && [lindex $result 1]} {

                if {$insertMappingNode == 0} {
                    $treePath insert end $parentNode $treeNode -text "Mapping" -open 0 -image img_pdo
                    set insertMappingNode 1
                }
                if {$insertPdoNodeOnce == 0} {
                    $treePath insert end $treeNode $TPDOTreeNode -text "TPDO" -open 0 -image img_pdo
                    set insertPdoNodeOnce 1
                }

                set mappingSubStr [string range $mappingIdxId 4 end]
                $treePath insert end $TPDOTreeNode TPDONode-$nodeId-$mappingSubStr -text "TPDO-$mappingSubStr" -open 0 -image img_pdo
            }
        }
    }

    set RPDOTreeNode RPDO-$nodeId
    set insertPdoNodeOnce 0
    set indexList [WrapperInteractions::GetIndexId $nodeId 5]
    foreach index $indexList {
        set mappingIdxId [WrapperInteractions::GetMappingParamIndex $index ]
        if {[string length $mappingIdxId]} {
            #puts ":: $mappingIdxId"
            set result [openConfLib::IsExistingIndex $nodeId $mappingIdxId ]
            if { [Result_IsSuccessful [lindex $result 0]]  && [lindex $result 1] } {

                if {$insertMappingNode == 0} {
                    $treePath insert end $parentNode $treeNode -text "Mapping" -open 0 -image img_pdo
                    set insertMappingNode 1
                }
                if {$insertPdoNodeOnce == 0} {
                    $treePath insert end $treeNode $RPDOTreeNode -text "RPDO" -open 0 -image img_pdo
                    set insertPdoNodeOnce 1
                }

                set mappingSubStr [string range $mappingIdxId 4 end]
                $treePath insert end $RPDOTreeNode RPDONode-$nodeId-$mappingSubStr -text "RPDO-$mappingSubStr" -open 0 -image img_pdo
            }
        }
    }

    #check for view if simple exit else advanced continue
    if { [string match "SIMPLE" $Operations::viewType ] == 1 } {
        return pass
    }

    set treeNode OBD-$nodeId
    $treePath insert end $parentNode $treeNode -text "ObjectDictionary" -open 0 -image img_pdo

    set indexCount 0
    set indexList [WrapperInteractions::GetIndexId $nodeId 0]
    foreach index $indexList {
        set indexName ""
        set result [openConfLib::GetIndexAttribute $nodeId $index $::NAME]
        if { [Result_IsSuccessful [lindex $result 0]] } {
            set indexName [lindex $result 1]
        }
        $treePath insert $indexCount $treeNode IndexValue-$nodeId-$indexCount -text $indexName\($index\) -open 0 -image img_index
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

                $treePath insert end IndexValue-$nodeId-$indexCount SubIndexValue-$nodeId-$indexCount-$subIndexCount -text $subIndexName\($subIndexIdHex\) -open 0 -image img_subindex
                incr subIndexCount
            }
        }
        incr indexCount
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
#               4 - TxCommunicationParams
#               5 - RxCommunicationParams
################################################################################
proc WrapperInteractions::GetIndexId {nodeId type} {
    set returnList ""
    set result [openConfLib::GetIndices $nodeId]
    if { [Result_IsSuccessful [lindex $result 0]] } {
        set indexList [lsort -integer [lindex $result 2]]
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
                        # do nothing
                    } else {
                        lappend returnList "0x$indexIdHex"
                    }
                }
                4 {
                    if {[string match "18*" $indexIdHex]} {
                        lappend returnList "0x$indexIdHex"
                    }
                }
                5 {
                    if {[string match "14*" $indexIdHex]} {
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

proc WrapperInteractions::GetMappingParamIndex { communicationParamIndex } {

    if {[string match "0x14*" $communicationParamIndex]} {
        set substr [string range $communicationParamIndex 4 end]
        return "0x16$substr"
    } elseif {[string match "0x18*" $communicationParamIndex]} {
        set substr [string range $communicationParamIndex 4 end]
        return "0x1A$substr"
    } else {
        puts "Not a Communication parameter IndexId : $communicationParamIndex"
        # not an communication param index
    }
}
