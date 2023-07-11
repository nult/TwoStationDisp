#!/bin/bash
# Written by Kai Wang, Mar 2019
export SAC_DISPLAY_COPYRIGHT=0

cd evt_catalog_dep0-30/processedSeismograms
#cd evt_catalog_dep200-1000/processedSeismograms
for evtdir in `ls -d Event_*`;do
  out=seismo_${evtdir}.ps
  icomp=1
  for comp in BHZ BHR BHT;do
    echo $icomp $comp
    sac <<eof
r $evtdir/*.$comp.sac
bp n 4 p 2 c 0.02 0.2
w append .lp
quit
eof
    saclst b e dist f $evtdir/*.$comp.sac.lp |awk '{print $2,$3,$4}'>dist.dat 
    t_min=`cat dist.dat |gmt minmax -C |awk '{print $1}'`
    t_max=`cat dist.dat |gmt minmax -C |awk '{print $4}'`
    #t_min=`cat dist.dat |gmtinfo -C |awk '{print $1}'`
    #t_max=`cat dist.dat |gmtinfo -C |awk '{print $4}'`
    d_min=-1
    d_max=`cat dist.dat |wc -l|awk '{print ($1+1)}'`
    tx=`echo $t_min $t_max |awk '{print ($1+$2)/2}'`
    ty=`echo $d_min $d_max |awk '{print $2+($2-$1)*0.04}'`
    echo $tx,$ty,$t_min,$t_max,$d_min,$d_max
    if [ $icomp -eq 1 ];then
       gmt psbasemap -JX12/8 -R$t_min/$t_max/$d_min/$d_max -Ba50:"Time (s)":/a1:"Distance (km)":wesn -K -P -X4 -Y20 >$out
    gmt pstext -J -R -N -O -K >>$out <<eof
$tx $ty 16 0 0 CB $evtdir
eof
    elif [ $icomp -eq 2 ];then
       gmt psbasemap -JX12/8 -R$t_min/$t_max/$d_min/$d_max -Ba50:"Time (s)":/a1:"Distance (km)":wesn -K -O -Y-8 >>$out
    else
       gmt psbasemap -JX12/8 -R$t_min/$t_max/$d_min/$d_max -Ba50:"Time (s)":/a1:"Distance (km)":weSn -K -O -Y-8 >>$out
    fi
    gmt pssac $evtdir/*.$comp.sac.lp -J -R -Entb -M1. -W0.5p -K -O >>$out 
    cat dist.dat |awk '{printf"%f %f 12 0 0 CM %s\n",$t_min-16,NR-1,$3}' |gmt pstext -J -R  -W255/0/0 -N -K -O >>$out 
    rm $evtdir/*.$comp.sac.lp
    let icomp=icomp+1
  done
  cat /dev/null |gmt psxy -J -R -O >>$out
done
cd ../..
