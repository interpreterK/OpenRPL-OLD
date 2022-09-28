local Collision = {}
Collision.__index = Collision

local abs, clamp = math.abs, math.clamp
local V3, CN = Vector3.new, CFrame.new

local function Hit_Detection_Top(self)
	local Object = self.Object
	local Inv_Pos = -self.Mover.Position
	local p = Object.Position
	local Hit = Vector3.zero
	pcall(function()
		local Top = Object.CFrame*CN(0,Object.Size.y/2,0)
		local point = Inv_Pos+Top.p
		local abs_size_X = abs(Object.Size.x/2)
		local abs_size_Z = abs(Object.Size.z/2)
		local max_sX = clamp(-abs_size_X,-point.x,abs_size_X)
		local max_sZ = clamp(-abs_size_Z,-point.z,abs_size_Z)
		Hit = V3(p.x+max_sX,Top.p.y,p.z+max_sZ)
	end)
	return Hit
end
local function Hit_Detection_Bottom(self)
	local Object = self.Object
	local Inv_Pos = -self.Mover.Position
	local p = Object.Position
	local Hit = Vector3.zero
	pcall(function()
		local Bottom = Object.CFrame*CN(0,Object.Size.y/-2,0)
		local point = Inv_Pos+Bottom.p
		local abs_size_X = abs(Object.Size.x/-2)
		local abs_size_Z = abs(Object.Size.z/-2)
		local max_sX = clamp(-abs_size_X,-point.x,abs_size_X)
		local max_sZ = clamp(-abs_size_Z,-point.z,abs_size_Z)
		Hit = V3(p.x+max_sX,Bottom.p.y,p.z+max_sZ)
	end)
	return Hit
end
local function Hit_Detection_Left(self)
	local Object = self.Object
	local Inv_Pos = -self.Mover.Position
	local p = Object.Position
	local Hit = Vector3.zero
	pcall(function()
		local Left = Object.CFrame*CN(Object.Size.x/-2,0,0)
		local point = Inv_Pos+Left.p
		local abs_size_Y = abs(Object.Size.y/-2)
		local abs_size_Z = abs(Object.Size.z/-2)
		local max_sY = clamp(-abs_size_Y,-point.y,abs_size_Y)
		local max_sZ = clamp(-abs_size_Z,-point.z,abs_size_Z)
		Hit = V3(Left.p.x,p.y+max_sY,p.z+max_sZ)
	end)
	return Hit
end
local function Hit_Detection_Right(self)
	local Object = self.Object
	local Inv_Pos = -self.Mover.Position
	local p = Object.Position
	local Hit = Vector3.zero
	pcall(function()
		local Right = Object.CFrame*CN(Object.Size.x/2,0,0)
		local point = Inv_Pos+Right.p
		local abs_size_Y = abs(Object.Size.y/2)
		local abs_size_Z = abs(Object.Size.z/2)
		local max_sY = clamp(-abs_size_Y,-point.y,abs_size_Y)
		local max_sZ = clamp(-abs_size_Z,-point.z,abs_size_Z)
		Hit = V3(Right.p.x,p.y+max_sY,p.z+max_sZ)
	end)
	return Hit
end
local function Hit_Detection_Front(self)
	local Object = self.Object
	local Inv_Pos = -self.Mover.Position
	local p = Object.Position
	local Hit = Vector3.zero
	pcall(function()
		local Front = Object.CFrame*CN(0,0,Object.Size.z/2)
		local point = Inv_Pos+Front.p
		local abs_size_Y = abs(Object.Size.y/2)
		local abs_size_X = abs(Object.Size.x/2)
		local max_sY = clamp(-abs_size_Y,-point.y,abs_size_Y)
		local max_sX = clamp(-abs_size_X,-point.x,abs_size_X)
		Hit = V3(p.x+max_sX,p.y+max_sY,Front.p.z)
	end)
	return Hit
end
local function Hit_Detection_Back(self)
	local Object = self.Object
	local Inv_Pos = -self.Mover.Position
	local p = Object.Position
	local Hit = Vector3.zero
	pcall(function()
		local Back = Object.CFrame*CN(0,0,Object.Size.z/-2)
		local point = Inv_Pos+Back.p
		local abs_size_Y = abs(Object.Size.y/-2)
		local abs_size_X = abs(Object.Size.x/-2)
		local max_sY = clamp(-abs_size_Y,-point.y,abs_size_Y)
		local max_sX = clamp(-abs_size_X,-point.x,abs_size_X)
		Hit = V3(p.x+max_sX,p.y+max_sY,Back.p.z)
	end)
	return Hit
end

function Collision.new(Object, Mover)
	local self = {}
	self.Object = Object
	self.Mover  = Mover
	return setmetatable(self, Collision)
end

function Collision:Top()
	return Hit_Detection_Top(self)
end
function Collision:Bottom()
	return Hit_Detection_Bottom(self)
end
function Collision:Left()
	return Hit_Detection_Left(self)
end
function Collision:Right()
	return Hit_Detection_Right(self)
end
function Collision:Front()
	return Hit_Detection_Front(self)
end
function Collision:Back()
	return Hit_Detection_Back(self)
end

function Collision:AllSides()
	return {
		Top    = self:Top(),
		Bottom = self:Bottom(),
		Left   = self:Left(),
		Right  = self:Right(),
		Front  = self:Front(),
		Back   = self:Back()
	}
end

return Collision
