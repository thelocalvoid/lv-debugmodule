Enum = {}

Enum.EntryTypes = {
    Text3d =    {Name = "Text3d", Bag = "Text3dBag", HandlePrefix = "TEXT3D:"},
    Text2d =    {Name = "Text2d", Bag = "Text2dBag", HandlePrefix = "TEXT2D:"},
    Line3d =    {Name = "Line3d", Bag = "Line3dBag", HandlePrefix = "LINE3D:"},
    Path3d =    {Name = "Path3d", Bag = "Path3dBag", HandlePrefix = "PATH3D:"},
    Sphere3d =  {Name = "Sphere3d", Bag = "Sphere3dBag", HandlePrefix = "SPHERE3D:"},
}


Enum.ClientCameraStates = {
    GAMEPLAY = 1,
    FREECAM = 2,
    MAP2D = 3,
    MAP3D = 4,
    ORBIT = 5,
}


Enum.RenderOrder = {
    [1] = Enum.EntryTypes.Path3d.Name,
    [2] = Enum.EntryTypes.Line3d.Name,
    [3] = Enum.EntryTypes.Sphere3d.Name,
    [4] = Enum.EntryTypes.Text3d.Name,
    [5] = Enum.EntryTypes.Text2d.Name,
}


Enum.DynamicFunctions = {
    ["pos"] = {
        ["GetEntityCoords"] = GetEntityCoords,
        ["GetBlipCoords"] = GetBlipCoords,
    }
}


Enum.CharacterWidths = { -- #### ASCII printable characters (32-126)

}


Enum.ColorPresets = {
     --* default textColor
    ["white"] =     { r = 255,  g = 255,    b = 255 },
     --* default lineColor
    ["black"] =     { r = 0,    g = 0,      b = 0 },
    ["grey"] =      { r = 127,  g = 127,    b = 127 },
    ["red"] =       { r = 211,  g = 0,      b = 35 },
    ["orange"] =    { r = 219,  g = 58,     b = 0 },
    ["yellow"] =    { r = 229,  g = 153,    b = 0 },
    ["green"] =     { r = 0,    g = 214,    b = 82 },
    ["lightblue"] = { r = 0,    g = 149,    b = 229 },
    ["blue"] =      { r = 0,    g = 37,     b = 226 },
    ["purple"] =    { r = 82,   g = 0,      b = 224 },
    ["pink"] =      { r = 181,  g = 0,      b = 221 },
    --* addd moreeeeeee
} -- * vector3 didnt work when tested, may be my fault tho