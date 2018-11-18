return function()

msg{"Frame",
  map {"FrameControl", type=t_U8, values={
    {"FrameTypeGlobal",         B"00000000", B"00000011"},
    {"FrameTypeLocal",          B"00000001", B"00000011"},
    {"ManufacturerSpecific",    B"00000100", B"00000100"},
    {"DirectionFromServer",     B"00001000", B"00001000"},
    {"DirectionToServer",       B"00000000", B"00001000"},
    {"DisableDefaultResponse",  B"00010000", B"00010000"}}},
  opt {nil, when=function(v) return contains(v.FrameControl, {"ManufacturerSpecific"}) end,
    U16 {"ManufacturerCode"}
  }
}

end
