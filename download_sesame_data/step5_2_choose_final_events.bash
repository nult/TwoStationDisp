#!/bin/bash
# Written by Kai Wang, Mar 2019

#double check if we save the roughly selected events from step5-1
# Central of area used to calculate baz of events
in=mid_events
out=final_events
if true;then
###@@@@ first time @@@@@###
i=1
for cl in dep200-1000 dep0-30;do
  cp evt_catalog_${cl}/${out}_${cl}.lst ${in}_${cl}.lst
  cat /dev/null >${out}_${cl}.lst
  ##copy the final-evetns selected from step 5-1
  IFS=$'\n'
  for line in `cat ${in}_${cl}.lst`;do
    evtpath=`echo $line |awk '{print $1}'` 
    pspath=`echo $evtpath |awk -F/ '{printf"%s/%s",$1,$2}'`
    evnm=`echo $evtpath |awk -F/ '{print $3}'`
    lon=`echo $line |awk '{print $2}'` 
    lat=`echo $line |awk '{print $3}'` 
    dep=`echo $line |awk '{print $4}'` 
    gv -scale=0.6  $pspath/seismo_${evnm}.ps &
    echo "Save this event or Not? Yes(y)No(n)"
    read issave
    if [ $issave == "y" ];then
       echo $evtpath $lon $lat $dep>>${out}_${cl}.lst
    fi
    let i=i+1
    if [ $i -gt 5 ];then
       killall gv
       i=1
    fi
  done
done
killall gv
fi
###@@@@ Second time to check and modify @@@@@###
if true;then
i=1
for cl in dep200-1000 dep0-30;do
cp ${out}_${cl}.lst ${in}_${cl}.lst
cat /dev/null >${out}_${cl}.lst
IFS=$'\n'
  for line in `cat ${in}_${cl}.lst`;do
    evtpath=`echo $line |awk '{print $1}'`
    pspath=`echo $evtpath |awk -F/ '{printf"%s/%s",$1,$2}'`
    evnm=`echo $evtpath |awk -F/ '{print $3}'`
    lon=`echo $line |awk '{print $2}'`
    lat=`echo $line |awk '{print $3}'`
    dep=`echo $line |awk '{print $4}'`
    gv -scale=0.6  $pspath/seismo_${evnm}.ps &
    echo "Save this event or Not? Yes(y)No(n)"
    read issave
    if [ $issave == "y" ];then
       echo $evtpath $lon $lat $dep>>${out}_${cl}.lst
    fi
    let i=i+1
    if [ $i -gt 5 ];then
       killall gv
       i=1
    fi
done
done
killall gv
fi
#*********** sort the list by baz **********
cat /dev/null > temp
for cl in dep200-1000 dep0-30;do
  IFS=$'\n'
  for line in `cat ${out}_${cl}.lst`;do
    evtpath=`echo $line |awk '{print $1}'` 
    pspath=`echo $evtpath |awk -F/ '{printf"%s/%s",$1,$2}'`
    evnm=`echo $evtpath |awk -F/ '{print $3}'`
    lon=`echo $line |awk '{print $2}'` 
    lat=`echo $line |awk '{print $3}'` 
    dep=`echo $line |awk '{print $4}'` 
    dist=`~/software/sactools_c/distaz 45.0 -93.0 $lat $lon |tail -1 |awk '{print $1}' `
    baz=`~/software/sactools_c/distaz 45.0 -93.0 $lat $lon |tail -2 |awk '{print $2}' `
    ~/software/TauP-2.5.0/bin/taup_time -mod prem -h $dep  -ph P -deg $dist >taup.out
    inc_ang=`cat taup.out |sed -n '6p' |awk '{print $7}'`  ## Incident angle
 
    echo $evtpath $lon $lat $dep $baz $inc_ang >> temp
  done
done
sort -k 5 -n temp >final_events_P.lst
exit
#********************************************
