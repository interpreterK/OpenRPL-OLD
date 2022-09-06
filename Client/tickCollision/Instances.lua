local New = function(Inst, Parent, Props)
	local i = Instance.new(Inst)
	for prop, val in next, Props or {} do
		pcall(function()
			i[prop] = val
		end)
	end
	i.Parent = Parent
	return i
end
Mover = New('Part', workspace, {
    Name = "Mover",
    Size = Vector3.new(2,2,1),
    Position = Vector3.new(0,100,0),
    Anchored = true,
    CanCollide = false,
    Transparency = .5
})
LookY = New('Part', workspace, {
    Name = "looky",
    Size = Vector3.new(.1,2,.1),
    Color = Color3.new(0, 1, 0),
    Anchored = true,
    CanCollide = false
})
LookX = New('Part', workspace, {
    Name = "lookx",
    Size = Vector3.new(.1,2,.1),
    Color = Color3.new(0,0,1),
    Anchored = true,
    CanCollide = false
})
LookZ = New('Part', workspace, {
    Name = "lookz",
    Size = Vector3.new(.1,2,.1),
    Color = Color3.new(1,0,0),
    Anchored = true,
    CanCollide = false
})
FC = New('Part', workspace, {
    Size = Vector3.zero,
    CanCollide = false,
    Anchored = true,
    Transparency = 1
})
Pointer = New('Part', workspace, {
    Size = Vector3.new(.5,.5,.5),
    Color = Color3.new(1,1,0),
    Shape = Enum.PartType.Ball,
    CanCollide = false,
    Anchored = true
})


return getfenv()