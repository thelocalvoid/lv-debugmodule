
local thisResourceName = GetCurrentResourceName()

-- ! GONNA HAVE TO STORE ALL THE CHANGES THAT WERE MADE BY THE MODULE
-- TO UNDO THEM
-- MAYBE STORE WHAT THE VALUES WERE BEFORE THE MODULE CHANGED IT - if appropriate

local function RestoreValuesAndStates()
    
end


RegisterNetEvent("onResourceStop", function (stoppingResourceName)
    if stoppingResourceName == thisResourceName then

        RestoreValuesAndStates()

    end
end)