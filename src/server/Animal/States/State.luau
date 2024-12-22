local State = {}
State.__index = State

function State.new(parent, stateName : string)
    local self = setmetatable({}, State)
    self.parent = parent
    self.priority = 0
    self.name = stateName

    return self
end

function State:GetName()
    return self.name
end

-- Some states have higher priorities than others, making them more "important".
function State:GetPriority()
    return self.priority
end

-- Return true if the we can go in this state within current conditions, false otherwise.
function State:CheckCondition()
    return true
end

function State:SwitchState()
    print("Switching state")
end

function State:Update(deltaT : number)
    print("Updating state")
end

return State