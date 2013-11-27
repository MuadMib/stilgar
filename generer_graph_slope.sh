#!/bin/sh

rrdtool create database_t.rrd --start 1369670000 -s 3600 DS:var1:GAUGE:3600:0:100 RRA:LAST:0:1:18000
cat database_t.txt | xargs rrdupdate database_t.rrd


rrdtool graph database_t.png --width 800 --height 600 -s $(date +%s -d '6 month ago') -e $(date +%s -d '3 month') DEF:var1=database_t.rrd:var1:LAST LINE1:var1#00FF00 VDEF:D2=var1,LSLSLOPE VDEF:H2=var1,LSLINT CDEF:predict=var1,POP,D2,COUNT,*,H2,+ LINE2:predict#FF00FF
cp database_t.png /var/www/

#rrdtool graph database_t.png --width 800 --height 600 -s 1369670000 -e $(date +%s -d '3 month') \
#DEF:var1=database_t.rrd:var1:MAX \
#LINE1:var1#00FF00 \
#VDEF:D2=var1,LSLSLOPE \
#VDEF:H2=var1,LSLINT \
#CDEF:predict=var1,POP,D2,COUNT,*,H2,+ \
#LINE2:predict#FF00FF

#DEF:fail1=minutes.rrd:Exemple:FAILURES \
#TICK:fail1#0000FF:1.0:"Failures " \
#DEF:var1=minutes.rrd:Exemple:MAX \
#AREA:var1#00FF00:"Response Times " \
#LINE1:var1#000000:"" \
#DEF:pred1=minutes.rrd:Exemple:HWPREDICT \
#DEF:dev1=minutes.rrd:Exemple:DEVPREDICT \
#CDEF:upper1=pred1,dev1,2,*,+ \
#CDEF:lower1=pred1,dev1,2,*,- \
#LINE2:upper1#ff00ff:"Upper Confidence Bound Average time to respond " \
#LINE2:lower1#ff0000:"Lower Confidence Bound Average time to respond "

