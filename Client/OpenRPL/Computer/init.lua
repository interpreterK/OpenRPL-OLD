local Computer = {
	World_Origin = Vector3.yAxis*100
}
Computer.__index = Computer

local Collision = require(script:WaitForChild('Collision'))
local Defaults = { --Read only, would not recommend changing.
	Gravity = 195,
	Fall_Gain = 1e-3,
	JumpHeight = 20,
	C_Indicators = false,
	Ground_Detection_Studs = 1.5,
}
local V3 = Vector3.new
local Fall_Velocity = 0

function Computer.new(Mover, Properties)
	local self                  = {}
	self.Mover                  = Mover
	self.Gravity                = Properties.Gravity or Defaults.Gravity
	self.Fall_Gain              = Properties.Fall_Gain or Defaults.Fall_Gain
	self.JumpHeight             = Properties.JumpHeight or Defaults.JumpHeight
	self.C_Indicators           = Properties.C_Indicators or Defaults.C_Indicators
	self.Ground_Detection_Studs = Properties.Ground_Detection_Studs or Defaults.Ground_Detection_Studs
	self.OnGround               = false
	self.Jumping                = false
	return setmetatable(self, Computer)
end

function Computer:World()
	if self.Mover.Position<=workspace.FallenPartsDestroyHeight then
		self.Mover.Position = self.World_Origin
	end
end

function Computer:Collision_Indicate(Hit_Matrix, Sides)
	if Hit_Matrix.inv_y[self.PhysicsObject] then
		Hit_Matrix.inv_y[self.PhysicsObject].Position = Sides.Bottom
	end
	if Hit_Matrix.y[self.PhysicsObject] then
		Hit_Matrix.y[self.PhysicsObject].Position = Sides.Top
	end
	if Hit_Matrix.x[self.PhysicsObject] then
		Hit_Matrix.x[self.PhysicsObject].Position = Sides.Left
	end
	if Hit_Matrix.inv_x[self.PhysicsObject] then
		Hit_Matrix.inv_x[self.PhysicsObject].Position = Sides.Right
	end
	if Hit_Matrix.z[self.PhysicsObject] then
		Hit_Matrix.z[self.PhysicsObject].Position = Sides.Front
	end
	if Hit_Matrix.inv_z[self.PhysicsObject] then
		Hit_Matrix.inv_z[self.PhysicsObject].Position = Sides.Back
	end
end

function Computer:Compute_FallVelociy(Ground_Level)
	if self.OnGround and not self.Jumping then
		local Mover_p = self.Mover.Position
		local Top_Ground = (Ground_Level+Mover_p).Unit+(self.PhysicsObject.Size/2)
		local Dist_Ground = -((Top_Ground-Mover_p).Unit.y*(Top_Ground+Mover_p).Magnitude)
		if Dist_Ground>=self.Ground_Detection_Studs then
			self.OnGround = false
			self.Mover.Position-=V3(0,.1+Fall_Velocity,0)
			Fall_Velocity+=self.Fall_Gain
		else
			self.OnGround = true
			Fall_Velocity = 0
		end
	end
end

function Computer:CalculateGeometry()
	local Mover = self.Mover
	local Mover_p, Object_p = Mover.Position, self.PhysicsObject.Position

	local Collision_Data = Collision.new(self.PhysicsObject, Mover)
	local Sides = Collision_Data:AllSides()
	local Top = Sides.Top

	if Mover_p.y==Top.y then
		Mover.Position=V3(Mover.Position.x,Top.y,Mover.Position.z)
	end

	return {
		Collision_Data = Collision_Data
	}
end

function Computer:Physics()
	local Geometry = self:CalculateGeometry(self.PhysicsObject)
	local Collisions = Geometry.Collision_Data

	self:Compute_FallVelociy(Collisions)
	if self.C_Indicators then
		self:Collision_Indicate(Collisions)
	end
end

function Computer:Jump(Step)
	local Mover = self.Mover
	local Goal = V3(0,self.JumpHeight,0)/10
	for i = 1, 10 do
		Step:Wait()
 		Mover.Position=Mover.Position:Lerp(Mover.Position+Goal,i/10)
	end
	for i = 1, 10 do
		Mover.Position=Mover.Position:Lerp(Mover.Position-Goal,i/10)
		Step:Wait()
	end
end

return Computer
