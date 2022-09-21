local Controls = {}
Controls.__index = Controls

local Modules = _G.__phys_modules__
local New     = Modules.Common.New
local S       = Modules.Common.S
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

		local Bind = self.Bindings.KeyDown[KeyName]
		if Bind and gameProcessed == Bind.gameProcessed then
			Bind.Callback()
		end
	end)
	IE = UIS.InputEnded:Connect(function(input, gameProcessed)
		local KeyName = input.KeyCode.Name:lower()
		KeyPressing_Remote:Fire(KeyName, false, gameProcessed)

		local Bind = self.Bindings.KeyUp[KeyName]
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
		Bindings = {
			KeyDown = {},
			KeyUp   = {}
		}
	}
	local KeyPressing_Remote   = New('BindableEvent')
	local InputChanging_Remote = New('BindableEvent')

	self.KeyPressing   = KeyPressing_Remote.Event
	self.InputChanging = InputChanging_Remote.Event

	for key, CFG in next, Bind_array.KeyDown do
		if self.Bindings.KeyDown[key] then
			warn("\""..key.."\" Is already registered with KeyDown, overwriting.")
		end
		self.Bindings.KeyDown[key] = CFG
	end
	for key, CFG in next, Bind_array.KeyUp do
		if self.Bindings.KeyUp[key] then
			warn("\""..key.."\" Is already registered with KeyUp, overwriting.")
		end
		self.Bindings.KeyUp[key] = CFG
	end

	new_Bind_System(self, KeyPressing_Remote, InputChanging_Remote)
	return setmetatable(self, Controls)
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