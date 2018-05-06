--***Shadow Zed***--

if myHero.charName ~= "Zed" then return end

local version,author,lVersion = "v0.1","TheCallunxz","8.9"

local shadow1 = "null"
local shadow2 = "null"

local shadow1Timer = 0
local shadow2Timer = 0

local shadow1Swapped = false
local shadow2Swapped = false

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
    return
end

class "ShadowZed"

function ShadowZed:__init()
    self:LoadSpells()
    PrintChat("YEP")
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
end

function HasBuff(unit, buffName)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff ~= nil and buff.count > 0 then
			if buff.name == buffName then
				local CurrentTime = Game.Timer()
				if buff.startTime <= CurrentTime + 0.1 and buff.expireTime >= CurrentTime then
					return true
				end
			end
		end
	end
	return false
end

function IsRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function ShadowZed:LoadSpells()
	Q = {Range = 900, Width = 40, Delay = 0.40, Speed = 900, Collision = false, aoe = false, Type = "line"}
	W = {Range = 650, Delay = 0.40, Speed = 1750, Collision = false, aoe = false, Type = "line"}
	E = {Delay = 0.40, Speed = 1750, Collision = false, aoe = false, Type = "circular", Radius = 290}
	R = {}
end

function ShadowZed:LoadMenu()
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

    ZedMenu:MenuElement({id = "blank", type = SPACE , name = ""})
	ZedMenu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..version.. " - LoL Ver: "..lVersion.. ""})
	ZedMenu:MenuElement({id = "blank", type = SPACE , name = "by "..author.. ""})
end

function ShadowZed:Tick()
    self:getShadowPos1()
    self:getShadowPos2()
    if myHero.dead or Game.IsChatOpen() == true or IsRecalling() == true then return end
end

function ShadowZed:getShadowPos1()
    if(shadow1Timer < Game.Timer()) then
        if(shadow1 ~= "null") then
            shadow1 = "null"
            shadow1Swapped = false
        end
    end
    if (myHero:GetSpellData(_W).name == "ZedW2") then
        if(shadow1 == "null") then
            if(shadow1Timer < Game.Timer()) then
                for i = 0, Game.ParticleCount(), 1 do
                    local obj = Game.Particle(i)
                    if (obj.name == "Zed_Base_W_cloneswap_buf") then
                        shadow1 = obj.pos
                        shadow1Timer = Game.Timer() + 5.5
                        break
                    end
                end
            end
        end
    end

    if(Game.CanUseSpell(_W) ~= 0) and (shadow1 == "null") then
        if(shadow1Timer < Game.Timer()) then
            for i = 0, Game.ParticleCount(), 1 do
                local obj = Game.Particle(i)
                if (obj.name == "Zed_Base_CloneSwap") then
                    shadow1 = obj.pos
                    shadow1Timer = Game.Timer() + 5.5
                    break
                end
            end
        end
    end

    if(shadow1Swapped == false) and (shadow1 ~= "null") and not HasBuff(myHero, "ZedWHandler") then
        for i = 0, Game.ParticleCount(), 1 do
            local obj = Game.Particle(i)
            if (obj.name == "Zed_Base_CloneSwap") then
                shadow1 = obj.pos
                break
            end
        end
        shadow1Swapped = true
    end


end

function ShadowZed:getShadowPos2()
    if(shadow2Timer < Game.Timer()) then
        if(shadow2 ~= "null") then
            shadow2 = "null"
            shadow2Swapped = false
        end
    end
    if (myHero:GetSpellData(_R).name == "ZedR2") then
        if(shadow2 == "null") then
            if(shadow2Timer < Game.Timer()) then
                for i = 0, Game.ParticleCount(), 1 do
                    local obj = Game.Particle(i)
                    if (obj.name == "Zed_Base_R_cloneswap_buf") then
                        shadow2 = obj.pos
                        shadow2Timer = Game.Timer() + 7.7
                        break
                    end
                end
            end
        end
    end

    if(shadow2Swapped == false) and (shadow2 ~= "null") and not HasBuff(myHero, "ZedR2") then
        for i = 0, Game.ParticleCount(), 1 do
            local obj = Game.Particle(i)
            if (obj.name == "Zed_Base_CloneSwap") then
                shadow2 = obj.pos
                break
            end
        end
        shadow2Swapped = true
    end

end

function OnLoad()
	ShadowZed()
end

