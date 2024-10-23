local State = require(script.Parent.State)

local Hungry = setmetatable({}, State)
Hungry.__index = Hungry

function Hungry.new(parent)
    local self = State.new(parent)
    setmetatable(self, Hungry)

    return self
end

function Hungry:CheckCondition()
    return true
end

function Hungry:Update(deltaT : number)
    local World = require(script.Parent.Parent.Parent.World)

    local function findFood()
        local foodFound = nil

        for _, foodCriteria in self.parent.foodCriterias do 
            foodFound = World.GetClosestFood(self.parent:GetInstance():GetPivot().Position, foodCriteria)
            if foodFound then
                break
            end
        end

        return foodFound
    end

    local food = findFood()

    if food then
        local destPosition = World.GetWorldInstancePosition(food.WorldInstance)
        self.parent:Move(destPosition)
    else 
        print("No food found")
    end
end

return Hungry