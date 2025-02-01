local Animal = require(script.Parent)
local CustomEnum = require(script.Parent.Parent.Enums)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MeerkatModel = ReplicatedStorage.Meerkat

local Meerkat = setmetatable({}, Animal)
Meerkat.__index = Meerkat

--[=========================================[
                CLASS
]=========================================]
function Meerkat.new(name : string, workspaceParent : Folder, spawnPosition : Vector3)
    local self = Animal.new(name)
    setmetatable(self, Meerkat)

    self.worldInstance = MeerkatModel:Clone()
    self.worldInstance.Parent = workspaceParent
    self.worldInstance:MoveTo(spawnPosition)
    self.humanoid = self.worldInstance:FindFirstChild("Humanoid")

    self.foodCriterias = {
        CustomEnum.FoodType.EGG,
        CustomEnum.FoodType.FRUIT,
        CustomEnum.FoodType.INSECT
    }

    local modelOrientation : CFrame, modelSize : Vector3 = self.worldInstance:GetBoundingBox()
    local height = modelSize.Y
    local radius = math.floor(math.sqrt(modelSize.X * modelSize.X + modelSize.Z * modelSize.Z))

    self.pathParams = {
        AgentRadius = radius,
        AgentHeight = height,
        AgentCanJump = false,
        WaypointSpacing = 4
    }

    return self
end

return Meerkat