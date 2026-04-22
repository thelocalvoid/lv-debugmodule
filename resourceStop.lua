local gPointersName = Debug.ResourcePointers["ResourceName"]
local RemoveResource = Debug.RemoveResource

RegisterNetEvent("onClientResourceStop", function (resourceName)
    if gPointersName[resourceName] then
        RemoveResource(resourceName)
    end
end)