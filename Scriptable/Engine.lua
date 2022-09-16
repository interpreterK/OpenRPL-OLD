--This module makes the engine scriptable and interactable with the client or server

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Common = require(Shared:WaitForChild("Common"))

local Engine = {Objects = {}}
Engine.__index = Engine
Engine.__metatable = nil

function Engine.__newindex(self,i,v)
    local get = rawget(self,i)
    rawset(self,i,v)
    if get then
        warn("! \""..tostring(get).."\"", "Is overwritten.")
    end
end

local S = Common.S
local RunS = S.RunService

local Properties = setmetatable({
    Collisions = true,
    Anchored = true
}, {
    __index = function(self,i)
        return rawget(self,i)
    end,
    __newindex = function(self,i,v)
        if rawget(self,i) then
            rawset(self,i,v)
        else
            print("\""..tostring(i).."\"", "Is not a valid member of Properties.")
        end
    end,
    __metatable = nil
})

function Engine.New(Object)
    Engine.Objects[Object] = Properties
end

function Engine:SetProperties(Object, meta_Props)
    assert(self.Objects[Object], "Unknown Instance: \""..tostring(Object).."\"")
    Engine.Objects[Object] = Properties
    for ind, val in next, meta_Props do
        Engine.Objects[Object][ind] = val
    end
end

return Engine