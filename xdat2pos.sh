#!/bin/bash
## written by Zhufeng HOU, Dec 14,2018
fpos='XDATCAR'
if [ $# -ne 1 ]; then
    echo "Command line shall contain 1 arguments."
    echo "Example: XDATCAR "
    echo "1st arg: name of a XDATCAR-like file"
    exit 1
else
fpos="$1"

isvasp5=false
isseldyna=false
isdirect=false

    line6=`sed -n  '6p'   $fpos |awk '{printf "%s\n", $1}'`
    line7=`sed -n  '7p'   $fpos |awk '{printf "%s\n", $1}'`
    line8=`sed -n  '8p'   $fpos |awk '{printf "%s\n", $1}'`
    line9=`sed -n  '9p'   $fpos |awk '{printf "%s\n", $1}'`
    ## check the 1st argument; convert the 1st character of the 1st argument into a lower case.
    first_char_line6="$(printf '%s' $line6 | cut -c1)"
    first_char_line7="$(printf '%s' $line7 | cut -c1)"
    first_char_line8="$(printf '%s' $line8 | cut -c1)"
    first_char_line9="$(printf '%s' $line9 | cut -c1)"
    lfirst_char_line6=`echo "$first_char_line6" | awk '{ print tolower($1) }'`
    lfirst_char_line7=`echo "$first_char_line7" | awk '{ print tolower($1) }'`
    lfirst_char_line8=`echo "$first_char_line8" | awk '{ print tolower($1) }'`
    lfirst_char_line9=`echo "$first_char_line9" | awk '{ print tolower($1) }'`
    if [ `echo "$lfirst_char_line6" | grep [a-zA-Z]`  ];then
        isvasp5=true
    else
        isvasp5=false
    fi

    if $isvasp5;then
        line4coor1=9
        elemptype=(`sed -n  '6p'   $fpos`)
        ionsptype=(`sed -n  '7p'   $fpos`)
        if [  "$lfirst_char_line8" == 's' ];then
            isseldyna=true
            line4coor1=10
            if [ "$lfirst_char_line9" == 'd' ];then
                isdirect=true
            fi
        elif [ "$lfirst_char_line8" == 'd' ];then
            isdirect=true
        else
            isdirect=false
            isseldyna=false
        fi
    else
        line4coor1=8
        elemptype=()
        ionsptype=(`sed -n  '6p'   $fpos`)
        for index in ${!ionsptype[*]};do
            elemptype+=(`echo $index |awk '{printf "%d\n", $1+1}'`)
        done

        if [  "$lfirst_char_line7" == 's' ];then
            line4coor1=9
            isseldyna=true
            if [ "$lfirst_char_line8" == 'd' ];then
                isdirect=true
            fi
        elif [ "$lfirst_char_line7" == 'd' ];then
            isdirect=true
        else
            isdirect=false
            isseldyna=false
        fi
    fi

    #echo ${elemptype[*]}   ${ionsptype[*]}
    #echo $isvasp5  $isseldyna  $isdirect
	nions=0
    for index in "${!ionsptype[@]}";do
	     nions=`echo 'scale=8;'  "$nions + ${ionsptype[index]}  "|bc -l`
	done

    title=`head -1  $1 | awk '{printf "%s\n", $1}'`
    nconf=`grep 'configuration=' $1 |wc -l`
    conflines=(`sed -n  '/configuration=/=' $1 `)
    titlelines=(`sed -n "/${title}/="  $1`)

    for idx in `seq  0  $((${nconf}-1))`;do
        idfirst=`echo 'scale=5;'  "${conflines[$idx]}- ${conflines[0]} +1"|bc -l | awk '{printf "%d\n", $1}'`
        idlast=`echo 'scale=5;'  "$idfirst +$nions + ${conflines[0]} -1"|bc -l | awk '{printf "%d\n", $1}'`
        id=`echo $idx |awk '{printf "%05d\n", $1+1}'`
        sed -n "$idfirst","$idlast"p  $1    > conf_"$id".vasp
    done
fi
