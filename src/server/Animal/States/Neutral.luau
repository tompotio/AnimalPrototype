local State = require(script.Parent.State)

local Neutral = setmetatable({}, State)
Neutral.__index = Neutral

function Neutral.new(parent)
    local self = State.new(parent, "Neutral")
    setmetatable(self, Neutral)

    self.coolDown = 0

    return self
end

function Neutral:Update(deltaT : number)
    -- Creates a list of possible states.
    local function selectPossibleStates()
        local selectedStates = {}

        for _, state in self.parent.states do

            -- Not adding neutral in the selection
            if state == self then
                continue
            end
    
            local stateCondition = state:CheckCondition()
            local statePriority = state:GetPriority()
    
            if #selectedStates > 0 then 
                local heapStatePriority = selectedStates[1]:GetPriority()
    
                if statePriority < heapStatePriority then
                    continue
                end
    
                --[[
                    Two cases:
                        ● statePriority is higher than current heap state's priority => We clear the table
                        ● statePriority has the same priority as the current heap => We keep all states with the same priority
                ]]
                if stateCondition then
                    if statePriority > heapStatePriority then
                        table.clear(selectedStates)
                    end
    
                    table.insert(selectedStates, state)
                end

            else 
                if stateCondition then
                    table.insert(selectedStates, state)
                end
            end
        end

        return selectedStates
    end

    -- Select a new state.
    local function selectNewState(selectedStates : table)
        local numberOfStates = #selectedStates
        
        if numberOfStates == 0 then
            return

        elseif numberOfStates == 1 then
            self.parent.currentState = selectedStates[1]

        -- Pick one randomly.
        else
            local randomStateId = math.random(1, numberOfStates)
            self.parent.currentState = selectedStates[randomStateId]
        end
    end

    -- Switch state every 10 seconds.
    do 
        self.coolDown += deltaT

        if self.coolDown >= 2 then
            self.coolDown = 0

        else
            return
        end
    end

    local selectedStates = selectPossibleStates()
    selectNewState(selectedStates)
end

return Neutral