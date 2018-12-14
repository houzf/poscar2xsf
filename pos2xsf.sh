#!/bin/bash
fpos='POSCAR'
if [ $# -ne 1 ]; then
    echo "Command line shall contain 1 arguments."
    echo "Example: POSCAR "
    echo "1st arg: name of a POSCAR-like file"
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


    scale=`sed -n  '2p'  $fpos  |awk '{printf "%15.5f\n", $1}'`
    lat1=`sed -n  '3p'   $fpos `
    lat2=`sed -n  '4p'   $fpos `
    lat3=`sed -n  '5p'   $fpos `
    a1=`echo $lat1 |awk -v sca="$scale" '{printf "%15.5f\n", $1 * sca}'`
    a2=`echo $lat1 |awk -v sca="$scale" '{printf "%15.5f\n", $2 * sca}'`
    a3=`echo $lat1 |awk -v sca="$scale" '{printf "%15.5f\n", $3 * sca}'`
    b1=`echo $lat2 |awk -v sca="$scale" '{printf "%15.5f\n", $1 * sca}'`
    b2=`echo $lat2 |awk -v sca="$scale" '{printf "%15.5f\n", $2 * sca}'`
    b3=`echo $lat2 |awk -v sca="$scale" '{printf "%15.5f\n", $3 * sca}'`
    c1=`echo $lat3 |awk -v sca="$scale" '{printf "%15.5f\n", $1 * sca}'`
    c2=`echo $lat3 |awk -v sca="$scale" '{printf "%15.5f\n", $2 * sca}'`
    c3=`echo $lat3 |awk -v sca="$scale" '{printf "%15.5f\n", $3 * sca}'`
    #echo "Lattice vectors:"
    #echo  $a1  $a2  $a3  |awk '{printf "%15.5f %15.5f %15.5f\n", $1, $2, $3}'
    #echo  $b1  $b2  $b3  |awk '{printf "%15.5f %15.5f %15.5f\n", $1, $2, $3}'
    #echo  $c1  $c2  $c3  |awk '{printf "%15.5f %15.5f %15.5f\n", $1, $2, $3}'
    ##Matrix of CoFactors 
    cfa1=`echo 'scale=15;' "${b2} *  ${c3} -  ${b3} *  ${c2}" |bc -l |awk '{printf "%15.5f\n", $1}'`
    cfa2=`echo 'scale=15;' "-(${b1} *  ${c3} -  ${b3} *   ${c1})" |bc -l |awk '{printf "%15.5f\n", $1}'`
    cfa3=`echo 'scale=15;' "${b1} *  ${c2} -  ${b2} *   ${c1}" |bc -l |awk '{printf "%15.5f\n", $1}'`
    cfb1=`echo 'scale=15;' "-(${a2} *  ${c3} -  ${a3} *   ${c2})" |bc -l |awk '{printf "%15.5f\n", $1}'`
    cfb2=`echo 'scale=15;' "${a1} *  ${c3} -  ${a3} *   ${c1}" |bc -l |awk '{printf "%15.5f\n", $1}'`
    cfb3=`echo 'scale=15;' "-(${a1} *  ${c2} -  ${a2} *   ${c1})" |bc -l |awk '{printf "%15.5f\n", $1}'`
    cfc1=`echo 'scale=15;' "${a2} *  ${b3} -  ${a3} *   ${b2}" |bc -l |awk '{printf "%15.5f\n", $1}'`
    cfc2=`echo 'scale=15;' "-(${a1} *  ${b3} -  ${a3} *   ${b1})" |bc -l |awk '{printf "%15.5f\n", $1}'`
    cfc3=`echo 'scale=15;' "${a1} *  ${b2} -  ${a2} *   ${b1}" |bc -l |awk '{printf "%15.5f\n", $1}'`
    ## Determinant of a matrix
    det1=`echo 'scale=15;' " (${a1} *  ${cfa1} +  ${a2} * ${cfa2} + ${a3} * ${cfa3}) " |bc -l |awk '{printf "%15.5f\n", $1}'`
    det2=`echo 'scale=15;' " (${a2} *  ${cfa2} +  ${b2} * ${cfb2} + ${c2} * ${cfc2}) " |bc -l |awk '{printf "%15.5f\n", $1}'`
    #echo  $det1  $det2
    if [ ` echo " $det1 < 0.00" |bc -l` ];then 
        det1=`echo $det1 | awk '{printf "%15.5f\n", -$1}'`
    else
        echo "Determinant of lattice vectors is negative."
        exit 1
    fi
    # Inverse of a matrix
    inva1=`echo 'scale=15;' "${cfa1} /  ${det1} " |bc -l |awk '{printf "%15.5f\n", $1}'`
    inva2=`echo 'scale=15;' "${cfb1} /  ${det1} " |bc -l |awk '{printf "%15.5f\n", $1}'`
    inva3=`echo 'scale=15;' "${cfc1} /  ${det1} " |bc -l |awk '{printf "%15.5f\n", $1}'`
    invb1=`echo 'scale=15;' "${cfa2} /  ${det1} " |bc -l |awk '{printf "%15.5f\n", $1}'`
    invb2=`echo 'scale=15;' "${cfb2} /  ${det1} " |bc -l |awk '{printf "%15.5f\n", $1}'`
    invb3=`echo 'scale=15;' "${cfc2} /  ${det1} " |bc -l |awk '{printf "%15.5f\n", $1}'`
    invc1=`echo 'scale=15;' "${cfa3} /  ${det1} " |bc -l |awk '{printf "%15.5f\n", $1}'`
    invc2=`echo 'scale=15;' "${cfb3} /  ${det1} " |bc -l |awk '{printf "%15.5f\n", $1}'`
    invc3=`echo 'scale=15;' "${cfc3} /  ${det1} " |bc -l |awk '{printf "%15.5f\n", $1}'`
    #echo  $inva1  $inva2  $inva3  |awk '{printf "%15.5f %15.5f %15.5f\n", $1, $2, $3}'
    #echo  $invb1  $invb2  $invb3  |awk '{printf "%15.5f %15.5f %15.5f\n", $1, $2, $3}'
    #echo  $invc1  $invc2  $invc3  |awk '{printf "%15.5f %15.5f %15.5f\n", $1, $2, $3}'

    ##head lines in a XSF file
    echo "CRYSTAL"
    echo "PRIMVEC"
    echo  $a1  $a2  $a3  |awk '{printf "%15.5f %15.5f %15.5f\n", $1, $2, $3}'
    echo  $b1  $b2  $b3  |awk '{printf "%15.5f %15.5f %15.5f\n", $1, $2, $3}'
    echo  $c1  $c2  $c3  |awk '{printf "%15.5f %15.5f %15.5f\n", $1, $2, $3}'
    echo "CONVVEC"
    echo  $a1  $a2  $a3  |awk '{printf "%15.5f %15.5f %15.5f\n", $1, $2, $3}'
    echo  $b1  $b2  $b3  |awk '{printf "%15.5f %15.5f %15.5f\n", $1, $2, $3}'
    echo  $c1  $c2  $c3  |awk '{printf "%15.5f %15.5f %15.5f\n", $1, $2, $3}'
    echo "PRIMCOORD"
    echo  "$nions"   " 1"
    #### print out the Cartesian coordinates of atoms
    ia=0
    for index in ${!ionsptype[*]};do
        aa=`echo ${ionsptype[$index]}`
        for j in `seq 1 $aa`;do
            let ia+=1
            pline=`echo 'scale=5;' "${ia} +  ${line4coor1}-1 " |bc -l |awk '{printf "%5d\n", $1}'`
            pu=`sed -n  "${pline}p"   $fpos |awk '{printf "%15.5f\n", $1}'`
            pv=`sed -n  "${pline}p"   $fpos |awk '{printf "%15.5f\n", $2}'`
            pw=`sed -n  "${pline}p"   $fpos |awk '{printf "%15.5f\n", $3}'`
            if $isdirect;then
                cx=`echo 'scale=15;' "${pu} *  ${a1} +  ${pv} *  ${b1} + ${pw} *  ${c1} " |bc -l |awk '{printf "%15.5f\n", $1}'`
                cy=`echo 'scale=15;' "${pu} *  ${a2} +  ${pv} *  ${b2} + ${pw} *  ${c2} " |bc -l |awk '{printf "%15.5f\n", $1}'`
                cz=`echo 'scale=15;' "${pu} *  ${a3} +  ${pv} *  ${b3} + ${pw} *  ${c3} " |bc -l |awk '{printf "%15.5f\n", $1}'`
            else
                cx=`echo "${pu} " |awk '{printf "%15.5f\n", $1}'`
                cy=`echo "${pv} " |awk '{printf "%15.5f\n", $1}'`
                cz=`echo "${pw} " |awk '{printf "%15.5f\n", $1}'`
            fi
            echo  ${elemptype[$index]}  $cx  $cy  $cz  |awk '{printf "%5s %15.5f %15.5f %15.5f\n", $1, $2, $3, $4}'
        done
    done
fi
