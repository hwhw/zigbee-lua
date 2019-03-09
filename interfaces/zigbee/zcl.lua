return (require"lib.codec")(function()

local function more_data(name)
  return function(v, getc) if getc then return getc(true) else return v[name] end end
end
local function more_of(name) return opt{nil, when=more_data(name), msg{ref=name}} end

map{"Status", type=t_U8, register=true, values={
  {"SUCCESS",                     0x00, 0xFF},
  {"FAILURE",                     0x01, 0xFF},
  {"NOT_AUTHORIZED",              0x7e, 0xFF},
  {"RESERVED_FIELD_NOT_ZERO",     0x7f, 0xFF},
  {"MALFORMED_COMMAND",           0x80, 0xFF},
  {"UNSUP_CLUSTER_COMMAND",       0x81, 0xFF},
  {"UNSUP_GENERAL_COMMAND",       0x82, 0xFF},
  {"UNSUP_MANUF_CLUSTER_COMMAND", 0x83, 0xFF},
  {"UNSUP_MANUF_GENERAL_COMMAND", 0x84, 0xFF},
  {"INVALID_FIELD",               0x85, 0xFF},
  {"UNSUPPORTED_ATTRIBUTE",       0x86, 0xFF},
  {"INVALID_VALUE",               0x87, 0xFF},
  {"READ_ONLY",                   0x88, 0xFF},
  {"INSUFFICIENT_SPACE",          0x89, 0xFF},
  {"DUPLICATE_EXISTS",            0x8a, 0xFF},
  {"NOT_FOUND",                   0x8b, 0xFF},
  {"UNREPORTABLE_ATTRIBUTE",      0x8c, 0xFF},
  {"INVALID_DATA_TYPE",           0x8d, 0xFF},
  {"INVALID_SELECTOR",            0x8e, 0xFF},
  {"WRITE_ONLY",                  0x8f, 0xFF},
  {"INCONSISTENT_STARTUP_STATE",  0x90, 0xFF},
  {"DEFINED_OUT_OF_BAND",         0x91, 0xFF},
  {"INCONSISTENT",                0x92, 0xFF},
  {"ACTION_DENIED",               0x93, 0xFF},
  {"TIMEOUT",                     0x94, 0xFF},
  {"ABORT",                       0x95, 0xFF},
  {"INVALID_IMAGE",               0x96, 0xFF},
  {"WAIT_FOR_DATA",               0x97, 0xFF},
  {"NO_IMAGE_AVAILABLE",          0x98, 0xFF},
  {"REQUIRE_MORE_IMAGE",          0x99, 0xFF},
  {"NOTIFICATION_PENDING",        0x9a, 0xFF},
  {"HARDWARE_FAILURE",            0xc0, 0xFF},
  {"SOFTWARE_FAILURE",            0xc1, 0xFF},
  {"CALIBRATION_ERROR",           0xc2, 0xFF},
  {"UNSUPPORTED_CLUSTER",         0xc3, 0xFF}
}}

local function clusterlocal(id, name)
  return opt {nil, when=function(v,_,ctx,r) return contains(v.FrameControl, {"FrameTypeLocal"}) and ctx.ClusterId==id end, msg{ref=name.."ClusterFrame"}}
end
msg{"Frame",
  map {"FrameControl", type=t_U8, values={
    {"FrameTypeGlobal",         B"00000000", B"00000011"},
    {"FrameTypeLocal",          B"00000001", B"00000011"},
    {"ManufacturerSpecific",    B"00000100", B"00000100"},
    {"DirectionFromServer",     B"00001000", B"00001000"},
    {"DirectionToServer",       B"00000000", B"00001000"},
    {"DisableDefaultResponse",  B"00010000", B"00010000"}}},
  opt {nil, when=function(v) return contains(v.FrameControl, {"ManufacturerSpecific"}) end, U16{"ManufacturerCode"}},
  U8  {"TransactionSequenceNumber"},

  opt {nil, when=function(v) return contains(v.FrameControl, {"FrameTypeGlobal"}) end, msg{ref="GeneralCommandFrame"}},

  clusterlocal(0x0000, "Basic"),
  clusterlocal(0x0001, "PowerConfiguration"),
  clusterlocal(0x0002, "DeviceTemperatureConfiguration"),
  clusterlocal(0x0003, "Identify"),

  clusterlocal(0x0004, "Groups"),
  --clusterlocal(0x0005, "Scenes"),

  clusterlocal(0x0006, "OnOff"),
  clusterlocal(0x0007, "OnOffSwitchConfiguration"),
  clusterlocal(0x0008, "LevelControl"),

  --clusterlocal(0x0009, "Alarms"),

  clusterlocal(0x000a, "Time"),
  --clusterlocal(0x000b, "RSSILocation"),
  --clusterlocal(0x0b05, "Diagnostics"),
  --clusterlocal(0x0020, "PollControl"),
  --clusterlocal(0x001a, "PowerProfile"),
  --clusterlocal(0x0b01, "MeterIdentification"),

  --clusterlocal(0x000c, "AnalogInput"),
  --clusterlocal(0x000d, "AnalogOutput"),
  --clusterlocal(0x000e, "AnalogValue"),
  --clusterlocal(0x000f, "BinaryInput"),
  --clusterlocal(0x0010, "BinaryOutput"),
  --clusterlocal(0x0011, "BinaryValue"),
  --clusterlocal(0x0012, "MultistateInput"),
  --clusterlocal(0x0013, "MultistateOutput"),
  --clusterlocal(0x0014, "MultistateValue"),

  -- Measurement and sensing
  clusterlocal(0x0400, "IlluminanceMeasurement"),
  clusterlocal(0x0401, "IlluminanceLevelSensing"),
  clusterlocal(0x0402, "TemperatureMeasurement"),
  clusterlocal(0x0403, "PressureMeasurement"),
  clusterlocal(0x0404, "FlowMeasurement"),
  clusterlocal(0x0405, "RelativeHumidityMeasurement"),
  clusterlocal(0x0406, "OccupancySensing"),
  --clusterlocal(0x0b04, "ElectricalMeasurement"),

  -- Lighting
  clusterlocal(0x0300, "ColorControl"),
  --clusterlocal(0x0301, "BallastConfiguration"),

}

map {"CommandIdentifier", register=true, type=t_U8, values={
  "ReadAttributes",
  "ReadAttributesResponse",
  "WriteAttributes",
  "WriteAttributesUndivided",
  "WriteAttributesResponse",
  "WriteAttributesNoResponse",
  "ConfigureReporting",
  "ConfigureReportingResponse",
  "ReadReportingConfiguration",
  "ReadReportingConfigurationResponse",
  "ReportAttributes",
  "DefaultResponse",
  "DiscoverAttributes",
  "DiscoverAttributesResponse",
  "ReadAttributesStructured",
  "WriteAttributesStructured",
  "WriteAttributesStructuredResponse",
  "DiscoverCommandsReceived",
  "DiscoverCommandsReceivedResponse",
  "DiscoverCommandsGenerated",
  "DiscoverCommandsGeneratedResponse",
  "DiscoverAttributesExtended",
  "DiscoverAttributesExtendedResponse"
}}

local function cmdref(c) return opt{nil, when=function(v) return v.CommandIdentifier==c end, msg{ref=c}} end
msg{"GeneralCommandFrame",
  map {ref="CommandIdentifier"},
  cmdref"ReadAttributes",
  cmdref"ReadAttributesResponse",
  cmdref"WriteAttributes",
  cmdref"WriteAttributesUndivided",
  cmdref"WriteAttributesResponse",
  cmdref"WriteAttributesNoResponse",
  cmdref"ConfigureReporting",
  cmdref"ConfigureReportingResponse",
  cmdref"ReadReportingConfiguration",
  cmdref"ReadReportingConfigurationResponse",
  cmdref"ReportAttributes",
  cmdref"DefaultResponse",
  cmdref"DiscoverAttributes",
  cmdref"DiscoverAttributesResponse",
  cmdref"ReadAttributesStructured",
  cmdref"WriteAttributesStructured",
  cmdref"WriteAttributesStructuredResponse",
  cmdref"DiscoverCommandsReceived",
  cmdref"DiscoverCommandsReceivedResponse",
  cmdref"DiscoverCommandsGenerated",
  cmdref"DiscoverCommandsGeneratedResponse",
  cmdref"DiscoverAttributesExtended",
  cmdref"DiscoverAttributesExtendedResponse",
}

map {"Type", type=t_U8, register=true, values={
  {"nodata",    0x00, 0xFF},
  {"data8",     0x08, 0xFF},
  {"data16",    0x09, 0xFF},
  {"data24",    0x0a, 0xFF},
  {"data32",    0x0b, 0xFF},
  {"data40",    0x0c, 0xFF},
  {"data48",    0x0d, 0xFF},
  {"data56",    0x0e, 0xFF},
  {"data64",    0x0f, 0xFF},
  {"bool",      0x10, 0xFF},
  {"map8",      0x18, 0xFF},
  {"map16",     0x19, 0xFF},
  {"map24",     0x1a, 0xFF},
  {"map32",     0x1b, 0xFF},
  {"map40",     0x1c, 0xFF},
  {"map48",     0x1d, 0xFF},
  {"map56",     0x1e, 0xFF},
  {"map64",     0x1f, 0xFF},
  {"uint8",     0x20, 0xFF},
  {"uint16",    0x21, 0xFF},
  {"uint24",    0x22, 0xFF},
  {"uint32",    0x23, 0xFF},
  {"uint40",    0x24, 0xFF},
  {"uint48",    0x25, 0xFF},
  {"uint56",    0x26, 0xFF},
  {"uint64",    0x27, 0xFF},
  {"int8",      0x28, 0xFF},
  {"int16",     0x29, 0xFF},
  {"int24",     0x2a, 0xFF},
  {"int32",     0x2b, 0xFF},
  {"int40",     0x2c, 0xFF},
  {"int48",     0x2d, 0xFF},
  {"int56",     0x2e, 0xFF},
  {"int64",     0x2f, 0xFF},
  {"enum8",     0x30, 0xFF},
  {"enum16",    0x31, 0xFF},
  {"semi",      0x38, 0xFF},
  {"single",    0x39, 0xFF},
  {"double",    0x3a, 0xFF},
  {"octstr",    0x41, 0xFF},
  {"string",    0x42, 0xFF},
  {"octstr16",  0x43, 0xFF},
  {"string16",  0x44, 0xFF},
  {"array",     0x48, 0xFF},
  {"struct",    0x4c, 0xFF},
  {"set",       0x50, 0xFF},
  {"bag",       0x51, 0xFF},
  {"ToD",       0xe0, 0xFF},
  {"date",      0xe1, 0xFF},
  {"UTC",       0xe2, 0xFF},
  {"clusterId", 0xe8, 0xFF},
  {"attribId",  0xe9, 0xFF},
  {"bacOID",    0xea, 0xFF},
  {"EUI64",     0xf0, 0xFF},
  {"key128",    0xf1, 0xFF},
  {"unk",       0xff, 0xFF}
}}

local function iftype(t, ...) return opt{nil, when=function(v) return v.Type==t end, ...} end
msg{"Attribute",
  map {ref="Type"},
  iftype("data8", arr{"Value", type=t_U8, length=1}),
  iftype("data16", arr{"Value", type=t_U8, length=2}),
  iftype("data24", arr{"Value", type=t_U8, length=3}),
  iftype("data32", arr{"Value", type=t_U8, length=4}),
  iftype("data40", arr{"Value", type=t_U8, length=5}),
  iftype("data48", arr{"Value", type=t_U8, length=6}),
  iftype("data56", arr{"Value", type=t_U8, length=7}),
  iftype("data64", arr{"Value", type=t_U8, length=8}),
  iftype("bool", bool{"Value"}),
  iftype("map8", bmap{"Value", bytes=1}),
  iftype("map16", bmap{"Value", bytes=2}),
  iftype("map24", bmap{"Value", bytes=3}),
  iftype("map32", bmap{"Value", bytes=4}),
  iftype("map40", bmap{"Value", bytes=5}),
  iftype("map48", bmap{"Value", bytes=6}),
  iftype("map56", bmap{"Value", bytes=7}),
  iftype("map64", bmap{"Value", bytes=8}),
  iftype("uint8", U8{"Value"}),
  iftype("uint16", U16{"Value"}),
  iftype("uint24", U24{"Value"}),
  iftype("uint32", U32{"Value"}),
  iftype("uint40", U40{"Value"}),
  iftype("uint48", U48{"Value"}),
  iftype("uint56", U56{"Value"}),
  iftype("uint64", U64{"Value"}),
  iftype("int8", I8{"Value"}),
  iftype("int16", I16{"Value"}),
  iftype("int24", I24{"Value"}),
  iftype("int32", I32{"Value"}),
  iftype("int40", I40{"Value"}),
  iftype("int48", I48{"Value"}),
  iftype("int56", I56{"Value"}),
  iftype("int64", I64{"Value"}),
  iftype("enum8", U8{"Value"}),
  iftype("enum16", U16{"Value"}),
  iftype("semi", U16{"Value", const=0xFFFF}), -- not yet implemented!
  iftype("single", float{"Value"}),
  iftype("double", double{"Value"}),
  iftype("octstr", arr{"Value", asstring=true, type=t_U8, counter=t_U8}),

  -- some messages from Aqara buttons have a string value that has a length indication that is
  -- wrong by 1 Byte - which is missing in the packet's payload. We substitute this
  -- with a zero byte
  iftype("string", arr{"Value", asstring=true, type=t_U8, counter=t_U8, fill_zero=true}),

  iftype("octstr16", arr{"Value", asstring=true, type=t_U8, counter=t_U16}),
  iftype("string16", arr{"Value", asstring=true, type=t_U8, counter=t_U16}),
  iftype("array", nil), -- not yet implemented
  iftype("struct", arr{"Members", counter=t_U16, msg{ref="Attribute"}}),
  iftype("set", nil), -- not yet implemented
  iftype("bag", nil), -- not yet implemented
  iftype("ToD", U32{"Value"}),
  iftype("date", U32{"Value"}),
  iftype("UTC", U32{"Value"}),
  iftype("clusterId", U16{"Value"}),
  iftype("attribId", U16{"Value"}),
  iftype("bacOID", U32{"Value"}),
  iftype("EUI64", arr{"Value", ashex=true, type=t_U8, length=8}),
  iftype("key128", arr{"Value", ashex=true, type=t_U8, length=16}),
  iftype("unk", nil)
}


msg{"ReadAttributes",
  arr {"AttributeIdentifiers", type=t_U16}
}

msg{"ReadAttributesResponse",
  arr {"ReadAttributeStatusRecords",
    U16 {"AttributeIdentifier"},
    map {ref="Status"},
    opt {nil, when=function(v) return v.Status=="SUCCESS" end, msg{ref="Attribute"}}
  }
}

msg{"WriteAttributes",
  arr {"WriteAttributeRecords",
    U16 {"AttributeIdentifier"},
    msg {ref="Attribute"}
  }
}

msg{"WriteAttributesUndivided",
  arr {"WriteAttributeRecords",
    U16 {"AttributeIdentifier"},
    msg {ref="Attribute"}
  }
}

msg{"WriteAttributesResponse",
  arr {"WriteAttributeStatusRecords",
    map {ref="Status"},
    opt {nil, when=more_data("AttributeIdentifier"), U16{"AttributeIdentifier"}}
  }
}

msg{"WriteAttributesNoResponse",
  arr {"WriteAttributeRecords",
    U16 {"AttributeIdentifier"},
    msg {ref="Attribute"}
  }
}

msg{"ConfigureReporting",
  arr {"AttributeReportingConfigurationRecords",
    U8  {"Direction", default=0},
    U16 {"AttributeIdentifier"},
    opt {nil, when=function(v) return v.Direction==0 end,
      map {ref="Type"},
      U16 {"MinimumReportingInterval"},
      U16 {"MaximumReportingInterval"},
      iftype("uint8", U8{"Value"}),
      iftype("uint16", U16{"Value"}),
      iftype("uint24", U24{"Value"}),
      iftype("uint32", U32{"Value"}),
      iftype("uint40", U40{"Value"}),
      iftype("uint48", U48{"Value"}),
      iftype("uint56", U56{"Value"}),
      iftype("uint64", U64{"Value"}),
      iftype("int8", I8{"Value"}),
      iftype("int16", I16{"Value"}),
      iftype("int24", I24{"Value"}),
      iftype("int32", I32{"Value"}),
      iftype("int40", I40{"Value"}),
      iftype("int48", I48{"Value"}),
      iftype("int56", I56{"Value"}),
      iftype("int64", I64{"Value"}),
      iftype("semi", U16{"Value", const=0xFFFF}), -- not yet implemented!
      iftype("single", float{"Value"}),
      iftype("double", double{"Value"}),
      iftype("ToD", U32{"Value"}),
      iftype("date", U32{"Value"}),
      iftype("UTC", U32{"Value"})
    },
    opt {nil, when=function(v) return v.Direction==1 end,
      U16 {"TimeoutPeriod"}
    }
  }
}

msg{"ConfigureReportingResponse",
  arr {"AttributeStatusRecords",
    map {ref="Status"},
    U8  {"Direction", default=0},
    U16 {"AttributeIdentifier"}
  }
}

msg{"ReadReportingConfiguration",
  arr {"AttributeRecords",
    U8  {"Direction", default=0},
    U16 {"AttributeIdentifier"}
  }
}

msg{"ReadReportingConfigurationResponse",
  arr {"AttributeReportingConfigurationRecords",
    map {ref="Status"},
    U8  {"Direction", default=0},
    U16 {"AttributeIdentifier"},
    opt {nil, when=function(v) return v.Direction==0 end,
      map {ref="Type"},
      U16 {"MinimumReportingInterval"},
      U16 {"MaximumReportingInterval"},
      iftype("uint8", U8{"uint8"}),
      iftype("uint16", U16{"uint16"}),
      iftype("uint24", U24{"uint24"}),
      iftype("uint32", U32{"uint32"}),
      iftype("uint40", U40{"uint40"}),
      iftype("uint48", U48{"uint48"}),
      iftype("uint56", U56{"uint56"}),
      iftype("uint64", U64{"uint64"}),
      iftype("int8", I8{"int8"}),
      iftype("int16", I16{"int16"}),
      iftype("int24", I24{"int24"}),
      iftype("int32", I32{"int32"}),
      iftype("int40", I40{"int40"}),
      iftype("int48", I48{"int48"}),
      iftype("int56", I56{"int56"}),
      iftype("int64", I64{"int64"}),
      iftype("semi", U16{"semi", const=0xFFFF}), -- not yet implemented!
      iftype("single", float{"single"}),
      iftype("double", double{"double"}),
      iftype("ToD", U32{"ToD"}),
      iftype("date", U32{"date"}),
      iftype("UTC", U32{"UTC"})
    },
    opt {nil, when=function(v) return v.Direction==1 end,
      U16 {"TimeoutPeriod"}
    }
  }
}

msg{"ReportAttributes",
  arr {"AttributeReports",
    U16 {"AttributeIdentifier"},
    msg {ref="Attribute"}
  }
}

msg{"DefaultResponse",
  --map {ref="CommandIdentifier"},
  U8  {"CommandIdentifier"},
  map {ref="Status"}
}

msg{"DiscoverAttributes",
  U16 {"StartAttributeIdentifier"},
  U8  {"MaximumAttributeIdentifiers"}
}

msg{"DiscoverAttributesResponse",
  bool{"DiscoveryComplete"},
  arr {"AttributeInformations",
    U16 {"AttributeIdentifier"},
    map {ref="Type"}
  }
}

msg{"ReadAttributesStructured",
  arr {"AttributeSelectors",
    U16 {"AttributeIdentifier"},
    msg {ref="Selector"}
  }
}
msg{"Selector",
  -- TODO: implement special behaviour for arrays, structs, sets, bags
  arr {"Index", type=t_U16, counter=t_U8}
}

msg{"WriteAttributesStructured",
  arr {"WriteAttributeRecords",
    U16 {"AttributeIdentifier"},
    msg {ref="Selector"},
    msg {ref="Attribute"}
  }
}

msg{"WriteAttributesStructuredResponse",
  arr {"WriteAttributeStatusRecords",
    map {ref="Status"},
    U16 {"AttributeIdentifier"},
    msg {ref="Selector"}
  }
}

msg{"DiscoverCommandsReceived",
  U8  {"StartCommandIdentifier"},
  U8  {"MaximumCommandIdentifier"}
}

msg{"DiscoverCommandsReceivedResponse",
  bool{"DiscoveryComplete"},
  arr {"CommandIdentifiers", type=t_U8}
}

msg{"DiscoverCommandsGenerated",
  U8  {"StartCommandIdentifier"},
  U8  {"MaximumCommandIdentifier"}
}

msg{"DiscoverCommandsGeneratedResponse",
  bool{"DiscoveryComplete"},
  arr {"CommandIdentifiers", type=t_U8}
}

msg{"DiscoverAttributesExtended",
  U16 {"StartAttributeIdentifier"},
  U8  {"MaximumAttributeIdentifiers"}
}

msg{"DiscoverAttributesExtendedResponse",
  bool{"DiscoveryComplete"},
  arr {"ExtendedAttributeInformations",
    U16 {"AttributeIdentifier"},
    map {ref="Type"},
    map {"AttributeAccessControl", type=t_U8, values={
      {"Readable",   B"001"},
      {"Writable",   B"010"},
      {"Reportable", B"100"}}}
  }
}

--------------------------------------------------------------------------

local function commandfromserver(c)
  return opt {nil, when=function(_,_,ctx,r) return contains(r.FrameControl, {"DirectionFromServer"}) end, map {"CommandIdentifier", type=t_U8, values=c}}
end
local function commandtoserver(c)
  return opt {nil, when=function(_,_,ctx,r) return contains(r.FrameControl, {"DirectionToServer"}) end, map {"CommandIdentifier", type=t_U8, values=c}}
end

-- BASIC CLUSTER

msg{"BasicClusterFrame",
  commandtoserver{
    {"ResetToFactoryDefaults",  0x00, 0xFF}
  }
}

-- POWER CONFIGURATION CLUSTER

msg{"PowerConfigurationClusterFrame"}

-- DEVICE TEMPERATURE CONFIGURATION CLUSTER

msg{"DeviceTemperatureConfigurationClusterFrame"}

-- IDENTIFY CLUSTER

msg{"IdentifyClusterFrame",
  commandtoserver{
    {"Identify",                0x00, 0xFF},
    {"IdentifyQuery",           0x01, 0xFF},
    {"TriggerEffect",           0x40, 0xFF}
  },
  commandfromserver{
    {"IdentifyQueryResponse",   0x00, 0xFF}
  },
  cmdref"Identify",
  cmdref"TriggerEffect",
  cmdref"IdentifyQueryResponse"
}

msg{"Identify",
  U16 {"IdentifyTime"}
}

msg{"TriggerEffect",
  map {"EffectIdentifier", type=t_U8, values={
    {"Blink",           0x00, 0xFF},
    {"Breathe",         0x01, 0xFF},
    {"Okay",            0x02, 0xFF},
    {"ChannelChange",   0x0b, 0xFF},
    {"FinishEffect",    0xfe, 0xFF},
    {"StopEffect",      0xff, 0xFF}
  }},
  map {"EffectVariant", type=t_U8, values={
    {"Default",         0x00, 0xFF}
  }}
}

msg{"IdentifyQueryResponse",
  U16 {"Timeout"}
}

-- GROUPS CLUSTER

msg{"GroupsClusterFrame",
  commandtoserver{
    {"AddGroup",                0x00, 0xFF},
    {"ViewGroup",               0x01, 0xFF},
    {"GetGroupMembership",      0x02, 0xFF},
    {"RemoveGroup",             0x03, 0xFF},
    {"RemoveAllGroups",         0x04, 0xFF},
    {"AddGroupIfIdentifying",   0x05, 0xFF}
  },
  commandfromserver{
    {"AddGroupResponse",            0x00, 0xFF},
    {"ViewGroupResponse",           0x01, 0xFF},
    {"GetGroupMembershipResponse",  0x02, 0xFF},
    {"RemoveGroupResponse",         0x03, 0xFF}
  },
  cmdref"AddGroup",
  cmdref"ViewGroup",
  cmdref"GetGroupMembership",
  cmdref"RemoveGroup",
  cmdref"AddGroupIfIdentifying",
  cmdref"AddGroupResponse",
  cmdref"ViewGroupResponse",
  cmdref"GetGroupMembershipResponse",
  cmdref"RemoveGroupResponse"
}

msg{"AddGroup",
  U16 {"GroupId"},
  arr {"GroupName", asstring=true, type=t_U8, counter=t_U8}
}

msg{"ViewGroup",
  U16 {"GroupId"}
}

msg{"GetGroupMembership",
  arr {"Groups", type=t_U16, counter=t_U8}
}

msg{"RemoveGroup",
  U16 {"GroupId"}
}

msg{"AddGroupIfIdentifying",
  U16 {"GroupId"},
  arr {"GroupName", asstring=true, type=t_U8, counter=t_U8}
}

msg{"AddGroupResponse",
  map {ref="Status"},
  U16 {"GroupId"}
}

msg{"ViewGroupResponse",
  map {ref="Status"},
  U16 {"GroupId"},
  arr {"GroupName", asstring=true, type=t_U8, counter=t_U8}
}

msg{"GetGroupMembershipResponse",
  U8  {"Capacity"},
  arr {"Groups", type=t_U16, counter=t_U8}
}

msg{"RemoveGroupResponse",
  map {ref="Status"},
  U16 {"GroupId"}
}
  
-- SCENES CLUSTER  

msg{"ScenesClusterFrame",
  commandtoserver{
    {"AddScene",            0x00, 0xFF},
    {"ViewScene",           0x01, 0xFF},
    {"RemoveScene",         0x02, 0xFF},
    {"RemoveAllScenes",     0x03, 0xFF},
    {"StoreScene",          0x04, 0xFF},
    {"RecallScene",         0x05, 0xFF},
    {"GetSceneMembership",  0x06, 0xFF},
    {"EnhancedAddScene",    0x40, 0xFF},
    {"EnhancedViewScene",   0x41, 0xFF},
    {"CopyScene",           0x42, 0xFF}
  },
  commandfromserver{
    {"AddSceneResponse",            0x00, 0xFF},
    {"ViewSceneResponse",           0x01, 0xFF},
    {"RemoveSceneResponse",         0x02, 0xFF},
    {"RemoveAllScenesResponse",     0x03, 0xFF},
    {"StoreSceneResponse",          0x04, 0xFF},
    {"RecallSceneResponse",         0x05, 0xFF},
    {"GetSceneMembershipResponse",  0x06, 0xFF},
    {"EnhancedAddSceneResponse",    0x40, 0xFF},
    {"EnhancedViewSceneResponse",   0x41, 0xFF},
    {"CopySceneResponse",           0x42, 0xFF}
  },
  cmdref"AddScene",
  cmdref"ViewScene",
  cmdref"RemoveScene",
  cmdref"RemoveAllScenes",
  cmdref"StoreScene",
  cmdref"RecallScene",
  cmdref"GetSceneMembership",
  cmdref"EnhancedAddScene",
  cmdref"EnhancedViewScene",
  cmdref"CopyScene",
  cmdref"AddSceneResponse",
  cmdref"ViewSceneResponse",
  cmdref"RemoveSceneResponse",
  cmdref"RemoveAllScenesResponse",
  cmdref"StoreSceneResponse",
  cmdref"RecallSceneResponse",
  cmdref"GetSceneMembershipResponse",
  cmdref"EnhancedAddSceneResponse",
  cmdref"EnhancedViewSceneResponse",
  cmdref"CopySceneResponse",
}

msg{"AddScene",
  U16 {"GroupId"},
  U8  {"SceneId"},
  U16 {"TransitionTime"},
  arr {"SceneName", asstring=true, type=t_U8, counter=t_U8},
  arr {"ExtensionFieldSets",
    U16 {"ClusterId"},
    -- TODO: better reflect content of extension field sets
    arr {"ExtensionFieldSetData", type=t_U8, counter=t_U8}
  }
}
msg{"AddSceneResponse",
  map {ref="Status"},
  U16 {"GroupId"},
  U8  {"SceneId"}
}

msg{"ViewScene",
  U16 {"GroupId"},
  U8  {"SceneId"}
}
msg{"ViewSceneResponse",
  map {ref="Status"},
  U16 {"GroupId"},
  U8  {"SceneId"},
  U16 {"TransitionTime"},
  arr {"SceneName", asstring=true, type=t_U8, counter=t_U8},
  arr {"ExtensionFieldSets",
    U16 {"ClusterId"},
    arr {"ExtensionFieldSetData", type=t_U8, counter=t_U8}
  }
}

msg{"RemoveScene",
  U16 {"GroupId"},
  U8  {"SceneId"}
}
msg{"RemoveSceneResponse",
  map {ref="Status"},
  U16 {"GroupId"},
  U8  {"SceneId"}
}

msg{"RemoveAllScenes",
  U16 {"GroupId"}
}
msg{"RemoveAllScenesResponse",
  map {ref="Status"},
  U16 {"GroupId"}
}

msg{"StoreScene",
  U16 {"GroupId"},
  U8  {"SceneId"}
}
msg{"StoreSceneResponse",
  map {ref="Status"},
  U16 {"GroupId"},
  U8  {"SceneId"}
}

msg{"RecallScene",
  U16 {"GroupId"},
  U8  {"SceneId"}
}
msg{"RecallSceneResponse",
  map {ref="Status"},
  U16 {"GroupId"},
  U8  {"SceneId"}
}

msg{"GetSceneMembership",
  U16 {"GroupId"}
}
msg{"GetSceneMembershipResponse",
  map {ref="Status"},
  U8  {"Capacity"},
  U16 {"GroupId"},
  arr {"Scenes", type=t_U8, counter=t_U8}
}

msg{"EnhancedAddScene",
  U16 {"GroupId"},
  U8  {"SceneId"},
  U16 {"TransitionTime"},
  arr {"SceneName", asstring=true, type=t_U8, counter=t_U8},
  arr {"ExtensionFieldSets",
    U16 {"ClusterId"},
    -- TODO: better reflect content of extension field sets
    arr {"ExtensionFieldSetData", type=t_U8, counter=t_U8}
  }
}
msg{"EnhancedAddSceneResponse",
  map {ref="Status"},
  U16 {"GroupId"},
  U8  {"SceneId"}
}

msg{"EnhancedViewScene",
  U16 {"GroupId"},
  U8  {"SceneId"}
}
msg{"EnhancedViewSceneResponse",
  map {ref="Status"},
  U16 {"GroupId"},
  U8  {"SceneId"},
  U16 {"TransitionTime"},
  arr {"SceneName", asstring=true, type=t_U8, counter=t_U8},
  arr {"ExtensionFieldSets",
    U16 {"ClusterId"},
    arr {"ExtensionFieldSetData", type=t_U8, counter=t_U8}
  }
}

msg{"CopyScene",
  U8  {"Mode"},
  U16 {"GroupIdFrom"},
  U8  {"SceneIdFrom"},
  U16 {"GroupIdTo"},
  U8  {"SceneIdTo"}
}
msg{"CopySceneResponse",
  map {ref="Status"},
  U16 {"GroupIdFrom"},
  U8  {"SceneIdFrom"}
}

-- ON/OFF CLUSTER

msg{"OnOffClusterFrame",
  commandtoserver{
    {"Off",                     0x00, 0xFF},
    {"On",                      0x01, 0xFF},
    {"Toggle",                  0x02, 0xFF},
    {"OffWithEffect",           0x40, 0xFF},
    {"OnWithRecallGlobalScene", 0x41, 0xFF},
    {"OnWithTimedOff",          0x42, 0xFF}
  },
  cmdref"OffWithEffect",
  cmdref"OnWithTimedOff",
}

msg{"OffWithEffect",
  map {"EffectIdentifier", type=t_U8, values={
    {"DelayedAllOff",           0x00, 0xFF},
    {"DyingLight",              0x01, 0xFF}
  }},
  U8  {"EffectVariant", default=0} -- TODO: map all variants? Identifyer specific...
}

msg{"OnWithTimedOff",
  U8  {"OnOffControl", default=0}, -- TODO: map this?
  U16 {"OnTime"},
  U16 {"OffWaitTime"}
}

-- ON/OFF SWITCH CLUSTER

msg{"OnOffSwitchConfigurationClusterFrame"}

-- LEVEL CONTROL CLUSTER

msg{"LevelControlClusterFrame",
  commandtoserver{
    {"MoveToLevel",             0x00, 0xFF},
    {"Move",                    0x01, 0xFF},
    {"Step",                    0x02, 0xFF},
    {"Stop",                    0x03, 0xFF},
    {"MoveToLevelWithOnOff",    0x04, 0xFF},
    {"MoveWithOnOff",           0x05, 0xFF},
    {"StepWithOnOff",           0x06, 0xFF},
    {"Stop",                    0x07, 0xFF}
  },
  cmdref"MoveToLevel",
  cmdref"Move",
  cmdref"Step",
  cmdref"MoveToLevelWithOnOff",
  cmdref"MoveWithOnOff",
  cmdref"StepWithOnOff"
}

msg{"MoveToLevel",
  U8  {"Level"},
  U16 {"TransitionTime"}
}

msg{"Move",
  map {"MoveMode", type=t_U8, values={"Up", "Down"}},
  U8  {"Rate"}
}

msg{"Step",
  map {"StepMode", type=t_U8, values={"Up", "Down"}},
  U8  {"StepSize"},
  U16 {"TransitionTime"}
}

msg{"MoveToLevelWithOnOff",
  U8  {"Level"},
  U16 {"TransitionTime"}
}

msg{"MoveWithOnOff",
  map {"MoveMode", type=t_U8, values={"Up", "Down"}},
  U8  {"Rate"}
}

msg{"StepWithOnOff",
  map {"StepMode", type=t_U8, values={"Up", "Down"}},
  U8  {"StepSize"},
  U16 {"TransitionTime"}
}

-- ALARMS CLUSTER

msg{"AlarmsClusterFrame"
  -- TODO
}

-- TIME CLUSTER

msg{"TimeClusterFrame"}

-- RSSI LOCATION CLUSTER

msg{"RSSILocationClusterFrame"
  -- TODO
}

-- DIAGNOSTICS CLUSTER

msg{"DiagnosticsClusterFrame"}

-- POLL CONTROL CLUSTER

msg{"PollControlClusterFrame"}

-- POWER PROFILE CLUSTER

msg{"PowerProfileClusterFrame"}

-- METER IDENTIFICATION CLUSTER

msg{"MeterIdentificationClusterFrame"}

-- ANALOG INPUT CLUSTER

msg{"AnalogInputClusterFrame"}

-- ANALOG OUTPUT CLUSTER

msg{"AnalogOutputClusterFrame"}

-- ANALOG VALUE CLUSTER

msg{"AnalogValueClusterFrame"}

-- BINARY INPUT CLUSTER

msg{"BinaryInputClusterFrame"}

-- BINARY OUTPUT CLUSTER

msg{"BinaryOutputClusterFrame"}

-- BINARY VALUE CLUSTER

msg{"BinaryValueClusterFrame"}

-- MULTISTATE INPUT CLUSTER

msg{"MultistateInputClusterFrame"}

-- MULTISTATE OUTPUT CLUSTER

msg{"MultistateOutputClusterFrame"}

-- MULTISTATE VALUE CLUSTER

msg{"MultistateValueClusterFrame"}

-- ILLUMINANCE MEASUREMENT CLUSTER

msg{"IlluminanceMeasurementClusterFrame"}

-- ILLUMINANCE LEVEL SENSING CLUSTER

msg{"IlluminanceLevelSensingClusterFrame"}

-- TEMPERATURE MEASUREMENT CLUSTER

msg{"TemperatureMeasurementClusterFrame"}

-- PRESSURE MEASUREMENT CLUSTER

msg{"PressureMeasurementClusterFrame"}

-- FLOW MEASUREMENT CLUSTER

msg{"FlowMeasurementClusterFrame"}

-- RELATIVE HUMIDITY MEASUREMENT CLUSTER

msg{"RelativeHumidityMeasurementClusterFrame"}

-- OCCUPANCY SENSING CLUSTER

msg{"OccupancySensingClusterFrame"}

-- ELECTRICAL MEASUREMENT CLUSTER

msg{"ElectricalMeasurementClusterFrame"}

-- COLOR CONTROL CLUSTER

msg{"ColorControlClusterFrame",
  commandtoserver{
    {"MoveToHue",                       0x00, 0xFF},
    {"MoveHue",                         0x01, 0xFF},
    {"StepHue",                         0x02, 0xFF},
    {"MoveToSaturation",                0x03, 0xFF},
    {"MoveSaturation",                  0x04, 0xFF},
    {"StepSaturation",                  0x05, 0xFF},
    {"MoveToHueAndSaturation",          0x06, 0xFF},
    {"MoveToColor",                     0x07, 0xFF},
    {"MoveColor",                       0x08, 0xFF},
    {"StepColor",                       0x09, 0xFF},
    {"MoveToColorTemperature",          0x0a, 0xFF},
    {"EnhancedMoveToHue",               0x40, 0xFF},
    {"EnhancedMoveHue",                 0x41, 0xFF},
    {"EnhancedStepHue",                 0x42, 0xFF},
    {"EnhancedMoveToHueAndSaturation",  0x43, 0xFF},
    {"ColorLoopSet",                    0x44, 0xFF},
    {"StopMoveStep",                    0x47, 0xFF},
    {"MoveColorTemperature",            0x4b, 0xFF},
    {"StepColorTemperature",            0x4c, 0xFF}
  },
  cmdref"MoveToHue",
  cmdref"MoveHue",
  cmdref"StepHue",
  cmdref"MoveToSaturation",
  cmdref"MoveSaturation",
  cmdref"StepSaturation",
  cmdref"MoveToHueAndSaturation",
  cmdref"MoveToColor",
  cmdref"MoveColor",
  cmdref"StepColor",
  cmdref"MoveToColorTemperature",
  cmdref"EnhancedMoveToHue",
  cmdref"EnhancedMoveHue",
  cmdref"EnhancedStepHue",
  cmdref"EnhancedMoveToHueAndSaturation",
  cmdref"ColorLoopSet",
  cmdref"MoveColorTemperature",
  cmdref"StepColorTemperature"
}

msg{"MoveToHue",
  U8  {"Hue"},
  map {"Direction", type=t_U8, values={"ShortestDistance","LongestDistance","Up","Down"}},
  U16 {"TransitionTime", default=0}
}

msg{"MoveHue",
  map {"MoveMode", type=t_U8, values={"Stop","Up","Reserved","Down"}},
  U8  {"Rate"}
}

msg{"StepHue",
  map {"StepMode", type=t_U8, values={"Reserved","Up","Reserved","Down"}},
  U8  {"StepSize"},
  U8  {"TransitionTime"}
}

msg{"MoveToSaturation",
  U8  {"Saturation"},
  U16 {"TransitionTime", default=0}
}

msg{"MoveSaturation",
  map {"MoveMode", type=t_U8, values={"Stop","Up","Reserved","Down"}},
  U8  {"Rate"}
}

msg{"StepSaturation",
  map {"StepMode", type=t_U8, values={"Reserved","Up","Reserved","Down"}},
  U8  {"StepSize"},
  U8  {"TransitionTime"}
}

msg{"MoveToHueAndSaturation",
  U8  {"Hue"},
  U8  {"Saturation"},
  U16 {"TransitionTime", default=0}
}

msg{"MoveToColor",
  U16 {"ColorX"},
  U16 {"ColorY"},
  U16 {"TransitionTime"}
}

msg{"MoveColor",
  I16 {"RateX"},
  I16 {"RateY"}
}

msg{"StepColor",
  I16 {"StepX"},
  I16 {"StepY"},
  U16 {"TransitionTime"}
}

msg{"MoveToColorTemperature",
  U16 {"ColorTemperatureMireds"},
  U16 {"TransitionTime"}
}

msg{"EnhancedMoveToHue",
  U16 {"EnhancedHue"},
  map {"Direction", type=t_U8, values={"ShortestDistance","LongestDistance","Up","Down"}},
  U16 {"TransitionTime", default=0}
}

msg{"EnhancedMoveHue",
  map {"MoveMode", type=t_U8, values={"Stop","Up","Reserved","Down"}},
  U16 {"Rate"}
}

msg{"EnhancedStepHue",
  map {"StepMode", type=t_U8, values={"Reserved","Up","Reserved","Down"}},
  U16 {"StepSize"},
  U16 {"TransitionTime"}
}

msg{"EnhancedMoveToHueAndSaturation",
  U16 {"EnhancedHue"},
  U8  {"Saturation"},
  U16 {"TransitionTime", default=0}
}

msg{"ColorLoopSet",
  map {"UpdateFlags", type=t_U8, values={
    {"UpdateAction",      B"0001"},
    {"UpdateDirection",   B"0010"},
    {"UpdateTime",        B"0100"},
    {"UpdateStartHue",    B"1000"}
  }},
  map {"Action", type=t_U8, values={"DeactivateColorLoop","ActivateColorLoopStartHue","ActivateColorLoopCurrentHue"}},
  map {"Direction", type=t_U8, values={"DecrementHue","IncrementHue"}},
  U16 {"Time"},
  U16 {"StartHue"}
}

msg{"MoveColorTemperature",
  map {"MoveMode", type=t_U8, values={"Stop","Up","Reserved","Down"}},
  U16 {"Rate"},
  U16 {"ColorTemperatureMinimumMireds", default=0},
  U16 {"ColorTemperatureMaximumMireds", default=0}
}

msg{"StepColorTemperature",
  map {"StepMode", type=t_U8, values={"Reserved","Up","Reserved","Down"}},
  U16 {"StepSize"},
  U16 {"TransitionTime"},
  U16 {"ColorTemperatureMinimumMireds", default=0},
  U16 {"ColorTemperatureMaximumMireds", default=0}
}

-- BALLAST CONFIGURATION CLUSTER

msg{"BallastConfigurationClusterFrame"}

end)
