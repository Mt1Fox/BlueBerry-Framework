local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlueBerry = require(ReplicatedStorage.Shared:WaitForChild("BlueBerry")) :: typeof(require(ReplicatedStorage.Shared:WaitForChild("BlueBerry")))

BlueBerry:Init()
BlueBerry:LoadModules(script)