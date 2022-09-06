local desc = workspace:GetDescendants()

workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("BasePart") then
		descendant.CanCollide = false
	end
end)
for i = 1, #desc do
	if desc[i]:IsA("BasePart") then
		desc[i].CanCollide = false
	end
end