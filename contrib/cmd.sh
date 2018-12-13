#!/bin/bash
echo 'require"interfaces.zigbee.any":new{id="'$1'"}:'$2 | nc -N ${ZIGBEELUA:-127.0.0.1} 16580
