
--============================================================--
--|| | \ | |                  / ____|         (_)           ||--
--|| |  \| | _____   ____ _  | (___   ___ _ __ _  ___  ___  ||--
--|| | . ` |/ _ \ \ / / _` |  \___ \ / _ \ '__| |/ _ \/ __| ||--
--|| | |\  | (_) \ V / (_| |  ____) |  __/ |  | |  __/\__ \ ||--
--|| |_| \_|\___/ \_/ \__,_| |_____/ \___|_|  |_|\___||___/ ||--
--============================================================--
-- [[Champion: Maokai, Author: Nova, Created: 5/4/16]]
-- Fatures:
--     - Auto Q, W, E
--     - Drawings for q, w, e and r
--     - Auto ignite
--     - Auto exhaust
require('Inspired')
require('OpenPredict')


if GetObjectName(myHero) ~= "Maokai" then return end

local RANGE_Q, RANGE_W, RANGE_E, RANGE_R =  myHero:GetSpellData(_Q).range, myHero:GetSpellData(_W).range,  myHero:GetSpellData(_E).range, myHero:GetSpellData(_R).range
local currentSkin = 0
local IDmg = 0
local summonerNameOne = GetCastName(myHero,SUMMONER_1)
local summonerNameTwo = GetCastName(myHero,SUMMONER_2)
local Ignite = (summonerNameOne:lower():find("summonerdot") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerdot") and SUMMONER_2 or nil))

local n = {}

local levelOrdering={   [1]={_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E},
                        [2]={_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W} }

local Tree = Menu("Tree", "Maokai")

-- GLOBAL CHECK
Tree:Boolean("AutoSpell","Allow Auto Casts",true)

-- SUMMONER SPELLS
Tree:Menu("SP","Summoner Spells")

    Tree.SP:Boolean("Ignite","Auto-Ignite",true)


-- DRAWINGS
Tree:Menu("Draw", "Drawings")

    Tree.Draw:Boolean("DrawsEb", "Enable Drawings", true)
    Tree.Draw:Slider("DrawQuality", "Quality Drawings", 50, 1, 100, 1)

    Tree.Draw:Boolean("DrawQ", "Q Range", true)
        Tree.Draw:ColorPick("ColourQ", "Q Color", {135, 244, 245, 120})
    Tree.Draw:Boolean("DrawW", "W Range", true)
        Tree.Draw:ColorPick("ColourW", "W Color", {135, 244, 245, 120})
    Tree.Draw:Boolean("DrawE", "E Range", true)
        Tree.Draw:ColorPick("ColourE", "E Color", {135, 244, 245, 120})
    Tree.Draw:Boolean("DrawR", "R Range", true)
        Tree.Draw:ColorPick("ColourR", "R Color", {135, 244, 245, 120})

-- COMBO
Tree:Menu("Combo","Combo")
    Tree.Combo:Boolean("ComboEnable","Enable Combo",true)

        Tree.Combo:Boolean("Q","Auto Cast Q",true)
            Tree.Combo:Slider("EChance", "HitChance Q", 5, 0, 100, 1)
        Tree.Combo:Boolean("W","Auto Cast W",true)
        Tree.Combo:Boolean("E","Auto Cast E",true)
        Tree.Combo:Boolean("R","Auto Cast R",true)

-- PREFS
Tree:Menu("Pref","Special Features")
    Tree.Pref:Boolean("SpellCancel","Auto Cancel Spell Chanelling",true)
    Tree.Pref:Boolean("AutoLevel","Auto-Level Up",true)
    Tree.Pref:DropDown("LvlUpType", "Level Up Order", 1, {"Q-W-E","Q-E-W"})
    
-- SKINS
Tree:SubMenu("Skin","Skin")
    Tree.Skin:Boolean("SkinEnable", "Use Skin", false)
    Tree.Skin:Slider("Value", "Skin Number", 0, 0, 6, 1)


-- Automatic Spell Casting
local function SpellCast()
	if #n > 0 then
		for  i = 1, #n do
    	  	local armor = GetArmor(n[i])
    	  	local hp = GetCurrentHP(n[i])
    	  	local hpreg = GetHPRegen(n[i])
    		local shield = GetDmgShield(n[i])
		 	local health = hp * ((100 + ((armor - GetArmorPenFlat(myHero)) * GetArmorPenPercent(myHero))) * .01) + hpreg * 6 + shield
            
            local IReady = Ignite and CanUseSpell(myHero, Ignite) == 0 and 1 or 0
        
            IDmg = (50 + GetLevel(myHero) * 20) * IReady
            
            if IReady == 1 and IDmg > GetCurrentHP(n[i])+GetHPRegen(n[i])*2.5 and GetDistance(n[i]) <= 600 then
                if Tree.SP.Ignite:Value() then
                    CastTargetSpell(n[i], Ignite)
                end
            end
        
            if Tree.Combo.ComboEnable:Value() then
                ComboActivate(n[i])
            end

        end
	end
end

local function MaoE(unit)
    return { delay = 0, speed = math.min(GetDistance(unit.pos)/0.445,2000), radius = 80, range = RANGE_E }
end
local function MaoW(unit)
    return { delay = 0, speed = math.min(GetDistance(unit.pos)/0.445,2000), radius = 80, range = RANGE_W }
end
local function MaoQ(unit)
    return { delay = 0, speed = math.min(GetDistance(unit.pos)/0.445,2000), radius = 80, range = RANGE_Q }
end

-- Auto Skill Combo
function ComboActivate(unit)
	if IOW:Mode() == "Combo" then
		local QReady = Ready(_Q)
		local WReady = Ready(_W)
        local EReady = Ready(_E)
		local RReady = Ready(_R)
        

        --E
		if Tree.Combo.E:Value() and EReady and ValidTarget(unit, RANGE_E) then
			local EPredict = GetPrediction(unit, MaoE(unit))

			if EPredict and EPredict.hitChance >= (Tree.Combo.EChance:Value()/100) then
				myHero:Cast(_E, EPredict.castPos)
			end
		end

        --W
        if Tree.Combo.W:Value() and WReady and ValidTarget(unit, RANGE_W) then
			local WPredict = GetPrediction(unit, MaoW(unit))
			myHero:Cast(_W, unit)
            
		end
        
        --Q
        if Tree.Combo.Q:Value() and QReady and ValidTarget(unit, RANGE_Q ) then
			local QPredict = GetLinearAOEPrediction(unit, MaoQ(unit))
            CastSkillShot(_Q , unit.pos)
		end
        
        --R
        if IsReady(_R) and GotBuff(myHero, "VengefulMaelstrom") ~= 1 and ValidTarget(unit, RANGE_R) and GetDistance(unit) <= RANGE_R then
            CastSpell(_R)
        elseif IsReady(_R) and GotBuff(myHero, "VengefulMaelstrom") == 1 and ValidTarget(unit, RANGE_R) and GetDistance(unit) >= RANGE_R + 400 then
            CastSpell(_R)
        end
    
    end
end

function skin()
	if Tree.Skin.SkinEnable:Value() and Tree.Skin.Value:Value() ~= currentSkin then
		HeroSkinChanger(GetMyHero(),Tree.Skin.Value:Value()) 
		currentSkin = Tree.Skin.Value:Value()
	end
end

-- Automatic Leveling
function AutoLevel()
    if Tree.Pref.AutoLevel:Value() and GetLevelPoints(myHero) >= 1 then
		DelayAction(function() LevelSpell(levelOrdering[Tree.Pref.LvlUpType:Value()][GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(0.500,0.750))
	else
		LevelSpell(levelOrdering[Tree.Pref.LvlUpType:Value()][GetLevel(myHero)-GetLevelPoints(myHero)+1])
	end
end


OnDraw(function(myHero)

    local pos = myHero.pos
    
    if Tree.Draw.DrawsEb:Value() then
        if IsReady(_W) then
            if Tree.Draw.DrawW:Value() then 
                DrawCircle3D(pos.x, pos.y, pos.z, RANGE_W, 1, Tree.Draw.ColourW:Value(), Tree.Draw.DrawQuality:Value()) 
            end
        end
        if IsReady(_E) then
            if Tree.Draw.DrawE:Value() then 
                DrawCircle3D(pos.x, pos.y, pos.z, RANGE_E, 1, Tree.Draw.ColourE:Value(), Tree.Draw.DrawQuality:Value()) 
            end
        end
        if IsReady(_Q) then
            if Tree.Draw.DrawQ:Value() then 
                DrawCircle3D(pos.x, pos.y, pos.z, RANGE_Q, 1, Tree.Draw.ColourQ:Value(), Tree.Draw.DrawQuality:Value()) 
            end
        end
        if IsReady(_R) then
            if Tree.Draw.DrawR:Value() then 
                DrawCircle3D(pos.x, pos.y, pos.z, RANGE_R, 1, Tree.Draw.ColourR:Value(), Tree.Draw.DrawQuality:Value()) 
            end
        end
    end

	if #n > 0 then
		for  i = 1, #n do
			if GetDistance(n[i]) < 2000 then
				local drawPos = GetOrigin(n[i])
        		if IDmg > GetCurrentHP(n[i])+GetHPRegen(n[i])*2.5 then
          			DrawCircle(drawPos, 50, 0, 0, 0xffff0000) --red
                end
	  	    end
	    end
	end
end)

-- Event each frame tick
OnTick(function(myHero)
	n = GetEnemyHeroes()

	if not IsDead(myHero) and Tree.AutoSpell:Value() then
        SpellCast()
        skin()
    end

    if Tree.Pref.AutoLevel:Value() then
        AutoLevel()
    end
end)

-- Start Output
PrintChat("<font color=\'#fc1212\'><b>[Nova]: <font color=\'#ffffff\'>Maokai Loaded!</b></font>")
