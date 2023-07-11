#!/bin/bash
# This script is to download specific events when there is a event list.
# Written by Kai Wang, Mar 2019

evtlst=events_zz.lst
#evtlst=events_tt.lst

mkdir -p Tele_ZZ_P_waveforms
#mkdir -p Tele_RR_P_waveforms
#mkdir -p Tele_TT_P_waveforms
#mkdir -p Tele_TT_S_waveforms
#mkdir -p evt_catalog_S_TO2013-2015

#for line in `cat $evtlst |sed -n '2,$p' `;do
cat $evtlst
for line in `cat $evtlst `;do
   echo $line
   year=`echo $line |awk '{printf"%04d\n",substr($1,1,4)}'`
   month=`echo $line |awk '{printf"%02d\n",substr($1,5,2)}'`
   day=`echo $line |awk '{printf"%02d\n",substr($1,7,2)}'`
   hr=`echo $line |awk '{printf"%02d\n",substr($1,9,2)}'`
   day1=`echo $line |awk '{printf"%02d\n",substr($1,7,2)+1}'`
   hr1=`echo $line |awk '{printf"%02d\n",substr($1,9,2)+1}'`
   echo $year $month $day $hr == $day1 $hr1
done
