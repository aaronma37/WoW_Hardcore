local _G = _G
local _achievement = CreateFrame("Frame")
_G.passive_achievements.Parkour = _achievement

-- General info
_achievement.name = "Parkour"
_achievement.title = "Parkour (1)"
_achievement.class = "All"
_achievement.icon_path = "Interface\\Addons\\Hardcore\\Media\\icon_speedrunner.blp"
_achievement.category = "Miscellaneous"
_achievement.level_cap = 60
_achievement.bl_text = "Miscellaneous"
_achievement.pts = 5
_achievement.description = "Jump to the Orgrimmar bank ledge and then apply a bandage to Ambassador Rokhstrom"
_achievement.restricted_game_versions = {
	["WotLK"] = 1,
}

-- Registers
function _achievement:Register(succeed_function_executor)
	_achievement.succeed_function_executor = succeed_function_executor
	_achievement:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

function _achievement:Unregister()
	_achievement:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

-- Register Definitions
_achievement:SetScript("OnEvent", function(self, event, ...)
	local arg = { ... }
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, cast_guid, spell_id = ...
		if unit ~= "player" then
			return
		end
		-- Checks where the position is confirmed by First Aid range to a mob
		if spell_id == 746 or spell_id == 1159 or spell_id == 3267 or spell_id == 3268 or
			spell_id == 7926 or spell_id == 7927 or spell_id == 10838 or spell_id == 10839 or
			spell_id == 18608 or spell_id == 23696 then
			-- Check if we are in the Orgrimmar bank ledge and the target is Rokhstrom
			print( "You cast first aid, " .. unit .. ", " .. cast_guid .. ", " .. spell_id )
		end
	end
end)
