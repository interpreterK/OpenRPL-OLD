local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Common = require(Shared:WaitForChild("Common"))
local New = Common.New

local insert, remove, find = table.insert, table.remove, table.find
local PhysicsList, IgnoredPhysicsList = {}, {}

local PhysicsList_Invoke = New('RemoteFunction', Shared, {Name = 'PhysicsList'})
PhysicsList_Invoke.OnServerInvoke = function(_)
	return PhysicsList
end

local function ConditionPassable(i)
	return i.Anchored and i.CanCollide
end
workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA('BasePart') then
		if ConditionPassable(descendant) then
			insert(PhysicsList, descendant)
			descendant.CanCollide = false
		else
			insert(IgnoredPhysicsList, descendant)
		end
	end
end)
workspace.DescendantRemoving:Connect(function(descendant)
	if descendant:IsA('BasePart') then
		local f = find(PhysicsList, descendant)
		if f then
			remove(PhysicsList, f)
		end
	end
end)

local desc = workspace:GetDescendants()
for i = 1, #desc do
	local p = desc[i]
	if p:IsA("BasePart") then
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
end

print("Ignored post-init instances=", IgnoredPhysicsList)