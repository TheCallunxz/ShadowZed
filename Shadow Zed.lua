--***Shadow Zed***--

if myHero.charName ~= "Zed" then return end

local version,author,lVersion = "v0.1","TheCallunxz","8.9"

local shadow1Prev = "null"
local shadow2Prev = "null"

local shadow1 = "null"
local shadow2 = "null"

local shadow1Timer = 0
local shadow2Timer = 0

local shadow1Swapped = false
local shadow2Swapped = false

local canQuickW2 = true

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
	self:LoadMenu()
    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
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
    ZedMenu.Combo:MenuElement({id = "ignite", name = "Ignite?", value = true})
	
    ZedMenu:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
    ZedMenu.Killsteal:MenuElement({id = "ksQ", name = "KS Q", value = true})

    ZedMenu:MenuElement({id = "Auto", name = "Auto", type = MENU})
    ZedMenu.Auto:MenuElement({id = "autoE", name = "Auto E", value = true})
    ZedMenu.Auto:MenuElement({id = "autoEEnergy", name = "Auto E - Min Energy% Needed", value = 50, min = 0, max = 100, step = 5})

    ZedMenu:MenuElement({type = MENU, id = "Key", name = "Keys Settings"})
	ZedMenu.Key:MenuElement({id = "Combo", name = "Combo Key", key = 32})
	ZedMenu.Key:MenuElement({id = "Harass", name = "Harass Key", key = string.byte("C")})
	ZedMenu.Key:MenuElement({id = "Clear", name = "Clear Key", key = string.byte("V")})
	ZedMenu.Key:MenuElement({id = "LastHit", name = "Last Hit Key", key = string.byte("X")})
    ZedMenu.Key:MenuElement({id = "Flee", name = "Flee Key", key = string.byte("A")})
    
    ZedMenu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
    ZedMenu.Pred:MenuElement({id = "hPred", name = "HPred Hitchance", value = 2, min = 1, max = 5, step = 1})

    ZedMenu:MenuElement({id = "blank", type = SPACE , name = ""})
	ZedMenu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..version.. " - LoL Ver: "..lVersion.. ""})
	ZedMenu:MenuElement({id = "blank", type = SPACE , name = "by "..author.. ""})
end

function ShadowZed:Tick()
    self:getShadowPos1()
    self:getShadowPos2()

    if myHero.dead or Game.IsChatOpen() == true or self:IsRecalling() == true then return end
    if ExtLibEvade and ExtLibEvade.Evading then return end

    if (ZedMenu.Key.Combo:Value() == false) then
		--Auto stuff here
    end
    
    if self:IsWindingUp(myHero) then return end

    if ZedMenu.Key.Combo:Value() then
		self:OnCombo()
	elseif ZedMenu.Key.Harass:Value() then
		self:OnHarass()
	elseif ZedMenu.Key.Clear:Value() then
		self:OnClear()
	elseif ZedMenu.Key.Flee:Value() then
		self:OnFlee()
	end
end

function ShadowZed:OnCombo()
    if (Game.CanUseSpell(_W) == 0) and not self:HasBuff(myHero, "ZedWHandler") then
        PrintChat("COMBO")
    end
end

function ShadowZed:OnHarass()
    PrintChat("HARASS")
end

function ShadowZed:OnClear()
    PrintChat("CLEAR")
end

function ShadowZed:OnFlee()
    PrintChat("FLEE")
end

function ShadowZed:Draw()
    if(shadow1 ~= "null") then
        Draw.Circle(shadow1, 150, 10, Draw.Color(200, 255, 87, 51))
    end
    if(shadow2 ~= "null") then
        Draw.Circle(shadow2, 150, 10, Draw.Color(200, 255, 87, 51))
    end
end

function ShadowZed:getShadowPos1()
    if(shadow1Timer < Game.Timer()) then
        if(shadow1 ~= "null") then
            shadow1Prev = shadow1
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
                        if(obj.pos ~= shadow2) and (obj.pos ~= shadow1) and (obj.pos ~= myHero.pos) and (obj.pos ~= shadow1Prev) and (obj.pos ~= shadow2Prev) then
                            shadow1 = obj.pos
                            shadow1Swapped = false
                            shadow1Timer = Game.Timer() + 5.2
                            PrintChat("1")
                            canQuickW2 = false
                            break
                        end
                    end
                end
            end
        end
    end

    if(shadow1Swapped == false) and (shadow1 ~= "null") and not self:HasBuff(myHero, "ZedWHandler") then
        for i = 0, Game.ParticleCount(), 1 do
            local obj = Game.Particle(i)
            if (obj.name == "Zed_Base_CloneSwap") then
                if(obj.pos ~= shadow2) and (obj.pos ~= shadow1) and (obj.pos ~= myHero.pos) and (obj.pos ~= shadow1Prev) and (obj.pos ~= shadow2Prev) then
                    shadow1 = obj.pos
                    PrintChat("2")
                    break
                end
            end
        end
        shadow1Swapped = true
    end

    if(Game.CanUseSpell(_W) == 0) and not self:HasBuff(myHero, "ZedWHandler") and (canQuickW2 == false) then
        canQuickW2 = true
    end

    if(Game.CanUseSpell(_W) == 32) and not self:HasBuff(myHero, "ZedWHandler") and (canQuickW2 == true)  then
        if(shadow1Timer < Game.Timer()) then
            for i = 0, Game.ParticleCount(), 1 do
                local obj = Game.Particle(i)
                if (obj.name == "Zed_Base_CloneSwap") then
                    if(obj.pos ~= shadow2) and (obj.pos ~= shadow1) and (obj.pos ~= myHero.pos) and (obj.pos ~= shadow1Prev) and (obj.pos ~= shadow2Prev) then
                        shadow1 = obj.pos
                        shadow1Timer = Game.Timer() + 5.2
                        PrintChat("3")
                        shadow1Swapped = true
                        break
                    end
                end
            end
        end
    end

    if(shadow1Swapped == true) and self:HasBuff(myHero, "ZedWHandler") then
        shadow1Prev = shadow1
        shadow1 = "null"
        shadow1Swapped = false
        shadow1Timer = 0
    end

end

function ShadowZed:getShadowPos2()
    if(shadow2Timer < Game.Timer()) then
        if(shadow2 ~= "null") then
            shadow2Prev = shadow2
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
                        if(obj.pos ~= shadow2) and (obj.pos ~= shadow1) and (obj.pos ~= myHero.pos) and (obj.pos ~= shadow1Prev) and (obj.pos ~= shadow2Prev) then
                            shadow2 = obj.pos
                            shadow2Swapped = false
                            shadow2Timer = Game.Timer() + 7.5
                            break
                        end
                    end
                end
            end
        end
    end

    if(shadow2Swapped == false) and (shadow2 ~= "null") and not self:HasBuff(myHero, "ZedR2") then
        for i = 0, Game.ParticleCount(), 1 do
            local obj = Game.Particle(i)
            if (obj.name == "Zed_Base_CloneSwap") then
                if(obj.pos ~= shadow2) and (obj.pos ~= shadow1) and (obj.pos ~= myHero.pos) and (obj.pos ~= shadow1Prev) and (obj.pos ~= shadow2Prev) then
                    shadow2 = obj.pos
                    break
                end
            end
        end
        shadow2Swapped = true
    end

    if(shadow2Swapped == true) and self:HasBuff(myHero, "ZedR2") then
        shadow2Prev = shadow1
        shadow2 = "null"
        shadow2Swapped = false
        shadow2Timer = 0
    end

end

function ShadowZed:GetTarget(range)
	if _G.SDK and _G.SDK.TargetSelector then
		if myHero.ap > myHero.totalDamage then
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL)
		else
			return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL)
		end
	end
end

function ShadowZed:HasBuff(unit, buffName)
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

function ShadowZed:IsRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function ShadowZed:IsWindingUp(unit)
	return unit.activeSpell.valid
end

function OnLoad()
	ShadowZed()
end

