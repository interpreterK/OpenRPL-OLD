local Modules = _G.__phys_modules__
local Common = Modules.Common
local New = Common.New

Mover = New('Part', workspace, {
    Name = "Mover",
    Size = Vector3.new(2,2,1),
    Position = Vector3.new(0,100,0),
    Anchored = true,
    CanCollide = false,
    --Transparency = .5
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