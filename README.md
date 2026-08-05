# BlueBerry Framework

[BlueBerry] Is a lightweight module loader framework for Roblox - Created for my games used inside Vulpes Studios. <br/>
Created by: @Mt1Fox | Vulpes Studios <br/>
Version: 1.8.1

# Get on Wally
https://wally.run/package/mt1fox/blueberry

# How to use

```BLueBerry.luau
BlueBerry:Init()
```
Run this before loading any modules to create a table and add BlueBerry to shared. <br/>

```BlueBerry.luau
BlueBerry:LoadModules(Parent : Instance, Category : string?, Debug : boolean?)
```
You can add .LoadingPriority to the modules, to load important modules first, priority is set to 1 by default.
Used to load all the modules provided in parent, it loops through all childrens, requires them and adds them in table, after runs their :Init() and :Start() functions. Returns `self.LoadedModules` a table of all modules it just loaded. Category puts them in additional empty or not table and debug adds additional print/warns outputs in the console. <br/>

```BlueBerry.luau
BlueBerry:LoadModule(Module : ModuleScript, Category : string?, Debug : boolean?, Initialize : boolean?, Start : boolean?)
```
Used to load one specific module, doesn't runs :Init() and :Start() by default, but could be enabled by adding booleans, only outputs debug.