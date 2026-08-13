




--[[

    <<<<<<<<<< NOTICE FROM MODULE DEVELOPER >>>>>>>>>>
    
    
    This module has **very little security** implemented - to avoid performance impacts.
    This module should never be used in a live environment, accessible to the public.

    ! STRICTLY DEVELOPER ENVIRONMENTS ONLY !!!!!!

    Additionally,
    It is highly suggested that you do not make changes to this file
    It is critical to the intended functionality of the module
    Any changes may cause malfunctions or unsatisfactory results


]]





local protectInstruction = {
    __index = function()
        return setmetatable({}, {
            __index = function()
                return function (...)
                end
            end,
            __call = function()
                
                return function (...)
                end
            end
        })
    end,
    __call = function()
        return nil
    end
}

local key = exports["lv-debugmodule"]:Register(GetCurrentResourceName())
local modulePresent = (key ~= nil)

local protectTable = function (tbl)
    return setmetatable(tbl, protectInstruction)
end



--* /////////////// FUNCTION MANAGEMENT ///////////////

CDebug = protectTable({})

if modulePresent then
    CDebug = protectTable(exports["lv-debugmodule"]:LoadModule(GetCurrentResourceName(), key, false))
    CDebug.GetEditorVariable = _GetEditorVariable
end


RegisterNetEvent("cdebug-module:toggle->"..GetCurrentResourceName(), function (enabled, auth)
    if auth ~= key then
        -- print("^4AUTHKEY MISMATCH")
        -- print(auth, key)
        return
    end
    if enabled then
        -- Retreive active module functions
        CDebug = protectTable(exports["lv-debugmodule"]:LoadModule(GetCurrentResourceName(), key, enabled))
        
        CDebug.GetEditorVariable = _GetEditorVariable
    else
        -- Retreive in-active module functions
        CDebug = protectTable(exports["lv-debugmodule"]:LoadModule(GetCurrentResourceName(), key, enabled))
        CDebug.GetEditorVariable = _GetEditorVariable
    end
end)



-- --* /////////////// EDITOR VARIABLE MANAGEMENT ///////////////

-- local cl_editor_variables = {}

-- _GetEditorVariable = function (varName)
--     if cl_editor_variables[varName] then 
--         return cl_editor_variables[varName]
--     else
--         print(varName, "does not exist as editable variable")
--     end
-- end

-- -- Avoid manually setting variables
-- -- Doing so may break the functionality of the inspector

-- local setEditorVariable = function (varName, varValue, token)
--     if token ~= CDebug["VARIABLE_TOKEN"] then
--         print("Unauthorized write to:", varName)
--         return
--     else
--         if cl_editor_variables[varName] then
--             cl_editor_variables[varName] = varValue
--         else
--             return
--         end
--     end
-- end
-- local createEditorVariable = function (varName, varValue, token)
--     if token ~= CDebug["VARIABLE_TOKEN"] then
--         print("Unauthorized entry to editor:", varName)
--         return
--     else
--         if cl_editor_variables[varName] then
--             print("Variable already exists in editor")
--         else
--             cl_editor_variables[varName] = varValue
--         end
--     end
-- end

-- RegisterNetEvent("cdebug-module:SetEditorVariable->"..GetCurrentResourceName(), function (varName, varValue, token)
--     -- print("Set request:", varName, varValue, token)
--     setEditorVariable(varName, varValue, token)
-- end)
-- RegisterNetEvent("cdebug-module:CreateEditorVariable->"..GetCurrentResourceName(), function (varName, varValue, token)
--     -- print("Create request:", varName, varValue, token)
--     createEditorVariable(varName, varValue, token)
-- end)