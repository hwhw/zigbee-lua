#!/bin/bash
# set a route for a device in the device database
# The device is identified by its IEEEaddr, NWK address or its current name (if applicable)
# same goes for the route, must be given as a table
echo 'local ctx,o=...; ctx.interfaces.zigbee[1].devices:find('$1'):set({source_route='$2'})' | nc -N ${ZIGBEELUA:-127.0.0.1} 16580
