local Serialize = function (resourceName, fieldName, fieldType, fieldDefault, fieldMin, fieldMax)
    -- local args = {...}
    -- local fieldName = args[1]
    -- local fieldType = args[2]
    -- local fieldDefault = args[3]

    local fieldRange = {min = fieldMin, max = fieldMax}
    local object = {
        name = fieldName,
        type = fieldType,
        value = fieldDefault,
        range = fieldRange,
    }

    setmetatable(object, {
        __call = function (t, ...)
            return t.value
        end,
        __newindex = function (t, k, v)
            print("table: "..t, "key: "..k, "value: "..v)
            local errorMsg = "You cannot write to this object"
            if k ~= "value" then print(errorMsg, t, k) return end


        end
    })

    return object
end

local playerHeight = Serialize("test", "PlayerHeight", "number", 1.6, 1.4, 1.8)

print(playerHeight())