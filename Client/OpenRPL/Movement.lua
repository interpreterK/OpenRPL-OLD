local Movement = {
	Z = Vector3.zAxis/10,
	Y = Vector3.yAxis
}
Movement.__index = Movement

function Movement.new(Mover, Alt)
	local self = {}
	self.Mover = Mover
	self.Alt   = Alt
	return setmetatable(self, Movement)
end

function Movement:Forward()
	local dir = self.Mover.CFrame.LookVector
	if self.Alt then
		dir = self.Alt.CFrame.LookVector
	end
	self.Mover.Position+=dir+self.Z
end
function Movement:Back()
	local dir = self.Mover.CFrame.LookVector
	if self.Alt then
		dir = self.Alt.CFrame.LookVector
	end
	self.Mover.Position-=dir+self.Z
end
function Movement:Right()
	local dir = self.Mover.CFrame.RightVector
	if self.Alt then
		dir = self.Alt.CFrame.RightVector
	end
	self.Mover.Position+=dir+self.Z
end
function Movement:Left()
	local dir = self.Mover.CFrame.RightVector
	if self.Alt then
		dir = self.Alt.CFrame.RightVector
	end
	self.Mover.Position-=dir+self.Z
end
function Movement:Up()
	self.Mover.Position+=self.Y
end
function Movement:Down()
	self.Mover.Position-=self.Y
end

return Movement