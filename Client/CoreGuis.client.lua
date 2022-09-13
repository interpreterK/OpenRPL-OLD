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