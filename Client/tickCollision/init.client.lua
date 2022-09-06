local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Common, Instances = require(Shared:WaitForChild("Common")), require(script:WaitForChild("Instances"))
local S, thread, WFC = Common.S, Common.thread, Common.WFC

local Players = S.Players
local UIS = S.UserInputService
local RS = S.RunService
local Storage = S.ReplicatedStorage
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local Mover, FC, Pointer, LookX, LookY, LookZ = Instances.Mover, Instances.FC, Instances.Pointer, Instances.LookX, Instances.LookY, Instances.LookZ
local V3, CN, ANG, lookAt = Vector3.new, CFrame.new, CFrame.Angles, CFrame.lookAt
local CN_zero, CN_one, V3_zero, V3_one = CN(0,0,0), CN(1,1,1), Vector3.zero, Vector3.one
local pi = math.pi
local insert, find, remove = table.insert, table.find, table.remove

local cc = workspace.CurrentCamera

--Remove the default character
local function set_CameraPOV(BasePart)
	cc.CameraSubject = BasePart
	cc.CameraType = Enum.CameraType.Custom
end
local char = LocalPlayer.Character
while not char do
	char = LocalPlayer.CharacterAdded:Wait()
end
char:Destroy()
set_CameraPOV(Mover)
FC.Parent = cc

--Init the workspace physics
local PhysicsList = {}
local PhysicsList_Remote = WFC(Shared, 'PhysicsList', 10, "Fetching PhysicsList Remote...", "Got the PhysicsList Remote.", "Failed to fetch the PhysicsList, The physics engine will not work!")

--Controls
local Hold, Down, Up = {}, {}, {}
local MouseHit_p = V3_zero
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
local Sides, Corners = {}, {}
function Sides.Top(BasePart)
	return Mover.CFrame*CN(0,BasePart.Size.y/2,0)
end
function Sides.Bottom(BasePart)
	return Mover.CFrame*CN(0,BasePart.Size.y/-2,0)*ANG(pi/-2,0,0)
end
function Sides.Front(BasePart)
	return Mover.CFrame*CN(0,0,BasePart.Size.z/-2)
end
function Sides.Back(BasePart)
	return Mover.CFrame*CN(0,0,BasePart.Size.z/2)*ANG(0,pi,0)
end
function Sides.Left(BasePart)
	return Mover.CFrame*CN(BasePart.Size.x/-2,0,0)
end
function Sides.Right(BasePart)
	return Mover.CFrame*CN(BasePart.Size.x/2,0,0)*ANG(0,pi/-2,0)
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
local function frontFace(cf,size)
	local t = (cf+cf.LookVector*size.z/2)
	return t+t.UpVector*size.y/2
end
function Corners.Top_FrontRight(BasePart)
	local t = frontFace(BasePart.CFrame, BasePart.Size)
	return (t+t.RightVector*BasePart.Size.x/2).p
end
function Corners.Top_FrontLeft(BasePart)
	local t = frontFace(BasePart.CFrame, BasePart.Size)
	return (t-t.RightVector*BasePart.Size.x/2).p
end
local function backFace(cf,size)
	local t = (cf-cf.LookVector*size.z/2)
	return t-t.UpVector*size.y/2
end
function Corners.Top_BackRight(BasePart)
	local t = backFace(BasePart.CFrame, BasePart.Size)
	return (t+t.RightVector*BasePart.Size.x/2).p
end
function Corners.Top_BackLeft(BasePart)
	local t = backFace(BasePart.CFrame, BasePart.Size)
	return (t-t.RightVector*BasePart.Size.x/2).p
end

local ys = 1
local function m_2D_3DVector() --This is NOT suppose to be mouse.Target or react's to physics *yet* -09/04
	local SPTR = cc:ScreenPointToRay(MouseHit_p.x, MouseHit_p.y, 0)
	return (SPTR.Origin+Mover.CFrame.LookVector+SPTR.Direction*(cc.CFrame.p-Mover.CFrame.p).Magnitude*2)
end

--Step info
--https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/original/4X/0/b/6/0b6fde38a15dd528063a92ac8916ce3cd84fc1ce.png
RS.Heartbeat:Connect(function()
	thread(function()
		--Grab the physics info after a physics step
		PhysicsList = PhysicsList_Remote:InvokeServer()
	end)
	local z = Vector3.zAxis/10
	local lv, m_lv = cc.CFrame.LookVector, Mover.CFrame.LookVector
	local rv = cc.CFrame.RightVector
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
	if Hold.space then
		if not Freecam then
			if GroundPhysics then
				--jump
			else
				z/=100
			end
		end
		ys = .1
	else
		ys = 1
		z = Vector3.zAxis/10
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
RS.RenderStepped:Connect(function()
	--figure out a formula to get all sides (baseparts)
	for i = 1, #PhysicsList do
		local obj = PhysicsList[i]
		local floor = (obj.CFrame*CN(0,Mover.Size.y/2,0)).p
		local moverB = (Mover.CFrame*CN(0,Mover.Size.y/2,0)).p
		local unit = (floor-moverB).Unit



		--print(obj.Name,"=",unit)
	end
end)