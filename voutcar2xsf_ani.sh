#!/bin/bash
## written by Zhufeng HOU, Dec 14,2018
fout='OUTCAR'
if [ $# -ne 1 ]; then
    echo "Command line shall contain 1 arguments."
    echo "Example: OUTCAR "
    echo "1st arg: name of a OUTCAR-like file"
    exit 1
else
    fout="$1"

    nstep=(`sed -n '/total drift:/=' $fout`)
    echo 'ANIMSTEPS' "${#nstep[@]}"
    linelattice=(`sed -n '/direct lattice vectors/=' $fout`)
    lineposition=(`sed -n '/POSITION/=' $fout`)
    ionsptype=(`grep 'ions per type ='  $fout|sed 's/ions per type =//g' `)
    elemptype=(`grep 'VRHFIN =' $fout  |sed 's/VRHFIN =/ /g' |sed 's/:/ /g'| awk '{printf "%s\n", $1}'`)
    
	nions=0
    for index in "${!ionsptype[@]}";do
	     nions=`echo 'scale=8;'  "$nions + ${ionsptype[index]}  "|bc -l`
	done

    ##head lines in a XSF file
    for k in `seq 0  $((${#nstep[@]}-1))`;do
    if [  $k -eq 0 ];then
    echo "CRYSTAL"
    fi
    step=`echo ${k}+1|bc -l`
    echo "PRIMVEC" "${step}"
    for i in `seq 1 3`;do
        pline=`echo 'scale=5;' "${i} +  ${linelattice[k+1]} " |bc -l |awk '{printf "%5d\n", $1}'`
        sed -n  "${pline}p"   $fout |awk '{printf "%15.5f %15.5f %15.5f\n", $1, $2, $3}'
    done


    echo "CONVVEC" "${step}"
    for i in `seq 1 3`;do
        pline=`echo 'scale=5;' "${i} +  ${linelattice[k+1]} " |bc -l |awk '{printf "%5d\n", $1}'`
        sed -n  "${pline}p"   $fout |awk '{printf "%15.5f %15.5f %15.5f\n", $1, $2, $3}'
    done
    echo "PRIMCOORD" "${step}"
    echo  "$nions"   " 1"
    #### print out the Cartesian coordinates of atoms
    ia=0
    for index in ${!ionsptype[*]};do
        aa=`echo ${ionsptype[$index]}`
        for j in `seq 1 $aa`;do
            let ia+=1
            pline=`echo 'scale=5;' "${ia} +  ${lineposition[k]}+1 " |bc -l |awk '{printf "%5d\n", $1}'`
            cx=`sed -n  "${pline}p"   $fout |awk '{printf "%15.5f\n", $1}'`
            cy=`sed -n  "${pline}p"   $fout |awk '{printf "%15.5f\n", $2}'`
            cz=`sed -n  "${pline}p"   $fout |awk '{printf "%15.5f\n", $3}'`
            fx=`sed -n  "${pline}p"   $fout |awk '{printf "%15.5f\n", $4}'`
            fy=`sed -n  "${pline}p"   $fout |awk '{printf "%15.5f\n", $5}'`
            fz=`sed -n  "${pline}p"   $fout |awk '{printf "%15.5f\n", $6}'`
            echo  ${elemptype[$index]}  $cx  $cy  $cz  $fx $fy  $fz \
              |awk '{printf "%5s %15.5f %15.5f %15.5f  %15.5f %15.5f %15.5f\n", $1, $2, $3, $4, $5, $6, $7}'
        done
    done
    done
fi
