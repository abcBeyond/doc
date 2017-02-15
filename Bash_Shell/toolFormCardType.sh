#! /bin/bash

beginstr="******************************卡关联生成/更爱脚本，你可以根据以下提示\
			输入具体内容****************"

createOrUpDate="创建卡关联文件 修正卡关联文件"
fileName="CardTypeRelateParameterDL.csv"
cardType=("01" "32" "45" "67" "86" "35" "23" "33" "34")
cardTypeName=("普通卡" "老年卡" "关爱卡" "学生卡" "爱心卡" "拥军卡" "夕阳红卡" "小学生卡" "优惠卡")
cardTypeContent="主卡类型 是否允许使用 语音 同一张卡有效交易间隔时间\
				优先扣款方式 消费上限 消费下限 是否可透支 钱包上限 \
				是否检查黑名单 是否检查有效期开始 是否检查有效期结束\
				同公交线路间联乘优惠标志 单位时间内优惠次数上限 最小联乘时间间隔\
				最大联乘时间间隔 联乘折扣类型 联乘折扣值 分段计价逃票付款方式 \
				分段计价逃票扣款值 失眠机制是否开启 失眠时间 基础折扣类型 基础折扣值 是否开启特殊时段调整票价"

numTest=${#cardType[@]}

usage=""
for((i=0;i<$numTest;i++))
do
	usage=$usage"**"${cardType[$i]}"-"${cardTypeName[$i]}	
done
strDate=`date +%y%m%d%H%M%S`
cardNumth=0;
##默认数据
dataMainCardType=0
dataIsEnable=1
dataVoice=2
dataPeriod=3
dataCostStyle=4
dataMaxPrice=5
dataMinPrice=6
dataOverDraw=7
dataMaxBalance=8
dataCheckBlack=9
dataCheckStart=10
dataCheckEnd=11
dataMulCheckLine=12
dataMulMaxTimes=13
dataMulMinBetTime=14
dataMulMaxBetTime=15
dataMultype=16
dataMulPrice=17
dataMulRideCostStyle=18
dataMulRideCostPrice=19
dataIsSleep=20
dataSleepTime=21
dataBaseDiscountType=22
dataBaseDiscountPrice=23
dataOpenSpePrice=24

dataArray=("00" "01" "00000000" "01" "00" "00000000" "00000000" "00" "00000000" "00" "00" "00" "00" "00000000" \
			"000000" "000000" "00" "00000000" "00" "00000000" "00" "0000" "00" "0000" "00")

strisenable="可以使用 不可使用"
strperiod="禁止连续刷卡 允许连续刷卡 输入刷卡间隔"
strCostType="扣钱 扣次 显扣次，次数不足再扣钱"
strOverDraw="可透支 不可透支"
strCheckBlackList="不检测黑名单 检测黑名单"
strCheckOutDataStart="不检测有效期开始 检测有效期开始"
strCheckOutDataEnd="不检测有效期结束 检测有效期结束"
strCheckMulLine="联乘不优惠 联乘优惠"
strMulRideType="无折扣 优惠差额 百分比 固定钱数"
strMulRideCostType="补扣卡 全程票价 全额票价 固定值"
strisOpenSleepMode="不开启 开启"
strisOpenSpeTimePrice="不开启 开启"
strBaseDiscountType="无折扣 优惠差额 百分比 固定钱数 上浮差额"

lenTemp=${#fileName}
let lenTemp=lenTemp-4

fileHead=`echo $fileName | cut -c -$lenTemp`
##write some 0 to the file 
###################################################################################################################
function writeZero() 
{
	i=0
	while [ $i -lt $1 ]
	do	
		echo -n 0 >> $fileName
		let i=i+1
	done
}

function commonSelect()
{
	select i in $* 
	do
		selectNum=$REPLY
		break
	done

}
function funcSetMainCardType()
{
		echo "做什么，最好别做-----～～～～------"	
}
function funcSetIsEnable()
{
	#str=${dataArray[$iData]}
	#len=${#str}
	#read 
	commonSelect $strisenable 
	if [ $selectNum -eq 1 ]
	then
		dataArray2[$dataIsEnable]="01"
	else
		dataArray2[$dataIsEnable]="00"
	fi
}

function funcSetVoice()
{
		echo "设置语音"
}

function funcSetPeriod()
{
		commonSelect $strperiod
		case $REPLY in
			1)dataArray2[dataPeroid]="00";;
			2)dataArray2[dataPeroid]="01";;
			3)	echo "请输入刷卡时间间隔(单位S,输入HEX!!!!!!!)"
				read a
				dataArray2[dataPeroid]=$a;;
			*);;
		esac
}

function funcSetCostType()
{
	commonSelect $strCostType
	case $REPLY in
		1) dataArray2[dataCostStyle]="00";;
		2) dataArray2[dataCostStyle]="01";;
		3) dataArray2[dataCostStyle]="02";;
		*) ;;
	esac
}

function funcMaxPrice()
{
	echo "设置消费上限说明：单位为分，输入DEC码，如50元，既输入5000"
	read a
	len=${#a}
	str=${dataArray2[$dataMaxPrice]}
	lenTotal=${#str}
	let len=lenTotal-len
	result=""
	for((i=0;i<len;i++))
	do
		result=$result"0"
	done
	result=$result$a
	echo $result
	dataArray2[$dataMaxPrice]=$result
}

function funcMinPrice()
{
	echo "设置消费下限说明：单位为分，输入DEC码，如50元，既输入5000"
	read a
	len=${#a}
	str=${dataArray2[$dataMaxPrice]}
	lenTotal=${#str}
	let len=lenTotal-len
	result=""
	for((i=0;i<len;i++))
	do
		result=$result"0"
	done
	result=$result$a
	echo $result
	dataArray2[$dataMinPrice]=$result
}

function funcSetOverDraw()
{
	commonSelect $strOverDraw
	case $REPLY in
		1) dataArray2[$dataOverDraw]="00";;
		2) dataArray2[$dataOverDraw]="01";;
		*) ;;
	esac
}

function funcMaxBalance()
{
	echo "设置消费下限说明：单位为分，输入DEC码，如50元，既输入5000"
	read a
	len=${#a}
	str=${dataArray2[$dataMaxBalance]}
	lenTotal=${#str}
	let len=lenTotal-len
	result=""
	for((i=0;i<len;i++))
	do
		result=$result"0"
	done
	result=$result$a
	echo $result
	dataArray2[$dataMaxBalance]=$result
}

function funcCheckOverDraw()
{
	commonSelect $strOverDraw
	case $REPLY in
		1) dataArray2[dataOverDraw]="00";;
		2) dataArray2[dataOverDraw]="01";;
		*) ;;
	esac
}
function funcCheckBlackList()
{
	commonSelect $strCheckBlackList
	case $REPLY in
		1) dataArray2[$dataCheckBlack]="00";;
		2) dataArray2[$dataCheckBlack]="01";;
		*) ;;
	esac
}
function funcCheckOutDataStart()
{
	commonSelect $strCheckOutDataStart
	case $REPLY in
		1) dataArray2[$dataCheckStart]="00";;
		2) dataArray2[$dataCheckStart]="01";;
		*) ;;
	esac
}
function funcCheckOutDataEnd()
{
	commonSelect $strCheckOutDataEnd
	case $REPLY in
		1) dataArray2[$dataCheckEnd]="00";;
		2) dataArray2[$dataCheckEnd]="01";;
		*) ;;
	esac
}

function funcMulRideOneLine()
{
	commonSelect $strCheckMulLine
	case $REPLY in
		1) dataArray2[$dataMulCheckLine]="00";;
		2) dataArray2[$dataMulCheckLine]="01";;
		*) ;;
	esac
}
function funcsetMulMaxTimes()
{
	echo "暂时不对应"
}

function funcMinMulTime()
{
	read a
	len=${#a}
	str=${dataArray2[$dataMulMinBetTime]}
	lenTotal=${#str}
	let len=lenTotal-len
	result=""
	for((i=0;i<len;i++))
	do
		result=$result"0"
	done
	result=$result$a
	echo $result
	dataArray2[$dataMulMinBetTime]=$result
}
function funcMaxMulTime()
{
	read a
	len=${#a}
	str=${dataArray2[$dataMulMaxBetTime]}
	lenTotal=${#str}
	let len=lenTotal-len
	result=""
	for((i=0;i<len;i++))
	do
		result=$result"0"
	done
	result=$result$a
	echo $result
	dataArray2[$dataMulMaxBetTime]=$result
}
function funcSetMulType()
{
	commonSelect $strMulRideType
	case $REPLY in
		1) dataArray2[$dataMultype]="00";;
		2) dataArray2[$dataMultype]="01";;
		3) dataArray2[$dataMultype]="02";;
		4) dataArray2[$dataMultype]="03";;
		*) ;;
	esac
}
function funcMulRidePrice()
{
	echo "请先选择联乘折扣类型------"
}

function funcMulRideCostType()
{
	commonSelect $strMulRideCostType
	case $REPLY in
		1) dataArray2[$dataMulRideCostStyle]="00";;
		2) dataArray2[$dataMulRideCostStyle]="01";;
		3) dataArray2[$dataMulRideCostStyle]="02";;
		4) dataArray2[$dataMulRideCostStyle]="03";;
		*) ;;
	esac
}
function funcMulRideCostPrice()
{
	echo "请先选择分段计价逃票补扣方式----"
}
function funcisSleepMode()
{
	commonSelect $strisOpenSleepMode 
	case $REPLY in
		1) dataArray2[$dataIsSleep]="00";;
		2) dataArray2[$dataIsSleep]="01";;
		*) ;;
	esac
}
function funcSetSleepTime()
{
	read a
	len=${#a}
	str=${dataArray2[$dataSleepTime]}
	lenTotal=${#str}
	let len=lenTotal-len
	result=""
	for((i=0;i<len;i++))
	do
		result=$result"0"
	done
	result=$result$a
	echo $result
	dataArray2[$dataSleepTime]=$result
}
function funcBaseDiscountType()
{
	commonSelect $strBaseDiscountType
	case $REPLY in
		1) dataArray2[$dataBaseDiscountType]="00";;
		2) dataArray2[$dataBaseDiscountType]="01";;
		3) dataArray2[$dataBaseDiscountType]="02";;
		4) dataArray2[$dataBaseDiscountType]="03";;
		5) dataArray2[$dataBaseDiscountType]="04";;
		*) ;;
	esac
}
function funcBaseDiscountPrice()
{
	echo "请先选择基础折扣类型-----"
}
function funcisOpenSpcTimePrice()
{
	commonSelect $strisOpenSpeTimePrice
	case $REPLY in
		1) dataArray2[$dataOpenSpePrice]="00";;
		2) dataArray2[$dataOpenSpePrice]="01";;
		*) ;;
	esac
}
function echoFun()
{
	echo "common function"
}
funcArray=(funcSetMainCardType funcSetIsEnable funcSetVoice funcSetPeriod funcSetCostType \
	funcMaxPrice funcMinPrice funcCheckOverDraw funcMaxBalance funcCheckBlackList \
	funcCheckOutDataStart funcCheckOutDataEnd funcMulRideOneLine funcsetMulMaxTimes funcMinMulTime \
	funcMaxMulTime funcSetMulType funcMulRidePrice funcMulRideCostType funcMulRideCostPrice funcisSleepMode \
	funcSetSleepTime funcBaseDiscountType funcBaseDiscountPrice funcisOpenSpcTimePrice)

#########################################################################################################################

	function createCardTypeFile()
	{
		#create the file
		if [ -e $fileName ]
		then 
			#echo $fileHead'_'$strDate.csv
			mv $fileName $fileHead'_'$strDate.csv 
		fi

		touch $fileName
		iTest=0
		len=${#dataArray[@]}
		for((i=0;i<$len;i++))
	do
		dataArray2[$i]=${dataArray[$i]}
	done


	for cardTypeDetail in ${cardType[@]}
	do	
		echo "=========设置 ${cardTypeName[$iTest]} 为默认状态??======"
		echo "确定输入Y,否则输入N"
		read a
		if [ -z $a ] || [ $a = 'Y' ] || [ $a = 'y' ]
		then
				let iTest=iTest+1
				result=""
				for((i=0;i<$len;i++))
				do
					result=$result${dataArray2[$i]}
					if [ $i -eq 0 ]
					then
						result=$result$cardTypeDetail
					fi
				done
				echo $result >> $fileName	
			continue
		fi
		while : 
		do	
		echo "=========设置 ${cardTypeName[$iTest]} 相关内容==========="
		commonSelect $cardTypeContent
		iFuncTh=$REPLY
		let iFuncTh=iFuncTh-1
		${funcArray[$iFuncTh]}		
		echo "继续设置 ${cardTypeName[$iTest]}?? Y/N"
		read a
		if  [ -z $a ]|| [ $a = 'y'  ] || [ $a = 'Y' ]
		then
				continue;	
		else
				result=""
				for((i=0;i<$len;i++))
				do
					result=$result${dataArray2[$i]}
					if [ $i -eq 0 ]
					then
						result=$result$cardTypeDetail
					fi
				done
				echo $result >> $fileName	
				##reset array dataArray2	
				for((i=0;i<$len;i++))
				do
					dataArray2[$i]=${dataArray[$i]}
				done
				let iTest=iTest+1
				break	
				echo "=========设置 ${cardTypeName[$iTest]} 内容完成==========="
		fi
		done
	done
	}
	function readDataToArray()
	{
		str=$1	
		arrayNum=${#dataArray[@]}
		numTemp=0
		strLen=0
		for((i=0;i<$arrayNum;i++))
		do
			strLen=${#dataArray[$i]}
			dataArray2[$i]=${str:$numTemp:$strLen}
			if [ $i -eq 0 ]
			then
				let numTemp=$numTemp+2

			fi

			let numTemp=$numTemp+$strLen
		done

	}
	function upDateCardTypeFile()
	{
			echo "===========请选择要修正的文件按名称============"
			echo

			filelist=`ls | grep $fileHead`
		
			select selFileName in $filelist
			do
				break;
			done
			
			##读取当前文件关键字节到数组cardType中	
			cardTypeNum=0
			cat $selFileName | while read a
			do
				cardType[cardTypeNum]="${a:2-4}"
				let cardTypeNum=cardTypeNum+1	
			done

			##选择要修正的卡类型
			echo "============选择要修正的卡类型============="
			echo $usage
			echo	
			select cardTypeTemp in ${cardType[@]}
			do
				break
			done
				
			##检测是否有临时文件，如果有的话删除,重新创建
			newFileName=$fileHead"_temp.csv"
			if [ -e $newFileName ]
			then
				rm $newFileName
			fi	
			touch $newFileName
		
			array3Num=0
			array2Len=${#dataArray[@]}
			totalLine=`cat $selFileName | wc -l`
			lineNum=1	
			while [ $lineNum -le $totalLine ]
			do	
				str_a=`sed -n "${lineNum}p" $selFileName`
				cardType2=`echo $str_a | cut -c 3-4`
				if [ $cardTypeTemp = $cardType2 ]
				then 
					readDataToArray $str_a
					while :  
					do
						echo "==========选择要修正的内容========"
						echo
						commonSelect $cardTypeContent
						let numth=$REPLY-1		
						${funcArray[$numth]}	
						echo "继续修改??Y/N"
						read b
						if  [ -z $b ] || [ $b = 'y'  ] || [ $b = 'Y' ]
						then
							continue;	
						else
							result=""
							for((i=0;i<$array2Len;i++))
							do
								result=$result${dataArray2[$i]}
								if [ $i -eq 0 ]
								then
									result=$result$cardTypeTemp
								fi
							done
							echo $result >> $newFileName
							break
						fi
					done
				else
					echo $str_a >> $newFileName
				fi
			let lineNum=lineNum+1
		done
		mv $newFileName $selFileName	
	}
#####start#######
#打印输入提示
echo 
echo

echo $beginstr

echo
echo
commonSelect $createOrUpDate

case $REPLY in
	1)createCardTypeFile;;
	2)upDateCardTypeFile;;
	*)echo "input error";;
esac

