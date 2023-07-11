#!/bin/bash
# Written by Kai Wang, Mar 2019

### for Teleseismic FWI by hybrid methods (Pick good waveform of P at both R and Z components)
#  Mag >5.8
#  Dep < 30 km or > 200 km
#  Dist >30 deg < 90 deg

#find_events -d36/-120/30/90 -b 2013-12-13 -e 2015-10-12 -m 5.8  -D200-10000 -r |
#find_stations -R-122/-118/35/37 -n TO -r |
#find_seismograms -B -2ttp -E 3ttp -c HH* -r >recipes/Cecal/waveform_d200+.xml 
#
#find_events -d36/-120/30/90 -b 2013-12-13 -e 2015-10-12 -m 5.8  -D0-30 -r |
#find_stations -R-122/-118/35/37 -n TO -r |
#find_seismograms -B -2ttp -E 3ttp -c HH* -r >recipes/Cecal/waveform_d0-30.xml 

### for Teleseismic travetime inversion by hybrid methods (pick direct P at Z comp and direct S at T comp)
#   Mag >5.5
#   Dist >30 deg

#===================================================================#
#                     MCR_WEST                                      #
#                 BinHe,2021-04-02                                  #
#===================================================================#
#depth 200-1000km
#find_events -d45/-93/30/90 -b 2011-05-01 -e 2013-11-01 -m 5.8  -D200-1000 >event_mag5.8_dep200-1000.lst

recipe=recipes/waveform_d200-1000.xml

#recipe=recipes/waveform_d0-30.xml
#find_events -d32/-83/30/90 -b 2011-04-01 -e 2014-07-01 -m 5.8  -D0-30 -r | find_stations -R-85/-81/28.5/36 -n Z9 -r >$recipe
sed -i '$ d' $recipe
sed -i '$ d' $recipe
cat >> $recipe <<!
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
            <workingDir>processedSeismograms1</workingDir>
        </sacWriter>
        <legacyExecute>
            <command>echo Sod saved this file</command>
        </legacyExecute>

    </waveformVectorArm>
</sod>
!
 rm -rf Sod*
sod -f $recipe

