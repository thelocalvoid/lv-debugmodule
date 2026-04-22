DebugMenu = {}

local menu_ids = {
    [0] = {
        title = "title",
        position = 0,
        parent = nil,
        children = {}
    },
}
local buttom_ids = {
    
}

function MenuStruct()



end

function DebugMenu.RegisterMenu(title, parent)

    local menuCount = #menu_ids
    local newMenuId = menuCount+1

    menu_ids[newMenuId] = {
        title = title,
        position = newMenuId,
        parent = parent,
        children = {}
    }

    

    return newMenuId

end

