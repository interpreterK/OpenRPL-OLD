local Controls = {Bindings = {}}
Controls.__index = Controls

local Modules = _G.__phys_modules__
local S = Modules.Common.S
local UIS = S.UserInputService
--[[
local Binds = {
	KeyDown = {
		["e"] = {
			gameProcessed = true/false,
			Callback = function
		}
	},
	KeyUp = {
	
	}
}
]]
UIS.InputBegan:Connect(function(input, gameProcessed)
	local Bind = Controls.KeyDown[input.KeyCode.Name]
	if Bind and Bind.gameProcessed == gameProcessed then
		Bind.Callback()
	end
end)
UIS.InputEnded:Connect(function(input, gameProcessed)
	local Bind = Controls.KeyUp[input.KeyCode.Name]
	if Bind and Bind.gameProcessed == gameProcessed then
		Bind.Callback()
	end
end)

function Controls.new(Bind_array)
	for key, CFG in next, Bind_array do
		if Controls.Bindings[key] then
			warn("\"..key..""\" Is already registered, overwriting.")
		end
		Controls.Bindings[key] = CFG
	end
end

function Controls:ForceAction()

end

return Controls
