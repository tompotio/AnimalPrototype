--[========================================================================[

Copyright (C) 08.28.2024 tompotio4 - All Rights Reserved 
Unauthorized copying or redistribution of this file in source and binary forms via any medium is strictly prohibited.
Unless autorized.

Explaination:

Last Updated : 12.23.2024
Updated By : tompotio4


Note : 

Qu'est-ce qui est le mieux ?
    - Chaque état correspond à une animation.
        - Comment modéliser les états transitoires ? Pour lesquels entre deux états avec une animation différente, il y a une animation de transition ? Ex : assis -> debout

]========================================================================]
--!strict

--[=========================================[
               IMPORTS          
]=========================================]
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")

local Chat = game:GetService("Chat")

--[[
local TextChatService = game:GetService("TextChatService")
local TalkEvent = ReplicatedStorage:WaitForChild("Talk")
]]

local States = script.States
local Neutral = require(States.Neutral)
local Hungry = require(States.Hungry)

--[=========================================[
            ABSTRACT ANIMAL CLASS    
]=========================================]
local Animal = {}
Animal.__index = Animal

function Animal.new(name : string, workspaceParent : Folder, spawnPosition : Vector3)
    local self = setmetatable({}, Animal)

    -- Default attributes --
    self.health = 100
    self.hunger = 0
    self.thirst = 0
    self.energy = 100
    self.coolDown = 0 -- update Cooldown
    self.age = 0

    self.maxHunger = 100
    self.maxThirst = 100

    self.states = {
        Neutral = Neutral.new(self),
        Hungry = Hungry.new(self)
    }
    self.currentState = self.states.Neutral

    -- Completed in inherited class --
    self.worldInstance = nil
    self.humanoid = nil
    self.pathParams = {}
    self.foodCriterias = {}

    self.lastSpeech = 0

    return self
end

-- Method called internally in the Move method to check if the animal should cess to follow the path
function Animal:_MoveCriterias() : boolean
    return true
end

function Animal:Move(position : Vector3)
    local function calculatePath(origin : Vector3, target : Vector3)
        local path = PathfindingService:CreatePath(self.pathParams)
        path:ComputeAsync(origin, target)
        return path
    end

    local originPos : Vector3 = self.worldInstance.PrimaryPart.Position
    local path = calculatePath(originPos, position)

    if path.Status == Enum.PathStatus.Success then
        for _, waypoint in pairs(path:GetWaypoints()) do
			path.Blocked:Connect(function()
				path:Destroy()
			end)

            -- Determine if the animal will continue to walk the path or stop
            if not self:_MoveCriterias() then 
                path:Destroy()
                break
            end

            self.humanoid:MoveTo(waypoint.Position)
			self.humanoid.MoveToFinished:Wait()
        end
    end
end

function Animal:SetEnergy(energy)
    self.energy = math.min(math.max(0, energy), 100)
end

function Animal:GetEnergy()
    return self.energy
end

function Animal:SetThirst(thirst)
    self.thirst = math.min(math.max(0, thirst), 100)
end

function Animal:GetThirst()
    return self.thirst
end

function Animal:SetHunger(hunger)
    self.hunger = math.min(math.max(0, hunger), 100)
end

function Animal:GetHunger() : number
    return self.hunger
end

function Animal:Speech(dialog : string)
    local Head : Part = self.worldInstance:FindFirstChild("Head")

    if os.time() - self.lastSpeech < 5 then
        return 
    end
    
    Chat:Chat(Head, dialog)

    self.lastSpeech = os.time()
end

--[[
    @param state : State Object or String 
    Some states do not have logic behind them, they can be just used as transition between other states.
    Animations are triggered as soon as the state attribute is modified.
]]
function Animal:SetState(state)
    --[[
    if state:isA(classObject)

        local currentInstanceState = self.worldInstance:GetAttribute()
        if state ~= currentInstanceState then
            self.worldInstance:SetAttribute("State", state)
        end

    elseif stateObj:GetName() ~= self.currentState:GetName()

        if  then
        self.worldInstance:SetAttribute("State", stateObj:GetName())
    end
    ]]
end

function Animal:GetInstance()
    return self.worldInstance
end

function Animal:Update(deltaT : number)
    self.coolDown += deltaT

    if self.coolDown >= 2 then
        self.hunger = math.min(self.hunger + .25, self.maxHunger)
        self.thirst = math.min(self.thirst + 1, self.maxHunger)
        self.coolDown = 0
    end

    if self.currentState:CheckCondition() then 
        self.currentState:Update(deltaT)
    else 
        self.currentState:SwitchState()
    end
end

return Animal