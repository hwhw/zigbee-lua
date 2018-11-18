return {
  srv_implementation = "lib.srv-epoll",
  device_database = "device_database.json",
  devtype = "cc2530",
  --port = "/dev/tnt0",
  port = "/dev/ttyACM0",
  baud = 115200,
  systemd = false,
  debug = true,
  debugsel = ".*"
}
