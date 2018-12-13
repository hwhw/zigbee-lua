#!/bin/bash
# allow new devices to join to routers (but not coordinator directly)
echo 'local ctx,o=...; ctx:fire({"Zigbee","permit_join"},{include={0xfffc},exclude={0}})' | nc -N ${ZIGBEELUA:-127.0.0.1} 16580
