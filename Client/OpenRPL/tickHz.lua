local tickHz = {}
tickHz.__index = tickHz

local Components = require(script.Parent)
local Shared     = Components.Shared
local S, New     = Shared.S, Shared.New

local RunS = S.RunService

local function CreateVM(Hz, Step_Func, STEP)
    local Hz_Bind = New('BindableEvent')
    local tdt     = 0
    local Connection;
    Hz = Hz or 60
    
    local function HzControl(dt,st)
        if Hz == 0 then
            Hz_Bind:Fire(tdt,dt,st)
            return
        end
        tdt+=dt
        if tdt>=1/(Hz+10) then
            Hz_Bind:Fire(tdt,dt,st)
            tdt=0
        end
    end
    if Step_Func == "Stepped" then
        Connection = RunS.Stepped:Connect(function(st,dt)
            HzControl(dt,st)
        end)
    else
        Connection = RunS[Step_Func]:Connect(HzControl)
    end

    return {
        Hz_Bind    = Hz_Bind,
        Connection = Connection
    }
end

function tickHz.new(Hz, Step)
    assert(Step, "Step instruction is required")
    local self          = {}
    local VM            = CreateVM(Hz, Step)
    self.Hz             = Hz
    self.TickStep       = VM.Hz_Bind.Event
    self.TickConnection = VM.Connection
    return setmetatable(self, tickHz)
end

return tickHz