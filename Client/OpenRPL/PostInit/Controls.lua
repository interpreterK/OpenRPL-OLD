local Controls = {}
Controls.__index = Controls

local include = _G.__openrpl_modules__
local New     = include'Shared'.New
local S       = include'Shared'.S
local UIS     = S.UserInputService

local IB, IE, IC;

local function new_Bind_System(self, KeyPressing_Remote, InputChanging_Remote)
	if IB or IE or IC then
		warn("Re-init'ing a new control system.")
		if IB then IB:Disconnect() end
		if IE then IE:Disconnect() end
		if IC then IC:Disconnect() end
	end

	IB = UIS.InputBegan:Connect(function(input, gameProcessed)
		local KeyName = input.KeyCode.Name:lower()
		KeyPressing_Remote:Fire(KeyName, true, gameProcessed)

		local Bind = self.KeyDown[KeyName]
		if Bind and gameProcessed == Bind.gameProcessed then
			Bind.Callback()
		end
	end)
	IE = UIS.InputEnded:Connect(function(input, gameProcessed)
		local KeyName = input.KeyCode.Name:lower()
		KeyPressing_Remote:Fire(KeyName, false, gameProcessed)

		local Bind = self.KeyUp[KeyName]
		if Bind and gameProcessed == Bind.gameProcessed then
			Bind.Callback()
		end
	end)
	IC = UIS.InputChanged:Connect(function(input, gameProcessed)
		InputChanging_Remote:Fire(input, gameProcessed)
	end)
end

function Controls.new(Bind_array)
	local self = {
		KeyDown = {},
		KeyUp   = {}
	}
	local KeyPressing_Remote = New('BindableEvent')
	local InputChanging_Remote = New('BindableEvent')

	self.KeyPressing   = KeyPressing_Remote.Event
	self.InputChanging = InputChanging_Remote.Event

	for key, CFG in next, Bind_array.KeyDown do
		if self.KeyDown[key] then
			warn("\""..key.."\" Is already registered with KeyDown, overwriting.")
		end
		self.KeyDown[key] = CFG
	end
	for key, CFG in next, Bind_array.KeyUp do
		if self.KeyUp[key] then
			warn("\""..key.."\" Is already registered with KeyUp, overwriting.")
		end
		self.KeyUp[key] = CFG
	end

	new_Bind_System(self, KeyPressing_Remote, InputChanging_Remote)
	self.InputBegan = IB
	self.InputEnded = IE
	self.InputChanged = IC

	return setmetatable(self, Controls)
end

function Controls:RemoveBind(Key)
	
end

function Controls:ForceAction(Key, isKeyDown)
	if isKeyDown then
		local Bind = self.KeyDown[Key]
		if Bind then
			Bind.Callback()
		end
	else
		local Bind = self.KeyUp[Key]
		if Bind then
			Bind.Callback()
		end
	end
end

return Controls