--[[
	A custom physics engine for ROBLOX.
	
	Author: interpreterK
	https://github.com/interpreterK/OpenRPL
]]

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Modules       = require(script:WaitForChild("Components"))
local S             = Modules.Shared.S
local thread        = Modules.Shared.thread
local Critical_wait = Modules.Shared.Critical_wait
local New           = Modules.Shared.New
local PhysicsFPS    = Modules.Shared.PhysicsFPS
local PlayerFPS     = Modules.Shared.PlayerFPS

local Mover       = Modules.Instances.Mover
local Freecam_Obj = Modules.Instances.Freecam
local Pointer     = Modules.Instances.Pointer
local debug_ball  = Modules.Instances.debug_ball

local Players = S.Players

local V3, CN, ANG, lookAt = Vector3.new, CFrame.new, CFrame.Angles, CFrame.lookAt
local pi = math.pi
local Freecam = false
local Ground  = false

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Default_Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local CurrentCamera = workspace.CurrentCamera

local PhysicsFPS_Remote = PhysicsFPS()
local PlayerFPS_Remote = PlayerFPS()

local function Camera_POV(CurrentCamera, Subject)
	CurrentCamera.CameraSubject = Subject
	CurrentCamera.CameraType = Enum.CameraType.Custom
end

local function NoCharacter(Subject, Current_Character)
	CurrentCamera = workspace.CurrentCamera
	Current_Character:Destroy()
	Freecam_Obj.Parent = CurrentCamera

	Camera_POV(CurrentCamera, Subject)
end

--Remove the default character
NoCharacter(Mover, Default_Character)
LocalPlayer.CharacterAdded:Connect(function(character)
	NoCharacter(Mover, character)
end)

--Init the workspace physics
--Critical dependency
local PhysicsList_Remote = Critical_wait(OpenRPL, 'PhysicsList', 10, "Fetching PhysicsList Remote...", "Got the PhysicsList Remote.", "Failed to fetch the PhysicsList, The physics engine will not work!")
local PhysicsList = {}
--
local Hit_Matrix = {
	x = {}, y = {}, z = {},
	inv_x = {}, inv_y = {}, inv_z = {}
}
local function Visual_HitCollisions(Type, Obj, Color, Side, Ang)
	Hit_Matrix[Type][Obj] = New('Part', workspace, {
		Name         = 'physics hit',
		Anchored     = true,
		Size         = V3(2,.1,2),
		Color        = Color,
		Transparency = .5,
		Position     = Obj.CFrame*Side,
		CFrame       = Ang or CN()
	})
end
local function HitCollisions_Visibility(value)
	local tobool = value and (.5 or 1)
	local FAT_table = {
		unpack(Hit_Matrix.x), unpack(Hit_Matrix.inv_x),
		unpack(Hit_Matrix.y), unpack(Hit_Matrix.inv_y),
		unpack(Hit_Matrix.z), unpack(Hit_Matrix.inv_z)
	}
	
	for i = 1, #FAT_table do
		FAT_table[i].Transparency = tobool
	end
end

local OnGround            = false
local Hit_Indicators      = true
local JumpHeight          = 20
local Jumping             = false
local StudSteps           = 1 --Never recommend below 1 or else the hit detection will/can be to perfect
local MaxGround_Detect    = 100
local Fall_velocity       = 1e-3
local Fall_velocity_level = 0
local Fall_velocity_max   = 5
local MouseHit_p          = Vector3.zero

--Init custom classes
local Movement = Modules.Movement.new(Mover)
--Step info
--https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/original/4X/0/b/6/0b6fde38a15dd528063a92ac8916ce3cd84fc1ce.png
local Heartbeat = Modules.tickHz.new(0, "Heartbeat")
local Stepped = Modules.tickHz.new(60, "Stepped")
--Controls
local Bind_Map = {
	KeyDown = {
		f = {gameProcessed = false},
		r = {gameProcessed = false},
		t = {gameProcessed = false},
		g = {gameProcessed = false},
		y = {gameProcessed = false},
		h = {gameProcessed = false}
	},
	KeyUp = {}
}
local KeyHolding = {}	
local Controls = Modules.Controls.new(Bind_Map)
local Mouse = Modules.Mouse.new(Mover, CurrentCamera)
--

local function NewBind_KeyDown(Key, Callback_Function)
	Bind_Map.KeyDown[Key].Callback = Callback_Function
end
local function NewBind_KeyUp(Key, Callback_Function)
	Bind_Map.KeyUp[Key].Callback = Callback_Function
end

NewBind_KeyDown('f', function()
	Freecam = not Freecam
	if Freecam then
		Movement = Modules.Movement.new(Freecam_Obj, workspace.CurrentCamera)
		Camera_POV(workspace.CurrentCamera, Freecam_Obj)
	else
		Movement = Modules.Movement.new(Mover)
		Camera_POV(workspace.CurrentCamera, Mover)
	end
	print('Freecam=', Freecam)
end)

NewBind_KeyDown('h', function()
	Ground = not Ground
	Movement = Modules.Movement.new(Mover, workspace.CurrentCamera)
	Mover.Orientation = Vector3.zero
	print('Ground=', Ground)
end)

NewBind_KeyDown('g', function()
	Hit_Indicators = not Hit_Indicators
	HitCollisions_Visibility(Hit_Indicators)
	print("Hit indicators=", Hit_Indicators)
end)

local function Reset()
	Mover.Position = Vector3.yAxis*100
end
NewBind_KeyDown('r', Reset)

--Init the control system
Controls.KeyPressing:Connect(function(KeyName, HeldDown, gameProcessed)
	if not gameProcessed then
		KeyHolding[KeyName] = HeldDown
	end
end)

Controls.InputChanging:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		MouseHit_p = input.Position
	end
end)

local function ComputeJump()
	local goal = V3(0,JumpHeight,0)/10
	for i = 1, 10 do
		Stepped.TickStep:Wait()
		Mover.Position=Mover.Position:Lerp(Mover.Position+goal,i/10)
	end
	for i = 1, 10 do
		Mover.Position=Mover.Position:Lerp(Mover.Position-goal,i/10)
		Stepped.TickStep:Wait()
	end
end

Stepped.TickStep:Connect(function(tdt,dt)
	local Dir = Mouse:PointRay(MouseHit_p)
	local Mover_cf = Mover.CFrame
	local ccf = CurrentCamera.CFrame
	if KeyHolding.w then
		Movement:Forward()
	end
	if KeyHolding.a then
		Movement:Left()
	end
	if KeyHolding.s then
		Movement:Back()
	end
	if KeyHolding.d then
		Movement:Right()
	end
	if KeyHolding.e then
		if not Ground then
			Movement:Up()
		end
	end
	if KeyHolding.q then
		if not Ground then
			Movement:Down()
		end
	end

	if KeyHolding.space then
		if Ground and OnGround and not Jumping then
			Jumping = true
			ComputeJump()
			Jumping = false
		end
	end


	if not Freecam then
		Pointer.Position=Mover_cf.p
		Freecam_Obj.Position=Mover.Position
		if not Ground then
			Mover.CFrame=lookAt(Mover.Position,Dir)
		end
	end
	if Ground then
		debug_ball.Transparency = 0
		debug_ball.Position = Dir
		Mover.CFrame=lookAt(Mover.Position,V3(ccf.Position.x,0,ccf.Position.z))
	else
		debug_ball.Transparency = 1
	end

	PlayerFPS_Remote:Fire(dt)
end)


local function ComputeFall_velocity(Object, Mover_p, y_hit_level)
	if Ground and not Jumping then
		local Ground_Detect = (y_hit_level+Mover_p).Unit+(Object.Size/2)
		local Ground_Unit = -((Ground_Detect-Mover_p).Unit.y*(Ground_Detect+Mover_p).Magnitude)
		if Ground_Unit>=StudSteps then
			OnGround = false
			Mover.Position-=V3(0,.1+Fall_velocity_level,0)
			Fall_velocity_level+=Fall_velocity
		else
			OnGround = true
			Fall_velocity_level=0
		end
	end
end

local Coordinate_Matrix = {
	
}

local function ComputePhysics(Object)
	local Mover_p = Mover.Position

	local Collision_data = Modules.Collision.new_block(Object, Mover)
	local Sides = Collision_data:AllSides()

	ComputeFall_velocity(Object, Mover_p, Sides.Top)

	--Come up with a formula to get MinN-MaxN sizes for magnitude and angles of the mover
	if (Mover_p-Sides.Top).Magnitude<=StudSteps then
		Mover.Position=V3(Mover_p.x,Sides.Top.y+Mover.Size.y/2,Mover_p.z)
	end
	if (Mover_p-Sides.Left).Magnitude<=StudSteps then
		Mover.Position=V3(Sides.Left.x+Mover.Size.x/-2,Mover_p.y,Mover.Position.z)
	end
	if (Mover_p-Sides.Front).Magnitude<=StudSteps then
		Mover.Position=V3(Mover_p.x,Mover_p.y,Sides.Front.z+Mover.Size.z/2)
	end
	
	if (Mover_p-Sides.Bottom).Magnitude<=StudSteps then
		Mover.Position=V3(Mover_p.x,Sides.Bottom.y-Mover.Size.y/2,Mover_p.z)
	end
	if (Mover_p-Sides.Right).Magnitude<=StudSteps then
		Mover.Position=V3(Sides.Right.x-Mover.Size.x/-2,Mover_p.y,Mover_p.z)
	end
	if (Mover_p-Sides.Back).Magnitude<=StudSteps then
		Mover.Position=V3(Mover_p.x,Mover_p.y,Sides.Back.z-Mover.Size.z/2)
	end

	if m_p.y<=workspace.FallenPartsDestroyHeight then
		Reset()
	end

	if Hit_Indicators then
		if Hit_Matrix.inv_y[Object] then
			Hit_Matrix.inv_y[Object].Position = Sides.Bottom
		end
		if Hit_Matrix.y[Object] then
			Hit_Matrix.y[Object].Position = Sides.Top
		end
		if Hit_Matrix.x[Object] then
			Hit_Matrix.x[Object].Position = Sides.Left
		end
		if Hit_Matrix.inv_x[Object] then
			Hit_Matrix.inv_x[Object].Position = Sides.Right
		end
		if Hit_Matrix.z[Object] then
			Hit_Matrix.z[Object].Position = Sides.Front
		end
		if Hit_Matrix.inv_z[Object] then
			Hit_Matrix.inv_z[Object].Position = Sides.Back
		end
	end
end

Heartbeat.TickStep:Connect(function(tdt,dt)
	thread(function()
		--Grab the physics info after a physics step
		PhysicsList = PhysicsList_Remote:InvokeServer()
	end)
	for i = 1, #PhysicsList do
		ComputePhysics(PhysicsList[i])
	end
	PhysicsFPS_Remote:Fire(dt)
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
		Visual_HitCollisions('x',Obj,Color3.new(1,0,1),CN(Obj.Size.x/2,0,0).p,ANG(0,0,pi/-2))
		Visual_HitCollisions('inv_x',Obj,Color3.new(0,1,1),CN(Obj.Size.x/2,0,0).p,ANG(0,0,pi/2))
	end
end)
