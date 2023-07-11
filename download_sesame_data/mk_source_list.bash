#!/bin/bash
all_sources=event_mag5.8_dep0-30.lst
ntot=`cat $all_sources |wc -l`
ntot1=`echo $ntot |awk '{print $1-1}'`
nlen=20
npart=6
i=1
for i in `seq $npart`;do
   ib=`echo $i |awk '{print ($1-1)*a+1}' a=$nlen`
   ie=`echo $i |awk '{print $1*a}' a=$nlen`
   if [ $ie -gt $ntot ];then
      ie=$ntot
   fi
   echo $i $ib $ie
   cat $all_sources |sed -n "$ib,${ie}p" >$all_sources.$i
done

