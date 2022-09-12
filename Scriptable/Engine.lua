--This module makes the engine scriptable and interactable with the client or server

local Engine = {
    Objects = {
        Server = {},
        Client = {}
    }
}
Engine.__index = Engine
Engine.__metatable = nil

function Engine.__newindex(self,i,v)
    local get = rawget(self,i)
    rawset(self,i,v)
    if get then
        warn("! \""..tostring(get).."\"", "Is overwritten.")
    end
end

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Common = require(Shared:WaitForChild("Common"))
local S = Common.S

local RunS = S.RunService

local Default_Properties = {
    Collisions = true,
    Anchored = true
}
local Properties = setmetatable(Default_Properties, {
    __index = function(self,i)
        return rawget(self,i)
    end,
    __metatable = nil
})

function Engine.newObject(Object)
    Engine.Objects[Object] = Properties
end

function Engine:SetProperties(Object, meta_Props)
    assert(self.Objects[Object], "Unknown Instance: \""..tostring(Object).."\"")
    
end

return Engine