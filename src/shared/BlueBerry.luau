--w-- // [BlueBerry] A lightweight framework module loader for Roblox - Created for my games used inside Vulpes Studios.
--w-- // Created by: @Mt1Fox | Vulpes Studios
--w-- // Version: 1.3

local RunService = game:GetService("RunService")
local Context = RunService:IsServer() and "Server" or "Client"

-----------------------------------------------------------------www

--w-- // How to use
--w-- // 1. Run BlueBerry:Init() before loading modules. This creates the table and sets shared.BlueBerry
--w-- // 2. Run BlueBerry:LoadModules(Parent, Category, Debug) to load, cache, and run :Init() and :Start() on all modules
--w-- // 2.1 Optionally you can run just BlueBerry:LoadModule(Module, Category, Debug) to load a single module instead of an entire folder

--w-- // Framework initialization
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

function BlueBerry:LoadModules(Parent : Instance, Category : string?, Debug : boolean?)
	if not Parent or not Parent:IsA("Instance") then
		warn("[BlueBerry]: Parent - " .. tostring(Parent) .. " provided is not a valid Instance.")
		return self.LoadedModules
	end

	local LoadedCount = 0
	local StartedModules = {}

	--w-- // Main loading loop, loops through all children of the provided Parent instance,
	--w-- // checks if they are ModuleScripts, and attempts to require them. It also tracks loading time for each module and prints debug information if enabled
	for _, Module in ipairs(Parent:GetChildren()) do
		if not Module:IsA("ModuleScript") then continue end
		if Module.Name == "BlueBerry" then continue end --w-- // Prevent loading itself if placed inside the same folder
		local StartTime = os.clock()
		local Success, Result = pcall(require, Module)
		local LoadTime = os.clock() - StartTime
		
		if Success then
			if Category then
				local CategoryTable = StartedModules[Category]
				if not CategoryTable then
					CategoryTable = {}
					StartedModules[Category] = CategoryTable
				end
				CategoryTable[Module.Name] = Result
			else
				StartedModules[Module.Name] = Result
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
	for Name, Item in pairs(StartedModules) do
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

	for Name, Item in pairs(StartedModules) do
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

	--w-- // Merging started modules with loaded modules
	for Key, Value in pairs(StartedModules) do
		BlueBerry.LoadedModules[Key] = Value
	end
	
	--w-- // Loading complete, print summary
	print("[BlueBerry]: Loaded " .. LoadedCount .. " modules from " .. Parent.Name .. " in: " .. Context .. " ✅")

	return StartedModules
end

function BlueBerry:LoadModule(Module : ModuleScript, Category : string?, Debug : boolean?)
	if not Module or not Module:IsA("ModuleScript") then
		warn("[BlueBerry]: Module - " .. tostring(Module) .. " provided is not a valid ModuleScript.")
		return nil
	end

	local StartTime = os.clock()
	local Success, Result = pcall(require, Module)
	local LoadTime = os.clock() - StartTime
	
	if Success then
		if Category then
			local CategoryTable = BlueBerry.LoadedModules[Category]
			if not CategoryTable then
				CategoryTable = {}
				BlueBerry.LoadedModules[Category] = CategoryTable
			end
			CategoryTable[Module.Name] = Result
		else
			BlueBerry.LoadedModules[Module.Name] = Result
		end
		if Debug then
			print("[BlueBerry]: Loaded module: " .. Module.Name .. " in: " .. string.format("%.4f", LoadTime) .. "s ✅")
		end

		return Result
	else
		warn("[BlueBerry]: Failed to load module: " .. Module.Name .. " Error: " .. tostring(Result) .. " ❌")
		return nil
	end
end

return BlueBerry