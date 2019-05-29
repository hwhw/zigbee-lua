#!/bin/bash
# delete a device from database
# The device is identified by its IEEEaddr, NWK address or its current name (if applicable)
echo 'local ctx,o=...; ctx.interfaces.zigbee[1].devices:delete('$1')' | nc -N ${ZIGBEELUA:-127.0.0.1} 16580
