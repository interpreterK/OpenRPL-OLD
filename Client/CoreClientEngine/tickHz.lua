local tickHz = {}
tickHz.__index = tickHz

local Modules = _G.__phys_modules__
local Common = Modules.Common
local S, New = Common.S, Common.New

local RunS = S.RunService

local function CreateVM(FPS)
    local Hz_Bind = New('BindableEvent')
    local Hz, pdt = FPS or 60, 0
    local hstep = RunS.Heartbeat:Connect(function(dt)
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
    local self = {}
    local VM = CreateVM(Hz)
    self.Connection = VM.hstep
    self.OnNewTick = VM.Hz_Bind.Event
    return setmetatable(self, tickHz)
end

return tickHz