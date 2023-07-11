#!/bin/bash

cat station_sesame.txt | while read -r c1 c2 c3 c4; do
  cp RESP.7A.LADY..BHZ RESP.Z9.${c1}..BHZ
done
