return function()

-- MT_AF:

msg{"SREQ_AF_REGISTER",
  U8  {"Cmd0", const=0x24},
  U8  {"Cmd1", const=0x00},
  U8  {"EndPoint"},
  U16 {"AppProfId"},
  U16 {"AppDeviceId"},
  U8  {"AddDevVer"},
  map {"LatencyReq", type=t_U8, values={"NoLatency", "FastBeacons", "SlowBeacons"}},
  arr {"AppInClusterList", type=t_U16, counter=t_U8},
  arr {"AppOutClusterList", type=t_U16, counter=t_U8}
}
msg{"SRSP_AF_REGISTER",
  U8  {"Cmd0", const=0x64},
  U8  {"Cmd1", const=0x00},
  U8  {"Status"}
}

msg{"SREQ_AF_DATA_REQUEST",
  U8  {"Cmd0", const=0x24},
  U8  {"Cmd1", const=0x01},
  U16 {"DstAddr"},
  U8  {"DstEndpoint"},
  U8  {"SrcEndpoint"},
  U16 {"ClusterId"},
  U8  {"TransId"},
  map {"Options", type=t_U8, values={
    {"WildcardProfileID", B"00000010"},
    {"APSACK",            B"00010000"},
    {"DiscoverRoute",     B"00100000"},
    {"APSSecurity",       B"01000000"},
    {"SkipRouting",       B"10000000"}}},
  U8  {"Radius"},
  arr {"Data", type=t_U8, counter=t_U8}
}
msg{"SRSP_AF_DATA_REQUEST",
  U8  {"Cmd0", const=0x64},
  U8  {"Cmd1", const=0x01},
  U8  {"Status"}
}

msg{"SREQ_AF_DATA_REQUEST_EXT",
  U8  {"Cmd0", const=0x24},
  U8  {"Cmd1", const=0x02},
  map {"DstAddrMode", type=t_U8, values={
    {"AddrNotPresent", 0, 0xFF},
    {"AddrGroup", 1, 0xFF},
    {"Addr16Bit", 2, 0xFF},
    {"Addr64Bit", 3, 0xFF},
    {"AddrBroadcast", 15, 0xFF}}},
  arr {"DstAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U8  {"DstEndpoint"},
  U16 {"DstPanId", default=0},
  U8  {"SrcEndpoint"},
  U16 {"ClusterId"},
  U8  {"TransId"},
  map {"Options", type=t_U8, values={
    {"WildcardProfileID", B"00000010"},
    {"APSACK",            B"00010000"},
    {"DiscoverRoute",     B"00100000"},
    {"APSSecurity",       B"01000000"},
    {"SkipRouting",       B"10000000"}}},
  U8  {"Radius"},
  arr {"Data", type=t_U8, counter=t_U16}
}
msg{"SRSP_AF_DATA_REQUEST_EXT",
  U8  {"Cmd0", const=0x64},
  U8  {"Cmd1", const=0x02},
  U8  {"Status"}
}

msg{"SREQ_AF_DATA_REQUEST_SRC_RTG",
  U8  {"Cmd0", const=0x24},
  U8  {"Cmd1", const=0x03},
  U16 {"DstAddr"},
  U8  {"DstEndpoint"},
  U8  {"SrcEndpoint"},
  U16 {"ClusterId"},
  U8  {"TransId"},
  map {"Options", type=t_U8, values={
    {"WildcardProfileID", B"00000010"},
    {"APSACK",            B"00010000"},
    {"DiscoverRoute",     B"00100000"},
    {"APSSecurity",       B"01000000"},
    {"SkipRouting",       B"10000000"}}},
  U8  {"Radius"},
  arr {"RelayList", type=t_U16, counter=t_U8},
  arr {"Data", type=t_U8, counter=t_U8}
}
msg{"SRSP_AF_DATA_REQUEST_SRC_RTG",
  U8  {"Cmd0", const=0x64},
  U8  {"Cmd1", const=0x03},
  U8  {"Status"}
}

msg{"SREQ_AF_INTER_PAN_CTL_InterPanClr",
  U8  {"Cmd0", const=0x24},
  U8  {"Cmd1", const=0x10},
  U8  {"InterPanClr", const=0}
}
msg{"SREQ_AF_INTER_PAN_CTL_InterPanSet",
  U8  {"Cmd0", const=0x24},
  U8  {"Cmd1", const=0x10},
  U8  {"InterPanSet", const=1},
  U8  {"Channel"}
}
msg{"SREQ_AF_INTER_PAN_CTL_InterPanReg",
  U8  {"Cmd0", const=0x24},
  U8  {"Cmd1", const=0x10},
  U8  {"InterPanReg", const=2},
  U8  {"Endpoint"}
}
msg{"SREQ_AF_INTER_PAN_CTL_InterPanChk",
  U8  {"Cmd0", const=0x24},
  U8  {"Cmd1", const=0x10},
  U8  {"InterPanClr", const=3},
  U16 {"PanId"},
  U8  {"Endpoint"}
}
msg{"SRSP_AF_INTER_PAN_CTL",
  U8  {"Cmd0", const=0x64},
  U8  {"Cmd1", const=0x10},
  U8  {"Status"}
}

msg{"SREQ_AF_DATA_STORE",
  U8  {"Cmd0", const=0x24},
  U8  {"Cmd1", const=0x11},
  U16 {"Index"},
  arr {"Data", type=t_U8, counter=t_U8}
}
msg{"SRSP_AF_DATA_STORE",
  U8  {"Cmd0", const=0x64},
  U8  {"Cmd1", const=0x11},
  U8  {"Status"}
}

msg{"SREQ_AF_DATA_RETRIEVE",
  U8  {"Cmd0", const=0x24},
  U8  {"Cmd1", const=0x12},
  U32 {"Timestamp"},
  U16 {"Index"},
  U8  {"Length"}
}
msg{"SRSP_AF_DATA_RETRIEVE",
  U8  {"Cmd0", const=0x64},
  U8  {"Cmd1", const=0x12},
  U8  {"Status"},
  arr {"Data", type=t_U8, counter=t_U8}
}

msg{"SREQ_AF_APSF_CONFIG_SET",
  U8  {"Cmd0", const=0x24},
  U8  {"Cmd1", const=0x13},
  U8  {"Endpoint"},
  U8  {"FrameDelay"},
  U8  {"WindowSize"}
}
msg{"SRSP_AF_DATA_STORE",
  U8  {"Cmd0", const=0x64},
  U8  {"Cmd1", const=0x13},
  U8  {"Status"}
}

msg{"AREQ_AF_DATA_CONFIRM",
  U8  {"Cmd0", const=0x44},
  U8  {"Cmd1", const=0x80},
  U8  {"Status"},
  U8  {"Endpoint"},
  U8  {"TransId"}
}
msg{"AREQ_AF_REFLECT_ERROR",
  U8  {"Cmd0", const=0x44},
  U8  {"Cmd1", const=0x83},
  U8  {"Status"},
  U8  {"Endpoint"},
  U8  {"TransId"},
  U8  {"DstAddrMode"},
  U16 {"DstAddr"}
}
msg{"AREQ_AF_INCOMING_MSG",
  U8  {"Cmd0", const=0x44},
  U8  {"Cmd1", const=0x81},
  U16 {"GroupId"},
  U16 {"ClusterId"},
  U16 {"SrcAddr"},
  U8  {"SrcEndpoint"},
  U8  {"DstEndpoint"},
  U8  {"WasBroadcast"},
  U8  {"LinkQuality"},
  U8  {"SecurityUse"},
  U32 {"Timestamp"},
  U8  {"TransSeqNumber"},
  arr {"Data", type=t_U8, counter=t_U8}
}
msg{"AREQ_AF_INCOMING_MSG_EXT",
  U8  {"Cmd0", const=0x44},
  U8  {"Cmd1", const=0x82},
  U16 {"GroupId"},
  U16 {"ClusterId"},
  map {"SrcAddrMode", type=t_U8, values={
    {"AddrNotPresent", 0, 0xFF},
    {"AddrGroup", 1, 0xFF},
    {"Addr16Bit", 2, 0xFF},
    {"Addr64Bit", 3, 0xFF},
    {"AddrBroadcast", 15, 0xFF}}},
  arr {"SrcAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U8  {"SrcEndpoint"},
  U16 {"SrcPanId"},
  U8  {"DstEndpoint"},
  U8  {"WasBroadcast"},
  U8  {"LinkQuality"},
  U8  {"SecurityUse"},
  U32 {"Timestamp"},
  U8  {"TransSeqNumber"},
  arr {"Data", type=t_U8, counter=t_U16}
}


-- MT_APP:

msg{"SREQ_APP_MSG",
  U8  {"Cmd0", const=0x29},
  U8  {"Cmd1", const=0x00},
  U8  {"AppEndpoint"},
  U16 {"DestAddress"},
  U8  {"DestEndpoint"},
  U16 {"ClusterId"},
  arr {"Message", type=t_U8, counter=t_U8}
}
msg{"SRSP_APP_MSG",
  U8  {"Cmd0", const=0x69},
  U8  {"Cmd1", const=0x00},
  U8  {"Status"}
}

msg{"SREQ_APP_USER_TEST",
  U8  {"Cmd0", const=0x29},
  U8  {"Cmd1", const=0x01},
  U8  {"SrcEP"},
  U16 {"CommandId"},
  U16 {"Parameter1", default=0},
  U16 {"Parameter2", default=0}
}
msg{"SRSP_APP_USER_TEST",
  U8  {"Cmd0", const=0x69},
  U8  {"Cmd1", const=0x01},
  U8  {"Status"}
}

-- MT_DEBUG:

msg{"SREQ_DEBUG_SET_THRESHOLD",
  U8  {"Cmd0", const=0x28},
  U8  {"Cmd1", const=0x00},
  U8  {"ComponentId"},
  U8  {"Threshold"}
}
msg{"SRSP_DEBUG_SET_THRESHOLD",
  U8  {"Cmd0", const=0x68},
  U8  {"Cmd1", const=0x00},
  U8  {"Status"}
}

msg{"AREQ_DEBUG_MSG",
  U8  {"Cmd0", const=0x48},
  U8  {"Cmd1", const=0x00},
  arr {"Message", type=t_U8, counter=t_U8, asstring=true}
}
  
-- MT_MAC:

msg{"SREQ_MAC_RESET_REQ",
  U8  {"Cmd0", const=0x22},
  U8  {"Cmd1", const=0x01},
  U8  {"SetDefault", default=0},
}
msg{"SRSP_MAC_RESET_REQ",
  U8  {"Cmd0", const=0x62},
  U8  {"Cmd1", const=0x01},
  U8  {"Status"}
}

msg{"SREQ_MAC_INIT",
  U8  {"Cmd0", const=0x22},
  U8  {"Cmd1", const=0x02},
}
msg{"SRSP_MAC_INIT",
  U8  {"Cmd0", const=0x62},
  U8  {"Cmd1", const=0x02},
  U8  {"Status"}
}

-- to be continued...


-- MT_SAPI:

msg{"AREQ_ZB_SYSTEM_RESET",
  U8  {"Cmd0", const=0x46},
  U8  {"Cmd1", const=0x09}
}

msg{"SREQ_ZB_START_REQUEST",
  U8  {"Cmd0", const=0x26},
  U8  {"Cmd1", const=0x00}
}
msg{"SRSP_ZB_START_REQUEST",
  U8  {"Cmd0", const=0x66},
  U8  {"Cmd1", const=0x00}
}

msg{"SREQ_ZB_PERMIT_JOINING_REQUEST",
  U8  {"Cmd0", const=0x26},
  U8  {"Cmd1", const=0x08},
  U16 {"Destination", default=0xFFFC},
  U8  {"Timeout", default=0}
}
msg{"SRSP_ZB_PERMIT_JOINING_REQUEST",
  U8  {"Cmd0", const=0x66},
  U8  {"Cmd1", const=0x08},
  U8  {"Status"}
}

msg{"SREQ_ZB_BIND_DEVICE",
  U8  {"Cmd0", const=0x26},
  U8  {"Cmd1", const=0x01},
  U8  {"Create", default=1},
  U16 {"CommandId"},
  arr {"Destination", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_ZB_BIND_DEVICE",
  U8  {"Cmd0", const=0x66},
  U8  {"Cmd1", const=0x01}
}

msg{"SREQ_ZB_ALLOW_BIND",
  U8  {"Cmd0", const=0x26},
  U8  {"Cmd1", const=0x02},
  U8  {"Timeout", default=0}
}
msg{"SRSP_ZB_ALLOW_BIND",
  U8  {"Cmd0", const=0x66},
  U8  {"Cmd1", const=0x02},
}

msg{"SREQ_ZB_SEND_DATA_REQUEST",
  U8  {"Cmd0", const=0x26},
  U8  {"Cmd1", const=0x03},
  U16 {"Destination"},
  U16 {"CommandId"},
  U8  {"Handle"},
  U8  {"Ack"},
  U8  {"Radius"},
  arr {"Data", type=t_U8, counter=t_U8}
}
msg{"SRSP_ZB_SEND_DATA_REQUEST",
  U8  {"Cmd0", const=0x66},
  U8  {"Cmd1", const=0x03},
}

msg{"SREQ_ZB_READ_CONFIGURATION",
  U8  {"Cmd0", const=0x26},
  U8  {"Cmd1", const=0x04},
  U8  {"ConfigId"}
}
msg{"SRSP_ZB_READ_CONFIGURATION",
  U8  {"Cmd0", const=0x66},
  U8  {"Cmd1", const=0x04},
  U8  {"Status"},
  U8  {"ConfigId"},
  arr {"Value", type=t_U8, counter=t_U8}
}

msg{"SREQ_ZB_WRITE_CONFIGURATION",
  U8  {"Cmd0", const=0x26},
  U8  {"Cmd1", const=0x05},
  U8  {"ConfigId"},
  arr {"Value", type=t_U8, counter=t_U8}
}
msg{"SRSP_ZB_WRITE_CONFIGURATION",
  U8  {"Cmd0", const=0x66},
  U8  {"Cmd1", const=0x05},
  U8  {"Status"}
}

msg{"SREQ_ZB_GET_DEVICE_INFO",
  U8  {"Cmd0", const=0x26},
  U8  {"Cmd1", const=0x06},
  U8  {"Param"}
}
msg{"SRSP_ZB_GET_DEVICE_INFO",
  U8  {"Cmd0", const=0x66},
  U8  {"Cmd1", const=0x06},
  U8  {"Param"},
  U16 {"Value"}
}

msg{"SREQ_ZB_FIND_DEVICE_REQUEST",
  U8  {"Cmd0", const=0x26},
  U8  {"Cmd1", const=0x07},
  arr {"SearchKey", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_ZB_FIND_DEVICE_REQUEST",
  U8  {"Cmd0", const=0x66},
  U8  {"Cmd1", const=0x07},
}

msg{"AREQ_ZB_START_CONFIRM",
  U8  {"Cmd0", const=0x46},
  U8  {"Cmd1", const=0x80},
  U8  {"Status"}
}
msg{"AREQ_ZB_BIND_CONFIRM",
  U8  {"Cmd0", const=0x46},
  U8  {"Cmd1", const=0x81},
  U16 {"CommandId"},
  U8  {"Status"}
}
msg{"AREQ_ZB_ALLOW_BIND_CONFIRM",
  U8  {"Cmd0", const=0x46},
  U8  {"Cmd1", const=0x82},
  U16 {"Source"}
}
msg{"AREQ_ZB_SEND_DATA_CONFIRM",
  U8  {"Cmd0", const=0x46},
  U8  {"Cmd1", const=0x83},
  U8  {"Handle"},
  U8  {"Status"}
}
msg{"AREQ_ZB_RECEIVE_DATA_INDICATION",
  U8  {"Cmd0", const=0x46},
  U8  {"Cmd1", const=0x87},
  U16 {"Source"},
  U16 {"Command"},
  arr {"Value", type=t_U8, counter=t_U16}
}
msg{"AREQ_ZB_FIND_DEVICE_CONFIRM",
  U8  {"Cmd0", const=0x46},
  U8  {"Cmd1", const=0x85},
  U8  {"SearchType"},
  U16 {"SearchKey"},
  arr {"Result", type=t_U8, length=8, reverse=true, ashex=true}
}

-- MT_SYS:

msg{"AREQ_SYS_RESET_REQ",
  U8  {"Cmd0", const=0x41},
  U8  {"Cmd1", const=0x00},
  U8  {"Type", default=1}
}

msg{"SREQ_SYS_PING",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x01}
}
msg{"SRSP_SYS_PING",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x01},
  map {"Capabilities", type=t_U16, values={
    {"MT_CAP_SYS",    0x0001, 0x0001},
    {"MT_CAP_MAC",    0x0002, 0x0002},
    {"MT_CAP_NWK",    0x0004, 0x0004},
    {"MT_CAP_AF",     0x0008, 0x0008},
    {"MT_CAP_ZDO",    0x0010, 0x0010},
    {"MT_CAP_SAPI",   0x0020, 0x0020},
    {"MT_CAP_UTIL",   0x0040, 0x0040},
    {"MT_CAP_DEBUG",  0x0080, 0x0080},
    {"MT_CAP_APP",    0x0100, 0x0100},
    {"MT_CAP_ZOAD",   0x1000, 0x1000}}}
}

msg{"SREQ_SYS_VERSION",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x02}
}
msg{"SRSP_SYS_VERSION",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x02},
  U8  {"TransportRev"},
  U8  {"Product"},
  U8  {"MajorRel"},
  U8  {"MinorRel"},
  U8  {"MaintRel"}
}

msg{"SREQ_SYS_SET_EXTADDR",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x03},
  arr {"ExtAddress", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_SYS_SET_EXTADDR",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x03},
  U8  {"Status"}
}

msg{"SREQ_SYS_GET_EXTADDR",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x04}
  -- manual talks of another U8 "Status" here, considering this to be an error for now
}
msg{"SRSP_SYS_GET_EXTADDR",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x04},
  arr {"ExtAddress", type=t_U8, length=8, reverse=true, ashex=true}
}

msg{"SREQ_SYS_RAM_READ",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x05},
  U16 {"Address"},
  U8  {"Len"}
}
msg{"SRSP_SYS_RAM_READ",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x05},
  U8  {"Status"},
  arr {"Value", type=t_U8, counter=t_U8}
}

msg{"SREQ_SYS_RAM_WRITE",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x06},
  U16 {"Address"},
  arr {"Value", type=t_U8, counter=t_U8}
}
msg{"SRSP_SYS_RAM_WRITE",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x06},
  U8  {"Status"}
}

msg{"SREQ_SYS_OSAL_NV_READ",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x08},
  U16 {"Id"},
  U8  {"Offset", default=0}
}
msg{"SRSP_SYS_OSAL_NV_READ",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x08},
  U8  {"Status"},
  arr {"Value", type=t_U8, counter=t_U8}
}

msg{"SREQ_SYS_OSAL_NV_WRITE",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x09},
  U16 {"Id"},
  U8  {"Offset", default=0},
  arr {"Value", type=t_U8, counter=t_U8}
}
msg{"SRSP_SYS_OSAL_NV_WRITE",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x09},
  U8  {"Status"}
}

msg{"SREQ_SYS_OSAL_NV_ITEM_INIT",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x07},
  U16 {"Id"},
  U16 {"ItemLen"},
  arr {"InitData", type=t_U8, counter=t_U8}
}
msg{"SRSP_SYS_OSAL_NV_ITEM_INIT",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x07},
  U8  {"Status"}
}

msg{"SREQ_SYS_OSAL_NV_DELETE",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x12},
  U16 {"Id"},
  U16 {"ItemLen"}
}
msg{"SRSP_SYS_OSAL_NV_DELETE",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x12},
  U8  {"Status"}
}

msg{"SREQ_SYS_OSAL_NV_LENGTH",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x13},
  U16 {"Id"}
}
msg{"SRSP_SYS_OSAL_NV_LENGTH",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x13},
  U16 {"Length"}
}

msg{"SREQ_SYS_OSAL_START_TIMER",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x0A},
  U8  {"Id"},
  U16 {"Timeout"}
}
msg{"SRSP_SYS_OSAL_START_TIMER",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x0A},
  U8  {"Status"}
}

msg{"SREQ_SYS_OSAL_STOP_TIMER",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x0B},
  U8  {"Id"}
}
msg{"SRSP_SYS_OSAL_STOP_TIMER",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x0B},
  U8  {"Status"}
}

msg{"SREQ_SYS_RANDOM",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x0C}
}
msg{"SRSP_SYS_RANDOM",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x0C},
  U16 {"Value"}
}

msg{"SREQ_SYS_ADC_READ",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x0D},
  U8  {"Channel"},
  U8  {"Resolution"}
}
msg{"SRSP_SYS_ADC_READ",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x0D},
  U16 {"Value"}
}

msg{"SREQ_SYS_GPIO",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x0E},
  map {"Operation", type=t_U8, values={"SetDirection", "SetInputMode", "Set", "Clear", "Toggle", "Read"}},
  U8  {"Value"}
}
msg{"SRSP_SYS_GPIO",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x0E},
  U8  {"Value"}
}

msg{"SREQ_SYS_STACK_TUNE",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x0F},
  map {"Operation", type=t_U8, values={"SetTransmitPower", "RxOnWhenIdle"}},
  U8  {"Value"}
}
msg{"SRSP_SYS_STACK_TUNE",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x0F},
  U8  {"Value"}
}

msg{"SREQ_SYS_SET_TIME",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x10},
  U32 {"UTCTime", default=0},
  U8  {"Hour", default=0},
  U8  {"Minute", default=0},
  U8  {"Second", default=0},
  U8  {"Month", default=1},
  U8  {"Day", default=1},
  U16 {"Year", default=2019}
}
msg{"SRSP_SYS_SET_TIME",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x10},
  U8  {"Status"}
}

msg{"SREQ_SYS_GET_TIME",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x11}
}
msg{"SRSP_SYS_GET_TIME",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x11},
  U32 {"UTCTime"},
  U8  {"Hour"},
  U8  {"Minute"},
  U8  {"Second"},
  U8  {"Month"},
  U8  {"Day"},
  U16 {"Year"}
}

msg{"SREQ_SYS_SET_TX_POWER",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x14},
  U8  {"TXPower"}
}
msg{"SRSP_SYS_SET_TX_POWER",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x14},
  U8  {"TXPower"}
}

msg{"SREQ_SYS_ZDIAGS_INIT_STATS",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x17}
}
msg{"SRSP_SYS_ZDIAGS_INIT_STATS",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x17},
  U8  {"Status"}
}

msg{"SREQ_SYS_ZDIAGS_CLEAR_STATS",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x18},
  U8  {"ClearNV", default=0}
}
msg{"SRSP_SYS_ZDIAGS_CLEAR_STATS",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x18},
  U32 {"SysClock"}
}

msg{"SREQ_SYS_ZDIAGS_GET_STATS",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x19},
  U16 {"AttributeId"}
}
msg{"SRSP_SYS_ZDIAGS_GET_STATS",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x19},
  U32 {"AttributeValue"}
}

msg{"SREQ_SYS_ZDIAGS_RESTORE_STATS_NV",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x1A}
}
msg{"SRSP_SYS_ZDIAGS_RESTORE_STATS_NV",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x1A},
  U8  {"Status"}
}

msg{"SREQ_SYS_ZDIAGS_SAFE_STATS_TO_NV",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x1B}
}
msg{"SRSP_SYS_ZDIAGS_SAFE_STATS_TO_NV",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x1B},
  U32 {"SysClock"}
}

msg{"SREQ_SYS_NV_CREATE",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x30},
  U8  {"SysId"},
  U16 {"ItemId"},
  U16 {"SubId"},
  U32 {"Length"}
}
msg{"SRSP_SYS_NV_CREATE",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x30},
  U8  {"Status"}
}

msg{"SREQ_SYS_NV_DELETE",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x31},
  U8  {"SysId"},
  U16 {"ItemId"},
  U16 {"SubId"}
}
msg{"SRSP_SYS_NV_DELETE",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x31},
  U8  {"Status"}
}

msg{"SREQ_SYS_NV_LENGTH",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x32},
  U8  {"SysId"},
  U16 {"ItemId"},
  U16 {"SubId"}
}
msg{"SRSP_SYS_NV_LENGTH",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x32},
  U8  {"Length"}
}

msg{"SREQ_SYS_NV_READ",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x33},
  U8  {"SysId"},
  U16 {"ItemId"},
  U16 {"SubId"},
  U16 {"Offset", default=0},
  U8  {"Length"}
}
msg{"SRSP_SYS_NV_READ",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x33},
  U8  {"Status"},
  arr {"Value", type=t_U8, counter=t_U8}
}

msg{"SREQ_SYS_NV_WRITE",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x34},
  U8  {"SysId"},
  U16 {"ItemId"},
  U16 {"SubId"},
  U16 {"Offset", default=0},
  arr {"Value", type=t_U8, counter=t_U16}
}
msg{"SRSP_SYS_NV_WRITE",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x34},
  U8  {"Status"}
}

msg{"SREQ_SYS_NV_UPDATE",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x35},
  U8  {"SysId"},
  U16 {"ItemId"},
  U16 {"SubId"},
  arr {"Value", type=t_U8, counter=t_U8}
}
msg{"SRSP_SYS_NV_UPDATE",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x35},
  U8  {"Status"}
}

msg{"SREQ_SYS_NV_COMPACT",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x36},
  U16 {"Threshold", default=128}
}
msg{"SRSP_SYS_NV_COMPACT",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x36},
  U8  {"Status"}
}

msg{"SREQ_SYS_OSAL_NV_READ_EXT",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x08},
  U16 {"Id"},
  U16 {"Offset", default=0}
}
msg{"SRSP_SYS_OSAL_NV_READ_EXT",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x08},
  U8  {"Status"},
  arr {"Value", type=t_U8, counter=t_U8}
}

--[[ -- redundant with SYS_OSAL_NV_WRITE
msg{"SREQ_SYS_OSAL_NV_WRITE_EXT",
  U8  {"Cmd0", const=0x21},
  U8  {"Cmd1", const=0x09},
  U16 {"Id"},
  U16 {"Offset", default=0},
  arr {"Value", type=t_U8, counter=t_U8}
}
msg{"SRSP_SYS_OSAL_NV_WRITE_EXT",
  U8  {"Cmd0", const=0x61},
  U8  {"Cmd1", const=0x09},
  U8  {"Status"}
}
]]

msg{"AREQ_SYS_RESET_IND",
  U8  {"Cmd0", const=0x41},
  U8  {"Cmd1", const=0x80},
  map {"Reason", type=t_U8, values={"PowerUp", "External", "Watchdog"}},
  U8  {"TransportRev"},
  U8  {"Product"},
  U8  {"MajorRel"},
  U8  {"MinorRel"},
  U8  {"HwRev"}
}

msg{"AREQ_SYS_OSAL_TIMER_EXPIRED",
  U8  {"Cmd0", const=0x41},
  U8  {"Cmd1", const=0x81},
  U8  {"Id"}
}

msg{"SREQ_UTIL_GET_DEVICE_INFO",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x00},
}
msg{"SRSP_UTIL_GET_DEVICE_INFO",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x00},
  U8  {"Status"}, -- does not really make sense
  arr {"IEEEAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"ShortAddr"},
  map {"DeviceType", type=t_U8, values={
    {"Coordinator", B"001", B"001"},
    {"Router", B"010", B"010"},
    {"EndDevice", B"100", B"100"}}},
  map {"DeviceState", type=t_U8, values={
    "Initialized - not started automatically",
    "Initialized - not connected to anything",
    "Discovering PANs to join",
    "Joining a PAN",
    "Rejoining a PAN",
    "Joined but not yet authenticated by TC",
    "Started as device after authentication",
    "Device joined, authenticated and is a router",
    "Starting as ZigBee Coordinator",
    "Started as ZigBee Coordinator",
    "Device has lost information about its parent"}},
  arr {"AssocDevicesList", type=t_U16, counter=t_U8}
}

msg{"SREQ_UTIL_GET_NV_INFO",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x01}
}
msg{"SRSP_UTIL_GET_NV_INFO",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x01},
  U8  {"Status"},
  arr {"IEEEAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U32 {"ScanChannels"},
  U16 {"PanId"},
  U8  {"SecurityLevel"},
  arr {"PreConfigKey", type=t_U8, length=16}
}

msg{"SREQ_UTIL_SET_PANID",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x02},
  U16 {"PanId"}
}
msg{"SRSP_UTIL_SET_PANID",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x02},
  U8  {"Status"}
}

msg{"SREQ_UTIL_SET_CHANNELS",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x03},
  U32 {"Channels"}
}
msg{"SRSP_UTIL_SET_CHANNELS",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x03},
  U8  {"Status"}
}

msg{"SREQ_UTIL_SET_SECLEVEL",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x04},
  U8  {"SecLevel"}
}
msg{"SRSP_UTIL_SET_SECLEVEL",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x04},
  U8  {"Status"}
}

msg{"SREQ_UTIL_SET_PRECFGKEY",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x05},
  arr {"PreCfgKey", type=t_U8, length=16}
}
msg{"SRSP_UTIL_SET_PRECFGKEY",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x05},
  U8  {"Status"}
}

msg{"SREQ_UTIL_CALLBACK_SUB_CMD",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x06},
  map {"Subsystem", type=t_U16, values={
    {"MT_SYS",        0x0100, 0xFFFF},
    {"MT_MAC",        0x0200, 0xFFFF},
    {"MT_NWK",        0x0300, 0xFFFF},
    {"MT_AF",         0x0400, 0xFFFF},
    {"MT_ZDO",        0x0500, 0xFFFF},
    {"MT_SAPI",       0x0600, 0xFFFF},
    {"MT_UTIL",       0x0700, 0xFFFF},
    {"MT_DEBUG",      0x0800, 0xFFFF},
    {"MT_APP",        0x0900, 0xFFFF},
    {"ALL_SUBSYSTEM", 0xFFFF, 0xFFFF}}},
  map {"Action", type=t_U8, values={"Disable","Enable"}}
}
msg{"SRSP_UTIL_CALLBACK_SUB_CMD",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x06},
  U8  {"Status"}
}

msg{"SREQ_UTIL_KEY_EVENT",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x07},
  U8  {"Keys"},
  U8  {"Shift"}
}
msg{"SRSP_UTIL_KEY_EVENT",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x07},
  U8  {"Status"}
}

msg{"SREQ_UTIL_TIME_ALIVE",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x09}
}
msg{"SRSP_UTIL_TIME_ALIVE",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x09},
  U32 {"Seconds"}
}

msg{"SREQ_UTIL_LED_CONTROL",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x0A},
  U8  {"LedId"},
  U8  {"Mode"}
}
msg{"SRSP_UTIL_LED_CONTROL",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x0A},
  U8  {"Status"}
}

msg{"SREQ_UTIL_LOOPBACK",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x10},
  arr {"Data", type=t_U8}
}
msg{"SRSP_UTIL_LOOPBACK",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x10},
  arr {"Data", type=t_U8}
}

msg{"SREQ_UTIL_DATA_REQ",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x11},
  U8  {"SecurityUse", default=0}
}
msg{"SRSP_UTIL_DATA_REQ",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x11},
  U8  {"Status"}
}

msg{"SREQ_UTIL_SRC_MATCH_ENABLE",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x20}
}
msg{"SRSP_UTIL_SRC_MATCH_ENABLE",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x20},
  U8  {"Status"}
}

msg{"SREQ_UTIL_SRC_MATCH_ADD_ENTRY",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x21},
  map {"AddressMode", type=t_U8, values={
    {"Addr16Bit", 2, 0xFF},
    {"Addr64Bit", 3, 0xFF}}},
  arr {"Address", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"PanId"}
}
msg{"SRSP_UTIL_SRC_MATCH_ADD_ENTRY",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x21},
  U8  {"Status"}
}

msg{"SREQ_UTIL_SRC_MATCH_DEL_ENTRY",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x22},
  map {"AddressMode", type=t_U8, values={
    {"Addr16Bit", 2, 0xFF},
    {"Addr64Bit", 3, 0xFF}}},
  arr {"Address", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"PanId"}
}
msg{"SRSP_UTIL_SRC_MATCH_DEL_ENTRY",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x22},
  U8  {"Status"}
}

msg{"SREQ_UTIL_SRC_MATCH_CHECK_SRC_ADDR",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x23},
  map {"AddressMode", type=t_U8, values={
    {"Addr16Bit", 2, 0xFF},
    {"Addr64Bit", 3, 0xFF}}},
  arr {"Address", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"PanId"}
}
msg{"SRSP_UTIL_SRC_MATCH_CHECK_SRC_ADDR",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x23},
  U8  {"Status"}
}

msg{"SREQ_UTIL_SRC_MATCH_ACK_ALL_PENDING",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x24},
  U8  {"Option"}
}
msg{"SRSP_UTIL_SRC_MATCH_ACK_ALL_PENDING",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x24},
  U8  {"Status"}
}

msg{"SREQ_UTIL_SRC_MATCH_CHECK_ALL_PENDING",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x25}
}
msg{"SRSP_UTIL_SRC_MATCH_CHECK_ALL_PENDING",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x25},
  U8  {"Status"},
  U8  {"Value"}
}

msg{"SREQ_UTIL_ADDRMGR_EXT_ADDR_LOOKUP",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x40},
  arr {"ExtAddr", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_UTIL_ADDRMGR_EXT_ADDR_LOOKUP",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x40},
  U16 {"NwkAddr"}
}

msg{"SREQ_UTIL_ADDRMGR_NWK_ADDR_LOOKUP",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x41},
  U16 {"NwkAddr"}
}
msg{"SRSP_UTIL_ADDRMGR_NWK_ADDR_LOOKUP",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x41},
  arr {"ExtAddr", type=t_U8, length=8, reverse=true, ashex=true}
}

msg{"SREQ_UTIL_APSME_LINK_KEY_DATA_GET",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x44},
  arr {"ExtAddr", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_UTIL_APSME_LINK_KEY_DATA_GET",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x44},
  U8  {"Status"},
  arr {"SecKey", type=t_U8, length=16},
  U32 {"TxFrmCntr"},
  U32 {"RxFrmCntr"}
}

msg{"SREQ_UTIL_APSME_LINK_KEY_NV_ID_GET",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x45},
  arr {"ExtAddr", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_UTIL_APSME_LINK_KEY_NV_ID_GET",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x45},
  U8  {"Status"},
  U16 {"LinkKeyNvId"}
}

msg{"SREQ_UTIL_APSME_REQUEST_KEY_CMD",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x4B},
  arr {"PartnerAddr", type=t_U8, length=8, reverse=true, ashex=true} -- or is it U16? Specs are wrong at at least one place
}
msg{"SRSP_UTIL_APSME_REQUEST_KEY_CMD",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x4B},
  U8  {"Status"}
}

msg{"SREQ_UTIL_ASSOC_COUNT",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x48},
  map {"StartRelation", type=t_U8, values={"PARENT", "CHILD_RFD", "CHILD_RFD_RX_IDLE", "CHILD_FFD", "CHILD_FFD_RX_IDLE", "NEIGHBOR", "OTHER"}},
  map {"EndRelation", type=t_U8, values={"PARENT", "CHILD_RFD", "CHILD_RFD_RX_IDLE", "CHILD_FFD", "CHILD_FFD_RX_IDLE", "NEIGHBOR", "OTHER"}}
}
msg{"SRSP_UTIL_ASSOC_COUNT",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x48},
  U16 {"Count"}
}

msg{"SREQ_UTIL_ASSOC_FIND_DEVICE",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x49},
  U8  {"Number"}
}
msg{"SRSP_UTIL_ASSOC_FIND_DEVICE",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x49},
--[[ wrong number of bytes according to doc (maybe typo? 18 bytes according to doc, but struct has 28):
  -- associated_devices_t:
  U16 {"ShortAddr"},
  U16 {"AddrIdx"},
  U8  {"NodeRelation"},
  U8  {"DevStatus"},
  U8  {"AssocCnt"},
  U8  {"Age"},
  --   linkInfo_t:
  U8  {"TxCounter"},
  U8  {"TxCost"},
  U8  {"RxLqi"},
  U8  {"InKeySeqNum"},
  U32 {"inFrmCntr"},
  U16 {"TxFailure"},
  --   aging_end_device_t:
  U8  {"EndDevCfg"},
  U32 {"DeviceTimeout"},
  -- associated_devices_t cont.:
  U32 {"TimeoutCounter"},
  U8  {"KeepaliveRcv"}
--]]
  arr {"Device", type=t_U8, length=18}
}

msg{"SREQ_UTIL_ASSOC_GET_WITH_ADDRESS",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x4A},
  arr {"ExtAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"NwkAddr"}
}
msg{"SRSP_UTIL_ASSOC_GET_WITH_ADDRESS",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x4A},
  arr {"Device", type=t_U8, length=18} -- see above @UTIL_ASSOC_FIND_DEVICE
}

msg{"SREQ_UTIL_BIND_ADD_ENTRY",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x4D},
  map {"AddrMode", type=t_U8, values={
    {"AddrNotPresent", 0, 0xFF},
    {"AddrGroup", 1, 0xFF},
    {"Addr16Bit", 2, 0xFF},
    {"Addr64Bit", 3, 0xFF},
    {"AddrBroadcast", 15, 0xFF}}},
  arr {"DstAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U8  {"DstEndpoint"},
  arr {"ClusterIds", type=t_U16, counter=t_U8}
}
msg{"SRSP_UTIL_BIND_ADD_ENTRY",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x4D},
  -- BindingEntry_t:
  U8  {"SrcEP"},
  U8  {"DstGroupMode"},
  U16 {"DstIdx"},
  U8  {"DstEP"},
  arr {"ClusterIdList", type=t_U16, counter=t_U8}
}

msg{"SREQ_UTIL_ZCL_KEY_EST_INIT_EST",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x80},
  U8  {"TaskId"},
  U8  {"SeqNum"},
  U8  {"EndPoint"},
  map {"AddrMode", type=t_U8, values={
    {"AddrNotPresent", 0, 0xFF},
    {"AddrGroup", 1, 0xFF},
    {"Addr16Bit", 2, 0xFF},
    {"Addr64Bit", 3, 0xFF},
    {"AddrBroadcast", 15, 0xFF}}},
  arr {"Addr", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_UTIL_ZCL_KEY_EST_INIT_EST",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x80},
  U8  {"Status"}
}

msg{"SREQ_UTIL_ZCL_KEY_EST_SIGN",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x81},
  arr {"Input", type=t_U8, counter=t_U8}
}
msg{"SRSP_UTIL_ZCL_KEY_EST_SIGN",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x81},
  U8  {"Status"},
  arr {"Key", type=t_U8, length=42}
}

msg{"SREQ_UTIL_SRNG_GEN",
  U8  {"Cmd0", const=0x27},
  U8  {"Cmd1", const=0x4C}
}
msg{"SRSP_UTIL_SRNG_GEN",
  U8  {"Cmd0", const=0x67},
  U8  {"Cmd1", const=0x4C},
  arr {"SecureRandomNumbers", type=t_U8, length=100}
}

msg{"AREQ_UTIL_SYNC_REQ",
  U8  {"Cmd0", const=0x47},
  U8  {"Cmd1", const=0xE0}
}
msg{"AREQ_UTIL_ZCL_KEY_ESTABLISH_IND",
  U8  {"Cmd0", const=0x47},
  U8  {"Cmd1", const=0xE1},
  U8  {"TaskId"},
  U8  {"Event"},
  U8  {"Status"},
  U8  {"WaitTime"},
  U16 {"Suite"}
}

msg{"SREQ_ZDO_NWK_ADDR_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x00},
  arr {"IEEEAddress", type=t_U8, length=8, reverse=true, ashex=true},
  map {"ReqType", type=t_U8, values={"Single", "Extended"}},
  U8  {"StartIndex", default=0}
}
msg{"SRSP_ZDO_NWK_ADDR_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x00},
  U8  {"Status"}
}

msg{"SREQ_ZDO_IEEE_ADDR_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x01},
  U16 {"ShortAddr"},
  map {"ReqType", type=t_U8, values={"Single", "Extended"}},
  U8  {"StartIndex", default=0}
}
msg{"SRSP_ZDO_IEEE_ADDR_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x01},
  U8  {"Status"}
}

msg{"SREQ_ZDO_NODE_DESC_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x02},
  U16 {"DstAddr"},
  U16 {"NWKAddrOfInterest"}
}
msg{"SRSP_ZDO_NODE_DESC_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x02},
  U8  {"Status"}
}

msg{"SREQ_ZDO_POWER_DESC_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x03},
  U16 {"DstAddr"},
  U16 {"NWKAddrOfInterest"}
}
msg{"SRSP_ZDO_POWER_DESC_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x03},
  U8  {"Status"}
}

msg{"SREQ_ZDO_SIMPLE_DESC_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x04},
  U16 {"DstAddr"},
  U16 {"NWKAddrOfInterest"},
  U8  {"Endpoint"}
}
msg{"SRSP_ZDO_SIMPLE_DESC_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x04},
  U8  {"Status"}
}

msg{"SREQ_ZDO_ACTIVE_EP_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x05},
  U16 {"DstAddr"},
  U16 {"NWKAddrOfInterest"}
}
msg{"SRSP_ZDO_ACTIVE_EP_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x05},
  U8  {"Status"}
}

msg{"SREQ_ZDO_MATCH_DESC_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x06},
  U16 {"DstAddr"},
  U16 {"NWKAddrOfInterest"},
  U16 {"ProfileId"},
  arr {"InClusterList", type=t_U16, counter=t_U8},
  arr {"OutClusterList", type=t_U16, counter=t_U8}
}
msg{"SRSP_ZDO_MATCH_DESC_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x06},
  U8  {"Status"}
}

msg{"SREQ_ZDO_COMPLEX_DESC_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x07},
  U16 {"DstAddr"},
  U16 {"NWKAddrOfInterest"}
}
msg{"SRSP_ZDO_COMPLEX_DESC_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x07},
  U8  {"Status"}
}

msg{"SREQ_ZDO_USER_DESC_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x08},
  U16 {"DstAddr"},
  U16 {"NWKAddrOfInterest"}
}
msg{"SRSP_ZDO_USER_DESC_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x08},
  U8  {"Status"}
}

msg{"SREQ_ZDO_END_DEVICE_ANNCE",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x0A},
  U16 {"NwkAddr"},
  arr {"IEEEAddr", type=t_U8, length=8, reverse=true, ashex=true},
  map {"Capabilities", type=t_U8, values={
    {"AlternatePANCoordinator", B"00000001", B"00000001"},
    {"ZigbeeRouter",            B"00000010", B"00000010"},
    {"MainPowered",             B"00000100", B"00000100"},
    {"ReceiverOnWhenIdle",      B"00001000", B"00001000"},
    {"Reserved1",               B"00010000", B"00010000"},
    {"Reserved2",               B"00100000", B"00100000"},
    {"SecurityCapability",      B"01000000", B"01000000"},
    {"AllocateShortAddress",    B"10000000", B"10000000"},
  }}
}
msg{"SRSP_ZDO_END_DEVICE_ANNCE",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x0A},
  U8  {"Status"}
}

msg{"SREQ_ZDO_USER_DESC_SET",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x0B},
  U16 {"DstAddr"},
  U16 {"NWKAddrOfInterest"},
  arr {"UserDescriptor", type=t_U8, counter=t_U8}
}
msg{"SRSP_ZDO_USER_DESC_SET",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x0B},
  U8  {"Status"}
}

msg{"SREQ_ZDO_SERVER_DISC_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x0C},
  U16 {"ServerMask"}
}
msg{"SRSP_ZDO_SERVER_DISC_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x0C},
  U8  {"Status"}
}

msg{"SREQ_ZDO_END_DEVICE_BIND_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x20},
  U16 {"DstAddr"},
  U16 {"LocalCoordinator"},
  arr {"IEEE", type=t_U8, length=8, reverse=true, ashex=true}, -- documentation is inconsistent here
  U8  {"Endpoint"},
  U16 {"ProfileId"},
  arr {"InClusterList", type=t_U16, counter=t_U8},
  arr {"OutClusterList", type=t_U16, counter=t_U8}
}
msg{"SRSP_ZDO_END_DEVICE_BIND_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x20},
  U8  {"Status"}
}

msg{"SREQ_ZDO_BIND_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x21},
  U16 {"DstAddr"},
  arr {"SrcAddress", type=t_U8, length=8, reverse=true, ashex=true},
  U8  {"SrcEndpoint"},
  U16 {"ClusterId"},
  map {"DstAddrMode", type=t_U8, values={
    {"AddrNotPresent", 0, 0xFF},
    {"AddrGroup", 1, 0xFF},
    {"Addr16Bit", 2, 0xFF},
    {"Addr64Bit", 3, 0xFF},
    {"AddrBroadcast", 15, 0xFF}}},
  arr {"DstAddress", type=t_U8, length=8, reverse=true, ashex=true}, -- note that there is an alternative
  U8  {"DstEndpoint"} -- variant that uses 16 bit addresses
}
msg{"SRSP_ZDO_BIND_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x21},
  U8  {"Status"}
}

msg{"SREQ_ZDO_UNBIND_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x22},
  U16 {"DstAddr"},
  arr {"SrcAddress", type=t_U8, length=8, reverse=true, ashex=true},
  U8  {"SrcEndpoint"},
  U16 {"ClusterId"},
  map {"DstAddrMode", type=t_U8, values={
    {"AddrNotPresent", 0, 0xFF},
    {"AddrGroup", 1, 0xFF},
    {"Addr16Bit", 2, 0xFF},
    {"Addr64Bit", 3, 0xFF},
    {"AddrBroadcast", 15, 0xFF}}},
  arr {"DstAddress", type=t_U8, length=8, reverse=true, ashex=true},
  U8  {"DstEndpoint"}
}
msg{"SRSP_ZDO_UNBIND_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x22},
  U8  {"Status"}
}

msg{"SREQ_ZDO_MGMT_NWK_DISC_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x30},
  U16 {"DstAddr"},
  U32 {"ScanChannels"},
  U8  {"ScanDuration"},
  U8  {"StartIndex", default=0}
}
msg{"SRSP_ZDO_MGMT_NWK_DISC_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x30},
  U8  {"Status"}
}

msg{"SREQ_ZDO_MGMT_LQI_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x31},
  U16 {"DstAddr"},
  U8  {"StartIndex", default=0}
}
msg{"SRSP_ZDO_MGMT_LQI_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x31},
  U8  {"Status"}
}

msg{"SREQ_ZDO_MGMT_RTG_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x32},
  U16 {"DstAddr"},
  U8  {"StartIndex", default=0}
}
msg{"SRSP_ZDO_MGMT_RTG_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x32},
  U8  {"Status"}
}

msg{"SREQ_ZDO_MGMT_BIND_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x33},
  U16 {"DstAddr"},
  U8  {"StartIndex", default=0}
}
msg{"SRSP_ZDO_MGMT_BIND_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x33},
  U8  {"Status"}
}

msg{"SREQ_ZDO_MGMT_LEAVE_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x34},
  U16 {"DstAddr"},
  arr {"DeviceAddress", type=t_U8, length=8, reverse=true, ashex=true},
  U8  {"RemoveChildren", default=0}
}
msg{"SRSP_ZDO_MGMT_LEAVE_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x34},
  U8  {"Status"}
}

msg{"SREQ_ZDO_MGMT_DIRECT_JOIN_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x35},
  U16 {"DstAddr"},
  arr {"DeviceAddress", type=t_U8, length=8, reverse=true, ashex=true},
  map {"CapInfo", type=t_U8, values={
    {"AlternatePANCoordinator", B"0000001", B"0000001"},
    {"ZigbeeRouter",            B"0000010", B"0000010"},
    {"MainPowered",             B"0000100", B"0000100"},
    {"ReceiverOnWhenIdle",      B"0001000", B"0001000"},
    {"Reserved1",               B"0010000", B"0010000"},
    {"Reserved2",               B"0100000", B"0100000"},
    {"SecurityCapability",      B"1000000", B"1000000"}}}
}
msg{"SRSP_ZDO_MGMT_DIRECT_JOIN_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x35},
  U8  {"Status"}
}

msg{"SREQ_ZDO_MGMT_PERMIT_JOIN_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x36},
  U16 {"DstAddr"},
  U8  {"Duration", default=0},
  U8  {"TCSignificance"}
}
msg{"SRSP_ZDO_MGMT_PERMIT_JOIN_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x36},
  U8  {"Status"}
}

msg{"SREQ_ZDO_MGMT_NWK_UPDATE_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x37},
  U16 {"DstAddr"},
  map {"DstAddrMode", type=t_U8, values={
    {"AddrNotPresent", 0, 0xFF},
    {"AddrGroup", 1, 0xFF},
    {"Addr16Bit", 2, 0xFF},
    {"Addr64Bit", 3, 0xFF},
    {"AddrBroadcast", 0xFF, 0xFF}}}, -- check this, it might be wrong in the docs and 0x0F instead
  U32 {"ChannelMask", default=0x07FFF800},
  U8  {"ScanDuration"},
  U8  {"ScanCount"},
  U16 {"NwkManagerAddr"}
}
msg{"SRSP_ZDO_MGMT_NWK_UPDATE_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x37},
  U8  {"Status"}
}

msg{"SREQ_ZDO_MSG_CB_REGISTER",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x3E},
  U16 {"ClusterId"}
}
msg{"SRSP_ZDO_MSG_CB_REGISTER",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x3E},
  U8  {"Status"}
}

msg{"SREQ_ZDO_MSG_CB_REMOVE",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x3F},
  U16 {"ClusterId"}
}
msg{"SRSP_ZDO_MSG_CB_REMOVE",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x3F},
  U8  {"Status"}
}

msg{"SREQ_ZDO_STARTUP_FROM_APP",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x40},
  U16 {"StartDelay", default=0}
}
msg{"SRSP_ZDO_STARTUP_FROM_APP",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x40},
  U8  {"Status"}
}

msg{"SREQ_ZDO_STARTUP_FROM_APP_EX", -- doc says it exists, sources are not really confirming this
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x54},
  U8  {"StartDelay", default=0},
  U8  {"Mode", default=0}
}
msg{"SRSP_ZDO_STARTUP_FROM_APP_EX",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x54}, -- doc is most probably wrong and says it's 0x6540
  U8  {"Status"}
}

msg{"SREQ_ZDO_SET_LINK_KEY",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x23},
  U16 {"ShortAddr"},
  arr {"IEEEAddr", type=t_U8, length=8, reverse=true, ashex=true},
  arr {"LinkKeyData", type=t_U8, length=16}
}
msg{"SRSP_ZDO_SET_LINK_KEY",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x23},
  U8  {"Status"}
}

msg{"SREQ_ZDO_REMOVE_LINK_KEY",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x24},
  arr {"IEEEAddr", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_ZDO_REMOVE_LINK_KEY",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x24},
  U8  {"Status"}
}

msg{"SREQ_ZDO_GET_LINK_KEY",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x25},
  arr {"IEEEAddr", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_ZDO_GET_LINK_KEY",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x25},
  U8  {"Status"}
}

msg{"SREQ_ZDO_NWK_DISCOVERY_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x26},
  U32 {"ScanChannels"},
  U8  {"ScanDuration"}
}
msg{"SRSP_ZDO_NWK_DISCOVERY_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x26},
  U8  {"Status"}
}

msg{"SREQ_ZDO_JOIN_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x27},
  U8  {"LogicalChannel"},
  U16 {"PanId"},
  arr {"ExtendedPanId", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"ChosenParent"},
  U8  {"ParentDepth"},
  U8  {"StackProfile"}
}
msg{"SRSP_ZDO_JOIN_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x27},
  U8  {"Status"}
}

msg{"SREQ_ZDO_SET_REJOIN_PARAMETERS",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0xCC}, -- not per docs
  U32 {"BackoffDuration"},
  U32 {"ScanDuration"}
}
msg{"SRSP_ZDO_SET_REJOIN_PARAMETERS",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0xCC}, -- not per docs
  U8  {"Status"}
}

msg{"SREQ_ZDO_SEC_ADD_LINK_KEY",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x42},
  U16 {"ShortAddress"},
  arr {"ExtendedAddress", type=t_U8, length=8, reverse=true, ashex=true},
  arr {"Key", type=t_U8, length=16}
}
msg{"SRSP_ZDO_SEC_ADD_LINK_KEY",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x42},
  U8  {"Status"}
}

msg{"SREQ_ZDO_SEC_ENTRY_LOOKUP_EXT",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x43},
  arr {"ExtendedAddress", type=t_U8, length=8, reverse=true, ashex=true},
  arr {"ValidEntry", type=t_U8, length=5}
}
msg{"SRSP_ZDO_SEC_ENTRY_LOOKUP_EXT",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x43},
  U16 {"AMI"},
  U16 {"KeyNVId"},
  U8  {"AuthenticationOption"}
}

msg{"SREQ_ZDO_SEC_DEVICE_REMOVE",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x44},
  arr {"ExtendedAddress", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_ZDO_SEC_DEVICE_REMOVE",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x44},
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_ROUTE_DISC",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x45},
  U16 {"DestinationAddress"},
  U8  {"Options"},
  U8  {"Radius"}
}
msg{"SRSP_ZDO_EXT_ROUTE_DISC",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x45},
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_ROUTE_CHECK",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x46},
  U16 {"DestinationAddress"},
  U8  {"RtStatus"},
  U8  {"Options"}
}
msg{"SRSP_ZDO_EXT_ROUTE_CHECK",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x46},
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_REMOVE_GROUP",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x47},
  U8  {"Endpoint"},
  U16 {"GroupId"}
}
msg{"SRSP_ZDO_EXT_REMOVE_GROUP",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x47},
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_REMOVE_ALL_GROUP",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x48},
  U8  {"Endpoint"}
}
msg{"SRSP_ZDO_EXT_REMOVE_ALL_GROUP",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x48},
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_FIND_ALL_GROUPS_ENDPOINT",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x49},
  U8  {"Endpoint"},
  U16 {"GroupList"}
}
msg{"SRSP_ZDO_EXT_FIND_ALL_GROUPS_ENDPOINT",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x49},
  arr {"Groups", type=t_U16, counter=t_U8}
}

msg{"SREQ_ZDO_EXT_FIND_GROUP",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x4A},
  U8  {"Endpoint"},
  U16 {"GroupId"}
}
msg{"SRSP_ZDO_EXT_FIND_GROUP",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x4A},
  arr {"Groups", type=t_U16, counter=t_U8} -- docs are fuzzy here
}

msg{"SREQ_ZDO_EXT_ADD_GROUP",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x4B},
  U8  {"Endpoint"},
  U16 {"GroupId"},
  arr {"GroupName", type=t_U8, length=16} -- docs are fuzzy/strange here
}
msg{"SRSP_ZDO_EXT_ADD_GROUP",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x4B},
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_COUNT_ALL_GROUPS",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x4C}
}
msg{"SRSP_ZDO_EXT_COUNT_ALL_GROUPS",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x4C},
  U8  {"NumberOfGroups"}
}

msg{"SREQ_ZDO_EXT_RX_IDLE",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x4D},
  U8  {"SetFlag"},
  U8  {"SetValue"}
}
msg{"SRSP_ZDO_EXT_RX_IDLE",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x4D},
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_UPDATE_NWK_KEY",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x4E},
  U16 {"DestinationAddress"},
  U8  {"KeySeqNum"},
  arr {"Key", length=128} -- length is probably an error in the docs?
}
msg{"SRSP_ZDO_EXT_UPDATE_NWK_KEY",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x4E},
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_SWITCH_NWK_KEY",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x4F},
  U16 {"DestinationAddress"},
  U8  {"KeySeqNum"}
}
msg{"SRSP_ZDO_EXT_SWITCH_NWK_KEY",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x4F},
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_NWK_INFO",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x50}
}
msg{"SRSP_ZDO_EXT_NWK_INFO",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x50},
  U16 {"ShortAddress"},
  U16 {"PanId"},
  U16 {"ParentAddress"},
  arr {"ExtendedPanId", type=t_U8, length=8, reverse=true, ashex=true},
  arr {"ExtendedParentAddress", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"Channel"}
}

msg{"SREQ_ZDO_EXT_SEC_APS_REMOVE_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x51},
  U16 {"NwkAddress"},
  arr {"ExtendedAddress", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"ParentAddress"}
}
msg{"SRSP_ZDO_EXT_SEC_APS_REMOVE_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x51},
  U8  {"Status"}
}

msg{"SREQ_ZDO_FORCE_CONCENTRATOR_CHANGE",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x52}
}
msg{"SRSP_ZDO_FORCE_CONCENTRATOR_CHANGE",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x52}
}

msg{"SREQ_ZDO_EXT_SET_PARAMS",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x53},
  U8  {"UseMulticast"}
}
msg{"SRSP_ZDO_EXT_SET_PARAMS",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x53},
  U8  {"Status"}
}

msg{"SREQ_ZDO_NWK_ADDR_OF_INTEREST_REQ",
  U8  {"Cmd0", const=0x25},
  U8  {"Cmd1", const=0x29},
  U16 {"DestAddr"},
  U16 {"NwkAddrOfInterest"},
  U8  {"Cmd"} -- according to docs, a cluster ID - however, those would be 16bit?!?
}
msg{"SRSP_ZDO_NWK_ADDR_OF_INTEREST_REQ",
  U8  {"Cmd0", const=0x65},
  U8  {"Cmd1", const=0x29},
  U8  {"Status"}
}

msg{"AREQ_ZDO_NWK_ADDR_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0x80},
  U8  {"Status"},
  arr {"IEEEAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"NwkAddr"},
  U8  {"StartIndex"},
  arr {"AssocDevList", type=t_U16, counter=t_U8}
}

msg{"AREQ_ZDO_IEEE_ADDR_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0x81},
  U8  {"Status"},
  arr {"IEEEAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"NwkAddr"},
  U8  {"StartIndex"},
  arr {"AssocDevList", type=t_U16, counter=t_U8} -- now is it t_U16 or t_U64?
}

msg{"AREQ_ZDO_NODE_DESC_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0x82},
  U16 {"SrcAddr"},
  U8  {"Status"},
  U16 {"NwkAddrOfInterest"},
  map {"Flags", type=t_U8, values={
    {"LogicalTypeCoordinator",     B"00000", B"00111"},
    {"LogicalTypeRouter",          B"00001", B"00111"},
    {"LogicalTypeEndDevice",       B"00010", B"00111"},
    {"ComplexDescriptorAvailable", B"01000", B"01000"},
    {"UserDescriptorAvailable",    B"10000", B"10000"}}},
  U8  {"Flags2"},
  U8  {"MacCapabilitiesFlags"}, -- TODO: map this
  U16 {"ManufacturerCode"},
  U8  {"MaxBufferSize"},
  U16 {"MaxInTransferSize"},
  U16 {"ServerMask"}, -- TODO: map this
  U16 {"MaxOutTransferSize"},
  U8  {"DescriptorCapabilities"}
}

msg{"AREQ_ZDO_POWER_DESC_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0x83},
  U16 {"SrcAddr"},
  U8  {"Status"},
  U16 {"NwkAddr"},
  U8  {"CurrentPowerMode_AvailablePowerSources"},
  U8  {"CurrentPowerSource_CurrentPowerSourceLevel"}
}

msg{"AREQ_ZDO_SIMPLE_DESC_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0x84},
  U16 {"SrcAddr"},
  U8  {"Status"},
  U16 {"NwkAddr"},
  U8  {"Len"},
  U8  {"Endpoint"},
  U16 {"ProfileId"},
  U16 {"DeviceId"},
  U8  {"DeviceVersion"},
  arr {"InClusterList", type=t_U16, counter=t_U8},
  arr {"OutClusterList", type=t_U16, counter=t_U8}
}

msg{"AREQ_ZDO_ACTIVE_EP_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0x85},
  U16 {"SrcAddr"},
  U8  {"Status"},
  U16 {"NwkAddr"},
  arr {"ActiveEPList", type=t_U8, counter=t_U8},
}

msg{"AREQ_ZDO_MATCH_DESC_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0x86},
  U16 {"SrcAddr"},
  U8  {"Status"},
  U16 {"NwkAddr"},
  arr {"MatchList", type=t_U8, counter=t_U8},
}

msg{"AREQ_ZDO_COMPLEX_DESC_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0x87},
  U16 {"SrcAddr"},
  U8  {"Status"},
  U16 {"NwkAddr"},
  arr {"ComplexDescriptor", type=t_U8, counter=t_U8},
}

msg{"AREQ_ZDO_USER_DESC_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0x88},
  U16 {"SrcAddr"},
  U8  {"Status"},
  U16 {"NwkAddr"},
  arr {"UserDescriptor", type=t_U8, counter=t_U8},
}

msg{"AREQ_ZDO_USER_DESC_CONF",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0x89},
  U16 {"SrcAddr"},
  U8  {"Status"},
  U16 {"NwkAddr"}
}

msg{"AREQ_ZDO_SERVER_DISC_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0x8A},
  U16 {"SrcAddr"},
  U8  {"Status"},
  U16 {"ServerMask"} -- TODO: map this
}

msg{"AREQ_ZDO_END_DEVICE_BIND_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xA0},
  U16 {"SrcAddr"},
  U8  {"Status"},
}

msg{"AREQ_ZDO_BIND_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xA1},
  U16 {"SrcAddr"},
  U8  {"Status"},
}

msg{"AREQ_ZDO_UNBIND_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xA2},
  U16 {"SrcAddr"},
  U8  {"Status"},
}

msg{"AREQ_ZDO_MGMT_NWK_DISC_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xB0},
  U16 {"SrcAddr"},
  U8  {"Status"},
  U8  {"NetworkCount"},
  U8  {"StartIndex"},
  arr {"NetworkList", type=msg{false,
      U16 {"PanId"},
      U8  {"LogicalChannel"},
      U8  {"StackProfile_ZigbeeVersion"},
      U8  {"BeaconOrder_SuperframeOrder"},
      U8  {"PermitJoining"}
    },
    counter=t_U8}
}

msg{"AREQ_ZDO_MGMT_LQI_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xB1},
  U16 {"SrcAddr"},
  U8  {"Status"},
  U8  {"NeighborTableEntries"},
  U8  {"StartIndex"},
  arr {"NeighborTableList", type=msg{false,
      arr {"ExtendedPanId", type=t_U8, length=8, reverse=true, ashex=true},
      arr {"ExtendedAddress", type=t_U8, length=8, reverse=true, ashex=true},
      U16 {"NetworkAddress"},
      U8  {"DeviceType_RxOnWhenIdle_Relationship"},
      U8  {"PermitJoining"},
      U8  {"Depth"},
      U8  {"Lqi"}
    },
    counter=t_U8}
}

msg{"AREQ_ZDO_MGMT_RTG_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xB2},
  U16 {"SrcAddr"},
  U8  {"Status"},
  U8  {"RoutingTableEntries"},
  U8  {"StartIndex"},
  arr {"RoutingTableList", type=msg{false,
      U16 {"DestinationAddress"},
      U8  {"Status"},
      U16 {"NextHop"}
    },
    counter=t_U8}
}

msg{"AREQ_ZDO_MGMT_BIND_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xB3},
  U16 {"SrcAddr"},
  U8  {"Status"},
  U8  {"BindTableEntries"},
  U8  {"StartIndex"},
  arr {"BindTableList", type=msg{false,
      arr {"SrcAddr", type=t_U8, length=8, reverse=true, ashex=true},
      U8  {"SrcEndpoint"},
      U8  {"ClusterId"},
      U8  {"DstAddrMode"},
      arr {"DstAddr", type=t_U8, length=8, reverse=true, ashex=true},
      U8  {"DstEndpoint"}
    },
    counter=t_U8}
}

msg{"AREQ_ZDO_MGMT_LEAVE_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xB4},
  U16 {"SrcAddr"},
  U8  {"Status"}
}

msg{"AREQ_ZDO_MGMT_DIRECT_JOIN_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xB5},
  U16 {"SrcAddr"},
  U8  {"Status"}
}

msg{"AREQ_ZDO_MGMT_PERMIT_JOIN_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xB6},
  U16 {"SrcAddr"},
  U8  {"Status"}
}

msg{"AREQ_ZDO_STATE_CHANGE_IND",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xC0},
  U8  {"State"},
}

msg{"AREQ_ZDO_END_DEVICE_ANNCE_IND",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xC1},
  U16 {"SrcAddr"},
  U16 {"NwkAddr"},
  arr {"IEEEAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U8  {"Capabilities"} -- TODO: map this
}

msg{"AREQ_ZDO_MATCH_DESC_RSP_SENT",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xC2},
  U16 {"NwkAddr"},
  arr {"InClusterList", type=t_U16, counter=t_U8},
  arr {"OutClusterList", type=t_U16, counter=t_U8}
}

msg{"AREQ_ZDO_STATUS_ERROR_RSP",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xC3},
  U16 {"SrcAddr"},
  U8  {"Status"}
}

msg{"AREQ_ZDO_SRC_RTG_IND",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xC4},
  U16 {"DstAddr"},
  arr {"RelayList", type=t_U16, counter=t_U8}
}

msg{"AREQ_ZDO_BEACON_NOTIFY_IND",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xC5},
  arr {"BeaconList", type=map{false,
      U16 {"SourceAddress"},
      U16 {"PanId"},
      U8  {"LogicalChannel"},
      U8  {"PermitJoining"},
      U8  {"RouterCapacity"},
      U8  {"DeviceCapacity"},
      U8  {"ProtocolVersion"},
      U8  {"StackProfile"},
      U8  {"Lqi"},
      U8  {"Depth"},
      U8  {"UpdateId"},
      arr {"ExtendedPanId", type=t_U8, length=8, reverse=true, ashex=true}
    },
    counter=t_U8}
}

msg{"AREQ_ZDO_JOIN_CNF",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xC6},
  U8  {"Status"},
  U16 {"DeviceAddress"},
  U16 {"ParentAddress"}
}

msg{"AREQ_ZDO_NWK_DISCOVERY_CNF",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xC7},
  U8  {"Status"},
}

msg{"AREQ_ZDO_LEAVE_IND",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xC9},
  U16 {"SrcAddr"},
  arr {"ExtAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U8  {"Request"},
  U8  {"Remove"},
  U8  {"Rejoin"}
}

msg{"AREQ_ZDO_MSG_CB_INCOMING",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xFF},
  U16 {"SrcAddr"},
  U8  {"WasBroadcast"},
  U16 {"ClusterId"},
  U8  {"SecurityUse"},
  U8  {"SeqNum"},
  U16 {"MacDstAddr"},
  rst {"Data"}
}

msg{"AREQ_ZDO_TC_DEV_IND",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xCA},
  U16 {"SrcNwkAddr"},
  arr {"SrcIEEEAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"ParentNwkAddr"}
}

msg{"AREQ_ZDO_PERMIT_JOIN_IND",
  U8  {"Cmd0", const=0x45},
  U8  {"Cmd1", const=0xCB},
  U8  {"PermitJoinDuration"}
}

msg{"SREQ_APP_CNF_SET_NWK_FRAME_COUNTER",
  U8  {"Cmd0", const=0x2F},
  U8  {"Cmd1", const=0xFF},
  U32 {"FrameCounterValue"} -- docs are fuzzy whether this is U8/U32
}
msg{"SRSP_APP_CNF_SET_NWK_FRAME_COUNTER",
  U8  {"Cmd0", const=0x6F},
  U8  {"Cmd1", const=0xFF},
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_SET_DEFAULT_REMOTE_ENDDEVICE_TIMEOUT",
  U8  {"Cmd0", const=0x2F},
  U8  {"Cmd1", const=0x01},
  U8  {"TimeoutIndex"}
}
msg{"SRSP_APP_CNF_SET_DEFAULT_REMOTE_ENDDEVICE_TIMEOUT",
  U8  {"Cmd0", const=0x6F},
  U8  {"Cmd1", const=0x01},
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_SET_ENDDEVICETIMEOUT",
  U8  {"Cmd0", const=0x2F},
  U8  {"Cmd1", const=0x02},
  U8  {"TimeoutIndex"}
}
msg{"SRSP_APP_CNF_SET_ENDDEVICETIMEOUT",
  U8  {"Cmd0", const=0x6F},
  U8  {"Cmd1", const=0x02},
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_SET_ALLOWREJOIN_TC_POLICY",
  U8  {"Cmd0", const=0x2F},
  U8  {"Cmd1", const=0x03},
  U8  {"AllowRejoin"}
}
msg{"SRSP_APP_CNF_SET_ALLOWREJOIN_TC_POLICY",
  U8  {"Cmd0", const=0x6F},
  U8  {"Cmd1", const=0x03},
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_BDB_START_COMMISSIONING",
  U8  {"Cmd0", const=0x2F},
  U8  {"Cmd1", const=0x05},
  U8  {"CommissioningMode"}
}
msg{"SRSP_APP_CNF_BDB_START_COMMISSIONING",
  U8  {"Cmd0", const=0x6F},
  U8  {"Cmd1", const=0x05},
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_BDB_SET_CHANNEL",
  U8  {"Cmd0", const=0x2F},
  U8  {"Cmd1", const=0x08},
  U8  {"IsPrimary", default=1},
  U32 {"Channel", default=0x800}
}
msg{"SRSP_APP_CNF_BDB_SET_CHANNEL",
  U8  {"Cmd0", const=0x6F},
  U8  {"Cmd1", const=0x08},
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_BDB_ADD_INSTALLCODE_installcode_crc",
  U8  {"Cmd0", const=0x2F},
  U8  {"Cmd1", const=0x04},
  U8  {"InstallCodeFormat", const=0x01},
  arr {"IEEEAddress", type=t_U8, length=8, reverse=true, ashex=true},
  arr {"InstallCode", type=t_U8, length=18}
}
msg{"SREQ_APP_CNF_BDB_ADD_INSTALLCODE_derived_key",
  U8  {"Cmd0", const=0x2F},
  U8  {"Cmd1", const=0x04},
  U8  {"InstallCodeFormat", const=0x02},
  arr {"IEEEAddress", type=t_U8, length=8, reverse=true, ashex=true},
  arr {"InstallCode", type=t_U8, length=16}
}
msg{"SRSP_APP_CNF_BDB_ADD_INSTALLCODE",
  U8  {"Cmd0", const=0x6F},
  U8  {"Cmd1", const=0x04},
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_BDB_SET_TC_REQUIRE_KEY_EXCHANGE",
  U8  {"Cmd0", const=0x2F},
  U8  {"Cmd1", const=0x09},
  U8  {"BdbTrustCenterRequireKeyExchange"},
}
msg{"SRSP_APP_CNF_BDB_SET_TC_REQUIRE_KEY_EXCHANGE",
  U8  {"Cmd0", const=0x6F},
  U8  {"Cmd1", const=0x09},
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_BDB_SET_JOINUSESINSTALLCODEKEY",
  U8  {"Cmd0", const=0x2F},
  U8  {"Cmd1", const=0x06},
  U8  {"BdbJoinUsesInstallCodeKey"},
}
msg{"SRSP_APP_CNF_BDB_SET_JOINUSESINSTALLCODEKEY",
  U8  {"Cmd0", const=0x6F},
  U8  {"Cmd1", const=0x06},
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_BDB_SET_ACTIVE_DEFAULT_CENTRALIZED_KEY",
  U8  {"Cmd0", const=0x2F},
  U8  {"Cmd1", const=0x07},
  U8  {"UseGlobal"},
  arr {"InstallCode", type=t_U8, length=18}
}
msg{"SRSP_APP_CNF_BDB_SET_ACTIVE_DEFAULT_CENTRALIZED_KEY",
  U8  {"Cmd0", const=0x6F},
  U8  {"Cmd1", const=0x07},
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_BDB_ZED_ATTEMPT_RECOVER_NWK",
  U8  {"Cmd0", const=0x2F},
  U8  {"Cmd1", const=0x0A}
}
msg{"SRSP_APP_CNF_BDB_ZED_ATTEMPT_RECOVER_NWK",
  U8  {"Cmd0", const=0x6F},
  U8  {"Cmd1", const=0x0A},
  U8  {"Status"}
}

msg{"AREQ_APP_CNF_BDB_COMMISSIONING_NOTIFICATION",
  U8  {"Cmd0", const=0x4F},
  U8  {"Cmd1", const=0x80},
  U8  {"Status"}, -- TODO: map all of these
  U8  {"CommissioningMode"},
  U8  {"RemainingCommissioningModes"}
}

msg{"SREQ_GP_DATA_REQ",
  U8  {"Cmd0", const=0x35},
  U8  {"Cmd1", const=0x01},
  U8  {"Action"},
  U8  {"TxOptions"},
  U8  {"ApplicationId"},
  U32 {"SrcId"},
  arr {"GPDIEEEAddress", type=t_U8, length=8, reverse=true, ashex=true},
  U8  {"Endpoint"},
  U8  {"GPDCommandId"},
  arr {"GPDASDU", type=t_U8, counter=t_U8},
  U8  {"GPEPHandle"},
  arr {"GPTxQueueEntryLifetime", type=t_U8, length=3}
}
msg{"SRSP_GP_DATA_REQ",
  U8  {"Cmd0", const=0x75},
  U8  {"Cmd1", const=0x01},
  U8  {"Status"}
}

msg{"SREQ_GP_SEC_RSP",
  U8  {"Cmd0", const=0x35},
  U8  {"Cmd1", const=0x02},
  U8  {"Status"},
  U8  {"DGPStubHandle"},
  U8  {"ApplicationId"},
  U32 {"SrcId"},
  arr {"GPDIEEEAddress", type=t_U8, length=8, reverse=true, ashex=true},
  U8  {"Endpoint"},
  U8  {"GPDFSecurityLevel"},
  U8  {"GPDFKeyType"},
  arr {"GPDKey", type=t_U8, length=16},
  U32 {"GPDSecurityFrameCounter"}
}
msg{"SRSP_GP_SEC_RSP",
  U8  {"Cmd0", const=0x75},
  U8  {"Cmd1", const=0x02},
  U8  {"Status"}
}

msg{"AREQ_GP_DATA_CNF",
  U8  {"Cmd0", const=0x55},
  U8  {"Cmd1", const=0x05},
  U8  {"Status"},
  U8  {"GPMPDUHandle"}
}

msg{"AREQ_GP_SEC_REQ",
  U8  {"Cmd0", const=0x55},
  U8  {"Cmd1", const=0x03}, -- docs say it is 0x5303
  U8  {"ApplicationId"},
  U32 {"SrcId"},
  arr {"GPDIEEEAddress", type=t_U8, length=8, reverse=true, ashex=true},
  U8  {"Endpoint"},
  U8  {"GPDFSecurityLevel"},
  U8  {"GPDFKeyType"},
  arr {"GPDSecurityFrameCounter", type=t_U8, length=1}, -- or length=4
  U8  {"DGPStubHandle"}
}

msg{"AREQ_GP_DATA_IND",
  U8  {"Cmd0", const=0x55},
  U8  {"Cmd1", const=0x04},
  U8  {"Status"},
  U8  {"RSSI"},
  U8  {"LinkQuality"},
  U8  {"SeqNumber"},
  U8  {"SrcAddrMode"},
  U8  {"SrcPanId"},
  arr {"SrcAddress", type=t_U8, length=2}, -- or length=8
  U8  {"DstAddrMode"},
  U8  {"DstPanId"},
  arr {"DstAddress", type=t_U8, length=2}, -- or length=8
  arr {"GPMPDU", type=t_U8, counter=t_U8}
}

end
