local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Meerkat = require(script.Parent.Animal.Meerkat)
local CustomEnum = require(script.Parent.Enums)

local World = {}

local entitiesDict = {} -- Every animal instances or food type are instances in the game, so I added them all in the same array
local updateThread : RBXScriptSignal

local function addNewEntity(entityInfos : table, type : string)
    local entityTable = entitiesDict[type]
    table.insert(entityTable, entityInfos)
end

function World.CreateMeerkat(name : string)
    local folder = workspace:FindFirstChild("MEERKAT")

    if not folder then 
        error("MEERKAT Folder don't exist")
    end

    local newMeerkat = Meerkat.new(name, folder, Vector3.zero + Vector3.new(0,0,5))
    local infos = {
        Instance = newMeerkat,
        WorldInstance = newMeerkat:GetInstance()
    }

    addNewEntity(infos, "MEERKAT")
end

function World.GetWorldInstancePosition(worldInstance : Instance) : Vector3
    if worldInstance:IsA("Part") then 
        return worldInstance.Position

    elseif worldInstance:IsA("Model") then
        return worldInstance:GetPivot().Position

    else -- Critical, should never happen.
        error("Entity's instance can only be a Part or a Model!")
    end
end

--[[
    Returns the closest food of foodType from the origin.
    @param origin : CFrame origin position
    @param foodType : Type of food to look for
    @return a tuple {Instance, WorldInstance} (entityFound) and nil if nothing has been found 
]]
function World.GetClosestFood(origin : Vector3, foodType : CustomEnum.FoodType)
    local minDistance, entityFound = math.huge, nil
    local foodEntities = entitiesDict[foodType]

    for _, entity in foodEntities do 
        -- ajouter un test sur la nourriture pour savoir si elle est dispo.

        local instancePosition : Vector3 = World.GetWorldInstancePosition(entity.WorldInstance)

        if not instancePosition then
            continue
        end

        local distance = (instancePosition - origin).Magnitude

        if distance < minDistance then
            minDistance = distance
            entityFound = entity
        end
    end

    if entityFound then
        return entityFound
    end
end

function World.Eat()
    print("You can eat")
end

function World.Create()
    for _, entityValue in CustomEnum.Entity do 
        entitiesDict[entityValue] = {}

        local newFolder = Instance.new("Folder")
        newFolder.Parent = workspace
        newFolder.Name = entityValue

        if entityValue == CustomEnum.FoodType.INSECT then 
            local insects = ReplicatedStorage.Insects:Clone()
            insects.Parent = workspace

            table.insert(
                entitiesDict[entityValue], 
                {
                    Instance = {Health = 100},
                    WorldInstance = insects
                }
            )
        end
    end

    updateThread = RunService.Heartbeat:Connect(function(deltaT)
        for _, entities in entitiesDict do 
            for _, entity in entities do 
                if entity.Instance["Update"] then
                    entity.Instance:Update(deltaT)
                end
            end
        end
    end)
end

function World.delete()
    updateThread:Disconnect()

    for _, entities in entitiesDict do 
        for _, entity in entities do 
            if entity.Instance["Disconnect"] then
                entity.Instance:Disconnect()
            end
        end
    end

    table.clear(entitiesDict)
end

return World