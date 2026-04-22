--[[

    !!! It is highly suggested that you do not make changes to this file
    !!! It is critical to the intended functionality of the module
    !!! Any changes may cause malfunctions or unsatisfactory results

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
local protectTable = function (tbl)
    return setmetatable(tbl, protectInstruction)
end



local key = exports["cdebug-module"]:Register(GetCurrentResourceName())
CDebug = protectTable(exports["cdebug-module"]:LoadModule(GetCurrentResourceName(), key, false))

RegisterNetEvent("cdebug-module:toggle->"..GetCurrentResourceName(), function (enabled, auth)
    if auth ~= key then
        print("^4AUTHKEY MISMATCH")
        print(auth, key)
        return
    end
    if enabled then
        CDebug = protectTable(exports["cdebug-module"]:LoadModule(GetCurrentResourceName(), key, enabled))
    else
        CDebug = protectTable(exports["cdebug-module"]:LoadModule(GetCurrentResourceName(), key, enabled))
    end
end)