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

function Movement:Forward(Offset)
	Offset = Offset or Vector3.zero
	local dir = self.Mover.CFrame.LookVector
	if self.Alt then
		dir = self.Alt.CFrame.LookVector
	end
	self.Mover.Position+=dir+self.Z+Offset
end
function Movement:Back(Offset)
	Offset = Offset or Vector3.zero
	local dir = self.Mover.CFrame.LookVector
	if self.Alt then
		dir = self.Alt.CFrame.LookVector
	end
	self.Mover.Position-=dir+self.Z+Offset
end
function Movement:Right(Offset)
	Offset = Offset or Vector3.zero
	local dir = self.Mover.CFrame.RightVector
	if self.Alt then
		dir = self.Alt.CFrame.RightVector
	end
	self.Mover.Position+=dir+self.X+Offset
end
function Movement:Left(Offset)
	Offset = Offset or Vector3.zero
	local dir = self.Mover.CFrame.RightVector
	if self.Alt then
		dir = self.Alt.CFrame.RightVector
	end
	self.Mover.Position-=dir+self.X+Offset
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