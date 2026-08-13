




--* /////////////// EDITOR VARIABLE MANAGEMENT ///////////////

local sv_editor_variables = {}

_GetEditorVariable = function (varName)
    if sv_editor_variables[varName] then 
        return sv_editor_variables[varName]
    else
        print(varName, "does not exist as editable variable")
    end
end

-- Avoid manually setting variables
-- Doing so may break the functionality of the inspector

local setEditorVariable = function (varName, varValue, token)
    if token ~= CDebug["VARIABLE_TOKEN"] then
        print("Unauthorized write to:", varName)
        return
    else
        if sv_editor_variables[varName] then
            sv_editor_variables[varName] = varValue
        else
            return
        end
    end
end
local createEditorVariable = function (varName, varValue, token)
    if token ~= CDebug["VARIABLE_TOKEN"] then
        print("Unauthorized entry to editor:", varName)
        return
    else
        if sv_editor_variables[varName] then
            print("Variable already exists in editor")
        else
            sv_editor_variables[varName] = varValue
        end
    end
end

AddEventHandler("cdebug-module:SetEditorVariable->"..GetCurrentResourceName(), function (varName, varValue, token)
    -- print("Set request:", varName, varValue, token)
    setEditorVariable(varName, varValue, token)
end)
AddEventHandler("cdebug-module:CreateEditorVariable->"..GetCurrentResourceName(), function (varName, varValue, token)
    -- print("Create request:", varName, varValue, token)
    createEditorVariable(varName, varValue, token)
end)