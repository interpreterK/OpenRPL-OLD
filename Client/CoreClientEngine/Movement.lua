local Movement = {
	Z = Vector3.zAxis/10,
	Y = Vector3.yAxis
}
Movement.__index = Movement

function Movement.new(Mover)
	return setmetatable({
		Mover = Mover
	}, Movement)
end

function Movement:Forward()
	self.Mover.Position+=self.Mover.CFrame.LookVector+self.Z
end
function Movement:Back()
	self.Mover.Position-=self.Mover.CFrame.LookVector+self.Z
end
function Movement:Right()
	self.Mover.Position+=self.Mover.CFrame.RightVector+self.Z
end
function Movement:Left()
	self.Mover.Position-=self.Mover.CFrame.RightVector+self.Z
end
function Movement:Up()
	self.Mover.Position+=self.Y
end
function Movement:Down()
	self.Mover.Position-=self.Y
end

return Movement