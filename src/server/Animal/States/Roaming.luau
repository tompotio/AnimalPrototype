local State = require(script.Parent.State)

local Roaming = setmetatable({}, State)
Roaming.__index = Roaming

function Roaming.new(parent)
    local self = State.new(parent, "Roaming")
    setmetatable(self, Roaming)

    return self
end


return Roaming