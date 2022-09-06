local Common = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Common"))
local New, S = Common.New, Common.S

local insert, remove, find = table.insert, table.remove, table.find
local PhysicsList = {}

local PhysicsList_Invoke = New('RemoteFunction', S.ReplicatedStorage, {Name = 'PhysicsList'})
PhysicsList_Invoke.OnServerInvoke = function(_)
	return PhysicsList
end

local function ConditionPassable(i)
	return i:IsA('BasePart') and (i.Anchored and i.CanCollide)
end
workspace.DescendantAdded:Connect(function(descendant)
	if ConditionPassable(descendant) then
		insert(PhysicsList, descendant)
		descendant.CanCollide = false
	else
		print('ignoring instance=',descendant)
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
	if ConditionPassable(desc[i]) then
		desc[i].CanCollide = false
	else
		print('ignoring instance=',desc[i])
	end
end