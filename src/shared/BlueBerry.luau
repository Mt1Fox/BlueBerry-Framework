--w-- // [BlueBerry] A lightweight framework for Roblox - Created for my games used inside Vulpes Studios.
--w-- // Created by: @Mt1Fox | Vulpes Studios
--w-- // Version: 1.0

local RunService = game:GetService("RunService")
local Context = RunService:IsServer() and "Server" or "Client"

-----------------------------------------------------------------www

--w-- // How to access intellisense and load it?
--w-- // 1. Run LoadModules with the parent instance of the modules you want to load, and optionally a category and debug flag in server script or local
--w-- // 2. In different module/script, you just require the BlueBerry module and add ::typeof(require(Module)) so it will return the correct type and intellisense will work
--w-- // 2.1 You can also use shared.BlueBerry to access the framework, but require is recommended

--w-- // Definitions
export type ModuleReturn = {
	Init: ((self: ModuleReturn) -> ())?,
	Start: ((self: ModuleReturn) -> ())?,
	[string]: any
}

export type Registy = {
	[string]: ModuleReturn | Registy
}

type BlueBerry_t = {
	LoadedModules: Registy,
	Init: (self: BlueBerry_t) -> BlueBerry_t,
	LoadModules: (self: BlueBerry_t, Parent: Instance, Category: string?, Debug: boolean?) -> Registy
}

--w-- // Initialize with the correct type definition
local BlueBerry = {
	LoadedModules = {}
}

--w-- // Run this before loading modules
function BlueBerry:Init()
	print("[BlueBerry]: Initializing framework... ✅")
	BlueBerry.LoadedModules = {}
	shared.BlueBerry = self
	return self
end

function BlueBerry:LoadModules(Parent : Instance, Category : string?, Debug : boolean?) : Registy
	if not Parent or not Parent:IsA("Instance") then
		warn("[BlueBerry]: Parent - " .. tostring(Parent) .. " provided is not a valid Instance.")
		return self.LoadedModules
	end

	local LoadedCount = 0

	--w-- // Main loading loop, loops through all children of the provided Parent instance,
	--w-- // checks if they are ModuleScripts, and attempts to require them. It also tracks loading time for each module and prints debug information if enabled
	for _, Module in ipairs(Parent:GetChildren()) do
		if not Module:IsA("ModuleScript") then continue end
		local StartTime = os.clock()
		local Success, Result = pcall(require, Module)
		local LoadTime = os.clock() - StartTime
		
		if Success then
			if Category then
				local CategoryTable = BlueBerry.LoadedModules[Category]
				if not CategoryTable then
					CategoryTable = {} :: Registy
					BlueBerry.LoadedModules[Category] = CategoryTable
				end
				CategoryTable[Module.Name] = Result
			else
				BlueBerry.LoadedModules[Module.Name] = Result
			end
			LoadedCount += 1
			if Debug then
				print("[BlueBerry]: Loaded module: " .. Module.Name .. " in: " .. string.format("%.4f", LoadTime) .. "s ✅")
			end
		else
			warn("[BlueBerry]: Failed to load module: " .. Module.Name .. " Error: " .. tostring(Result) .. " ❌")
		end
	end

	--w-- // Second step, initializes and starts modules if they have Init and Start functions respectively.
	--w-- // It uses pcall to catch any errors during initialization or starting of modules and prints debug information if enabled.
	for Name, Item in pairs(BlueBerry.LoadedModules) do
		local IsCategory = type(Item) == "table" and not Item.Init and not Item.Start
		
		if IsCategory then
			for ModuleName, Module in pairs(Item) do
				if type(Module) == "table" and type(Module.Init) == "function" then
					local Success, Result = pcall(Module.Init, Module)
					if not Success then
						warn("[BlueBerry]: Failed to initialize module: " .. ModuleName .. " Error: " .. tostring(Result) .. " ❌")
					elseif Debug then
						print("[BlueBerry]: Initialized module: " .. ModuleName .. " ✅")
					end
				end
			end
		else
			if type(Item) == "table" and type(Item.Init) == "function" then
				local Success, Result = pcall(Item.Init, Item)
				if not Success then
					warn("[BlueBerry]: Failed to initialize module: " .. Name .. " Error: " .. tostring(Result) .. " ❌")
				elseif Debug then
					print("[BlueBerry]: Initialized module: " .. Name .. " ✅")
				end
			end
		end
	end

	for Name, Item in pairs(BlueBerry.LoadedModules) do
		local IsCategory = type(Item) == "table" and not Item.Init and not Item.Start
		
		if IsCategory then
			for ModuleName, Module in pairs(Item) do
				if type(Module) == "table" and type(Module.Start) == "function" then
					local Success, Result = pcall(Module.Start, Module)
					if not Success then
						warn("[BlueBerry]: Failed to start module: " .. ModuleName .. " Error: " .. tostring(Result) .. " ❌")
					elseif Debug then
						print("[BlueBerry]: Started module: " .. ModuleName .. " ✅")
					end
				end
			end
		else
			if type(Item) == "table" and type(Item.Start) == "function" then
				local Success, Result = pcall(Item.Start, Item)
				if not Success then
					warn("[BlueBerry]: Failed to start module: " .. Name .. " Error: " .. tostring(Result) .. " ❌")
				elseif Debug then
					print("[BlueBerry]: Started module: " .. Name .. " ✅")
				end
			end
		end
	end

	--w-- // Loading complete, print summary
	print("[BlueBerry]: Loaded " .. LoadedCount .. " modules from " .. Parent.Name .. " in: " .. Context .. " ✅")

	return self.LoadedModules
end

return BlueBerry