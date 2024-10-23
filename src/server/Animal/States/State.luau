local State = {}
State.__index = State

function State.new(parent)
    local self = setmetatable({}, State)
    self.parent = parent
    self.priority = 0

    return self
end

function State:GetPriority()
    return self.priority
end

-- Check if the state can be triggered.
function State:CheckCondition()
    return true
end

function State:Update(deltaT : number)
    print("Nothing")
end

return State