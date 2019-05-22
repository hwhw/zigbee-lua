return require"lib.codec"(function()

map{"Status", type=t_U8, register=true, values={
  {"SUCCESS",                   0x00, 0xFF},

  {"INV_REQUESTTYPE",           0x80, 0xFF},
  {"DEVICE_NOT_FOUND",          0x81, 0xFF},
  {"INVALID_EP",                0x82, 0xFF},
  {"NOT_ACTIVE",                0x83, 0xFF},
  {"NOT_SUPPORTED",             0x84, 0xFF},
  {"TIMEOUT",                   0x85, 0xFF},
  {"NO_MATCH",                  0x86, 0xFF},
  {"NO_ENTRY",                  0x88, 0xFF},
  {"NO_DESCRIPTOR",             0x89, 0xFF},
  {"INSUFFICIENT_SPACE",        0x8A, 0xFF},
  {"NOT_PERMITTED",             0x8B, 0xFF},
  {"TABLE_FULL",                0x8C, 0xFF},
  {"NOT_AUTHORIZED",            0x8D, 0xFF},
  {"DEVICE_BINDING_TABLE_FULL", 0x8E, 0xFF},

  {"ASDU_TOO_LONG",             0xA0, 0xFF},
  {"DEFRAG_DEFERRED",           0xA1, 0xFF},
  {"DEFRAG_UNSUPPORTED",        0xA2, 0xFF},
  {"ILLEGAL_REQUEST",           0xA3, 0xFF},
  {"INVALID_BINDING",           0xA4, 0xFF},
  {"INVALID_GROUP",             0xA5, 0xFF},
  {"INVALID_PARAMETER",         0xA6, 0xFF},
  {"NO_ACK",                    0xA7, 0xFF},
  {"NO_BOUND_DEVICE",           0xA8, 0xFF},
  {"NO_SHORT_ADDRESS",          0xA9, 0xFF},
  {"NOT_SUPPORTED",             0xAA, 0xFF},
  {"SECURED_LINK_KEY",          0xAB, 0xFF},
  {"SECURED_NWK_KEY",           0xAC, 0xFF},
  {"SECURITY_FAIL",             0xAD, 0xFF},
  {"TABLE_FULL2",               0xAE, 0xFF},
  {"UNSECURED",                 0xAF, 0xFF},
  {"UNSUPPORTED_ATTRIBUTE",     0xB0, 0xFF},
}}

local function clusterlocal(id, name)
  return opt {nil, when=function(v,_,ctx,r) return ctx.ClusterId==id end, msg{ref=name}}
end

msg{"Frame",
  U8  {"TransactionSequenceNumber"},

  -- Device and Service Discovery Client
  clusterlocal(0x0000, "NWK_addr_req"),
  clusterlocal(0x0001, "IEEE_addr_req"),
  clusterlocal(0x0002, "Node_Desc_req"),
  clusterlocal(0x0003, "Power_Desc_req"),
  clusterlocal(0x0004, "Simple_Desc_req"),
  clusterlocal(0x0005, "Active_EP_req"),
  --clusterlocal(0x0006, "Match_Desc_req"),
  --clusterlocal(0x0010, "Complex_Desc_req"),
  --clusterlocal(0x0011, "User_Desc_req"),
  --clusterlocal(0x0015, "System_Server_Discovery_req"),
  --clusterlocal(0x0016, "Discovery_Store_req"),
  --clusterlocal(0x0017, "Node_Desc_store_req"),
  --clusterlocal(0x0018, "Power_Desc_store_req"),
  --clusterlocal(0x0019, "Active_EP_store_req"),
  --clusterlocal(0x001a, "Simple_Desc_store_req"),
  --clusterlocal(0x001b, "Remove_node_cache_req"),
  --clusterlocal(0x001c, "Find_node_cache_req"),
  --clusterlocal(0x001d, "Extended_Simple_Desc_req"),
  --clusterlocal(0x001e, "Extended_Active_EP_req"),

  -- Bind Client
  -- ...
  
  -- Network Management Client
  -- ...
  clusterlocal(0x0031, "Mgmt_Lqi_req"),
  clusterlocal(0x0032, "Mgmt_Rtg_req"),
  clusterlocal(0x0036, "Mgmt_Permit_Joining_req"),
  -- ...

  -- Device and Service Discovery Server
  clusterlocal(0x8000, "NWK_addr_rsp"),
  clusterlocal(0x8001, "IEEE_addr_rsp"),
  clusterlocal(0x8002, "Node_Desc_rsp"),
  clusterlocal(0x8003, "Power_Desc_rsp"),
  clusterlocal(0x8004, "Simple_Desc_rsp"),
  clusterlocal(0x8005, "Active_EP_rsp"),
  --clusterlocal(0x8006, "Match_Desc_rsp"),
  --clusterlocal(0x8010, "Complex_Desc_rsp"),
  --clusterlocal(0x8011, "User_Desc_rsp"),
  --clusterlocal(0x8015, "System_Server_Discovery_rsp"),
  --clusterlocal(0x8016, "Discovery_Store_rsp"),
  --clusterlocal(0x8017, "Node_Desc_store_rsp"),
  --clusterlocal(0x8018, "Power_Desc_store_rsp"),
  --clusterlocal(0x8019, "Active_EP_store_rsp"),
  --clusterlocal(0x801a, "Simple_Desc_store_rsp"),
  --clusterlocal(0x801b, "Remove_node_cache_rsp"),
  --clusterlocal(0x801c, "Find_node_cache_rsp"),
  --clusterlocal(0x801d, "Extended_Simple_Desc_rsp"),
  --clusterlocal(0x801e, "Extended_Active_EP_rsp"),

  -- Bind Server
  -- ...
  
  -- Network Management Server
  -- ...
  clusterlocal(0x8031, "Mgmt_Lqi_rsp"),
  clusterlocal(0x8032, "Mgmt_Rtg_rsp"),
  clusterlocal(0x8036, "Mgmt_Permit_Joining_rsp"),
  -- ...
}

msg{"NWK_addr_req",
  arr {"IEEEAddress", type=t_U8, length=8, reverse=true, ashex=true},
  map {"ReqType", type=t_U8, values={"Single", "Extended"}},
  U8  {"StartIndex", default=0}
}

msg{"IEEE_addr_req",
  U16 {"ShortAddr"},
  map {"ReqType", type=t_U8, values={"Single", "Extended"}},
  U8  {"StartIndex", default=0}
}

msg{"Node_Desc_req",
  U16 {"NWKAddrOfInterest"},
}

msg{"Power_Desc_req",
  U16 {"NWKAddrOfInterest"},
}

msg{"Simple_Desc_req",
  U16 {"NWKAddrOfInterest"},
  U8  {"Endpoint"}
}

msg{"Active_EP_req",
  U16 {"NWKAddrOfInterest"},
}

-- ...

msg{"Mgmt_Lqi_req",
  U8  {"StartIndex"}
}

msg{"Mgmt_Rtg_req",
  U8  {"StartIndex"}
}

msg{"Mgmt_Permit_Joining_req",
  U8  {"PermitDuration"},
  U8  {"TC_Significance", default=0}
}

-- ...

msg{"NWK_addr_rsp",
  map {ref="Status"},
  arr {"IEEEAddrRemoteDev", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"NWKAddrRemoteDev"},
  -- TODO: NumAssocDev, StartIndex, AssocDevList
}

msg{"IEEE_addr_rsp",
  map {ref="Status"},
  arr {"IEEEAddrRemoteDev", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"NWKAddrRemoteDev"},
  -- TODO: NumAssocDev, StartIndex, AssocDevList
}

msg{"NodeDescriptor",
  map {"Flags1", type=t_U8, values={
    {"Coordinator",                 B"00000000", B"00000111"},
    {"Router",                      B"00000001", B"00000111"},
    {"EndDevice",                   B"00000010", B"00000111"},
    {"ComplexDescriptorAvailable",  B"00001000", B"00001000"},
    {"UserDescriptorAvailable",     B"00010000", B"00010000"},
  }},
  map {"Flags2", type=t_U8, values={
    {"FrequencyBand868MHz",         B"00001000", B"00001000"},
    {"FrequencyBand902MHz",         B"00100000", B"00100000"},
    {"FrequencyBand2400MHz",        B"01000000", B"01000000"},
  }},
  map {"MACCapabilityFlags", type=t_U8, values={
    {"AlternatePANCoordinator",     B"00000001", B"00000001"},
    {"DeviceType",                  B"00000010", B"00000010"},
    {"PowerSource",                 B"00000100", B"00000100"},
    {"ReceiverOnWhenIdle",          B"00001000", B"00001000"},
    {"SecurityCapability",          B"01000000", B"01000000"},
    {"AllocateAddress",             B"10000000", B"10000000"},
  }},
  U16 {"ManufacturerCode"},
  U8  {"MaximumBufferSize"},
  U16 {"MaximumIncomingTransferSize"},
  map {"ServerMask", type=t_U16, values={
    {"PrimaryTrustCenter",          B"0000000000000001", B"00000000000000001"},
    {"BackupTrustCenter",           B"0000000000000010", B"00000000000000010"},
    {"PrimaryBindingTableCache",    B"0000000000000100", B"00000000000000100"},
    {"BackupBindingTableCache",     B"0000000000001000", B"00000000000001000"},
    {"PrimaryDiscoveryCache",       B"0000000000010000", B"00000000000010000"},
    {"BackupDiscoveryCache",        B"0000000000100000", B"00000000000100000"},
    {"NetworkManager",              B"0000000001000000", B"00000000001000000"},
  }},
  U16 {"MaximumOutgoingTransferSize"},
  map {"DescriptorCapabilityField", type=t_U8, values={
    {"ExtendedActiveEndpointListAvailable",   B"00000001", B"00000001"},
    {"ExtendedSimpleDescriptorListAvailable", B"00000010", B"00000010"},
  }},
}

msg{"Node_Desc_rsp",
  map {ref="Status"},
  U16 {"NWKAddrOfInterest"},
  msg{ref="NodeDescriptor"}
}

msg{"Power_Desc_rsp",
  map {ref="Status"},
  U16 {"NWKAddrOfInterest"},
  map {"PowerDescriptor", type=t_U16, values={
    {"ReceiverOnWhenIdle",           B"0000000000000000", B"1111000000000000"},
    {"ReceiverPeriodicallyOn",       B"0001000000000000", B"1111000000000000"},
    {"ReceiverOnWhenStimulated",     B"0010000000000000", B"1111000000000000"},

    {"AvailableConstantPower",       B"0000000100000000", B"0000000100000000"},
    {"AvailableRechargeableBattery", B"0000001000000000", B"0000001000000000"},
    {"AvailableDisposableBattery",   B"0000010000000000", B"0000010000000000"},

    {"CurrentConstantPower",         B"0000000000010000", B"0000000000010000"},
    {"CurrentRechargeableBattery",   B"0000000000100000", B"0000000000100000"},
    {"CurrentDisposableBattery",     B"0000000001000000", B"0000000001000000"},

    {"CurrentLevelCritical",         B"0000000000000000", B"0000000000001111"},
    {"CurrentLevel33",               B"0000000000000100", B"0000000000001111"},
    {"CurrentLevel66",               B"0000000000001000", B"0000000000001111"},
    {"CurrentLevel100",              B"0000000000001100", B"0000000000001111"}
  }}
}

msg{"SimpleDescriptor",
  U8  {"Endpoint"},
  U16 {"ApplicationProfileIdentifier"},
  U16 {"ApplicationDeviceIdentifier"},
  U8  {"ApplicationDeviceVersion"}, -- is in fact only 4 bits, other 4 bits are Reserved
  arr {"ApplicationInputClusterList", type=t_U16, counter=t_U8},
  arr {"ApplicationOutputClusterList", type=t_U16, counter=t_U8}
}

msg{"Simple_Desc_rsp",
  map {ref="Status"},
  U16 {"NWKAddrOfInterest"},
  U8  {"Length"},
  msg{ref="SimpleDescriptor"}
}

msg{"Active_EP_rsp",
  map {ref="Status"},
  U16 {"NWKAddrOfInterest"},
  arr {"ActiveEPList", type=t_U8, counter=t_U8}
}

-- ...

msg{"NeighborTableListRecord",
  arr {"ExtendedPANId", type=t_U8, length=8, reverse=true, ashex=true},
  arr {"ExtendedAddress", type=t_U8, length=8, reverse=true, ashex=true},
  U16 {"NetworkAddress"},
  map {"Info1", type=t_U8, values={
    {"DeviceTypeZigBeeCoordinator",     B"00000000", B"00000011"},
    {"DeviceTypeZigBeeRouter",          B"00000001", B"00000011"},
    {"DeviceTypeZigBeeEndDevice",       B"00000010", B"00000011"},
    {"DeviceTypeUnknown",               B"00000011", B"00000011"},
    {"ReceiverOffWhenIdle",             B"00000000", B"00001100"},
    {"ReceiverOnWhenIdle",              B"00000100", B"00001100"},
    {"ReceiverWhenIdleUnknown",         B"00001000", B"00001100"},
    {"RelationshipIsParent",            B"00000000", B"01110000"},
    {"RelationshipIsChild",             B"00010000", B"01110000"},
    {"RelationshipIsSibling",           B"00100000", B"01110000"},
    {"RelationshipNone",                B"00110000", B"01110000"},
    {"RelationshipPreviousChild",       B"01000000", B"01110000"},
  }},
  map {"Info2", type=t_U8, values={
    {"NotAcceptingJoinRequests",        B"00000000", B"00000011"},
    {"AcceptingJoinRequests",           B"00000001", B"00000011"},
    {"JoinRequestHandlingUnknown",      B"00000010", B"00000011"},
  }},
  U8  {"Depth"},
  U8  {"LQI"}
}
  
msg{"Mgmt_Lqi_rsp",
  map {ref="Status"},
  U8  {"NeighborTableEntries"},
  U8  {"StartIndex"},
  arr {"NeighborTableList", counter=t_U8, msg{ref="NeighborTableListRecord"}}
}

msg{"RoutingTableListRecord",
  U16 {"DestinationAddress"},
  map {"RouteStatus", type=t_U8, values={
    {"StatusActive",              B"00000000", B"00000111"},
    {"StatusDiscoveryUnderway",   B"00000001", B"00000111"},
    {"StatusDiscoveryFailed",     B"00000010", B"00000111"},
    {"StatusInactive",            B"00000011", B"00000111"},
    {"StatusValidationUnderway",  B"00000100", B"00000111"},
    {"MemoryConstrained",         B"00001000", B"00001000"},
    {"ManyToOne",                 B"00010000", B"00010000"},
    {"RouteRecordRequired",       B"00100000", B"00100000"}
  }},
  U16 {"NextHopAddress"}
}

msg{"Mgmt_Rtg_rsp",
  map {ref="Status"},
  U8  {"RoutingTableEntries"},
  U8  {"StartIndex"},
  arr {"RoutingTableList", counter=t_U8, msg{ref="RoutingTableListRecord"}}
}

msg{"Mgmt_Permit_Joining_rsp",
  map {ref="Status"}
}

end)
