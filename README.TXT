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


Description of software structure:
----------------------------------

* Core (in lib/):
  * ctx.lua is a general application context. It is supposed to be the
    single instance of its kind. It implements:
    * coroutine based tasks integrated with
    * messaging between these tasks
  * util.lua is a collection of small utility functions, e.g. logging, table
    copies and more
  * srv-epoll.lua is a epoll-based (and thus: Linux specific) wrapper around
    socket management. This would have to be reimplemented on other platforms.
    It also implements a main loop.
  * serial.lua is a ljsyscall based wrapper for serial/UART communication
  * codec.lua is a generic binary protocol codec, configured by simple Lua
    data structures.

* Interfaces (in interfaces/):
  * These will get loaded depending on configuration (in config.lua)
  * Noteworthy interface is the "zigbee" interface. There is a try to separate
    the protocol stuff (interfaces/zigbee.lua, interfaces/zigbee/zcl.lua)
    from device-/cluster-specific code
  * The CC253x ZNP interface is in interfaces/zigbee/devices/dongle-cc253x.lua,
    the ZNP protocol definition (using codec.lua) can be found in
    interfaces/zigbee/cc-znp.lua


Similar projects:
-----------------

When I started this whole smarthome project of mine, I had a loooong look at
https://github.com/Koenkk/zigbee2mqtt - and I used it for a short amount of
time. It is good for what it does. I have to admit though, that I have a
certain dislike for Javascript in general and the nodejs ecosystem in
particular. Zigbee2mqtt pulled LOTS of other packages and there is no way
to get me motivated enough to go and see what they all do. Yes, there is
some amount of "not invented here" syndrome, too. Zigbee2mqtt mostly stands on
the shoulders of https://github.com/zigbeer/zigbee-shepherd.

I was not really content with the behaviour of these applications. A lot of
development seems to be on the "hacky" side, which is generally fine. However,
these levels of hacks are accumulating...

Also, I found some really nicely written software:

https://github.com/Frans-Willem/AqaraHub/ is really nicely abstracted, very
concise modern C++. ZNP and ZCL are cleanly abstracted. Its abstractions use
futures, which makes for easily read state machines - a value in its own
accord for a state machine heavy task. This software, like Zigbee2mqtt,
focuses on providing an MQTT interface for controlling the Zigbee devices.

https://github.com/Tropicao/zigbridge/ is also really nicely abstracted.
It is written in a very nicely styled C, from the enlightenment.org school
of programming. It does NOT provide an MQTT interface and has some rudimentary
implementation of other interfaces.

Making up my mind, I came to the point where I wanted to have my own
implementation. Central design points were:

* not focused on MQTT only (or even at all?)
* must allow to script the "home automation" logic
* must allow for access to as many Zigbee (ZDP/ZCL) features as possible
* must not try to be too clever

While Languages like C++ and C have their appeal (and I spent a few days
thinking about continuing development by reusing corresponding projects),
I am quite proficient with Lua and Lua/C interop using (LuaJIT) FFI. So
I settled on this. Result is a very compact (in terms of lines of code)
core that allows quite some flexibility.


Road map:
---------

* MQTT interface (as soon as I feel I need it)
* Something to store/analyze sensor data (temperature & so on)
* Better abstracted Zigbee device classes (rather than the "any.lua" which
  does a bit of everything)
* Better examples
* Tests
