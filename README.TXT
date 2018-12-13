Zigbee-lua

A Zigbee control framework written in Lua

Supposed to run via LuaJIT (uses ffi, bitop)

Supported Zigbee interfaces:
* CC253x via ZNP

Features:
* start up a Zigbee coordinator
* maintain a simple device database
* TCP interface for injecting code into the running instance
* ZCL abstraction to build/parse data packages

Device related notes:
* CC253x: testing is done using the CC253x firmware from zigbee2mqtt project

Status: It's operational. You can use this to run a Zigbee coordinator and
control its communication. Via the TCP interface, you can control its behaviour
and e.g. send adhoc custom packages.
