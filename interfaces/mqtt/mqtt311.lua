return require"lib.codec"(function()



msg{"MQTT",
  bitfield{"Header", parts={
    {"RETAIN", length=1},
    {"QoS", length=2},
    {"DUP", length=1},
    map{"ControlPacketType", length=4, values={
      "Reserved",
      "CONNECT",
      "CONNACK",
      "PUBLISH",
      "PUBACK",
      "PUBREC",
      "PUBREL",
      "PUBCOMP",
      "SUBSCRIBE",
      "SUBACK",
      "UNSUBSCRIBE",
      "UNSUBACK",
      "PINGREQ",
      "PINGRESP",
      "DISCONNECT",
      "Reserved"
    }}
  }},
  arr{"Remainder", type=t_U8, counter=t_varint},
}

local function String(name) return arr{name, asstring=true, type=t_U8, counter=t_U16r} end

msg{"CONNECT",
  arr{"ProtocolName", asstring=true, type=t_U8, counter=t_U16r, default="MQTT"},
  U8{"ProtocolLevel", default=4},
  bitfield{"ConnectFlags", parts={
    {"Reserved", length=1, default=0},
    bool{"CleanSession", length=1, default=false},
    bool{"WillFlag", length=1, default=false},
    {"WillQoS", length=2, default=0},
    bool{"WillRetain", length=1, default=false},
    bool{"PasswordFlag", length=1, default=false},
    bool{"UserNameFlag", length=1, default=false},
  }},
  U16r{"KeepAlive", default=0},
  -- Payload:
  String("ClientIdentifier"),
  opt{nil, when=function(v) return v.ConnectFlags.WillFlag end,
    String("WillTopic"),
    String("WillMessage")
  },
  opt{nil, when=function(v) return v.ConnectFlags.UserNameFlag end, String("UserName")},
  opt{nil, when=function(v) return v.ConnectFlags.PasswordFlag end, String("Password")},
}

msg{"CONNACK",
  bitfield{"ConnectAcknowledgeFlags", parts={
    bool{"SessionPresent", length=1},
    {"Reserved", length=7, default=0},
  }},
  map{"ConnectReturnCode", type=t_U8, values={
    "ConnectionAccepted",
    "ConnectionRefusedUnacceptableProtocolVersion",
    "ConnectionRefusedIdentifierRejected",
    "ConnectionRefusedServerUnavailable",
    "ConnectionRefusedBadUserNameOrPassword",
    "ConnectionRefusedNotAuthorized"
  }},
}

msg{"PUBLISH",
  String("TopicName"),
  opt{nil, when=function(v,_,ctx) return ctx.QoS and ctx.QoS>0 end, U16r{"PacketIdentifier"}},
  arr{"Payload", type=t_U8},
}

msg{"PUBACK",
  U16r{"PacketIdentifier"},
}

msg{"PUBREC",
  U16r{"PacketIdentifier"},
}

msg{"PUBREL",
  U16r{"PacketIdentifier"},
}

msg{"PUBCOMP",
  U16r{"PacketIdentifier"},
}

msg{"SUBSCRIBE",
  U16r{"PacketIdentifier"},
  arr{"Payload",
    String("TopicFilter"),
    U8{"QoS"},
  },
}

msg{"SUBACK",
  U16r{"PacketIdentifier"},
  arr{"Payload", type=t_U8}, -- error on 0x80
}

msg{"UNSUBSCRIBE",
  U16r{"PacketIdentifier"},
  arr{"Payload",
    String("TopicFilter"),
  },
}

msg{"UNSUBACK",
  U16r{"PacketIdentifier"},
}

end)
