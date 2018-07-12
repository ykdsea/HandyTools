

if [ $# -lt 1 ]
then
	echo "please enter the file to analysis."
	exit 0
fi

logfile=$1
layerNumPrefix="*--------------ComposeLayerNum "
layerAttrPrefix="*LayerCompose--"
layerAttrPrefix2="*):"
declare -i layerNum0
declare -i layerNum1
declare -i lastLayerNum
declare -i composeCount
composeCount=0

layerNumStatis=(0 0 0 0 0 0)
layerNumDesc=("0_layers" "1_layers" "2_layers" "3_layers" "4_layers" "5_layers_more")

layerNum1Scaled=(0 0)
layerNum2Scaled=(0 0 0)
layerNum3Scaled=(0 0 0 0)
layerNum4Scaled=(0 0 0 0 0)
layerNum5Scaled=(0 0 0 0 0 0)

layerBlendStatis=(0 0 0 0)
layerBlendDesc=("invalid" "noblend" "premultiplied" "coverage")

layerPlaneAlphaStatis=(0 0)
layerPlaneAlphaDesc=("no-planeAlpha" "planeAlpha")

layerBufferTypeStatis=(0 0 0 0)
layerBufferTypeDesc=("normal" "sideband" "solidcolor" "client")

layerFullscreenStatis=(0 0 0 0)
layerFullscreenDesc=("full" "cropped" "smaller" "bigger")

layerScaledStatis=(0 0)
layerScaledDesc=("nonscale" "scale")

layerTransformStatis=(0 0)
layerTransformDesc=("non-rotate" "rotate")

layerDataSpaceStatis=(0 0)
layerDataSpaceDesc=("default" "specified-space")

dumpComposeStatis(){
	echo "-------layer num statis-----"

	let idx=0
	for i in ${layerNumStatis[@]};do
		echo -n ${layerNumDesc[$[$idx]]} : $i
		if [ $idx -eq 0 ]
		then
			echo " "
		elif [ $idx -eq 1 ]
		then
			echo : ${layerNum1Scaled[*]}
		elif [ $idx -eq 2 ]
		then
			echo : ${layerNum2Scaled[*]}
		elif [ $idx -eq 3 ]
		then
			echo : ${layerNum3Scaled[*]}
		elif [ $idx -eq 4 ]
		then
			echo : ${layerNum4Scaled[*]}
		elif [ $idx -eq 5 ]
		then
			echo : ${layerNum5Scaled[*]}
		fi

		idx=`expr $idx + 1`
	done
	echo "-------layer blend statis-----"
	let idx=0
	for i in ${layerBlendStatis[@]};do
		echo ${layerBlendDesc[$[$idx]]} : $i
		idx=`expr $idx + 1`
	done
	echo "-------layer plane alpha statis-----"
	let idx=0
	for i in ${layerPlaneAlphaStatis[@]};do
		echo ${layerPlaneAlphaDesc[$[$idx]]} : $i
		idx=`expr $idx + 1`
	done
	echo "-------layer buffertype statis-----"
	let idx=0
	for i in ${layerBufferTypeStatis[@]};do
		echo ${layerBufferTypeDesc[$[$idx]]} : $i
		idx=`expr $idx + 1`
	done
	#echo "-------layer fullscreen statis-----"
	#let idx=0
	#for i in ${layerFullscreenStatis[@]};do
	#	echo ${layerFullscreenDesc[$[$idx]]} : $i / $composeCount
	#	idx=`expr $idx + 1`
	#done
	echo "-------layer scaled statis-----"
	let idx=0
	for i in ${layerScaledStatis[@]};do
		echo ${layerScaledDesc[$[$idx]]} : $i
		idx=`expr $idx + 1`
	done
	echo "-------layer transform statis-----"
	let idx=0
	for i in ${layerTransformStatis[@]};do
		echo ${layerTransformDesc[$[$idx]]} : $i
		idx=`expr $idx + 1`
	done
	echo "-------layer dataspace statis-----"
	let idx=0
	for i in ${layerDataSpaceStatis[@]};do
		echo ${layerDataSpaceDesc[$[$idx]]} : $i
		idx=`expr $idx + 1`
	done
}


main() {
	echo "start analysis log file ("$logfile")!"

	linenum=1
	lastLayerNum=0
	bNewLine=0
	
	let composeLayerNum=0
	let composeScaledLayerNum=0

	while read line
	do
		linenum=`expr $linenum + 1`
		linechars=${#line}	

		#read layer number
		layerNumStr=${line##$layerNumPrefix}
		if [ ${#layerNumStr} -lt $linechars ]
		then
			if [ $[$lastLayerNum] -gt 0 ]
			then
				echo "ERROR, lastLayerNum "$lastLayerNum ", line "$line
				#return 0
			else
				#echo $composeLayerNum : $composeScaledLayerNum
				#record composeScaled layer num.
				if [ $composeLayerNum -lt 5 ]
				then
					layerNumStatis[$composeLayerNum]=`expr ${layerNumStatis[$composeLayerNum]} + 1`
				else
					layerNumStatis[5]=`expr ${layerNumStatis[5]} + 1`
				fi
				#echo $lastLayerNum :  ${layerNumStatis[$layerNum0]}

				if [ $[$composeLayerNum] -eq 1 ]
				then
					layerNum1Scaled[$[$composeScaledLayerNum]]=`expr ${layerNum1Scaled[$[$composeScaledLayerNum]]} + 1`
				elif [ $[$composeLayerNum] -eq 2 ]
				then
					layerNum2Scaled[$[$composeScaledLayerNum]]=`expr ${layerNum2Scaled[$[$composeScaledLayerNum]]} + 1`
				elif [ $[$composeLayerNum] -eq 3 ]
				then
					layerNum3Scaled[$[$composeScaledLayerNum]]=`expr ${layerNum3Scaled[$[$composeScaledLayerNum]]} + 1`
				elif [ $[$composeLayerNum] -eq 4 ]
				then
					layerNum4Scaled[$[$composeScaledLayerNum]]=`expr ${layerNum4Scaled[$[$composeScaledLayerNum]]} + 1`
				elif [ $[$composeLayerNum] -ge 5 ]
				then
					layerNum5Scaled[$[$composeScaledLayerNum]]=`expr ${layerNum5Scaled[$[$composeScaledLayerNum]]} + 1`
				fi
			fi

			#echo parse: $layerNumStr
			arr=($layerNumStr)
			layerNum0=`expr ${arr[0]}`	
        		layerNum1=`expr ${arr[1]}`
			if [ $layerNum0 -ne $layerNum1 ]
			then
				echo "ERROR layer num "$layerNum0 "vs" $layerNum1
				return 0
			fi

			lastLayerNum=$layerNum0
			composeLayerNum=$layerNum0
			let composeScaledLayerNum=0
			composeCount=`expr $composeCount + 1`	
			#echo -n "."
			continue
		fi

		#read layer attrute
		layerAttrStr=${line##$layerAttrPrefix}
		if [ ${#layerAttrStr} -lt $linechars ]
		then
			lastLayerNum=`expr $lastLayerNum - 1`
			layerAttrStr=${layerAttrStr##$layerAttrPrefix2}

			arr=($layerAttrStr)
			#echo "parse layer attr:"$layerAttrStr
			if [ ${#arr[@]} -ne 8 ]
			then
				echo "get attr faile:"${#arr[@]}
				return 0
			fi

			blendMode=${arr[0]}
			layerBlendStatis[$[$blendMode]]=`expr ${layerBlendStatis[$[$blendMode]]} + 1`

			planeAlpha=${arr[1]}
			layerPlaneAlphaStatis[$[$planeAlpha]]=`expr ${layerPlaneAlphaStatis[$[$planeAlpha]]} + 1`

			bufferType=${arr[2]}
			layerBufferTypeStatis[$[$bufferType]]=`expr ${layerBufferTypeStatis[$[$bufferType]]} + 1`

			dataSpace=${arr[3]}
			let spaceIdx=0
			if [ $[$dataSpace] -gt 0 ]
			then
				let spaceIdx=1
			fi
			layerDataSpaceStatis[$spaceIdx]=`expr ${layerDataSpaceStatis[$spaceIdx]} + 1`

			#bufferCrop=${arr[4]}

			transfrom=${arr[5]}
			layerTransformStatis[$[$transfrom]]=`expr ${layerTransformStatis[$[$transfrom]]} + 1`

			bufferScaled=${arr[6]}
			layerScaledStatis[$[$bufferScaled]]=`expr ${layerScaledStatis[$[$bufferScaled]]} + 1`
			if [ $[$bufferScaled] -eq 1 ]
			then
				composeScaledLayerNum=`expr $[$composeScaledLayerNum] + 1`
			fi

			fullscreenType=${arr[7]}
			layerFullscreenStatis[$[$fullscreenType]]=`expr ${layerFullscreenStatis[$[$fullscreenType]]} + 1`
			
			continue
		fi

	done < $logfile

	
	if [ $[$lastLayerNum] -eq 0 ]
	then
		#record composeScaled layer num.  if [ $[$composeLayerNum] -eq 1 ]
		if [ $[$composeLayerNum] -eq 1 ]
		then
			layerNum1Scaled[$[$composeScaledLayerNum]]=`expr ${layerNum1Scaled[$[$composeScaledLayerNum]]} + 1`
		elif [ $[$composeLayerNum] -eq 2 ]
		then
			layerNum2Scaled[$[$composeScaledLayerNum]]=`expr ${layerNum2Scaled[$[$composeScaledLayerNum]]} + 1`
		elif [ $[$composeLayerNum] -eq 3 ]
		then
			layerNum3Scaled[$[$composeScaledLayerNum]]=`expr ${layerNum3Scaled[$[$composeScaledLayerNum]]} + 1`
		elif [ $[$composeLayerNum] -eq 4 ]
		then
			layerNum4Scaled[$[$composeScaledLayerNum]]=`expr ${layerNum4Scaled[$[$composeScaledLayerNum]]} + 1`
		elif [ $[$composeLayerNum] -ge 5 ]
		then
			layerNum5Scaled[$[$composeScaledLayerNum]]=`expr ${layerNum5Scaled[$[$composeScaledLayerNum]]} + 1`
		fi
	fi

	echo "analysis end, lines ("$linenum"),frames("$composeCount")"
}


dos2unix $logfile
main
dumpComposeStatis


exit 0

