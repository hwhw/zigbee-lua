Zigbee-lua

An early stage of a Zigbee control framework.

Supposed to run via LuaJIT (uses ffi, bitop)

Supported Zigbee interfaces:
* CC253x (so far, only CC2531 is being used for testing) via ZNP

Features:
* start up a Zigbee coordinator
* maintain a simple device database
* TCP interface for injecting code into the running instance

Device related notes:
* CC253x: testing is done using the CC253x firmware from zigbee2mqtt project
