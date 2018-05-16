--***Shadow Zed***--

if myHero.charName ~= "Zed" then return end

local version,author,lVersion = "v1.2","TheCallunxz","8.10"

local shadow1Prev = "null"
local shadow2Prev = "null"

local shadow1 = "null"
local shadow2 = "null"

local shadow1Timer = 0
local shadow2Timer = 0

local shadow1Swapped = false
local shadow2Swapped = false

local canQuickW2 = true

local readyToW = true

local LocalGameMinionCount = Game.MinionCount
local LocalGameMinion = Game.Minion
local LocalGameHeroCount = Game.HeroCount;
local LocalGameHero = Game.Hero;

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
    PrintChat("Thank you for using Shadow Zed | " ..version.. "")
else
    PrintChat("ERROR. Failed to load libraries")
    return
end

class "ShadowZed"

function ShadowZed:__init()
    self:LoadSpells()
    self:LoadMenu()
    self.SpellsLoaded = false
    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
end

function ShadowZed:LoadSpells()
	Q = {Range = 900, Width = 40, Delay = 0.2, Speed = 900, Collision = false, aoe = false, Type = "line"}
	W = {Range = 850, Delay = 0.1, Speed = 1750, Radius = 290, Collision = false, aoe = false, Type = "line"}
	E = {Delay = 0, Speed = 1750, Collision = false, aoe = false, Type = "circular", Radius = 290}
	R = {}
end

function ShadowZed:LoadMenu()
    ZedMenu = MenuElement({type = MENU, id = "Zed", name = "Shadow Zed | " ..version.. "", icon = MenuIcon})
    
	ZedMenu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	ZedMenu.Combo:MenuElement({id = "useQ", name = "Q", value = true})
	ZedMenu.Combo:MenuElement({id = "useW", name = "W", value = true})
    ZedMenu.Combo:MenuElement({id = "useE", name = "E", value = true})
    ZedMenu.Combo:MenuElement({id = "Ignite", name = "Ignite", value = true})

    ZedMenu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	ZedMenu.Harass:MenuElement({id = "useQ", name = "Q", value = true})
    ZedMenu.Harass:MenuElement({id = "useE", name = "E", value = true})

    ZedMenu:MenuElement({id = "Clear", name = "Clear", type = MENU})
	ZedMenu.Clear:MenuElement({id = "useQ", name = "Q", value = true})
    ZedMenu.Clear:MenuElement({id = "useE", name = "E", value = true})
    ZedMenu.Clear:MenuElement({id = "energy", name = "Min Energy% Needed", value = 25, min = 0, max = 100, step = 5})
	
    ZedMenu:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
    ZedMenu.Killsteal:MenuElement({id = "ksQ", name = "KS Q", value = true})

    ZedMenu:MenuElement({id = "Auto", name = "Auto", type = MENU})
    ZedMenu.Auto:MenuElement({id = "autoE", name = "Auto E", value = true})
    ZedMenu.Auto:MenuElement({id = "autoEEnergy", name = "Auto E - Min Energy% Needed", value = 25, min = 0, max = 100, step = 5})
    ZedMenu.Auto:MenuElement({id = "autoR2", name = "Auto R2 on Death Mark", value = false})

    ZedMenu:MenuElement({id = "Dodge", name = "Dodge", type = MENU})
    ZedMenu.Dodge:MenuElement({id = "dodgeW2", name = "Use W2 to Dodge", value = true})
    ZedMenu.Dodge:MenuElement({id = "dodgeR2", name = "Use R2 to Dodge", value = true})
    ZedMenu.Dodge:MenuElement({id = "DodgeList", name = "Dodge List", type = MENU})

    ZedMenu:MenuElement({id = "Misc", name = "Misc", type = MENU})
    ZedMenu.Misc:MenuElement({id = "focusR", name = "Focus R Target", value = true})
    ZedMenu.Misc:MenuElement({id = "danger", name = "Only Move To Shadow When Safe", value = true})

    ZedMenu:MenuElement({type = MENU, id = "Key", name = "Keys Settings"})
	ZedMenu.Key:MenuElement({id = "Combo", name = "Combo Key", key = 32})
	ZedMenu.Key:MenuElement({id = "Harass", name = "Harass Key", key = string.byte("C")})
	ZedMenu.Key:MenuElement({id = "Clear", name = "Clear Key", key = string.byte("V")})
    
    ZedMenu:MenuElement({type = MENU, id = "Pred", name = "Prediction"})
    ZedMenu.Pred:MenuElement({id = "hPred", name = "HPred Hitchance", value = 1, min = 1, max = 5, step = 1})


    ZedMenu:MenuElement({id = "blank", type = SPACE , name = ""})
	ZedMenu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..version.. " - LoL Ver: "..lVersion.. ""})
	ZedMenu:MenuElement({id = "blank", type = SPACE , name = "by "..author.. ""})
end

function ShadowZed:Tick()
    self:getShadowPos1()
    self:getShadowPos2()

    if myHero.dead or Game.IsChatOpen() == true or IsRecalling() == true then return end

    self:Dodging()

    if ExtLibEvade and ExtLibEvade.Evading then return end    

    if (ZedMenu.Key.Combo:Value() == false) then
        self:AutoE()
        self:KS_Q()
    end

    if ZedMenu.Key.Combo:Value() then
        self:ComboW()
        self:ComboE()
        self:ComboQ()
        self:AutoIgnite()
	elseif ZedMenu.Key.Harass:Value() then
		self:OnHarass()
	elseif ZedMenu.Key.Clear:Value() then
		self:OnClear()
	end
end

function ShadowZed:Dodging()
    self:AutoR2Dead()

    if not self.SpellsLoaded then
		self:LoadBlockSpells()
    end

    if ((myHero:GetSpellData(_W).name == "ZedW2") or (myHero:GetSpellData(_R).name == "ZedR2")) and (self.SpellsLoaded == true) then --Credits to DamnedNoob/Sikaka/ZeroTwo
        for i = 1, #self:GetEnemyHeroes(2000, myHero.pos) do
            local current = self:GetEnemyHeroes(2000, myHero.pos)[i]
            if current then
                if current.activeSpell and current.activeSpell.valid and
                    (current.activeSpell.target == myHero.handle or 
                        GetDistance(current.activeSpell.placementPos, myHero.pos) <= myHero.boundingRadius * 2 + current.activeSpell.width) and not 
                        string.find(current.activeSpell.name:lower(), "attack") then
                    for j = 0, 3 do
                        local spell = current:GetSpellData(j)
                        if ZedMenu.Dodge.DodgeList[spell.name] and ZedMenu.Dodge.DodgeList[spell.name]:Value() and spell.name == current.activeSpell.name then
                            local startPos = current.activeSpell.startPos
                            local placementPos = current.activeSpell.placementPos
                            local width = 0
                            if current.activeSpell.width > 0 then
                                width = current.activeSpell.width
                            else
                                width = 100
                            end
                            local distance = GetDistance(myHero.pos, placementPos)											
                            if current.activeSpell.target == myHero.handle then
                                self:DodgeToShadow1()
                                return
                            else
                                if distance <= width * 2 + myHero.boundingRadius then
                                    self:DodgeToShadow1()
                                    break
                                end
                            end							
                        end
                    end
                end
            end
        end
    end
end

function ShadowZed:DodgeToShadow1()
    if(ZedMenu.Dodge.dodgeW2:Value() and shadow1 ~= "null" and (myHero:GetSpellData(_W).name == "ZedW2")) then
        if(ZedMenu.Misc.danger:Value()) then
            if(self:checkSafeArea(400, shadow1)) then
                Control.CastSpell(HK_W)
            else
                self:DodgeToShadow2()
            end
        else
            Control.CastSpell(HK_W)
        end
    else
        self:DodgeToShadow2()
    end
end

function ShadowZed:DodgeToShadow2()
    if(ZedMenu.Dodge.dodgeR2:Value() and shadow2 ~= "null" and (myHero:GetSpellData(_R).name == "ZedR2")) then
        if(ZedMenu.Misc.danger:Value()) then
            if(self:checkSafeArea(400, shadow2)) then
                Control.CastSpell(HK_R)
            end
        end
    end
end

function ShadowZed:LoadBlockSpells() --Credits to DamnedNoob/Sikaka/ZeroTwo
	for i = 1, LocalGameHeroCount(i) do
        local t = LocalGameHero(i)
		if t and t.isEnemy then		
			for slot = 0, 3 do
				local enemy = t
				local spellName = enemy:GetSpellData(slot).name
				if slot == 0 then
					ZedMenu.Dodge.DodgeList:MenuElement({ id = spellName, name = enemy.charName.."- Q", value = true })
				end
				if slot == 1 then
					ZedMenu.Dodge.DodgeList:MenuElement({ id = spellName, name = enemy.charName.."- W", value = true })
				end
				if slot == 2 then
					ZedMenu.Dodge.DodgeList:MenuElement({ id = spellName, name = enemy.charName.."- E", value = true })
				end
				if slot == 3 then
					ZedMenu.Dodge.DodgeList:MenuElement({ id = spellName, name = enemy.charName.."- R", value = true })
                end
                self.SpellsLoaded = true			
			end
		end
	end
end

function ShadowZed:AutoR2Dead() 
    if(ZedMenu.Auto.autoR2:Value() and HasBuff(myHero, "ZedR2")) then
        deathMark = false

        for i = 0, Game.ParticleCount(), 1 do
            local obj = Game.Particle(i)
            if (obj.name == "Zed_Base_R_buf_tell") then
                deathMark = true
                break
            end
        end

        if(deathMark == true) then
            if(ZedMenu.Misc.danger:Value()) then
                if(shadow2 ~= "null") then
                    if(self:checkSafeArea(400, shadow2)) then
                        Control.CastSpell(HK_R)
                    end
                end
            else
                Control.CastSpell(HK_R)
            end
        end
    end
end

function ShadowZed:checkSafeArea(radius, areaPos)
    local target = self:GetTargetQ()
    local closeEnemies = self:GetEnemyHeroes(radius, areaPos)
    local closeAllies = self:GetAllyHeroes(radius, areaPos)
    local closeEnemiesHere = self:GetEnemyHeroes(radius, myHero.pos)
    local closeAlliesHere = self:GetAllyHeroes(radius, myHero.pos)
    local safelvl = 0
    local safelvlhere = 0
    

    for i = 1, #closeEnemiesHere do
        local enemy = closeEnemiesHere[i];
        if(enemy ~= target) then
            safelvlhere = safelvlhere - 1
            if(enemy.health > myHero.health) then
                safelvlhere = safelvlhere - 1
            end
        end
    end

    for i = 1, #closeAlliesHere do
        local ally = closeAlliesHere[i];
        safelvlhere = safelvlhere + 1
        if(ally.health > myHero.health) then
            safelvlhere = safelvlhere + 1
        end
    end

    for i = 1, #closeEnemies do
        local enemy = closeEnemies[i];
        if(enemy ~= target) then
            safelvl = safelvl - 1
            if(enemy.health > myHero.health) then
                safelvl = safelvl - 1
            end
        end
    end

    for i = 1, #closeAllies do
        local ally = closeAllies[i];
        safelvl = safelvl + 1
        if(ally.health > myHero.health) then
            safelvl = safelvl + 1
        end
    end

    return (safelvl >= safelvlhere)
end

function ShadowZed:AutoE()
    if ZedMenu.Auto.autoE:Value() then
        closeEnemies = ShadowZed:GetShadowTargets(E.Radius - 10)
        if (closeEnemies[1] ~= nil) then
            if(GetManaPercent(myHero) > (ZedMenu.Auto.autoEEnergy:Value())) then
                if (Game.CanUseSpell(_E) == 0) then
                    Control.CastSpell(HK_E)
                    return
                end
            end
        end
    end
end

function ShadowZed:KS_Q()
    if ZedMenu.Killsteal.ksQ:Value() then
        closeEnemies = ShadowZed:GetShadowTargets(Q.Range)
        for i = 1, #closeEnemies do
            local enemy = closeEnemies[i];
            local hp = _G.SDK.HealthPrediction:GetPrediction(enemy, Q.Delay)
            if (Game.CanUseSpell(_Q) == 0) then
                local Qdmg = ({80, 115, 150, 185, 220})[myHero:GetSpellData(_Q).level] + 0.9 * myHero.bonusDamage
                if  hp > 0 and hp <= _G.SDK.Damage:CalculateDamage(myHero, enemy, _G.SDK.DAMAGE_TYPE_PHYSICAL, Qdmg) then
                    local hitChance, aimPos = HPred:GetHitchance(myHero.pos, enemy, Q.Range, Q.Delay, Q.Speed, Q.Width, true)
                        if (hitChance >= ZedMenu.Pred.hPred:Value()) then
                            if (Game.CanUseSpell(_Q) == 0) then
                                Control.CastSpell(HK_Q, aimPos)
                                return
                            end
                        end
                    if(shadow1 ~= "null") then
                        local hitChance, aimPos = HPred:GetHitchance(shadow1, enemy, Q.Range, Q.Delay, Q.Speed, Q.Width, true)
                        if (hitChance >= ZedMenu.Pred.hPred:Value()) then
                            if (Game.CanUseSpell(_Q) == 0) then
                                Control.CastSpell(HK_Q, aimPos)
                                return
                            end
                        end
                    end
                    if(shadow2 ~= "null") then
                        local hitChance, aimPos = HPred:GetHitchance(shadow2, enemy, Q.Range, Q.Delay, Q.Speed, Q.Width, true)
                        if (hitChance >= ZedMenu.Pred.hPred:Value()) then
                            if (Game.CanUseSpell(_Q) == 0) then
                                Control.CastSpell(HK_Q, aimPos)
                                return
                            end
                        end
                    end
                end
                --Pierce
                newQdmg = Qdmg * 0.6
                if  hp > 0 and hp <= _G.SDK.Damage:CalculateDamage(myHero, enemy, _G.SDK.DAMAGE_TYPE_PHYSICAL, newQdmg) then
                    local hitChance, aimPos = HPred:GetHitchance(myHero.pos, enemy, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
                        if (hitChance >= ZedMenu.Pred.hPred:Value()) then
                            if (Game.CanUseSpell(_Q) == 0) then
                                Control.CastSpell(HK_Q, aimPos)
                                return
                            end
                        end
                    if(shadow1 ~= "null") then
                        local hitChance, aimPos = HPred:GetHitchance(shadow1, enemy, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
                        if (hitChance >= ZedMenu.Pred.hPred:Value()) then
                            if (Game.CanUseSpell(_Q) == 0) then
                                Control.CastSpell(HK_Q, aimPos)
                                return
                            end
                        end
                    end
                    if(shadow2 ~= "null") then
                        local hitChance, aimPos = HPred:GetHitchance(shadow2, enemy, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
                        if (hitChance >= ZedMenu.Pred.hPred:Value()) then
                            if (Game.CanUseSpell(_Q) == 0) then
                                Control.CastSpell(HK_Q, aimPos)
                                return
                            end
                        end
                    end
                end
            end
        end
    end
end

function ShadowZed:AutoIgnite()
    if ZedMenu.Combo.Ignite:Value() then
        closeEnemies = self:GetEnemyHeroes(600, myHero.pos)
        for i = 1, #closeEnemies do
            local enemy = closeEnemies[i];
            local IgniteDmg = (55 + 25 * myHero.levelData.lvl)
            if (enemy.health + enemy.shieldAD) < IgniteDmg or HasBuff(enemy, "zedrtargetmark") then
                closeAllies = self:GetAllyHeroes(300, enemy.pos)
                if (closeAllies[1] == nil) then 
                    if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and (Game.CanUseSpell(SUMMONER_1) == 0) then
                        Control.CastSpell(HK_SUMMONER_1, enemy)
                        break
                    elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and (Game.CanUseSpell(SUMMONER_2) == 0) then
                        Control.CastSpell(HK_SUMMONER_2, enemy)
                        break
                    end
                end
            end
        end
    end
end

function ShadowZed:ComboW()
    --W
    if (Game.CanUseSpell(_W) == 0) and not HasBuff(myHero, "ZedWHandler") then
        if ZedMenu.Key.Combo:Value() and ZedMenu.Combo.useW:Value() then
            local wTarget = self:GetTargetW()
            if wTarget == nil then return end
            local hitChance, aimPos = HPred:GetHitchance(myHero.pos, wTarget, W.Range, W.Delay, W.Speed, W.Radius, false)
            local newPos
            if(GetDistance(wTarget.pos, myHero.pos) > E.Radius) then
                newPos = aimPos
                if (hitChance >= ZedMenu.Pred.hPred:Value()) then
                    if (Game.CanUseSpell(_W) == 0) and not HasBuff(myHero, "ZedWHandler") and (myHero:GetSpellData(_W).name ~= "ZedW2") then
                        if ((Game.CanUseSpell(_Q) == 0) or (Game.CanUseSpell(_E) == 0) and GetManaPercent(myHero) > 50) then
                            if(myHero:GetSpellData(_W).name == "ZedW") and (readyToW == true) then
                                Control.CastSpell(HK_W, newPos)
                                readyToW = false
                                if((Game.CanUseSpell(_E) == 0)) then
                                    Control.CastSpell(HK_E)
                                end
                                if((Game.CanUseSpell(_Q) == 0)) then
                                    Control.CastSpell(HK_Q, newPos)
                                end
                                return
                            end
                        end
                    end
                end
            else
                newPos = myHero.pos + Vector(myHero.pos, aimPos):Normalized() * 900
                if (Game.CanUseSpell(_W) == 0) and not HasBuff(myHero, "ZedWHandler") and (myHero:GetSpellData(_W).name ~= "ZedW2") then
                    if ((Game.CanUseSpell(_Q) == 0) and GetManaPercent(myHero) > 50) and (readyToW == true) then
                        Control.CastSpell(HK_W, newPos)
                        readyToW = false
                        Control.CastSpell(HK_Q, aimPos)
                        return
                    end
                end
            end
        end
    end
end

function ShadowZed:ComboE()
    --E
    if (Game.CanUseSpell(_E) == 0) then
        local eTarget = self:GetTargetE()
        if eTarget == nil then return end
        if ZedMenu.Key.Combo:Value() and ZedMenu.Combo.useE:Value() then
            if(GetDistance(eTarget.pos, myHero.pos) < E.Radius) then
                Control.CastSpell(HK_E)
                return
            end
            if(shadow1 ~= "null") then
                if(GetDistance(eTarget.pos, shadow1) < E.Radius) then
                    Control.CastSpell(HK_E)
                    return
                end
            end
            if(shadow2 ~= "null") then
                if(GetDistance(eTarget.pos, shadow2) < E.Radius) then
                    Control.CastSpell(HK_E)
                    return
                end
            end
        end
    end
end

function ShadowZed:ComboQ()
    --Q
    if (Game.CanUseSpell(_Q) == 0) then
        if ZedMenu.Key.Combo:Value() and ZedMenu.Combo.useQ:Value() then
            local qTarget = self:GetTargetQ()
            if qTarget == nil then return end
            local hitChance, aimPos = HPred:GetHitchance(myHero.pos, qTarget, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
            if (hitChance >= ZedMenu.Pred.hPred:Value()) then
                if (Game.CanUseSpell(_Q) == 0) and (((shadow1 == "null") and (shadow2 == "null") and not (Game.CanUseSpell(_W) == 0)) or (GetManaPercent(myHero) < 50) or (GetDistance(qTarget.pos, myHero.pos) < (W.Range - 100)) or (Game.CanUseSpell(_W) ~= 0) or HasBuff(myHero, "ZedWHandler")) then
                    Control.CastSpell(HK_Q, aimPos)
                    return
                elseif (Game.CanUseSpell(_Q) == 0) and ((shadow1 ~= "null") or (shadow2 ~= "null")) then
                    Control.CastSpell(HK_Q, aimPos)
                    return
                end
            end
            if(shadow1 ~= "null") then
                local hitChance, aimPos = HPred:GetHitchance(shadow1, qTarget, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
                if (hitChance >= ZedMenu.Pred.hPred:Value()) then
                    if (Game.CanUseSpell(_Q) == 0) then
                        Control.CastSpell(HK_Q, aimPos)
                        return
                    end
                end
            end
            if(shadow2 ~= "null") then
                local hitChance, aimPos = HPred:GetHitchance(shadow2, qTarget, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
                if (hitChance >= ZedMenu.Pred.hPred:Value()) then
                    if (Game.CanUseSpell(_Q) == 0) then
                        Control.CastSpell(HK_Q, aimPos)
                        return
                    end
                end
            end
        end
    end
end

function ShadowZed:OnHarass()
    if myHero.attackData.state == STATE_WINDUP then return end
    if IsWindingUp(myHero) then return end
    --Q
    if (Game.CanUseSpell(_Q) == 0) then
        if ZedMenu.Key.Harass:Value() and ZedMenu.Harass.useQ:Value() then
            local qTarget = self:GetTargetQ()
            if qTarget == nil then return end
            local hitChance, aimPos = HPred:GetHitchance(myHero.pos, qTarget, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
            if (hitChance >= ZedMenu.Pred.hPred:Value()) then
                if (Game.CanUseSpell(_Q) == 0) then
                    Control.CastSpell(HK_Q, aimPos)
                    return
                end
            end
            if(shadow1 ~= "null") then
                local hitChance, aimPos = HPred:GetHitchance(shadow1, qTarget, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
                if (hitChance >= ZedMenu.Pred.hPred:Value()) then
                    if (Game.CanUseSpell(_Q) == 0) then
                        Control.CastSpell(HK_Q, aimPos)
                        return
                    end
                end
            end
            if(shadow2 ~= "null") then
                local hitChance, aimPos = HPred:GetHitchance(shadow2, qTarget, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
                if (hitChance >= ZedMenu.Pred.hPred:Value()) then
                    if (Game.CanUseSpell(_Q) == 0) then
                        Control.CastSpell(HK_Q, aimPos)
                        return
                    end
                end
            end
        end
    end

    --E
    if (Game.CanUseSpell(_E) == 0) then
        local eTarget = self:GetTargetE()
        if eTarget == nil then return end
        if ZedMenu.Key.Harass:Value() and ZedMenu.Harass.useE:Value() then
            if(GetDistance(eTarget.pos, myHero.pos) < E.Radius) then
                Control.CastSpell(HK_E)
                return
            end
            if(shadow1 ~= "null") then
                if(GetDistance(eTarget.pos, shadow1) < E.Radius) then
                    Control.CastSpell(HK_E)
                    return
                end
            end
            if(shadow2 ~= "null") then
                if(GetDistance(eTarget.pos, shadow2) < E.Radius) then
                    Control.CastSpell(HK_E)
                    return
                end
            end
        end
    end
end

function ShadowZed:OnClear()
    if ZedMenu.Key.Clear:Value() then
        if(GetManaPercent(myHero) > (ZedMenu.Clear.energy:Value())) then
            local EnemyMinions = GetEnemyMinions(Q.Range)
            for i = 1, #EnemyMinions do
                local enemy = EnemyMinions[i];
                local hp = _G.SDK.HealthPrediction:GetPrediction(enemy, Q.Delay)
                local Qlvl = 1
                local Elvl = 1

                if (Game.CanUseSpell(_Q) == 0) then
                   Qlvl = myHero:GetSpellData(_Q).level
                end
                if (Game.CanUseSpell(_E) == 0) then
                    Elvl = myHero:GetSpellData(_Q).level
                end

                local Qdmg = ({80, 115, 150, 185, 220})[Qlvl] + (0.9 * myHero.bonusDamage)
                local Edmg = ({60, 85, 110, 135, 160})[Elvl] + (0.8 * myHero.bonusDamage)

                if (Game.CanUseSpell(_E) == 0 and ZedMenu.Clear.useE:Value()) then
                    if  hp > 0 and hp <= _G.SDK.Damage:CalculateDamage(myHero, enemy, _G.SDK.DAMAGE_TYPE_PHYSICAL, Edmg) then
                        if(GetDistance(enemy.pos, myHero.pos) < E.Radius) then
                            Control.CastSpell(HK_E)
                            break
                        end
                        if(shadow1 ~= "null") then
                            if(GetDistance(enemy.pos, shadow1) < E.Radius) then
                                Control.CastSpell(HK_E)
                                break
                            end
                        end
                        if(shadow2 ~= "null") then
                            if(GetDistance(enemy.pos, shadow2) < E.Radius) then
                                Control.CastSpell(HK_E)
                                break
                            end
                        end
                    end
                end

                if (Game.CanUseSpell(_Q) == 0 and ZedMenu.Clear.useQ:Value()) then
                    if  hp > 0 and hp <= _G.SDK.Damage:CalculateDamage(myHero, enemy, _G.SDK.DAMAGE_TYPE_PHYSICAL, Qdmg) then
                        local hitChance, aimPos = HPred:GetHitchance(myHero.pos, enemy, Q.Range, Q.Delay, Q.Speed, Q.Width, true)
                        if (hitChance >= ZedMenu.Pred.hPred:Value()) then
                            if (myHero.attackData.state == STATE_WINDUP or IsWindingUp(myHero) == true) then break end
                            Control.CastSpell(HK_Q, aimPos)
                            break
                        end
                    end
                    --Pierce
                    newQdmg = Qdmg * 0.6
                    if  hp > 0 and hp <= _G.SDK.Damage:CalculateDamage(myHero, enemy, _G.SDK.DAMAGE_TYPE_PHYSICAL, newQdmg) then
                        local hitChance, aimPos = HPred:GetHitchance(myHero.pos, enemy, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
                        if (hitChance >= ZedMenu.Pred.hPred:Value()) then
                            if (myHero.attackData.state == STATE_WINDUP or IsWindingUp(myHero) == true) then break end
                            Control.CastSpell(HK_Q, aimPos)
                            break
                        end
                    end
                end
            end
        end
    end
end

function ShadowZed:Draw()
   --[[ if(shadow1 ~= "null") then
        Draw.Circle(shadow1, 150, 10, Draw.Color(200, 255, 87, 51))
    end
    if(shadow2 ~= "null") then
        Draw.Circle(shadow2, 150, 10, Draw.Color(200, 255, 87, 51))
    end]]--
end

function ShadowZed:GetShadowTargets(range)
    closeEnemies = self:GetEnemyHeroes(range, myHero.pos)
    if(shadow1 ~= "null") then
        closeEnemies = tableMerge(closeEnemies, self:GetEnemyHeroes(range, shadow1))
    end
    if(shadow2 ~= "null") then
        closeEnemies = tableMerge(closeEnemies, self:GetEnemyHeroes(range, shadow2))
    end
    return closeEnemies
end

function ShadowZed:GetTargetQ()
    damageType = _G.SDK.DAMAGE_TYPE_PHYSICAL;

    closeEnemies = self:GetShadowTargets(Q.Range)

    if(ZedMenu.Misc.focusR:Value()) then
        for i = 1, #closeEnemies do
            local target = closeEnemies[i];
            if(HasBuff(target, "zedrtargetmark") or HasBuff(target, "zedrdeathmark")) then
                return target
            end
        end
    end

    return _G.SDK.TargetSelector:GetTarget(closeEnemies, damageType);
end

function ShadowZed:GetTargetW()
    damageType = _G.SDK.DAMAGE_TYPE_PHYSICAL;

    closeEnemies = self:GetEnemyHeroes(W.Range, myHero.pos)

    if(ZedMenu.Misc.focusR:Value()) then
        for i = 1, #closeEnemies do
            local target = closeEnemies[i];
            if(HasBuff(target, "zedrtargetmark") or HasBuff(target, "zedrdeathmark")) then
                return target
            end
        end
    end

    return _G.SDK.TargetSelector:GetTarget(closeEnemies, damageType);
end

function ShadowZed:GetTargetE()
    damageType = _G.SDK.DAMAGE_TYPE_PHYSICAL;

    closeEnemies = self:GetShadowTargets(E.Radius)

    if(ZedMenu.Misc.focusR:Value()) then
        for i = 1, #closeEnemies do
            local target = closeEnemies[i];
            if(HasBuff(target, "zedrtargetmark") or HasBuff(target, "zedrdeathmark")) then
                return target
            end
        end
    end
    return _G.SDK.TargetSelector:GetTarget(closeEnemies, damageType);
end

function ShadowZed:GetEnemyHeroes(range, fromPos)
    local result = {};
    for i = 1, LocalGameHeroCount() do
        local hero = LocalGameHero(i);
        if _G.SDK.Utilities:IsValidTarget(hero) and hero.isEnemy then
            if _G.SDK.Utilities:IsInRange(fromPos, hero, range) then
                _G.SDK.Linq:Add(result, hero);
            end
        end
    end
    return result;
end

function ShadowZed:GetAllyHeroes(range, fromPos)
    local result = {};
    for i = 1, LocalGameHeroCount() do
        local hero = LocalGameHero(i);
        if _G.SDK.Utilities:IsValidTarget(hero) and not hero.isEnemy and (hero ~= myHero) then
            if _G.SDK.Utilities:IsInRange(fromPos, hero, range) then
                _G.SDK.Linq:Add(result, hero);
            end
        end
    end
    return result;
end

function ShadowZed:getShadowPos1()

    if((readyToW == false) and (Game.CanUseSpell(_W) ~= 0)) then
        readyToW = true
    end

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
                            canQuickW2 = false
                            break
                        end
                    end
                end
            end
        end
    end

    if(shadow1Swapped == false) and (shadow1 ~= "null") and not HasBuff(myHero, "ZedWHandler") then
        for i = 0, Game.ParticleCount(), 1 do
            local obj = Game.Particle(i)
            if (obj.name == "Zed_Base_CloneSwap") then
                if(obj.pos ~= shadow2) and (obj.pos ~= shadow1) and (obj.pos ~= myHero.pos) and (obj.pos ~= shadow1Prev) and (obj.pos ~= shadow2Prev) then
                    shadow1 = obj.pos
                    break
                end
            end
        end
        shadow1Swapped = true
    end

    if(Game.CanUseSpell(_W) == 0) and not HasBuff(myHero, "ZedWHandler") and (canQuickW2 == false) then
        canQuickW2 = true
    end

    if(Game.CanUseSpell(_W) == 32) and not HasBuff(myHero, "ZedWHandler") and (canQuickW2 == true)  then
        if(shadow1Timer < Game.Timer()) then
            for i = 0, Game.ParticleCount(), 1 do
                local obj = Game.Particle(i)
                if (obj.name == "Zed_Base_CloneSwap") then
                    if(obj.pos ~= shadow2) and (obj.pos ~= shadow1) and (obj.pos ~= myHero.pos) and (obj.pos ~= shadow1Prev) and (obj.pos ~= shadow2Prev) then
                        shadow1 = obj.pos
                        shadow1Timer = Game.Timer() + 5.2
                        shadow1Swapped = true
                        break
                    end
                end
            end
        end
    end

    if(shadow1Swapped == true) and HasBuff(myHero, "ZedWHandler") then
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

    if(shadow2Swapped == false) and (shadow2 ~= "null") and not HasBuff(myHero, "ZedR2") then
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

    if(shadow2Swapped == true) and HasBuff(myHero, "ZedR2") then
        shadow2Prev = shadow1
        shadow2 = "null"
        shadow2Swapped = false
        shadow2Timer = 0
    end

end

function GetTarget(range)
	if _G.SDK then
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
	else
		return _G.GOS:GetTarget(range,"AD")
	end
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

function tableMerge(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                tableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

function IsRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function IsWindingUp(unit)
	return unit.activeSpell.valid
end

function GetDistanceSqr(a, b)
	if a.pos ~= nil then
		a = a.pos;
	end
	if b.pos ~= nil then
		b = b.pos;
	end
	if a.z ~= nil and b.z ~= nil then
		local x = (a.x - b.x)
		local z = (a.z - b.z)
		return x * x + z * z
	else
		local x = (a.x - b.x)
		local y = (a.y - b.y)
		return x * x + y * y
	end
end

function GetDistance(a, b)
	return math.sqrt(GetDistanceSqr(a, b))
end

function GetManaPercent(unit)
	return unit.mana / unit.maxMana * 100
end

function GetEnemyMinions(range)
	local result = {}
	local counter = 1
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i);
		if minion.isEnemy and minion.team ~= 300 and minion.valid and minion.alive and minion.visible and minion.isTargetable then
			if GetDistanceSqr(myHero, minion) <= range * range then
				result[counter] = minion
				counter = counter + 1
			end
		end
	end
	return result
end

function OnLoad()
	ShadowZed()
end

