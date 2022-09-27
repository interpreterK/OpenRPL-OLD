local Movement = {
	X = Vector3.xAxis/10,
	Y = Vector3.yAxis,
	Z = Vector3.zAxis/10
}
Movement.__index = Movement

function Movement.new(Mover, Alt)
	local self = {}
	self.Mover = Mover
	self.Alt   = Alt
	return setmetatable(self, Movement)
end

local function Look(self)
	if self.Alt then
		return self.Alt.CFrame.LookVector
	end
	return self.Mover.CFrame.LookVector
end
local function RightLook(self) 
	if self.Alt then
		return self.Alt.CFrame.RightVector
	end
	return self.Mover.CFrame.RightVector
end

function Movement:Forward(Offset)
	Offset = Offset or Vector3.zero
	self.Mover.Position+=Look(self)+self.Z+Offset
end
function Movement:Back(Offset)
	Offset = Offset or Vector3.zero
	self.Mover.Position-=Look(self)+self.Z+Offset
end
function Movement:Right(Offset)
	Offset = Offset or Vector3.zero
	self.Mover.Position+=RightLook(self)+self.X+Offset
end
function Movement:Left(Offset)
	Offset = Offset or Vector3.zero
	self.Mover.Position-=RightLook(self)+self.X+Offset
end
function Movement:Up(Offset)
	Offset = Offset or Vector3.zero
	self.Mover.Position+=self.Y+Offset
end
function Movement:Down(Offset)
	Offset = Offset or Vector3.zero
	self.Mover.Position-=self.Y+Offset
end

return Movement