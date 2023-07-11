#!/bin/bash
# This script is to download specific events when there is a event list.
# Written by Kai Wang, Mar 2019

evtlst=event_selected.lst

mkdir -p Tele_ZZ_P_waveforms

for line in `cat $evtlst `;do
   echo $line
   year=`echo $line |awk '{printf"%04d\n",substr($1,1,4)}'`
   month=`echo $line |awk '{printf"%02d\n",substr($1,5,2)}'`
   day=`echo $line |awk '{printf"%02d\n",substr($1,7,2)}'`
   hr=`echo $line |awk '{printf"%02d\n",substr($1,9,2)}'`
   day1=`echo $line |awk '{printf"%02d\n",substr($1,7,2)+1}'`
   hr1=`echo $line |awk '{printf"%02d\n",substr($1,9,2)+1}'`
   echo $year $month $day $hr == $day1 $hr1
exit 0
if true;then
   cd Tele_ZZ_P_waveforms 
   find_events -d32/-83/30/90 -b ${year}-${month}-${day} -e ${year}-${month}-${day} -m 5.0  -D0-100 -r |
   find_stations -R-85/-81/28.5/36 -n Z9,TA -r > recipe_${year}${month}${day}${hr}.xml 
   sed -i '$ d' recipe_${year}${month}${day}${hr}.xml
   sed -i '$ d' recipe_${year}${month}${day}${hr}.xml
   cat >>recipe_${year}${month}${day}${hr}.xml <<!
    <waveformVectorArm>
        <phaseRequest>
            <beginPhase>ttp</beginPhase>
            <beginOffset>
                <unit>MINUTE</unit>
                <value>-2</value>
            </beginOffset>
            <endPhase>ttp</endPhase>
            <endOffset>
                <unit>MINUTE</unit>
                <value>3</value>
            </endOffset>
        </phaseRequest>
        <fullCoverage/>
        <printlineSeismogramProcess/>
        <sacWriter/>
        <responseGain/>
        <rMean/>
        <rTrend/>
        <integrate/>
                <sampleSyncronize/>
                <vectorTrim/>
                <rotateGCP/>
        <sacWriter>
            <workingDir>processedSeismograms</workingDir>
        </sacWriter>
        <legacyExecute>
            <command>echo Sod saved this file</command>
        </legacyExecute>

    </waveformVectorArm>
</sod>
!
sod -f recipe_${year}${month}${day}${hr}.xml
rm -rf SodDb
rm Sod*
fi
#########################################################################
#   cd evt_catalog_S_TO2013-2015
#   find_events -d36/-120/30/180 -b ${year}-${month}-${day}-${hr} -e ${year}-${month}-${day}-${hr1} -m 5.5  -D0-1000 -r |
#   find_stations -R-122.2/-117.5/35.0/37.25 -n TO,BK,CE,CI,NP -r >recipe_${year}${month}${day}${hr}.xml
#   gsed -i '$ d' recipe_${year}${month}${day}${hr}.xml
#   gsed -i '$ d' recipe_${year}${month}${day}${hr}.xml
#   cat >>recipe_${year}${month}${day}${hr}.xml <<!
#    <waveformVectorArm>
#        <phaseRequest>
#            <beginPhase>tts</beginPhase>
#            <beginOffset>
#                <unit>MINUTE</unit>
#                <value>-2</value>
#            </beginOffset>
#            <endPhase>tts</endPhase>
#            <endOffset>
#                <unit>MINUTE</unit>
#                <value>3</value>
#            </endOffset>
#        </phaseRequest>
#	<bestChannelAtStation/>
#        <fullCoverage/>
#        <printlineSeismogramProcess/>
#        <sacWriter/>
#        <responseGain/>
#        <rMean/>
#        <rTrend/>
#        <integrate/>
#                <sampleSyncronize/>
#                <vectorTrim/>
#                <rotateGCP/>
#        <sacWriter>
#            <workingDir>processedSeismograms</workingDir>
#        </sacWriter>
#        <legacyExecute>
#            <command>echo Sod saved this file</command>
#        </legacyExecute>
#
#    </waveformVectorArm>
#</sod>
#!
#sod -f recipe_${year}${month}${day}${hr}.xml
#rm -rf SodDb
#rm Sod*
########################################################################
   cd .. 
done


