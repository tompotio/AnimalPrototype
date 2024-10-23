--[========================================================================[

Copyright (C) 08.28.2024 tompotio4 - All Rights Reserved 
Unauthorized copying or redistribution of this file in source and binary forms via any medium is strictly prohibited.
Unless autorized.

Explainations:

    This setting system is somewhat hard-coded, meaning you can't simply add a new panel in the Gui and expect it to work automatically.
    You'll need to manually add its information to the script (c.f settings table)

    Despite that, the code is relatively simple to follow and understand.

    Each panel has a simple state that determines its visibility.
    There is also a basic implementation of widgets, which can be easily duplicated.

    Linker: A linker is essentially a background frame for buttons that connects 
    to their respective options panel (the panel that appears when you hover over a button).

Last Updated : 09.06.2024
Updated By : tompotio4

]========================================================================]
--!strict
local Gui = {}

local Player = game:GetService("Players").LocalPlayer
local Gui = Player:WaitForChild("PlayerGui")

local Widget = require(script.Widget)
local CustomEnum = require(script.Parent:WaitForChild("Enums"))

local TweenService = game:GetService("TweenService")

local Settings : ScreenGui = Gui:WaitForChild("Settings")
local OpenClose : ImageButton = Settings:WaitForChild("OpenClose")

local Main : Frame = Settings:WaitForChild("Main")
local Header : Frame = Main:WaitForChild("Header")
local Exit : ImageButton = Header:WaitForChild("Exit")
local Sound : ImageButton = Header:WaitForChild("Sound")
local Cam : ImageButton = Header:WaitForChild("Cam")

local CamLinker : Frame = Header:WaitForChild("CamLinker")
local SoundLinker : Frame = Header:WaitForChild("SoundLinker")
local ExitHover : Frame = Header:WaitForChild("ExitHover")

local CameraSetting : Frame = Main:WaitForChild("Camera")
local SoundSetting : Frame = Main:WaitForChild("Sound")

local CameraScrollSettings : ScrollingFrame = CameraSetting:WaitForChild("ScrollSettings")
local CameraType : Frame = CameraScrollSettings:WaitForChild("CameraType")
local MoveSpeedChecker : Frame = CameraScrollSettings:WaitForChild("MoveSpeedChecker")
local MoveSpeed : Frame = CameraScrollSettings:WaitForChild("MoveSpeed")
local ZoomSpeed : Frame = CameraScrollSettings:WaitForChild("ZoomSpeed")

-- BINDABLE EVENTS -- 
local Events = script.Parent:WaitForChild("Events")
local CameraEvents = Events:WaitForChild("Camera")
local CameraTypeEvent : BindableEvent = CameraEvents:WaitForChild("Type")
local SpeedModeEvent : BindableEvent = CameraEvents:WaitForChild("SpeedMode")
local ZoomSpeedEvent : BindableEvent = CameraEvents:WaitForChild("ZoomSpeed")
local MoveSpeedEvent : BindableEvent = CameraEvents:WaitForChild("MoveSpeed")

local images = {
    Idle = "rbxassetid://100146908416790",
    Click = "rbxassetid://120942642878835"
}

local openened = false
local debounce = false
local debounceBis = false
local connected : RBXScriptSignal

local settings = {
    Camera = {
        button = Cam,
        frame = CameraSetting,
        linker = CamLinker,
        hovering = false
    },
    Sound = {
        button = Sound,
        frame = SoundSetting,
        linker = SoundLinker,
        hovering = false
    }
}

--[[ 
    ============================================
                        FUNCTIONS
    ============================================
]]
-- SETTING --
local function displaySetting(index : number, state : boolean)
    local frameInfo = settings[index]
    frameInfo.frame.Visible = state
    frameInfo.linker.Visible = state
end

local function closeFromLinker(index : number)
    local frameInfo = settings[index]
    if not frameInfo.hovering then
        displaySetting(index, false)
    end
end

local function hoveringSetting(index : number, state : boolean)
    local frameInfo = settings[index]
    frameInfo.hovering = state
end

local function hoveringSettingElement(frame : Frame, backgroundColor : Color3, textColor : Color3)
    local infos, success, error = Widget.isWidgetValid(frame)

    if not success then 
        error(error)
    end

    frame.BackgroundColor3 = backgroundColor
    infos.Description.TextColor3 = textColor

    if infos.type == "Selector" then
        infos.Input.TextColor3 = textColor

    elseif infos.type == "Slider" then
        infos.Value.TextColor3 = textColor
    end
end

-- EXIT BUTTON --
local function closeAll()
    openened = false
    Main.Visible = false

    for _, settingInfo in settings do 
        settingInfo.frame.Visible = false
        settingInfo.linker.Visible = false
    end
end

local function hoveringExitButton()
    ExitHover.Visible = true
end

local function leavingExitButton()
    ExitHover.Visible = false
end

-- CLOSE/OPEN --
local function rotateOpen()
    if not debounce then
        debounce = true
        local tweenInfo = TweenInfo.new(.6)
        local tween = TweenService:Create(OpenClose, tweenInfo, {Rotation = 180})
        tween:Play()

        tween.Completed:Wait()
        OpenClose.PressedImage = images.Click
        
        connected = OpenClose.MouseButton1Click:Connect(function() 
            if openened then 
                closeAll()
                return
            end

            openened = true
            Main.Visible = true
        end)

        debounce = false
    end
end

local function rotateClose()
    if not debounceBis then
        debounceBis = true
        local tweenInfo = TweenInfo.new(.25)
        local tween = TweenService:Create(OpenClose, tweenInfo, {Rotation = 0})

        tween:Play()
        tween.Completed:Wait()

        debounceBis = false
        OpenClose.PressedImage = ""

        if connected then
            connected:Disconnect()
        end
    end
end

--[[ 
    ============================================
                    CONNECTION
    ============================================
]]
-- Open / Close --
OpenClose.MouseEnter:Connect(rotateOpen)
OpenClose.MouseLeave:Connect(rotateClose)

-- Establish connections for each setting's UI elements.
for index, settingInfo in settings do 
    settingInfo.button.MouseEnter:Connect(function()
        displaySetting(index, true)
    end)

    settingInfo.frame.MouseLeave:Connect(function()
        displaySetting(index, false)
        hoveringSetting(index, false)
    end)

    settingInfo.frame.MouseEnter:Connect(function()
        hoveringSetting(index, true)
    end)

    settingInfo.linker.MouseLeave:Connect(function()
        closeFromLinker(index)
    end)
end

-- Adds hover effects to each setting element in the camera panel.
for _, frame : Frame in CameraScrollSettings:GetChildren() do
    if not frame:IsA("Frame") then 
        continue
    end

    frame.MouseEnter:Connect(function()
        hoveringSettingElement(frame, Color3.new(1,1,1), Color3.new(0.592156, 0.886274, 0.886274))
    end)

    frame.MouseLeave:Connect(function()
        hoveringSettingElement(frame, Color3.fromHex("#4c4c4c"), Color3.new(1,1,1))
    end)
end

-- Exit --
Exit.MouseButton1Click:Connect(closeAll)
Exit.MouseEnter:Connect(hoveringExitButton)
Exit.MouseLeave:Connect(leavingExitButton)

-- CHECKBOX --
Widget.CheckBox(MoveSpeedChecker, function(state : boolean)
    SpeedModeEvent:Fire(state)
    MoveSpeed.Visible = state
end)

-- SELECTOR -- 
local keys = {} -- I should automatize this...
for key, _ in pairs(CustomEnum.CameraType) do
    table.insert(keys, key)
end
Widget.Selector(CameraType, keys, 1, function(type : CustomEnum.CameraType)
    CameraTypeEvent:Fire(type)
end)

-- SLIDER --
Widget.Slider(ZoomSpeed, 4, function(value : number) -- NB: I should globalize in a specific module configurable values like MaxZoomSpeed, MaxMoveSpeed, etc.
    ZoomSpeedEvent:Fire(value)
end)

Widget.Slider(MoveSpeed, 100, function(value : number)
    MoveSpeedEvent:Fire(value)
end)

return Gui