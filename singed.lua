
--============================================================--
--|| | \ | |                  / ____|         (_)           ||--
--|| |  \| | _____   ____ _  | (___   ___ _ __ _  ___  ___  ||--
--|| | . ` |/ _ \ \ / / _` |  \___ \ / _ \ '__| |/ _ \/ __| ||--
--|| | |\  | (_) \ V / (_| |  ____) |  __/ |  | |  __/\__ \ ||--
--|| |_| \_|\___/ \_/ \__,_| |_____/ \___|_|  |_|\___||___/ ||--
--============================================================--
-- [[Champion: Singed, Author: Nova, Created: 4/4/16]]
--
-- Fatures:
--     - Invisible poison exploit
--     - Auto ignite
--     - Auto sludge
--
-- To come:
--     - Auto void toss
--     - Fling KS

if GetObjectName(myHero) ~= "Singed" then return end

local xIgnite, IRDY = 0, 0
local summonerNameOne = GetCastName(myHero,SUMMONER_1)
local summonerNameTwo = GetCastName(myHero,SUMMONER_2)
local Ignite = (summonerNameOne:lower():find("summonerdot") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerdot") and SUMMONER_2 or nil))
local n = {}

local Singed = Menu("Singed", "Singed")
Singed:Key("Q", "Q Exploit", string.byte("T"))
Singed:Menu("KS","Killfunctions")
Singed.KS:Boolean("Ignite","Auto-Ignite",true)


local function CheckItemCD()
    IRDY = Ignite and CanUseSpell(myHero, Ignite) == 0 and 1 or 0
end

local function DamageFunc()
    xIgnite = (50 + GetLevel(myHero) * 20) * IRDY
end

local function SpellSequence()
	if #n > 0 then
		for  i = 1, #n do
    	  	local armor = GetArmor(n[i])
    	  	local hp = GetCurrentHP(n[i])
    	  	local hpreg = GetHPRegen(n[i])
    		local shield = GetDmgShield(n[i])
		 	local health = hp * ((100 + ((armor - GetArmorPenFlat(myHero)) * GetArmorPenPercent(myHero))) * .01) + hpreg * 6 + shield
    		if IRDY == 1 and health < xIgnite and GetDistance(n[i]) <= 600 then
                if Singed.KS.Ignite:Value() then
    			    CastTargetSpell(n[i], Ignite)
                end
    		end
		end
	end
end

OnDraw(function(myHero)
	if #n > 0 then
		for  i = 1, #n do
			if GetDistance(n[i]) < 2000 and Valid(n[i]) then
				local drawPos = GetOrigin(n[i])
        	  	local armor = GetArmor(n[i])
        	  	local hp = GetCurrentHP(n[i])
        	  	local hpreg = GetHPRegen(n[i])
        		local shield = GetDmgShield(n[i])
                local health = hp * ((100 + ((armor - GetArmorPenFlat(myHero)) * GetArmorPenPercent(myHero))) * .01) + hpreg * 6 + shield
        		if health < xIgnite then
          			DrawCircle(drawPos, 50, 0, 0, 0xffff0000) --red
                end
	  	    end
	    end
	end
end)

OnTick(function(myHero)
	n = GetEnemyHeroes()

	if not IsDead(myHero) then
		CheckItemCD()
		DamageFunc()
        SpellSequence()
    end

    local mousePos = GetMousePos()

    if Singed.Q:Value() then
        CastSpell(_Q)
        MoveToXYZ(mousePos.x, mousePos.y, mousePos.z)
    end
end)

PrintChat(<font color=\"#fc1212\"><b>[Nova] - <font color=\"#00f20a\">Singed Loaded!</b></font>")
