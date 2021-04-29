return {
  srv_implementation = "lib.srv-epoll",
  systemd = false,

  interfaces = {
    tcp_server = {
      {
        host = '127.0.0.1',
        port = 16580
      }
    },
    zigbee = {
      {
        device = {
          class = "dongle-cc253x",
          port = "/dev/ttyACM0",
          baud = 115200,
          pan_id = 0x1a62,
          -- you can give an explicit ext pan id, otherwise the coordinator's IEEEaddr is used
          ext_pan_id = "coordinator",
          channel = 11,
          -- network key defaults to zigbee2mqtt/zigbee-shepherd key, better change this!
          network_key = {1,3,5,7,9,11,13,15,0,2,4,6,8,10,12,13},
          -- comment this out to allow zigbee-lua to actually configure the device
          -- this is a safety net to prevent you from factory-resetting your device
          -- by accident:
          never_reset = true
          -- switch this to true to set new values:
          --force_reset = true
        },
--[[ example for ETRX3 dongle:
        device = {
          class = "dongle-etrx3",
          port = "/dev/ttyUSB0",
          baud = 19200,
          -- you can set this to true to factory reset the dongle:
          factory_reset = false,
          ----------------------
          -- the following settings will only be applied if no network
          -- is yet configured in the dongle:
          pan_id = 0x1a65, -- warning: the module will check if a PAN with
                           -- this ID exists and will generate a random PAN ID if that is the case
          -- you can give an explicit ext pan id, otherwise the coordinator's IEEEaddr is used
          ext_pan_id = "coordinator",
          channel = 15,
          -- network key defaults to zigbee2mqtt/zigbee-shepherd key, better change this!
          network_key = {1,3,5,7,9,11,13,15,0,2,4,6,8,10,12,13}
        },
--]]
        device_database = "device_database.json",

        -- set this (to a number value indicating the interval in seconds)) to send many-to-one
        -- route requests to make devices (i.e. routers) aware how to send data to the central
        -- coordinator (implemented only on cc253x for now):
        send_many_to_one_route_requests = 15
      }
    }
  },

  log = {
    DBG = {
      true,
      ctx = {
        event=false
      }
    }
  }
}
