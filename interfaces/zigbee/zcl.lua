return function()

local function more_data(name)
  return function(v, getc) if getc then return getc(true) else return v[name] end end
end
local function more_of(name) return opt{nil, when=more_data(name), msg{ref=name}} end

map{"Status", type=t_U8, values={
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
  return opt {nil, when=function(v,_,ctx) return contains(v.FrameControl, {"FrameTypeLocal"}) and ctx.ClusterId==id end, msg{ref=name.."ClusterFrame"}}
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
  clusterlocal(0x0005, "Scenes"),

  clusterlocal(0x0006, "OnOff"),
  clusterlocal(0x0007, "OnOffSwitchConfiguration"),
  clusterlocal(0x0008, "LevelControl"),

  clusterlocal(0x0009, "Alarms"),

  clusterlocal(0x000a, "Time"),
  clusterlocal(0x000b, "RSSILocation"),
  clusterlocal(0x0b05, "Diagnostics"),
  clusterlocal(0x0020, "PollControl"),
  clusterlocal(0x001a, "PowerProfile"),
  clusterlocal(0x0b01, "MeterIdentification"),

  clusterlocal(0x000c, "AnalogInput"),
  clusterlocal(0x000d, "AnalogOutput"),
  clusterlocal(0x000e, "AnalogValue"),
  clusterlocal(0x000f, "BinaryInput"),
  clusterlocal(0x0010, "BinaryOutput"),
  clusterlocal(0x0011, "BinaryValue"),
  clusterlocal(0x0012, "MultistateInput"),
  clusterlocal(0x0013, "MultistateOutput"),
  clusterlocal(0x0014, "MultistateValue"),
}

map {"CommandIdentifier", type=t_U8, values={
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

map {"Type", type=t_U8, values={
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
  iftype("data8", arr{"data8", type=t_U8, length=1}),
  iftype("data16", arr{"data16", type=t_U8, length=2}),
  iftype("data24", arr{"data24", type=t_U8, length=3}),
  iftype("data32", arr{"data32", type=t_U8, length=4}),
  iftype("data40", arr{"data40", type=t_U8, length=5}),
  iftype("data48", arr{"data48", type=t_U8, length=6}),
  iftype("data56", arr{"data56", type=t_U8, length=7}),
  iftype("data64", arr{"data64", type=t_U8, length=8}),
  iftype("bool", bool{"bool"}),
  iftype("map8", bmap{"map8", bytes=1}),
  iftype("map16", bmap{"map16", bytes=2}),
  iftype("map24", bmap{"map24", bytes=3}),
  iftype("map32", bmap{"map32", bytes=4}),
  iftype("map40", bmap{"map40", bytes=5}),
  iftype("map48", bmap{"map48", bytes=6}),
  iftype("map56", bmap{"map56", bytes=7}),
  iftype("map64", bmap{"map64", bytes=8}),
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
  iftype("enum8", U8{"enum8"}),
  iftype("enum16", U16{"enum16"}),
  iftype("semi", U16{"semi", const=0xFFFF}), -- not yet implemented!
  iftype("single", float{"single"}),
  iftype("double", double{"double"}),
  iftype("octstr", arr{"octstr", asstring=true, type=t_U8, counter=t_U8}),
  iftype("string", arr{"string", asstring=true, type=t_U8, counter=t_U8}),
  iftype("octstr16", arr{"octstr16", asstring=true, type=t_U8, counter=t_U16}),
  iftype("string16", arr{"string", asstring=true, type=t_U8, counter=t_U16}),
  iftype("array", nil), -- not yet implemented
  iftype("struct", nil), -- not yet implemented
  iftype("set", nil), -- not yet implemented
  iftype("bag", nil), -- not yet implemented
  iftype("ToD", U32{"ToD"}),
  iftype("date", U32{"date"}),
  iftype("UTC", U32{"UTC"}),
  iftype("clusterId", U16{"clusterId"}),
  iftype("attribId", U16{"attribId"}),
  iftype("bacOID", U32{"bacOID"}),
  iftype("EUI64", arr{"EUI64", ashex=true, type=t_U8, length=8}),
  iftype("key128", arr{"key128", ashex=true, type=t_U8, length=16}),
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
  map {ref="CommandIdentifier"},
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
      {"Readable",   B"001", B"111"},
      {"Writable",   B"010", B"111"},
      {"Reportable", B"100", B"111"}}}
  }
}

msg{"BasicClusterFrame",
  U8  {"CommandIdentifier"}
}

end
