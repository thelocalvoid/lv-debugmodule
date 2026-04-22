local gPointersName = Debug.ResourcePointers["ResourceName"]
local gResources = Debug.Resources
local Commands = {
    {
        name = "ListDebug", 
        func = function ()
            for key, _ in ipairs(gPointersName) do
                print(key)
            end
        end, 
        restrict = false
    },
    {
        name = "toggledebug", 
        func = function (src, args)
            if not args[1] then
                print("Provide resource name")
                return
            end
            local resourceName = args[1]

            if not gPointersName[resourceName] then
                print("Name is not registered")
                return
            end

            local pIndex = GetResourceIndexFromName(resourceName)
            
            local bool

            if args[2] and (args[2] == "true" or args[2] == "false") then
                bool = args[2] == "true" and true or false
            else
                bool = not gResources[pIndex].Enabled
            end

            local authKey = gResources[pIndex].AuthKey

            if bool then
                if gResources[pIndex].Enabled ~= bool then
                    gResources[pIndex].Enabled = true
                    Debug.AddEnabled(pIndex)
                    TriggerEvent("cdebug-module:toggle->"..resourceName, true, authKey)
                end
            else
                if gResources[pIndex].Enabled ~= bool then
                    gResources[pIndex].Enabled = false
                    Debug.RemoveEnabled(pIndex)
                    TriggerEvent("cdebug-module:toggle->"..resourceName, false, authKey)
                end
            end

        end, 
        restrict = false
    },
    {
        name = "GetActiveHandles",
        func = function ()
            
        end,
        restrict = false
    },
    {
        name = "GetActiveResources",
        func = function ()
            
        end,
        restrict = false
    },
    {
        name = "GetRegisteredResources",
        func = function ()
            
        end,
        restrict = false
    },
    {
        name = "GetNumRendering",
        func = function ()
            local count = 0
            local enabled = GetEnabledEntries(--[[ Debug.GetEnabledResources() ]])
            for entryTypeIndex, entries in ipairs(enabled) do
                for entryIndex, data in ipairs(entries) do
                    count = count + 1
                end
            end
            print(count.. " current render calls")
        end,
        restrict = false
    },
}

for i,v in pairs(Commands) do
    RegisterCommand(v.name, v.func, v.restrict or false)
end

Commands = nil