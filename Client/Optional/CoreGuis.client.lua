--This is an optional script in the OpenRPL repository, you may remove this script if you want default ROBLOX GUI's (such as Chat and the Leaderboards).

local include = _G.__openrpl_modules__
if not include then
    repeat
        task.wait()
    until _G.__openrpl_modules__
    include = _G.__openrpl_modules__
end

local Shared = include'Shared'
local S = Shared.S
local StarterGui = S.StarterGui

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)