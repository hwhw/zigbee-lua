#!/bin/bash
# set a name for a device in the device database
# The device is identified by its IEEEaddr, NWK address or its current name (if applicable)
echo 'local ctx,o=...; ctx.interfaces.zigbee[1].devices:find('$1'):set({name="'$2'"})' | nc -N ${ZIGBEELUA:-127.0.0.1} 16580
