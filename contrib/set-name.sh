#!/bin/bash
# allow new devices to join to routers (but not coordinator directly)
echo 'local ctx,o=...; ctx:fire({"Zigbee","device_attibute"},{id='$1',key="name",value="'$2'"})' | nc -N ${ZIGBEELUA:-127.0.0.1} 16580
