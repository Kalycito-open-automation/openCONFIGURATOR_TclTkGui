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
        set indexList [lsort [lindex $result 2]]
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
                default {
                    puts "default"
                }
            }
        }
    }
    return $returnList
}
