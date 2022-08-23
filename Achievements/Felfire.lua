local _G = _G
local felfire_achievement = CreateFrame("Frame")
_G.achievements.Felfire = felfire_achievement

-- General info
felfire_achievement.name = "Felfire"
felfire_achievement.title = "Felfire"
felfire_achievement.class = "Warlock"
felfire_achievement.icon_path = "Interface\\Addons\\Hardcore\\Media\\icon_felfire.blp"
felfire_achievement.description =
	"Complete the Hardcore challenge without at any point using an ability that deals damage other than Fire. Spells and Demon abilities that deal Shadow damage are not allowed. All items and consumables that deal damage other than Fire are allowed."
felfire_achievement.forces = {
	"ImpMaster",
}

-- Registers
function felfire_achievement:Register(fail_function_executor)
	felfire_achievement:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	felfire_achievement.fail_function_executor = fail_function_executor
end

function felfire_achievement:Unregister()
	felfire_achievement:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

-- Register Definitions
felfire_achievement:SetScript("OnEvent", function(self, event, ...)
	local arg = { ... }
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local combat_log_payload = { CombatLogGetCurrentEventInfo() }
		-- 2: subevent index, 5: source_name, 14: spell school
		if not (combat_log_payload[5] == nil) then
			if combat_log_payload[5] == UnitName("player") then
				if string.find(combat_log_payload[2], "SPELL_DAMAGE") ~= nil then
					-- 2 holy, 4 fire, 8 nature, 16 frost, 32 shadow, 64 arcane
					if combat_log_payload[14] ~= 4 then
						felfire_achievement.fail_function_executor.Fail(felfire_achievement.name)
					end
				end
			end
		end
	end
end)
