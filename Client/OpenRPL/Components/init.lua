local OpenRPL_storage = game:GetService("ReplicatedStorage"):WaitForChild("OpenRPL")

local function GetModule(Name)
	local Module = script:WaitForChild(Name, 5)
	if Module then
		return require(Module)
	else
		warn("[OpenRPL]: CRITICAL - Failed to get: \""..Name.."\" module.")
	end
end

return {
	Shared = require(OpenRPL_storage:WaitForChild("Shared")),
	
}