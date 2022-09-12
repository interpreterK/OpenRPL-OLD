if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Modules = {
	Common = require(Shared:WaitForChild("Common"))
}

_G.__phys_modules__ = setmetatable(Modules, {
	__index = function(self,i)
		local fenv = getfenv(2)
		if fenv.script and fenv.script:IsDescendantOf(script) then
			return rawget(self,i)
		end
	end,
	__metatable = nil
})
Modules.Instances = require(script:WaitForChild("Instances"))
Modules.tickHz = require(script:WaitForChild("tickHz"))

local S, thread, WFC, New = Modules.Common.S, Modules.Common.thread, Modules.Common.WFC, Modules.Common.New
local Players = S.Players
local UIS = S.UserInputService
local Storage = S.ReplicatedStorage

local Mover, FC, Pointer, LookX, LookY, LookZ = Modules.Instances.Mover, Modules.Instances.FC, Modules.Instances.Pointer, Modules.Instances.LookX, Modules.Instances.LookY, Modules.Instances.LookZ
local V3, CN, ANG, lookAt = Vector3.new, CFrame.new, CFrame.Angles, CFrame.lookAt
local pi, clamp, abs = math.pi, math.clamp, math.abs

--Remove the default character
local cc = workspace.CurrentCamera
local function set_CameraPOV(BasePart)
	cc.CameraSubject = BasePart
	cc.CameraType = Enum.CameraType.Custom
end
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
char:Destroy()
set_CameraPOV(Mover)
FC.Parent = cc

--Init the workspace physics
local PhysicsList = {}
local HitColliders = {
	x={},y={},z={},
	inv_x={},inv_y={},inv_z={}
}
local PhysicsList_Remote = WFC(Shared, 'PhysicsList', 10, "Fetching PhysicsList Remote...", "Got the PhysicsList Remote.", "Failed to fetch the PhysicsList, The physics engine will not work!")
--local PhysicsFPS = Storage:WaitForChild("PhysicsFPS")

local function Visual_HitCollisions(Type, Obj, Color, Side, Ang)
	HitColliders[Type][Obj] = New('Part', workspace, {
		Name='physics hit',
		Anchored=true,
		Size=V3(2,.1,2),
		Color=Color,
		Transparency=.5,
		Position=Obj.CFrame*Side,
		CFrame=Ang or CN()
	})
	--CN(0,PhysicsList[i].Size.y/2,0).p
end

--Controls
local Hold, Down, Up = {}, {}, {}
local MouseHit_p = Vector3.zero
local Freecam = false
local GroundPhysics = false
function Down.f()
	Freecam = not Freecam
	if Freecam then
		set_CameraPOV(FC)
	else
		set_CameraPOV(Mover)
	end
	print("freecam=",Freecam)
end
function Down.r()
	GroundPhysics = not GroundPhysics
	print("groundphysics=",GroundPhysics)
end
function Down.t()
	print(PhysicsList)
	warn("Printed the PhysicsList.")
end
Down.g = HitCollisions

UIS.InputBegan:Connect(function(input, gp)
	if not gp then
		local i = input.KeyCode.Name:lower()
		Hold[i] = true
		if Down[i] then
			Down[i]()
		end
	end
end)
UIS.InputEnded:Connect(function(input, gp)
	if not gp then
		local i = input.KeyCode.Name:lower()
		Hold[i] = false
		if Up[i] then
			Up[i]()
		end
	end
end)
UIS.InputChanged:Connect(function(input, _)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		MouseHit_p = input.Position
	end
end)
local Sides = {}
function Sides.Top(BasePart)
	return BasePart.CFrame*CN(0,BasePart.Size.y/2,0)
end
function Sides.Bottom(BasePart)
	return BasePart.CFrame*CN(0,BasePart.Size.y/-2,0)
end
function Sides.Front(BasePart)
	return BasePart.CFrame*CN(0,0,BasePart.Size.z/-2)
end
function Sides.Back(BasePart)
	return BasePart.CFrame*CN(0,0,BasePart.Size.z/2)
end
function Sides.Left(BasePart)
	return BasePart.CFrame*CN(BasePart.Size.x/-2,0,0)
end
function Sides.Right(BasePart)
	return BasePart.CFrame*CN(BasePart.Size.x/2,0,0)
end
--[[
function getCorners(part)	
local cf = part.CFrame
local size = part.Size

local corners = {}

-- helper cframes for intermediate steps
-- before finding the corners cframes.
-- With corners I only need cframe.Position of corner cframes.

-- face centers - 2 of 6 faces referenced
local frontFaceCenter = (cf + cf.LookVector * size.Z/2)
local backFaceCenter = (cf - cf.LookVector * size.Z/2)

-- edge centers - 4 of 12 edges referenced
local topFrontEdgeCenter = frontFaceCenter + frontFaceCenter.UpVector * size.Y/2
local bottomFrontEdgeCenter = frontFaceCenter - frontFaceCenter.UpVector * size.Y/2
local topBackEdgeCenter = backFaceCenter + backFaceCenter.UpVector * size.Y/2
local bottomBackEdgeCenter = backFaceCenter - backFaceCenter.UpVector * size.Y/2

-- corners
corners.topFrontRight = (topFrontEdgeCenter + topFrontEdgeCenter.RightVector * size.X/2).Position
corners.topFrontLeft = (topFrontEdgeCenter - topFrontEdgeCenter.RightVector * size.X/2).Position

corners.bottomFrontRight = (bottomFrontEdgeCenter + bottomFrontEdgeCenter.RightVector * size.X/2).Position
corners.bottomFrontLeft = (bottomFrontEdgeCenter - bottomFrontEdgeCenter.RightVector * size.X/2).Position

corners.topBackRight = (topBackEdgeCenter + topBackEdgeCenter.RightVector * size.X/2).Position
corners.topBackLeft = (topBackEdgeCenter - topBackEdgeCenter.RightVector * size.X/2).Position

corners.bottomBackRight = (bottomBackEdgeCenter + bottomBackEdgeCenter.RightVector * size.X/2).Position
corners.bottomBackLeft = (bottomBackEdgeCenter - bottomBackEdgeCenter.RightVector * size.X/2).Position

return corners
end
]]

local function m_2D_3DVector() --This is NOT suppose to be mouse.Target or react's to physics *yet* -09/04
	local SPTR = cc:ScreenPointToRay(MouseHit_p.x, MouseHit_p.y, 0)
	return (SPTR.Origin+Mover.CFrame.LookVector+SPTR.Direction*(cc.CFrame.p-Mover.CFrame.p).Magnitude*2)
end

--Step info
--https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/original/4X/0/b/6/0b6fde38a15dd528063a92ac8916ce3cd84fc1ce.png
local Heartbeat = Modules.tickHz.new(0, "Heartbeat")
local Stepped = Modules.tickHz.new(60, "Stepped")

local z = Vector3.zAxis/10
local ys = 1

Stepped.TickStep:Connect(function(_,_)
	local lv, m_lv = cc.CFrame.LookVector, Mover.CFrame.LookVector
	local rv = cc.CFrame.RightVector
	if Hold.space then
		lv = cc.CFrame.LookVector/5
		rv = cc.CFrame.RightVector/5
	end
	if Hold.w then
		if not Freecam then
			if GroundPhysics then
				
			else
				Mover.Position+=lv+z
			end
		else
			FC.Position+=lv+z
		end
	end
	if Hold.s then
		if not Freecam then
			Mover.Position-=lv+z
		else
			FC.Position-=lv+z
		end
	end
	if Hold.a then
		if not Freecam then
			Mover.Position-=rv+z
		else
			FC.Position-=rv+z
		end
	end
	if Hold.d then
		if not Freecam then
			Mover.Position+=rv+z
		else
			FC.Position+=rv+z
		end
	end
	if Hold.e then
		if not Freecam then
			Mover.Position+=V3(0,ys,0)
		else
			FC.Position+=V3(0,ys,0)
		end
	end
	if Hold.q then
		if not Freecam then
			Mover.Position-=V3(0,ys,0)
		else
			FC.Position-=V3(0,ys,0)
		end
	end
	if not Freecam then
		Pointer.Position=m_2D_3DVector()
		FC.Position=Mover.Position
		if not GroundPhysics then
			Mover.CFrame=lookAt(Mover.Position,m_2D_3DVector())
		end
	end
	LookX.CFrame=(Sides.Left(LookX))*ANG(0,0,pi/2)
	LookY.CFrame=(Sides.Top(LookY))*ANG(0,pi/2,0)
	LookZ.CFrame=(Sides.Front(LookZ))*ANG(pi/2,0,0)
end)

local function Hit_Detection_Top(Object, pos_i, Origin)
	local Hit = Vector3.zero
	pcall(function()
		local Top = Object.CFrame*CN(0,Object.Size.y/2,0)
		local point = pos_i+Top.p
		local abs_size_X = abs(Object.Size.x/2)
		local abs_size_Z = abs(Object.Size.z/2)
		local max_sX = clamp(-abs_size_X,-point.x,abs_size_X)
		local max_sZ = clamp(-abs_size_Z,-point.z,abs_size_Z)
		Hit =  V3(Origin.x+max_sX,Top.p.y,Origin.z+max_sZ)
	end)
	return Hit
end

local function Hit_Detection_Bottom(Object, pos_i, Origin)
	local Hit = Vector3.zero
	pcall(function()
		local Bottom = Object.CFrame*CN(0,Object.Size.y/-2,0)
		local point = pos_i+Bottom.p
		local abs_size_X = abs(Object.Size.x/-2)
		local abs_size_Z = abs(Object.Size.z/-2)
		local max_sX = clamp(-abs_size_X,-point.x,abs_size_X)
		local max_sZ = clamp(-abs_size_Z,-point.z,abs_size_Z)
		Hit = V3(Origin.x+max_sX,Bottom.p.y,Origin.z+max_sZ)
	end)
	return Hit
end

local function Hit_Detection_Left(Object, pos_i, Origin)
	local Hit = Vector3.zero
	pcall(function()
		local Top = Object.CFrame*CN(Object.Size.x/-2,0,0)
		local point = pos_i+Top.p
		local abs_size_Y = abs(Object.Size.y/-2)
		local abs_size_Z = abs(Object.Size.z/-2)
		local max_sY = clamp(-abs_size_Y,-point.y,abs_size_Y)
		local max_sZ = clamp(-abs_size_Z,-point.z,abs_size_Z)
		Hit = V3(Top.p.x,Origin.y+max_sY,Origin.z+max_sZ)
	end)
	return Hit
end

local function Hit_Detection_Right(Object, pos_i, Origin)
	local Hit = Vector3.zero
	pcall(function()
		local Top = Object.CFrame*CN(Object.Size.x/2,0,0)
		local point = pos_i+Top.p
		local abs_size_Y = abs(Object.Size.y/2)
		local abs_size_Z = abs(Object.Size.z/2)
		local max_sY = clamp(-abs_size_Y,-point.y,abs_size_Y)
		local max_sZ = clamp(-abs_size_Z,-point.z,abs_size_Z)
		Hit = V3(Top.p.x,Origin.y+max_sY,Origin.z+max_sZ)
	end)
	return Hit
end

local function Hit_Detection_Front(Object, pos_i, Origin)
	local Hit = Vector3.zero
	pcall(function()
		local Top = Object.CFrame*CN(0,0,Object.Size.z/2)
		local point = pos_i+Top.p
		local abs_size_Y = abs(Object.Size.y/2)
		local abs_size_X = abs(Object.Size.x/2)
		local max_sY = clamp(-abs_size_Y,-point.y,abs_size_Y)
		local max_sX = clamp(-abs_size_X,-point.x,abs_size_X)
		Hit = V3(Origin.x+max_sX,Origin.y+max_sY,Top.p.z)
	end)
	return Hit
end

local function Hit_Detection_Back(Object, pos_i, Origin)
	local Hit = Vector3.zero
	pcall(function()
		local Top = Object.CFrame*CN(0,0,Object.Size.z/-2)
		local point = pos_i+Top.p
		local abs_size_Y = abs(Object.Size.y/-2)
		local abs_size_X = abs(Object.Size.x/-2)
		local max_sY = clamp(-abs_size_Y,-point.y,abs_size_Y)
		local max_sX = clamp(-abs_size_X,-point.x,abs_size_X)
		Hit = V3(Origin.x+max_sX,Origin.y+max_sY,Top.p.z)
	end)
	return Hit
end

--Never recommend below 1 or else the physics will be to ~perfect~
local StudSteps = 1

local function ComputePhysics(Object, Object_p, Mover_p)
	--[[
		local Position = Obj.Position
		^~~~~~~~~~~~~~~~~~~~~~~~~~~~^
		Make this possible
	]]
	local M_bottom, M_left, M_front = Mover.Size.y/2, Mover.Size.x/-2, Mover.Size.z/2
	local M_top, M_right, M_back = Mover.Size.y-2, Mover.Size.x/2, Mover.Size.z/-2

	local y_hit_level, inv_y_hit_level = Hit_Detection_Top(Object, -Mover_p, Object_p), Hit_Detection_Bottom(Object, -Mover_p, Object_p)
	local x_hit_level, inv_x_hit_level = Hit_Detection_Left(Object, -Mover_p, Object_p), Hit_Detection_Right(Object, -Mover_p, Object_p)
	local z_hit_level, inv_z_hit_level = Hit_Detection_Front(Object, -Mover_p, Object_p), Hit_Detection_Back(Object, -Mover_p, Object_p)

	--Come up with a formula to get MinN-MaxN sizes for magnitude and angles of the mover

	if (Mover_p-y_hit_level).Magnitude<StudSteps then
		Mover.Position=V3(Mover_p.x,y_hit_level.y+M_bottom,Mover_p.z)
	end 
	if (Mover_p-x_hit_level).Magnitude<StudSteps then
		Mover.Position=V3(x_hit_level.x+M_left,Mover_p.y,Mover.Position.z)
	end
	if (Mover_p-z_hit_level).Magnitude<StudSteps then
		Mover.Position=V3(Mover_p.x,Mover_p.y,z_hit_level.z+M_front)
	end
	
	if (Mover_p-inv_y_hit_level).Magnitude<StudSteps then
		Mover.Position=V3(Mover_p.x,inv_y_hit_level.y-M_top,Mover_p.z)
	end
	

	if HitColliders.inv_y[Object] then
		HitColliders.inv_y[Object].Position = inv_y_hit_level
	end
	if HitColliders.y[Object] then
		HitColliders.y[Object].Position = y_hit_level
	end
	if HitColliders.x[Object] then
		HitColliders.x[Object].Position = x_hit_level
	end
	if HitColliders.inv_x[Object] then
		HitColliders.inv_x[Object].Position = inv_x_hit_level
	end
	if HitColliders.z[Object] then
		HitColliders.z[Object].Position = z_hit_level
	end
	if HitColliders.inv_z[Object] then
		HitColliders.inv_z[Object].Position = inv_z_hit_level
	end
end

Heartbeat.TickStep:Connect(function(tdt,dt)
	thread(function()
		--Grab the physics info after a physics step
		PhysicsList = PhysicsList_Remote:InvokeServer()
	end)
	for i = 1, #PhysicsList do
		local m_p = Mover.Position
		local Object = PhysicsList[i]
		local o_s, o_p = Object.Size, Object.Position
		local abs_size = (o_s.x/2+o_s.z/2)+o_s.y/2
		local Mag = (o_s-m_p).Unit+m_p
		if Object.Name == "Baseplate" then
			print("Mag=",Mag, "abs_size=",abs_size,"Condition=")
		end
		--[[
		if Mag<=abs_size then
			ComputePhysics(Object, o_p, m_p)
		end
		]]
	end
	--PhysicsFPS:Fire(dt)
end)

thread(function()
	repeat
		task.wait()
	until #PhysicsList ~= 0
	for i = 1, #PhysicsList do
		local Obj = PhysicsList[i]
		Visual_HitCollisions('y',Obj,Color3.new(1,1,0),CN(0,Obj.Size.y/2,0).p)
		Visual_HitCollisions('inv_y',Obj,Color3.new(0,0,1),CN(0,Obj.Size.y/-2,0).p)
		Visual_HitCollisions('z',Obj,Color3.new(1,0,0),CN(Obj.Size.x/-2,0,0).p,ANG(pi/2,0,0))
		Visual_HitCollisions('inv_z',Obj,Color3.new(0,1,0),CN(Obj.Size.x/2,0,0).p,ANG(pi/-2,0,0))
		Visual_HitCollisions('inv_x',Obj,Color3.new(1,0,1),CN(Obj.Size.x/2,0,0).p,ANG(0,0,pi/2))
		Visual_HitCollisions('x',Obj,Color3.new(1,0,1),CN(Obj.Size.x/2,0,0).p,ANG(0,0,pi/-2))
	end
end)