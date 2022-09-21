--This is an optional script in the OpenRPL repository, you may remove this script if you want default ROBLOX GUI's (such as Chat and the Leaderboards).

local Modules = _G.__phys_modules__
if not Modules then
    repeat
        task.wait()
    until _G.__phys_modules__
    Modules = _G.__phys_modules__
end

local Common = Modules.Common
local S = Common.S
local StarterGui = S.StarterGui

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)