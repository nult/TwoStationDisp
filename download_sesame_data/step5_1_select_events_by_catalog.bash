#!/bin/bash
# Written by Kai Wang, Mar 2019

cl=dep0-30  # catalog <30km or >200km
#group=.1
out=final_events_${cl}.lst

#cl=dep200-1000  # catalog <30km or >200km
#out=final_events_${cl}.lst
#group=.1
cat /dev/null >$out

i=1
IFS=$'\n'
#for line in `cat event_mag5.8_${cl}.lst$group`;do
for line in `cat event_mag5.8_${cl}.lst`;do
evlo=`echo $line |awk '{print $1}'`
evla=`echo $line |awk '{print $2}'`
evdp=`echo $line |awk '{print $3}'`
evnm=`echo $line |awk '{print $4}'`
evdir=`echo $evnm |awk -F_ '{printf"%04d_%02d_%02d_%02d_%02d_%02d",$1,$2,$3,$4,$5,$6}'`
echo "$i: evlo evla evdp evdir  $evlo $evla $evdp $evdir"

if [ -f evt_catalog_${cl}/processedSeismograms/seismo_Event_${evdir}.ps ];then
  gv -scale=0.6  evt_catalog_${cl}/processedSeismograms/seismo_Event_${evdir}.ps &
  echo "Save this event or Not? Yes(y)No(n)"
  read issave
  if [ $issave == "y" ];then
    echo evt_catalog_${cl}/processedSeismograms/Event_${evdir} $evlo $evla $evdp >>$out
  fi
fi

let i=i+1
if [ $i -gt 5 ];then
   killall gv
   i=1
fi
done
cp $out evt_catalog_${cl}
killall gv
