
const _Description = "[BlueBerry] - Is a lightweight framework module loader for Roblox - Created for my games used inside Vulpes Studios."
const _Created     = "by: @Mt1Fox | Vulpes Studios"
const _Version     = 1.7

local RunService = game:GetService("RunService")
local Context = RunService:IsServer() and "Server" or "Client"
--------------------------------------------------------------------www

--w-- // How to use
--w-- // 1.  Run BlueBerry:Init() before loading modules. This creates the table and sets shared.BlueBerry
--w-- // 2.  Run BlueBerry:LoadModules(Parent, Category, Debug) to load, cache, 
--w-- //     and run :Init() (or :init, :_init, :initialize) with :Start() (or :start, :_start) on all modules
--w-- // 2.1 Optionally you can run BlueBerry:LoadModule(Module, Category, Debug) to load a single module instead of an entire folder

--w-- // Framework initialization
local BlueBerry = {}

--w-- // Run this before loading modules
function BlueBerry:Init()
	print(("[BlueBerry]: Initializing framework version %s... ✅"):format(tostring(_Version)))
	BlueBerry.LoadedModules = {}
	shared.BlueBerry = self
	return self
end

function BlueBerry:LoadModules(Parent : Instance, Category : string?, Debug : boolean?)
	if not Parent or not Parent:IsA("Instance") then
		warn("[BlueBerry]: Parent - " .. tostring(Parent) .. " provided is not a valid Instance.")
		return self.LoadedModules
	end

	if not BlueBerry.LoadedModules then
		warn("[BlueBerry]: BlueBerry framework is not initialized. Please run BlueBerry:Init() before loading modules.")
		return nil
	end

	local LoadedCount = 0
	local StartedModules = {}

	--w-- // Main loading loop, loops through all children of the provided Parent instance,
	--w-- // checks if they are ModuleScripts, and attempts to require them. It also tracks loading time for each module and prints debug information if enabled
	for _, Module in ipairs(Parent:GetChildren()) do
		if not Module:IsA("ModuleScript") and not Module:IsA("ObjectValue") then continue end
		if Module.Name == "BlueBerry" then continue end --w-- // Prevent loading itself if placed inside the same folder

		if BlueBerry.LoadedModules[Module.Name] then
			warn("[BlueBerry]: Module - " .. Module.Name .. " is already loaded. Skipping.")
			continue
		end

		local StartTime = os.clock()
		local Success, Result = pcall(require, Module:IsA("ObjectValue") and Module.Value or Module)
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
				print("[BlueBerry]: Loaded module: " ..Parent.Name.."/"..Module.Name .. " in: " .. string.format("%.4f", LoadTime) .. "s ✅")
			end
		else
			warn("[BlueBerry]: Failed to load module: " ..Parent.Name.."/".. Module.Name .. " Error: " .. tostring(Result) .. " ❌")
		end
	end

	--w-- // Second step, initializes and starts modules if they have Init and Start functions respectively.
	--w-- // It uses pcall to catch any errors during initialization or starting of modules and prints debug information if enabled.
	for Name, Item in pairs(StartedModules) do
		local IsCategory = type(Item) == "table" and not Item.Init and not Item._init and not Item.init and not Item.initialize 
				and not Item.Start and not Item._start and not Item.start
		
		if IsCategory then
			for ModuleName, Module in pairs(Item) do
				if type(Module) == "table" and (type(Module.Init) == "function" or type(Module.initialize) == "function" or type(Module._init) == "function" or type(Module.init) == "function") then
					local Require = Module.Init and Module.Init or Module._init and Module._init or Module.init and Module.init or Module.initialize and Module.initialize
					local Success, Result = pcall(Require, Module)
					if not Success then
						warn("[BlueBerry]: Failed to initialize module: " .. ModuleName .. " Error: " .. tostring(Result) .. " ❌")
					elseif Debug then
						print("[BlueBerry]: Initialized module: " .. ModuleName .. " ✅")
					end
				end
			end
		else
			if type(Item) == "table" and (type(Item.Init) == "function" or type(Item.initialize) == "function" or type(Item._init) == "function" or type(Item.init) == "function") then
				local Require = Item.Init and Item.Init or Item._init and Item._init or Item.init and Item.init or Item.initialize and Item.initialize
				local Success, Result = pcall(Require, Item)
				if not Success then
					warn("[BlueBerry]: Failed to initialize module: " .. Name .. " Error: " .. tostring(Result) .. " ❌")
				elseif Debug then
					print("[BlueBerry]: Initialized module: " .. Name .. " ✅")
				end
			end
		end
	end

	for Name, Item in pairs(StartedModules) do
		local IsCategory = type(Item) == "table" and not Item.Init and not Item._init and not Item.init and not Item.initialize 
				and not Item.Start and not Item._start and not Item.start
		
		if IsCategory then
			for ModuleName, Module in pairs(Item) do
				if type(Module) == "table" and (type(Module.Start) == "function" or type(Module._start) == "function" or type(Module.start) == "function") then
					local Require = Module.Start and Module.Start or Module._start and Module._start or Module.start and Module.start
					local Success, Result = pcall(Require, Module)
					if not Success then
						warn("[BlueBerry]: Failed to start module: " .. ModuleName .. " Error: " .. tostring(Result) .. " ❌")
					elseif Debug then
						print("[BlueBerry]: Started module: " .. ModuleName .. " ✅")
					end
				end
			end
		else
			if type(Item) == "table" and (type(Item.Start) == "function" or type(Item._start) == "function" or type(Item.start) == "function") then
				local Require = Item.Start and Item.Start or Item._start and Item._start or Item.start and Item.start
				local Success, Result = pcall(Require, Item)
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

	if not BlueBerry.LoadedModules then
		warn("[BlueBerry]: BlueBerry framework is not initialized. Please run BlueBerry:Init() before loading modules.")
		return nil
	end

	if BlueBerry.LoadedModules[Module.Name] then
		warn("[BlueBerry]: Module - " .. Module.Name .. " is already loaded. Skipping.")
		return BlueBerry.LoadedModules[Module.Name]
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