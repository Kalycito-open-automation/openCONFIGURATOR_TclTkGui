proc Import {cn tmpDir NodeType {NodeID 1}} {
	global updatetree
	global cnCount
	global xdcFile

	#global testNodeID 
	#incr testNodeID


	ImportProgress start


	global LocvarProgbar
	set LocvarProgbar 0
	#progressbar_incr 
#global prog
#doBars start $prog
#$prog start
#ttk::progressbar::stop $prog
#ProgressBar::stop $prog

	#IncrProgressIndicator
	#ImportProgress incr
#bind time - "? * * * *" {ImportProgress incr}


	set errorString []
	#set NodeID $testNodeID
	set NodeType 1
	
	set objNodeCollection [new_CNodeCollection]
	set objNodeCollection [CNodeCollection_getNodeColObjectPointer]

	puts "errorString->$errorString...NodeType->$NodeType...NodeID->$NodeID..."
	Tcl_CreateNode $NodeID $NodeType
	Tcl_ImportXML "$tmpDir" $errorString $NodeType $NodeID

    set LocvarProgbar 20 

	set objNode [new_CNode]

	set obj [new_CIndexCollection]
	set objNode [CNodeCollection_getNode $objNodeCollection $NodeType $NodeID]
	set obj [CNode_getIndexCollectionWithoutPDO $objNode]
	puts "**"

	set count [CIndexCollection_getNumberofIndexes $obj]
	puts COUNT$count



	#set tmpProg [ImportProgress start]
#puts "COUNT$count======tmpProg$tmpProg"

#$tmpProg configure -maximum [expr $count*2]

#	set TclObj [new_CNodeCollection]
#	set TclNodeObj [new_CNode]
#	set TclNodeObj [CNodeCollection_getNode $TclObj $NodeType $NodeID]

#	set TclIndexCollection [new_CIndexCollection]
#	set TclIndexCollection  [CNode_getIndexCollection $TclNodeObj]

#	set ObjIndex [new_CIndex]
#	set count [CIndexCollection_getNumberofIndexes $TclIndexCollection]

	set cnId [split $cn -]
	set xdcId [lrange $cnId 1 end]
	set xdcId [join $xdcId -]
	#puts xdcId-->$xdcId
	#set xdcFile($xdcId) $tmpDir
	set cnId [lindex $cnId end]
	puts cnId-->$cnId
	
	
	for { set i 0 } { $i < $count } { incr i } {
	
	#set ObjIndex [new_CIndex]
	
		#set ObjIndex [CIndexCollection_getIndex $TclIndexCollection $i]
		set ObjIndex [CIndexCollection_getIndex $obj $i]
		set xdcFile(1-$cnId-$i) $ObjIndex
		#puts ObjIndex-->$ObjIndex
		set IndexValue [CBaseIndex_getIndexValue $ObjIndex]
		set IndexName [CBaseIndex_getName $ObjIndex]
		#puts i---->$i
		$updatetree insert $i $cn IndexValue-1-$cnId-$i -text $IndexName\($IndexValue\) -open 0 -image [Bitmap::get index]
		
		set SIdxCount [CIndex_getNumberofSubIndexes $ObjIndex]

		for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
			set ObjSIdx [CIndex_getSubIndex $ObjIndex $tmpCount]
			#puts ObjSIdx-->$ObjSIdx=======tmpCount:$tmpCount
			set xdcFile(1-$cnId-$i-$tmpCount) $ObjSIdx
			set SIdxValue [CBaseIndex_getIndexValue $ObjSIdx]
			#puts SIdxValue:$SIdxValue=======tmpCount:$tmpCount
			set SIdxName [CBaseIndex_getName $ObjIndex]
			#set SIdxDefaultValue [CBaseIndex_getDefaultValue $ObjSIdx]
			#puts SIdxDefaultValue:$SIdxDefaultValue
			$updatetree insert end IndexValue-1-$cnId-$i SubIndexValue-1-$cnId-$i-$tmpCount -text $SIdxName\($SIdxValue\) -open 0 -image [Bitmap::get subindex]
			
		}
		update idletasks
		#ImportProgress incr
	}
set LocvarProgbar 40
###########################################for TPDO
	set TclIndexCollection  [CNode_getPDOIndexCollection $objNode 1]

	set ObjIndex [new_CIndex]
	set count [CIndexCollection_getNumberofIndexes $TclIndexCollection]
	puts "count for tpdo->$count"

#	puts cn-->$cn
	$updatetree insert end $cn PDO-1-$cnId -text "PDO" -open 0 -image [Bitmap::get pdo]
	$updatetree insert end PDO-1-$cnId TPDO-1-$cnId -text "TPDO" -open 0 -image [Bitmap::get pdo]
	for { set i 0 } { $i < $count } { incr i } {
		set ObjIndex [CIndexCollection_getIndex $TclIndexCollection $i]
		set xdcFile(1-TPdo$cnId-$i) $ObjIndex
		#puts ObjIndex-->$ObjIndex
		set IndexValue [CBaseIndex_getIndexValue $ObjIndex]
		set IndexName [CBaseIndex_getName $ObjIndex]
		#puts i---->$i
		$updatetree insert $i TPDO-1-$cnId TPdoIndexValue-1-TPdo$cnId-$i -text $IndexName\($IndexValue\) -open 0 -image [Bitmap::get index]
		set SIdxCount [CIndex_getNumberofSubIndexes $ObjIndex]
		for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
			set ObjSIdx [CIndex_getSubIndex $ObjIndex $tmpCount]
			#puts ObjSIdx-->$ObjSIdx
			set xdcFile(1-TPdo$cnId-$i-$tmpCount) $ObjSIdx
			set SIdxValue [CBaseIndex_getIndexValue $ObjSIdx]
			#puts SIdxValue:$SIdxValue=======tmpCount:$tmpCount
			set SIdxName [CBaseIndex_getName $ObjIndex]
			set SIdxDefaultValue [CBaseIndex_getDefaultValue $ObjSIdx]
			#puts SIdxDefaultValue:$SIdxDefaultValue
			$updatetree insert end TPdoIndexValue-1-TPdo$cnId-$i TPdoSubIndexValue-1-TPdo$cnId-$i-$tmpCount -text $SIdxName\($SIdxValue\) -open 0 -image [Bitmap::get subindex]
		}
		update idletasks
		#ImportProgress incr
	}
	
	
set LocvarProgbar 60	
	###########################################for RPDO
	set TclIndexCollection  [CNode_getPDOIndexCollection $objNode 2]

	set ObjIndex [new_CIndex]
	set count [CIndexCollection_getNumberofIndexes $TclIndexCollection]
	puts "count for rpdo->$count"

#	puts cn-->$cn
	#$updatetree insert end $cn PDO-1-$cnId -text "PDO" -open 1 -image [Bitmap::get pdo]
	$updatetree insert end PDO-1-$cnId RPDO-1-$cnId -text "RPDO" -open 0 -image [Bitmap::get pdo]
	for { set i 0 } { $i < $count } { incr i } {
		set ObjIndex [CIndexCollection_getIndex $TclIndexCollection $i]
		set xdcFile(1-RPdo$cnId-$i) $ObjIndex
		#puts ObjIndex-->$ObjIndex
		set IndexValue [CBaseIndex_getIndexValue $ObjIndex]
		set IndexName [CBaseIndex_getName $ObjIndex]
		#puts i---->$i
		$updatetree insert $i RPDO-1-$cnId RPdoIndexValue-1-RPdo$cnId-$i -text $IndexName\($IndexValue\) -open 0 -image [Bitmap::get index]
		set SIdxCount [CIndex_getNumberofSubIndexes $ObjIndex]
		for { set tmpCount 0 } { $tmpCount < $SIdxCount } { incr tmpCount } {
			set ObjSIdx [CIndex_getSubIndex $ObjIndex $tmpCount]
			#puts ObjSIdx-->$ObjSIdx
			set xdcFile(1-RPdo$cnId-$i-$tmpCount) $ObjSIdx
			set SIdxValue [CBaseIndex_getIndexValue $ObjSIdx]
			#puts SIdxValue:$SIdxValue=======tmpCount:$tmpCount
			set SIdxName [CBaseIndex_getName $ObjIndex]
			set SIdxDefaultValue [CBaseIndex_getDefaultValue $ObjSIdx]
			#puts SIdxDefaultValue:$SIdxDefaultValue
			$updatetree insert end RPdoIndexValue-1-RPdo$cnId-$i RPdoSubIndexValue-1-RPdo$cnId-$i-$tmpCount -text $SIdxName\($SIdxValue\) -open 0 -image [Bitmap::get subindex]
		}
		update idletasks
		#ImportProgress incr
	}

	puts "errorString->$errorString...NodeType->$NodeType...NodeID->$NodeID..."
	set LocvarProgbar 80
	ImportProgress stop

#############

}

