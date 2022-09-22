local Mouse = {}
Mouse.__index = Mouse

function Mouse.new(Mover, CurrentCamera)
	local self = {}
	self.Mover = Mover
	self.CurrentCamera = CurrentCamera
	return setmetatable(self, Mouse)
end

function Mouse:PointRay(MouseHit)
	local Mover_CF = self.Mover.CFrame
	local ScreenRay = self.CurrentCamera:ScreenPointToRay(MouseHit.x, MouseHit.y, 0)
	return (ScreenRay.Origin+Mover_CF.LookVector+ScreenRay.Direction*(self.CurrentCamera.CFrame.p-Mover_CF.p).Magnitude*2)
end

return Mouse