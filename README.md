# BlueBerry Framework

[BlueBerry] Is a lightweight framework for Roblox - Created for my games used inside Vulpes Studios. <br/>
Created by: @Mt1Fox | Vulpes Studios <br/>
Version: 1.2

# How to use

```BLueBerry.luau
BlueBerry:Init()
```
Run this before loading any modules to create a table and add BlueBerry to shared. <br/>

```BlueBerry.luau
BlueBerry:LoadModules(Parent : Instance, Category : string?, Debug : boolean?)
```
Used to load all the modules provided in parent, it loops through all childrens, requires them and adds them in table, after runs their :Init() and :Start() functions. Returns `self.LoadedModules` a table of all modules it just loaded. Category puts them in additional empty or not table and debug adds additional print/warns outputs in the console. <br/>

```BlueBerry.luau
BlueBerry:LoadModule(ModuleName : string, Category : string?, Debug : boolean?)
```
Used to load one specific module, doesn't runs :Init() and :Start(), only outputs debug.
