local World = require(script.World)

World.Create()
World.CreateMeerkat()

--[[

local TextChatService = game:GetService("TextChatService")
local BubbleChatConfiguration = TextChatService.BubbleChatConfiguration

BubbleChatConfiguration.BackgroundColor3 = Color3.new(1,1,1)

]]