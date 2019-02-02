#!/bin/bash
# set a name for a device in the device database
# The device is identified by its IEEEaddr, NWK address or its current name (if applicable)
echo 'local ctx,o=...; ctx:fire({"Zigbee","device_attibute"},{id='$1',key="name",value="'$2'"})' | nc -N ${ZIGBEELUA:-127.0.0.1} 16580
