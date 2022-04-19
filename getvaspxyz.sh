#!/bin/bash
#natom=161
#echo -n "Enter the number of atoms 'natom':"
#read natom
pwd1=`echo ${PWD##*/}`

natom=`grep 'NIONS' OUTCAR|tail -1 |awk '{printf "%s\n", $12}'`
last=`sed -n '/total drift:/=' OUTCAR |tail -1`
iaf=`echo "$last - 2 - $natom" |bc -l `
echo $natom        > opt.xyz 
sed -n "$iaf",+"$natom"p OUTCAR  >>opt.xyz
echo "The latest atomic positions are written to opt.xyz!"
iptc=`grep 'ions per type =' OUTCAR|tail -1 `
ipt=(`echo "${iptc##*=}"`)
ats=(`grep 'VRHFIN ='  OUTCAR | sed -e 's/=/  /g' |sed -e 's/:/  /g'| awk '{printf "%s\n", $2}' `)
ntp=${#ipt[@]}
i=2
for  it in `seq 0  $((${ntp}-1))`;do
    for j in `seq 1  ${ipt[$it]}`;do
    i=`echo "$i +1 " |bc` 
    elem=${ats[$it]} 
    sed -i "$i s/^/$elem/" opt.xyz
done
done

#cp opt.xyz   opt-"$pwd1".xyz
  
nstep=(`sed -n '/total drift:/=' OUTCAR `)
etot=(`grep 'energy  without entropy=' OUTCAR |awk '{printf "%20.8f\n", $4}' `)
myFile="trajec.xyz"
if [ ! -e "$myFile" ]; then 
echo $natom  > $myFile 
sed -i '1d' $myFile
fi 

#if  [ ${#nstep[@]} -gt 100 ];then
#  nd=20
#else
#  nd=1
#fi
for k in `seq 0  $((${#nstep[@]}-1))`;do
iaf=`echo "${nstep[k]} - 2 - $natom" |bc -l `
if [  $k -eq 0 ];then
echo $natom  > $myFile 
else
echo $natom  >> $myFile 
fi
sed -n "$iaf",+"$natom"p OUTCAR  >> $myFile
i=`echo "$k * ($natom+2) + 2"|bc -l`
sed -i "$i s/^/#Etotal: ${etot[k]} eV/"  $myFile 
for  it in `seq 0  $((${ntp}-1))`;do
    for j in `seq 1  ${ipt[$it]}`;do
    i=`echo "$i +1 " |bc` 
    elem=${ats[$it]} 
    sed -i "$i s/^/$elem/"  $myFile 
done
done
done
echo "The atomic positions in each optimization step are written to trajec.xyz!"
#cp  trajec.xyz   trajec-"$pwd1".xyz
