Debug = {}
Functions = {}
Debug.Resources = {}
Debug.EditorVariables = {}
Debug.VARIABLE_TOKEN = "DEBUG_VAR:TOKEN"

---Stores resource pointers.
---
---Each resource has two pointer tables:
---
---     `ResourceName` and `ResourceIndex`
--- Each table references the other, using the first index
--- 
--- Each table also contains other indexes:
--- 
--- **[2]**: EnabledResourceIndex - Points to resource's position in the;
--- @see Debug.EnabledResources table
Debug.ResourcePointers = {
    ['ResourceName'] = {}, -- Stores ResourceIndex and EnabledResourceIndex of ResourceName
    ['ResourceIndex'] = {}, -- Stores ResourceName and EnabledResourceIndex of ResourceIndex
}

Debug.EnabledResources = {}
local gResources = Debug.Resources
local gEnabledResources = Debug.EnabledResources
local gResourcePointers = Debug.ResourcePointers
    ---@type resourcepointer[]
    ---Table that stores all resource's pointers
    ---
    ---Accessed by the resource's index
    ---
    ---@see Debug.ResourcePointers
local gPointersIndex = gResourcePointers["ResourceIndex"]
    ---@type resourcepointer[]
    ---Table that stores all resource's pointers
    ---
    ---Accessed by the resource's name
    ---
    ---@see Debug.ResourcePointers
local gPointersName = gResourcePointers["ResourceName"]



local colorPresets = Enum.ColorPresets
local dynamicFunctions = Enum.DynamicFunctions
local eTypes = Enum.EntryTypes
local eRenderOrder = Enum.RenderOrder

ClientCameraState = Enum.ClientCameraStates.GAMEPLAY
ClientCoords = vector3(0.0,0.0,0.0)

local obsurdPrecisionScale = 1.0
AveragePadding = 0.0042220190798323 -- AT OBSURD SCALE




local function CalculateLetterAverage(char)
    print(char..":  ")
    SetTextFont(4)
    SetTextScale(1.0, obsurdPrecisionScale)
    BeginTextCommandWidth("STRING")
    AddTextComponentString(char)
    local singleWidth = EndTextCommandGetWidth(false)
    SetTextFont(4)
    SetTextScale(1.0, obsurdPrecisionScale)
    BeginTextCommandWidth("STRING")
    AddTextComponentString(char..char)
    local doubleWidth = EndTextCommandGetWidth(false)
    SetTextFont(4)
    SetTextScale(1.0, obsurdPrecisionScale)
    BeginTextCommandWidth("STRING")
    AddTextComponentString(char..char..char)
    local tripeWidth = EndTextCommandGetWidth(false)

    local letterAverage = ((singleWidth - (doubleWidth-singleWidth) + singleWidth - (tripeWidth-doubleWidth))/2)

    return singleWidth, letterAverage
end

local function CalculateTrueCharWidth(char, font, scale)
    SetTextFont(font or 4)
    SetTextScale(1.0, scale or obsurdPrecisionScale)
    BeginTextCommandWidth("STRING")
    AddTextComponentString(char)
    local singleWidth = EndTextCommandGetWidth(false)
    SetTextFont(font or 4)
    SetTextScale(1.0, scale or obsurdPrecisionScale)
    BeginTextCommandWidth("STRING")
    AddTextComponentString(char..char)
    local doubleWidth = EndTextCommandGetWidth(false)

    return doubleWidth - singleWidth
end

local baseWidth = CalculateTrueCharWidth("B", 0, 1.0)

local function CalculateTrueScale(givenScale)
    --* compare givenScale with baseScale

    local givenWidth = CalculateTrueCharWidth("B", 0, givenScale)

    local trueScale = givenWidth/baseWidth

    return trueScale

end

for i = 0.1, 20, 0.1 do
    local trueScale = CalculateTrueScale(i)
    -- print("TRUE: "..trueScale, "GIVEN: "..i)
    if i == trueScale then
        -- print("^4GIVEN = TRUE")
    end
end

local function step(string, char)
    string = string..char
    SetTextFont(4)
    SetTextScale(1.0, obsurdPrecisionScale)
    BeginTextCommandWidth("STRING")
    AddTextComponentString(string)
    local width = EndTextCommandGetWidth(false)
    return width, string
end

local function CalculateDeltas()
    for i = 32, 126, 1 do
        local char = string.char(i)
        local string = char
        local delta = 0.0
        local lowest = {
            delta = 100.0, iteration = 0, value = 0.0
        }

        SetTextFont(4)
        SetTextScale(1.0, obsurdPrecisionScale)
        BeginTextCommandWidth("STRING")
        AddTextComponentString(char)
        local baseWidth = EndTextCommandGetWidth(false)
        local lastWidth = baseWidth
        local lastCharWidth = 0.0
        -- local lastPadding = 0.0

        for i2 = 2, 32, 1 do
            local currentWidth, tempString = step(string, char)
            string = tempString
            -- local currentPadding = baseWidth - (currentWidth-lastWidth)
            local charWidth = currentWidth - lastWidth
            delta = charWidth - lastCharWidth
            -- if delta < lowest.delta then
            --     lowest.delta = delta
            --     lowest.value = currentPadding
            --     lowest.iteration = i2
            -- end
            lastWidth = currentWidth
            -- lastPadding = currentPadding
            lastCharWidth = charWidth
            print(char, i2, charWidth, delta)
        end
        -- print(char, "Lowest Delta: ".. "at: "..lowest.iteration)
    end
end

-- CalculateDeltas()

function GenerateASCIICharacterWidths()
    for i = 32, 126, 1 do
        local char = string.char(i)
        local textWidth --[[ , letterAverage ]] = CalculateTrueCharWidth(char, 0, 1.0)
        Enum.CharacterWidths[i] = textWidth -- - letterAverage -- STORE AT OBSURD SCALE FOR PRECISION
    end
end
GenerateASCIICharacterWidths()



local function TestASCIICharacterWidths()
    local letterAverage = 0.0
    local totalAverage = 0.0
    for i = 32, 125, 1 do
        local char = string.char(i)
        print(char..":  ")
        SetTextFont(4)
        SetTextScale(1.0, obsurdPrecisionScale)
        BeginTextCommandWidth("STRING")
        AddTextComponentString(char)
        local singleWidth = EndTextCommandGetWidth(true)
        SetTextFont(4)
        SetTextScale(1.0, obsurdPrecisionScale)
        BeginTextCommandWidth("STRING")
        AddTextComponentString(char..char)
        local doubleWidth = EndTextCommandGetWidth(true)
        SetTextFont(4)
        SetTextScale(1.0, obsurdPrecisionScale)
        BeginTextCommandWidth("STRING")
        AddTextComponentString(char..char..char)
        local tripeWidth = EndTextCommandGetWidth(true)
        print("^5 "..singleWidth, doubleWidth, tripeWidth)
        print("^1 compared", doubleWidth-singleWidth, tripeWidth-doubleWidth)

        print("^3 error", singleWidth - (doubleWidth-singleWidth), singleWidth - (tripeWidth-doubleWidth))


        letterAverage = (singleWidth - (doubleWidth-singleWidth) + singleWidth - (tripeWidth-doubleWidth))/2
        totalAverage = totalAverage + letterAverage
    print("letterAverage: "..letterAverage)
    end
    print("totalAverage: "..(totalAverage/(125-32)))
end

-- TestASCIICharacterWidths()




local function CreateEntryTable()
    local newTable = {}
    for typeIndex = 1, #eRenderOrder do
        newTable[typeIndex] = {}
    end
    return newTable
end

Debug.Entries = {}
local gEntries = Debug.Entries

Debug.EntryHandles = {}
local gEntryHandles = Debug.EntryHandles

Debug.Pools = {}
Debug.PoolSizes = {
    [eTypes.Text3d.Name]    = 128,
    [eTypes.Text2d.Name]    = 128,
    [eTypes.Line3d.Name]    = 128,
    [eTypes.Path3d.Name]    = 32,
    [eTypes.Sphere3d.Name]  =  32,
}
Debug.PoolStructures = {
    [eTypes.Text3d.Name] = function ()
        return {
            scale = 1.0,
            font = 4,
            lines = {},
            pos = function ()
                return vector3(0.0,0.0,0.0)
            end
        }
    end,
    [eTypes.Text2d.Name] = function ()
        return {
            scale = 1.0,
            font = 4,
            lines = {},
        }
    end,
    [eTypes.Line3d.Name] = function ()
        return {} -- TODO:
    end,
    [eTypes.Path3d.Name] = function ()
        return {} -- TODO:
    end,
    [eTypes.Sphere3d.Name] = function ()
        return {} -- TODO:
    end,
}

Debug.Module = {}

GetEntryIdFromHandle = function (resourceIndex, handle)
    return gEntryHandles[resourceIndex][handle][2]
end

GetEntryTypeIndexFromHandle = function (resourceIndex, handle)
    return gEntryHandles[resourceIndex][handle][1]
end

GetEntryTypeIndexFromEntryTypeName = function (entryTypeName)
    for index, value in ipairs(eRenderOrder) do
        if value == entryTypeName then
            return index
        end
    end
end
GetEntryTypeNameFromEntryTypeIndex = function (renderIndex)
    for index, value in ipairs(eRenderOrder) do
        if index == renderIndex then
            return value
        end
    end
end

---**`CDEBUG` `INTERNAL`**
---```
---resourceIndex: The index of resource
---```
---Retrieves the resource name from a resource index
---
---@return string|nil @The resource's name or nil if **resourceIndex** is invalid
---@param resourceIndex integer
GetResourceNameFromIndex = function (resourceIndex)
    if gPointersIndex[resourceIndex] then
        return gPointersIndex[resourceIndex][1]
    end
    return nil
end

---**`CDEBUG` `INTERNAL`**
---```
---resourceName: The name of resource
---```
---Retrieves the resource index from a resource name
---
---@return integer|nil @The resource's index or nil if **resourceName** is invalid
---@param resourceName string
GetResourceIndexFromName = function (resourceName)
    if gPointersName[resourceName] then
        return gPointersName[resourceName][1]
    end
    return nil
end

GetResourceEnabledIndexFromName = function (input)
    if gPointersName[input] then
        return gPointersName[input][2]
    end
    return nil
end
GetResourceEnabledIndexFromIndex = function (input)
    if gPointersIndex[input] then
        return gPointersIndex[input][2]
    end
    return nil
end

SetNewResourceIndex = function (oldIndex, newIndex)
    local name = GetResourceNameFromIndex(oldIndex)
    local eIndex  GetResourceEnabledIndexFromName(name)
    gPointersName[name][1] = newIndex
    gPointersIndex[oldIndex] = nil
    gPointersIndex[newIndex] = { name, eIndex }

    local entryData = table.remove(gEntries[oldIndex])
    table.insert(gEntries, newIndex, entryData)

    local entryHandleData = table.remove(gEntryHandles[oldIndex])
    table.insert(gEntryHandles, newIndex, entryHandleData)

end

SetResourceEnabledIndexFromName = function (name, value)
    local index = GetResourceIndexFromName(name)
    gPointersIndex[index][2] = value
    gPointersName[name][2] = value
end
SetResourceEnabledIndexFromIndex = function (index, value)
    local name = GetResourceNameFromIndex(index)
    gPointersIndex[index][2] = value
    gPointersName[name][2] = value
end

Debug.GenerateBags = function () --* Unused
    for _, eType in pairs(eTypes) do
        Debug.Global.Bags[eType.Name] = {}
    end
end

local ResetPoolItem = function (item)
    return item.GetPoolStructure()
end

local NewPool = function (eTypeName)
    local newPool = {}

    local poolItems = {}
    local poolSize = Debug.PoolSizes[eTypeName]
    local GetPoolStructure = Debug.PoolStructures[eTypeName]

    for itemNum = 1, poolSize, 1 do
        poolItems[itemNum] = GetPoolStructure()
    end
    
    newPool.items = poolItems
    newPool.TypeName = eTypeName
    newPool.itemsAvailable = poolSize -- * Incase #table doesnt work | IT DOES WORK BUT I THINK I WILL KEEP THIS FOR STATS
    newPool.maxItems = poolSize
    newPool.GetStructure = GetPoolStructure
    
    function newPool:TakeItemFromPool()
        if #self.items > 0 then
            self.itemsAvailable = self.itemsAvailable - 1
            print(self.TypeName, self.itemsAvailable, "( item taken )")
            return table.remove(self.items)
        else
            print(self.TypeName, "( item created )")
            return self.GetStructure()
        end
    end
    function newPool:ReturnItemToPool(item)
        -- DELETE ITEM IF POOL IS FULL
        if #self.items >= self.maxItems then
            item = nil
            return
        end

        -- RESET ITEM WITH CLEAN STRUCTURE
        item = ResetPoolItem(item)

        -- RETURN ITEM TO POOL
        self.itemsAvailable = self.itemsAvailable + 1
        print(self.TypeName, self.itemsAvailable, "( item returned )")
        table.insert(self.items, item)
    end
    function newPool:GetItemsAvailable()
        return self.itemsAvailable
    end

    return newPool
end

local GeneratePools = function ()
    local newPools = {}
    for _, eType in pairs(eTypes) do
        local eTypeName = eType.Name
        local eTypeIndex = GetEntryTypeIndexFromEntryTypeName(eTypeName)
    
        newPools[eTypeIndex] = NewPool(eTypeName)
    end
    Debug.Pools = newPools
end

GeneratePools()

local NewResourceObject = function (name)
    return {
        Enabled = false,
        Name = name,
        Data = {
            Groups = {
                ["root"] = {} -- * boilerplate for future features
            },
            Entries = CreateEntryTable()
        },
        AuthKey = ""
    }
end

local ResortEnabledList = function (prevPos, t)
    local lastItem = table.remove(t)
    table.insert(t, prevPos, lastItem)

    SetResourceEnabledIndexFromIndex(lastItem, prevPos)

end
local ResortResourceList = function (newPos)
    local t = gResources
    local lastItem = table.remove(t)
    local name = lastItem.Name
    table.insert(t, newPos, lastItem)
    
    local oldIndex = GetResourceIndexFromName(name)

    SetNewResourceIndex(oldIndex, newPos)

end

Debug.AddEnabled = function (pIndex)
    local t = gEnabledResources
    table.insert(t, pIndex)
    SetResourceEnabledIndexFromIndex(pIndex, #t)
end

Debug.RemoveEnabled = function (pIndex)
    local t = gEnabledResources
    local pEnabledIndex = GetResourceEnabledIndexFromIndex(pIndex)
    local isLast = (pEnabledIndex == #t)
    t[pEnabledIndex] = nil
    SetResourceEnabledIndexFromIndex(pIndex, -1)

    if not isLast and #t > 0 then
        ResortEnabledList(pEnabledIndex, t)
    end
end

Debug.AddResource = function (resourceName, authKey)

    -- if gResources[resourceName] then
    --     print(resourceName.. " ALREADY REGISTERED")
    --     return
    -- end
    
    -- gResources[resourceName] = NewResourceObject()
    -- gResources[resourceName].AuthKey = authKey
    -- print(resourceName.. " NOW REGISTERED")

    if gPointersName[resourceName] then
        print(resourceName.. " ALREADY REGISTERED")
        return
    end

    local newIndex = #gResources + 1
    gPointersName[resourceName] = {newIndex, -1}
    gPointersIndex[newIndex] = {resourceName, -1}
    gResources[newIndex] = NewResourceObject(resourceName)
    gResources[newIndex].AuthKey = authKey
    gEntries[newIndex] = CreateEntryTable()
    gEntryHandles[newIndex] = {}
    print(resourceName.. " NOW REGISTERED")
    
end

Debug.RemoveResource = function (resourceName)

    if not gPointersName[resourceName] then
        print(resourceName.. " NOT REGISTERED")
        return
    end

    local pIndex = GetResourceIndexFromName(resourceName)
    local pIndexEnabled = GetResourceEnabledIndexFromIndex(pIndex)
    
    local t = gResources
    local isLast = (pIndex == #t)
    t[pIndex] = nil

    if not isLast then
        ResortResourceList(pIndex)
    end

    if pIndexEnabled ~= -1 then
        Debug.RemoveEnabled(pIndex)
    end

    gPointersName[resourceName] = nil

    print(resourceName.. " REMOVED")
end


Debug.Module.SetGroupStructure = function (resourceName, data)
    return -- * FUTURE PLANS *
end

Debug.LoadModule = function (resourceName, authKey, enabled)
    
    local pIndex = GetResourceIndexFromName(resourceName)
    local AuthKey = gResources[pIndex].AuthKey

    if authKey ~= AuthKey then
        return setmetatable({}, {
            __index = function ()
                return function (...) end
            end
        })
    end

    print("'Module' request from: "..resourceName)

    local newTbl = {}
    newTbl["VARIABLE_TOKEN"] = Debug.VARIABLE_TOKEN

    local list = ""

    if enabled then
        list = "ENABLED"
    else
        list = "DISABLED"
    end

    for i1, v1 in pairs(Functions[list]) do
        if type(v1) == "function" then

            newTbl[i1] = function (...)
                return v1(resourceName, ...)
            end

        elseif type(v1) == "table" then

            print(i1, "is a table")
            newTbl[i1] = {}

            for i2, v2 in pairs(v1) do
                print(i2, type(v2))
                if type(v2) == "function" then
                    print(i2, "is a function inside", i1)
                    newTbl[i1][i2] = function (...)
                        return v2(resourceName, ...)
                    end
                end
            end
        end
    end

    return newTbl

end

local chars = {}
for c in ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&-_=+.<>?"):gmatch(".") do
    chars[#chars+1] = c
end

local GenerateKey = function (resourceName)

    local t = {}
    for i = 1, 8 do
        t[i] = chars[math.random(#chars)]
    end
    local concated = table.concat(t)

    local result = resourceName..concated
    print(result)

    return result
end

Debug.RequestNewKey = function (resourceName)

    local authKey = GenerateKey(resourceName)

    -- gResources[resourceName].AuthKey = authKey

    return authKey
end

-- Debug.ProtectNils = function () -- * Unused
--     print('protected')
--     local table = {}
--     setmetatable(table, {
--         __index = function(t, k)
--             -- create a subtable for "Module.Table"
--             local sub = setmetatable({}, {
--                 __index = function(tt, kk)
--                     -- if "Func" missing inside "Table"
--                     local f = function(...) end
--                     rawset(tt, kk, f)
--                     return f
--                 end
--             })
--             rawset(t, k, sub)
--             return sub
--         end
--     })
--     return table
-- end

-- function SafeTable() -- * Unused
--     local function makeProxy()
--         return setmetatable({}, {
--             __index = function()
--                 return makeProxy() -- returns another proxy for deeper indexing
--             end,
--             __call = function()
--                 -- allow it to be called like a function
--                 return nil
--             end
--         })
--     end
--     return makeProxy
-- end


Debug.Register = function (resourceName)
    
    print("'Register' request from: "..resourceName)
    local authKey = Debug.RequestNewKey(resourceName)
    Debug.AddResource(resourceName, authKey)

    return authKey

end

-- exports("RequestNewKey", Debug.RequestNewKey)
exports("Register", Debug.Register)
exports("LoadModule", Debug.LoadModule)

-- metaInstructions = {
--     __index = function()
--         print('base indexed')
--         return {
--             __index = function()
--                 print('func indexed')
--                 return function (...) 
--                     print('template func 1')
--                 end -- returns another proxy for deeper indexing
--             end,
--             __call = function()
--                 print('func called')
--                 -- allow it to be called like a function
--                 return function (...) 
--                     print('template func 2')
--                 end
--             end
--         }
--     end,
--     __call = function()
--         -- allow it to be called like a function
--         print('base called')
--         return nil
--     end
-- } -- * Not Used 

-- exports("ProtectNils", function ()
--     -- local function makeProxy()
--     --     print("TEST")
--     --     return setmetatable({}, {
--     --         __index = function()
--     --             print('base indexed')
--     --             return setmetatable({}, {
--     --                 __index = function()
--     --                     print('func indexed')
--     --                     return function (...) 
--     --                         print('template func 1')
--     --                     end -- returns another proxy for deeper indexing
--     --                 end,
--     --                 __call = function()
--     --                     print('func called')
--     --                     -- allow it to be called like a function
--     --                     return function (...) 
--     --                         print('template func 2')
--     --                     end
--     --                 end
--     --             })
--     --         end,
--     --         __call = function()
--     --             -- allow it to be called like a function
--     --             print('base called')
--     --             return nil
--     --         end
--     --     })
--     -- end
--     return metaInstructions
-- end) -- * Not Used



Debug.AutoGenerateHandle = function (eTypeName)
    if not gEntries[eTypeName] then
        print("container Doesnt exist")
        return
    end
    local newHandle
    local prefix = eTypes[eTypeName].HandlePrefix
    print("prefix", prefix)
    repeat
        local random = math.random(100000,999999)
        newHandle = prefix .. random
    print(prefix .. random)
    until not gEntries[eTypeName][newHandle]
    print("handle", newHandle)
    return newHandle
end


Debug.GetEnabledResources = function ()
    return gEnabledResources
end

-- Debug.GetEnabledEntries = function ()
--     local enabledEntities = CreateEntryTable()
--     for resourceName, _ in pairs(gEnabledResources) do
--         for eTypeName, entries in pairs(gResources[resourceName]["Data"]['Entries']) do
--             for handle, data in pairs(entries) do
--                 enabledEntities[eTypeName][handle] = data
--             end
--         end
--     end
--     return enabledEntities
-- end

-- Debug.GetEnabledEntries = function ()
--     local enabledEntities = {}
--     for _, pIndex in ipairs(gEnabledResources) do
--         local cResourceEntries = gResources[pIndex]["Data"]['Entries']
--         for typeIndex, entries in ipairs(cResourceEntries) do
--             for handle, data in pairs(entries) do
--                 enabledEntities[typeIndex][handle] = data
--             end
--         end
--     end
--     return enabledEntities
-- end

GetEnabledEntries = function ()
    local enabledEntities = CreateEntryTable()
    for _, resourceIndex in ipairs(gEnabledResources) do
        for entryTypeIndex, entries in ipairs(gEntries[resourceIndex]) do
            local inputTo = enabledEntities[entryTypeIndex]
            for _, entry in ipairs(entries) do
                table.insert(inputTo, entry)
            end
        end
    end
    return enabledEntities
end


--[[
    . Confirm changes to Entries, Resources, EnabledResources, ResourcePointers have been completed
    . Continue implementation for handles
]]

 -- TODO: make enum
local byteToHtml = {
    -- [33] = "&excl;",
    -- [34] = "&quot;",
    -- [35] = "&num;",
    -- [36] = "&dollar;",
    -- [37] = "&percnt;",
    [38] = "&amp;",
    [39] = "&apos;",
    -- [40] = "&lparen;",
    -- [41] = "&rparen;",
    -- [42] = "&ast;",
    -- [43] = "&plus;",
    -- [44] = "&comma;",
    -- [46] = "&period;",
    -- [47] = "&sol;",
    -- [58] = "&colon;",
    -- [59] = "&semi;",
    [60] = "&lt;",
    -- [61] = "&equals;",
    [62] = "&gt;",
    -- [63] = "&quest;",
    -- [64] = "&commat;",
    -- [91] = "&lsqb;",
    -- [92] = "&bsol;",
    -- [93] = "&rsqb;",
    -- [94] = "&Hat;",
    -- [95] = "&lowbar;",
    -- [96] = "&grave;",
    -- [123] = "&lcub;",
    -- [124] = "&verbar;",
    -- [125] = "&rcub;",
    -- [126] = "&tilde;",
}

local eCharacterWidths = Enum.CharacterWidths

local ProcessString = function (string)
    local totalWidth = 0.0
    local newText = ""

    for char in string:gmatch(".") do
        local byte = char:byte()

        --* Add Character width to total width
        totalWidth = totalWidth + (eCharacterWidths[byte] / obsurdPrecisionScale)

        --* Replace character with html element if special character
        if byteToHtml[byte] then
            newText = newText..byteToHtml[byte]
        elseif char == "~" then
            newText = newText.."~~"
        else
            newText = newText..char
        end
    end

    return newText, totalWidth
end

local CompileMultiLineData = function (data, entry)
    local lines = entry.lines
    for lineNumber, lineData in pairs(data) do
        --> print(i, lineData)
        if type(lineData) == "table" then
            --> print(table.unpack(lineData))
            local length = 0
            for _ in pairs(lineData)do
                length = length + 1
                break
            end
            if length == 0 then
                --> print("table empty")
                lines[lineNumber] = nil
            else
                --> print("table has contents")
                if lines[lineNumber] then
                    -- print("line already present")
                    local text = lineData.text or lines[lineNumber]['text']
                    lines[lineNumber]['text'], lines[lineNumber]['textWidth'] = ProcessString(text)
                    lines[lineNumber]['textColor'] = lineData.textColor and colorPresets[lineData.textColor] or lines[lineNumber]['textColor']
                    lines[lineNumber]['lineColor'] = lineData.lineColor and colorPresets[lineData.lineColor] or lines[lineNumber]['lineColor']
                else
                    --> print("line created")
                    lines[lineNumber] = {}
                    local text = lineData.text or "  "
                    lines[lineNumber]['text'], lines[lineNumber]['textWidth'] = ProcessString(text)
                    lines[lineNumber]['textColor'] = lineData.textColor and colorPresets[lineData.textColor] or colorPresets["white"]
                    lines[lineNumber]['lineColor'] = lineData.lineColor and colorPresets[lineData.lineColor] or colorPresets["black"]
                end
                --> print(table.unpack(lines[lineNumber]))
            end
        end
    end
    --> print(table.unpack(lines))
    return lines
end

rasterizeFunctionList = {
    [eTypes.Text3d.Name] = {

        ['lines'] = CompileMultiLineData,

        ['pos'] = function (value)
            if type(value) == "vector3" then
                return function ()
                    return value
                end
            end

            local chosenMethod = dynamicFunctions["pos"][value.method]
            return function ()
                return chosenMethod(table.unpack(value.args))
            end
        end,

        ['scale'] = function (value)
            return value
        end,
        
        ['font'] = function (value)
            return value
        end
    }
    
}

local doesValueMatchVariablesType = function (resourceName, varName, value)
    local typeRequired = Debug.EditorVariables[resourceName][varName].type

    if type(value) == typeRequired then
        return true
    else
        return false
    end
end

local sendVariableUpdateToResource = function (resourceName, varName, value)
    TriggerEvent("cdebug-module:SetEditorVariable->"..resourceName, varName, value, Debug.VARIABLE_TOKEN)
end

local setEditorVariable = function (resourceName, varName, value)
    Debug.EditorVariables[resourceName][varName].value = value
end


RegisterCommand("SetEditorVariable", function (source, args)
    local resourceName = args[1]
    local varName = args[2]
    local value = args[3]

    if doesValueMatchVariablesType(resourceName, varName, value) then
        setEditorVariable(resourceName, varName, value)
        sendVariableUpdateToResource(resourceName, varName, value)
    else
        print("TYPE MISMATCH")
    end

end, false)



-----------------------------------------------------------------------


