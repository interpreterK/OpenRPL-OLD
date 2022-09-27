local Computer = {}
Computer.__index = Computer

local Defaults = { --Read only, would not recommend changing.
	Gravity = 195,
	Fall_Gain = 1e-3
}

local Velocity = 0

function Computer.new(Mover, Properties)
	local self = {}
	self.Mover     = Mover
	self.Gravity   = Properties.Gravity or Defaults.Gravity
	self.Fall_Gain = Properties.Fall_Gain or Defaults.Fall_Gain
	self.OnGround  = false
	self.Jumping   = false
	return setmetatable(self, Computer)
end

function Computer:CalculateGeometry(Object)
	
end

function Computer:Jump(Ground_Level)
	if self.OnGround and not self.Jumping then
		local Mover_p = self.Mover.Position
		
		local Ground = (Ground_Level+Mover_p).Unit
	end
end

return Computer