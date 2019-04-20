Zigbee-lua

A Zigbee control framework written in Lua

Supposed to run via LuaJIT (uses ffi, bitop)

Supported Zigbee interfaces:
* CC253x via ZNP

Features:
* start up a Zigbee coordinator
* maintain a simple device database
* TCP interface for injecting code into the running instance
* MQTT client that allows for publishing/subscribing (still rough around
  the edges, see mqtt-environment.lua for a very basic example)
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


Usage:
------

The following description assumes that you want to use this software to build
a home automation infrastructure with Zigbee devices - which is what drove the
development of this software in the first place. But note that you can probably
use this software for other tasks, too.

1. Prepare software
  * check out the git submodules. You do not need luarocks or similar lua
    package management. Just do:
    - git submodule init
    - git submodule update
2. Prepare hardware
  * At the moment, the CC253x devices (CC2531 USB stick, CC2530 via UART) are
    the only supported hardware. Support for ETRX357 based devices (featuring
    the AT-command firmware support) is planned.
  * CC253x: flash with appropriate firmware. See firmware remarks for a very
    subjective view on what you should use.
3. optional: configure USB serial interface permissions
   This might be your chance to look and see what udev is and can do for you
4. edit/adapt config.lua
5. run main.lua via LuaJIT, optionally giving the name (without .lua suffix)
   of an "environment" as additional argument.

Then:

* peruse scripts in contrib/ to show list of known devices, permit network
  joins, name devices, ...
* create an "environment" by writing event handling functions that trigger
  actions. Have a look at the example environments in the project's root
  directory.


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

* Something to store/analyze sensor data (temperature & so on)
* Better abstracted Zigbee device classes (rather than the "any.lua" which
  does a bit of everything)
* Better examples
* Tests
