return require"lib.codec"(function()

local cmds={
  {"SREQ_AF_REGISTER", 0x2400, 0xFFFF},
  {"SRSP_AF_REGISTER", 0x6400, 0xFFFF},
  {"SREQ_AF_DATA_REQUEST", 0x2401, 0xFFFF},
  {"SRSP_AF_DATA_REQUEST", 0x6401, 0xFFFF},
  {"SREQ_AF_DATA_REQUEST_EXT", 0x2402, 0xFFFF},
  {"SRSP_AF_DATA_REQUEST_EXT", 0x6402, 0xFFFF},
  {"SREQ_AF_DATA_REQUEST_SRC_RTG", 0x2403, 0xFFFF},
  {"SRSP_AF_DATA_REQUEST_SRC_RTG", 0x6403, 0xFFFF},
  {"SREQ_AF_INTER_PAN_CTL_InterPanClr", 0x2410, 0xFFFF},
  {"SREQ_AF_INTER_PAN_CTL_InterPanSet", 0x2410, 0xFFFF},
  {"SREQ_AF_INTER_PAN_CTL_InterPanReg", 0x2410, 0xFFFF},
  {"SREQ_AF_INTER_PAN_CTL_InterPanChk", 0x2410, 0xFFFF},
  {"SRSP_AF_INTER_PAN_CTL", 0x6410, 0xFFFF},
  {"SREQ_AF_DATA_STORE", 0x2411, 0xFFFF},
  {"SRSP_AF_DATA_STORE", 0x6411, 0xFFFF},
  {"SREQ_AF_DATA_RETRIEVE", 0x2412, 0xFFFF},
  {"SRSP_AF_DATA_RETRIEVE", 0x6412, 0xFFFF},
  {"SREQ_AF_APSF_CONFIG_SET", 0x2413, 0xFFFF},
  {"SRSP_AF_DATA_STORE", 0x6413, 0xFFFF},
  {"AREQ_AF_DATA_CONFIRM", 0x4480, 0xFFFF},
  {"AREQ_AF_REFLECT_ERROR", 0x4483, 0xFFFF},
  {"AREQ_AF_INCOMING_MSG", 0x4481, 0xFFFF},
  {"AREQ_AF_INCOMING_MSG_EXT", 0x4482, 0xFFFF},
  {"SREQ_APP_MSG", 0x2900, 0xFFFF},
  {"SRSP_APP_MSG", 0x6900, 0xFFFF},
  {"SREQ_APP_USER_TEST", 0x2901, 0xFFFF},
  {"SRSP_APP_USER_TEST", 0x6901, 0xFFFF},
  {"SREQ_DEBUG_SET_THRESHOLD", 0x2800, 0xFFFF},
  {"SRSP_DEBUG_SET_THRESHOLD", 0x6800, 0xFFFF},
  {"AREQ_DEBUG_MSG", 0x4800, 0xFFFF},
  {"SREQ_MAC_RESET_REQ", 0x2201, 0xFFFF},
  {"SRSP_MAC_RESET_REQ", 0x6201, 0xFFFF},
  {"SREQ_MAC_INIT", 0x2202, 0xFFFF},
  {"SRSP_MAC_INIT", 0x6202, 0xFFFF},
  {"AREQ_ZB_SYSTEM_RESET", 0x4609, 0xFFFF},
  {"SREQ_ZB_START_REQUEST", 0x2600, 0xFFFF},
  {"SRSP_ZB_START_REQUEST", 0x6600, 0xFFFF},
  {"SREQ_ZB_PERMIT_JOINING_REQUEST", 0x2608, 0xFFFF},
  {"SRSP_ZB_PERMIT_JOINING_REQUEST", 0x6608, 0xFFFF},
  {"SREQ_ZB_BIND_DEVICE", 0x2601, 0xFFFF},
  {"SRSP_ZB_BIND_DEVICE", 0x6601, 0xFFFF},
  {"SREQ_ZB_ALLOW_BIND", 0x2602, 0xFFFF},
  {"SRSP_ZB_ALLOW_BIND", 0x6602, 0xFFFF},
  {"SREQ_ZB_SEND_DATA_REQUEST", 0x2603, 0xFFFF},
  {"SRSP_ZB_SEND_DATA_REQUEST", 0x6603, 0xFFFF},
  {"SREQ_ZB_READ_CONFIGURATION", 0x2604, 0xFFFF},
  {"SRSP_ZB_READ_CONFIGURATION", 0x6604, 0xFFFF},
  {"SREQ_ZB_WRITE_CONFIGURATION", 0x2605, 0xFFFF},
  {"SRSP_ZB_WRITE_CONFIGURATION", 0x6605, 0xFFFF},
  {"SREQ_ZB_GET_DEVICE_INFO", 0x2606, 0xFFFF},
  {"SRSP_ZB_GET_DEVICE_INFO", 0x6606, 0xFFFF},
  {"SREQ_ZB_FIND_DEVICE_REQUEST", 0x2607, 0xFFFF},
  {"SRSP_ZB_FIND_DEVICE_REQUEST", 0x6607, 0xFFFF},
  {"AREQ_ZB_START_CONFIRM", 0x4680, 0xFFFF},
  {"AREQ_ZB_BIND_CONFIRM", 0x4681, 0xFFFF},
  {"AREQ_ZB_ALLOW_BIND_CONFIRM", 0x4682, 0xFFFF},
  {"AREQ_ZB_SEND_DATA_CONFIRM", 0x4683, 0xFFFF},
  {"AREQ_ZB_RECEIVE_DATA_INDICATION", 0x4687, 0xFFFF},
  {"AREQ_ZB_FIND_DEVICE_CONFIRM", 0x4685, 0xFFFF},
  {"AREQ_SYS_RESET_REQ", 0x4100, 0xFFFF},
  {"SREQ_SYS_PING", 0x2101, 0xFFFF},
  {"SRSP_SYS_PING", 0x6101, 0xFFFF},
  {"SREQ_SYS_VERSION", 0x2102, 0xFFFF},
  {"SRSP_SYS_VERSION", 0x6102, 0xFFFF},
  {"SREQ_SYS_SET_EXTADDR", 0x2103, 0xFFFF},
  {"SRSP_SYS_SET_EXTADDR", 0x6103, 0xFFFF},
  {"SREQ_SYS_GET_EXTADDR", 0x2104, 0xFFFF},
  {"SRSP_SYS_GET_EXTADDR", 0x6104, 0xFFFF},
  {"SREQ_SYS_RAM_READ", 0x2105, 0xFFFF},
  {"SRSP_SYS_RAM_READ", 0x6105, 0xFFFF},
  {"SREQ_SYS_RAM_WRITE", 0x2106, 0xFFFF},
  {"SRSP_SYS_RAM_WRITE", 0x6106, 0xFFFF},
  {"SREQ_SYS_OSAL_NV_READ", 0x2108, 0xFFFF},
  {"SRSP_SYS_OSAL_NV_READ", 0x6108, 0xFFFF},
  {"SREQ_SYS_OSAL_NV_WRITE", 0x2109, 0xFFFF},
  {"SRSP_SYS_OSAL_NV_WRITE", 0x6109, 0xFFFF},
  {"SREQ_SYS_OSAL_NV_ITEM_INIT", 0x2107, 0xFFFF},
  {"SRSP_SYS_OSAL_NV_ITEM_INIT", 0x6107, 0xFFFF},
  {"SREQ_SYS_OSAL_NV_DELETE", 0x2112, 0xFFFF},
  {"SRSP_SYS_OSAL_NV_DELETE", 0x6112, 0xFFFF},
  {"SREQ_SYS_OSAL_NV_LENGTH", 0x2113, 0xFFFF},
  {"SRSP_SYS_OSAL_NV_LENGTH", 0x6113, 0xFFFF},
  {"SREQ_SYS_OSAL_START_TIMER", 0x210A, 0xFFFF},
  {"SRSP_SYS_OSAL_START_TIMER", 0x610A, 0xFFFF},
  {"SREQ_SYS_OSAL_STOP_TIMER", 0x210B, 0xFFFF},
  {"SRSP_SYS_OSAL_STOP_TIMER", 0x610B, 0xFFFF},
  {"SREQ_SYS_RANDOM", 0x210C, 0xFFFF},
  {"SRSP_SYS_RANDOM", 0x610C, 0xFFFF},
  {"SREQ_SYS_ADC_READ", 0x210D, 0xFFFF},
  {"SRSP_SYS_ADC_READ", 0x610D, 0xFFFF},
  {"SREQ_SYS_GPIO", 0x210E, 0xFFFF},
  {"SRSP_SYS_GPIO", 0x610E, 0xFFFF},
  {"SREQ_SYS_STACK_TUNE", 0x210F, 0xFFFF},
  {"SRSP_SYS_STACK_TUNE", 0x610F, 0xFFFF},
  {"SREQ_SYS_SET_TIME", 0x2110, 0xFFFF},
  {"SRSP_SYS_SET_TIME", 0x6110, 0xFFFF},
  {"SREQ_SYS_GET_TIME", 0x2111, 0xFFFF},
  {"SRSP_SYS_GET_TIME", 0x6111, 0xFFFF},
  {"SREQ_SYS_SET_TX_POWER", 0x2114, 0xFFFF},
  {"SRSP_SYS_SET_TX_POWER", 0x6114, 0xFFFF},
  {"SREQ_SYS_ZDIAGS_INIT_STATS", 0x2117, 0xFFFF},
  {"SRSP_SYS_ZDIAGS_INIT_STATS", 0x6117, 0xFFFF},
  {"SREQ_SYS_ZDIAGS_CLEAR_STATS", 0x2118, 0xFFFF},
  {"SRSP_SYS_ZDIAGS_CLEAR_STATS", 0x6118, 0xFFFF},
  {"SREQ_SYS_ZDIAGS_GET_STATS", 0x2119, 0xFFFF},
  {"SRSP_SYS_ZDIAGS_GET_STATS", 0x6119, 0xFFFF},
  {"SREQ_SYS_ZDIAGS_RESTORE_STATS_NV", 0x211A, 0xFFFF},
  {"SRSP_SYS_ZDIAGS_RESTORE_STATS_NV", 0x611A, 0xFFFF},
  {"SREQ_SYS_ZDIAGS_SAFE_STATS_TO_NV", 0x211B, 0xFFFF},
  {"SRSP_SYS_ZDIAGS_SAFE_STATS_TO_NV", 0x611B, 0xFFFF},
  {"SREQ_SYS_NV_CREATE", 0x2130, 0xFFFF},
  {"SRSP_SYS_NV_CREATE", 0x6130, 0xFFFF},
  {"SREQ_SYS_NV_DELETE", 0x2131, 0xFFFF},
  {"SRSP_SYS_NV_DELETE", 0x6131, 0xFFFF},
  {"SREQ_SYS_NV_LENGTH", 0x2132, 0xFFFF},
  {"SRSP_SYS_NV_LENGTH", 0x6132, 0xFFFF},
  {"SREQ_SYS_NV_READ", 0x2133, 0xFFFF},
  {"SRSP_SYS_NV_READ", 0x6133, 0xFFFF},
  {"SREQ_SYS_NV_WRITE", 0x2134, 0xFFFF},
  {"SRSP_SYS_NV_WRITE", 0x6134, 0xFFFF},
  {"SREQ_SYS_NV_UPDATE", 0x2135, 0xFFFF},
  {"SRSP_SYS_NV_UPDATE", 0x6135, 0xFFFF},
  {"SREQ_SYS_NV_COMPACT", 0x2136, 0xFFFF},
  {"SRSP_SYS_NV_COMPACT", 0x6136, 0xFFFF},
  {"SREQ_SYS_OSAL_NV_READ_EXT", 0x2108, 0xFFFF},
  {"SRSP_SYS_OSAL_NV_READ_EXT", 0x6108, 0xFFFF},
  {"SREQ_SYS_OSAL_NV_WRITE_EXT", 0x2109, 0xFFFF},
  {"SRSP_SYS_OSAL_NV_WRITE_EXT", 0x6109, 0xFFFF},
  {"AREQ_SYS_RESET_IND", 0x4180, 0xFFFF},
  {"AREQ_SYS_OSAL_TIMER_EXPIRED", 0x4181, 0xFFFF},
  {"SREQ_UTIL_GET_DEVICE_INFO", 0x2700, 0xFFFF},
  {"SRSP_UTIL_GET_DEVICE_INFO", 0x6700, 0xFFFF},
  {"SREQ_UTIL_GET_NV_INFO", 0x2701, 0xFFFF},
  {"SRSP_UTIL_GET_NV_INFO", 0x6701, 0xFFFF},
  {"SREQ_UTIL_SET_PANID", 0x2702, 0xFFFF},
  {"SRSP_UTIL_SET_PANID", 0x6702, 0xFFFF},
  {"SREQ_UTIL_SET_CHANNELS", 0x2703, 0xFFFF},
  {"SRSP_UTIL_SET_CHANNELS", 0x6703, 0xFFFF},
  {"SREQ_UTIL_SET_SECLEVEL", 0x2704, 0xFFFF},
  {"SRSP_UTIL_SET_SECLEVEL", 0x6704, 0xFFFF},
  {"SREQ_UTIL_SET_PRECFGKEY", 0x2705, 0xFFFF},
  {"SRSP_UTIL_SET_PRECFGKEY", 0x6705, 0xFFFF},
  {"SREQ_UTIL_CALLBACK_SUB_CMD", 0x2706, 0xFFFF},
  {"SRSP_UTIL_CALLBACK_SUB_CMD", 0x6706, 0xFFFF},
  {"SREQ_UTIL_KEY_EVENT", 0x2707, 0xFFFF},
  {"SRSP_UTIL_KEY_EVENT", 0x6707, 0xFFFF},
  {"SREQ_UTIL_TIME_ALIVE", 0x2709, 0xFFFF},
  {"SRSP_UTIL_TIME_ALIVE", 0x6709, 0xFFFF},
  {"SREQ_UTIL_LED_CONTROL", 0x270A, 0xFFFF},
  {"SRSP_UTIL_LED_CONTROL", 0x670A, 0xFFFF},
  {"SREQ_UTIL_LOOPBACK", 0x2710, 0xFFFF},
  {"SRSP_UTIL_LOOPBACK", 0x6710, 0xFFFF},
  {"SREQ_UTIL_DATA_REQ", 0x2711, 0xFFFF},
  {"SRSP_UTIL_DATA_REQ", 0x6711, 0xFFFF},
  {"SREQ_UTIL_SRC_MATCH_ENABLE", 0x2720, 0xFFFF},
  {"SRSP_UTIL_SRC_MATCH_ENABLE", 0x6720, 0xFFFF},
  {"SREQ_UTIL_SRC_MATCH_ADD_ENTRY", 0x2721, 0xFFFF},
  {"SRSP_UTIL_SRC_MATCH_ADD_ENTRY", 0x6721, 0xFFFF},
  {"SREQ_UTIL_SRC_MATCH_DEL_ENTRY", 0x2722, 0xFFFF},
  {"SRSP_UTIL_SRC_MATCH_DEL_ENTRY", 0x6722, 0xFFFF},
  {"SREQ_UTIL_SRC_MATCH_CHECK_SRC_ADDR", 0x2723, 0xFFFF},
  {"SRSP_UTIL_SRC_MATCH_CHECK_SRC_ADDR", 0x6723, 0xFFFF},
  {"SREQ_UTIL_SRC_MATCH_ACK_ALL_PENDING", 0x2724, 0xFFFF},
  {"SRSP_UTIL_SRC_MATCH_ACK_ALL_PENDING", 0x6724, 0xFFFF},
  {"SREQ_UTIL_SRC_MATCH_CHECK_ALL_PENDING", 0x2725, 0xFFFF},
  {"SRSP_UTIL_SRC_MATCH_CHECK_ALL_PENDING", 0x6725, 0xFFFF},
  {"SREQ_UTIL_ADDRMGR_EXT_ADDR_LOOKUP", 0x2740, 0xFFFF},
  {"SRSP_UTIL_ADDRMGR_EXT_ADDR_LOOKUP", 0x6740, 0xFFFF},
  {"SREQ_UTIL_ADDRMGR_NWK_ADDR_LOOKUP", 0x2741, 0xFFFF},
  {"SRSP_UTIL_ADDRMGR_NWK_ADDR_LOOKUP", 0x6741, 0xFFFF},
  {"SREQ_UTIL_APSME_LINK_KEY_DATA_GET", 0x2744, 0xFFFF},
  {"SRSP_UTIL_APSME_LINK_KEY_DATA_GET", 0x6744, 0xFFFF},
  {"SREQ_UTIL_APSME_LINK_KEY_NV_ID_GET", 0x2745, 0xFFFF},
  {"SRSP_UTIL_APSME_LINK_KEY_NV_ID_GET", 0x6745, 0xFFFF},
  {"SREQ_UTIL_APSME_REQUEST_KEY_CMD", 0x274B, 0xFFFF},
  {"SRSP_UTIL_APSME_REQUEST_KEY_CMD", 0x674B, 0xFFFF},
  {"SREQ_UTIL_ASSOC_COUNT", 0x2748, 0xFFFF},
  {"SRSP_UTIL_ASSOC_COUNT", 0x6748, 0xFFFF},
  {"SREQ_UTIL_ASSOC_FIND_DEVICE", 0x2749, 0xFFFF},
  {"SRSP_UTIL_ASSOC_FIND_DEVICE", 0x6749, 0xFFFF},
  {"SREQ_UTIL_ASSOC_GET_WITH_ADDRESS", 0x274A, 0xFFFF},
  {"SRSP_UTIL_ASSOC_GET_WITH_ADDRESS", 0x674A, 0xFFFF},
  {"SREQ_UTIL_BIND_ADD_ENTRY", 0x274D, 0xFFFF},
  {"SRSP_UTIL_BIND_ADD_ENTRY", 0x674D, 0xFFFF},
  {"SREQ_UTIL_ZCL_KEY_EST_INIT_EST", 0x2780, 0xFFFF},
  {"SRSP_UTIL_ZCL_KEY_EST_INIT_EST", 0x6780, 0xFFFF},
  {"SREQ_UTIL_ZCL_KEY_EST_SIGN", 0x2781, 0xFFFF},
  {"SRSP_UTIL_ZCL_KEY_EST_SIGN", 0x6781, 0xFFFF},
  {"SREQ_UTIL_SRNG_GEN", 0x274C, 0xFFFF},
  {"SRSP_UTIL_SRNG_GEN", 0x674C, 0xFFFF},
  {"AREQ_UTIL_SYNC_REQ", 0x47E0, 0xFFFF},
  {"AREQ_UTIL_ZCL_KEY_ESTABLISH_IND", 0x47E1, 0xFFFF},
  {"SREQ_ZDO_NWK_ADDR_REQ", 0x2500, 0xFFFF},
  {"SRSP_ZDO_NWK_ADDR_REQ", 0x6500, 0xFFFF},
  {"SREQ_ZDO_IEEE_ADDR_REQ", 0x2501, 0xFFFF},
  {"SRSP_ZDO_IEEE_ADDR_REQ", 0x6501, 0xFFFF},
  {"SREQ_ZDO_NODE_DESC_REQ", 0x2502, 0xFFFF},
  {"SRSP_ZDO_NODE_DESC_REQ", 0x6502, 0xFFFF},
  {"SREQ_ZDO_POWER_DESC_REQ", 0x2503, 0xFFFF},
  {"SRSP_ZDO_POWER_DESC_REQ", 0x6503, 0xFFFF},
  {"SREQ_ZDO_SIMPLE_DESC_REQ", 0x2504, 0xFFFF},
  {"SRSP_ZDO_SIMPLE_DESC_REQ", 0x6504, 0xFFFF},
  {"SREQ_ZDO_ACTIVE_EP_REQ", 0x2505, 0xFFFF},
  {"SRSP_ZDO_ACTIVE_EP_REQ", 0x6505, 0xFFFF},
  {"SREQ_ZDO_MATCH_DESC_REQ", 0x2506, 0xFFFF},
  {"SRSP_ZDO_MATCH_DESC_REQ", 0x6506, 0xFFFF},
  {"SREQ_ZDO_COMPLEX_DESC_REQ", 0x2507, 0xFFFF},
  {"SRSP_ZDO_COMPLEX_DESC_REQ", 0x6507, 0xFFFF},
  {"SREQ_ZDO_USER_DESC_REQ", 0x2508, 0xFFFF},
  {"SRSP_ZDO_USER_DESC_REQ", 0x6508, 0xFFFF},
  {"SREQ_ZDO_END_DEVICE_ANNCE", 0x250A, 0xFFFF},
  {"SRSP_ZDO_END_DEVICE_ANNCE", 0x650A, 0xFFFF},
  {"SREQ_ZDO_USER_DESC_SET", 0x250B, 0xFFFF},
  {"SRSP_ZDO_USER_DESC_SET", 0x650B, 0xFFFF},
  {"SREQ_ZDO_SERVER_DISC_REQ", 0x250C, 0xFFFF},
  {"SRSP_ZDO_SERVER_DISC_REQ", 0x650C, 0xFFFF},
  {"SREQ_ZDO_END_DEVICE_BIND_REQ", 0x2520, 0xFFFF},
  {"SRSP_ZDO_END_DEVICE_BIND_REQ", 0x6520, 0xFFFF},
  {"SREQ_ZDO_BIND_REQ", 0x2521, 0xFFFF},
  {"SRSP_ZDO_BIND_REQ", 0x6521, 0xFFFF},
  {"SREQ_ZDO_UNBIND_REQ", 0x2522, 0xFFFF},
  {"SRSP_ZDO_UNBIND_REQ", 0x6522, 0xFFFF},
  {"SREQ_ZDO_MGMT_NWK_DISC_REQ", 0x2530, 0xFFFF},
  {"SRSP_ZDO_MGMT_NWK_DISC_REQ", 0x6530, 0xFFFF},
  {"SREQ_ZDO_MGMT_LQI_REQ", 0x2531, 0xFFFF},
  {"SRSP_ZDO_MGMT_LQI_REQ", 0x6531, 0xFFFF},
  {"SREQ_ZDO_MGMT_RTG_REQ", 0x2532, 0xFFFF},
  {"SRSP_ZDO_MGMT_RTG_REQ", 0x6532, 0xFFFF},
  {"SREQ_ZDO_MGMT_BIND_REQ", 0x2533, 0xFFFF},
  {"SRSP_ZDO_MGMT_BIND_REQ", 0x6533, 0xFFFF},
  {"SREQ_ZDO_MGMT_LEAVE_REQ", 0x2534, 0xFFFF},
  {"SRSP_ZDO_MGMT_LEAVE_REQ", 0x6534, 0xFFFF},
  {"SREQ_ZDO_MGMT_DIRECT_JOIN_REQ", 0x2535, 0xFFFF},
  {"SRSP_ZDO_MGMT_DIRECT_JOIN_REQ", 0x6535, 0xFFFF},
  {"SREQ_ZDO_MGMT_PERMIT_JOIN_REQ", 0x2536, 0xFFFF},
  {"SRSP_ZDO_MGMT_PERMIT_JOIN_REQ", 0x6536, 0xFFFF},
  {"SREQ_ZDO_MGMT_NWK_UPDATE_REQ", 0x2537, 0xFFFF},
  {"SRSP_ZDO_MGMT_NWK_UPDATE_REQ", 0x6537, 0xFFFF},
  {"SREQ_ZDO_MSG_CB_REGISTER", 0x253E, 0xFFFF},
  {"SRSP_ZDO_MSG_CB_REGISTER", 0x653E, 0xFFFF},
  {"SREQ_ZDO_MSG_CB_REMOVE", 0x253F, 0xFFFF},
  {"SRSP_ZDO_MSG_CB_REMOVE", 0x653F, 0xFFFF},
  {"SREQ_ZDO_STARTUP_FROM_APP", 0x2540, 0xFFFF},
  {"SRSP_ZDO_STARTUP_FROM_APP", 0x6540, 0xFFFF},
  {"SREQ_ZDO_STARTUP_FROM_APP_EX", 0x2554, 0xFFFF},
  {"SRSP_ZDO_STARTUP_FROM_APP_EX", 0x6554, 0xFFFF},
  {"SREQ_ZDO_SET_LINK_KEY", 0x2523, 0xFFFF},
  {"SRSP_ZDO_SET_LINK_KEY", 0x6523, 0xFFFF},
  {"SREQ_ZDO_REMOVE_LINK_KEY", 0x2524, 0xFFFF},
  {"SRSP_ZDO_REMOVE_LINK_KEY", 0x6524, 0xFFFF},
  {"SREQ_ZDO_GET_LINK_KEY", 0x2525, 0xFFFF},
  {"SRSP_ZDO_GET_LINK_KEY", 0x6525, 0xFFFF},
  {"SREQ_ZDO_NWK_DISCOVERY_REQ", 0x2526, 0xFFFF},
  {"SRSP_ZDO_NWK_DISCOVERY_REQ", 0x6526, 0xFFFF},
  {"SREQ_ZDO_JOIN_REQ", 0x2527, 0xFFFF},
  {"SRSP_ZDO_JOIN_REQ", 0x6527, 0xFFFF},
  {"SREQ_ZDO_SET_REJOIN_PARAMETERS", 0x25CC, 0xFFFF},
  {"SRSP_ZDO_SET_REJOIN_PARAMETERS", 0x65CC, 0xFFFF},
  {"SREQ_ZDO_SEC_ADD_LINK_KEY", 0x2542, 0xFFFF},
  {"SRSP_ZDO_SEC_ADD_LINK_KEY", 0x6542, 0xFFFF},
  {"SREQ_ZDO_SEC_ENTRY_LOOKUP_EXT", 0x2543, 0xFFFF},
  {"SRSP_ZDO_SEC_ENTRY_LOOKUP_EXT", 0x6543, 0xFFFF},
  {"SREQ_ZDO_SEC_DEVICE_REMOVE", 0x2544, 0xFFFF},
  {"SRSP_ZDO_SEC_DEVICE_REMOVE", 0x6544, 0xFFFF},
  {"SREQ_ZDO_EXT_ROUTE_DISC", 0x2545, 0xFFFF},
  {"SRSP_ZDO_EXT_ROUTE_DISC", 0x6545, 0xFFFF},
  {"SREQ_ZDO_EXT_ROUTE_CHECK", 0x2546, 0xFFFF},
  {"SRSP_ZDO_EXT_ROUTE_CHECK", 0x6546, 0xFFFF},
  {"SREQ_ZDO_EXT_REMOVE_GROUP", 0x2547, 0xFFFF},
  {"SRSP_ZDO_EXT_REMOVE_GROUP", 0x6547, 0xFFFF},
  {"SREQ_ZDO_EXT_REMOVE_ALL_GROUP", 0x2548, 0xFFFF},
  {"SRSP_ZDO_EXT_REMOVE_ALL_GROUP", 0x6548, 0xFFFF},
  {"SREQ_ZDO_EXT_FIND_ALL_GROUPS_ENDPOINT", 0x2549, 0xFFFF},
  {"SRSP_ZDO_EXT_FIND_ALL_GROUPS_ENDPOINT", 0x6549, 0xFFFF},
  {"SREQ_ZDO_EXT_FIND_GROUP", 0x254A, 0xFFFF},
  {"SRSP_ZDO_EXT_FIND_GROUP", 0x654A, 0xFFFF},
  {"SREQ_ZDO_EXT_ADD_GROUP", 0x254B, 0xFFFF},
  {"SRSP_ZDO_EXT_ADD_GROUP", 0x654B, 0xFFFF},
  {"SREQ_ZDO_EXT_COUNT_ALL_GROUPS", 0x254C, 0xFFFF},
  {"SRSP_ZDO_EXT_COUNT_ALL_GROUPS", 0x654C, 0xFFFF},
  {"SREQ_ZDO_EXT_RX_IDLE", 0x254D, 0xFFFF},
  {"SRSP_ZDO_EXT_RX_IDLE", 0x654D, 0xFFFF},
  {"SREQ_ZDO_EXT_UPDATE_NWK_KEY", 0x254E, 0xFFFF},
  {"SRSP_ZDO_EXT_UPDATE_NWK_KEY", 0x654E, 0xFFFF},
  {"SREQ_ZDO_EXT_SWITCH_NWK_KEY", 0x254F, 0xFFFF},
  {"SRSP_ZDO_EXT_SWITCH_NWK_KEY", 0x654F, 0xFFFF},
  {"SREQ_ZDO_EXT_NWK_INFO", 0x2550, 0xFFFF},
  {"SRSP_ZDO_EXT_NWK_INFO", 0x6550, 0xFFFF},
  {"SREQ_ZDO_EXT_SEC_APS_REMOVE_REQ", 0x2551, 0xFFFF},
  {"SRSP_ZDO_EXT_SEC_APS_REMOVE_REQ", 0x6551, 0xFFFF},
  {"SREQ_ZDO_FORCE_CONCENTRATOR_CHANGE", 0x2552, 0xFFFF},
  {"SRSP_ZDO_FORCE_CONCENTRATOR_CHANGE", 0x6552, 0xFFFF},
  {"SREQ_ZDO_EXT_SET_PARAMS", 0x2553, 0xFFFF},
  {"SRSP_ZDO_EXT_SET_PARAMS", 0x6553, 0xFFFF},
  {"SREQ_ZDO_NWK_ADDR_OF_INTEREST_REQ", 0x2529, 0xFFFF},
  {"SRSP_ZDO_NWK_ADDR_OF_INTEREST_REQ", 0x6529, 0xFFFF},
  {"AREQ_ZDO_NWK_ADDR_RSP", 0x4580, 0xFFFF},
  {"AREQ_ZDO_IEEE_ADDR_RSP", 0x4581, 0xFFFF},
  {"AREQ_ZDO_NODE_DESC_RSP", 0x4582, 0xFFFF},
  {"AREQ_ZDO_POWER_DESC_RSP", 0x4583, 0xFFFF},
  {"AREQ_ZDO_SIMPLE_DESC_RSP", 0x4584, 0xFFFF},
  {"AREQ_ZDO_ACTIVE_EP_RSP", 0x4585, 0xFFFF},
  {"AREQ_ZDO_MATCH_DESC_RSP", 0x4586, 0xFFFF},
  {"AREQ_ZDO_COMPLEX_DESC_RSP", 0x4587, 0xFFFF},
  {"AREQ_ZDO_USER_DESC_RSP", 0x4588, 0xFFFF},
  {"AREQ_ZDO_USER_DESC_CONF", 0x4589, 0xFFFF},
  {"AREQ_ZDO_SERVER_DISC_RSP", 0x458A, 0xFFFF},
  {"AREQ_ZDO_END_DEVICE_BIND_RSP", 0x45A0, 0xFFFF},
  {"AREQ_ZDO_BIND_RSP", 0x45A1, 0xFFFF},
  {"AREQ_ZDO_UNBIND_RSP", 0x45A2, 0xFFFF},
  {"AREQ_ZDO_MGMT_NWK_DISC_RSP", 0x45B0, 0xFFFF},
  {"AREQ_ZDO_MGMT_LQI_RSP", 0x45B1, 0xFFFF},
  {"AREQ_ZDO_MGMT_RTG_RSP", 0x45B2, 0xFFFF},
  {"AREQ_ZDO_MGMT_BIND_RSP", 0x45B3, 0xFFFF},
  {"AREQ_ZDO_MGMT_LEAVE_RSP", 0x45B4, 0xFFFF},
  {"AREQ_ZDO_MGMT_DIRECT_JOIN_RSP", 0x45B5, 0xFFFF},
  {"AREQ_ZDO_MGMT_PERMIT_JOIN_RSP", 0x45B6, 0xFFFF},
  {"AREQ_ZDO_STATE_CHANGE_IND", 0x45C0, 0xFFFF},
  {"AREQ_ZDO_END_DEVICE_ANNCE_IND", 0x45C1, 0xFFFF},
  {"AREQ_ZDO_MATCH_DESC_RSP_SENT", 0x45C2, 0xFFFF},
  {"AREQ_ZDO_STATUS_ERROR_RSP", 0x45C3, 0xFFFF},
  {"AREQ_ZDO_SRC_RTG_IND", 0x45C4, 0xFFFF},
  {"AREQ_ZDO_BEACON_NOTIFY_IND", 0x45C5, 0xFFFF},
  {"AREQ_ZDO_JOIN_CNF", 0x45C6, 0xFFFF},
  {"AREQ_ZDO_NWK_DISCOVERY_CNF", 0x45C7, 0xFFFF},
  {"AREQ_ZDO_LEAVE_IND", 0x45C9, 0xFFFF},
  {"AREQ_ZDO_MSG_CB_INCOMING", 0x45FF, 0xFFFF},
  {"AREQ_ZDO_TC_DEV_IND", 0x45CA, 0xFFFF},
  {"AREQ_ZDO_PERMIT_JOIN_IND", 0x45CB, 0xFFFF},
  {"SREQ_APP_CNF_SET_NWK_FRAME_COUNTER", 0x2FFF, 0xFFFF},
  {"SRSP_APP_CNF_SET_NWK_FRAME_COUNTER", 0x6FFF, 0xFFFF},
  {"SREQ_APP_CNF_SET_DEFAULT_REMOTE_ENDDEVICE_TIMEOUT", 0x2F01, 0xFFFF},
  {"SRSP_APP_CNF_SET_DEFAULT_REMOTE_ENDDEVICE_TIMEOUT", 0x6F01, 0xFFFF},
  {"SREQ_APP_CNF_SET_ENDDEVICETIMEOUT", 0x2F02, 0xFFFF},
  {"SRSP_APP_CNF_SET_ENDDEVICETIMEOUT", 0x6F02, 0xFFFF},
  {"SREQ_APP_CNF_SET_ALLOWREJOIN_TC_POLICY", 0x2F03, 0xFFFF},
  {"SRSP_APP_CNF_SET_ALLOWREJOIN_TC_POLICY", 0x6F03, 0xFFFF},
  {"SREQ_APP_CNF_BDB_START_COMMISSIONING", 0x2F05, 0xFFFF},
  {"SRSP_APP_CNF_BDB_START_COMMISSIONING", 0x6F05, 0xFFFF},
  {"SREQ_APP_CNF_BDB_SET_CHANNEL", 0x2F08, 0xFFFF},
  {"SRSP_APP_CNF_BDB_SET_CHANNEL", 0x6F08, 0xFFFF},
  {"SREQ_APP_CNF_BDB_ADD_INSTALLCODE_installcode_crc", 0x2F04, 0xFFFF},
  {"SREQ_APP_CNF_BDB_ADD_INSTALLCODE_derived_key", 0x2F04, 0xFFFF},
  {"SRSP_APP_CNF_BDB_ADD_INSTALLCODE", 0x6F04, 0xFFFF},
  {"SREQ_APP_CNF_BDB_SET_TC_REQUIRE_KEY_EXCHANGE", 0x2F09, 0xFFFF},
  {"SRSP_APP_CNF_BDB_SET_TC_REQUIRE_KEY_EXCHANGE", 0x6F09, 0xFFFF},
  {"SREQ_APP_CNF_BDB_SET_JOINUSESINSTALLCODEKEY", 0x2F06, 0xFFFF},
  {"SRSP_APP_CNF_BDB_SET_JOINUSESINSTALLCODEKEY", 0x6F06, 0xFFFF},
  {"SREQ_APP_CNF_BDB_SET_ACTIVE_DEFAULT_CENTRALIZED_KEY", 0x2F07, 0xFFFF},
  {"SRSP_APP_CNF_BDB_SET_ACTIVE_DEFAULT_CENTRALIZED_KEY", 0x6F07, 0xFFFF},
  {"SREQ_APP_CNF_BDB_ZED_ATTEMPT_RECOVER_NWK", 0x2F0A, 0xFFFF},
  {"SRSP_APP_CNF_BDB_ZED_ATTEMPT_RECOVER_NWK", 0x6F0A, 0xFFFF},
  {"AREQ_APP_CNF_BDB_COMMISSIONING_NOTIFICATION", 0x4F80, 0xFFFF},
  {"SREQ_GP_DATA_REQ", 0x3501, 0xFFFF},
  {"SRSP_GP_DATA_REQ", 0x7501, 0xFFFF},
  {"SREQ_GP_SEC_RSP", 0x3502, 0xFFFF},
  {"SRSP_GP_SEC_RSP", 0x7502, 0xFFFF},
  {"AREQ_GP_DATA_CNF", 0x5505, 0xFFFF},
  {"AREQ_GP_SEC_REQ", 0x5503, 0xFFFF},
  {"AREQ_GP_DATA_IND", 0x5504, 0xFFFF}
}
local function allcmds()
  local msgs = {}
  for i, c in ipairs(cmds) do
    msgs[i] = opt{nil, when=function(v) return v.Cmd==c[1] end, msg{ref=c[1]}}
  end
  return unpack(msgs)
end
msg{"ZNP",
  map{"Cmd", type=t_U16r, values=cmds},
  allcmds()
}

-- MT_AF:

msg{"SREQ_AF_REGISTER",
  U8  {"EndPoint"},
  U16 {"AppProfId"},
  U16 {"AppDeviceId"},
  U8  {"AddDevVer"},
  map {"LatencyReq", type=t_U8, values={"NoLatency", "FastBeacons", "SlowBeacons"}},
  arr {"AppInClusterList", type=t_U16, counter=t_U8},
  arr {"AppOutClusterList", type=t_U16, counter=t_U8}
}
msg{"SRSP_AF_REGISTER",
  U8  {"Status"}
}

msg{"SREQ_AF_DATA_REQUEST",
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
  U8  {"Status"}
}

msg{"SREQ_AF_DATA_REQUEST_EXT",
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
  U8  {"Status"}
}

msg{"SREQ_AF_DATA_REQUEST_SRC_RTG",
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
  U8  {"Status"}
}

msg{"SREQ_AF_INTER_PAN_CTL_InterPanClr",
  U8  {"InterPanClr", const=0}
}
msg{"SREQ_AF_INTER_PAN_CTL_InterPanSet",
  U8  {"InterPanSet", const=1},
  U8  {"Channel"}
}
msg{"SREQ_AF_INTER_PAN_CTL_InterPanReg",
  U8  {"InterPanReg", const=2},
  U8  {"Endpoint"}
}
msg{"SREQ_AF_INTER_PAN_CTL_InterPanChk",
  U8  {"InterPanClr", const=3},
  U16 {"PanId"},
  U8  {"Endpoint"}
}
msg{"SRSP_AF_INTER_PAN_CTL",
  U8  {"Status"}
}

msg{"SREQ_AF_DATA_STORE",
  U16 {"Index"},
  arr {"Data", type=t_U8, counter=t_U8}
}
msg{"SRSP_AF_DATA_STORE",
  U8  {"Status"}
}

msg{"SREQ_AF_DATA_RETRIEVE",
  U32 {"Timestamp"},
  U16 {"Index"},
  U8  {"Length"}
}
msg{"SRSP_AF_DATA_RETRIEVE",
  U8  {"Status"},
  arr {"Data", type=t_U8, counter=t_U8}
}

msg{"SREQ_AF_APSF_CONFIG_SET",
  U8  {"Endpoint"},
  U8  {"FrameDelay"},
  U8  {"WindowSize"}
}
msg{"SRSP_AF_DATA_STORE",
  U8  {"Status"}
}

msg{"AREQ_AF_DATA_CONFIRM",
  U8  {"Status"},
  U8  {"Endpoint"},
  U8  {"TransId"}
}
msg{"AREQ_AF_REFLECT_ERROR",
  U8  {"Status"},
  U8  {"Endpoint"},
  U8  {"TransId"},
  U8  {"DstAddrMode"},
  U16 {"DstAddr"}
}
msg{"AREQ_AF_INCOMING_MSG",
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
  U8  {"AppEndpoint"},
  U16 {"DestAddress"},
  U8  {"DestEndpoint"},
  U16 {"ClusterId"},
  arr {"Message", type=t_U8, counter=t_U8}
}
msg{"SRSP_APP_MSG",
  U8  {"Status"}
}

msg{"SREQ_APP_USER_TEST",
  U8  {"SrcEP"},
  U16 {"CommandId"},
  U16 {"Parameter1", default=0},
  U16 {"Parameter2", default=0}
}
msg{"SRSP_APP_USER_TEST",
  U8  {"Status"}
}

-- MT_DEBUG:

msg{"SREQ_DEBUG_SET_THRESHOLD",
  U8  {"ComponentId"},
  U8  {"Threshold"}
}
msg{"SRSP_DEBUG_SET_THRESHOLD",
  U8  {"Status"}
}

msg{"AREQ_DEBUG_MSG",
  arr {"Message", type=t_U8, counter=t_U8, asstring=true}
}
  
-- MT_MAC:

msg{"SREQ_MAC_RESET_REQ",
  U8  {"SetDefault", default=0},
}
msg{"SRSP_MAC_RESET_REQ",
  U8  {"Status"}
}

msg{"SREQ_MAC_INIT"}
msg{"SRSP_MAC_INIT",
  U8  {"Status"}
}

-- to be continued...


-- MT_SAPI:

msg{"AREQ_ZB_SYSTEM_RESET"}
msg{"SREQ_ZB_START_REQUEST"}
msg{"SRSP_ZB_START_REQUEST"}

msg{"SREQ_ZB_PERMIT_JOINING_REQUEST",
  U16 {"Destination", default=0xFFFC},
  U8  {"Timeout", default=0}
}
msg{"SRSP_ZB_PERMIT_JOINING_REQUEST",
  U8  {"Status"}
}

msg{"SREQ_ZB_BIND_DEVICE",
  U8  {"Create", default=1},
  U16 {"CommandId"},
  arr {"Destination", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_ZB_BIND_DEVICE",
}

msg{"SREQ_ZB_ALLOW_BIND",
  U8  {"Timeout", default=0}
}
msg{"SRSP_ZB_ALLOW_BIND",
}

msg{"SREQ_ZB_SEND_DATA_REQUEST",
  U16 {"Destination"},
  U16 {"CommandId"},
  U8  {"Handle"},
  U8  {"Ack"},
  U8  {"Radius"},
  arr {"Data", type=t_U8, counter=t_U8}
}
msg{"SRSP_ZB_SEND_DATA_REQUEST",
}

msg{"SREQ_ZB_READ_CONFIGURATION",
  U8  {"ConfigId"}
}
msg{"SRSP_ZB_READ_CONFIGURATION",
  U8  {"Status"},
  U8  {"ConfigId"},
  arr {"Value", type=t_U8, counter=t_U8}
}

msg{"SREQ_ZB_WRITE_CONFIGURATION",
  U8  {"ConfigId"},
  arr {"Value", type=t_U8, counter=t_U8}
}
msg{"SRSP_ZB_WRITE_CONFIGURATION",
  U8  {"Status"}
}

msg{"SREQ_ZB_GET_DEVICE_INFO",
  U8  {"Param"}
}
msg{"SRSP_ZB_GET_DEVICE_INFO",
  U8  {"Param"},
  U16 {"Value"}
}

msg{"SREQ_ZB_FIND_DEVICE_REQUEST",
  arr {"SearchKey", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_ZB_FIND_DEVICE_REQUEST"}

msg{"AREQ_ZB_START_CONFIRM",
  U8  {"Status"}
}
msg{"AREQ_ZB_BIND_CONFIRM",
  U16 {"CommandId"},
  U8  {"Status"}
}
msg{"AREQ_ZB_ALLOW_BIND_CONFIRM",
  U16 {"Source"}
}
msg{"AREQ_ZB_SEND_DATA_CONFIRM",
  U8  {"Handle"},
  U8  {"Status"}
}
msg{"AREQ_ZB_RECEIVE_DATA_INDICATION",
  U16 {"Source"},
  U16 {"Command"},
  arr {"Value", type=t_U8, counter=t_U16}
}
msg{"AREQ_ZB_FIND_DEVICE_CONFIRM",
  U8  {"SearchType"},
  U16 {"SearchKey"},
  arr {"Result", type=t_U8, length=8, reverse=true, ashex=true}
}

-- MT_SYS:

msg{"AREQ_SYS_RESET_REQ",
  U8  {"Type", default=1}
}

msg{"SREQ_SYS_PING"}
msg{"SRSP_SYS_PING",
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

msg{"SREQ_SYS_VERSION"}
msg{"SRSP_SYS_VERSION",
  U8  {"TransportRev"},
  U8  {"Product"},
  U8  {"MajorRel"},
  U8  {"MinorRel"},
  U8  {"MaintRel"}
}

msg{"SREQ_SYS_SET_EXTADDR",
  arr {"ExtAddress", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_SYS_SET_EXTADDR",
  U8  {"Status"}
}

msg{"SREQ_SYS_GET_EXTADDR",
  -- manual talks of another U8 "Status" here, considering this to be an error for now
}
msg{"SRSP_SYS_GET_EXTADDR",
  arr {"ExtAddress", type=t_U8, length=8, reverse=true, ashex=true}
}

msg{"SREQ_SYS_RAM_READ",
  U16 {"Address"},
  U8  {"Len"}
}
msg{"SRSP_SYS_RAM_READ",
  U8  {"Status"},
  arr {"Value", type=t_U8, counter=t_U8}
}

msg{"SREQ_SYS_RAM_WRITE",
  U16 {"Address"},
  arr {"Value", type=t_U8, counter=t_U8}
}
msg{"SRSP_SYS_RAM_WRITE",
  U8  {"Status"}
}

msg{"SREQ_SYS_OSAL_NV_READ",
  U16 {"Id"},
  U8  {"Offset", default=0}
}
msg{"SRSP_SYS_OSAL_NV_READ",
  U8  {"Status"},
  arr {"Value", type=t_U8, counter=t_U8}
}

msg{"SREQ_SYS_OSAL_NV_WRITE",
  U16 {"Id"},
  U8  {"Offset", default=0},
  arr {"Value", type=t_U8, counter=t_U8}
}
msg{"SRSP_SYS_OSAL_NV_WRITE",
  U8  {"Status"}
}

msg{"SREQ_SYS_OSAL_NV_ITEM_INIT",
  U16 {"Id"},
  U16 {"ItemLen"},
  arr {"InitData", type=t_U8, counter=t_U8}
}
msg{"SRSP_SYS_OSAL_NV_ITEM_INIT",
  U8  {"Status"}
}

msg{"SREQ_SYS_OSAL_NV_DELETE",
  U16 {"Id"},
  U16 {"ItemLen"}
}
msg{"SRSP_SYS_OSAL_NV_DELETE",
  U8  {"Status"}
}

msg{"SREQ_SYS_OSAL_NV_LENGTH",
  U16 {"Id"}
}
msg{"SRSP_SYS_OSAL_NV_LENGTH",
  U16 {"Length"}
}

msg{"SREQ_SYS_OSAL_START_TIMER",
  U8  {"Id"},
  U16 {"Timeout"}
}
msg{"SRSP_SYS_OSAL_START_TIMER",
  U8  {"Status"}
}

msg{"SREQ_SYS_OSAL_STOP_TIMER",
  U8  {"Id"}
}
msg{"SRSP_SYS_OSAL_STOP_TIMER",
  U8  {"Status"}
}

msg{"SREQ_SYS_RANDOM"}
msg{"SRSP_SYS_RANDOM",
  U16 {"Value"}
}

msg{"SREQ_SYS_ADC_READ",
  U8  {"Channel"},
  U8  {"Resolution"}
}
msg{"SRSP_SYS_ADC_READ",
  U16 {"Value"}
}

msg{"SREQ_SYS_GPIO",
  map {"Operation", type=t_U8, values={"SetDirection", "SetInputMode", "Set", "Clear", "Toggle", "Read"}},
  U8  {"Value"}
}
msg{"SRSP_SYS_GPIO",
  U8  {"Value"}
}

msg{"SREQ_SYS_STACK_TUNE",
  map {"Operation", type=t_U8, values={"SetTransmitPower", "RxOnWhenIdle"}},
  U8  {"Value"}
}
msg{"SRSP_SYS_STACK_TUNE",
  U8  {"Value"}
}

msg{"SREQ_SYS_SET_TIME",
  U32 {"UTCTime", default=0},
  U8  {"Hour", default=0},
  U8  {"Minute", default=0},
  U8  {"Second", default=0},
  U8  {"Month", default=1},
  U8  {"Day", default=1},
  U16 {"Year", default=2019}
}
msg{"SRSP_SYS_SET_TIME",
  U8  {"Status"}
}

msg{"SREQ_SYS_GET_TIME"}
msg{"SRSP_SYS_GET_TIME",
  U32 {"UTCTime"},
  U8  {"Hour"},
  U8  {"Minute"},
  U8  {"Second"},
  U8  {"Month"},
  U8  {"Day"},
  U16 {"Year"}
}

msg{"SREQ_SYS_SET_TX_POWER",
  U8  {"TXPower"}
}
msg{"SRSP_SYS_SET_TX_POWER",
  U8  {"TXPower"}
}

msg{"SREQ_SYS_ZDIAGS_INIT_STATS"}
msg{"SRSP_SYS_ZDIAGS_INIT_STATS",
  U8  {"Status"}
}

msg{"SREQ_SYS_ZDIAGS_CLEAR_STATS",
  U8  {"ClearNV", default=0}
}
msg{"SRSP_SYS_ZDIAGS_CLEAR_STATS",
  U32 {"SysClock"}
}

msg{"SREQ_SYS_ZDIAGS_GET_STATS",
  U16 {"AttributeId"}
}
msg{"SRSP_SYS_ZDIAGS_GET_STATS",
  U32 {"AttributeValue"}
}

msg{"SREQ_SYS_ZDIAGS_RESTORE_STATS_NV"}
msg{"SRSP_SYS_ZDIAGS_RESTORE_STATS_NV",
  U8  {"Status"}
}

msg{"SREQ_SYS_ZDIAGS_SAFE_STATS_TO_NV"}
msg{"SRSP_SYS_ZDIAGS_SAFE_STATS_TO_NV",
  U32 {"SysClock"}
}

msg{"SREQ_SYS_NV_CREATE",
  U8  {"SysId"},
  U16 {"ItemId"},
  U16 {"SubId"},
  U32 {"Length"}
}
msg{"SRSP_SYS_NV_CREATE",
  U8  {"Status"}
}

msg{"SREQ_SYS_NV_DELETE",
  U8  {"SysId"},
  U16 {"ItemId"},
  U16 {"SubId"}
}
msg{"SRSP_SYS_NV_DELETE",
  U8  {"Status"}
}

msg{"SREQ_SYS_NV_LENGTH",
  U8  {"SysId"},
  U16 {"ItemId"},
  U16 {"SubId"}
}
msg{"SRSP_SYS_NV_LENGTH",
  U8  {"Length"}
}

msg{"SREQ_SYS_NV_READ",
  U8  {"SysId"},
  U16 {"ItemId"},
  U16 {"SubId"},
  U16 {"Offset", default=0},
  U8  {"Length"}
}
msg{"SRSP_SYS_NV_READ",
  U8  {"Status"},
  arr {"Value", type=t_U8, counter=t_U8}
}

msg{"SREQ_SYS_NV_WRITE",
  U8  {"SysId"},
  U16 {"ItemId"},
  U16 {"SubId"},
  U16 {"Offset", default=0},
  arr {"Value", type=t_U8, counter=t_U16}
}
msg{"SRSP_SYS_NV_WRITE",
  U8  {"Status"}
}

msg{"SREQ_SYS_NV_UPDATE",
  U8  {"SysId"},
  U16 {"ItemId"},
  U16 {"SubId"},
  arr {"Value", type=t_U8, counter=t_U8}
}
msg{"SRSP_SYS_NV_UPDATE",
  U8  {"Status"}
}

msg{"SREQ_SYS_NV_COMPACT",
  U16 {"Threshold", default=128}
}
msg{"SRSP_SYS_NV_COMPACT",
  U8  {"Status"}
}

msg{"SREQ_SYS_OSAL_NV_READ_EXT",
  U16 {"Id"},
  U16 {"Offset", default=0}
}
msg{"SRSP_SYS_OSAL_NV_READ_EXT",
  U8  {"Status"},
  arr {"Value", type=t_U8, counter=t_U8}
}

--[[ -- redundant with SYS_OSAL_NV_WRITE
msg{"SREQ_SYS_OSAL_NV_WRITE_EXT",
  U16 {"Id"},
  U16 {"Offset", default=0},
  arr {"Value", type=t_U8, counter=t_U8}
}
msg{"SRSP_SYS_OSAL_NV_WRITE_EXT",
  U8  {"Status"}
}
]]

msg{"AREQ_SYS_RESET_IND",
  map {"Reason", type=t_U8, values={"PowerUp", "External", "Watchdog"}},
  U8  {"TransportRev"},
  U8  {"Product"},
  U8  {"MajorRel"},
  U8  {"MinorRel"},
  U8  {"HwRev"}
}

msg{"AREQ_SYS_OSAL_TIMER_EXPIRED",
  U8  {"Id"}
}

msg{"SREQ_UTIL_GET_DEVICE_INFO"}
msg{"SRSP_UTIL_GET_DEVICE_INFO",
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

msg{"SREQ_UTIL_GET_NV_INFO"}
msg{"SRSP_UTIL_GET_NV_INFO",
  U8  {"Status"},
  arr {"IEEEAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U32 {"ScanChannels"},
  U16 {"PanId"},
  U8  {"SecurityLevel"},
  arr {"PreConfigKey", type=t_U8, length=16}
}

msg{"SREQ_UTIL_SET_PANID",
  U16 {"PanId"}
}
msg{"SRSP_UTIL_SET_PANID",
  U8  {"Status"}
}

msg{"SREQ_UTIL_SET_CHANNELS",
  U32 {"Channels"}
}
msg{"SRSP_UTIL_SET_CHANNELS",
  U8  {"Status"}
}

msg{"SREQ_UTIL_SET_SECLEVEL",
  U8  {"SecLevel"}
}
msg{"SRSP_UTIL_SET_SECLEVEL",
  U8  {"Status"}
}

msg{"SREQ_UTIL_SET_PRECFGKEY",
  arr {"PreCfgKey", type=t_U8, length=16}
}
msg{"SRSP_UTIL_SET_PRECFGKEY",
  U8  {"Status"}
}

msg{"SREQ_UTIL_CALLBACK_SUB_CMD",
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
  U8  {"Status"}
}

msg{"SREQ_UTIL_KEY_EVENT",
  U8  {"Keys"},
  U8  {"Shift"}
}
msg{"SRSP_UTIL_KEY_EVENT",
  U8  {"Status"}
}

msg{"SREQ_UTIL_TIME_ALIVE"}
msg{"SRSP_UTIL_TIME_ALIVE",
  U32 {"Seconds"}
}

msg{"SREQ_UTIL_LED_CONTROL",
  U8  {"LedId"},
  U8  {"Mode"}
}
msg{"SRSP_UTIL_LED_CONTROL",
  U8  {"Status"}
}

msg{"SREQ_UTIL_LOOPBACK",
  arr {"Data", type=t_U8}
}
msg{"SRSP_UTIL_LOOPBACK",
  arr {"Data", type=t_U8}
}

msg{"SREQ_UTIL_DATA_REQ",
  U8  {"SecurityUse", default=0}
}
msg{"SRSP_UTIL_DATA_REQ",
  U8  {"Status"}
}

msg{"SREQ_UTIL_SRC_MATCH_ENABLE"}
msg{"SRSP_UTIL_SRC_MATCH_ENABLE",
  U8  {"Status"}
}

msg{"SREQ_UTIL_SRC_MATCH_ADD_ENTRY",
  map {"AddressMode", type=t_U8, values={
    {"Addr16Bit", 2, 0xFF},
    {"Addr64Bit", 3, 0xFF}}},
  arr {"Address", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"PanId"}
}
msg{"SRSP_UTIL_SRC_MATCH_ADD_ENTRY",
  U8  {"Status"}
}

msg{"SREQ_UTIL_SRC_MATCH_DEL_ENTRY",
  map {"AddressMode", type=t_U8, values={
    {"Addr16Bit", 2, 0xFF},
    {"Addr64Bit", 3, 0xFF}}},
  arr {"Address", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"PanId"}
}
msg{"SRSP_UTIL_SRC_MATCH_DEL_ENTRY",
  U8  {"Status"}
}

msg{"SREQ_UTIL_SRC_MATCH_CHECK_SRC_ADDR",
  map {"AddressMode", type=t_U8, values={
    {"Addr16Bit", 2, 0xFF},
    {"Addr64Bit", 3, 0xFF}}},
  arr {"Address", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"PanId"}
}
msg{"SRSP_UTIL_SRC_MATCH_CHECK_SRC_ADDR",
  U8  {"Status"}
}

msg{"SREQ_UTIL_SRC_MATCH_ACK_ALL_PENDING",
  U8  {"Option"}
}
msg{"SRSP_UTIL_SRC_MATCH_ACK_ALL_PENDING",
  U8  {"Status"}
}

msg{"SREQ_UTIL_SRC_MATCH_CHECK_ALL_PENDING"}
msg{"SRSP_UTIL_SRC_MATCH_CHECK_ALL_PENDING",
  U8  {"Status"},
  U8  {"Value"}
}

msg{"SREQ_UTIL_ADDRMGR_EXT_ADDR_LOOKUP",
  arr {"ExtAddr", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_UTIL_ADDRMGR_EXT_ADDR_LOOKUP",
  U16 {"NwkAddr"}
}

msg{"SREQ_UTIL_ADDRMGR_NWK_ADDR_LOOKUP",
  U16 {"NwkAddr"}
}
msg{"SRSP_UTIL_ADDRMGR_NWK_ADDR_LOOKUP",
  arr {"ExtAddr", type=t_U8, length=8, reverse=true, ashex=true}
}

msg{"SREQ_UTIL_APSME_LINK_KEY_DATA_GET",
  arr {"ExtAddr", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_UTIL_APSME_LINK_KEY_DATA_GET",
  U8  {"Status"},
  arr {"SecKey", type=t_U8, length=16},
  U32 {"TxFrmCntr"},
  U32 {"RxFrmCntr"}
}

msg{"SREQ_UTIL_APSME_LINK_KEY_NV_ID_GET",
  arr {"ExtAddr", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_UTIL_APSME_LINK_KEY_NV_ID_GET",
  U8  {"Status"},
  U16 {"LinkKeyNvId"}
}

msg{"SREQ_UTIL_APSME_REQUEST_KEY_CMD",
  arr {"PartnerAddr", type=t_U8, length=8, reverse=true, ashex=true} -- or is it U16? Specs are wrong at at least one place
}
msg{"SRSP_UTIL_APSME_REQUEST_KEY_CMD",
  U8  {"Status"}
}

msg{"SREQ_UTIL_ASSOC_COUNT",
  map {"StartRelation", type=t_U8, values={"PARENT", "CHILD_RFD", "CHILD_RFD_RX_IDLE", "CHILD_FFD", "CHILD_FFD_RX_IDLE", "NEIGHBOR", "OTHER"}},
  map {"EndRelation", type=t_U8, values={"PARENT", "CHILD_RFD", "CHILD_RFD_RX_IDLE", "CHILD_FFD", "CHILD_FFD_RX_IDLE", "NEIGHBOR", "OTHER"}}
}
msg{"SRSP_UTIL_ASSOC_COUNT",
  U16 {"Count"}
}

msg{"SREQ_UTIL_ASSOC_FIND_DEVICE",
  U8  {"Number"}
}
msg{"SRSP_UTIL_ASSOC_FIND_DEVICE",
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
  arr {"ExtAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"NwkAddr"}
}
msg{"SRSP_UTIL_ASSOC_GET_WITH_ADDRESS",
  arr {"Device", type=t_U8, length=18} -- see above @UTIL_ASSOC_FIND_DEVICE
}

msg{"SREQ_UTIL_BIND_ADD_ENTRY",
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
  -- BindingEntry_t:
  U8  {"SrcEP"},
  U8  {"DstGroupMode"},
  U16 {"DstIdx"},
  U8  {"DstEP"},
  arr {"ClusterIdList", type=t_U16, counter=t_U8}
}

msg{"SREQ_UTIL_ZCL_KEY_EST_INIT_EST",
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
  U8  {"Status"}
}

msg{"SREQ_UTIL_ZCL_KEY_EST_SIGN",
  arr {"Input", type=t_U8, counter=t_U8}
}
msg{"SRSP_UTIL_ZCL_KEY_EST_SIGN",
  U8  {"Status"},
  arr {"Key", type=t_U8, length=42}
}

msg{"SREQ_UTIL_SRNG_GEN"}
msg{"SRSP_UTIL_SRNG_GEN",
  arr {"SecureRandomNumbers", type=t_U8, length=100}
}

msg{"AREQ_UTIL_SYNC_REQ"}
msg{"AREQ_UTIL_ZCL_KEY_ESTABLISH_IND",
  U8  {"TaskId"},
  U8  {"Event"},
  U8  {"Status"},
  U8  {"WaitTime"},
  U16 {"Suite"}
}

msg{"SREQ_ZDO_NWK_ADDR_REQ",
  arr {"IEEEAddress", type=t_U8, length=8, reverse=true, ashex=true},
  map {"ReqType", type=t_U8, values={"Single", "Extended"}},
  U8  {"StartIndex", default=0}
}
msg{"SRSP_ZDO_NWK_ADDR_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_IEEE_ADDR_REQ",
  U16 {"ShortAddr"},
  map {"ReqType", type=t_U8, values={"Single", "Extended"}},
  U8  {"StartIndex", default=0}
}
msg{"SRSP_ZDO_IEEE_ADDR_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_NODE_DESC_REQ",
  U16 {"DstAddr"},
  U16 {"NWKAddrOfInterest"}
}
msg{"SRSP_ZDO_NODE_DESC_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_POWER_DESC_REQ",
  U16 {"DstAddr"},
  U16 {"NWKAddrOfInterest"}
}
msg{"SRSP_ZDO_POWER_DESC_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_SIMPLE_DESC_REQ",
  U16 {"DstAddr"},
  U16 {"NWKAddrOfInterest"},
  U8  {"Endpoint"}
}
msg{"SRSP_ZDO_SIMPLE_DESC_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_ACTIVE_EP_REQ",
  U16 {"DstAddr"},
  U16 {"NWKAddrOfInterest"}
}
msg{"SRSP_ZDO_ACTIVE_EP_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_MATCH_DESC_REQ",
  U16 {"DstAddr"},
  U16 {"NWKAddrOfInterest"},
  U16 {"ProfileId"},
  arr {"InClusterList", type=t_U16, counter=t_U8},
  arr {"OutClusterList", type=t_U16, counter=t_U8}
}
msg{"SRSP_ZDO_MATCH_DESC_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_COMPLEX_DESC_REQ",
  U16 {"DstAddr"},
  U16 {"NWKAddrOfInterest"}
}
msg{"SRSP_ZDO_COMPLEX_DESC_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_USER_DESC_REQ",
  U16 {"DstAddr"},
  U16 {"NWKAddrOfInterest"}
}
msg{"SRSP_ZDO_USER_DESC_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_END_DEVICE_ANNCE",
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
  U8  {"Status"}
}

msg{"SREQ_ZDO_USER_DESC_SET",
  U16 {"DstAddr"},
  U16 {"NWKAddrOfInterest"},
  arr {"UserDescriptor", type=t_U8, counter=t_U8}
}
msg{"SRSP_ZDO_USER_DESC_SET",
  U8  {"Status"}
}

msg{"SREQ_ZDO_SERVER_DISC_REQ",
  U16 {"ServerMask"}
}
msg{"SRSP_ZDO_SERVER_DISC_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_END_DEVICE_BIND_REQ",
  U16 {"DstAddr"},
  U16 {"LocalCoordinator"},
  arr {"IEEE", type=t_U8, length=8, reverse=true, ashex=true}, -- documentation is inconsistent here
  U8  {"Endpoint"},
  U16 {"ProfileId"},
  arr {"InClusterList", type=t_U16, counter=t_U8},
  arr {"OutClusterList", type=t_U16, counter=t_U8}
}
msg{"SRSP_ZDO_END_DEVICE_BIND_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_BIND_REQ",
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
  U8  {"Status"}
}

msg{"SREQ_ZDO_UNBIND_REQ",
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
  U8  {"Status"}
}

msg{"SREQ_ZDO_MGMT_NWK_DISC_REQ",
  U16 {"DstAddr"},
  U32 {"ScanChannels"},
  U8  {"ScanDuration"},
  U8  {"StartIndex", default=0}
}
msg{"SRSP_ZDO_MGMT_NWK_DISC_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_MGMT_LQI_REQ",
  U16 {"DstAddr"},
  U8  {"StartIndex", default=0}
}
msg{"SRSP_ZDO_MGMT_LQI_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_MGMT_RTG_REQ",
  U16 {"DstAddr"},
  U8  {"StartIndex", default=0}
}
msg{"SRSP_ZDO_MGMT_RTG_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_MGMT_BIND_REQ",
  U16 {"DstAddr"},
  U8  {"StartIndex", default=0}
}
msg{"SRSP_ZDO_MGMT_BIND_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_MGMT_LEAVE_REQ",
  U16 {"DstAddr"},
  arr {"DeviceAddress", type=t_U8, length=8, reverse=true, ashex=true},
  U8  {"RemoveChildren", default=0}
}
msg{"SRSP_ZDO_MGMT_LEAVE_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_MGMT_DIRECT_JOIN_REQ",
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
  U8  {"Status"}
}

msg{"SREQ_ZDO_MGMT_PERMIT_JOIN_REQ",
  U16 {"DstAddr"},
  U8  {"Duration", default=0},
  U8  {"TCSignificance"}
}
msg{"SRSP_ZDO_MGMT_PERMIT_JOIN_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_MGMT_NWK_UPDATE_REQ",
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
  U8  {"Status"}
}

msg{"SREQ_ZDO_MSG_CB_REGISTER",
  U16 {"ClusterId"}
}
msg{"SRSP_ZDO_MSG_CB_REGISTER",
  U8  {"Status"}
}

msg{"SREQ_ZDO_MSG_CB_REMOVE",
  U16 {"ClusterId"}
}
msg{"SRSP_ZDO_MSG_CB_REMOVE",
  U8  {"Status"}
}

msg{"SREQ_ZDO_STARTUP_FROM_APP",
  U16 {"StartDelay", default=0}
}
msg{"SRSP_ZDO_STARTUP_FROM_APP",
  U8  {"Status"}
}

msg{"SREQ_ZDO_STARTUP_FROM_APP_EX", -- doc says it exists, sources are not really confirming this
  U8  {"StartDelay", default=0},
  U8  {"Mode", default=0}
}
msg{"SRSP_ZDO_STARTUP_FROM_APP_EX",
  U8  {"Status"}
}

msg{"SREQ_ZDO_SET_LINK_KEY",
  U16 {"ShortAddr"},
  arr {"IEEEAddr", type=t_U8, length=8, reverse=true, ashex=true},
  arr {"LinkKeyData", type=t_U8, length=16}
}
msg{"SRSP_ZDO_SET_LINK_KEY",
  U8  {"Status"}
}

msg{"SREQ_ZDO_REMOVE_LINK_KEY",
  arr {"IEEEAddr", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_ZDO_REMOVE_LINK_KEY",
  U8  {"Status"}
}

msg{"SREQ_ZDO_GET_LINK_KEY",
  arr {"IEEEAddr", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_ZDO_GET_LINK_KEY",
  U8  {"Status"}
}

msg{"SREQ_ZDO_NWK_DISCOVERY_REQ",
  U32 {"ScanChannels"},
  U8  {"ScanDuration"}
}
msg{"SRSP_ZDO_NWK_DISCOVERY_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_JOIN_REQ",
  U8  {"LogicalChannel"},
  U16 {"PanId"},
  arr {"ExtendedPanId", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"ChosenParent"},
  U8  {"ParentDepth"},
  U8  {"StackProfile"}
}
msg{"SRSP_ZDO_JOIN_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_SET_REJOIN_PARAMETERS",
  U32 {"BackoffDuration"},
  U32 {"ScanDuration"}
}
msg{"SRSP_ZDO_SET_REJOIN_PARAMETERS",
  U8  {"Status"}
}

msg{"SREQ_ZDO_SEC_ADD_LINK_KEY",
  U16 {"ShortAddress"},
  arr {"ExtendedAddress", type=t_U8, length=8, reverse=true, ashex=true},
  arr {"Key", type=t_U8, length=16}
}
msg{"SRSP_ZDO_SEC_ADD_LINK_KEY",
  U8  {"Status"}
}

msg{"SREQ_ZDO_SEC_ENTRY_LOOKUP_EXT",
  arr {"ExtendedAddress", type=t_U8, length=8, reverse=true, ashex=true},
  arr {"ValidEntry", type=t_U8, length=5}
}
msg{"SRSP_ZDO_SEC_ENTRY_LOOKUP_EXT",
  U16 {"AMI"},
  U16 {"KeyNVId"},
  U8  {"AuthenticationOption"}
}

msg{"SREQ_ZDO_SEC_DEVICE_REMOVE",
  arr {"ExtendedAddress", type=t_U8, length=8, reverse=true, ashex=true}
}
msg{"SRSP_ZDO_SEC_DEVICE_REMOVE",
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_ROUTE_DISC",
  U16 {"DestinationAddress"},
  U8  {"Options"},
  U8  {"Radius"}
}
msg{"SRSP_ZDO_EXT_ROUTE_DISC",
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_ROUTE_CHECK",
  U16 {"DestinationAddress"},
  U8  {"RtStatus"},
  U8  {"Options"}
}
msg{"SRSP_ZDO_EXT_ROUTE_CHECK",
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_REMOVE_GROUP",
  U8  {"Endpoint"},
  U16 {"GroupId"}
}
msg{"SRSP_ZDO_EXT_REMOVE_GROUP",
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_REMOVE_ALL_GROUP",
  U8  {"Endpoint"}
}
msg{"SRSP_ZDO_EXT_REMOVE_ALL_GROUP",
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_FIND_ALL_GROUPS_ENDPOINT",
  U8  {"Endpoint"},
  U16 {"GroupList"}
}
msg{"SRSP_ZDO_EXT_FIND_ALL_GROUPS_ENDPOINT",
  arr {"Groups", type=t_U16, counter=t_U8}
}

msg{"SREQ_ZDO_EXT_FIND_GROUP",
  U8  {"Endpoint"},
  U16 {"GroupId"}
}
msg{"SRSP_ZDO_EXT_FIND_GROUP",
  arr {"Groups", type=t_U16, counter=t_U8} -- docs are fuzzy here
}

msg{"SREQ_ZDO_EXT_ADD_GROUP",
  U8  {"Endpoint"},
  U16 {"GroupId"},
  arr {"GroupName", type=t_U8, length=16} -- docs are fuzzy/strange here
}
msg{"SRSP_ZDO_EXT_ADD_GROUP",
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_COUNT_ALL_GROUPS"}
msg{"SRSP_ZDO_EXT_COUNT_ALL_GROUPS",
  U8  {"NumberOfGroups"}
}

msg{"SREQ_ZDO_EXT_RX_IDLE",
  U8  {"SetFlag"},
  U8  {"SetValue"}
}
msg{"SRSP_ZDO_EXT_RX_IDLE",
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_UPDATE_NWK_KEY",
  U16 {"DestinationAddress"},
  U8  {"KeySeqNum"},
  arr {"Key", length=128} -- length is probably an error in the docs?
}
msg{"SRSP_ZDO_EXT_UPDATE_NWK_KEY",
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_SWITCH_NWK_KEY",
  U16 {"DestinationAddress"},
  U8  {"KeySeqNum"}
}
msg{"SRSP_ZDO_EXT_SWITCH_NWK_KEY",
  U8  {"Status"}
}

msg{"SREQ_ZDO_EXT_NWK_INFO"}
msg{"SRSP_ZDO_EXT_NWK_INFO",
  U16 {"ShortAddress"},
  U16 {"PanId"},
  U16 {"ParentAddress"},
  arr {"ExtendedPanId", type=t_U8, length=8, reverse=true, ashex=true},
  arr {"ExtendedParentAddress", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"Channel"}
}

msg{"SREQ_ZDO_EXT_SEC_APS_REMOVE_REQ",
  U16 {"NwkAddress"},
  arr {"ExtendedAddress", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"ParentAddress"}
}
msg{"SRSP_ZDO_EXT_SEC_APS_REMOVE_REQ",
  U8  {"Status"}
}

msg{"SREQ_ZDO_FORCE_CONCENTRATOR_CHANGE"}
msg{"SRSP_ZDO_FORCE_CONCENTRATOR_CHANGE"}

msg{"SREQ_ZDO_EXT_SET_PARAMS",
  U8  {"UseMulticast"}
}
msg{"SRSP_ZDO_EXT_SET_PARAMS",
  U8  {"Status"}
}

msg{"SREQ_ZDO_NWK_ADDR_OF_INTEREST_REQ",
  U16 {"DestAddr"},
  U16 {"NwkAddrOfInterest"},
  U8  {"Cmd"} -- according to docs, a cluster ID - however, those would be 16bit?!?
}
msg{"SRSP_ZDO_NWK_ADDR_OF_INTEREST_REQ",
  U8  {"Status"}
}

msg{"AREQ_ZDO_NWK_ADDR_RSP",
  U8  {"Status"},
  arr {"IEEEAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"NwkAddr"},
  U8  {"StartIndex"},
  arr {"AssocDevList", type=t_U16, counter=t_U8}
}

msg{"AREQ_ZDO_IEEE_ADDR_RSP",
  U8  {"Status"},
  arr {"IEEEAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"NwkAddr"},
  U8  {"StartIndex"},
  arr {"AssocDevList", type=t_U16, counter=t_U8} -- now is it t_U16 or t_U64?
}

msg{"AREQ_ZDO_NODE_DESC_RSP",
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
  U16 {"SrcAddr"},
  U8  {"Status"},
  U16 {"NwkAddr"},
  U8  {"CurrentPowerMode_AvailablePowerSources"},
  U8  {"CurrentPowerSource_CurrentPowerSourceLevel"}
}

msg{"AREQ_ZDO_SIMPLE_DESC_RSP",
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
  U16 {"SrcAddr"},
  U8  {"Status"},
  U16 {"NwkAddr"},
  arr {"ActiveEPList", type=t_U8, counter=t_U8},
}

msg{"AREQ_ZDO_MATCH_DESC_RSP",
  U16 {"SrcAddr"},
  U8  {"Status"},
  U16 {"NwkAddr"},
  arr {"MatchList", type=t_U8, counter=t_U8},
}

msg{"AREQ_ZDO_COMPLEX_DESC_RSP",
  U16 {"SrcAddr"},
  U8  {"Status"},
  U16 {"NwkAddr"},
  arr {"ComplexDescriptor", type=t_U8, counter=t_U8},
}

msg{"AREQ_ZDO_USER_DESC_RSP",
  U16 {"SrcAddr"},
  U8  {"Status"},
  U16 {"NwkAddr"},
  arr {"UserDescriptor", type=t_U8, counter=t_U8},
}

msg{"AREQ_ZDO_USER_DESC_CONF",
  U16 {"SrcAddr"},
  U8  {"Status"},
  U16 {"NwkAddr"}
}

msg{"AREQ_ZDO_SERVER_DISC_RSP",
  U16 {"SrcAddr"},
  U8  {"Status"},
  U16 {"ServerMask"} -- TODO: map this
}

msg{"AREQ_ZDO_END_DEVICE_BIND_RSP",
  U16 {"SrcAddr"},
  U8  {"Status"},
}

msg{"AREQ_ZDO_BIND_RSP",
  U16 {"SrcAddr"},
  U8  {"Status"},
}

msg{"AREQ_ZDO_UNBIND_RSP",
  U16 {"SrcAddr"},
  U8  {"Status"},
}

msg{"AREQ_ZDO_MGMT_NWK_DISC_RSP",
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
  U16 {"SrcAddr"},
  U8  {"Status"}
}

msg{"AREQ_ZDO_MGMT_DIRECT_JOIN_RSP",
  U16 {"SrcAddr"},
  U8  {"Status"}
}

msg{"AREQ_ZDO_MGMT_PERMIT_JOIN_RSP",
  U16 {"SrcAddr"},
  U8  {"Status"}
}

msg{"AREQ_ZDO_STATE_CHANGE_IND",
  U8  {"State"},
}

msg{"AREQ_ZDO_END_DEVICE_ANNCE_IND",
  U16 {"SrcAddr"},
  U16 {"NwkAddr"},
  arr {"IEEEAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U8  {"Capabilities"} -- TODO: map this
}

msg{"AREQ_ZDO_MATCH_DESC_RSP_SENT",
  U16 {"NwkAddr"},
  arr {"InClusterList", type=t_U16, counter=t_U8},
  arr {"OutClusterList", type=t_U16, counter=t_U8}
}

msg{"AREQ_ZDO_STATUS_ERROR_RSP",
  U16 {"SrcAddr"},
  U8  {"Status"}
}

msg{"AREQ_ZDO_SRC_RTG_IND",
  U16 {"DstAddr"},
  arr {"RelayList", type=t_U16, counter=t_U8}
}

msg{"AREQ_ZDO_BEACON_NOTIFY_IND",
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
  U8  {"Status"},
  U16 {"DeviceAddress"},
  U16 {"ParentAddress"}
}

msg{"AREQ_ZDO_NWK_DISCOVERY_CNF",
  U8  {"Status"},
}

msg{"AREQ_ZDO_LEAVE_IND",
  U16 {"SrcAddr"},
  arr {"ExtAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U8  {"Request"},
  U8  {"Remove"},
  U8  {"Rejoin"}
}

msg{"AREQ_ZDO_MSG_CB_INCOMING",
  U16 {"SrcAddr"},
  U8  {"WasBroadcast"},
  U16 {"ClusterId"},
  U8  {"SecurityUse"},
  U8  {"SeqNum"},
  U16 {"MacDstAddr"},
  arr {"Data", type=t_U8}
}

msg{"AREQ_ZDO_TC_DEV_IND",
  U16 {"SrcNwkAddr"},
  arr {"SrcIEEEAddr", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"ParentNwkAddr"}
}

msg{"AREQ_ZDO_PERMIT_JOIN_IND",
  U8  {"PermitJoinDuration"}
}

msg{"SREQ_APP_CNF_SET_NWK_FRAME_COUNTER",
  U32 {"FrameCounterValue"} -- docs are fuzzy whether this is U8/U32
}
msg{"SRSP_APP_CNF_SET_NWK_FRAME_COUNTER",
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_SET_DEFAULT_REMOTE_ENDDEVICE_TIMEOUT",
  U8  {"TimeoutIndex"}
}
msg{"SRSP_APP_CNF_SET_DEFAULT_REMOTE_ENDDEVICE_TIMEOUT",
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_SET_ENDDEVICETIMEOUT",
  U8  {"TimeoutIndex"}
}
msg{"SRSP_APP_CNF_SET_ENDDEVICETIMEOUT",
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_SET_ALLOWREJOIN_TC_POLICY",
  U8  {"AllowRejoin"}
}
msg{"SRSP_APP_CNF_SET_ALLOWREJOIN_TC_POLICY",
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_BDB_START_COMMISSIONING",
  U8  {"CommissioningMode"}
}
msg{"SRSP_APP_CNF_BDB_START_COMMISSIONING",
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_BDB_SET_CHANNEL",
  U8  {"IsPrimary", default=1},
  U32 {"Channel", default=0x800}
}
msg{"SRSP_APP_CNF_BDB_SET_CHANNEL",
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_BDB_ADD_INSTALLCODE_installcode_crc",
  U8  {"InstallCodeFormat", const=0x01},
  arr {"IEEEAddress", type=t_U8, length=8, reverse=true, ashex=true},
  arr {"InstallCode", type=t_U8, length=18}
}
msg{"SREQ_APP_CNF_BDB_ADD_INSTALLCODE_derived_key",
  U8  {"InstallCodeFormat", const=0x02},
  arr {"IEEEAddress", type=t_U8, length=8, reverse=true, ashex=true},
  arr {"InstallCode", type=t_U8, length=16}
}
msg{"SRSP_APP_CNF_BDB_ADD_INSTALLCODE",
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_BDB_SET_TC_REQUIRE_KEY_EXCHANGE",
  U8  {"BdbTrustCenterRequireKeyExchange"},
}
msg{"SRSP_APP_CNF_BDB_SET_TC_REQUIRE_KEY_EXCHANGE",
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_BDB_SET_JOINUSESINSTALLCODEKEY",
  U8  {"BdbJoinUsesInstallCodeKey"},
}
msg{"SRSP_APP_CNF_BDB_SET_JOINUSESINSTALLCODEKEY",
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_BDB_SET_ACTIVE_DEFAULT_CENTRALIZED_KEY",
  U8  {"UseGlobal"},
  arr {"InstallCode", type=t_U8, length=18}
}
msg{"SRSP_APP_CNF_BDB_SET_ACTIVE_DEFAULT_CENTRALIZED_KEY",
  U8  {"Status"}
}

msg{"SREQ_APP_CNF_BDB_ZED_ATTEMPT_RECOVER_NWK"}
msg{"SRSP_APP_CNF_BDB_ZED_ATTEMPT_RECOVER_NWK",
  U8  {"Status"}
}

msg{"AREQ_APP_CNF_BDB_COMMISSIONING_NOTIFICATION",
  U8  {"Status"}, -- TODO: map all of these
  U8  {"CommissioningMode"},
  U8  {"RemainingCommissioningModes"}
}

msg{"SREQ_GP_DATA_REQ",
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
  U8  {"Status"}
}

msg{"SREQ_GP_SEC_RSP",
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
  U8  {"Status"}
}

msg{"AREQ_GP_DATA_CNF",
  U8  {"Status"},
  U8  {"GPMPDUHandle"}
}

msg{"AREQ_GP_SEC_REQ",
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

end)
