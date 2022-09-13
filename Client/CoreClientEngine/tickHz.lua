local tickHz = {}
tickHz.__index = tickHz

local Modules = _G.__phys_modules__
local Common = Modules.Common
local S, New = Common.S, Common.New

local RunS = S.RunService

local function CreateVM(FPS, Step_Func)
    local Hz_Bind = New('BindableEvent')
    local Hz, tdt = FPS or 60, 0
    local function HzControl(dt,st)
        tdt+=dt
        if Hz == 0 then
            Hz_Bind:Fire(tdt,dt,st)
            return
        end
        if tdt>=1/(Hz+10) then
            Hz_Bind:Fire(tdt,dt,st)
            tdt=0
        end
    end
    local Connection;
    if Step_Func == "Stepped" then
        Connection = RunS.Stepped:Connect(function(st,dt)
            HzControl(dt,st)
        end)
    else
        Connection = RunS[Step_Func]:Connect(HzControl)
    end
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