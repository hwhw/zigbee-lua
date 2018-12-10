return {
  srv_implementation = "lib.srv-epoll",

  zigbee_device_database = "device_database.json",

  devtype = "cc2530",
  zigbee_pan_id = 0x1a62,
  -- you can give an explicit ext pan id, otherwise the coordinator's IEEEaddr is used
  zigbee_ext_pan_id = "coordinator",
  zigbee_channel = 11,
  -- network key defaults to zigbee2mqtt/zigbee-shepherd key, better change this!
  zigbee_network_key = {1,3,5,7,9,11,13,15,0,2,4,6,8,10,12,13},
  port = "/dev/ttyACM0",
  baud = 115200,

  tcp_server_host = '127.0.0.1',
  tcp_server_port = 16580,

  systemd = false,

  debug = true,
  debugsel = ".*"
}
