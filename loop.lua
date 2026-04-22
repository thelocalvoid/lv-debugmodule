

local function CalculateTrueCharWidth(char, font, scale)
    SetTextFont(font or 4)
    SetTextScale(1.0, scale or obsurdPresicionScale)
    BeginTextCommandWidth("STRING")
    AddTextComponentString(char)
    local singleWidth = EndTextCommandGetWidth(false)
    SetTextFont(font or 4)
    SetTextScale(1.0, scale or obsurdPresicionScale)
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



local eEntryTypes = Enum.EntryTypes

local averagePad = AveragePadding

local uiScaleMultiplier = 0.5

local screenX, screenY
local pixelInScreenSpaceX, pixelInScreenSpaceY


local function PixelToScreenSpace(pixels, orientation)
    if type(pixels) == "number" --[[ and math.type(pixels) == "integer" ]] then
        if orientation == 1 then
            return pixelInScreenSpaceX * pixels
        elseif orientation == 2 then
            return pixelInScreenSpaceY * pixels
        end
    end
end
local function ScreenSpaceToPixels(screenSpace, orientation)
    if type(screenSpace) == "number" --[[ and math.type(pixels) == "integer" ]] then
        if orientation == 1 then
            return screenSpace * screenX
        elseif orientation == 2 then
            return screenSpace * screenY
        end
    end
end

local TextInfo = {}


CreateThread(function (threadId)

    screenX, screenY = GetActualScreenResolution()
    pixelInScreenSpaceX, pixelInScreenSpaceY = 1.0/screenX, 1.0/screenY

    -- Offset Formula
    -- 4 + ((textscale - 0.2) / 0.2) * 2
    -- Text height
    -- Increases by either 12 or 13, per 0.2 increase in textscale

    TextInfo = {
        [0] = { -- STANDARD (0)
            [1] = {
                [1] = 0.2, -- TextScale
                [2] = PixelToScreenSpace(4, 2), -- OriginToTopOffset
                [3] = PixelToScreenSpace(14, 2), -- TextHeight
                [4] = 0, -- TextFont
                [5] = PixelToScreenSpace(2, 1) -- xTextOffset
            },
            [2] = {
                [1] = 0.4, -- TextScale
                [2] = PixelToScreenSpace(6, 2), -- OriginToTopOffset
                [3] = PixelToScreenSpace(26, 2), -- TextHeight
                [4] = 0, -- TextFont
                [5] = PixelToScreenSpace(2, 1) -- xTextOffset
            },
            [3] = {
                [1] = 0.6, -- TextScale
                [2] = PixelToScreenSpace(8, 2), -- OriginToTopOffset
                [3] = PixelToScreenSpace(39, 2), -- TextHeight
                [4] = 0, -- TextFont
                [5] = PixelToScreenSpace(2, 1) -- xTextOffset
            },
            [4] = {
                [1] = 0.8, -- TextScale
                [2] = PixelToScreenSpace(10, 2), -- OriginToTopOffset
                [3] = PixelToScreenSpace(51, 2), -- TextHeight
                [4] = 0, -- TextFont
                [5] = PixelToScreenSpace(2, 1) -- xTextOffset
            },
            [5] = {
                [1] = 1.0, -- TextScale
                [2] = PixelToScreenSpace(12, 2), -- OriginToTopOffset
                [3] = PixelToScreenSpace(64, 2), -- TextHeight
                [4] = 0, -- TextFont
                [5] = PixelToScreenSpace(2, 1) -- xTextOffset
            },
            [6] = {
                [1] = 1.2, -- TextScale
                [2] = PixelToScreenSpace(14, 2), -- OriginToTopOffset
                [3] = PixelToScreenSpace(77, 2), -- TextHeight
                [4] = 0, -- TextFont
                [5] = PixelToScreenSpace(2, 1) -- xTextOffset
            },
            [7] = {
                [1] = 1.4, -- TextScale
                [2] = PixelToScreenSpace(16, 2), -- OriginToTopOffset
                [3] = PixelToScreenSpace(89, 2), -- TextHeight
                [4] = 0, -- TextFont
                [5] = PixelToScreenSpace(2, 1) -- xTextOffset
            },
            [8] = {
                [1] = 1.6, -- TextScale
                [2] = PixelToScreenSpace(18, 2), -- OriginToTopOffset
                [3] = PixelToScreenSpace(101, 2), -- TextHeight
                [4] = 0, -- TextFont
                [5] = PixelToScreenSpace(2, 1) -- xTextOffset
            },
            [9] = {
                [1] = 1.8, -- TextScale
                [2] = PixelToScreenSpace(20, 2), -- OriginToTopOffset
                [3] = PixelToScreenSpace(114, 2), -- TextHeight
                [4] = 0, -- TextFont
                [5] = PixelToScreenSpace(2, 1) -- xTextOffset
            },
            [10] = {
                [1] = 2.0, -- TextScale
                [2] = PixelToScreenSpace(22, 2), -- OriginToTopOffset
                [3] = PixelToScreenSpace(126, 2), -- TextHeight
                [4] = 0, -- TextFont
                [5] = PixelToScreenSpace(2, 1) -- xTextOffset
            },
        },
        [1] = { -- COMPACT (4)
            [1] = {
                [1] = 0.2, -- TextScale
                [2] = 0.0, -- OriginToTopOffset
                [3] = 0.0, -- TextHeight
                [4] = 4, -- TextFont
                [5] = PixelToScreenSpace(0, 1) -- xTextOffset
            },
        }
    }

    while true do
        screenX, screenY = GetActualScreenResolution()
        pixelInScreenSpaceX, pixelInScreenSpaceY = 1.0/screenX, 1.0/screenY
        Wait(100)
    end
end)

local function GetTextInfoForScaleAndFont(scale, font)
    local data = TextInfo[font][scale]
    return data[1], data[2], data[3], data[4], data[5]
end

local function CalculateTabWidth(font, scale)
    SetTextFont(font or 4)
    SetTextScale(1.0, scale or obsurdPresicionScale)
    BeginTextCommandWidth("STRING")
    AddTextComponentString("O____O")
    local singleWidth = EndTextCommandGetWidth(false)
    SetTextFont(font or 4)
    SetTextScale(1.0, scale or obsurdPresicionScale)
    BeginTextCommandWidth("STRING")
    AddTextComponentString("O________O")
    local doubleWidth = EndTextCommandGetWidth(false)

    return doubleWidth - singleWidth
end


local rawTabSize = CalculateTabWidth(0, 1.0)

local function CalculateTextBounds(newLineHeight, font, scaleInt, width, vPadding, hPadding, tab)

    local textScale, originToTopOffset, textHeight, textFont, xTextOffset = GetTextInfoForScaleAndFont(scaleInt, font)
    local yHalfPixel = PixelToScreenSpace(0.5, 2)
    local xHalfPixel = PixelToScreenSpace(0.5, 1)
    hPadding = PixelToScreenSpace(hPadding, 1)
    vPadding = PixelToScreenSpace(vPadding, 2)
    local textWidth = width
    local xTabSize = rawTabSize
    local xTabOffset = (tab * xTabSize)

    local boxWidth = (textWidth + xTabOffset) * textScale  + (hPadding * 2)
    local boxHeight = textHeight + (vPadding * 2)
    local boxPosX = (boxWidth / 2) --[[ + xHalfPixel ]]
    local boxPosY = newLineHeight + ((boxHeight / 2) - yHalfPixel)

    local textPosY = newLineHeight + vPadding - originToTopOffset
    local textPosX = (xTabOffset * textScale) + hPadding - xTextOffset

    local bottomBound = newLineHeight + boxHeight - (yHalfPixel * 2)
    local topBound = newLineHeight
    local leftBound
    local rightBound
    -- ! Give this a go GetRenderedCharacterHeight

    return textScale, textFont, textPosX, textPosY, boxWidth, boxHeight, boxPosX, boxPosY, topBound, bottomBound, leftBound, rightBound
    
end

-- * SHOULD COMPILE AS MUCH AS POSSIBLE
-- * LIKE THIS SHOULD BE WITHOUT newLineHeight
-- * Then just add newLineHeight at renderTime


local function CalculateTextBoxPosition(boxWidth, boxHeight, yHalfPixel, xHalfPixel)
    local boxPosX, boxPosY

    boxPosX = (boxWidth / 2) --[[ + xHalfPixel ]]
    boxPosY = ((boxHeight / 2) - yHalfPixel)
    
    return boxPosX, boxPosY
end

local function CalculateTextBoxDimensions(textWidth, textHeight, xTabOffset, textScale, hPadding, vPadding)
    local boxWidth, boxHeight

    boxWidth = (textWidth + xTabOffset) * textScale  + (hPadding * 2)
    boxHeight = textHeight + (vPadding * 2)
    
    return boxWidth, boxHeight
end

local function CreateRenderTextInfo(newLineHeight, font, scaleInt, textWidth, vPadding, hPadding, tab)

    local textScale, originToTopOffset, textHeight, textFont, xTextOffset = GetTextInfoForScaleAndFont(scaleInt, font)
    local yHalfPixel = PixelToScreenSpace(0.5, 2)
    local xHalfPixel = PixelToScreenSpace(0.5, 1)
    hPadding = PixelToScreenSpace(hPadding, 1)
    vPadding = PixelToScreenSpace(vPadding, 2)
    local xTabSize = rawTabSize
    local xTabOffset = (tab * xTabSize)
    
    local boxWidth, boxHeight = CalculateTextBoxDimensions(textWidth, textHeight, xTabOffset, textScale, hPadding, vPadding)
    local boxPosX, boxPosY = CalculateTextBoxPosition(boxWidth, boxHeight, yHalfPixel, xHalfPixel)


    local textPosY = vPadding - originToTopOffset
    local textPosX = (xTabOffset * textScale) + hPadding - xTextOffset

    local bottomBound = boxHeight - (yHalfPixel * 2)
    local topBound = 0.0
    local leftBound = 0.0
    local rightBound = boxWidth

    return textScale, textFont, textPosX, textPosY, boxWidth, boxHeight, boxPosX, boxPosY, topBound, bottomBound, leftBound, rightBound
    
end

local function GetRangeFromClient(maxRange, fadeStart, start, stop)
    
    local diff = {stop.x - start.x, stop.y - start.y, stop.z - start.z}
    local distance = math.sqrt(diff[1] * diff[1] + diff[2] * diff[2] + diff[3] * diff[3])
    local opacity = 1.0
    local inRange = false


    --[[
    OOOOOOOOOOOOOOOOOO
    OOOOOOOOOOOO
    OOOOOOOOOOOOOOO

    OOO
    OOOOOO
    ]]

    if distance < maxRange then
        inRange = true
        if distance > fadeStart then
            opacity = 1.0 - ((distance - fadeStart) / (maxRange - fadeStart))
        end
    end

    return inRange, distance, opacity

end

AddTextEntry("CDEBUG_HEADER", "KEY: ~a~")


local Render3dText = function (renderData)

    local drawOrigin = renderData.pos()

    local onScreen, originX, originY = GetScreenCoordFromWorldCoord(drawOrigin.x, drawOrigin.y, drawOrigin.z)

    -- onScreen = true

    if not onScreen then
        return
    end

    local inRange, distance, opacityEffect = GetRangeFromClient(400.0,300.0, ClientCoords, drawOrigin)

    -- inRange = true

    if not inRange then
        return
    end

    local scale = renderData.scale * uiScaleMultiplier
    -- local font = renderData.font

    --> print(drawOrigin, scale, font)

    local textPadding = 0.01 * scale
    -- local textHeight = 0.05 * scale
    local rectHeight = 0.05 * scale -- = textHeight
    -- local rectMargin = 0.005 * scale
    local lineGap = PixelToScreenSpace(1, 2) -- * Replaces rectMargin

    -- local opacity = 1

    
    -- SetDrawOrigin(drawOrigin.x, drawOrigin.y, drawOrigin.z, 0)



    local newLineHeight = originY --[[ PixelToScreenSpace(100, 2) ]]
    -- local newLineHeight = 0.0 --[[ PixelToScreenSpace(100, 2) ]]

    for lineNumber, lineData in ipairs(renderData.lines) do
        
        local scale = lineNumber * 0.2 --[[ * uiScaleMultiplier ]]
        local text = lineData.text
        local tc = lineData.textColor
        local lc = lineData.lineColor 

        local trueScale = CalculateTrueScale(scale)

        local textWidth = lineData.textWidth --[[ * scale ]]

        --> print(text, tc, lc)

        -- if lineNumber == 2 then
        --     SetTextFont(4)
        --     SetTextScale(1.0, scale)
        --     BeginTextCommandWidth("STRING")
        --     AddTextComponentString(text)
        --     textWidth = EndTextCommandGetWidth(false)
        --     averagePad = 0.0
        -- end


        -- SetTextFont(4)
        -- SetTextScale(1.0, scale)
        -- BeginTextCommandWidth("STRING")
        -- AddTextComponentString(text)
        -- local textWidth = EndTextCommandGetWidth(true)
        -- # A SOLID 2/3 of frameTime is wasted on getting the width of the text using FiveM Natives
        -- local textWidth = 20.0
        local modLeft = ""
        local modRight = ""
        local middleString = "g[]{}()"
        local tempString = modLeft..middleString..modRight

        
        
        -- SetTextFont(0)
        -- SetTextScale(1.0, scale) -- keep at given scale
        -- SetTextColour(tc.r, tc.g, tc.b, --[[ math.floor( ]] 255 --[[  * opacity) ]]) --! This may be wrong input order, may be RBGA??
        -- SetTextEntry('STRING')
        -- SetTextWrap(-1.0, 2.0)
        -- AddTextComponentSubstringKeyboardDisplay(text.."    "..scale) -- ! string is limited to 99 Characters, will still funciton but only shows 99
        
        local rectWidth = textWidth + averagePad -- + textPadding

        local oneYPixel = PixelToScreenSpace(1,2)
        local lineXWidth = PixelToScreenSpace(128,1)
        local lineYWidth = PixelToScreenSpace(2,1)
        local lineXHeight = PixelToScreenSpace(1,2)
        local lineYHeight = PixelToScreenSpace(128,2)
        
        local boxHeight = lineYHeight
        local boxWidth = lineXWidth

        -- local reverseOffset = (1 - scale / 24) * 0.003
        -- local newScalar = (((scale * 2) / 24) - 1) * -1
        -- local additionalOffset = PixelToScreenSpace(math.floor(1/scale), 2)
        -- local TempVerticalOffset = 0.01252 + reverseOffset--[[ PixelToScreenSpace(-8.5,2) ]]
        local TopLineHeightOffset = 0.0095 --[[ + additionalOffset ]]--[[  + (0.0003 * newScalar) ]]
        local topOffsetFromY = TopLineHeightOffset * trueScale
        local estBaseTextHeight = 0.059 --[[ + additionalOffset ]]
        local estScaledTextHeight = estBaseTextHeight * trueScale
        local centreX = 0.0625
        local centreY = PixelToScreenSpace(100,2)

        -- local lineOffset = (lineNumber - 1) * (estScaledTextHeight + oneYPixel)
        -- local linePosY = centreY + lineOffset
        local nextPosY = 0.0
        local linePosY = nextPosY
        local topPosY = linePosY + topOffsetFromY
        local halfPosY = topPosY + (estScaledTextHeight / 2)
        local bottomPosY = topPosY + estScaledTextHeight
        nextPosY = bottomPosY - topOffsetFromY



        -- DrawRect(centreX, linePosY, 2.0, lineXHeight, 255, 0, 0, 200)
        -- DrawRect(centreX, topPosY, 2.0, lineXHeight, 255, 0, 255, 200)

        -- DrawRect(centreX + (textWidth/2), halfPosY, textWidth, estScaledTextHeight, 0, 255, 0, 200) ***A
        -- DrawRect(centreX, bottomPosY, 2.0, oneYPixel, 0, 0, 255, 200) ****
        
        -- DrawRect(centreX, bottomPosY, 2.0, lineXHeight, 255, 255, 0, 200)

        -- DrawRect(centreX, centreY, lineYWidth, lineYHeight, 0, 255, 0, 200)

        -- DrawText(centreX, (centreY  - (TopLineHeightOffset * scale)--[[ - (TempVerticalOffset * scale) ]]))
        
        -- .DrawText(centreX, linePosY )
        -- DrawRect(((rectWidth) / 2), (rectHeight * lineNumber)+((lineNumber - 1) * lineGap), rectWidth, rectHeight, lc.r, lc.g, lc.b,--[[  math.floor( ]]200--[[  * opacity) ]])

        -- DrawText(0.0--[[ textPadding/2 ]], (rectHeight * lineNumber)+((lineNumber - 1) * lineGap) - (textPadding * 3.5))
        
        -- TODO: Figure out better positioning

        local vPadding = 1
        local hPadding = 0
        local gap = 1

        -- local textScale, textFont, textPosX, textPosY, boxWidth, boxHeight, boxPosX, boxPosY, topBound, bottomBound, leftBound, rightBound = CalculateTextBounds(newLineHeight, 0, 5, textWidth, vPadding, hPadding, 0)
        local textScale, textFont, textPosX, textPosY, boxWidth, boxHeight, boxPosX, boxPosY, topBound, bottomBound, leftBound, rightBound = CreateRenderTextInfo(newLineHeight, 0, 1, textWidth, vPadding, hPadding, 0)

        SetTextFont(textFont)
        SetTextScale(1.0, textScale) -- keep at given scale
        SetTextColour(tc.r, tc.g, tc.b, --[[ math.floor( ]] math.floor(255 * opacityEffect) --[[  * opacity) ]]) --! This may be wrong input order, may be RBGA??
        SetTextEntry('STRING')
        SetTextWrap(-1.0, 2.0)
        AddTextComponentSubstringPlayerName(text)
        -- TODO: DEFINE ENTRY AS STRING OR NUMBER | TO SPLIT LOAD BETWEEN NUMBER POOL AND STRING POOL
        -- 160 Numbers and 144 strings
        -- AddTextComponentSubstringKeyboardDisplay(text) -- ! string is limited to 99 Characters, will still funciton but only shows 99

        local offset = PixelToScreenSpace(12, 1)

        DrawRect(boxPosX + originX, newLineHeight + boxPosY, boxWidth, boxHeight, lc.r, lc.g, lc.b, math.floor(255 * opacityEffect))
        DrawText(textPosX + originX, newLineHeight + textPosY) -- ! Limited to 144 draws per frame
        -- DrawRect(centreX, centreY, 2.0, oneYPixel, 255, 0, 0, 255)
        -- DrawRect(textPosX, textPosY, PixelToScreenSpace(1, 1), PixelToScreenSpace(1, 2), 255, 0, 0, 255)

        newLineHeight = newLineHeight + bottomBound + PixelToScreenSpace(1, 2) + PixelToScreenSpace(gap, 2)
    end

    -- ClearDrawOrigin()

end

local Render3dLine = function (renderData)
    local startPos, endPos, color = renderData.startPos(), renderData.endPos(), renderData.color()
    DrawLine(startPos.x, startPos.y, startPos.z, endPos.x, endPos.y, endPos.z, color.r, color.g, color.b, color.a)
end

 -- *This should be upgraded later - have points, that lines are drawn between
 -- *and have the option to do stuff at each point, like have text or...
local Render3dPath = function (pathData)
    for index, renderData in ipairs(pathData) do
        Render3dLine(renderData)
    end
end

local Render3dSphere = function ()
    
end

local Render2dText = function ()
    
end

local renderInstructions = {
    [eEntryTypes.Path3d.Name] = Render3dPath,
    [eEntryTypes.Line3d.Name] = Render3dLine,
    [eEntryTypes.Sphere3d.Name] = Render3dSphere,
    [eEntryTypes.Text3d.Name] = Render3dText,
    [eEntryTypes.Text2d.Name] = Render2dText,
}
local eRenderOrder = Enum.RenderOrder
local renderTasks = {}

for index, value in ipairs(eRenderOrder) do
    renderTasks[index] = renderInstructions[value]
end



-- TODO: RASTERIZE ABOVE for -1 Indexing
-- (Put the function instide the renderOrder call)

CreateThread(function (threadId)

    -- pre-initialise data table
    local enabledEntries = {}
    local preCalculated = {}
    local calculatedData = {}
    local enabledResources = {}


    while true do

        --[[
        .   GC
        .   Calculations (Handle Requests) - Calculate values for Renderer
        .   Render
        .       Draw Paths
        .       Draw Lines
        .       Draw Shapes?
        .       Draw 3d Text
        .       Draw 2d Text
        ]]

        -- * GC



        -- * Calculations


        -- preCalculated = enabledEntries["Static"]
        

        -- * Dynamic Calculations

        -- for _, eType in pairs(Enum.EntryTypes) do
        --     calculatedData[eType.Name] = {}

        --     -- . Get all active resource's dynamic entries

        --     for key, value in pairs(enabledResources) do
        --         for i, v in pairs(Debug.Global.CompiledData["Dynamic"][key]) do
                    
        --         end
        --     end
            
        -- end

        -- -- * add static Calculations
        -- for eTypeName, entries in pairs(staticData) do --? ?????
        --     for handle, renderData in pairs(entries) do
        --         calculatedData[eTypeName][handle] = renderData
        --     end
        -- end


        -- enabledResources = Debug.GetEnabledResources()
        enabledEntries = GetEnabledEntries(--[[ enabledResources ]])


        -- * RENDER STAGE
        --! PRINTING PER FRAME TAKES ALOT OF RESOURCES
        --> print("preRender")


        for renderIndex, eTypeName in ipairs(eRenderOrder) do -- renderIndex, eTypeName
            --> print(renderIndex, eTypeName)
            local renderTask = renderTasks[renderIndex]
            local entriesToRender = enabledEntries[renderIndex]
            for _, renderData in ipairs(entriesToRender) do -- handle, renderData
                --> print("attempting to render:    "..handle)
                renderTask(renderData)
            end
        end


        Wait(0) -- * per frame
    end
end)
