#!/bin/bash
# allow new devices to join to coordinator and routers
echo 'local ctx,o=...; ctx:fire({"Zigbee","permit_join"},{include={0}})' | nc -N ${ZIGBEELUA:-127.0.0.1} 16580
