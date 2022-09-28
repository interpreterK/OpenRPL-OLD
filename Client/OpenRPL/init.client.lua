--[[
	A custom physics engine for ROBLOX.
	
	Author: interpreterK
	https://github.com/interpreterK/OpenRPL
]]

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local S = setmetatable({}, {
	__index = function(self,i)
		if not rawget(self,i) then
			self[i] = game:GetService(i)
		end
		return rawget(self,i)
	end
})

local Players = S.Players
local Storage = S.ReplicatedStorage

--Wait for all the require dependencies
local Modules = {'Controls','Instances','Mouse','Movement','tickHz','Computer'}
for i = 1, #Modules do
	script:WaitForChild(Modules[i])
end 
local OpenRPL_Directory  = Storage:WaitForChild("OpenRPL")
local PhysicsList_Remote = OpenRPL_Directory:WaitForChild("PhysicsList")

--Import the required dependencies
local Instances = require(script.Instances)
local Controls  = require(script.Controls)
local tickHz    = require(script.tickHz)
local Movement  = require(script.Movement)
local Mouse     = require(script.Mouse)
local Computer  = require(script.Computer)

local function thread(f)
	local new_thread = coroutine.wrap(f)
	local bool, error = pcall(new_thread)
	if not bool then
		warn(error, debug.traceback())
	end
end

local function New(Inst, Parent, Props)
	local i = Instance.new(Inst)
	for prop, value in next, Props or {} do
		pcall(function()
			i[prop] = value
		end)
	end
	i.Parent = Parent
	return i
end

local Mover       = Instances.Mover
local Freecam_Obj = Instances.Freecam
local Pointer     = Instances.Pointer
local debug_ball  = Instances.debug_ball

local V3, CN, ANG, lookAt = Vector3.new, CFrame.new, CFrame.Angles, CFrame.lookAt
local pi = math.pi

local Freecam             = false
local Ground              = false
local OnGround            = false
local Hit_Indicators      = true
local JumpHeight          = 20
local Jumping             = false
local StudSteps           = 1 --Never recommend below 1 or else the hit detection will/can be to perfect
local MaxGround_Detect    = 100
local MouseHit_p          = Vector3.zero

local LocalPlayer       = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Default_Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local PhysicsFPS_Remote  = New('BindableEvent', OpenRPL_Directory, {Name = "PhysicsFPS"})
local PlayerFPS_Remote   = New('BindableEvent', OpenRPL_Directory, {Name = "PlayerFPS"})

local CurrentCamera = workspace.CurrentCamera
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

local PhysicsList = {}
local PhysicsProperties = {
	Gravity = 195,
	Fall_Gain = 1e-3,
	JumpHeight = 20
}

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

--Init custom classes

local Movement = Movement.new(Mover)
--Step info
--https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/original/4X/0/b/6/0b6fde38a15dd528063a92ac8916ce3cd84fc1ce.png
local Heartbeat = tickHz.new(0, "Heartbeat")
local Stepped = tickHz.new(60, "Stepped")
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
local Controls = Controls.new(Bind_Map)
local Mouse = Mouse.new(Mover, CurrentCamera)
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
		Movement = Movement.new(Freecam_Obj, workspace.CurrentCamera)
		Camera_POV(workspace.CurrentCamera, Freecam_Obj)
	else
		Movement = Movement.new(Mover)
		Camera_POV(workspace.CurrentCamera, Mover)
	end
	print('Freecam=', Freecam)
end)

NewBind_KeyDown('h', function()
	Ground = not Ground
	Movement = Movement.new(Mover, workspace.CurrentCamera)
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


Heartbeat.TickStep:Connect(function(tdt,dt)
	thread(function()
		--Grab the physics info after a physics step
		PhysicsList = PhysicsList_Remote:InvokeServer()
	end)
	for i = 1, #PhysicsList do
		Computer.PhysicsObject = PhysicsList[i]
		Computer:Physics()
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
