local include = _G.__phys_modules__
local New = include'Shared'.New

local Mover = New('Part', workspace, {
    Name = "Mover",
    Size = Vector3.new(2,2,1),
    Position = Vector3.new(0,100,0),
    Color = Color3.new(1,1,1),
    Anchored = true,
    CanCollide = false,
    Transparency = .1
})
local Freecam = New('Part', workspace, {
    Size = Vector3.zero,
    CanCollide = false,
    Anchored = true,
    Transparency = 1
})
local Pointer = New('Part', workspace, {
    Size = Vector3.new(.5,.5,.5),
    Color = Color3.new(1,1,0),
    Shape = Enum.PartType.Ball,
    CanCollide = false,
    Anchored = true
})
local debug_ball = New('Part', workspace, {
    Size = Vector3.new(.5,.5,.5),
    Color = Color3.new(0,0,1),
    Shape = Enum.PartType.Ball,
    CanCollide = false,
    Anchored = true
})

return {
    Mover       = Mover,
    Freecam     = Freecam,
    Pointer     = Pointer,
    debug_ball  = debug_ball
}