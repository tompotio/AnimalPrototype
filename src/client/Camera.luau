--[========================================================================[

Copyright (C) 08.28.2024 tompotio4 - All Rights Reserved 
Unauthorized copying or redistribution of this file in source and binary forms via any medium is strictly prohibited.
Unless autorized.

Explaination:

Last Updated : 08.28.2024
Updated By : tompotio4

]========================================================================]
--!strict
local Camera = {}

--[===========================================[
        SERVICES | GLOBAL | WORKSPACE
]===========================================]
local CustomEnum = require(script.Parent.Enums)

local UserInputService = game:GetService("UserInputService")

local CurrentCamera = workspace.CurrentCamera
local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

--[===========================================[
        LOAD CAMERA IN SCRIPTABLE MODE
]===========================================]
repeat 
	CurrentCamera.CameraType = Enum.CameraType.Scriptable 
	task.wait(.5)
until CurrentCamera.CameraType == Enum.CameraType.Scriptable

--[=========================================[
                VARIABLES       
]=========================================]

-- CONSTANTS --
local BASE_MOVE_SPEED = 10
local MAX_MOVE_SPEED = 100
local ROTATIONAL_SENSITIVITY = .075
local BASE_ZOOM_SPEED = 200
local MAXHEIGHT = 100
local MINHEIGHT = 10

-- VARIABLES --
local cameraSpeedMode : CustomEnum.CameraSpeedMode = CustomEnum.CameraSpeedMode.AUTOMATIC
local cameraType : CustomEnum.CameraType = CustomEnum.CameraType.RTS
local zoomType : CustomEnum.ZoomType = CustomEnum.ZoomType.LINEAR
local moveInputs = {}
local currentlyZooming = { 
    false, -- if zooming
    nil, -- Vector3
}
local currentlyRotating = false
local canMove = true
local pressedTime = 0 -- used for automatic mode.
local rotation : Vector2 = Vector2.new(0,0) -- distanceTraveled by the mouse.
local customMoveSpeed = BASE_MOVE_SPEED -- by default customMoveSpeed is the same as BASE_MOVE_SPEED.
local customZoomSpeedMultiplier = 2

--[=========================================[
            MICRO OPTIMISATIONS          
]=========================================]
local Exp = math.exp
local Clamp = math.clamp
local Floor = math.floor
local Max = math.max
local Min = math.min
local Time = os.clock
local Round = math.round
local Pow = math.pow
local Wait = task.wait

--[=========================================[
                FUNCTIONS          
]=========================================]
local function clampCameraPosition()
    local position = CurrentCamera.CFrame.Position
    local height = Clamp(position.Y, MINHEIGHT, MAXHEIGHT)
    CurrentCamera.CFrame = CFrame.new(position.X, height, position.Z) * CurrentCamera.CFrame.Rotation
end

local function zoom(deltaT : number)
    if zoomType == CustomEnum.ZoomType.LINEAR then
        local direction = CurrentCamera.CFrame.LookVector.Unit
        
        local speed = direction * BASE_ZOOM_SPEED * customZoomSpeedMultiplier * currentlyZooming[2].Z * deltaT
        CurrentCamera.CFrame += speed

        clampCameraPosition()

        currentlyZooming = {false, nil}

    else
        currentlyZooming[3] = CustomEnum.ZoomType.LINEAR
        warn("Other kind of zoom are not supported yet...")
    end
end

local function rotate()
    local mousePosition = UserInputService:GetMouseDelta()
    rotation = Vector2.new(
        rotation.X - mousePosition.X * ROTATIONAL_SENSITIVITY,
        math.clamp(rotation.Y - mousePosition.Y * ROTATIONAL_SENSITIVITY, -70, 0)
    )
    
    local cameraCFrame = CFrame.new(CurrentCamera.CFrame.Position)
    cameraCFrame = cameraCFrame * CFrame.Angles(0, math.rad(rotation.X), 0)
    cameraCFrame = cameraCFrame * CFrame.Angles(math.rad(rotation.Y), 0, 0)
    CurrentCamera.CFrame = cameraCFrame
end

local function move(deltaT : number)
    local function roundDecimal(n : number, p : number)
        local power = Pow(10, p)
        local integered = Floor(n)
        local decimals = Round((n - integered) * power) / power
        return integered + decimals
    end

    local cameraOffset : Vector3 = Vector3.new(0, 0, 0)
    local speed : number -- the speed which will be applied to the camera.
    local elapsedTime = Time() - pressedTime

    if cameraSpeedMode == CustomEnum.CameraSpeedMode.AUTOMATIC then 
        if elapsedTime > 3 then 
            speed = MAX_MOVE_SPEED * deltaT
        else
            local t = roundDecimal(elapsedTime, 2)
            local speedMultiplier = t * t + 1
            speed = BASE_MOVE_SPEED * speedMultiplier * deltaT
        end

    elseif cameraSpeedMode == CustomEnum.CameraSpeedMode.MANUAL then
        speed = customMoveSpeed * deltaT
    end

    -- Adds the effective speed according to each input.
    for _, input in moveInputs do 
        if input == "Z" then
            cameraOffset += Vector3.new(0, 0, -speed)
        elseif input == "Q" then
            cameraOffset += Vector3.new(-speed, 0, 0)
        elseif input == "D" then
            cameraOffset += Vector3.new(speed, 0, 0)
        elseif input == "S" then
            cameraOffset += Vector3.new(0, 0, speed)
        end
    end

    -- Applies speed to camera.
    if cameraType == CustomEnum.CameraType.RTS then 
        local relativeOffset = CurrentCamera.CFrame:VectorToWorldSpace(cameraOffset)
        local RTSOffset = Vector3.new(relativeOffset.X, 0, relativeOffset.Z)
        CurrentCamera.CFrame += RTSOffset

    elseif cameraType == CustomEnum.CameraType.FREE then 
        CurrentCamera.CFrame += CurrentCamera.CFrame:VectorToWorldSpace(cameraOffset)
    end

    clampCameraPosition()
end

function Camera.update(deltaT : number)
    if not canMove then
        return
    end

    if #moveInputs > 0 then
        move(deltaT)
    end

    if currentlyRotating then
        rotate()
    end

    if currentlyZooming[1] then
        zoom(deltaT)
    end
end

--[[
    @brief Takes input and adds or removes them according to the UserInputState.
]]
function Camera.inputs(actionName : string, inputState : Enum.UserInputState, inputObject : any)
    local Rotate = (actionName == "Rotate")
    local Zoom = (actionName == "Zoom")
    local currentNumberInputs = #moveInputs

    local function inputCases(inpstate : Enum.UserInputState, rotating : boolean, mouseBehavior : Enum.MouseBehavior, pressTime : number)
        if inpstate == inputState then

            if Rotate then
                currentlyRotating = rotating
                UserInputService.MouseBehavior = mouseBehavior
            end

            if currentNumberInputs == 0 then
                pressedTime = pressTime
            end

            return true
        end

        return false
    end

    --  We do not care about any other kind of inputs (shouldn't happen anyway).
    if not table.find({"Z","Q","S","D", "Rotate", "Zoom"}, actionName) then 
        warn("Incorrect action name : " .. actionName)
        return
    end
    
    if inputCases(Enum.UserInputState.Begin, true, Enum.MouseBehavior.LockCurrentPosition, Time()) then      
        table.insert(moveInputs, actionName)
        
    elseif inputCases(Enum.UserInputState.End, false, Enum.MouseBehavior.Default, 0) then 
        local inputIndex = table.find(moveInputs, actionName)
        table.remove(moveInputs, inputIndex)
    end

    if Zoom then
        local mouseWheelDirection = inputObject.Position

        if mouseWheelDirection.Z == 1 or mouseWheelDirection.Z == -1 then
            currentlyZooming = {
                true,
                mouseWheelDirection
            }
        end
    end
end

function Camera.setCanMove(bool : boolean)
    canMove = bool
end

function Camera.setSpeedMode(mode : CustomEnum.CameraSpeedMode)
    cameraSpeedMode = mode
end

function Camera.setCameraType(type : CustomEnum.CameraType)
    cameraType = type
end

function Camera.setCustomSpeed(speed : number)
    if speed > MAX_MOVE_SPEED then
        customMoveSpeed = MAX_MOVE_SPEED
        warn("Custom speed cannot exceed MAX_MOVE_SPEED limit...")

    else
        customMoveSpeed = speed
    end
end

function Camera.setZoomSpeed(multiplier : number)
    customZoomSpeedMultiplier = multiplier
end

return Camera