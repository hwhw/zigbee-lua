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
          network_key = {1,3,5,7,9,11,13,15,0,2,4,6,8,10,12,13}
        },
        device_database = "device_database.json"
      }
    }
  },

  debug = true,
  debugsel = ".*"
}
