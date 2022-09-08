local tickHz = {}
tickHz.__index = tickHz

local Modules = _G.__phys_modules__
local Common = Modules.Common
local S, New = Common.S, Common.New

local RunS = S.RunService

local function CreateVM(FPS, Step_Func)
    local Hz_Bind = New('BindableEvent')
    local Hz, pdt = FPS or 60, 0
    local Connection = RunS[Step_Func]:Connect(function(dt)
        pdt+=dt
        if pdt>1/(Hz+4) then
            Hz_Bind:Fire(dt)
            pdt=0
        end
    end)
    return {
        Hz_Bind = Hz_Bind,
        Connection = Connection
    }
end

function tickHz.new(Hz, Step)
    assert(Step, "Step instruction is required")
    local self = {}
    local VM = CreateVM(Hz, Step)
    self.Hz = Hz
    self.TickStep = VM.Hz_Bind.Event
    self.TickConnection = VM.Connection
    return setmetatable(self, tickHz)
end

return tickHz