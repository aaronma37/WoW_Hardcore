local _G = _G
local thunderstruck_achievement = CreateFrame("Frame")
_G.achievements.Thunderstruck = thunderstruck_achievement

local blacklist = {
	-- Forbidden fire spells
	["Fire Nova Totem"] = 1,
	["Flame Shock"] = 1,
	["Flametongue Totem"] = 1,
	["Flametongue Weapon"] = 1,
	["Frost Resistance Totem"] = 1,
	["Magma Totem"] = 1,
	["Searing Totem"] = 1,
	-- Forbidden frost spells
	["Fire Resistance Totem"] = 1,
	["Frost Shock"] = 1,
	["Frostbrand Weapon"] = 1,

	-- Same list, now in French
	-- Forbidden fire spells
	["Totem Nova de feu"] = 1,
	["Horion de flammes"] = 1,
	["Totem Langue de feu"] = 1,
	["Arme Langue de feu"] = 1,
	["Totem de résistance au Givre"] = 1,
	["Totem de Magma"] = 1,
	["Totem incendiaire"] = 1,
	-- Forbidden frost spells
	["Totem de résistance au Feu"] = 1,
	["Horion de givre"] = 1,
	["Arme de givre"] = 1,

	-- Same list, now in German
	-- Forbidden fire spells
	["Totem der Feuernova"] = 1,
	["Flammenschock"] = 1,
	["Totem der Flammenzunge"] = 1,
	["Waffe der Flammenzunge"] = 1,
	["Totem des Frostwiderstands"] = 1,
	["Totem der glühenden Magma"] = 1,
	["Totem der Verbrennung"] = 1,
	-- Forbidden frost spells
	["Totem des Feuerwiderstands"] = 1,
	["Frostschock"] = 1,
	["Waffe des Frostbrands"] = 1,

	-- Same list, now in Spanish
	-- Forbidden fire spells
	["Tótem Nova de Fuego"] = 1,
	["Choque de llamas"] = 1,
	["Tótem lengua de Fuego"] = 1,
	["Arma lengua de Fuego"] = 1,
	["Tótem de resistencia a la Escarcha"] = 1,
	["Tótem de magma"] = 1,
	["Tótem abrasador"] = 1,
	-- Forbidden frost spells
	["Tótem de Resistencia al Fuego"] = 1,
	["Choque de Escarcha"] = 1,
	["Arma Estigma de Escarcha"] = 1,

	-- Same list, now in Italian
	-- Forbidden fire spells
--	["Fire Nova Totem"] = 1,
--	["Flame Shock"] = 1,
--	["Flametongue Totem"] = 1,
--	["Flametongue Weapon"] = 1,
--	["Frost Resistance Totem"] = 1,
--	["Magma Totem"] = 1,
--	["Searing Totem"] = 1,
	-- Forbidden frost spells
--	["Fire Resistance Totem"] = 1,
--	["Frost Shock"] = 1,
--	["Frostbrand Weapon"] = 1,

	-- Same list, now in Portuguese
	-- Forbidden fire spells
	["Totem de Nova de Fogo"] = 1,
	["Choque Flamejante"] = 1,
	["Totem de Labaredas"] = 1,
	["Arma de Labaredas"] = 1,
	["Totem de Resistência ao Gelo"] = 1,
--	["Totem de Magma"] = 1, -- Same as French
	["Totem Calcinante"] = 1,
	-- Forbidden frost spells
	["Totem de Resistência ao Fogo"] = 1,
	["Choque Gélido"] = 1,
	["Arma da Marca Gélida"] = 1,

	-- Same list, now in Russian
	-- Forbidden fire spells
	["Тотем кольца огня"] = 1,
	["Огненный шок"] = 1,
	["Тотем языка пламени"] = 1,
	["Оружие языка пламени"] = 1,
	["Тотем сопротивления льду"] = 1,
	["Тотем магмы"] = 1,
	["Опаляющий тотем"] = 1,
	-- Forbidden frost spells
	["Тотем сопротивления огню"] = 1,
	["Ледяной шок"] = 1,
	["Оружие ледяного клейма"] = 1,

	-- Same list, now in Korean
	-- Forbidden fire spells
	["불꽃 회오리 토템"] = 1,
	["화염 충격"] = 1,
	["불꽃의 토템"] = 1,
	["불꽃의 무기"] = 1,
	["냉기 저항 토템"] = 1,
	["용암 토템"] = 1,
	["불타는 토템"] = 1,
	-- Forbidden frost spells
	["화염 저항 토템"] = 1,
	["냉기 충격"] = 1,
	["냉기의 무기"] = 1,

	-- Same list, now in Chinese
	-- Forbidden fire spells
	["火焰新星图腾"] = 1,
	["烈焰震击"] = 1,
	["火舌图腾"] = 1,
	["火舌武器"] = 1,
	["抗寒图腾"] = 1,
	["熔岩图腾"] = 1,
	["灼热图腾"] = 1,
	-- Forbidden frost spells
	["抗火图腾"] = 1,
	["冰霜震击"] = 1,
	["冰封武器"] = 1,
}


-- General info
thunderstruck_achievement.name = "Thunderstruck"
thunderstruck_achievement.title = "Thunderstruck"
thunderstruck_achievement.class = "Shaman"
thunderstruck_achievement.icon_path = "Interface\\Addons\\Hardcore\\Media\\icon_thunderstruck.blp"
thunderstruck_achievement.pts = 10
thunderstruck_achievement.description =
	"Complete the Hardcore challenge without at any point using an ability that deals damage other than Nature. Spells, weapon enhancements, or totems that deal Fire or Frost damage are not allowed. All items and consumables that deal damage other than Nature are allowed."

-- Registers
function thunderstruck_achievement:Register(fail_function_executor)
	thunderstruck_achievement:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	thunderstruck_achievement.fail_function_executor = fail_function_executor
end

function thunderstruck_achievement:Unregister()
	thunderstruck_achievement:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

-- Register Definitions
thunderstruck_achievement:SetScript("OnEvent", function(self, event, ...)
	local arg = { ... }
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local combat_log_payload = { CombatLogGetCurrentEventInfo() }
		-- 2: subevent index, 5: source_name, 14: spell school
		if not (combat_log_payload[5] == nil) then
			if combat_log_payload[5] == UnitName("player") then
				if string.find(combat_log_payload[2], "SPELL_CAST_SUCCESS") ~= nil then
					-- 2 holy, 4 fire, 8 nature, 16 frost, 32 shadow, 64 arcane
					if combat_log_payload[14] ~= 8 then
						if combat_log_payload[13] ~= nil and blacklist[combat_log_payload[13]] ~= nil then
							thunderstruck_achievement.fail_function_executor.Fail(thunderstruck_achievement.name)
						end
					end
				end
			end
		end
	end
end)
