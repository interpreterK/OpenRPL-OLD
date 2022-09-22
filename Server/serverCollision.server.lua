local OpenRPL = game:GetService("ReplicatedStorage"):WaitForChild("OpenRPL")
local Shared = require(OpenRPL:WaitForChild("Shared"))
local New = Shared.New

local insert, remove, find = table.insert, table.remove, table.find
local PhysicsList, IgnoredPhysicsList = {}, {}

local PhysicsList_Invoke = New('RemoteFunction', OpenRPL, {Name = 'PhysicsList'})
PhysicsList_Invoke.OnServerInvoke = function(_)
	return PhysicsList
end

local Supported_Objects = {
	"Part",
	"TrussPart"
}
local function ConditionPassable(inst)
	if inst:IsA("BasePart") and inst.Anchored and inst.CanCollide then
		for i = 1, #Supported_Objects do
			if inst.ClassName == Supported_Objects[i] then
				return true
			end
		end
	end
	return false
end
workspace.DescendantAdded:Connect(function(descendant)
	if ConditionPassable(descendant) then
		insert(PhysicsList, descendant)
		descendant.CanCollide = false
	else
		insert(IgnoredPhysicsList, descendant)
	end
end)
workspace.DescendantRemoving:Connect(function(descendant)
	local f = find(PhysicsList, descendant)
	if f then
		remove(PhysicsList, f)
	end
end)

local desc = workspace:GetDescendants()
for i = 1, #desc do
	local p = desc[i]
	if ConditionPassable(p) then
		local f = find(PhysicsList, p)
		if not f then
			insert(PhysicsList, p)
			p.CanCollide = false
		end
	else
		insert(IgnoredPhysicsList, p)
	end
end

print("Ignored post-init instances=",'{')
for i,v in next, IgnoredPhysicsList do
	print("["..tostring(i).."] = "..tostring(v)..",")
	if i == #IgnoredPhysicsList then
		print('}')
	end
end