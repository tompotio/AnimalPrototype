--[========================================================================[

Copyright (C) 08.28.2024 tompotio4 - All Rights Reserved 
Unauthorized copying or redistribution of this file in source and binary forms via any medium is strictly prohibited.
Unless autorized.
]========================================================================]
--!strict
local Widget = {}

function Widget.isWidgetValid(frame : Frame)
    local infos = {}
    local error = ""
    local success = false

    local type : string = frame:GetAttribute("Type")

    if not type then 
        error = "Incorrect type"
        return infos, success, error
    end

    local validType = table.find({"Selector", "Slider", "CheckBox"}, type)

    if not validType then
        error = "Setting element isn't of correct type..."
    end

    local Description : TextLabel = frame:FindFirstChild("Description")

    if not Description then 
        error = "Setting element doesn't have a Description"
        return infos, success, error
    end

    if type == "Selector" then
        local Selector : Frame = frame:FindFirstChild("Selector")

        if not Selector then 
            error = "Selector item does not follow the template"
            return infos, success, error
        end

        local Input : TextLabel = Selector:FindFirstChild("Input")

        if not Input then 
            error = "Input not found in Selector item..."
            return infos, success, error
        end
        
        infos.Selector = Selector
        infos.Input = Input

    elseif type == "Slider" then
        local Slider : Frame = frame:FindFirstChild("Slider")

        if not Slider then 
            error = "Slider item does not follow the template"
            return infos, success, error
        end

        local Value : TextLabel = Slider:FindFirstChild("Value")

        if not Value then 
            error = "Value not found in Slider item..."
            return infos, success, error
        end

        infos.Slider = Slider
        infos.Value = Value
        
    elseif type == "CheckBox" then
        local CheckBox : Frame = frame:FindFirstChild("CheckBox")

        if not CheckBox then 
            error = "CheckBox item does not follow the template"
            return infos, success, error
        end

        infos.CheckBox = CheckBox
    end

    infos.type = type
    infos.Description = Description
    success = true

    return infos, success, error
end

-- Sets up a CheckBox
function Widget.CheckBox(frame : Frame, callBack : (state : boolean) -> ())
    local infos, success, error = Widget.isWidgetValid(frame)

    if not success then 
        error(error)
    end

    local CheckBox : ImageButton = infos.CheckBox

    local Check = CheckBox:FindFirstChild("Check")

    if not Check then 
        error("CheckBox doesn't have a Check image")
    end

    CheckBox:SetAttribute("State", false)

    CheckBox.MouseButton1Click:Connect(function()
        local newState = not CheckBox:GetAttribute("State")
        CheckBox:SetAttribute("State", newState)
        Check.Visible = newState
        CheckBox.BackgroundTransparency = newState and 0 or 1

        -- Triggers the action linked to the CheckBox
        callBack(newState)
    end)
end

-- Sets up a Slider
function Widget.Slider(frame : Frame, range : number, callBack : (value : any) -> ())
    local infos, success, error = Widget.isWidgetValid(frame)

    if not success then 
        error(error)
    end

    local Bar : Frame = infos.Slider:FindFirstChild("Bar")

    if not Bar then 
        error("Bar not found in Slider item")
    end

    local Filled : Frame = Bar:FindFirstChild("Filled")

    if not Filled then 
        error("Bar not found in Slider item")
    end

    local Void : ImageLabel = Bar:FindFirstChild("Void")

    if not Void then 
        error("Void not found in Slider item")
    end

    local Cursor : ImageLabel = Bar:FindFirstChild("Cursor")

    if not Cursor then 
        error("Filled not found in Slider item")
    end

    local DragDetector = Instance.new("UIDragDetector")
    DragDetector.BoundingUI = Void
    DragDetector.ReferenceUIInstance = Void
    DragDetector.DragStyle = Enum.UIDragDetectorDragStyle.TranslateLine
    DragDetector.Parent = Cursor

    -- Updates the value after each motion.
    local function updateValue(position : UDim2, rotation : number)
        local absSizeX = Bar.AbsoluteSize.X
        local sizeX = (Cursor.AbsolutePosition.X + Cursor.AbsoluteSize.X / 2) - Filled.AbsolutePosition.X --math.clamp((Cursor.AbsolutePosition.X + Cursor.AbsoluteSize.X / 2) - Filled.AbsolutePosition.X, 0, absSizeX)
        local scaleX = sizeX / absSizeX
        Filled.Size = UDim2.new(scaleX, 0, Filled.Size.Y.Scale, 0)

        local value = math.floor(range * scaleX)
        value = math.clamp(value, 0, range)

        infos.Value.Text = value
        callBack(value)
    end

    -- Reposition the cursor after motion and if the user stopped dragging.
    local function repositionCursor(inputPosition : Vector2)

    end

    DragDetector:AddConstraintFunction(1, updateValue)
    DragDetector.DragEnd:Connect(repositionCursor)
end

local selectorsIndex = {}
-- Sets up a Selector
function Widget.Selector(frame : Frame, items : table, startIndex : number, callBack : (value : any) -> ())
    local infos, success, errorMsg = Widget.isWidgetValid(frame)

    if not success then 
        error(errorMsg)
    end

    selectorsIndex[frame] = startIndex

    local Left : ImageButton = infos.Selector:FindFirstChild("Left")

    if not Left then 
        error("Left not found in Selector item")
    end

    local Right : ImageButton = infos.Selector:FindFirstChild("Right")

    if not Right then
        error("Right not found in Selector item")
    end

    Left.MouseButton1Click:Connect(function()
        local currentIndex = selectorsIndex[frame]
        local newIndex = currentIndex - 1

        if newIndex <= 0 then 
            newIndex = #items
        end

        selectorsIndex[frame] = newIndex

        local input = items[newIndex]
        infos.Input.Text = input
        
        callBack(input)
    end)

    Right.MouseButton1Click:Connect(function()
        local currentIndex = selectorsIndex[frame]
        local newIndex = currentIndex + 1

        if newIndex > #items then
            newIndex = 1
        end

        selectorsIndex[frame] = newIndex
        
        local input = items[newIndex]
        infos.Input.Text = input

        callBack(input)
    end)
end

return Widget