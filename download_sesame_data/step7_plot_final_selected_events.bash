#!/bin/bash
# Written by Kai Wang, Mar 2019
export SAC_DISPLAY_COPYRIGHT=0

gmt begin final_events_P jpg
fevets=final_events_P.lst
lonmin=-97
lonmax=-89
latmin=42
latmax=48


gmt coast -JH180/12c -Rg -Bg -A1000 -W1/1p

gmt end show
