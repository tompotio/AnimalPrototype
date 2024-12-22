local LocalPlayer = game:GetService("Players").LocalPlayer
LocalPlayer.CharacterAdded:Wait()

local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local Events = script:WaitForChild("Events")
local CameraEvents = Events:WaitForChild("Camera")

local MoveSpeedEvent : BindableEvent = CameraEvents:WaitForChild("MoveSpeed")
local ZoomSpeedEvent : BindableEvent = CameraEvents:WaitForChild("ZoomSpeed")
local CameraTypeEvent : BindableEvent = CameraEvents:WaitForChild("Type")
local SpeedModeEvent : BindableEvent = CameraEvents:WaitForChild("SpeedMode")

local CustomEnum = require(script.Enums)
local Gui = require(script.Gui)
local Camera = require(script.Camera)

--[[ 
    ============================================
                INPUTS BINDING
    ============================================
]]
-- Note : I could add other keys for mobile?
ContextActionService:BindAction("Z", Camera.inputs, false, Enum.KeyCode.W)
ContextActionService:BindAction("Q", Camera.inputs, false, Enum.KeyCode.A)
ContextActionService:BindAction("S", Camera.inputs, false, Enum.KeyCode.S)
ContextActionService:BindAction("D", Camera.inputs, false, Enum.KeyCode.D)
ContextActionService:BindAction("Rotate", Camera.inputs, false, Enum.UserInputType.MouseButton2)
ContextActionService:BindAction("Zoom", Camera.inputs, false, Enum.UserInputType.MouseWheel)

--[[ 
    ============================================
                        EVENTS
    ============================================
]]
SpeedModeEvent.Event:Connect(function(mode : CustomEnum.CameraSpeedMode)
    Camera.setSpeedMode(mode)
end)

MoveSpeedEvent.Event:Connect(function(value : number)
    Camera.setCustomSpeed(value)
end)

ZoomSpeedEvent.Event:Connect(function(value : number)
    Camera.setZoomSpeed(value)
end)

CameraTypeEvent.Event:Connect(function(type : CustomEnum.CameraType)
    local newType = CustomEnum.CameraType[type]
    Camera.setCameraType(newType)
end)

RunService.RenderStepped:Connect(function(deltaT) 
    local success, error = pcall(Camera.update, deltaT)

    if not success then 
        warn("Critical Error during RenderStepped of camera : " .. error)
    end
end)

--[[ 
    ============================================
                        CHAT
    ============================================
]]

local ChatService = game:GetService("Chat")
ChatService.BubbleChatEnabled = true

ChatService:SetBubbleChatSettings({
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 20,
	Font = Enum.Font.Cartoon,
    MaxDistance = 200
})