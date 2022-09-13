local Vars = {}
Vars.__index = Vars

local resume, create = coroutine.resume, coroutine.create
local WFC = game.WaitForChild
local PhysicsFPS_Event = nil

Vars.S = setmetatable({}, {
	__index = function(self,i)
		if not rawget(self,i) then
			self[i] = game:GetService(i)
		end
		return rawget(self,i)
	end
})
local Storage = Vars.S.ReplicatedStorage

Vars.ptrace = function(func)
	local b,e = pcall(func)
	if not b then
		warn(e, debug.traceback())
	end
end

Vars.thread = function(thread_f)
	local b,e = resume(create(thread_f))
	if not b then
		warn(e, debug.traceback())
	end
end

Vars.New = function(Inst, Parent, Props)
	local i = Instance.new(Inst)
	for prop, val in next, Props or {} do
		Vars.ptrace(function()
			i[prop] = val
		end)
	end
	i.Parent = Parent
	return i
end

Vars.PhysicsFPS = function()
	if not PhysicsFPS_Event then
		PhysicsFPS_Event = Vars.New("BindableEvent", Storage, {Name = "PhysicsFPS"})
	end
	return PhysicsFPS_Event
end

Vars.Remove = function(Inst)
	Vars.ptrace(function()
		Inst:Destroy()
	end)
end

--Use for important instances and locations
Vars.WFC = function(Parent, Name, Timeout, pt_MSG, gp_MSG, nil_MSG)
	if pt_MSG then
		print(pt_MSG)
	end
	local i = WFC(Parent, Name, Timeout or math.huge)
	if not i and nil_MSG then
		warn(nil_MSG)
	end
	if gp_MSG then
		print(gp_MSG)
	end
	return i
end

function Vars.write(array)
	for i,v in next, array do
		Vars[i] = v
	end
end

return Vars