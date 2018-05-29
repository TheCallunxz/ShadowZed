--***Shadow Zed***--

if myHero.charName ~= "Zed" then return end

local version,author,lVersion = "v2.1","TheCallunxz","8.10"

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

PrintChat("Thank you for using Shadow Zed | " ..version.. "")

class "ShadowZed"

function ShadowZed:__init()
    self:LoadSpells()
    self:LoadMenu()
    self.SpellsLoaded = false
    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Tick", function() HPred:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
end

function ShadowZed:LoadSpells()
	Q = {Range = 900, Width = 40, Delay = 0.25, Speed = 900, Collision = false, aoe = false, Type = "line"}
	W = {Range = 950, Delay = 0.1, Speed = 1750, Radius = 290, Collision = false, aoe = false, Type = "line"}
	E = {Delay = 0, Speed = 1750, Collision = false, aoe = false, Type = "circular", Radius = 290}
	R = {}
end

function ShadowZed:LoadMenu()
    ZedMenu = MenuElement({type = MENU, id = "Zed", name = "Shadow Zed | " ..version.. "", icon = MenuIcon})
    
	ZedMenu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	ZedMenu.Combo:MenuElement({id = "useQ", name = "Q", value = true})
    ZedMenu.Combo:MenuElement({id = "useW", name = "W", value = true})
    ZedMenu.Combo:MenuElement({id = "useW2", name = "W2", value = false})
    ZedMenu.Combo:MenuElement({id = "useE", name = "E", value = true})
    ZedMenu.Combo:MenuElement({id = "useR", name = "R", value = false})
    ZedMenu.Combo:MenuElement({id = "rHP", name = "Enemy %HP to R", value = 50, min = 0, max = 100, step = 5})
    ZedMenu.Combo:MenuElement({id = "Ignite", name = "Ignite", value = true})

    ZedMenu:MenuElement({id = "Harass", name = "Harass", type = MENU})
    ZedMenu.Harass:MenuElement({id = "useQ", name = "Q", value = true})
    ZedMenu.Harass:MenuElement({id = "useW", name = "W", value = false})
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
    ZedMenu.Pred:MenuElement({id = "pred", name = "Pred to use",  drop = {"TPred", "HPred"}, value = 1})


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
        local rTarget = self:GetTargetR()
        if rTarget ~= nil then
            if ((Game.CanUseSpell(_R) == 0) and not HasBuff(myHero, "ZedR2") and ZedMenu.Combo.useR:Value() and (((rTarget.health/rTarget.maxHealth)*100) <= ZedMenu.Combo.rHP:Value())) then
                self:ComboR()
                self:ComboW()
                self:ComboW2()
            else
                self:ComboW()
                self:ComboE()
                self:ComboQ()
                self:ComboW2()
            end
        else
            self:ComboW()
            self:ComboE()
            self:ComboQ()
            self:ComboW2()
        end
        self:AutoIgnite()
	elseif ZedMenu.Key.Harass:Value() then
		self:OnHarass()
	elseif ZedMenu.Key.Clear:Value() then
		self:OnClear()
	end
end

function ShadowZed:GetPredHitChance(heroPos, target, range, speed, delay, width, collision)
	canhit = 0
	aimpos = 0
	if(ZedMenu.Pred.pred:Value() == 1) then
		castpos, hitchance, temppos = TPred:GetBestCastPosition(target, delay, width, range, speed, heroPos, collision, "line")
		if(hitchance >= 2) then
			canhit = 1
			aimpos = temppos
		end
	elseif(ZedMenu.Pred.pred:Value() == 2) then
		hitchance, temppos = HPred:GetHitchance(heroPos, target, range, speed, delay, width, collision)
		if(hitchance >= 1) then
			canhit = 1
			aimpos = temppos
		end
	elseif(ZedMenu.Pred.pred:Value() == 3) then

	end
    
    return canhit, aimpos
end

function ShadowZed:Dodging()
    self:AutoR2Dead()
    
    if((Game.CanUseSpell(_W) == 0) and (myHero:GetSpellData(_W).name == "ZedW") and readyToW == false) then
        readyToW = true
    end

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
			local qTarget = self:GetTargetQ()
			if qTarget == nil then return end
			if(shadow2 ~= "null") then
				if(GetDistance(qTarget.pos, myHero.pos) < GetDistance(qTarget.pos, shadow2)) then
					if(ZedMenu.Misc.danger:Value()) then
						if(self:checkSafeArea(400, shadow2)) then
							Control.CastSpell(HK_R)
						end
					else
						Control.CastSpell(HK_R)
					end
				end
			end
        end
    end
end

function ShadowZed:checkSafeArea(radius, areaPos, target)
    local target = target or self:GetTargetQ()
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
                    local hitChance, aimPos = self:GetPredHitChance(myHero.pos, enemy, Q.Range, Q.Delay, Q.Speed, Q.Width, true)
                        if (hitChance >= 1) then
                            if (Game.CanUseSpell(_Q) == 0) then
                                Control.CastSpell(HK_Q, aimPos)
                                return
                            end
                        end
                    if(shadow1 ~= "null") then
                        local hitChance, aimPos = self:GetPredHitChance(shadow1, enemy, Q.Range, Q.Delay, Q.Speed, Q.Width, true)
                        if (hitChance >= 1) then
                            if (Game.CanUseSpell(_Q) == 0) then
                                Control.CastSpell(HK_Q, aimPos)
                                return
                            end
                        end
                    end
                    if(shadow2 ~= "null") then
                        local hitChance, aimPos = self:GetPredHitChance(shadow2, enemy, Q.Range, Q.Delay, Q.Speed, Q.Width, true)
                        if (hitChance >= 1) then
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
                    local hitChance, aimPos = self:GetPredHitChance(myHero.pos, enemy, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
                        if (hitChance >= 1) then
                            if (Game.CanUseSpell(_Q) == 0) then
                                Control.CastSpell(HK_Q, aimPos)
                                return
                            end
                        end
                    if(shadow1 ~= "null") then
                        local hitChance, aimPos = self:GetPredHitChance(shadow1, enemy, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
                        if (hitChance >= 1) then
                            if (Game.CanUseSpell(_Q) == 0) then
                                Control.CastSpell(HK_Q, aimPos)
                                return
                            end
                        end
                    end
                    if(shadow2 ~= "null") then
                        local hitChance, aimPos = self:GetPredHitChance(shadow2, enemy, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
                        if (hitChance >= 1) then
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

function ShadowZed:ComboR()
    if (Game.CanUseSpell(_R) == 0) and not HasBuff(myHero, "ZedR2") then
        if ZedMenu.Key.Combo:Value() and ZedMenu.Combo.useR:Value() then
            local rTarget = self:GetTargetR()
            if rTarget == nil then return end
            if(((rTarget.health/rTarget.maxHealth)*100) <= ZedMenu.Combo.rHP:Value()) then
                if(ZedMenu.Misc.danger:Value()) then
                    if(self:checkSafeArea(400, rTarget.pos, rTarget)) then
                        Control.CastSpell(HK_R, rTarget.pos)
                    end
                else
                    Control.CastSpell(HK_R, rTarget.pos)
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
            local hitChance, aimPos = self:GetPredHitChance(myHero.pos, wTarget, W.Range, W.Delay, W.Speed, W.Radius, false)
            local newPos
            if(GetDistance(wTarget.pos, myHero.pos) > E.Radius) then
                newPos = aimPos
                if (hitChance >= 1) then
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
            local hitChance, aimPos = self:GetPredHitChance(myHero.pos, qTarget, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
            if (hitChance >= 1) then
                if (Game.CanUseSpell(_Q) == 0) and (((shadow1 == "null") and (shadow2 == "null") and not (Game.CanUseSpell(_W) == 0)) or (GetManaPercent(myHero) < 50) or (GetDistance(qTarget.pos, myHero.pos) < (W.Range - 100)) or (Game.CanUseSpell(_W) ~= 0) or HasBuff(myHero, "ZedWHandler")) then
                    Control.CastSpell(HK_Q, aimPos)
                    return
                elseif (Game.CanUseSpell(_Q) == 0) and ((shadow1 ~= "null") or (shadow2 ~= "null")) then
                    Control.CastSpell(HK_Q, aimPos)
                    return
                end
            end
            if(shadow1 ~= "null") then
                local hitChance, aimPos = self:GetPredHitChance(shadow1, qTarget, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
                if (hitChance >= 1) then
                    if (Game.CanUseSpell(_Q) == 0) then
                        Control.CastSpell(HK_Q, aimPos)
                        return
                    end
                end
            end
            if(shadow2 ~= "null") then
                local hitChance, aimPos = self:GetPredHitChance(shadow2, qTarget, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
                if (hitChance >= 1) then
                    if (Game.CanUseSpell(_Q) == 0) then
                        Control.CastSpell(HK_Q, aimPos)
                        return
                    end
                end
            end
        end
    end
end

function ShadowZed:ComboW2()
    if (Game.CanUseSpell(_W) == 0 and (myHero:GetSpellData(_W).name == "ZedW2")) then
        if ZedMenu.Key.Combo:Value() and ZedMenu.Combo.useW2:Value() then
            local target = self:GetTargetQ()
            if target == nil then return end
            if(shadow1 ~= "null") then
                shadowDist = GetDistance(shadow1, target.pos)
                playerDist = GetDistance(myHero.pos, target.pos)
                if(shadowDist < playerDist) then
                    if(ZedMenu.Misc.danger:Value()) then
                        if(self:checkSafeArea(400, shadow1)) then
                            Control.CastSpell(HK_W)
                        end
                    else
                        Control.CastSpell(HK_W)
                    end
                end
            end
        end
    end
end

function ShadowZed:OnHarass()
    if myHero.attackData.state == STATE_WINDUP then return end
    if IsWindingUp(myHero) then return end
    --W
    if (Game.CanUseSpell(_W) == 0) and not HasBuff(myHero, "ZedWHandler") then
        if ZedMenu.Key.Harass:Value() and ZedMenu.Harass.useW:Value() then
            local wTarget = self:GetTargetW()
            if wTarget == nil then return end
            local hitChance, aimPos = self:GetPredHitChance(myHero.pos, wTarget, W.Range, W.Delay, W.Speed, W.Radius, false)
            local newPos
            if(GetDistance(wTarget.pos, myHero.pos) > E.Radius) then
                newPos = aimPos
                if (hitChance >= 1) then
                    if (Game.CanUseSpell(_W) == 0) and not HasBuff(myHero, "ZedWHandler") and (myHero:GetSpellData(_W).name ~= "ZedW2") then
                        if ((Game.CanUseSpell(_Q) == 0) or (Game.CanUseSpell(_E) == 0) and GetManaPercent(myHero) > 50) then
                            if(myHero:GetSpellData(_W).name == "ZedW") and (readyToW == true) then
                                Control.CastSpell(HK_W, newPos)
								readyToW = false
								PrintChat("TRIAL")
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

    --Q
    if (Game.CanUseSpell(_Q) == 0) then
        if ZedMenu.Key.Harass:Value() and ZedMenu.Harass.useQ:Value() then
            local qTarget = self:GetTargetQ()
            if qTarget == nil then return end
            local hitChance, aimPos = self:GetPredHitChance(myHero.pos, qTarget, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
            if (hitChance >= 1) then
                if (Game.CanUseSpell(_Q) == 0) then
                    Control.CastSpell(HK_Q, aimPos)
                    return
                end
            end
            if(shadow1 ~= "null") then
                local hitChance, aimPos = self:GetPredHitChance(shadow1, qTarget, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
                if (hitChance >= 1) then
                    if (Game.CanUseSpell(_Q) == 0) then
                        Control.CastSpell(HK_Q, aimPos)
                        return
                    end
                end
            end
            if(shadow2 ~= "null") then
                local hitChance, aimPos = self:GetPredHitChance(shadow2, qTarget, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
                if (hitChance >= 1) then
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
                local Edmg = ({30, 40, 50, 60, 70})[Elvl] + (0.8 * myHero.bonusDamage)

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
                        local hitChance, aimPos = self:GetPredHitChance(myHero.pos, enemy, Q.Range, Q.Delay, Q.Speed, Q.Width, true)
                        if (hitChance >= 1) then
                            if (myHero.attackData.state == STATE_WINDUP or IsWindingUp(myHero) == true) then break end
                            Control.CastSpell(HK_Q, aimPos)
                            break
                        end
                    end
                    --Pierce
                    newQdmg = Qdmg * 0.6
                    if  hp > 0 and hp <= _G.SDK.Damage:CalculateDamage(myHero, enemy, _G.SDK.DAMAGE_TYPE_PHYSICAL, newQdmg) then
                        local hitChance, aimPos = self:GetPredHitChance(myHero.pos, enemy, Q.Range, Q.Delay, Q.Speed, Q.Width, false)
                        if (hitChance >= 1) then
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

function ShadowZed:GetTargetR()
    damageType = _G.SDK.DAMAGE_TYPE_PHYSICAL;
    closeEnemies = self:GetEnemyHeroes(625, myHero.pos)
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

class "HPred"
local _atan = math.atan2
local _pi = math.pi
local _min = math.min
local _abs = math.abs
local _sqrt = math.sqrt
local _huge = math.huge
local _insert = table.insert
local _sort = table.sort
local _find = string.find
local _sub = string.sub
local _len = string.len

local LocalDrawLine					= Draw.Line;
local LocalDrawColor				= Draw.Color;
local LocalDrawCircle				= Draw.Circle;
local LocalDrawText					= Draw.Text;
local LocalControlIsKeyDown			= Control.IsKeyDown;
local LocalControlMouseEvent		= Control.mouse_event;
local LocalControlSetCursorPos		= Control.SetCursorPos;
local LocalControlKeyUp				= Control.KeyUp;
local LocalControlKeyDown			= Control.KeyDown;
local LocalGameCanUseSpell			= Game.CanUseSpell;
local LocalGameLatency				= Game.Latency;
local LocalGameTimer				= Game.Timer;
local LocalGameHeroCount 			= Game.HeroCount;
local LocalGameHero 				= Game.Hero;
local LocalGameMinionCount 			= Game.MinionCount;
local LocalGameMinion 				= Game.Minion;
local LocalGameTurretCount 			= Game.TurretCount;
local LocalGameTurret 				= Game.Turret;
local LocalGameWardCount 			= Game.WardCount;
local LocalGameWard 				= Game.Ward;
local LocalGameObjectCount 			= Game.ObjectCount;
local LocalGameObject				= Game.Object;
local LocalGameMissileCount 		= Game.MissileCount;
local LocalGameMissile				= Game.Missile;
local LocalGameParticleCount 		= Game.ParticleCount;
local LocalGameParticle				= Game.Particle;
local LocalGameIsChatOpen			= Game.IsChatOpen;
local LocalGameIsOnTop				= Game.IsOnTop;
	
local _tickFrequency = .2
local _nextTick = Game.Timer()
local _reviveLookupTable = 
	{ 
		["LifeAura.troy"] = 4, 
		["ZileanBase_R_Buf.troy"] = 3,
		["Aatrox_Base_Passive_Death_Activate"] = 3
		
		--TwistedFate_Base_R_Gatemarker_Red
			--String match would be ideal.... could be different in other skins
	}

--Stores a collection of spells that will cause a character to blink
	--Ground targeted spells go towards mouse castPos with a maximum range
	--Hero/Minion targeted spells have a direction type to determine where we will land relative to our target (in front of, behind, etc)
	
--Key = Spell name
--Value = range a spell can travel, OR a targeted end position type, OR a list of particles the spell can teleport to	
local _blinkSpellLookupTable = 
	{ 
		["EzrealArcaneShift"] = 475, 
		["RiftWalk"] = 500,
		
		--Ekko and other similar blinks end up between their start pos and target pos (in front of their target relatively speaking)
		["EkkoEAttack"] = 0,
		["AlphaStrike"] = 0,
		
		--Katarina E ends on the side of her target closest to where her mouse was... 
		["KatarinaE"] = -255,
		
		--Katarina can target a dagger to teleport directly to it: Each skin has a different particle name. This should cover all of them.
		["KatarinaEDagger"] = { "Katarina_Base_Dagger_Ground_Indicator","Katarina_Skin01_Dagger_Ground_Indicator","Katarina_Skin02_Dagger_Ground_Indicator","Katarina_Skin03_Dagger_Ground_Indicator","Katarina_Skin04_Dagger_Ground_Indicator","Katarina_Skin05_Dagger_Ground_Indicator","Katarina_Skin06_Dagger_Ground_Indicator","Katarina_Skin07_Dagger_Ground_Indicator" ,"Katarina_Skin08_Dagger_Ground_Indicator","Katarina_Skin09_Dagger_Ground_Indicator"  }, 
	}

local _blinkLookupTable = 
	{ 
		"global_ss_flash_02.troy",
		"Lissandra_Base_E_Arrival.troy",
		"LeBlanc_Base_W_return_activation.troy"
		--TODO: Check if liss/leblanc have diff skill versions. MOST likely dont but worth checking for completion sake
		
		--Zed uses 'switch shadows'... It will require some special checks to choose the shadow he's going TO not from...
		--Shaco deceive no longer has any particles where you jump to so it cant be tracked (no spell data or particles showing path)
		
	}

local _cachedBlinks = {}
local _cachedRevives = {}
local _cachedTeleports = {}

--Cache of all TARGETED missiles currently running
local _cachedMissiles = {}
local _incomingDamage = {}

--Cache of active enemy windwalls so we can calculate it when dealing with collision checks
local _windwall
local _windwallStartPos
local _windwallWidth

local _OnVision = {}
function HPred:OnVision(unit)
	if unit == nil or type(unit) ~= "userdata" then return end
	if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {visible = unit.visible , tick = GetTickCount(), pos = unit.pos } end
	if _OnVision[unit.networkID].visible == true and not unit.visible then _OnVision[unit.networkID].visible = false _OnVision[unit.networkID].tick = GetTickCount() end
	if _OnVision[unit.networkID].visible == false and unit.visible then _OnVision[unit.networkID].visible = true _OnVision[unit.networkID].tick = GetTickCount() _OnVision[unit.networkID].pos = unit.pos end
	return _OnVision[unit.networkID]
end

--This must be called manually - It's not on by default because we've tracked down most of the freeze issues to this.
function HPred:Tick()
	
	
	--Update missile cache
	--DISABLED UNTIL LATER.
	--self:CacheMissiles()
	
	--Limit how often tick logic runs
	if _nextTick > Game.Timer() then return end
	_nextTick = Game.Timer() + _tickFrequency
	
	--Update hero movement history	
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t then
			if t.isEnemy then
				HPred:OnVision(t)
			end
		end
	end
	
	--Do not run rest of logic until freeze issues are fully tracked down
	if true then return end
	
	
	--Remove old cached teleports	
	for _, teleport in pairs(_cachedTeleports) do
		if teleport and Game.Timer() > teleport.expireTime + .5 then
			_cachedTeleports[_] = nil
		end
	end	
	
	--Update teleport cache
	HPred:CacheTeleports()	
	
	
	--Record windwall
	HPred:CacheParticles()
	
	--Remove old cached revives
	for _, revive in pairs(_cachedRevives) do
		if Game.Timer() > revive.expireTime + .5 then
			_cachedRevives[_] = nil
		end
	end
	
	--Remove old cached blinks
	for _, revive in pairs(_cachedRevives) do
		if Game.Timer() > revive.expireTime + .5 then
			_cachedRevives[_] = nil
		end
	end
	
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		--Record revives
		if particle and not _cachedRevives[particle.networkID] and  _reviveLookupTable[particle.name] then
			_cachedRevives[particle.networkID] = {}
			_cachedRevives[particle.networkID]["expireTime"] = Game.Timer() + _reviveLookupTable[particle.name]			
			local target = HPred:GetHeroByPosition(particle.pos)
			if target.isEnemy then				
				_cachedRevives[particle.networkID]["target"] = target
				_cachedRevives[particle.networkID]["pos"] = target.pos
				_cachedRevives[particle.networkID]["isEnemy"] = target.isEnemy	
			end
		end
		
		--Record blinks
		if particle and not _cachedBlinks[particle.networkID] and  _blinkLookupTable[particle.name] then
			_cachedBlinks[particle.networkID] = {}
			_cachedBlinks[particle.networkID]["expireTime"] = Game.Timer() + _reviveLookupTable[particle.name]			
			local target = HPred:GetHeroByPosition(particle.pos)
			if target.isEnemy then				
				_cachedBlinks[particle.networkID]["target"] = target
				_cachedBlinks[particle.networkID]["pos"] = target.pos
				_cachedBlinks[particle.networkID]["isEnemy"] = target.isEnemy	
			end
		end
	end
	
end

function HPred:GetEnemyNexusPosition()
	--This is slightly wrong. It represents fountain not the nexus. Fix later.
	if myHero.team == 100 then return Vector(14340, 171.977722167969, 14390); else return Vector(396,182.132507324219,462); end
end


function HPred:GetGuarenteedTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
	--Get hourglass enemies
	local target, aimPosition =self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get reviving target
	local target, aimPosition =self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
	
	--Get teleporting enemies
	local target, aimPosition =self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)	
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get stunned enemies
	local target, aimPosition =self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
end


function HPred:GetReliableTarget(source, range, delay, speed, radius, timingAccuracy, checkCollision)
	--TODO: Target whitelist. This will target anyone which is definitely not what we want
	--For now we can handle in the champ script. That will cause issues with multiple people in range who are goood targets though.
	
	
	--Get hourglass enemies
	local target, aimPosition =self:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get reviving target
	local target, aimPosition =self:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get channeling enemies
	--local target, aimPosition =self:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	--	if target and aimPosition then
	--	return target, aimPosition
	--end
	
	--Get teleporting enemies
	local target, aimPosition =self:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)	
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get instant dash enemies
	local target, aimPosition =self:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
	
	--Get dashing enemies
	local target, aimPosition =self:GetDashingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius, midDash)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get stunned enemies
	local target, aimPosition =self:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end
	
	--Get blink targets
	local target, aimPosition =self:GetBlinkTarget(source, range, speed, delay, checkCollision, radius)
	if target and aimPosition then
		return target, aimPosition
	end	
end

--Will return how many allies or enemies will be hit by a linear spell based on current waypoint data.
function HPred:GetLineTargetCount(source, aimPos, delay, speed, width, targetAllies)
	local targetCount = 0
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and self:CanTargetALL(t) and ( targetAllies or t.isEnemy) then
			
			local predictedPos = self:PredictUnitPosition(t, delay+ self:GetDistance(source, t.pos) / speed)
			local proj1, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(source, aimPos, predictedPos)
			if proj1 and isOnSegment and (self:GetDistanceSqr(predictedPos, proj1) <= (t.boundingRadius + width) * (t.boundingRadius + width)) then
				targetCount = targetCount + 1
			end
		end
	end
	return targetCount
end

--Will return the valid target who has the highest hit chance and meets all conditions (minHitChance, whitelist check, etc)
function HPred:GetUnreliableTarget(source, range, delay, speed, radius, checkCollision, minimumHitChance, whitelist, isLine)
	local _validTargets = {}
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)		
		if t and self:CanTarget(t, true) and (not whitelist or whitelist[t.charName]) then
			local hitChance, aimPosition = self:GetHitchance(source, t, range, delay, speed, radius, checkCollision, isLine)		
			if hitChance >= minimumHitChance then
				_insert(_validTargets, {aimPosition,hitChance, hitChance * 100 + self:CalculateMagicDamage(t, 400)})
			end
		end
	end	
	_sort(_validTargets, function( a, b ) return a[3] >b[3] end)	
	if #_validTargets > 0 then	
		return _validTargets[1][2], _validTargets[1][1]
	end
end

function HPred:GetHitchance(source, target, range, delay, speed, radius, checkCollision, isLine)

	if isLine == nil and checkCollision then
		isLine = true
	end
	
	local hitChance = 1
	local aimPosition = self:PredictUnitPosition(target, delay + self:GetDistance(source, target.pos) / speed)	
	local interceptTime = self:GetSpellInterceptTime(source, aimPosition, delay, speed)
	local reactionTime = self:PredictReactionTime(target, .1, isLine)
	
	--Check if they are walking the same path as the line or very close to it
	if isLine then
		local pathVector = aimPosition - target.pos
		local castVector = (aimPosition - myHero.pos):Normalized()
		if pathVector.x + pathVector.z ~= 0 then
			pathVector = pathVector:Normalized()
			if pathVector:DotProduct(castVector) < -.85 or pathVector:DotProduct(castVector) > .85 then
				if speed > 3000 then
					reactionTime = reactionTime + .25
				else
					reactionTime = reactionTime + .15
				end
			end
		end
	end			

	--If they are standing still give a higher accuracy because they have to take actions to react to it
	if not target.pathing or not target.pathing.hasMovePath then
		hitChancevisionData = 2
	end	
	
	
	local origin,movementRadius = self:UnitMovementBounds(target, interceptTime, reactionTime)
	--Our spell is so wide or the target so slow or their reaction time is such that the spell will be nearly impossible to avoid
	if movementRadius - target.boundingRadius <= radius /2 then
		origin,movementRadius = self:UnitMovementBounds(target, interceptTime, 0)
		if movementRadius - target.boundingRadius <= radius /2 then
			hitChance = 4
		else		
			hitChance = 3
		end
	end	
	
	--If they are casting a spell then the accuracy will be fairly high. if the windup is longer than our delay then it's quite likely to hit. 
	--Ideally we would predict where they will go AFTER the spell finishes but that's beyond the scope of this prediction
	if target.activeSpell and target.activeSpell.valid then
		if target.activeSpell.startTime + target.activeSpell.windup - Game.Timer() >= delay then
			hitChance = 5
		else			
			hitChance = 3
		end
	end
	
	local visionData = HPred:OnVision(target)
	if visionData and visionData.visible == false then
		local hiddenTime = visionData.tick -GetTickCount()
		if hiddenTime < -1000 then
			hitChance = -1
		else
			local targetSpeed = self:GetTargetMS(target)
			local unitPos = target.pos + Vector(target.pos,target.posTo):Normalized() * ((GetTickCount() - visionData.tick)/1000 * targetSpeed)
			local aimPosition = unitPos + Vector(target.pos,target.posTo):Normalized() * (targetSpeed * (delay + (self:GetDistance(myHero.pos,unitPos)/speed)))
			if self:GetDistance(target.pos,aimPosition) > self:GetDistance(target.pos,target.posTo) then aimPosition = target.posTo end
			hitChance = _min(hitChance, 2)
		end
	end
	
	--Check for out of range
	if not self:IsInRange(source, aimPosition, range) then
		hitChance = -1
	end
	
	--Check minion block
	if hitChance > 0 and checkCollision then
		if self:IsWindwallBlocking(source, aimPosition) then
			hitChance = -1		
		elseif self:CheckMinionCollision(source, aimPosition, delay, speed, radius) then
			hitChance = -1
		end
	end
	
	return hitChance, aimPosition
end

function HPred:PredictReactionTime(unit, minimumReactionTime)
	local reactionTime = minimumReactionTime
	
	--If the target is auto attacking increase their reaction time by .15s - If using a skill use the remaining windup time
	if unit.activeSpell and unit.activeSpell.valid then
		local windupRemaining = unit.activeSpell.startTime + unit.activeSpell.windup - Game.Timer()
		if windupRemaining > 0 then
			reactionTime = windupRemaining
		end
	end	
	return reactionTime
end

function HPred:GetDashingTarget(source, range, delay, speed, dashThreshold, checkCollision, radius, midDash)

	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and t.isEnemy and t.pathing.hasMovePath and t.pathing.isDashing and t.pathing.dashSpeed>500  then
			local dashEndPosition = t:GetPath(1)
			if self:IsInRange(source, dashEndPosition, range) then				
				--The dash ends within range of our skill. We now need to find if our spell can connect with them very close to the time their dash will end
				local dashTimeRemaining = self:GetDistance(t.pos, dashEndPosition) / t.pathing.dashSpeed
				local skillInterceptTime = self:GetSpellInterceptTime(source, dashEndPosition, delay, speed)
				local deltaInterceptTime =skillInterceptTime - dashTimeRemaining
				if deltaInterceptTime > 0 and deltaInterceptTime < dashThreshold and (not checkCollision or not self:CheckMinionCollision(source, dashEndPosition, delay, speed, radius)) then
					target = t
					aimPosition = dashEndPosition
					return target, aimPosition
				end
			end			
		end
	end
end

function HPred:GetHourglassTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and t.isEnemy then		
			local success, timeRemaining = self:HasBuff(t, "zhonyasringshield")
			if success then
				local spellInterceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
				local deltaInterceptTime = spellInterceptTime - timeRemaining
				if spellInterceptTime > timeRemaining and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, interceptPosition, delay, speed, radius)) then
					target = t
					aimPosition = t.pos
					return target, aimPosition
				end
			end
		end
	end
end

function HPred:GetRevivingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for _, revive in pairs(_cachedRevives) do	
		if revive.isEnemy then
			local interceptTime = self:GetSpellInterceptTime(source, revive.pos, delay, speed)
			if interceptTime > revive.expireTime - Game.Timer() and interceptTime - revive.expireTime - Game.Timer() < timingAccuracy then
				target = revive.target
				aimPosition = revive.pos
				return target, aimPosition
			end
		end
	end	
end

function HPred:GetInstantDashTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and t.isEnemy and t.activeSpell and t.activeSpell.valid and _blinkSpellLookupTable[t.activeSpell.name] then
			local windupRemaining = t.activeSpell.startTime + t.activeSpell.windup - Game.Timer()
			if windupRemaining > 0 then
				local endPos
				local blinkRange = _blinkSpellLookupTable[t.activeSpell.name]
				if type(blinkRange) == "table" then
					--Find the nearest matching particle to our mouse
					--local target, distance = self:GetNearestParticleByNames(t.pos, blinkRange)
					--if target and distance < 250 then					
					--	endPos = target.pos		
					--end
				elseif blinkRange > 0 then
					endPos = Vector(t.activeSpell.placementPos.x, t.activeSpell.placementPos.y, t.activeSpell.placementPos.z)					
					endPos = t.activeSpell.startPos + (endPos- t.activeSpell.startPos):Normalized() * _min(self:GetDistance(t.activeSpell.startPos,endPos), range)
				else
					local blinkTarget = self:GetObjectByHandle(t.activeSpell.target)
					if blinkTarget then				
						local offsetDirection						
						
						--We will land in front of our target relative to our starting position
						if blinkRange == 0 then				

							if t.activeSpell.name ==  "AlphaStrike" then
								windupRemaining = windupRemaining + .75
								--TODO: Boost the windup time by the number of targets alpha will hit. Need to calculate the exact times this is just rough testing right now
							end						
							offsetDirection = (blinkTarget.pos - t.pos):Normalized()
						--We will land behind our target relative to our starting position
						elseif blinkRange == -1 then						
							offsetDirection = (t.pos-blinkTarget.pos):Normalized()
						--They can choose which side of target to come out on , there is no way currently to read this data so we will only use this calculation if the spell radius is large
						elseif blinkRange == -255 then
							if radius > 250 then
								endPos = blinkTarget.pos
							end							
						end
						
						if offsetDirection then
							endPos = blinkTarget.pos - offsetDirection * blinkTarget.boundingRadius
						end
						
					end
				end	
				
				local interceptTime = self:GetSpellInterceptTime(source, endPos, delay,speed)
				local deltaInterceptTime = interceptTime - windupRemaining
				if self:IsInRange(source, endPos, range) and deltaInterceptTime < timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, endPos, delay, speed, radius)) then
					target = t
					aimPosition = endPos
					return target,aimPosition					
				end
			end
		end
	end
end

function HPred:GetBlinkTarget(source, range, speed, delay, checkCollision, radius)
	local target
	local aimPosition
	for _, particle in pairs(_cachedBlinks) do
		if particle  and self:IsInRange(source, particle.pos, range) then
			local t = particle.target
			local pPos = particle.pos
			if t and t.isEnemy and (not checkCollision or not self:CheckMinionCollision(source, pPos, delay, speed, radius)) then
				target = t
				aimPosition = pPos
				return target,aimPosition
			end
		end		
	end
end

function HPred:GetChannelingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t then
			local interceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
			if self:CanTarget(t) and self:IsInRange(source, t.pos, range) and self:IsChannelling(t, interceptTime) and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then
				target = t
				aimPosition = t.pos	
				return target, aimPosition
			end
		end
	end
end

function HPred:GetImmobileTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)
	local target
	local aimPosition
	for i = 1, LocalGameHeroCount() do
		local t = LocalGameHero(i)
		if t and self:CanTarget(t) and self:IsInRange(source, t.pos, range) then
			local immobileTime = self:GetImmobileTime(t)
			
			local interceptTime = self:GetSpellInterceptTime(source, t.pos, delay, speed)
			if immobileTime - interceptTime > timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, t.pos, delay, speed, radius)) then
				target = t
				aimPosition = t.pos
				return target, aimPosition
			end
		end
	end
end

function HPred:CacheTeleports()
	--Get enemies who are teleporting to towers
	for i = 1, LocalGameTurretCount() do
		local turret = LocalGameTurret(i);
		if turret and turret.isEnemy and not _cachedTeleports[turret.networkID] then
			local hasBuff, expiresAt = self:HasBuff(turret, "teleport_target")
			if hasBuff then
				self:RecordTeleport(turret, self:GetTeleportOffset(turret.pos,223.31),expiresAt)
			end
		end
	end	
	
	--Get enemies who are teleporting to wards	
	for i = 1, LocalGameWardCount() do
		local ward = LocalGameWard(i);
		if ward and ward.isEnemy and not _cachedTeleports[ward.networkID] then
			local hasBuff, expiresAt = self:HasBuff(ward, "teleport_target")
			if hasBuff then
				self:RecordTeleport(ward, self:GetTeleportOffset(ward.pos,100.01),expiresAt)
			end
		end
	end
	
	--Get enemies who are teleporting to minions
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i);
		if minion and minion.isEnemy and not _cachedTeleports[minion.networkID] then
			local hasBuff, expiresAt = self:HasBuff(minion, "teleport_target")
			if hasBuff then
				self:RecordTeleport(minion, self:GetTeleportOffset(minion.pos,143.25),expiresAt)
			end
		end
	end	
end

function HPred:RecordTeleport(target, aimPos, endTime)
	_cachedTeleports[target.networkID] = {}
	_cachedTeleports[target.networkID]["target"] = target
	_cachedTeleports[target.networkID]["aimPos"] = aimPos
	_cachedTeleports[target.networkID]["expireTime"] = endTime + Game.Timer()
end


function HPred:CalculateIncomingDamage()
	_incomingDamage = {}
	local currentTime = Game.Timer()
	for _, missile in pairs(_cachedMissiles) do
		if missile then 
			local dist = self:GetDistance(missile.data.pos, missile.target.pos)			
			if missile.name == "" or currentTime >= missile.timeout or dist < missile.target.boundingRadius then
				_cachedMissiles[_] = nil
			else
				if not _incomingDamage[missile.target.networkID] then
					_incomingDamage[missile.target.networkID] = missile.damage
				else
					_incomingDamage[missile.target.networkID] = _incomingDamage[missile.target.networkID] + missile.damage
				end
			end
		end
	end	
end

function HPred:GetIncomingDamage(target)
	local damage = 0
	if _incomingDamage[target.networkID] then
		damage = _incomingDamage[target.networkID]
	end
	return damage
end


local _maxCacheRange = 3000

--Right now only used to cache enemy windwalls
function HPred:CacheParticles()	
	if _windwall and _windwall.name == "" then
		_windwall = nil
	end
	
	for i = 1, LocalGameParticleCount() do
		local particle = LocalGameParticle(i)		
		if particle and self:IsInRange(particle.pos, myHero.pos, _maxCacheRange) then			
			if _find(particle.name, "W_windwall%d") and not _windwall then
				--We don't care about ally windwalls for now
				local owner =  self:GetObjectByHandle(particle.handle)
				if owner and owner.isEnemy then
					_windwall = particle
					_windwallStartPos = Vector(particle.pos.x, particle.pos.y, particle.pos.z)				
					
					local index = _len(particle.name) - 5
					local spellLevel = _sub(particle.name, index, index) -1
					--Simple fix
					if type(spellLevel) ~= "number" then
						spellLevel = 1
					end
					_windwallWidth = 150 + spellLevel * 25					
				end
			end
		end
	end
end

function HPred:CacheMissiles()
	local currentTime = Game.Timer()
	for i = 1, LocalGameMissileCount() do
		local missile = LocalGameMissile(i)
		if missile and not _cachedMissiles[missile.networkID] and missile.missileData then
			--Handle targeted missiles
			if missile.missileData.target and missile.missileData.owner then
				local missileName = missile.missileData.name
				local owner =  self:GetObjectByHandle(missile.missileData.owner)	
				local target =  self:GetObjectByHandle(missile.missileData.target)		
				if owner and target and _find(target.type, "Hero") then			
					--The missile is an auto attack of some sort that is targeting a player	
					if (_find(missileName, "BasicAttack") or _find(missileName, "CritAttack")) then
						--Cache it all and update the count
						_cachedMissiles[missile.networkID] = {}
						_cachedMissiles[missile.networkID].target = target
						_cachedMissiles[missile.networkID].data = missile
						_cachedMissiles[missile.networkID].danger = 1
						_cachedMissiles[missile.networkID].timeout = currentTime + 1.5
						
						local damage = owner.totalDamage
						if _find(missileName, "CritAttack") then
							--Leave it rough we're not that concerned
							damage = damage * 1.5
						end						
						_cachedMissiles[missile.networkID].damage = self:CalculatePhysicalDamage(target, damage)
					end
				end
			end
		end
	end
end

function HPred:CalculatePhysicalDamage(target, damage)			
	local targetArmor = target.armor * myHero.armorPenPercent - myHero.armorPen
	local damageReduction = 100 / ( 100 + targetArmor)
	if targetArmor < 0 then
		damageReduction = 2 - (100 / (100 - targetArmor))
	end		
	damage = damage * damageReduction	
	return damage
end

function HPred:CalculateMagicDamage(target, damage)			
	local targetMR = target.magicResist * myHero.magicPenPercent - myHero.magicPen
	local damageReduction = 100 / ( 100 + targetMR)
	if targetMR < 0 then
		damageReduction = 2 - (100 / (100 - targetMR))
	end		
	damage = damage * damageReduction
	
	return damage
end


function HPred:GetTeleportingTarget(source, range, delay, speed, timingAccuracy, checkCollision, radius)

	local target
	local aimPosition
	for _, teleport in pairs(_cachedTeleports) do
		if teleport.expireTime > Game.Timer() and self:IsInRange(source,teleport.aimPos, range) then			
			local spellInterceptTime = self:GetSpellInterceptTime(source, teleport.aimPos, delay, speed)
			local teleportRemaining = teleport.expireTime - Game.Timer()
			if spellInterceptTime > teleportRemaining and spellInterceptTime - teleportRemaining <= timingAccuracy and (not checkCollision or not self:CheckMinionCollision(source, teleport.aimPos, delay, speed, radius)) then								
				target = teleport.target
				aimPosition = teleport.aimPos
				return target, aimPosition
			end
		end
	end		
end

function HPred:GetTargetMS(target)
	local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms
	return ms
end

function HPred:Angle(A, B)
	local deltaPos = A - B
	local angle = _atan(deltaPos.x, deltaPos.z) *  180 / _pi	
	if angle < 0 then angle = angle + 360 end
	return angle
end

--Returns where the unit will be when the delay has passed given current pathing information. This assumes the target makes NO CHANGES during the delay.
function HPred:PredictUnitPosition(unit, delay)
	local predictedPosition = unit.pos
	local timeRemaining = delay
	local pathNodes = self:GetPathNodes(unit)
	for i = 1, #pathNodes -1 do
		local nodeDistance = self:GetDistance(pathNodes[i], pathNodes[i +1])
		local nodeTraversalTime = nodeDistance / self:GetTargetMS(unit)
			
		if timeRemaining > nodeTraversalTime then
			--This node of the path will be completed before the delay has finished. Move on to the next node if one remains
			timeRemaining =  timeRemaining - nodeTraversalTime
			predictedPosition = pathNodes[i + 1]
		else
			local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized()
			predictedPosition = pathNodes[i] + directionVector *  self:GetTargetMS(unit) * timeRemaining
			break;
		end
	end
	return predictedPosition
end

function HPred:IsChannelling(target, interceptTime)
	if target.activeSpell and target.activeSpell.valid and target.activeSpell.isChanneling then
		return true
	end
end

function HPred:HasBuff(target, buffName, minimumDuration)
	local duration = minimumDuration
	if not minimumDuration then
		duration = 0
	end
	local durationRemaining
	for i = 1, target.buffCount do 
		local buff = target:GetBuff(i)
		if buff.duration > duration and buff.name == buffName then
			durationRemaining = buff.duration
			return true, durationRemaining
		end
	end
end

--Moves an origin towards the enemy team nexus by magnitude
function HPred:GetTeleportOffset(origin, magnitude)
	local teleportOffset = origin + (self:GetEnemyNexusPosition()- origin):Normalized() * magnitude
	return teleportOffset
end

function HPred:GetSpellInterceptTime(startPos, endPos, delay, speed)	
	local interceptTime = Game.Latency()/2000 + delay + self:GetDistance(startPos, endPos) / speed
	return interceptTime
end

--Checks if a target can be targeted by abilities or auto attacks currently.
--CanTarget(target)
	--target : gameObject we are trying to hit
function HPred:CanTarget(target, allowInvisible)
	return target.isEnemy and target.alive and target.health > 0  and (allowInvisible or target.visible) and target.isTargetable
end

--Derp: dont want to fuck with the isEnemy checks elsewhere. This will just let us know if the target can actually be hit by something even if its an ally
function HPred:CanTargetALL(target)
	return target.alive and target.health > 0 and target.visible and target.isTargetable
end

--Returns a position and radius in which the target could potentially move before the delay ends. ReactionTime defines how quick we expect the target to be able to change their current path
function HPred:UnitMovementBounds(unit, delay, reactionTime)
	local startPosition = self:PredictUnitPosition(unit, delay)
	
	local radius = 0
	local deltaDelay = delay -reactionTime- self:GetImmobileTime(unit)	
	if (deltaDelay >0) then
		radius = self:GetTargetMS(unit) * deltaDelay	
	end
	return startPosition, radius	
end

--Returns how long (in seconds) the target will be unable to move from their current location
function HPred:GetImmobileTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and buff.duration> duration and (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 39 ) then
			duration = buff.duration
		end
	end
	return duration		
end

--Returns how long (in seconds) the target will be slowed for
function HPred:GetSlowedTime(unit)
	local duration = 0
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and buff.duration > duration and buff.type == 10 then
			duration = buff.duration			
			return duration
		end
	end
	return duration		
end

--Returns all existing path nodes
function HPred:GetPathNodes(unit)
	local nodes = {}
	table.insert(nodes, unit.pos)
	if unit.pathing.hasMovePath then
		for i = unit.pathing.pathIndex, unit.pathing.pathCount do
			path = unit:GetPath(i)
			table.insert(nodes, path)
		end
	end		
	return nodes
end

--Finds any game object with the correct handle to match (hero, minion, wards on either team)
function HPred:GetObjectByHandle(handle)
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.handle == handle then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i)
		if minion and minion.handle == handle then
			target = minion
			return target
		end
	end
	
	for i = 1, LocalGameWardCount() do
		local ward = LocalGameWard(i);
		if ward and ward.handle == handle then
			target = ward
			return target
		end
	end
	
	for i = 1, LocalGameTurretCount() do 
		local turret = LocalGameTurret(i)
		if turret and turret.handle == handle then
			target = turret
			return target
		end
	end
	
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		if particle and particle.handle == handle then
			target = particle
			return target
		end
	end
end

function HPred:GetHeroByPosition(position)
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetObjectByPosition(position)
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameMinionCount() do
		local enemy = LocalGameMinion(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameWardCount() do
		local enemy = LocalGameWard(i);
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
	
	for i = 1, LocalGameParticleCount() do 
		local enemy = LocalGameParticle(i)
		if enemy and enemy.pos.x == position.x and enemy.pos.y == position.y and enemy.pos.z == position.z then
			target = enemy
			return target
		end
	end
end

function HPred:GetEnemyHeroByHandle(handle)	
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.handle == handle then
			target = enemy
			return target
		end
	end
end

--Finds the closest particle to the origin that is contained in the names array
function HPred:GetNearestParticleByNames(origin, names)
	local target
	local distance = 999999
	for i = 1, LocalGameParticleCount() do 
		local particle = LocalGameParticle(i)
		if particle then 
			local d = self:GetDistance(origin, particle.pos)
			if d < distance then
				distance = d
				target = particle
			end
		end
	end
	return target, distance
end

--Returns the total distance of our current path so we can calculate how long it will take to complete
function HPred:GetPathLength(nodes)
	local result = 0
	for i = 1, #nodes -1 do
		result = result + self:GetDistance(nodes[i], nodes[i + 1])
	end
	return result
end


--I know this isn't efficient but it works accurately... Leaving it for now.
function HPred:CheckMinionCollision(origin, endPos, delay, speed, radius, frequency)
		
	if not frequency then
		frequency = radius
	end
	local directionVector = (endPos - origin):Normalized()
	local checkCount = self:GetDistance(origin, endPos) / frequency
	for i = 1, checkCount do
		local checkPosition = origin + directionVector * i * frequency
		local checkDelay = delay + self:GetDistance(origin, checkPosition) / speed
		if self:IsMinionIntersection(checkPosition, radius, checkDelay, radius * 3) then
			return true
		end
	end
	return false
end


function HPred:IsMinionIntersection(location, radius, delay, maxDistance)
	if not maxDistance then
		maxDistance = 500
	end
	for i = 1, LocalGameMinionCount() do
		local minion = LocalGameMinion(i)
		if minion and self:CanTarget(minion) and self:IsInRange(minion.pos, location, maxDistance) then
			local predictedPosition = self:PredictUnitPosition(minion, delay)
			if self:IsInRange(location, predictedPosition, radius + minion.boundingRadius) then
				return true
			end
		end
	end
	return false
end

function HPred:VectorPointProjectionOnLineSegment(v1, v2, v)
	assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end

--Determines if there is a windwall between the source and target pos. 
function HPred:IsWindwallBlocking(source, target)
	if _windwall then
		local windwallFacing = (_windwallStartPos-_windwall.pos):Normalized()
		return self:DoLineSegmentsIntersect(source, target, _windwall.pos + windwallFacing:Perpendicular() * _windwallWidth, _windwall.pos + windwallFacing:Perpendicular2() * _windwallWidth)
	end	
	return false
end
--Returns if two line segments cross eachother. AB is segment 1, CD is segment 2.
function HPred:DoLineSegmentsIntersect(A, B, C, D)

	local o1 = self:GetOrientation(A, B, C)
	local o2 = self:GetOrientation(A, B, D)
	local o3 = self:GetOrientation(C, D, A)
	local o4 = self:GetOrientation(C, D, B)
	
	if o1 ~= o2 and o3 ~= o4 then
		return true
	end
	
	if o1 == 0 and self:IsOnSegment(A, C, B) then return true end
	if o2 == 0 and self:IsOnSegment(A, D, B) then return true end
	if o3 == 0 and self:IsOnSegment(C, A, D) then return true end
	if o4 == 0 and self:IsOnSegment(C, B, D) then return true end
	
	return false
end

--Determines the orientation of ordered triplet
--0 = Colinear
--1 = Clockwise
--2 = CounterClockwise
function HPred:GetOrientation(A,B,C)
	local val = (B.z - A.z) * (C.x - B.x) -
		(B.x - A.x) * (C.z - B.z)
	if val == 0 then
		return 0
	elseif val > 0 then
		return 1
	else
		return 2
	end
	
end

function HPred:IsOnSegment(A, B, C)
	return B.x <= _max(A.x, C.x) and 
		B.x >= _min(A.x, C.x) and
		B.z <= _max(A.z, C.z) and
		B.z >= _min(A.z, C.z)
end

--Gets the slope between two vectors. Ignores Y because it is non-needed height data. Its all 2d math.
function HPred:GetSlope(A, B)
	return (B.z - A.z) / (B.x - A.x)
end

function HPred:GetEnemyByName(name)
	local target
	for i = 1, LocalGameHeroCount() do
		local enemy = LocalGameHero(i)
		if enemy and enemy.isEnemy and enemy.charName == name then
			target = enemy
			return target
		end
	end
end

function HPred:IsPointInArc(source, origin, target, angle, range)
	local deltaAngle = _abs(HPred:Angle(origin, target) - HPred:Angle(source, origin))
	if deltaAngle < angle and self:IsInRange(origin,target,range) then
		return true
	end
end

function HPred:GetDistanceSqr(p1, p2)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined GetDistanceSqr target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return _huge
	end
	return (p1.x - p2.x) *  (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) 
end

function HPred:IsInRange(p1, p2, range)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined IsInRange target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return false
	end
	return (p1.x - p2.x) *  (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) < range * range 
end

function HPred:GetDistance(p1, p2)
	if not p1 or not p2 then
		local dInfo = debug.getinfo(2)
		print("Undefined GetDistance target. Please report. Method: " .. dInfo.name .. "  Line: " .. dInfo.linedefined)
		return _huge
	end
	return _sqrt(self:GetDistanceSqr(p1, p2))
end

class "TPred"

function TPred:CutWaypoints(Waypoints, distance, unit)
	local result = {}
	local remaining = distance
	if distance > 0 then
		for i = 1, #Waypoints -1 do
			local A, B = Waypoints[i], Waypoints[i + 1]
			if A and B then 
				local dist = GetDistance(A, B)
				if dist >= remaining then
					result[1] = Vector(A) + remaining * (Vector(B) - Vector(A)):Normalized()
					
					for j = i + 1, #Waypoints do
						result[j - i + 1] = Waypoints[j]
					end
					remaining = 0
					break
				else
					remaining = remaining - dist
				end
			end
		end
	else
		local A, B = Waypoints[1], Waypoints[2]
		result = Waypoints
		result[1] = Vector(A) - distance * (Vector(B) - Vector(A)):Normalized()
	end
	
	return result
end

function TPred:VectorMovementCollision(startPoint1, endPoint1, v1, startPoint2, v2, delay)
	local sP1x, sP1y, eP1x, eP1y, sP2x, sP2y = startPoint1.x, startPoint1.z, endPoint1.x, endPoint1.z, startPoint2.x, startPoint2.z
	local d, e = eP1x-sP1x, eP1y-sP1y
	local dist, t1, t2 = math.sqrt(d*d+e*e), nil, nil
	local S, K = dist~=0 and v1*d/dist or 0, dist~=0 and v1*e/dist or 0
	local function GetCollisionPoint(t) return t and {x = sP1x+S*t, y = sP1y+K*t} or nil end
	if delay and delay~=0 then sP1x, sP1y = sP1x+S*delay, sP1y+K*delay end
	local r, j = sP2x-sP1x, sP2y-sP1y
	local c = r*r+j*j
	if dist>0 then
		if v1 == math.huge then
			local t = dist/v1
			t1 = v2*t>=0 and t or nil
		elseif v2 == math.huge then
			t1 = 0
		else
			local a, b = S*S+K*K-v2*v2, -r*S-j*K
			if a==0 then 
				if b==0 then --c=0->t variable
					t1 = c==0 and 0 or nil
				else --2*b*t+c=0
					local t = -c/(2*b)
					t1 = v2*t>=0 and t or nil
				end
			else --a*t*t+2*b*t+c=0
				local sqr = b*b-a*c
				if sqr>=0 then
					local nom = math.sqrt(sqr)
					local t = (-nom-b)/a
					t1 = v2*t>=0 and t or nil
					t = (nom-b)/a
					t2 = v2*t>=0 and t or nil
				end
			end
		end
	elseif dist==0 then
		t1 = 0
	end
	return t1, GetCollisionPoint(t1), t2, GetCollisionPoint(t2), dist
end


function TPred:GetCurrentWayPoints(object)
	local result = {}
	if object.pathing.hasMovePath then
		table.insert(result, Vector(object.pos.x,object.pos.y, object.pos.z))
		for i = object.pathing.pathIndex, object.pathing.pathCount do
			path = object:GetPath(i)
			table.insert(result, Vector(path.x, path.y, path.z))
		end
	else
		table.insert(result, object and Vector(object.pos.x,object.pos.y, object.pos.z) or Vector(object.pos.x,object.pos.y, object.pos.z))
	end
	return result
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

function TPred:GetWaypointsLength(Waypoints)
	local result = 0
	for i = 1, #Waypoints -1 do
		result = result + GetDistance(Waypoints[i], Waypoints[i + 1])
	end
	return result
end

function TPred:CanMove(unit, delay)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if buff.count > 0 and buff.duration>=delay then
			if (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11) then
				return false -- block everything
			end
		end
	end
	return true
end

function TPred:IsImmobile(unit, delay, radius, speed, from, spelltype)
	local ExtraDelay = speed == math.huge and 0 or (from and unit and unit.pos and (GetDistance(from, unit.pos) / speed))
	if (self:CanMove(unit, delay + ExtraDelay) == false) then
		return true
	end
	return false
end
function TPred:CalculateTargetPosition(unit, delay, radius, speed, from, spelltype)
	local Waypoints = {}
	local Position, CastPosition = Vector(unit.pos), Vector(unit.pos)
	local t
	
	Waypoints = self:GetCurrentWayPoints(unit)
	local Waypointslength = self:GetWaypointsLength(Waypoints)
	local movementspeed = unit.pathing.isDashing and unit.pathing.dashSpeed or unit.ms
	if #Waypoints == 1 then
		Position, CastPosition = Vector(Waypoints[1].x, Waypoints[1].y, Waypoints[1].z), Vector(Waypoints[1].x, Waypoints[1].y, Waypoints[1].z)
		return Position, CastPosition
	elseif (Waypointslength - delay * movementspeed + radius) >= 0 then
		local tA = 0
		Waypoints = self:CutWaypoints(Waypoints, delay * movementspeed - radius)
		
		if speed ~= math.huge then
			for i = 1, #Waypoints - 1 do
				local A, B = Waypoints[i], Waypoints[i+1]
				if i == #Waypoints - 1 then
					B = Vector(B) + radius * Vector(B - A):Normalized()
				end
				
				local t1, p1, t2, p2, D = self:VectorMovementCollision(A, B, movementspeed, Vector(from.x,from.y,from.z), speed)
				local tB = tA + D / movementspeed
				t1, t2 = (t1 and tA <= t1 and t1 <= (tB - tA)) and t1 or nil, (t2 and tA <= t2 and t2 <= (tB - tA)) and t2 or nil
				t = t1 and t2 and math.min(t1, t2) or t1 or t2
				if t then
					CastPosition = t==t1 and Vector(p1.x, 0, p1.y) or Vector(p2.x, 0, p2.y)
					break
				end
				tA = tB
			end
		else
			t = 0
			CastPosition = Vector(Waypoints[1].x, Waypoints[1].y, Waypoints[1].z)
		end
		
		if t then
			if (self:GetWaypointsLength(Waypoints) - t * movementspeed - radius) >= 0 then
				Waypoints = self:CutWaypoints(Waypoints, radius + t * movementspeed)
				Position = Vector(Waypoints[1].x, Waypoints[1].y, Waypoints[1].z)
			else
				Position = CastPosition
			end
		elseif unit.type ~= myHero.type then
			CastPosition = Vector(Waypoints[#Waypoints].x, Waypoints[#Waypoints].y, Waypoints[#Waypoints].z)
			Position = CastPosition
		end
		
	elseif unit.type ~= myHero.type then
		CastPosition = Vector(Waypoints[#Waypoints].x, Waypoints[#Waypoints].y, Waypoints[#Waypoints].z)
		Position = CastPosition
	end
	
	return Position, CastPosition
end

function VectorPointProjectionOnLineSegment(v1, v2, v)
	assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
	local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
	local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
	local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
	local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
	local isOnSegment = rS == rL
	local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
	return pointSegment, pointLine, isOnSegment
end


function TPred:CheckCol(unit, minion, Position, delay, radius, range, speed, from, draw)
	if unit.networkID == minion.networkID then 
		return false
	end
	
	if from and minion and minion.pos and minion.type ~= myHero.type and _G.SDK.HealthPrediction:GetPrediction(minion, delay + GetDistance(from, minion.pos) / speed - Game.Latency()/1000) < 0 then
		return false
	end
	
	local waypoints = self:GetCurrentWayPoints(minion)
	local MPos, CastPosition = #waypoints == 1 and Vector(minion.pos) or self:CalculateTargetPosition(minion, delay, radius, speed, from, "line")
	
	if from and MPos and GetDistanceSqr(from, MPos) <= (range)^2 and GetDistanceSqr(from, minion.pos) <= (range + 100)^2 then
		local buffer = (#waypoints > 1) and 8 or 0 
		
		if minion.type == myHero.type then
			buffer = buffer + minion.boundingRadius
		end
		
		if #waypoints > 1 then
			local proj1, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(from, Position, Vector(MPos))
			if proj1 and isOnSegment and (GetDistanceSqr(MPos, proj1) <= (minion.boundingRadius + radius + buffer) ^ 2) then
				return true
			end
		end
		
		local proj2, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(from, Position, Vector(minion.pos))
		if proj2 and isOnSegment and (GetDistanceSqr(minion.pos, proj2) <= (minion.boundingRadius + radius + buffer) ^ 2) then
			return true
		end
	end
end

function TPred:CheckMinionCollision(unit, Position, delay, radius, range, speed, from)
	if (not _G.SDK) then
		return false
	end
	Position = Vector(Position)
	from = from and Vector(from) or myHero.pos
	local result = false
	for i, minion in ipairs(_G.SDK.ObjectManager:GetEnemyMinions(range)) do
		if self:CheckCol(unit, minion, Position, delay, radius, range, speed, from, draw) then
			return true
		end
	end
	for i, minion in ipairs(_G.SDK.ObjectManager:GetMonsters(range)) do
		if self:CheckCol(unit, minion, Position, delay, radius, range, speed, from, draw) then
			return true
		end
	end
	for i, minion in ipairs(_G.SDK.ObjectManager:GetOtherEnemyMinions(range)) do
		if minion.team ~= myHero.team and self:CheckCol(unit, minion, Position, delay, radius, range, speed, from, draw) then
			return true
		end
	end
	
	return false
end

function TPred:isSlowed(unit, delay, speed, from)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i);
		if from and unit and buff.count > 0 and buff.duration>=(delay + GetDistance(unit.pos, from) / speed) then
			if (buff.type == 10) then
				return true
			end
		end
	end
	return false
end

function TPred:GetSpellInterceptTime(startPos, endPos, delay, speed)	
	assert(startPos, "GetSpellInterceptTime: invalid argument: cannot calculate distance to "..type(p1))
	assert(endPos, "GetSpellInterceptTime: invalid argument: cannot calculate distance to "..type(p2))
	local interceptTime = delay + GetDistance(startPos, endPos) / speed
	return interceptTime
end

function TPred:TryGetBuff(unit, buffname)	
	for i = 1, unit.buffCount do 
		local Buff = unit:GetBuff(i)
		if Buff.name == buffname and Buff.duration > 0 then
			return Buff, true
		end
	end
	return nil, false
end

function TPred:HasBuff(unit, buffname,D,s)
	local D = D or 1 
	local s = s or 1 
	for i = 1, unit.buffCount do 
	local Buff = unit:GetBuff(i)
		if Buff.name == buffname and Buff.count > 0 and Game.Timer() + D/s < Buff.expireTime then
			return true
		end
	end
	return false
end

--Used to find target that is currently in stasis so we can hit them with spells as soon as it ends
--Note: This has not been fully tested yet... It should be close to right though
function TPred:GetStasisTarget(source, range, delay, speed, timingAccuracy)
	local target	
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		local buff, success = self:TryGetBuff(t, "zhonyasringshield")
		if success and buff ~= nil then
			local deltaInterceptTime = self:GetSpellInterceptTime(myHero.pos, t.pos, delay, speed) - buff.duration
			if deltaInterceptTime > -Game.Latency() / 2000 and deltaInterceptTime < timingAccuracy then
				target = t
				return target
			end
		end
	end
end

--Used to cast spells onto targets that are dashing. 
--Can target enemies that are dashing into range. Does not currently account for dashes which render the user un-targetable though.
function TPred:GetInteruptTarget(source, range, delay, speed, timingAccuracy)
	local target	
	for i = 1, Game.HeroCount() do
		local t = Game.Hero(i)
		if t.isEnemy and t.pathing.hasMovePath and t.pathing.isDashing and t.pathing.dashSpeed>500  then
			local dashEndPosition = t:GetPath(1)
			if GetDistance(source, dashEndPosition) <= range then				
				--The dash ends within range of our skill. We now need to find if our spell can connect with them very close to the time their dash will end
				local dashTimeRemaining = GetDistance(t.pos, dashEndPosition) / t.pathing.dashSpeed
				local skillInterceptTime = self:GetSpellInterceptTime(myHero.pos, dashEndPosition, delay, speed)
				local deltaInterceptTime = math.abs(skillInterceptTime - dashTimeRemaining)
				if deltaInterceptTime < timingAccuracy then
					target = t
					return target
				end
			end			
		end
	end
end

function TPred:GetBestCastPosition(unit, delay, radius, range, speed, from, collision, spelltype, timeThreshold)
	assert(unit, "TPred: Target can't be nil")
	
	if not timeThreshold then
		timeThreshold = .35
	end	
	range = range and range - 4 or math.huge
	radius = radius == 0 and 1 or radius - 4
	speed = speed and speed or math.huge
	
	if not from then
		from = Vector(myHero.pos)
	end
	local IsFromMyHero = GetDistanceSqr(from, myHero.pos) < 50*50 and true or false
	
	delay = delay + (0.07 + Game.Latency() / 2000)
	
	local Position, CastPosition = self:CalculateTargetPosition(unit, delay, radius, speed, from, spelltype)
	local HitChance = 1
	Waypoints = self:GetCurrentWayPoints(unit)
	if (#Waypoints == 1) then
		HitChance = 2
	end
	if self:isSlowed(unit, delay, speed, from) then
		HitChance = 2
	end
	
	if GetDistance(myHero.pos, unit.pos) < 250 then
		HitChance = 2
		Position, CastPosition = self:CalculateTargetPosition(unit, delay*0.5, radius, speed*2, from, spelltype)
		Position = CastPosition
	end
	local angletemp = Vector(from):AngleBetween(Vector(unit.pos), Vector(CastPosition))
	if angletemp > 60 then
		HitChance = 1
	elseif angletemp < 10 then
		HitChance = 2
	end
	if (unit.activeSpell and unit.activeSpell.valid) then
		HitChance = 2
		local timeToAvoid = radius / unit.ms +  unit.activeSpell.startTime + unit.activeSpell.windup - Game.Timer() 
		local timeToIntercept = self:GetSpellInterceptTime(from, unit.pos, delay, speed)
		local deltaInterceptTime = timeToIntercept - timeToAvoid		
		if deltaInterceptTime < timeThreshold then
			HitChance = 4
			CastPosition = unit.pos
		end		
	end
	
	if (self:IsImmobile(unit, delay, radius, speed, from, spelltype)) then
		HitChance = 5
		CastPosition = unit.pos
	end
	
	--[[Out of range]]
	if IsFromMyHero then
		if (spelltype == "line" and GetDistanceSqr(from, Position) >= range * range) then
			HitChance = 0
		end
		if (spelltype == "circular" and (GetDistanceSqr(from, Position) >= (range + radius)^2)) then
			HitChance = 0
		end
		if from and Position and (GetDistanceSqr(from, Position) > range ^ 2) then
			HitChance = 0
		end
	end
	radius = radius*2
	
	if collision and HitChance > 0 then
		if collision and self:CheckMinionCollision(unit, unit.pos, delay, radius, range, speed, from) then
			HitChance = -1
		elseif self:CheckMinionCollision(unit, Position, delay, radius, range, speed, from) then
			HitChance = -1
		elseif self:CheckMinionCollision(unit, CastPosition, delay, radius, range, speed, from) then
			HitChance = -1
		end
	end
	if not CastPosition or not Position then
		HitChance = -1
	end
	return CastPosition, HitChance, Position
end

