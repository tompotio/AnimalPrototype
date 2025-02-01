local State = require(script.Parent.State)

local Hungry = setmetatable({}, State)
Hungry.__index = Hungry

function Hungry.new(parent)
    local self = State.new(parent, "Hungry")
    setmetatable(self, Hungry)

    return self
end

function Hungry:CheckCondition()
    local hunger = self.parent:GetHunger()

    if hunger > 50 then
        return true
    end

    return false
end

function Hungry:Update(deltaT : number)
    local World = require(script.Parent.Parent.Parent.World)

    self.parent:Speech("🍕")

    local function findFood(parentPosition : Vector3)
        local foodFound = nil

        for _, foodCriteria in self.parent.foodCriterias do 
            foodFound = World.GetClosestFood(parentPosition, foodCriteria)
            if foodFound then
                break
            end
        end

        return foodFound
    end

    local parentPosition : Vector3 = self.parent:GetInstance():GetPivot().Position
    local food = findFood(parentPosition)

    if food then
        local destPosition = World.GetWorldInstancePosition(food.WorldInstance)

        if (destPosition - parentPosition).Magnitude > .1 then
            self.parent:Move(destPosition)
        
        else
            self.parent:SetHunger(self.parent:GetHunger() - .25)
        end

    else 
        print("No food found")

        self.parent:Speech(":(")
    end
end

return Hungry