local tickHz = {}
tickHz.__index = tickHz

local Modules = _G.__phys_modules__
local Common = Modules.Common
local S, New = Common.S, Common.New

local RunS = S.RunService

local function CreateVM(FPS, Step_Func)
    local Hz_Bind = New('BindableEvent')
    local Hz, pdt = FPS or 60, 0
    local hstep = RunS[Step_Func]:Connect(function(dt)
        pdt+=dt
        if pdt>1/Hz then
            Hz_Bind:Fire(dt)
            pdt=0
        end
    end)
    return {
        Hz_Bind = Hz_Bind,
        hstep = hstep
    }
end

function tickHz.new(Hz)
    return setmetatable({Hz}, tickHz)
end

function tickHz:PreRender()
    
end

return tickHz