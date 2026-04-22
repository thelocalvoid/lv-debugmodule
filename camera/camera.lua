local CurrentCameraControlFunction
local cameraControlThreadSwitch = 0
local cameraControlThreadStatus = 0

local currentCamera = -1

local mouseSensitivity = 0.15

local defaultVelocity = 0.5
local velocity = defaultVelocity

local minBaseVelocity = 0.005
local maxBaseVelocity = 2.0
local scrollVelocityStep = 0.005

local velocityScale = 1.0
local velocityScaleMin = 0.005
local velocityScaleMax = 10.0
local velocityScaleStep = 0.2

local boostedVelocityMultiplier = 2.0
local DefaultVelocityMultiplier = 1.0

local zoom = 1.0
local minZoom = 0.0
local maxZoom = 1.0
local zoomStep = 0.1

-- Orbit cam
local orbitPos = vector3(0.0,0.0,100.0)
local orbitRadius = 50.0
local orbitRadiusMin = 2.0
local orbitRadiusMax = 2000.0
local orbitRadiusStep = 0.2

local eCameraControlKeys = {
    W = 87,
    A = 65,
    S = 83,
    D = 68,
    Q = 81,
    E = 69,
    SHIFT = 16,
    SPACE = 32,
}

local ePadType = {
  PLAYER_CONTROL = 0,
  CAMERA_CONTROL = 1,
  FRONTEND_CONTRO = 2
}

local eRotationOrder = {
    --* Rotate around the z-axis, then the y-axis and finally the x-axis.
    ROT_ZYX = 0,
    --* Rotate around the y-axis, then the z-axis and finally the x-axis.
    ROT_YZX = 1,
    --* Rotate around the z-axis, then the x-axis and finally the y-axis.
    ROT_ZXY = 2,
    --* Rotate around the x-axis, then the z-axis and finally the y-axis.
    ROT_XZY = 3,
    --* Rotate around the y-axis, then the x-axis and finally the z-axis.
    ROT_YXZ = 4,
    --* Rotate around the x-axis, then the y-axis and finally the z-axis.
    ROT_XYZ = 5,
}

local eTimeCycles = {
    REMOVE_FOG_DOF_FARCLIP = {
        name = "REMOVE_FOG_DOF_FARCLIP",
        dof_enable_hq = {1.0, 0.0},
        dof_hq_farplane_out = {100000.0, 0.0},
        fog_haze_alpha = {0.0, 0.0},
        fog_alpha = {0.0, 0.0},
        far_clip = {15000.0, 15000.0},
    }
}
-- see CreateCustomTimeCycles()

-- TO CHECK WHEN ADDING CAMERA TYPE
-- eCameraTypeControls
-- GetVectorsFor
-- executeBefore, executeAfter
-- Consider UpdateCamera()
-- And register a command

-- Stores camera positions, rotations and other similar data
local cameraStateData = {

}

local eCameraTypeControls = {

    [Enum.ClientCameraStates.GAMEPLAY] = function ()
        
    end,
    [Enum.ClientCameraStates.FREECAM] = function ()
        HideHudAndRadarThisFrame()
        local r, f, u, pos = GetCamMatrix(currentCamera)

        -- print('asd')

        local spacePressed = IsDisabledControlJustPressed(ePadType.PLAYER_CONTROL, 22)

        if spacePressed then

            local stop = pos + (f * 100)

            local handle = StartShapeTestLosProbe(pos.x, pos.y, pos.z, stop.x, stop.y, stop.z, 19, 0, 0)
            local status, hit, endCoords, surfaceNorm, entityHit
            status = 1
            while status == 1 do
                status, hit, endCoords, surfaceNorm, entityHit = GetShapeTestResult(handle)
                Wait(0)
                print("waiting")
            end
            if status == 2 then
                print("complete")
                if hit then
                    print("A POSITIION WAS FOUND")
                    print(endCoords)
                    local ped = PlayerPedId()

                    SetEntityCoords(ped, endCoords.x, endCoords.y, endCoords.z, false, false, false, false)

                end
            end
            
        end

        -- local velocityMultiplier = IsRawKeyDown(eCameraControlKeys.SHIFT) and boostedVelocityMultiplier or DefaultVelocityMultiplier
        local velocityMultiplier = IsDisabledControlPressed(ePadType.PLAYER_CONTROL, 21) and boostedVelocityMultiplier or DefaultVelocityMultiplier

        local wPower = IsRawKeyDown(eCameraControlKeys.W) and 1 or 0
        local sPower = IsRawKeyDown(eCameraControlKeys.S) and 1 or 0
        local fDot = wPower - sPower

        local aPower = IsRawKeyDown(eCameraControlKeys.A) and 1 or 0
        local dPower = IsRawKeyDown(eCameraControlKeys.D) and 1 or 0
        local rDot = dPower - aPower

        local ePower = IsRawKeyDown(eCameraControlKeys.E) and 1 or 0
        local qPower = IsRawKeyDown(eCameraControlKeys.Q) and 1 or 0
        local uDot = ePower - qPower

        local finalVelocity = (velocity * velocityScale) * velocityMultiplier

        local fVelocity = f * fDot
        local hVelocity = r * rDot
        local vVelocity = u * uDot

        local newPos = pos + (fVelocity + hVelocity + vVelocity) * finalVelocity

        SetCamCoord(currentCamera, newPos.x, newPos.y, newPos.z)
        SetFocusPosAndVel(newPos.x, newPos.y, newPos.z, 0.0, 0.0, 0.0)

        -- UP +
        -- DOWN -
        -- RIGHT +
        -- LEFT -
        -- (IF INVERTED)
        local mouseUDNormal = GetDisabledControlNormal(ePadType.CAMERA_CONTROL, 2) * -1
        local mouseLRNormal = GetDisabledControlNormal(ePadType.CAMERA_CONTROL, 1) * -1

        -- print(mouseLRNormal, mouseUDNormal)

        local currentRot = GetCamRot(currentCamera, eRotationOrder.ROT_ZXY)

        local rotZ = currentRot.z
        local newYaz = rotZ + ((mouseSensitivity * 45) * mouseLRNormal)
        local rotX = currentRot.x
        local newPitch = rotX + ((mouseSensitivity * 45) * mouseUDNormal)
        
        -- Clamp new pitch value to avoid flipping bug
        if newPitch > 89.9 then
            newPitch = 89.9
        end
        if newPitch < -89.9 then
            newPitch = -89.9
        end

        -- Hardcode y value to 0.0 - We dont want rolling of the camera
        SetCamRot(currentCamera, newPitch, 0.0, newYaz, eRotationOrder.ROT_ZXY)

        local velocityScaleDelta = 0
        velocityScaleDelta = IsDisabledControlJustPressed(ePadType.PLAYER_CONTROL, 16) and velocityScaleDelta - 1 or velocityScaleDelta
        velocityScaleDelta = IsDisabledControlJustPressed(ePadType.PLAYER_CONTROL, 17) and velocityScaleDelta + 1 or velocityScaleDelta

        velocityScale = velocityScale * (1 + (velocityScaleStep * velocityScaleDelta))
        if velocityScale > velocityScaleMax then
            velocityScale = velocityScaleMax
        end
        if velocityScale < velocityScaleMin then
            velocityScale = velocityScaleMin
        end


    end,
    [Enum.ClientCameraStates.MAP2D] = function ()

        HideHudAndRadarThisFrame()

        local r, f, u, pos = GetCamMatrix(currentCamera)
        local n = vector3(0.0,1.0,0.0)
        local e = vector3(1.0,0.0,0.0)

        local velocityMultiplier = IsDisabledControlPressed(ePadType.PLAYER_CONTROL, 21) and boostedVelocityMultiplier or DefaultVelocityMultiplier


        local zTop = GetHeightmapTopZForPosition(pos.x, pos.y)
        local zBottom = GetHeightmapBottomZForPosition(pos.x, pos.y)
        local dist = zTop - zBottom
        local zMiddle = zBottom + dist/2

        -- print(zMiddle)

        local zNew = pos.z
        zNew = IsDisabledControlJustPressed(ePadType.PLAYER_CONTROL, 16) and zNew + 500 or zNew
        zNew = IsDisabledControlJustPressed(ePadType.PLAYER_CONTROL, 17) and zNew - 500 or zNew

        if zNew > 10000 then
            zNew = 10000
        end
        if zNew - 500.0 < zBottom then
            zNew = zBottom + 500
        end

        local zoomPercent = (zNew - 500 - zBottom) / (10000 - 500 - zBottom)


        local wPower = IsRawKeyDown(eCameraControlKeys.W) and 1 or 0
        local sPower = IsRawKeyDown(eCameraControlKeys.S) and 1 or 0
        local NDot = wPower - sPower

        local aPower = IsRawKeyDown(eCameraControlKeys.A) and 1 or 0
        local dPower = IsRawKeyDown(eCameraControlKeys.D) and 1 or 0
        local EDot = dPower - aPower

        local newFov = 0.0 + (15 * (zoomPercent * zoomPercent)) -- base on zoom
        local finalVelocity = (0.1 + (50 * (zoomPercent * zoomPercent * zoomPercent))) * velocityMultiplier-- based on zoom

        local nVelocity = n * NDot
        local eVelocity = e * EDot

        -- local newPos = vector3(pos.x, pos.y, zNew) --! temp

        local newPosXY = pos + (nVelocity + eVelocity) * finalVelocity
        local newPos = vector3(newPosXY.x, newPosXY.y, zNew)

        SetCamCoord(currentCamera, newPos.x, newPos.y, newPos.z)
        SetCamFov(currentCamera, newFov)
        -- local scale = GetLodscale()

        -- local lod = 30.0 - (24.0 * (zoomPercent * zoomPercent))

        -- OverrideLodscaleThisFrame(lod) -- ! MAY CAUSE CRASHES
        
        SetFocusPosAndVel(newPos.x, newPos.y, zMiddle, 0.0, 0.0, 0.0)

        
        print(zNew)
        -- print(lod)
        -- print(scale)
        -- print(newFov)
        -- print(finalVelocity)

    end,
    [Enum.ClientCameraStates.MAP3D] = function ()

        local velocityMultiplier = IsDisabledControlPressed(ePadType.PLAYER_CONTROL, 21) and boostedVelocityMultiplier or DefaultVelocityMultiplier
        local RCLICK = IsDisabledControlPressed(ePadType.PLAYER_CONTROL, 25)

        local wPower = IsRawKeyDown(eCameraControlKeys.W) and 1 or 0
        local sPower = IsRawKeyDown(eCameraControlKeys.S) and 1 or 0
        local fDot = wPower - sPower

        local aPower = IsRawKeyDown(eCameraControlKeys.A) and 1 or 0
        local dPower = IsRawKeyDown(eCameraControlKeys.D) and 1 or 0
        local rDot = dPower - aPower

        local ePower = IsRawKeyDown(eCameraControlKeys.E) and 1 or 0
        local qPower = IsRawKeyDown(eCameraControlKeys.Q) and 1 or 0
        local uDot = ePower - qPower


        
        HideHudAndRadarThisFrame()
        local r, f, u, pos = GetCamMatrix(currentCamera)

        local fXY = vector3(f.x, f.y, 0.0)
        local dist = math.sqrt(fXY.x * fXY.x + fXY.y * fXY.y)
        local fLevel = fXY * (1 / dist)

        local up = vector3(0.0, 0.0, 1.0)

        local camRot = GetCamRot(currentCamera, eRotationOrder.ROT_ZXY)
        local yaw = camRot.z

        local finalVelocity = (velocity * velocityScale) * velocityMultiplier

        local fVelocity = fLevel * fDot
        local hVelocity = r * rDot
        local vVelocity = up * uDot

        local newPos = pos + (fVelocity + hVelocity + vVelocity) * finalVelocity


        SetCamCoord(currentCamera, newPos.x, newPos.y, newPos.z)

        if RCLICK then
            -- UP +
            -- DOWN -
            -- RIGHT +
            -- LEFT -
            -- (IF INVERTED)
            local mouseUDNormal = GetDisabledControlNormal(ePadType.CAMERA_CONTROL, 2) * -1
            local mouseLRNormal = GetDisabledControlNormal(ePadType.CAMERA_CONTROL, 1) * -1

            local currentRot = GetCamRot(currentCamera, eRotationOrder.ROT_ZXY)

            local rotZ = currentRot.z
            local newYaz = rotZ + ((mouseSensitivity * 45) * mouseLRNormal)
            local rotX = currentRot.x
            local newPitch = rotX + ((mouseSensitivity * 45) * mouseUDNormal)

            
            -- Clamp new pitch value to avoid flipping bug
            if newPitch > 89.9 then
                newPitch = 89.9
            end
            if newPitch < -89.9 then
                newPitch = -89.9
            end

            -- Hardcode y value to 0.0 - We dont want rolling of the camera
            SetCamRot(currentCamera, newPitch, 0.0, newYaz, eRotationOrder.ROT_ZXY)
        end

        SetFocusPosAndVel(newPos.x, newPos.y, newPos.z, 0.0, 0.0, 0.0)
        
    end,
    [Enum.ClientCameraStates.ORBIT] = function ()
        local velocityMultiplier = IsDisabledControlPressed(ePadType.PLAYER_CONTROL, 21) and boostedVelocityMultiplier or DefaultVelocityMultiplier
        local RCLICK = IsDisabledControlPressed(ePadType.PLAYER_CONTROL, 25)

        local radiusDelta = 0
        radiusDelta = IsDisabledControlJustPressed(ePadType.PLAYER_CONTROL, 16) and radiusDelta + 1 or radiusDelta
        radiusDelta = IsDisabledControlJustPressed(ePadType.PLAYER_CONTROL, 17) and radiusDelta - 1 or radiusDelta

        orbitRadius = orbitRadius * (1 + (orbitRadiusStep * radiusDelta))
        if orbitRadius > orbitRadiusMax then
            orbitRadius = orbitRadiusMax
        end
        if orbitRadius < orbitRadiusMin then
            orbitRadius = orbitRadiusMin
        end

        local currentRot = GetCamRot(currentCamera, eRotationOrder.ROT_ZXY)

        local newYaw = currentRot.z
        local newPitch = currentRot.x

        if RCLICK then
            -- UP +
            -- DOWN -
            -- RIGHT +
            -- LEFT -
            -- (IF INVERTED)
            local mouseUDNormal = GetDisabledControlNormal(ePadType.CAMERA_CONTROL, 2) * -1
            local mouseLRNormal = GetDisabledControlNormal(ePadType.CAMERA_CONTROL, 1) * -1


            newYaw = currentRot.z + ((mouseSensitivity * 45) * mouseLRNormal)
            newPitch = currentRot.x + ((mouseSensitivity * 45) * mouseUDNormal)
            
            -- Clamp new pitch value to avoid flipping bug
            if newPitch > 89.9 then
                newPitch = 89.9
            end
            if newPitch < -89.9 then
                newPitch = -89.9
            end

            -- Hardcode y value to 0.0 - We dont want rolling of the camera
        end

        local wPower = IsRawKeyDown(eCameraControlKeys.W) and 1 or 0
        local sPower = IsRawKeyDown(eCameraControlKeys.S) and 1 or 0
        local fDot = wPower - sPower

        local aPower = IsRawKeyDown(eCameraControlKeys.A) and 1 or 0
        local dPower = IsRawKeyDown(eCameraControlKeys.D) and 1 or 0
        local rDot = dPower - aPower

        local ePower = IsRawKeyDown(eCameraControlKeys.E) and 1 or 0
        local qPower = IsRawKeyDown(eCameraControlKeys.Q) and 1 or 0
        local uDot = ePower - qPower

        local r, f, u, pos = GetCamMatrix(currentCamera)

        local fXY = vector3(f.x, f.y, 0.0)
        local dist = math.sqrt(fXY.x * fXY.x + fXY.y * fXY.y)
        local fLevel = fXY * (1 / dist)

        local up = vector3(0.0, 0.0, 1.0)

        local finalVelocity = (velocity * velocityScale) * velocityMultiplier

        local fVelocity = fLevel * fDot
        local hVelocity = r * rDot
        local vVelocity = up * uDot

        local newOrbitPos = orbitPos + (fVelocity + hVelocity + vVelocity) * finalVelocity
        orbitPos = newOrbitPos
        local newCamPos = newOrbitPos + ((f * -1) * orbitRadius)
        SetCamCoord(currentCamera, newCamPos.x, newCamPos.y, newCamPos.z)
        SetCamRot(currentCamera, newPitch, 0.0, newYaw, eRotationOrder.ROT_ZXY)





        SetFocusPosAndVel(newOrbitPos.x, newOrbitPos.y, newOrbitPos.z, 0.0, 0.0, 0.0)
        HideHudAndRadarThisFrame()
    end,
}

CurrentCameraControlFunction = eCameraTypeControls[Enum.ClientCameraStates.GAMEPLAY]


local function CreateCustomTimeCycles()
    for key, tc in pairs(eTimeCycles) do
        local TCModIndex = CreateTimecycleModifier(tc.name)
        for varName, varValues in pairs(tc) do
            SetTimecycleModifierVar(tc.name, varName, varValues[1], varValues[2])
        end
    end
end

CreateCustomTimeCycles()


local GetNewVectorsForFreecam = function (lastCoords, lastRotation, lastCameraType)
    local newCoords
    local newRotation

    if lastCameraType == Enum.ClientCameraStates.GAMEPLAY then
        
        newCoords = lastCoords
        newRotation = lastRotation

    end


    return newCoords, newRotation, 45.0
end

local GetNewVectorsForMap2d = function (lastCoords, lastRotation, lastCameraType)

    local newCoords = vector3(0.0,0.0,2001.0) -- !TEMP
    local newRotation = vector3(-90.0, 0.0, 0.0)
    local newFov = 1.0

    return newCoords, newRotation, newFov
end

local GetStartVectorsForMap3d = function (lastCoords, lastRotation, lastCameraType)

    local newCoords = vector3(1.0, 1.0, 100.0) -- !TEMP
    local newRotation = vector3(-45.0, 0.0, -45.0)
    local newFov = 50.0

    return newCoords, newRotation, newFov
end

local GenerateNewVectorsForOrbit = function ()
    
    -- local newFocusCoords = vector3(1.0, 1.0, 100.0) -- !TEMP
    local newRotation = vector3(-45.0, 0.0, -45.0)
    local newFov = 50.0

    return orbitPos, newRotation, newFov

end
local UseLastOrbitVectorsForOrbit = function ()
    
end
local UseLastCamerasVectorsForOrbit = function ()
    
end

local GetVectorsForOrbit = function ()

    local choice = "new" -- new | lastOfThisType | lastOfPrevType
    
    return GenerateNewVectorsForOrbit()

end

local GetVectorsFor = {
    [Enum.ClientCameraStates.FREECAM] = GetNewVectorsForFreecam,
    [Enum.ClientCameraStates.MAP2D] = GetNewVectorsForMap2d,
    [Enum.ClientCameraStates.MAP3D] = GetStartVectorsForMap3d,
    [Enum.ClientCameraStates.ORBIT] = GetVectorsForOrbit,

}



local executeBefore = {
    [Enum.ClientCameraStates.GAMEPLAY] = function ()
        
    end,
    [Enum.ClientCameraStates.FREECAM] = function ()
        
    end,
    [Enum.ClientCameraStates.MAP2D] = function ()
        SetCloudsAlpha(0.0)
        SetOverrideWeather("CLEAR")
        SetTimecycleModifier(eTimeCycles.REMOVE_FOG_DOF_FARCLIP.name)
    end,
    [Enum.ClientCameraStates.ORBIT] = function ()
        if not cameraStateData[Enum.ClientCameraStates.ORBIT] then
            cameraStateData[Enum.ClientCameraStates.ORBIT] = {
                focusPos = vector3(0.0),
                focusDist = 0.0,
                cameraPos = vector3(0.0),
                cameraRot = vector3(0.0),
            }
        end
    end,
}
local executeAfter = {
    
    [Enum.ClientCameraStates.GAMEPLAY] = function ()
        
    end,
    [Enum.ClientCameraStates.FREECAM] = function ()
        
    end,
    [Enum.ClientCameraStates.MAP2D] = function ()
        SetCloudsAlpha(1.0)
        ClearOverrideWeather()
        ClearTimecycleModifier()
    end,
    [Enum.ClientCameraStates.MAP3D] = function ()
        
    end,
}



local CameraControlThreadFunction = function ()
    cameraControlThreadStatus = 1
    while cameraControlThreadSwitch == 1 do

        DisableAllControlActions(ePadType.PLAYER_CONTROL)
        DisableAllControlActions(ePadType.CAMERA_CONTROL)
        CurrentCameraControlFunction()
        
        Wait(0)
    end
    EnableAllControlActions(ePadType.PLAYER_CONTROL)
    EnableAllControlActions(ePadType.CAMERA_CONTROL)
    cameraControlThreadStatus = 0
end

local StartCameraControlThread = function ()
    cameraControlThreadSwitch =  1
    CreateThread(CameraControlThreadFunction) 
end

local KillCameraControlThread = function ()
    cameraControlThreadSwitch = 0
end

local UpdateCameraControls = function (newCameraType)
    
    CurrentCameraControlFunction = eCameraTypeControls[newCameraType]

    if newCameraType == Enum.ClientCameraStates.GAMEPLAY then
        -- Disable custom controls
        KillCameraControlThread()
    else
        -- Enable Custom Controls
        if cameraControlThreadSwitch ~= 1 then
            StartCameraControlThread()
        end
    end

end

local RemoveLastCamera = function(lastCam)
    DestroyCam(lastCam)

    currentCamera = -1

    ClearFocus()
    RenderScriptCams(false, false, 0, false, false)
end

local CreateAndRenderCamera = function(coords, rotation, fov)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    SetCamCoord(cam, coords.x, coords.y, coords.z)
    SetCamRot(cam, rotation.x, rotation.y, rotation.z, eRotationOrder.ROT_ZXY)
    SetCamFov(cam, fov)
    SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)

    print(coords, rotation, fov)

    currentCamera = cam

    RenderScriptCams(true, false, 0, false, false)

end

local UpdateCamera = function(newCameraType, lastCameraType)

    local afterFunction = executeAfter[lastCameraType]
    if afterFunction then
        afterFunction()
    end

    local gameplayCamType = Enum.ClientCameraStates.GAMEPLAY

    local lastCam = currentCamera
    local lastCoords
    local lastRotation
    local lastFov

    if lastCameraType == gameplayCamType then
        lastCoords = GetGameplayCamCoord()
        lastRotation = GetGameplayCamRot(eRotationOrder.ROT_ZXY)
        lastFov = GetGameplayCamFov()
    else
        lastCoords = GetCamRot(lastCam, eRotationOrder.ROT_ZXY)
        lastRotation = GetCamCoord(lastCam)
        lastFov = GetCamFov(lastCam)
    end

    RemoveLastCamera(lastCam)
    
    -- escape if gameplaycam
    if newCameraType == gameplayCamType then
        EnableAllControlActions(ePadType.PLAYER_CONTROL)
        return
    end

    -- determine coords and rotation

    local newCoords, newRotation, newFov = GetVectorsFor[newCameraType](lastCoords, lastRotation, lastCameraType)

    local beforeFunction = executeBefore[newCameraType]
    if beforeFunction then
        beforeFunction()
    end

    CreateAndRenderCamera(newCoords, newRotation, newFov or lastFov)

end

local UpdateCameraState = function(cameraState)
    local lastCameraState = ClientCameraState

    if cameraState == lastCameraState then return end

    ClientCameraState = cameraState

    UpdateCamera(ClientCameraState, lastCameraState)
    UpdateCameraControls(ClientCameraState)

    return ClientCameraState, lastCameraState 
end


-- TODO: Add option for Q&E as relative to world, rather than relative to camera
RegisterCommand("freecam", function()

    UpdateCameraState(Enum.ClientCameraStates.FREECAM)
    
end, false)


RegisterCommand("gameplaycam", function()

    UpdateCameraState(Enum.ClientCameraStates.GAMEPLAY)
    
end, false)
-- TODO:
RegisterCommand("map2dcam", function() 

    UpdateCameraState(Enum.ClientCameraStates.MAP2D)
    
end, false)
-- TODO:
RegisterCommand("map3dcam", function()

    UpdateCameraState(Enum.ClientCameraStates.MAP3D)
    
end, false)
-- TODO:
RegisterCommand("orbitcam", function()

    UpdateCameraState(Enum.ClientCameraStates.ORBIT)
    
end, false)

-- ADDITIONAL TODO: FOV Option? Alt + scroll?
-- . Backspace to return to gameplay cam pos and rot?
-- . Space to teleport ped to lookat pos
-- ? UI? speed, fov, position, rotation? Border to show camera mode?
-- . ClearFocus on resourceStop
-- . DEFINE CAMERA MAP BOUNDS, avoid client flying to far off and getting lost/bugging





-- Update the ClientCoords global variable for reference in script
CreateThread(function (threadId)
    local GAMEPLAY = Enum.ClientCameraStates.GAMEPLAY
    while true do
        Wait(250)

        if ClientCameraState == GAMEPLAY then
            
            local ped = PlayerPedId()
            ClientCoords = ped ~= 0 and GetEntityCoords(ped) or vector3(0.0,0.0,0.0)

        else

            ClientCoords = GetCamCoord(currentCamera)

        end

    end
end)