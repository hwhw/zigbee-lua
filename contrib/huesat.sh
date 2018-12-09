#!/bin/sh
echo 'local ctx=...; ctx.zigbee:hue_sat("'$1'",'$2','$3')'|nc -w 0 localhost 16580
