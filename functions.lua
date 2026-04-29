
local colorPresets = Enum.ColorPresets
local dynamicFunctions = Enum.DynamicFunctions
local eTypes = Enum.EntryTypes
local eRenderOrder = Enum.RenderOrder

local gResources = Debug.Resources
local gEnabledResources = Debug.EnabledResources
local gResourcePointers = Debug.ResourcePointers
local gPointersIndex = gResourcePointers["ResourceIndex"]
local gPointersName = gResourcePointers["ResourceName"]
local gEntries = Debug.Entries
local gEntryHandles = Debug.EntryHandles


local ResortEntryList = function (resourceIndex, EntryTypeIndex, prevPos)
    local t = gEntries[resourceIndex][EntryTypeIndex]
    local lastItem = table.remove(t)
    table.insert(t, prevPos, lastItem)
    gEntryHandles[resourceIndex][lastItem.handle][2] = prevPos
end

local AddEntry = function (resourceIndex, EntryTypeIndex, handle, data, ProcessFunction)

    print(gEntries, resourceIndex, EntryTypeIndex)
    print(gEntries[resourceIndex])
    local entryTable = gEntries[resourceIndex][EntryTypeIndex]
    local entry = Debug.Pools[EntryTypeIndex]:TakeItemFromPool()
    local newEntry = ProcessFunction(entry, data)

    table.insert(entryTable, newEntry)
    local entryId = #entryTable
    gEntryHandles[resourceIndex][handle] = { EntryTypeIndex, entryId }
    
    return entryTable[entryId], entryId
end
local UpdateEntry = function (resourceIndex, EntryTypeIndex, handle, newData, ProcessFunction)
    local entryId = GetEntryIdFromHandle(resourceIndex, handle)
    local entryTable = gEntries[resourceIndex][EntryTypeIndex]

    local oldEntry = entryTable[entryId]
    local newEntry = ProcessFunction(oldEntry, newData)

    entryTable[entryId] = newEntry
    return entryTable[entryId]
    
end
local RemoveEntry = function (resourceIndex, EntryTypeIndex, handle)
    local entryId = GetEntryIdFromHandle(resourceIndex, handle)
    local entryTable = gEntries[resourceIndex][EntryTypeIndex]
    
    Debug.Pools[EntryTypeIndex]:ReturnItemToPool(entryTable[entryId])
    
    local isLast = (entryId == #entryTable)
    entryTable[entryId] = nil
    gEntryHandles[resourceIndex][handle] = nil

    if not isLast and #entryTable > 0 then
        ResortEntryList(resourceIndex, EntryTypeIndex, entryId)
    end

    
end


--* ///////// 3D TEXT /////////

Debug.Module.Text3d = {}

local Text3dEntryTypeIndex = GetEntryTypeIndexFromEntryTypeName(eTypes.Text3d.Name)
local Text3dEntryTypeName = GetEntryTypeNameFromEntryTypeIndex(Text3dEntryTypeIndex)
local Text3dRasterize = rasterizeFunctionList[Text3dEntryTypeName]

local ProcessText3dEntry = function (entry, newData)
    local scale = entry.scale
    if newData.scale then
       scale = newData.scale 
    end
    for key, value in pairs(newData) do
        local result = Text3dRasterize[key](value, entry, scale)
        entry[key] = result
    end
    return entry
end

Debug.Module.Text3d.Add = function (resourceName, handle, data)

    local handle = handle or Debug.AutoGenerateHandle(Text3dEntryTypeName)

    local resourceIndex = GetResourceIndexFromName(resourceName)

    local entry, entryId = AddEntry(resourceIndex, Text3dEntryTypeIndex, handle, data, ProcessText3dEntry)

    entry.addTime = GetGameTimer()
    entry.handle = handle

    return handle
end

Debug.Module.Text3d.Set = function (resourceName, handle, newData)

    local resourceIndex = GetResourceIndexFromName(resourceName)

    local entry = UpdateEntry(resourceIndex, Text3dEntryTypeIndex, handle, newData, ProcessText3dEntry)

end

Debug.Module.Text3d.QuickDraw = function (resourceName, data, handle)

    local handle = handle or Debug.AutoGenerateHandle(Text3dEntryTypeName)
    local resourceIndex = GetResourceIndexFromName(resourceName)

    if gEntryHandles[resourceIndex][handle] then
        --* Update

        local entry = UpdateEntry(resourceIndex, Text3dEntryTypeIndex, handle, data, ProcessText3dEntry)

        entry.addTime = GetGameTimer()
        entry.removeTime = entry.addTime + 2500

    else
        --* Add

        local entry, entryId = AddEntry(resourceIndex, Text3dEntryTypeIndex, handle, data, ProcessText3dEntry)
        
        entry.handle = handle
        entry.addTime = GetGameTimer()
        entry.removeTime = entry.addTime + 2500

    end

end


Debug.Module.Text3d.Clear = function (resourceName, handle)

    local resourceIndex = GetResourceIndexFromName(resourceName)

    RemoveEntry(resourceIndex, Text3dEntryTypeIndex, handle)

end


--* /////////////// 3D LINES /////////////////

Debug.Module.Line3d = {}

local Line3dEntryTypeIndex = GetEntryTypeIndexFromEntryTypeName(eTypes.Line3d.Name)
local Line3dEntryTypeName = GetEntryTypeNameFromEntryTypeIndex(Line3dEntryTypeIndex)

Debug.Module.Line3d.Add = function ()
    
end

Debug.Module.Line3d.Set = function ()
    
end

Debug.Module.Line3d.Clear = function ()
    
end

Debug.Module.Line3d.QuickDraw = function ()
    
end

--* ////////////// PRINT FUNCTIONS ///////////////

Debug.Module.Print = function (resourceName, ...)
    print("^5[DEBUG]  " ..resourceName..':^0 ' .. unpackToString({...}) )
end
Debug.Module.Error = function (resourceName, ...)
    print("^1[DEBUG]  " ..resourceName..': ' .. unpackToString({...}) )
end
Debug.Module.Warn = function (resourceName, ...)
    print("^3[DEBUG]  " ..resourceName..': ' .. unpackToString({...}) )
end
Debug.Module.Success = function (resourceName, ...)
    print("^2[DEBUG]  " ..resourceName..': ' .. unpackToString({...}) )
end


--* ////////////// SERIALIZE FUNCTIONS ///////////////

local numericTypes = {
    ["INT"] = true,
    ["NUMBER"] = true
}

-- NOTE: This is experimental
Debug.Module.NewEditorVariable = function (resourceName, fieldName, fieldType, fieldDefault, fieldMin, fieldMax)
    
    local success = false

    local newField = {}
    newField.name = fieldName
    newField.value = fieldDefault
    newField.type = fieldType

    if numericTypes[fieldType] then
        newField.range = {min = fieldMin, max = fieldMax}
    end

    -- TODO: Add item to menu
    -- TODO: [DONE] Create variable edit handler
    -- TODO: Menu talks to handler in module
    -- TODO: [DONE] Handler in module sends event to resource

    if Debug.EditorVariables[resourceName] then
        if Debug.EditorVariables[resourceName][fieldName] then

            -- TODO: INTERGRATE VARIABLES INTO RESOURCE CLEANUP ON STOP/REENSURE

            print(fieldName, "already exists as a variable for", resourceName)
        else
            -- Add variable to resource table
            Debug.EditorVariables[resourceName][fieldName] = newField
            success = true
        end
    else
        -- Create resource table
        -- Then Add variable to new resource table
        Debug.EditorVariables[resourceName] = {}
        Debug.EditorVariables[resourceName][fieldName] = newField
        success = true
    end

    if success then
        TriggerEvent("cdebug-module:CreateEditorVariable->"..resourceName, fieldName, fieldDefault, Debug.VARIABLE_TOKEN)
    end


    print("Field name is a ", type(fieldName))
    return fieldName, success
end





local IdleFunctions = { -- #### Functions that will run even if module is toggle off
    AddText3d   = Debug.Module.Text3d.Add,
    SetText3d   = Debug.Module.Text3d.Set,
    ClearText3d = Debug.Module.Text3d.Clear,
    
    Print       = Debug.Module.Print,
    Error       = Debug.Module.Error,
    Warn        = Debug.Module.Warn,
    Success     = Debug.Module.Success,

    AddEditorVariable = Debug.Module.NewEditorVariable
}

local ActiveFunctions = { --- #### Functions that will only run if module is toggle on
    -- table.unpack(idleFuncs), -- Intention was to include the idle functions automatically

    QuickDrawText3d = Debug.Module.Text3d.QuickDraw,
}


Functions["DISABLED"] = IdleFunctions
Functions["ENABLED"] = {}

-- # COMBINE ALL FUNCTIONS INTO "ENABLED"
for k, v in pairs(IdleFunctions) do Functions["ENABLED"][k] = v end
for k, v in pairs(ActiveFunctions) do Functions["ENABLED"][k] = v end

ExecuteCommand("ensure cdebug-testing")