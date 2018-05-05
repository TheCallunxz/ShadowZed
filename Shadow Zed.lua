--***Shadow Zed***--

if myHero.charName ~= "Zed" then return end

local version,author,lVersion = "v0.1","TheCallunxz","8.9"

local shadow1_pos = "null"
local shadow2_pos = "null"

local MenuIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/3/3f/Living_Shadow.png"

if FileExist(COMMON_PATH .. "HPred.lua") 
and FileExist(COMMON_PATH .. "DamageLib.lua") 
and FileExist(COMMON_PATH .. "MapPosition.lua") 
and FileExist(COMMON_PATH .. "Collision.lua") then

    require "DamageLib"
    require "MapPosition"
    require "HPred"
    require "Collision"

    PrintChat("All libraries loaded successfully!")
else
    PrintChat("ERROR. Failed to load libraries")
    return end
end

class "Zed"

function Zed:LoadSpells()
	Q = {Range = 900, Width = 40, Delay = 0.40, Speed = 900, Collision = false, aoe = false, Type = "line"}
	W = {Range = 650, Delay = 0.40, Speed = 1750, Collision = false, aoe = false, Type = "line"}
	E = {Delay = 0.40, Speed = 1750, Collision = false, aoe = false, Type = "circular", Radius = 290}
	R = {}
end

function Zed:LoadMenu()
    ZedMenu = MenuElement({type = MENU, id = "Zed", name = "Shadow Zed | " ..version.. "", icon = MenuIcon})
    
	ZedMenu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	ZedMenu.Combo:MenuElement({id = "useQ", name = "Q", value = true})
	ZedMenu.Combo:MenuElement({id = "useW", name = "W", value = true})
    ZedMenu.Combo:MenuElement({id = "useE", name = "E", value = true})
    
    ZedMenu.Combo:MenuElement({id = "useItems", name = "UseItems?", value = true})
    ZedMenu.Combo:MenuElement({id = "ignite", name = "Ignite?", value = true})
    ZedMenu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	
    ZedMenu:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
    ZedMenu.Killsteal:MenuElement({id = "ksQ", name = "KS Q", value = true})

    ZedMenu:MenuElement({id = "Auto", name = "Auto", type = MENU})
    ZedMenu.Auto:MenuElement({id = "autoE", name = "Auto E", value = true})
    ZedMenu.Auto:MenuElement({id = "autoEEnergy", name = "Auto E Energy Needed", value = 50, min = 50, max = 200, step = 10})

    ZedMenu:MenuElement({id = "Drawing", name = "Drawing", type = MENU})
    ZedMenu.Drawing:MenuElement({id = "drawKillable", name = "Draw Killable R", value = false})

    ZedMenu:MenuElement({id = "blank", type = SPACE , name = ""})
	ZedMenu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..version.. " - LoL Ver: "..lVersion.. ""})
	ZedMenu:MenuElement({id = "blank", type = SPACE , name = "by "..author.. ""})
end

