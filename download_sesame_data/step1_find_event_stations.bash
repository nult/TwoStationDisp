#!/bin/bash
# Written by Kai Wang, Mar 2019

### Step1: find events ###
#find_events -d45/-93/30/90 -b 2011-05-01 -e 2013-11-01 -m 5.8  -D0-30 >event_mag5.8_dep0-30.lst1
#find_events -d45/-93/30/90 -b 2011-05-01 -e 2013-11-01 -m 5.8  -D180-1000 >event_mag5.8_dep180-1000.lst1
#find_events -d47.08/-92.08/30/90 -b 2011-05-01 -e 2013-11-01 -m 5.8  -D0-30 >event_mag5.8_dep0-30.lst2
#find_events -d47.08/-92.08/30/90 -b 2011-05-01 -e 2013-11-01 -m 5.8  -D180-1000 >event_mag5.8_dep180-1000.lst2
#find_events -d44.02/-93.14/30/90 -b 2011-05-01 -e 2013-11-01 -m 5.8  -D0-30 >event_mag5.8_dep0-30.lst3
#find_events -d44.02/-93.14/30/90 -b 2011-05-01 -e 2013-11-01 -m 5.8  -D180-1000 >event_mag5.8_dep180-1000.lst3
#sort -u event_mag5.8_dep0-30.lst1 event_mag5.8_dep0-30.lst2 > event_mag5.8_dep0-30.lst.tmp
#sort -u event_mag5.8_dep0-30.lst3 event_mag5.8_dep0-30.lst.tmp > event_mag5.8_dep0-30.lst.0
#\rm event_mag5.8_dep0-30.lst.tmp
find_events -d32/-83/30/90 -b 2011-04-01 -e 2014-07-01 -m 5.5-6.8  -D0-100 >event_mag5.0_dep0-100.lst

### Step2: find stations ###
find_stations -R-85/-81/28.5/36 -n Z9,TA >station_sesame.lst
### Step3: download CMTSOLUTION ###
# go to https://www.globalcmt.org/CMTsearch.html
